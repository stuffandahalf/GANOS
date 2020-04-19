	.code16
	.global _start

_start:
	cli
	xorw %ax, %ax
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %ss
	movw $_start, %sp
	#sti

	pushw %ax
	pushw $1f
	retf
1:	# normalized segments and IP

go_unreal:
	pushw ds

	lgdt (gdtinfo)

	movd %cr0, %eax
	orb $1, %al
	movd %eax, %cr0

	jmp .+2

	movw $0x08, %bx
	movw %bx, %ds

	andb $0xfe, %al
	movd %eax, %cr0

	popw ds
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
    testb %al, %al # if al == 0
    je 2f
    int $0x10
    jmp 1b
2:	# end
    popw %ax
    ret

str: .asciz "Hello World!\r\n"

gdtinfo:
	.word gdt_end - gdt - 1
	.long gdt

gdt:
	.long 0, 0
flatdesc:
	.byte 0xff, 0xff, 0, 0, 0, 0b10010010, 0b11001111, 0
gdt_end:

	.org _start+446

.part0:
	.space 16, 0
.part1:
	.space 16, 0
.part2:
	.space 16, 0
.part3:
	.space 16, 0

boot_sig:
	.byte 0x55
	.byte 0xaa
