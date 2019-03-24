    [BITS 16]
    org 0x500

    mov si, msg
    call print
    jmp halt
    
print:
    push ax
    mov ah, 0x0E
.loop:
    lodsb
    ;cmp al, 0
    test al, al ; if al == 0
    je .end
    int 0x10
    jmp .loop
.end:
    pop ax

halt:
    cli
    hlt

msg: db 'Hello World!', 0x0A, 0x0D, 0
