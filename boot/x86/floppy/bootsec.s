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
	.word 18				/* sectors per track */
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
	pushw $begin
	lret

begin: /* normalized segments and IP */
	sti
	movb %dl, drive

load_fat: /* load FAT */
	/* load FAT to address 0x0500 */
	movw $load_fat_str, %si
	call print
	movw bpb+22, %ax /* sectors per FAT */
	movw $0x0050, %bx
	movw %bx, %es /* target segment */
	xorw %bx, %bx /* target offset */
	movw bpb+14, %cx /* reserved sectors */
	incw %cx
	xorb %dh, %dh
	
	call load
	jc halt
	
	movw $success_str, %si
	call print

load_root: /* load root directory */
	pushw %cx
	movb bpb+16, %cl /* number of FAT tables */
	xorw %ax, %ax
1:	/* loop adding sizeof(FAT) to total in %ax */
	addw bpb+22, %ax /* sizeof(FAT) */
	decb %cl
	jnz 1b
	popw %cx
	/* %ax contains number of sectors reserved for FAT */

2:	/* seperate CHS address */
	movb %ch, %bl
	movb %cl, %bh
	shr $6, %bh
	andb $0x4f, %cl
	
	/* %bx = cylinder */
	/* %dh = head */
	/* %cl = sector */

3:	/* calculate next CHS address */
	testw %ax, %ax
	jz 4f
	decw %ax
	
	incb %cl /* increment sector of track */
	cmpb bpb+24, %cl /* sectors per track */
	jbe 3b
	
	movb $1, %cl /* reset sector */
	incb %dh /* increment head */
	cmpb bpb+26, %dh /* number of heads */
	jb 3b
	
	xorb %dh, %dh /* reset head */
	incw %bx /* increment cylinder */
	jmp 3b
	
4:	/* reconstruct CHS address */
	andb $0x3f, %cl
	movb %bl, %ch
	shl $6, %bh
	orb %bh, %cl

	/* calculate next destination address */
	xorw %bx, %bx
	movw bpb+22, %ax /* sectors per FAT */
5:	/* loop */
	addw bpb+11, %bx /* bytes per sector */
	decw %ax
	jnz 5b
	
	/* %bx = target offset */
	
	/* sectors for root directory = number of root entries * 32 / bytes per sector */
	pushw %dx
	xorw %dx, %dx
	movw bpb+17, %ax /* number of root entries */
	shl $5, %ax /* %ax *= 32 */
	divw bpb+11 /* bytes per sector */
	popw %dx
	
6:	/* load root */
	movw $load_root_str, %si
	call print
	
	call load
	jc halt
	
	movw $success_str, %si
	call print

find_file:
	movw $locate_file_str, %si
	call print

	movw bpb+17, %cx /* number of root entries */
	
1:
	pushw %cx
	movw $11, %cx
	movw %bx, %di
	movw $target_file, %si
	
	repe cmpsb
	je 2f
	
	popw %cx
	decw %cx
	jz halt
	addw $32, %bx
	jmp 1b
	
2:
	popw %cx
	mov $success_str, %si
	call print

load_file:
	pushw %ds
	pushw %es
	popw %ds
	movw %bx, %si
	movb $11, %cl
	movb $0x0e, %ah
	
1:	/* loop */
	lodsb
	int $0x10
	dec %cl
	jz 2f
	jmp 1b
2:
	movb $'\r', %al
	int $0x10
	movb $'\n', %al
	int $0x10
	popw %ds

halt:
	movw $halt_str, %si
	call print
	cli
	hlt

/* parameters */
/* %si = offset address of string to be printed from segment of 0 */
print:
	pushw %ds
	pushw %ax
	
	xorw %ax, %ax
	movw %ax, %ds
	
	movb $0x0e, %ah
1: /* loop */
	lodsb
	testb %al, %al	# if %al == 0)
	je 2f
	int $0x10
	jmp 1b
2: /* function exit */
	popw %ax
	popw %ds
	ret

/* takes 5 parameters, as per int 13h, ah=2 */
/* %dx, %dl = drive, %dh = head */
/* %cx, %cl(lower 6 bits) = sector, %cl(upper 2 bits):%ch = cylinder */
/* %bx = target address offset */
/* %es = target segment */
/* %ax, %al = number of sectors to read, %ah = dont care */
/* Handles resetting drive before loading */
load:
	pushw %ax
	
	movb $0x06, reset_counter

1: /* retry */
	decb reset_counter
	jnz 2f
	stc
	jmp 4f
	
2: /* reset */
	pushw %si
	movw $reset_str, %si
	call print
	popw %si
	xorb %ah, %ah
	int $0x13
	jc 1b
	
3: /* load */
	movb $0x02, %ah
	int $0x13
	jc 1b
	
4: /* function exit */
	popw %ax
	ret

target_file:
	.ascii "BOOTLD  SYS"

drive:
	.byte 0
reset_counter:
	.byte 0

reset_str:
	.asciz "->reset disk\r\n"
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
