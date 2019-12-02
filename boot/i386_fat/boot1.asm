    [BITS 16]
    ;org 0x500
    
    global _start
    global halt
    global system
    extern entry32

_start:
    mov si, strings.start
    call print
    jc halt

try_enable_a20:
    call enable_a20
    
get_video_mode:
    mov ah, 0x0F
    int 0x10
    
    mov di, video_data
    mov [di], ax
    add di, 2
    mov [di], bh
  
get_memory_map:
    call mmap_e820h
    jnc .success
    
.int12h:
    mov word [memory_map.count], 1

    xor eax, eax
    int 0x12
    shl eax, 10
    
    xor di, di
    mov es, di
    mov di, memory_map.entries
    
    ;mov dword [es:di], 0
    mov dword [es:di + 8], eax
    mov dword [es:di + 16], 1
    mov dword [es:di + 20], 1
    
    add di, 24
    
    call mmap_e801h
    jnc .success
    
    call mmap_88h
    jnc .success
    
    mov si, strings.mem_probe_failed
    call print
    
.success:
    
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
    mov esp, 0x7C00
    
    ;mov eax, sys_info
    ;push eax
    call entry32
    
    
    [bits 16]
halt:
    cli
    hlt
    jmp halt    ; if an nmi ever awakes processor
    
    
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
    stc
    ret

.fail_str: db `a20 failed\r\n`, 0
.success_str: db `a20 enabled\r\n`, 0

.exit:
    mov si, .success_str
    call print
    ret


mmap_e820h:
    push es
    push di
    push bp
    push eax
    push ebx
    push ecx
    push edx

.init:
    xor bp, bp
    xor di, di
    mov es, di
    mov di, memory_map.entries
    xor ebx, ebx
    mov edx, 0x534D4150
    
.loop:
    mov eax, 0xE820
    mov ecx, 24
    int 0x15
    jc .fail
    
    inc bp
    mov dword [es:di + 20], 1
    test ebx, ebx
    jz .done
    
    add di, 24
    jmp .loop
    
.fail:
    stc
    push si
    mov si, .fail_str
    call print
    pop si
    jmp .exit
    
.done:
    mov [memory_map.count], bp

    clc
    push si
    mov si, .success_str
    call print
    pop si
    
.exit:
    pop edx
    pop ecx
    pop ebx
    pop eax
    pop bp
    pop di
    pop es
    ret
    
.fail_str: db `E820h, 15h failed\r\n`, 0
.success_str: db `E820h, 15h succeeded\r\n`, 0
    
mmap_e801h:
    push bp

    mov ax, 0xE801
    int 0x15
    
    jc .fail
    
    ; figure out which set of registers to use
    mov bp, ax
    and bp, bx
    jnz .cx_dx
    
.ax_bx:
    mov cx, ax
    mov dx, bx
    
.cx_dx:
    xor eax, eax
    mov ax, [memory_map.count]  ; eax should be 1, use it to initialize fields

    shl ecx, 10
    shl edx, 16

    mov dword [es:di], 0x100000     ; base 1M
    mov [es:di + 8], ecx            ; length = cx * 1024
    mov [es:di + 16], eax           ; type = free
    mov [es:di + 20], eax           ; acpi flag
    
    add di, 24
    
    mov dword [es:di], 0x1000000    ; base 16M
    mov [es:di + 8], edx            ; length = edx * 64 * 1024
    mov [es:di + 16], eax           ; type = free
    mov [es:di + 20], eax           ; acpi flag
    
    add ax, 2
    mov [memory_map.count], ax
    
.success:
    push si
    mov si, .success_str
    call print
    pop si

    clc
    
.exit:
    pop bp
    ret
    
.fail:
    push si
    mov si, .fail_str
    call print
    pop si
    stc
    jmp .exit
    
.success_str: db `E801h, int 15h succeeded\r\n`, 0
.fail_str: db `E801h, int 15h failed\r\n`, 0

mmap_88h:
    clc
    xor eax, eax
    mov ah, 0x88
    int 0x15
    jc .fail
    test ax, ax
    jz .fail
    
    xor ebx, ebx
    shl eax, 10
    
    mov bx, [memory_map.count]
    mov dword [es:di], 0x100000 ; memory starting from 1M
    mov [es:di + 8], eax
    mov [es:di + 16], ebx
    mov [es:di + 20], ebx
    
    inc bx
    mov [memory_map.count], bx
    
.success:
    push si
    mov si, .success_str
    call print
    pop si
    clc
    
.exit:
    ret
    
.fail:
    push si
    mov si, .fail_str
    call print
    pop si
    stc
    ret ; shorter than jmp .exit

.fail_str: db `88h, int 15h failed\r\n`, 0
.success_str: db `88h, int 15h succeeded\r\n`, 0

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
    .size: dw $ - gdt
    .offset: dd gdt
    
strings:
.start: db 'Loaded stage 1', 0x0A, 0x0D, 0
.msg: db 'Hello World!', 0x0A, 0x0D, 0
;.mem2: db 'BIOS call int 15h, eax=E820 failed', 0x0A, 0x0D, 0
.mem_probe_failed: db `Failed to get memory over 640k\r\n`, 0

system:
video_data:
.mode: db 0
.columns: db 0
.active_page: db 0
memory_map:
.count: dw 0
.entries: resb 24 * 16  ; space for 16 memory entries

