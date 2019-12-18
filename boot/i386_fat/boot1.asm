    [BITS 16]
    ;org 0x500
    
    global _start
    global halt
    global system
    extern entry32

; print the string stored
; at argument 1 while preserving si
%macro print_s 1
    push si
    mov si, %1
    call print
    pop si
%endmacro 

_start:
    mov [drive.num], dl

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

    ;call disk_io_init
    ;jmp halt
    
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
    print_s .fail_str
    jmp .exit
    
.done:
    mov [memory_map.count], bp
    clc
    
    print_s .success_str
    
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
    print_s .success_str
    clc
    
.exit:
    pop bp
    ret
    
.fail:
    print_s .fail_str
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
    print_s .success_str
    clc
    
.exit:
    ret
    
.fail:
    print_s .fail_str
    stc
    ret ; shorter than jmp .exit

.fail_str: db `88h, int 15h failed\r\n`, 0
.success_str: db `88h, int 15h succeeded\r\n`, 0

%if 0
DISK_IO_TIMEOUT: equ 3

; this is the variable that contains the address
; of the actual disk routine to use
; parameters are es:
disk_io: dw 0

; dl = drive number
disk_io_init:
    push ax
    push bx
    push dx
    
    mov ah, 0x41
    mov bx, 0x55AA
    int 0x13 ; check extensions present
    
    jnc .present
    
.not_present:
    mov word [disk_io], chs_read
    
    print_s .legacy_str
    
    push es
    push di
    
    xor di, di
    mov es, di
    mov ah, 0x08
    int 0x13
    
    inc dh
    mov [chs_drive_params.heads], dh
    
    mov dh, cl
    and dh, 0x1F
    mov [chs_drive_params.sectors_per_track], dh
    
    shr cl, 6
    and cl, 0x2
    mov dh, cl
    mov cl, ch
    mov ch, dl
    inc cx
    
    mov [chs_drive_params.cylinders], cx
    
    pop di
    pop es
    
    jmp .exit
    
.present:
    mov word [disk_io], lba_read
    
    print_s .extension_str
    
    push ds
    push si
    
    xor si, si
    mov ds, si
    mov si, ext_drive_params
    mov ah, 0x48
    int 0x13 ; get drive properties
    mov ax, [ext_drive_params.sector_size]
    mov [drive.sector_size], ax
    
    pop si
    pop ds
    
.exit:
    pop dx
    pop bx
    pop ax
    ret
    
.legacy_str: db `Using CHS disk addressing\r\n`, 0
.extension_str: db `Using int 13h extensions\r\n`, 0
    
chs_drive_params:
.heads: db 0
.cylinders: dw 0
.sectors_per_track: dd 0
    
ext_drive_params:
.size: dw 0x1E
.flags: dw 0
.cylinders: dd 0
.heads: dd 0
.sectors_per_track: dd 0
.sectors: dq 0
.sector_size: dw 0
.edd_config: dd 0
    
chs_read:
    push eax
    push ebx
    push ecx
    
.convert:
    mov edx, [int13h_ext_pkt.starting_sector + 4]
    mov eax, [int13h_ext_pkt.starting_sector]
    div [chs_drive_params.sectors_per_track]    ; eax = tmp, edx = sectors - 1
    inc edx ; sectors
    mov [chs_tmp.sector], edx
    
    push eax
    pop ax
    pop dx
    div [chs_drive_params.heads]
    
    mov [chs_tmp.head], dx
    mov [chs_tmp.cyl], ax
    
.exit:
    pop ecx
    pop ebx
    pop eax
    ret

chs_tmp:
.cyl: dw 0
.sector: dd 0
.head: db 0

; packet should be populated by caller
; dl = drive number
; returns cx = sectors read
lba_read:
    push ax
    push es
    push di
    
    mov cx, DISK_IO_TIMEOUT
    
.rpt:
    mov ah, 0x42
    xor di, di
    mov es, di
    mov di, int13h_ext_pkt
    int 0x13
    jnc .pre_exit
    
    dec cx
    jcxz .fail
    jmp .rpt
    
.pre_exit:
    clc
    mov cx, [int13h_ext_pkt.sector_count]
    
.exit:
    pop di
    pop es
    pop ax
    ret
    
.fail:
    stc
    jmp .exit
    
int13h_ext_pkt:
.size: db 0x10
.unused: db 0
.sector_count: dw 0
.offset: dw 0
.segment: dw 0
.starting_sector: dq 0
%endif

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
drive:
.num: db 0
.sector_size: dw 512

