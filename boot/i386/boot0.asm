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
    dw 18
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
    dd 0
total_logical_sectors_3_31:
    dd 0

string db 'Hello World', 0

_start:
    mov si, string
    call print
    
    mov ah, 0x00
    int 13h

    mov ax, 0
    mov es, ax
    mov bx, 1000h

    mov ah, 2
    mov al, 1
    mov ch, 0
    mov cl, 2
    mov dh, 0
    int 13h

    jmp 0x0000:0x1000



halt:
    ;nop
    hlt
    jmp halt

print:
    push ax
    mov ah, 0Eh
.loop:
    lodsb
    cmp al, 0
    jz .end
    int 10h
    jmp .loop
.end:
    pop ax
    ret

    
    times 509 - ($ - $$) db 0
    
drive_num:
    db 0
    
boot_sig:
    db 0x55
    db 0xAA
