    [BITS 16]
    org 0x1000
    mov si, msg
    call print
    hlt

msg: db 'Hello from second sector', 0

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
