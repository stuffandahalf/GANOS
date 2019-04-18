    [BITS 16]
    ;org 0x500
    
    global _start
    global halt
    extern entry32

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
    
    ;jmp entry
    
get_video_mode:
    mov ah, 0x0F
    int 0x10
    
    mov di, video_data
    mov [di], ax
    ;inc di
    ;inc di
    add di, 2
    mov [di], bh
    
    ;mov si, strings.vmode
    ;add [si], al
    call print
    
go32:
    cli
    lgdt [gdtr]
    mov eax, cr0
    or al, 1
    mov cr0, eax
    jmp 08h:init32
    
    [bits 32]
init32:

    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    
    mov ss, ax
    ;mov esp, 0x90000
    mov esp, 0x7C00
    
    mov eax, video_data
    push eax
    call entry32
    
    
    [bits 16]
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
.null:
    dq 0x0000000000000000
.code_priv0:
    dq 0x00CF9A000000FFFF
.data_priv0:
    dq 0x00CF92000000FFFF
;.code_priv3:
;    dq 0x00CFFA000000FFFF
;.data_priv3:
;    dq 0x00CFF2000000FFFF


gdtr:
    .size: dw $ - gdt - 1
    .offset: dd gdt
    
video_data:
.mode: db 0
.columns: db 0
.active_page: db 0

strings:
.start: db 'Loaded stage 1', 0x0A, 0x0D, 0
.msg: db 'Hello World!', 0x0A, 0x0D, 0
.vmode: db '0 is the video mode', 0x0A, 0x0D, 0
