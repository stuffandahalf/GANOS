	.code16
	.globl _start

top:

bpb:
	jmp _start
	nop
	.ascii "ALiX    "		/* OEM */
	.word 512				/* bytes per sector */
	.byte 1					/* sectors per cluster */
	.word 1					/* reserved sectors */
	.byte 2					/* number of fat tables */
	.word 224				/* number of root directory entries */
	.word 2880				/* total number of sectors */
	.byte 0xf0				/* media descriptor */
	.word 9					/* sectors per FAT */
	.word 9					/* sectors per track */
	.word 2					/* number of heads */
	.word 0					/* hidden sectors */
ebpb:
	.word 0					/* hidden sectors (high word) */
	.double 2879			/* total number of sectors in filesystem */
	.byte 0					/* logical drive number */
	.byte 0					/* reserved */
	.byte 0x29				/* extended signature */
	.double 0				/* serial number */
	.ascii "ALiX BOOT  "	/* volume name */
	.ascii "FAT12   "		/* Filesystem type */

_start:
	cli
	xorw %ax, %ax
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %ss
	movw $top, %sp

	pushw %ax
	pushw $1f
	lret
1:	/* normalized segments and IP */
	sti

begin:
	movw $str, %si
	call print


	/* load FAT */
	/* setup retry counter */
	pushw $0x0006
1:
	popw %cx
	decw %cx
	jz halt
	pushw %cx

	/* reset disk system */
	movw $reset_str, %si
	call print
	xorb %ah, %ah
	int $0x13
	jc halt

	/* load FAT to address 0x0500 */
	movw $load_fat_str, %si
	call print
	movb $0x02, %ah
	movb bpb+22, %al
	movw $0x0001, %cx
	xorb %dh, %dh
	pushw %es
	movw $0x0050, %bx
	movw %bx, %es
	xorw %bx, %bx
	int $0x13
	jnc 2f
	popw %es
	jmp 1b

2:
	popw %es

	/* locate bootloader file */
	/* calculate offset of root directory */
	movw $locate_str, %si
	call print
	movw bpb+16, %cx
	xorw %bx, %bx
	incw %bx
1:
	addw bpb+22, %bx
	decw %cx
	jnz 1b

	/* calculate size of root directory in # of sectors*/
	movb $32, %cl
	xorw %ax, %ax
2:
	addw bpb+17, %ax
	decb %cl
	jnz 2b

3:
	incw %cx
	subw bpb+11, %ax
	jnz 3b

	/* load root directory */
	

halt:
	movw $halt_str, %si
	call print
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

target_file:
	.ascii "BOOTLD  SYS"
fname_len:
	.equ .-target_file

str:
	.asciz "Hello World!\r\n"
reset_str:
	.asciz "reset\r\n"
load_fat_str:
	.asciz "loading FAT\r\n"
locate_str:
	.asciz "locate\r\n"
load_file_str:
	.asciz "loading file\r\n"
halt_str:
	.asciz "HALTED"

	.org top+510

boot_sig:
	.byte 0x55
	.byte 0xaa

fat:

