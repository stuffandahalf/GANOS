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

load_fat: /* load FAT */
1:
	decb reset_counter
	jz halt

	/* reset disk system */
	movw $reset_str, %si
	call print
	xorb %ah, %ah
	int $0x13
	jc halt

	/* load FAT to address 0x0500 */
	movw $load_fat_str, %si
	call print
	movw bpb+22, %ax /* Sectors per fat */
	movb $0x02, %ah
	movw bpb+14, %cx /* reserved sectors */
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
	movw $success_str, %si
	call print

load_root: /* load root directory */
	/* Calculate next CHS */
	pushw %ax
	movb %ch, %bl
	movb %cl, %bh
	shrb $6, %bh
	/* %bx contains cylinder */
	andb $0x3F, %cl
	/* %cl contains sector */
	/* %dh still contains head */
	
	shlb $1, %al /* REMOVE THIS LATER */
1:	/* next sector */
	test %al, %al
	jz 2f
	decb %al
	incb %cl /* increment sector */
	cmpb bpb+24, %cl /* sectors per track */
	jle 1b
	movb $0x01, %cl /* reset sector */
	incb %dh /* increment head */
	cmpb bpb+26, %dh
	jl 1b
	xorb %dh, %dh /* reset head */
	incw %bx /* increment cylinder */
	jmp 1b
	
	
2:	/* reconstruct CHS for int 13h */
	movb %bl, %ch
	shlb $6, %bh
	orb %bh, %cl

	/* calculate destination address */
	popw %ax
	;pushw %bx
	xorw %bx, %bx
3:
	addw bpb+11, %bx /* bytes per sector */
	decb %al
	jnz 3b
	/* %bx contains destination address */
	pushw %bx
	
	/* calculate number of sectors */
	movw bpb+17, %ax /* number of root directory entries */
	shl $5, %ax /* multiply by 32 */
	movw bpb+11, %bx
4:	/* divide by number of sectors */
	shr $1, %bx /* divide by 2 */
	jz 5f
	shr $1, %ax
	jmp 4b
5:	/* %al contains number of sectors to load */
	
	/* load root directory */
	movw $load_root_str, %si
	call print
	movb $0x06, reset_counter
	movw $0x0050, %bx
	movw %bx, %es
	popw %bx
	
1:
	decb reset_counter
	jz halt
	
	xorb %ah, %ah
	int $0x13
	jc 1b
	
	movb $0x02, %ah
	int $0x13
	jc halt
	
	movw $success_str, %si
	call print
	
find_stage2: /* find boot file in root directory */
	pushw %bx
	movw %es, %cx
	shr $8, %bx
	addw %bx, %cx
	movw %cx, %es
	popw %bx
	xorb %bh, %bh
	movw %bx, %di
	/* set %es:%di to point to directory entries */
	movw bpb+17, %cx /* number of root directory entries */
	
	pushw %es
	xorw %si, %si
	movw %si, %es
	movw locate_file_str, %si
	call print
	popw %es
1:
	pushw %cx
	movw 11, %cx
	mov target_file, %si
	repne cmpsb
	jcxz 2f
	popw %cx
	decw %cx
	addw $32, %bx
	jmp 1b
	
2: /* file found */
	popw %cx
	pushw %es
	xorw %si, %si
	movw %si, %es
	movw $success_str, %si
	call print
	popw %es

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
	;.ascii "BOOTLD  SYS"
	.ascii "BOOTLD  COM"
/*fname_len:
	.equ .-target_file*/

reset_counter:
	.byte 6

str:
	.asciz "Hello World!\r\n"
reset_str:
	.asciz "reset\r\n"
load_fat_str:
	.asciz "loading FAT\r\n"
load_root_str:
	.asciz "loading root\r\n"
locate_file_str:
	.asciz "searching for file\r\n"
load_file_str:
	.asciz "loading file\r\n"
success_str:
	.asciz "success\r\n"
halt_str:
	.asciz "HALTED"

	.org top+510

boot_sig:
	.byte 0x55
	.byte 0xaa

fat:

