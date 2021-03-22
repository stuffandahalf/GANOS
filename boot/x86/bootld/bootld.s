# Copyright (C) 2021 Gregory Norton <gregory.norton@me.com>
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, version 3.
# 
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along with
# this program. If not, see <https://www.gnu.org/licenses/>.
#
# SPDX-License-Identifier: GPL-3.0-only

	.code16
	.globl _start
	
	.set LOAD_ADDR, 0x7e00
	.set LINK_ADDR, top
	.set LOADER_SZ, (bottom - top)
	.set FAT_ADDR, bottom
	.set FILE_ADDR, 0x2000
	
top:
	# relocate to LINK_ADDR
	movw $LINK_ADDR, %sp
	movw $LOAD_ADDR, %si
	movw $LINK_ADDR, %di
	movw $LOADER_SZ, %cx
	rep movsb
	
	# long jump to target
	pushw $_start
	ret

_start:
	movb %dl, drive		# finally save drive number so %dx is available

	# welcome prompt
	call clear
	movw $welcome_str, %si
	call println
	
	# print processor brand
	call print_proc
	jnc 1f
	movw $cpuid_str, %si
	call print
	movw $ns_str, %si
	call println
1:
	
	# enable a20
	movw $a20_str, %si
	call print
	call enable_a20
	jnc 1f
	movw $disabled_str, %si
	call println
	jmp halt
1:
	movw $enabled_str, %si
	call println
	
	# initialize disk io
	call init_disk
	
	#call go_unreal
	
	#movw $kernel_path, %si
	#call load_file
	

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

# initializes disk for reading files
init_disk:
	pushw %ax
	pushw %bx
	pushw %cx
	pushw %dx
	pushw %es
	pushw %di
	
	# get drive parameters
	movb drive, %dl
	movb $0x08, %ah
	xorw %di, %di
	movw %di, %es
	int $0x13
	
	incb %dh
	movb %dh, heads
	
	movb %ch, %bl
	movb %cl, %bh
	shrb $6, %bh
	incw %bx
	movw %bx, cylinders
	
	andb $0x3f, %cl
	movb %cl, sectors
	
	# reset chs address to first sector of device
	xorb %dh, %dh
	movw $1, %cx
	movb drive, %dh
	
	testb $0x80, drive	# check if current drive is a hard disk
	jz 1f
	
	
	
1:
	
	popw %di
	popw %es
	popw %dx
	popw %cx
	popw %bx
	popw %ax
	ret

# enter unreal mode
# routine adapted from wiki.osdev.org
go_unreal:
	cli
	pushw %ds
	pushw %ax
	pushw %bx
	
	# load gdt
	lgdt gdt_info
	
	# enter protected mode
	movl %cr0, %eax
	orb $1, %al
	movl %eax, %cr0
	jmp 1f
1:
	# select descriptor 1
	movw $0x08, %bx
	movw %bx, %ds
	
	# back to real mode
	andb $0xfe, %al
	
	popw %bx
	popw %ax
	popw %ds
	sti
	
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
	call print_x
	movw %di, %si
	call print
	call println_d
	
	movl %ecx, %eax
	movw $ecx_str, %si
	call print
	movw %di, %si
	call print
	call print_x
	movw %di, %si
	call print
	call println_d
	
	movl %edx, %eax
	movw $edx_str, %si
	call print
	movw %di, %si
	call print
	call print_x
	movw %di, %si
	call print
	call println_d
	
	movl %ebx, %eax
	movw $ebx_str, %si
	call print
	movw %di, %si
	call print
	call print_x
	movw %di, %si
	call print
	call println_d
	
	movl %esp, %eax
	movw $esp_str, %si
	call print
	movw %di, %si
	call print
	call print_x
	movw %di, %si
	call print
	call println_d
	
	pushw %bp
	movw (%bp), %bp
	movl %ebp, %eax
	popw %bp
	movw $ebp_str, %si
	call print
	movw %di, %si
	call print
	call print_x
	movw %di, %si
	call print
	call println_d
	
	movw -4(%bp), %si
	movl %esi, %eax
	movw $esi_str, %si
	call print
	movw %di, %si
	call print
	call print_x
	movw %di, %si
	call print
	call println_d
	
	pushw %di
	movw -2(%bp), %di
	movl %edi, %eax
	popw %di
	movw $edi_str, %si
	call print
	movw %di, %si
	call print
	call print_x
	movw %di, %si
	call print
	call println_d
	
1:
	xorl %eax, %eax
	movw 2(%bp), %ax
	movw $eip_str, %si
	call print
	movw %di, %si
	call print
	call print_x
	movw %di, %si
	call print
	call println_d
	
	pushw %cs
	popw %ax
	movw $cs_str, %si
	call print
	movw %di, %si
	call print
	call print_x
	movw %di, %si
	call print
	call println_d
	
	pushw %ss
	popw %ax
	movw $ss_str, %si
	call print
	movw %di, %si
	call print
	call print_x
	movw %di, %si
	call print
	call println_d
	
	pushw %ds
	popw %ax
	movw $ss_str, %si
	call print
	movw %di, %si
	call print
	call print_x
	movw %di, %si
	call print
	call println_d
	
	pushw %es
	popw %ax
	movw $es_str, %si
	call print
	movw %di, %si
	call print
	call print_x
	movw %di, %si
	call print
	call println_d
	
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
	jmp 4f

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

print_proc:
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx
	
	movl $0x80000000, %eax
	cpuid
	cmpl $0x80000004, %eax
	jae 1f
	stc
1:
	pushw $0
	movl $0x80000004, %eax
	cpuid
	pushl %edx
	pushl %ecx
	pushl %ebx
	pushl %eax
	
	movl $0x80000003, %eax
	cpuid
	pushl %edx
	pushl %ecx
	pushl %ebx
	pushl %eax
	
	movl $0x80000002, %eax
	cpuid
	pushl %edx
	pushl %ecx
	pushl %ebx
	pushl %eax
	
	movw %sp, %si
	call println
	addw $50, %sp
2:
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax
	ret

welcome_str: .asciz "BOOTLD.SYS EXECUTED"
halt_str: .asciz "HALTED"

enabled_str: .asciz "enabled"
disabled_str: .asciz "disabled"

ns_str: .asciz "not supported"

a20_str: .asciz "a20 "
cpuid_str: .asciz "cpuid "

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
cs_str: .asciz "cs"
ss_str: .asciz "ss"
ds_str: .asciz "ds"
es_str: .asciz "es"

drive: .byte 0
heads: .byte 0
cylinders: .word 0
sectors: .byte 0

gdt_info:
	.word gdt_end - gdt - 1
	.long gdt

gdt: .long 0, 0
flatdesc: .byte 0xff, 0xff, 0, 0, 0, 0b10010010, 0b11001111, 0
gdt_end:

bottom:
