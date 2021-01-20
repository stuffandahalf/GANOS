	.code16
	.globl _start

	.set BUFFER, $0x500

top:
	xorw %ax, %ax
	movw %ax, %ss
	movw $top, %sp
	pushw %es
	pushw %di
	movw %ax, %es
	ljmp $0x0000, $_start

_start:
	movw $str, %si
	call print

verify:
	movb $0x41, %ah
	movw $0x55aa, %bx
	int $0x13
	jnc 1f
	movw $ns_str, %si
	call print
	jmp halt
1:	# present

load_header:
	pushl $0x00000000
	pushl $0x00000001
	pushw $0x0050
	pushw $0x0000
	pushw $0x0010
	movw %sp, %si
	int $0x10
	jc halt
	addw (%si), %sp
	
halt:
	cli
	hlt
	
print:
	pushw %ax
	movb $0x0e, %ah
1:
	lodsb
	testb %al, %al
	jz 2f
	int $0x10
	jmp 1b
2:
	popw %ax
	ret

str:	.asciz "Hello World!\r\n"
ns_str:	.asciz "Not supported\r\n"

	.org top+446

part0:	.quad 0, 0
part1:	.quad 0, 0
part2:	.quad 0, 0
part3:	.quad 0, 0

boot_sig: .byte 0x55, 0xaa

bottom:
