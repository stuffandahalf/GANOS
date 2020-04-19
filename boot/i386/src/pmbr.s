	.code16
	.global _start

	.equ NEED_UNREAL, 0
	.equ NEED_DISK_PARAMS, 0

_start:
	cli
	xorw %ax, %ax
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %ss
	movw $_start, %sp
.if !NEED_UNREAL
	sti
.endif

	pushw %ax
	pushw $1f
	lret
1:	# normalized segments and IP

.if NEED_UNREAL
go_unreal:
	pushw %ds

	lgdt (gdtinfo)

	movl %cr0, %eax
	orb $1, %al
	movl %eax, %cr0

	jmp .+2

	movw $0x08, %bx
	movw %bx, %ds

	andb $0xfe, %al
	movl %eax, %cr0

	popw %ds
	sti
.endif

begin:
	movw $str, %si
	call print

verify_disk_extensions:
	# dl = drive num
	movb $0x41, %ah
	movw $0x55aa, %bx
	int $0x13
	jc 1f
	andw $1, %cx
	jz 2f
	jmp 3f

1:	# no extensions
2:	# packet interface not supported
	jmp halt

3:	# disk extensions present
	movw $str, %si
	call print

.if NEED_DISK_PARAMS
read_disk_params:
	# ds = 0
	# dl = drive num
	movb $0x48, %ah
	movw $0x7e00, %di
	movw $0x1e, (%di)
	int $0x13
	jnc 1f	# succeeded
	jmp halt
1:	# success
.endif

load_gpt_header:
	#movw %di, %si
.if NEED_DISK_PARAMS
	pushw %di
	addw $0x200, %di	# target
.else
	movw $0x7e00, %di	# target
.endif
	movw $0x10, %bx		# packet size

	pushl $1	# low 4 bytes
	pushl $0	# high 4 bytes
	pushw $0	# segment = 0
	pushw %di	# offset = 0x8000
	pushw $1	# 1 sector
	pushw %bx	# unused = 0, size = 10h

	movw %sp, %si
	movb $0x42, %ah
	int $0x13
	jc halt		# reading failed

	addw %bx, %sp

tmp:
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

str:
	.asciz "Hello World!\r\n"

.if NEED_UNREAL
gdtinfo:
	.word gdt_end - gdt - 1
	.long gdt

gdt:
	.long 0, 0
flatdesc:
	.byte 0xff, 0xff, 0, 0, 0, 0b10010010, 0b11001111, 0
gdt_end:
.endif

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
