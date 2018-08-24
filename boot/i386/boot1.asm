    [BITS 16]
    org 0x1000

    mov si, msg
    call print

halt:
    nop
    jmp halt

msg: db `Ganix boot stage 1\r\n`, 0

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

    times 8704 - ($-$$) db 0
