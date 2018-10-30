    [BITS 16]
    org 0x7C00
    
;reserved_sectors: equ 18

_start:
    mov [drive_num], dl ;Preserve drive number of loading drive
    
    
    
    times 446 - ($ - $$) db 0

part_tbl:
.part1: times 16 db 0
.part2: times 16 db 0
.part3: times 16 db 0
.part4: times 16 db 0

boot_sig:
    db 0x55
    db 0xAA
