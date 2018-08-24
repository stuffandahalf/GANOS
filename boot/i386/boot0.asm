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

; variables
boot_str db `Ganix boot stage 0\r\n`, 0

drv_fail_str db `Failed to load second stage\r\n`, 0
drv_reset_counter db 3

a20_fail_str db `Failed to enable address line 20\r\n`, 0

_start:
    mov [drive_num], dl     ; save loading drive number

    mov si, boot_str        ; load string into source index
    call print              ; and print it

    call check_a20          ; check if a20 is enabled
    or ax, ax               ; and try to enable it
    jnz load_boot1          ; using several methods
    

load_boot1:
reset_disk:
    push ax
    mov ah, 0x00
    int 13h
    pop ax

load_sectors:
    xor ax, ax              ; clear ax
    mov es, ax              ; load es with 0000h
    mov bx, 1000h           ; load bx with offset 1000h

    mov ah, 2               ; function 2
    mov al, 1               ; number of sectors to read (1-128)
    mov ch, 0               ; track/cylinder (0-1023)
    mov cl, 2               ; starting sector (1-17)
    mov dh, 0               ; head number (0-15)
    mov dl, [drive_num]     ; restore drive number
    int 13h
    
    jc .retry

    ;jmp 0000h:1000h;
    jmp [es:bx]

.retry:
    dec byte [drv_reset_counter] ; decrement reset timeout
    jz .fail
    jmp reset_disk
.fail:
    mov si, drv_fail_str
    call print
    jmp halt

; routine from wiki.osdev.org
check_a20:
    pushf
    push ds
    push es
    push di
    push si
 
    cli
 
    xor ax, ax ; ax = 0
    mov es, ax
 
    not ax ; ax = 0xFFFF
    mov ds, ax
 
    mov di, 0x0500
    mov si, 0x0510
 
    mov al, byte [es:di]
    push ax
 
    mov al, byte [ds:si]
    push ax
 
    mov byte [es:di], 0x00
    mov byte [ds:si], 0xFF
 
    cmp byte [es:di], 0xFF
 
    pop ax
    mov byte [ds:si], al
 
    pop ax
    mov byte [es:di], al
 
    mov ax, 0
    je .exit
 
    mov ax, 1
 
.exit:
    pop si
    pop di
    pop es
    pop ds
    popf
 
    ret

; prints the \0 terminated string located in si
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

halt:
    hlt
    jmp halt

    times 509 - ($ - $$) db 0
    
drive_num:
    db 0
    
boot_sig:
    db 0x55
    db 0xAA
