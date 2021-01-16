	.code16
	.globl _start
	
	.set LOAD_ADDR, 0x7e00
	.set LINK_ADDR, 0x0600
	.set LOADER_SZ, (bottom - top)
	
top:
	# relocate to 0x600
	movw $LINK_ADDR, %sp
	movw $LOAD_ADDR, %si
	movw $LINK_ADDR, %di
	movw $LOADER_SZ, %cx
	rep movsb
	
	pushw $_start
	ret

_start:
	call clear
	movw $welcome_str, %si
	call println
	
	movw $a20_str, %si
	call print
	call enable_a20
	#call check_a20
	jc 1f
	movw $enabled_str, %si
	jmp 2f
1:
	movw $disabled_str, %si
2:
	call println

halt:
	pushw %ds
	pushw %si
	xorw %si, %si
	movw %si, %ds
	movw $halt_str, %si
	call println
	popw %si
	popw %ds
	call reg32_dump
	cli
	hlt

	#.org top+1024

# no parameters
# sets carry flag if a20 not enabled
enable_a20:
	pushw %cx
	pushf
	call check_a20
	jnc 3f
	
	call enable_a20_bios
	call check_a20
	jnc 3f
	call enable_a20_kb
	call check_a20
	jnc 3f
	call enable_a20_fast
	movw $30, %cx
1:
	call check_a20
	jnc 3f
	decw %cx
	jnz 1b
2:
	popf
	stc
	jmp 4f
3:
	popf
	clc
4:
	popw %cx
	ret

# no parameters
# sets carry flag if a20 not enabled
# adapted from routine on wiki.osdev.org
check_a20:
	pushw %ds
	pushw %es
	pushw %di
	pushw %si
	pushw %ax
	pushf
	
	cli
	
	xorw %ax, %ax
	movw %ax, %es
	
	notw %ax
	movw %ax, %ds
	
	movw $0x0500, %di
	movw $0x0510, %si
	
	movb %es:(%di), %al
	pushw %ax
	movb %ds:(%si), %al
	pushw %ax
	
	movb $0x00, %es:(%di)
	movb $0xff, %ds:(%si)
	
	cmpb $0xff, %es:(%di)
	
	popw %ax
	movb %al, %ds:(%si)
	popw %ax
	movb %al, %es:(%di)
	
	jne 1f
	
	popf
	stc
	jmp 2f

1:
	popf
	clc
	
2:
	sti
	popw %ax
	popw %si
	popw %di
	popw %es
	popw %ds
	ret

enable_a20_bios:
	pushw %ax
	pushw %bx
	pushf
	
	# check for bios support for a20
	movw $0x2403, %ax
	int $0x15
	testw %ax, %ax
	jz 1f
	jc 1f
	
	# attempt to enable a20
	movw $0x2401, %ax
	int $0x15
	
1:
	popf
	popw %bx
	popw %ax
	ret

enable_a20_kb:
	pushw %ax
	pushw %cx
	cli
	
	movw $30, %cx
1:	# busy?
	decw %cx
	jz 3f
	inb $0x64, %al
	testb $0x02, %al
	jnz 1b
	
	# write output port
	movb $0xd1, %al
	outb %al, $0x64
	
2:	# busy?
	inb $0x64, %al
	testb $0x02, %al
	jnz 2b
	
	# enable a20
	movb $0xdf, %al
	outb %al, $0x60
3:
	sti
	popw %cx
	popw %ax
	ret
/*	
	pushw %ax
	cli
	
	call a20_wait
	movb $0xad, %al
	outb %al, $0x64
	
	call a20_wait
	movb $0xd0, %al
	outb %al, $0x64
	
	call a20_wait2
	inb $0x60, %al
	pushl %eax
	
	call a20_wait
	movb $0xd1, %al
	outb %al, $0x64
	
	call a20_wait
	popl %eax
	orb $0x02, %al
	outb %al, $0x60
	
	call a20_wait
	movb $0xae, %al
	outb %al, $0x64
	
	call a20_wait
	
	sti
	popw %ax
	ret

a20_wait:
	pushw %ax
1:
	inb $0x64, %al
	testb $0x02, %al
	jnz 1b
	popw %ax
	ret

a20_wait2:
	pushw %ax
1:
	inb $0x64, %al
	testb $0x01, %al
	jz 1b
	popw %ax
	ret*/

enable_a20_fast:
	pushw %ax
	inb $0x92, %al
	testb $0x02, %al
	jnz 1f
	orb $0x02, %al
	andb $0xfe, %al
	outb %al, $0x92
1:
	popw %ax
	ret

