.code16
.global _start

jump:
#    jmp $0x0000, $_start
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

string: .asciz "Hello World\r\n"

load_status: .ascii "cf state is: "
var: .byte 0
line_feed: .asciz "\r\n"


_start:
    xor %ax, %ax
#    movw %ax, %cs
    movw %ax, %ds
    movw %ax, %es

    movw %ax, %ss
    movw $0x9c00, %sp

    #cld

    movw $string, %si
    call print

    movb $0x00, %ah
    int $0x13

    movw $0x00, %ax
    movw %ax, %es
    movw $0x1000, %bx
    
    movb $2, %ah
    movb $1, %al
    movb $0, %ch
    movb $2, %cl
    movb $0, %dh
    int $0x13

    jmp $0x0000, $0x1000

halt:
    nop
    jmp halt

edit_cf_state:
    movw %cx, %ax
    addb $'0', %al
    movb %al, (var)
    ret

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
