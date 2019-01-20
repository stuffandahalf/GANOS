; EFI emulator for i386 platforms
; Written by Gregory Norton

    [bits 16]
    org 0x1000

_start:
    mov si, strings.test
    call print
    call halt

print:
    push ax
    mov ah, 0x0E
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

strings:
.test: db 'Hello World!', 0
