	.code16
	.global _start

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
	movw legacy_sector_size, %ax
	movw %ax, sector_size
	jmp load_gpt_hdr

2:	# packet interface not supported
3:	# disk extensions present

read_disk_params:
	# ds = 0
	# dl = drive num
	movb $0x48, %ah
	movw $0x7e00, %di
	movw $0x1e, (%di)
	int $0x13
	jc halt	# failed
	mov $18, %bx
	movw (%bx, %di, 1), %ax
	movw %ax, sector_size

load_gpt_hdr:
	xorl %eax, %eax
	pushl %eax
	inc %al
	pushl %eax
	pushw $0x07e0
	xorb %al, %al
	pushw %ax
	inc %al
	pushw %ax

# sp -> number of sectors (2 bytes)
#       offset (2 bytes)
#       segment (2 bytes)
#       first LBA (8 bytes)

	call load_sectors
	jc halt
	addw $14, %sp

halt:
	cli
	hlt


# arguments on stack
# sp -> return address (2 bytes)
#       number of sectors (2 bytes)
#       offset (2 bytes)
#       segment (2 bytes)
#       first LBA (8 bytes)
#
# carry flag set on fail
load_sectors:
	pushw %bp
	movw %sp, %bp



	popw %bp
	ret

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

legacy_sector_size:
	.word 512
sector_size:
	.word 0

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
