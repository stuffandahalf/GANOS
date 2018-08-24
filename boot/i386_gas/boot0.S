.code16
.global _start
top:
jump:
    jmp _start
    #jmp jump
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

#.equ loaded_seg, 0x0000
#.equ loaded_offset, 0x1000

string: .asciz "Ganix boot stage 0\r\n"

_start:
    xor %ax, %ax
    movw %ax, %ds
    movw %ax, %es

    movw %ax, %ss
    movw $0x9c00, %sp

    movw $string, %si
    call print

reset_fd:
    movb $0x00, %ah
    int $0x13

load_second_sector:
    xor %ax, %ax
    movw %ax, %es
    movw $0x1000, %bx

    movb $2, %ah    # function number
    movb $17, %al   # number of sectors to read
    movb $0, %ch    # track
    movb $2, %cl    # start sector
    movb $0, %dh    # head
    int $0x13

/*halt:
    nop
    jmp halt*/
    ljmp $0x0000, $0x1000
    #ljmp %es:(%bx)
    

print:
    pushw %ax
    movb $0x0E, %ah
.loop:
    lodsb
    or %al, %al
    jz .end
    int $0x10
    jmp .loop
.end:
    popw %ax
    ret

    .= top + 509

drive_num:
    .byte 0
boot_sig:
    .byte 0x55
    .byte 0xAA
