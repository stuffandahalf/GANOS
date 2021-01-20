	.code16
	.globl _start

	.set LOAD_ADDR, 0x7c00
	.set LINK_ADDR, top
	.set VBR_SZ, bottom-top

top:
	#jmp LOAD_ADDR+begin-top
	hlt
	#jmp begin-top		# jump to relocation
	.ascii "ALiX    "			# OEM
bpb:
	.word 512					# offset 0, bytes per sector
	.byte 1						# offset 2, sectors per cluster
	.word 1						# offset 3, number of reserved sectors
	.byte 2						# offset 5, number of file allocation tables
	.word 224					# offset 6, number of root directory entries
	.word 2880					# offset 8, number of sectors
	.byte 0xfe					# offset 10, media type
	.word 9						# offset 11, logical sectors per FAT
	.word 18					# offset 13, physical sectors per track
	.word 2						# offset 15, number of heads
	.word 0						# offset 17, number of hidden sectors

begin:
	cli
	hlt
	xorw %ax, %ax
	movw %ax, %ss
	movw $top, %sp

	# preserve pnp address
	pushw %es
	pushw %di
	
	movw %ax, %es

	movw $LOAD_ADDR, %si
	movw $LINK_ADDR, %di
	movw $VBR_SZ, %cx
	rep movsb
	
	ljmp $0x0000, $_start

_start:

halt:
	cli
	hlt

print:
	pushw %si
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
	popw %si
	ret
	
	.org top+510

boot_sig: .byte 0x55, 0xaa

bottom:
