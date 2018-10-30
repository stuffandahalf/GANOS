    [BITS 16]
    ;org 0x1000
    global _start

STRUC MultibootHeader
    .magic: resd 1
    .flags: resd 1
    .checksum: resd 1
    .header_addr: resd 1
    .load_addr: resd 1
    .load_end_addr: resd 1
    .bss_end_addr: resd 1
    .entry_addr: resd 1
    .mode_type: resd 1
    .width: resd 1
    .height: resd 1
    .depth: resd 1
    .size:
ENDSTRUC

    global boot_str

_start:
    mov si, boot_str
    call print

    ;[extern tst]
    ;call tst

    ;mov si, boot_str
    ;call print

    cli

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ;[extern p_main]
    ;call p_main

    hlt


boot_str: db `Ganix boot stage 1\r\n`, 0

print:
    push ax
    mov ah, 0x0E
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
    jmp halt

    ;times 8704 - ($-$$) db 0
