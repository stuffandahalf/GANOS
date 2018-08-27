.code16
.global _start
top:
jump:
    jmp _start
    nop

oem:
    .ascii "GANIX   "
dos_2_0_bios_parameter_block:
sector_size:
    .word 512
logical_sectors_per_clustor:
    .byte 32
reserved_logical_sector_count:
    .word 18
number_of_fats:
    .byte 2
number_of_root_dirs:
    .word 224
total_logical_sectors_2_0:
    .word 2880  # 3.5" 1.44MB
media_descriptor:
    .byte 0xF0
logical_sectors_per_fat:
    .word 9

dos_3_31_bios_parameter_block:
physical_sectors_per_track:
    .word 18
number_of_heads:
    .word 2
hidden_sectors_before_fat:
    .long 0
total_logical_sectors_3_31:
    .long 0

.set stage1_seg, 0x0000
.set stage1_offset, 0x1000

boot_str: .asciz "Ganix boot stage 0\r\n"

_start:
    movb %dl, drive_num
    xor %ax, %ax
    movw %ax, %ds
    movw %ax, %es

    movw %ax, %ss
    movw $0x9c00, %sp

    movw $boot_str, %si
    call print

    call enable_a20
    
    call load_boot1
    
    ljmp $stage1_seg, $stage1_offset


load_boot1:

reset_fd:
    movb $0x00, %ah
    int $0x13

.Lload_sectors:
    #xor %ax, %ax
    #movw %ax, %es
    movw $stage1_seg, %ax
    movw %ax, %es
    movw $stage1_offset, %bx

    movb $2, %ah    # function number
    #movb $17, %al   # number of sectors to read
    movb reserved_logical_sector_count, %al
    decb %al
    movb $0, %ch    # track
    movb $2, %cl    # start sector
    movb $0, %dh    # head
    movb drive_num, %dl
    int $0x13

    jc .Lload_retry

    ret

.Lload_retry:
    decw (.Lload_reset_counter)
    jz .Lload_fail
    jmp reset_fd

.Lload_fail:
    movw $.Lload_fail_str, %si
    call print
    jmp halt

.Lload_fail_str: .asciz "Failed to load stage 1 bootloader\r\n"
.Lload_reset_counter: .byte 3

enable_a20:
    pushfw
    pushw %ds
    pushw %es
    pushw %di
    pushw %si

    cli

    call .La20_check
    #jmp .La20_fail
    
.La20_enable_keyboard:
    pushw $0xAD
    call .La20_out_64h

    pushw $0xD0
    call .La20_out_64h

    call .La20_kb_wait1
    in $0x60, %al
    pushw %ax
    
    pushw $0xD1
    call .La20_out_64h
    
    pushw $0x02
    call .La20_out_64h

    call .La20_kb_wait2

    call .La20_check
    jmp .La20_fail

.La20_enable_fast:
    in $0x92, %al
    or $0x02, %al
    out %al, $0x92

    call .La20_check
    call .La20_fail

.La20_out_64h:
    pushw %bp
    movw %sp, %bp
    call .La20_kb_wait2
    movw 4(%bp), %ax
    out %al, $0x64
    popw %bp
    ret $0x1

.La20_kb_wait2:
    in $0x64, %al
    test $2, %al
    jnz .La20_kb_wait2
    ret

.La20_kb_wait1:
    in $0x64, %al
    test $1, %al
    jnz .La20_kb_wait1
    ret

.La20_check:
    pushfw
    pushw %ds
    pushw %es
    pushw %di
    pushw %si

    xorw %ax, %ax
    movw %ax, %es
    
    notw %ax
    movw %ax, %ds
    #xor %ax, %ax
    
    movw $0x0500, %di
    movw $0x0510, %si
    
    movb %es:(%di), %al
    pushw %ax
    
    movb %ds:(%si), %al
    pushw %ax
    
    movb $0x00, %es:(%di)
    movb $0xFF, %ds:(%si)
    
    cmpb $0xFF, %es:(%di)
    
    popw %ax
    movb %al, %ds:(%si)
    
    popw %ax
    movb %al, %es:(%di)

    jne .La20_exit

    popw %si
    popw %di
    popw %es
    popw %ds
    popfw

    ret

.La20_fail:
    sti
    movw $.La20_fail_str, %si
    call print
    jmp halt
    #ret

.La20_exit:
    sti
    movw $.La20_success_str, %si
    call print

    popw %si
    popw %di
    popw %es
    popw %ds
    popfw
    ret

.La20_fail_str: .asciz "Failed to enable address line 20\r\n"
.La20_success_str: .asciz "Enabled address line 20\r\n"


halt:
    jmp halt

print:
    pushw %ax
    movb $0x0E, %ah
.Lloop:
    lodsb
    or %al, %al
    jz .Lend
    int $0x10
    jmp .Lloop
.Lend:
    popw %ax
    ret

    .= top + 509

drive_num:
    .byte 0
boot_sig:
    .byte 0x55
    .byte 0xAA
