	.code16
	.globl _start

	.set LOAD_ADDR, 0x7c00
	.set LINK_ADDR, top
	.set MBR_SZ, bottom - top
	.set PART_ENTRY_SZ, 16

	.set BOOTABLE_FLAG, 0x80

top:
	# set up stack
	xorw %ax, %ax
	movw %ax, %ss
	movw $LOAD_ADDR, %sp

	# preserve PnP address
	pushw %es
	pushw %di
	pushw %dx

	# finish preparing environment
	movw %ax, %es

	# relocate loaded mbr to link address
	movw $MBR_SZ, %cx
	movw $LOAD_ADDR, %si
	movw $LINK_ADDR, %di
	rep movsb

	ljmp $0, $_start

_start:
	sti

	movw $str0, %si
	call print

	movb $4, %cl
	movw $part_tab, %di
1:
	incb part
	movb (%di), %al
	testb $BOOTABLE_FLAG, %al
	jnz 2f
	addw $PART_ENTRY_SZ, %di
	decb %cl
	jnz 1b
	jmp halt
2:
	movb 1(%di), %dh
	movw 2(%di), %cx
	movw $LOAD_ADDR, %bx
	movw $0x0201, %ax
	int $0x13
	jnc 3f
	addw $PART_ENTRY_SZ, %di
	decb %cl
	jnz 1b
	jmp halt

3:
	movw $str1, %si
	call print

	popw %dx
	popw %di
	popw %es

	jmp LOAD_ADDR

halt:
	pushw %si
	movw $halt_str, %si
	call print
	popw %si
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

str0: .asciz "MBR loaded\r\nSearching for bootable partition\r\n"
str1: .ascii "Jumping to VBR of partition "
part: .byte '0'
	.asciz "\r\n"
halt_str: .asciz "halted"

	.org top+446

part_tab:
#part0: .quad 0, 0
part0: .byte 0x80, 0, 2, 0, 0x0b, 0, 0, 0
.long 2, 2880
part1: .quad 0, 0
part2: .quad 0, 0
part3: .quad 0, 0

boot_sig: .byte 0x55, 0xaa

bottom:

