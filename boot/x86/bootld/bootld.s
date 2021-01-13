	.code16
	.globl _start
	
	.set LOAD_ADDR, 0x7e00
	.set LINK_ADDR, 0x0600
	.set LOADER_SZ, (bottom - top)
	
top:
	/* relocate to 0x600 */
	movw $LINK_ADDR, %sp
	movw $LOAD_ADDR, %si
	movw $LINK_ADDR, %di
	movw $LOADER_SZ, %cx
	rep movsb
	
	pushw $_start
	ret
	#jmp _start

_start:
	movw $welcome_str, %si
	call print

a20_enable:


halt:
	movw $halt_str, %si
	call print
	cli
	hlt

	.org top+1024

welcome_str:
	.asciz "BOOTLD.SYS EXECUTED\r\n"

halt_str:
	.asciz "HALTED"

print:
	pushw %ds
	pushw %ax
	
	xorw %ax, %ax
	movw %ax, %ds
	
	movb $0x0e, %ah
1:	/* loop */
	lodsb
	testb %al, %al	# if %al == 0)
	je 2f
	int $0x10
	jmp 1b
2:	/* function exit */
	popw %ax
	popw %ds
	ret

bottom:
