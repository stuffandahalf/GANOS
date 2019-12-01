    [BITS 16]
    ;org 0x500
    
    global _start
    global halt
    global memory_map
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
    add di, 2
    mov [di], bh
  
%if 0
get_memory_map:
.try_E820:
    mov di, memory_map.entries
    xor ebx, ebx
    mov edx, 0x534D4159
.get_next_entry:
    mov ecx, 24
    mov eax, 0xE820
    int 0x15
    test ebx, ebx
    jz .next
    jc .next
    xor ch, ch
    add di, 24
    inc byte [memory_map.count]
    jmp .get_next_entry
    
.next:
    mov si, strings.mem2
    call print
%if 0
    test byte [memory_map.count], [memory_map.count]
    jnz .exit
    
.try_E801:
    mov ax, 0xE801
    int 0x15
    
.conventional_memory:
    int 0x12
    add di, 12
    stosb
    inc byte [memory_map.count]
%endif
.exit:
%endif

%if 0
get_memory_map:
.try_E820:
    xor di, di
    mov es, di
    mov di, memory_map.entries
    xor ebx, ebx
    mov edx, 0x534D4150
.E820_lp:
    mov eax, 0xE820
    mov ecx, 24
    int 0x15
    jc .E820_end
    
    mov dword [es:di + 20], 1
    
    ;inc [memory_map.count]
    mov ecx, [memory_map.count]
    inc ecx
    mov [memory_map.count], ecx
    add di, 24
    jmp short .E820_lp
.E820_end:
%endif

    xor di, di
    mov es, di
    mov di, memory_map.entries
    call do_e820
    
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
    
    
    
    ;mov eax, video_data
    mov eax, sys_info
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

mmap_ent: equ memory_map.count
do_e820:
        mov di, 0x8004          ; Set di to 0x8004. Otherwise this code will get stuck in `int 0x15` after some entries are fetched 
	xor ebx, ebx		; ebx must be 0 to start
	xor bp, bp		; keep an entry count in bp
	mov edx, 0x0534D4150	; Place "SMAP" into edx
	mov eax, 0xe820
	mov [es:di + 20], dword 1	; force a valid ACPI 3.X entry
	mov ecx, 24		; ask for 24 bytes
	int 0x15
	jc short .failed	; carry set on first call means "unsupported function"
	mov edx, 0x0534D4150	; Some BIOSes apparently trash this register?
	cmp eax, edx		; on success, eax must have been reset to "SMAP"
	jne short .failed
	test ebx, ebx		; ebx = 0 implies list is only 1 entry long (worthless)
	je short .failed
	jmp short .jmpin
.e820lp:
	mov eax, 0xe820		; eax, ecx get trashed on every int 0x15 call
	mov [es:di + 20], dword 1	; force a valid ACPI 3.X entry
	mov ecx, 24		; ask for 24 bytes again
	int 0x15
	jc short .e820f		; carry set means "end of list already reached"
	mov edx, 0x0534D4150	; repair potentially trashed register
.jmpin:
	jcxz .skipent		; skip any 0 length entries
	cmp cl, 20		; got a 24 byte ACPI 3.X response?
	jbe short .notext
	test byte [es:di + 20], 1	; if so: is the "ignore this data" bit clear?
	je short .skipent
.notext:
	mov ecx, [es:di + 8]	; get lower uint32_t of memory region length
	or ecx, [es:di + 12]	; "or" it with upper uint32_t to test for zero
	jz .skipent		; if length uint64_t is 0, skip entry
	inc bp			; got a good entry: ++count, move to next storage spot
	add di, 24
.skipent:
	test ebx, ebx		; if ebx resets to 0, list is complete
	jne short .e820lp
.e820f:
	mov [mmap_ent], bp	; store the entry count
	clc			; there is "jc" on end of list to this point, so the carry must be cleared
	ret
.failed:
	stc			; "function unsupported" error exit
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
    .size: dw $ - gdt
    .offset: dd gdt
    
strings:
.start: db 'Loaded stage 1', 0x0A, 0x0D, 0
.msg: db 'Hello World!', 0x0A, 0x0D, 0
.mem2: db 'BIOS call int 15h, eax=E820 failed', 0x0A, 0x0D, 0

sys_info:
video_data:
.mode: db 0
.columns: db 0
.active_page: db 0
memory_map:
.count: db 0
.address: dd memory_map.entries;$ + 1
.entries: 

