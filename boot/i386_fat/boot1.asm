    [BITS 16]
    ;org 0x500
    
    global _start
    global halt
    extern entry

_start:
    mov si, strings.start
    call print

enable_a20:
    call .check
    jnc .exit

.enable_bios:
    mov ax, 0x2401
    int 0x15

    call .check
    jnc .exit

.enable_kb:
    call .kb_wait_com
    mov al, 0xD1
    out 0x64, al
    call .kb_wait_com
    mov al, 0xDF
    out 0x60, al
    call .kb_wait_com

    call .check
    jnc .exit

.enable_fast:
    in al, 0x92
    test al, 2
    jnz .enable_end
    or al, 0x02
    and al, 0xFE
    out 0x92, al

.enable_end:
    call .check
    jnc .exit
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

    stc
    je .check_exit
    clc

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

    mov si, strings.msg
    call print
    
    jmp entry
    
load_gdt:
    lgdt [gdtr]
    
halt:
    cli
    hlt
    
    
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

gdt:
.entry0:
    dw 0
    dw 0
.entry1:
    

gdtr:
    .size: dw $ - gdt
    .offset: dd gdt

strings:
.start: db 'Loaded stage 1', 0x0A, 0x0D, 0
.msg: db 'Hello World!', 0x0A, 0x0D, 0
