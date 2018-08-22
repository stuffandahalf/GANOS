.code16
.global _start
top:
_start:
    movw $boot_str, %si
    call print

halt:
    #nop
    jmp halt
 
print:
    pushw %ax
    movb $0x0E, %ah
.loop:
    lodsb
    or %al, %al
    jz .end
    int $0x10
    jmp .loop
.end:
    popw %ax
    ret

    .= top + (512 *3)
boot_str: .asciz "Ganix boot stage 1"

    .= top + (512 * 17)
