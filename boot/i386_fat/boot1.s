	.file	"boot1.c"
	.text
/APP
	.code16
	.section	.rodata
.LC0:
	.string	"Hello World\r\n"
.LC1:
	.string	"This is coming from C!!!!!\r\n"
/NO_APP
	.text
	.globl	_start
	.type	_start, @function
_start:
.LFB0:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	subl	$8, %esp
	subl	$12, %esp
	pushl	$.LC0
	call	print
	addl	$16, %esp
	subl	$12, %esp
	pushl	$.LC1
	call	print
	addl	$16, %esp
/APP
/  26 "boot1.c" 1
	cli
hlt

/  0 "" 2
/NO_APP
	nop
	leave
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE0:
	.size	_start, .-_start
	.globl	print
	.type	print, @function
print:
.LFB1:
	.cfi_startproc
	pushl	%ebp
	.cfi_def_cfa_offset 8
	.cfi_offset 5, -8
	movl	%esp, %ebp
	.cfi_def_cfa_register 5
	pushl	%esi
	.cfi_offset 6, -12
	movl	8(%ebp), %eax
/APP
/  33 "boot1.c" 1
	mov %eax, %esi
movb $0x0E, %ah
0:
lodsb
testb %al, %al
je 1f
int $0x10
jmp 0b
1:

/  0 "" 2
/NO_APP
	nop
	popl	%esi
	.cfi_restore 6
	popl	%ebp
	.cfi_restore 5
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE1:
	.size	print, .-print
	.ident	"GCC: (GNU) 7.3.0"
