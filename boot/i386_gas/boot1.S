.code16
.global _start
top:
    jmp _start
msg: .asciz "Hello from second sector\r\n"
msg2: .asciz "I just want you to know that this took me at least 5 hours\r\n"

_start:
    movw $msg, %si
    call print

    movw $msg2, %si
    call print

halt:
    nop
    jmp halt
 
print:
    pushw %ax
    movb $0x0E, %ah
.loop:
    lodsb
    cmpb $0x00, %al
    jz .end
    int $0x10
    jmp .loop
.end:
    popw %ax
    ret

    .= top + (512 * 17)
