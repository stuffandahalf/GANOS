    [BITS 16]
    org 0x500

    mov si, msg
    call print
    jmp tst

    times 1000 db 0
tst:
    mov si, msg
    call print
    jmp halt
    
print:
    push ax
    mov ah, 0x0E
.loop:
    lodsb
    test al, al ; if al == 0
    je .end
    int 0x10
    jmp .loop
.end:
    pop ax
    ret

halt:
    cli
    hlt

msg: db 'Hello World!', 0x0A, 0x0D, 0
