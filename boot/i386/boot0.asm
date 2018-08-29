    [BITS 16]
    org 0x7c00

reserved_sectors: equ 18
stage1_seg: equ 0000h
stage1_offset: equ 1000h

_start:
    mov [drive_num], dl     ; save loading drive number

    mov si, boot_str        ; load string into source index
    call print              ; and print it

enable_a20:
    call .check
    cmp ax, 1
    je .exit

.enable_bios:
    mov ax, 0x2401
    int 0x15

    call .check
    cmp ax, 1
    je .exit

.enable_kb:
    call .kb_wait_com
    mov al, 0xD1
    out 0x64, al
    call .kb_wait_com
    mov al, 0xDF
    out 0x60, al
    call .kb_wait_com

    call .check
    cmp ax, 1
    je .exit

.enable_fast:
    in al, 0x92
    test al, 2
    jnz .enable_end
    or al, 0x02
    and al, 0xFE
    out 0x92, al

.enable_end:
    call .check
    cmp ax, 1
    je .exit
    jmp .fail

.kb_wait_com:
    in al, 0x64
    test al, 0x02
    jnz .kb_wait_com
    ret

.kb_wait_data:
    in al, 0x64
    test al, 0x01
    jnz .kb_wait_data
    ret

; routine from wiki.osdev.org
.check:
    pushf
    push ds
    push es
    push di
    push si

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
    je .check_exit
    mov ax, 1

.check_exit:
    pop si
    pop di
    pop es
    pop ds
    popf

    ret

.fail:
    mov si, .fail_str
    call print
    jmp halt

.fail_str: db `a20 failed\r\n`, 0
.success_str: db `a20 enabled\r\n`, 0

.exit:
    mov si, .success_str
    call print

load_gdt:
    lgdt [gdt_info]

load_boot1:
.reset_disk:
    mov ah, 00h
    int 13h

.load_sectors:
    mov ax, stage1_seg
    mov es, ax
    mov bx, stage1_offset

    mov ah, 2               ; function 2
;    mov al, 1               ; number of sectors to read (1-128)
    mov al, reserved_sectors
    dec al
    mov ch, 0               ; track/cylinder (0-1023)
    mov cl, 2               ; starting sector (1-17)
    mov dh, 0               ; head number (0-15)
    mov dl, [drive_num]     ; restore drive number
    int 13h

    jc .retry

    jmp .exit

.retry:
    dec byte [.drv_reset_counter] ; decrement reset timeout
    jz .fail
    jmp .reset_disk

.fail:
    mov si, .drv_fail_str
    call print
    jmp halt

.drv_reset_counter: db 3
;.drv_fail_str: db `Failed to load stage 1 bootloader\r\n`, 0
;.drv_success_str: db `Loaded stage 1 bootloader\r\n`, 0
.drv_fail_str: db `Loading failed\r\n`, 0
.drv_success_str: db `Loaded stage 1\r\n`, 0

.exit:
    mov si, .drv_success_str
    call print

    jmp stage1_seg:stage1_offset


; prints the \0 terminated string located in si
print:
    push ax
    mov ah, 0Eh
.loop:
    lodsb
    cmp al, 0
    jz .end
    int 0x10
    jmp .loop
.end:
    pop ax
    ret

halt:
    jmp halt

drive_num:
    db 0

boot_str: db `Ganix boot stage 0\r\n`, 0

gdt_info:
    dw gdt_end - gdt - 1
    dd gdt

gdt:
    dd 0, 0
flatdesc db 0xff, 0xff, 0, 0, 10010010b, 11001111b, 0
gdt_end:

    times 446 - ($ - $$) db 0

part_tbl:
.part1: times 16 db 0
.part2: times 16 db 0
.part3: times 16 db 0
.part4: times 16 db 0

boot_sig:
    db 0x55
    db 0xAA
