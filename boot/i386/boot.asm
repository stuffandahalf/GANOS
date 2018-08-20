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
    
    ;xor ax, ax
    ;mov ds, ax
    ;mov ss, ax
    ;mov sp, 0x9c00

    cli

    ; print state of a20 line
    call check_a20
    add al, '0'
    mov [a20_state], al
    mov si, a20_string
    call print

    ; load global descriptor table
    lgdt [gdtr]

    ; enable protected mode
    mov eax, cr0
    or al, 1
    mov cr0, eax

    jmp halt

a20_string:
    db 'line a20 is '
a20_state: db 0, 0

halt:
    nop
    jmp halt

gdtr:
    dw 0
    dd 0


    [BITS 16]
check_a20:
    ; preserve state
    pushf
    push ds
    push es
    push di
    push si

    ; clear ax and es
    xor ax, ax
    mov es, ax
    
    ; load ds with 0xFFFF
    not ax
    mov ds, ax
    
    mov di, 0x0500
    mov si, 0x0510

    mov al, [es:di]
    push ax
    
    mov al, [ds:si]
    push ax

    mov byte [es:di], 0x00
    mov byte [ds:si], 0xFF
    cmp byte [es:di], 0xFF
    
    pop ax
    mov byte [ds:si], al

    pop ax
    mov byte [es:di], al

    mov ax, 0
    je .end
    
    mov ax, 1
.end:
    pop si
    pop di
    pop es
    pop ds
    popf
    ret

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
