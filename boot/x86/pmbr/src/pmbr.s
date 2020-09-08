	.code16
	.global _start

	.extern sector_buffer

_start:
	cli
	xorw %ax, %ax
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %ss
	movw $_start, %sp

	pushw %ax
	pushw $1f
	lret
1:	# normalized segments and IP
	sti

begin:
	movw $str, %si
	call print

verify_disk_extensions:
	# dl = drive num
	movb $0x41, %ah
	movw $0x55aa, %bx
	int $0x13
	jnc 1f
	test $1, %cx
	jnz 1f
	mov $no_ext_str, %si
	call print
	jmp halt
1:	# extensions present

get_disk_params:
	subw $28, %sp
	pushw $0x1e
	mov %sp, %si
	pushw %bp
	mov %sp, %bp
	movb $42, %ah
	int $0x13

	movw -32(%bp), %ax
	movw %ax, sector_size

	popw %bp
	addw $30, %sp

load_gpt_hdr:
	mov $sector_buffer, %di
	xorl %eax, %eax
	xorl %ebx, %ebx
	incb %bl			# eax = 0, ebx = 1
	pushl %eax
	pushl %ebx
	pushw %ax
	pushw %di
	pushw %bx
	pushw $0x0010

	#movw %ss, %ds		# ds and ss are already both 0
	movw %sp, %si
	movb $0x42, %ah
	int $0x13
	jnc 1f
	movw $sector_load_fail_str, %si
	call print
	jmp halt
1:
	addw $0x10, %sp

.if 0
	movw %di, %si
	call print
.endif

locate_efi_part:
	pushw %dx
	movl 84(%di), %ecx	# ecx = entry size
	xorl %eax, %eax
	xorl %edx, %edx
	movw sector_size, %ax	# edx:eax = sector size
	divl %ecx
	# eax = entries / sector
	popw %dx

	# eax = entries / sector
	# dl = drive number
	# di = gpt header
	# di+bx = target address
	# (sp) = partition entries
	
	movw %di, %bx
	addw %bx, %bx
	# bx = target address
	
	# set up int 13h packet
	pushl 76(%di)
	pushl 72(%di)
	pushw %ss
	pushw %bx
	pushl $0x00010010	# one sector, 0x10 bytes packet size
	
	movw %sp, %si
	
	pushl %eax	# preserve entries per sector
1:	# load sector array part
	movb $0x42, %ah
	int $0x13
	
	movl -4(%si), %eax	# reload eax with entries / sector
	movw 4(%si), %bx	# reload target address
2:	# check next partition entry
	pushw %si
	pushw %di
	
	movw $efi_part_guid, %si
	movw %bx, %di
	movw $16, %cx
	repe cmpsb

	popw %di
	popw %si
	je 5f
	# get ready to check next entry
	decl %eax
	jnz 3f
	addl $1, 8(%si)
	adcl $0, 12(%si)
	jmp 1b	# last partition in sector
3:	# What to do next
	addw 84(%di), %bx
	decl 80(%di)
	jz 4f
	jmp 2b
4:	# No EFI partition
	movw $no_efi_str, %si
	call print
	jmp halt
5:	# found EFI partition
	movw $found_efi_str, %si
	call print
	
load_efi_part:
	

halt:
	cli
	hlt

print:
	pushw %ax
	movb $0x0e, %ah
1:	# loop
	lodsb
	testb %al, %al # if al == 0
	je 2f
	int $0x10
	jmp 1b
2:	# end
	popw %ax
	ret

efi_part_guid:
	.byte 0x28, 0x73, 0x2a, 0xc1, 0x1f, 0xf8, 0xd2, 0x11
	.byte 0xba, 0x4b, 0x00, 0xa0, 0xc9, 0x3e, 0xc9, 0x3b

str:
	.asciz "Hello World!\r\n"
sector_size:
	.word 512
no_ext_str:
	.asciz "No int 13h extensions\r\n"
sector_load_fail_str:
	.asciz "Failed to load sectors"
found_efi_str:
	.asciz "Found EFI"
no_efi_str:
	.asciz "No EFI"

	.org _start+446

part0:
	.space 16, 0
part1:
	.space 16, 0
part2:
	.space 16, 0
part3:
	.space 16, 0

boot_sig:
	.byte 0x55
	.byte 0xaa

.if 0
sector2_str:
	.asciz "This is from LBA 1!!!\r\n"

.org sector2_str + 0x200
.endif

