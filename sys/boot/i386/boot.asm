    [BITS 16]
    org 0x7c00
    
jump:
    jmp _start
    nop
oem:
    db 'GANIX   '
dos_2_0_bios_parameter_block:
sector_size:
    dw 512
logical_sectors_per_cluster:
    db 32
reserved_logical_sector_count:
    dw 1
number_of_fats:
    db 2
number_of_root_dirs:
    dw 224
total_logical_sectors_2_0:
    dw 2880     ; 3.5" 1.44MB
media_descriptor:
    db 0xF0
logical_sectors_per_fat:
    dw 9

dos_3_31_bios_parameter_block:
physical_sectors_per_track:
    dw 18
number_of_heads:
    dw 2
hidden_sectors_before_fat_count:
    dq 0
total_logical_sectors_3_31:
    dq 0

string db 'Ganix boot stage 0', 0

_start:
    
    mov si, string
    call print
    
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov sp, 0x9c00

    cli
    

halt:
    nop
    jmp halt


print:
.loop:
    mov ah, 0Eh
    lodsb
    cmp al, 0
    jz .end
    int 10h
    jmp .loop
.end:
    ret

    
    times 509 - ($ - $$) db 0
    
drive_num:
    db 0
    
boot_sig:
    db 0x55
    db 0xAA
