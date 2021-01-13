	.globl _start
	
top:

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
	.asciz "BOOTLD.SYS EXECUTED"

halt_str:
	.asciz "HALTED"

print:
	pushw %ax
	movb $0x0e, %ah
1:	/* loop */
	lodsb
	testb %al, %al /* if %al == 0 */
	je 2f
	int $0x10
	jmp 1b
2:	/* end */
	popw %ax
	ret

