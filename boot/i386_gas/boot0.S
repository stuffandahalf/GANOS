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
    call .La20_check
    cmp $1, %ax
    je .La20_exit
    
.La20_enable_keyboard:
    call .La20_kb_wait_com
    movb $0xD1, %al
    outb %al, $0x64
    call .La20_kb_wait_com
    movb $0xDF, %al
    outb %al, $0x60
    call .La20_kb_wait_com

    call .La20_check
    cmp $1, %ax
    je .La20_exit

.La20_enable_fast:
    in $0x92, %al
    testb $2, %al
    jnz .La20_enable_end
    orb $0x02, %al
    andb $0xFE, %al
    outb %al, $0x92

.La20_enable_end:
    call .La20_check
    cmp $1, %ax
    je .La20_exit
    jmp .La20_fail

.La20_kb_wait_com:
    in $0x64, %al
    test $2, %al
    jnz .La20_kb_wait_com
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

    movw $0, %ax
    je .La20_check_exit
    movw $1, %ax

.La20_check_exit:
    popw %si
    popw %di
    popw %es
    popw %ds
    popfw

    ret

.La20_fail:
    movw $.La20_fail_str, %si
    call print
    jmp halt

.La20_exit:
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
