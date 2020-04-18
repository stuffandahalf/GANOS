	.org 0x500

setup:
	xorw %ax, %ax
	movw %ax, %ds
	movw 0x9c00, %sp

go_unreal:
	cli
	pushw %ds
	lgdt (gdtinfo)
	
	movd %cr0, %eax
	orb 1, %al
	movd %eax, %cr0

	jmp $+2

	movw 0x08, %bx
	movw %bx, %ds

	andb 0xfe, %al
	movd %eax, %cr0

	popw ds
	sti

halt:
	cli
	hlt	

gdtinfo:
	.word gdt_end - gdt - 1
	.double gdt

gdt:
	.double 0, 0
flat_desc:
	.byte 0xff, 0xff, 0, 0, 0, 0b10010010, 0b1100111, 0
gdt_end:

