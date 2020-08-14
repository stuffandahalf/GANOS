	.code16
	.globl _start

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

halt:
	cli
	hlt

print:
	pushw %ax
	movb $0x0e, %ah
1:	# loop
	lodsb
	testb %al, %al	# if %al == 0)
	je 2f
	int $0x10
	jmp 1b
2:	# end
	popw %ax
	ret

str:
	.asciz "Hello World!\r\n"

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

