# SPDX-License-Identifier: GPL-3.0-only
#
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

	.code16
	.globl _start

	.set STACK_BOTTOM, 0x0500
	.set LOAD_ADDRESS, 0x7c00
	.set LINK_ADDRESS, top

top:
	nop
	jmp _start
	.ascii "ALiX    "

bpb:
	.word 512				# offset 0, bytes per sector
	.byte 1					# offset 2, sectors per cluster
	.word 1					# offset 3, reserved sectors
	.byte 2					# offset 5, number of fat tables
	.word 224				# offset 6, number of root directory entries
	.word 2880				# offset 8, total number of sectors
	.byte 0xf0				# offset 10, media descriptor
	.word 9					# offset 11, sectors per FAT
	.word 18				# offset 13, sectors per track
	.word 2					# offset 15, number of heads
	.long 0					# offset 17, hidden sectors
	.long 0					# offset 21, total sectors (if offset 8 is zero)
#ifdef FAT32
ebpb:
	.long 9					/* offset 25, sectors per FAT (same as offset 11)
	.word 0					/* offset 29, drive description
	.word 0					/* offset 31, version
	.long 2					/* offset 33, cluster num of root directory
	.word 
#else
ebpb:
	
#endif

_start:
	xorw %ax, %ax
	movw %ax, %ss
	movw $STACK_BOTTOM, %sp
	
	pushw %es
	pushw %si
	
	movw %ax, %ds
	movw %ax, %es
	movw $top, %si
	movw $LINK_ADDRESS, %di
	movw $(bottom-top), %cx
	rep movsb
	
	ljmp $0x0000, $begin
	
begin:

halt:
	hlt

print:
	pushw %ax
	pushw %bx
	xorw %bx, %bx
	movb $0x0e, %ah
1:
	lodsb
	testb %al, %al
	jz 2f
	int $0x10
	jmp 1b
2:
	popw %bx
	popw %ax
	ret


	.org top+510
	.byte 0x55, 0xaa

bottom:
