.code16
.global _start

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

string: .asciz "Hello World"

_start:
    movw $string, %si
    call print

halt:
    nop
    jmp halt

print:
    pushw %ax
    movb $0x0E, %ah
.loop:
    lodsb
    cmpb $0, %al
    jz .end
    int $0x10
    jmp .loop
.end:
    popw %ax
    ret

    .= jump + 509
drive_num:
    .byte 0
boot_sig:
    .byte 0x55
    .byte 0xAA
