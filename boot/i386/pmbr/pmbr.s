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
	mov $.Lno_ext_str, %si
	call print
	jmp halt
.Lno_ext_str:
	.asciz "No int 13h extensions\r\n"
1:	# extensions present

load_gpt_hdr:
	xorl %eax, %eax
	xorl %ebx, %ebx
	incb %bl			# eax = 0, ebx = 1
	pushl %eax
	pushl %ebx
	pushw %ax
	pushw $0x7e00
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
	movw $0x7e00, %si
	call print

halt:
	cli
	hlt

.if 0
# arguments on stack
# sp -> return address (2 bytes)
#       number of sectors (2 bytes)
#       offset (2 bytes)
#       segment (2 bytes)
#       first LBA low (4 bytes)
#		first LBA high (4 bytes)
#
# dl = drive num
# carry flag set on fail
load_sectors:
	pushw %bp
	movw %sp, %bp
	pushw %dx

	movl -12(%bp), %edx	# eax = LBA high
	jnz .Lfail
	movl -8(%bp), %eax	# eax = LBA low
	divl sec_per_track
	inc %edx
	pushl %edx

	xorl %edx, %edx
	divl heads

	movl %eax, %ecx
	movl %edx, %edx
	popl %eax

	popw %dx

.Lfail:	# fail
	stc
.Lexit:	# success
	popw %bp
	ret
.equ ld_retry, 3
.endif

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

#legacy_sector_size:
#	.word 512
#sector_size:
#	.word 512

heads:
	.byte 0
sec_per_track:
	.word 0
cylinders:
	.word 0

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