reg32_dump:
	pushw %bp
	movw %sp, %bp
	
	pushw %di
	pushw %si
	pushl %eax
	
	movw $tab_str, %di

	movw $eax_str, %si
	call print
	movw %di, %si
	call print
	call print_d
	movw %di, %si
	call print
	call println_x
	
	movl %ecx, %eax
	movw $ecx_str, %si
	call print
	movw %di, %si
	call print
	call print_d
	movw %di, %si
	call print
	call println_x
	
	movl %edx, %eax
	movw $edx_str, %si
	call print
	movw %di, %si
	call print
	call print_d
	movw %di, %si
	call print
	call println_x
	
	movl %ebx, %eax
	movw $ebx_str, %si
	call print
	movw %di, %si
	call print
	call print_d
	movw %di, %si
	call print
	call println_x
	
	movl %esp, %eax
	movw $esp_str, %si
	call print
	movw %di, %si
	call print
	call print_d
	movw %di, %si
	call print
	call println_x
	
	pushw %bp
	movw (%bp), %bp
	movl %ebp, %eax
	popw %bp
	movw $ebp_str, %si
	call print
	movw %di, %si
	call print
	call print_d
	movw %di, %si
	call print
	call println_x
	
	movw -4(%bp), %si
	movl %esi, %eax
	movw $esi_str, %si
	call print
	movw %di, %si
	call print
	call print_d
	movw %di, %si
	call print
	call println_x
	
	pushw %di
	movw -2(%bp), %di
	movl %edi, %eax
	popw %di
	movw $edi_str, %si
	call print
	movw %di, %si
	call print
	call print_d
	movw %di, %si
	call print
	call println_x
	
1:
	xorl %eax, %eax
	movw 2(%bp), %ax
	movw $eip_str, %si
	call print
	movw %di, %si
	call print
	call print_d
	movw %di, %si
	call print
	call println_x
	
	popl %eax
	popw %si
	popw %di
	
	popw %bp
	ret

# parameters
# %si = string address
# %ds = string segment
# no return
print:
	pushw %ds
	pushw %ax
	
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

# parameters
# %si = string address
# %ds = string segment
# no return
println:
	call print
	pushw %si
	movw $newline_str, %si
	call print
	popw %si
	ret

# parameters
# %eax = number
# no return
print_x:
	pushl %eax
	pushl %ebx
	pushw %cx
	pushl %edx
	
	pushw %ax
	movw $(0x0e << 8 + '0'), %ax
	int $0x10
	movb $'x', %al
	int $0x10
	popw %ax
	
	testl %eax, %eax
	jnz 1f
	movb $0x0e, %ah
	addb $'0', %al
	int $0x10
	jmp 6f
	
1:
	movl $0x10, %ebx
	xorl %edx, %edx
	xorw %cx, %cx
2:
	testl %eax, %eax
	jz 3f
	
	xorl %edx, %edx
	divl %ebx
	incb %cl
	pushw %dx
	jmp 2b

3:
	jcxz 6f
	decb %cl
	popw %ax
	cmpw $10, %ax
	jae 4f
	addb $'0', %al
	jmp 5f
4:
	addb $('a' - 10), %al
5:
	movb $0x0e, %ah
	int $0x10
	jmp 3b
	
6:
	popl %edx
	popw %cx
	popl %ebx
	popl %eax
	ret

println_x:
	call print_x
	pushw %si
	movw $newline_str, %si
	call print
	popw %si
	ret

# parameters
# %eax = number
# no return
print_d:
	pushl %eax
	pushl %ebx
	pushw %cx
	pushl %edx
	
	testl %eax, %eax
	jnz 1f
	pushw %ax
	movw $(0x0e << 8 + '0'), %ax
	int $0x10
	popw %ax
	jmp 3f

1:
	movl $10, %ebx
	xorl %edx, %edx
	xorw %cx, %cx
2:
	testl %eax, %eax
	jz 3f
	
	xorl %edx, %edx
	divl %ebx
	incb %cl
	pushw %dx
	jmp 2b
	
3:
	jcxz 4f
	decb %cl
	popw %ax
	addb $'0', %al
	movb $0x0e, %ah
	int $0x10
	jmp 3b
	
4:
	popl %edx
	popw %cx
	popl %ebx
	popl %eax
	ret

# parameters
# %eax = number
# no return
println_d:
	call print_d
	pushw %si
	movw $newline_str, %si
	call print
	popw %si
	ret

# no parameters
# no return
clear:
	pushw %ax
	
	movb $0x0f, %ah
	int $0x10
	
	xorb %ah, %ah
	int $0x10
	
	popw %ax
	ret

welcome_str: .asciz "BOOTLD.SYS EXECUTED"
halt_str: .asciz "HALTED"

enabled_str: .asciz "enabled"
disabled_str: .asciz "disabled"

a20_str: .asciz "a20 "

newline_str: .asciz "\r\n"
tab_str: .asciz "    "

eax_str: .asciz "eax"
ebx_str: .asciz "ebx"
ecx_str: .asciz "ecx"
edx_str: .asciz "edx"
esp_str: .asciz "esp"
ebp_str: .asciz "ebp"
esi_str: .asciz "esi"
edi_str: .asciz "edi"
eip_str: .asciz "eip"

bottom:
