    [BITS 16]
    org 0x7C00

;%define DEBUG

start:
    mov [data.drive_num], dl    ;Preserve drive number of loading drive
    
    mov al, [part_tbl.part1 + part_entry.type]
%ifndef DEBUG
    cmp al, 0xEE
    jnz halt
%endif

    mov si, strs.test
    call print
    
    
    
    jmp halt

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

load_sector:
    ret
    
halt:
    jmp halt

data:    
.drive_num: db 0

strs:
.test: db 'Hello World', 0
.validation: 

    times 446 - ($ - $$) db 0

metadata:
STRUC part_entry
    .status: resb 1
    .first_chs_address: resb 3
    .type: resb 1
    .last_chs_address: resb 3
    .first_lba: resb 4
    .sector_count: resb 4
ENDSTRUC

part_tbl:
.part1: times part_entry_size db 0
.part2: times part_entry_size db 0
.part3: times part_entry_size db 0
.part4: times part_entry_size db 0

boot_sig:
    db 0x55
    db 0xAA
