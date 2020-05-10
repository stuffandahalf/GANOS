	.code16
	.global _start

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
	mov $0x7e00, %di
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
	pushw %ax
	divl %ecx
	# eax = entries / sector
	popw %bx
	popw %dx
	addw %bx, %di

	# eax = entries / sector
	# bx = sector size
	# dl = drive number
	# di = target address
	
	
1:	# load sector array part
	

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

str:
	.asciz "Hello World!\r\n"

sector_size:
	.word 512

no_ext_str:
	.asciz "No int 13h extensions\r\n"
sector_load_fail_str:
	.asciz "Failed to load sectors"

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

