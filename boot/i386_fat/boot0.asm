    [BITS 16]
    org 0x7C00

;%define DEBUG

;target_segment: equ 0x1000

stage2_segment: equ 0x1000
stage2_offset: equ 0x0000

gpt_hdr:
.offset: equ 0x1000
.part_array_lba_offset: equ 0x48
.part_entry_size: equ 0x80

_start:
    mov [data.drive_num], dl    ;Preserve drive number of loading drive

    mov si, strs.welcome
    call print

.check_13h_extensions:
    mov ah, 0x41
    mov dl, [data.drive_num]
    mov bx, 0x55AA
    int 0x13
    jc halt
    and cx, 1
    jz halt

.verify_mbr:
    ; Verify that this is a protective mbr
    mov al, [part_tbl.part1 + part_entry.type]
    cmp al, 0xEE
    jnz halt

; load the gpt from the second sector of the drive
.load_gpt_hdr:
    mov al, 1                   ; one sector
    mov ch, 0                   ; cylinder 0
    mov cl, 2                   ; from sector 2
    mov dh, 0                   ; head 0
    mov dl, [data.drive_num]    ; restore the original drive number
    mov bx, gpt_hdr.offset      ; then move the offset to bx
    call load_sectors_chs

.verify_gpt:
    call validate_gpt_hdr

.load_part_array:
    mov si, gpt_hdr.offset + gpt_hdr.part_array_lba_offset
    call load_sectors_lba

.find_efi_part:

%ifdef DEBUG
    mov si, strs.test
    call print
%endif
    jmp halt

; Print a '\0' terminated string
; parameters: si = string address
print:
    push ax
    mov ah, 0x0E
.loop:
    lodsb
    cmp al, 0
    je .end
    int 0x10
    jmp .loop
.end:
    pop ax
    ret

; Convert the lba stored at [si] to chs
; for use with int 13h
; parameters:
; al = sector count
; dl = drive num
; [es:si] = 8 byte lba
load_sectors_lba:
.retrieve_drive_data:
    push ax
    push dx
    push es
    mov ah, 0x08
    xor di, di
    mov es, di
    int 0x13

    jc halt
    pop es

.get_sector:
    mov ax, [es:si]
    mov dx, cx
    and dx, 0x3F    ; isolate the sectors per track

%ifdef DEBUG
    ret
%endif

; Load the given sectors
; retrying 3 times on failure
; parameters: same as int 13h
load_sectors_chs:
.init:
    mov byte [.retry_counter], 3
    mov [.cylinder_and_sector_address], cx
.reset_disk:
    mov ah, .reset_function
    int .disk_interrupt
    jc .fail
.load:
    mov ah, .read_function
    mov cx, [.cylinder_and_sector_address]
    int .disk_interrupt

    jc .retry

.exit:
    ret

.retry:
    dec byte [.retry_counter]
    jnz .reset_disk             ; try again if this wasnt the last iteration

.fail:
    mov si, .fail_message
    call print
    jmp halt

.disk_interrupt: equ 0x13
.reset_function: equ 0x00
.read_function: equ 0x02
.retry_counter: db 0
.cylinder_and_sector_address: dw 0
.fail_message: db 'Failed to load sectors', 0x0D, 0x0A, 0



; validate that loaded sector is a gpt header
validate_gpt_hdr:
    mov bl, data.efi_part_sig_len
    mov si, data.efi_part_sig
    mov di, gpt_hdr.offset

.loop:
    lodsb   ; load al with next character from required header
    cmp [di], al
    jne .fail
    inc di  ; go to next character in loaded header

    dec bl
    jnz .loop

.success:
    ret

.fail:
    jmp halt

; Enter an infinite loop
; to halt the machine
halt:
    mov si, strs.halted
    call print
.loop:
    jmp .loop

data:
.drive_num: db 0
.sectors_per_track: db 0
.gpt_array_lba: db 8
.efi_part_sig: db 'EFI PART'
.efi_part_sig_len: equ 8

strs:
%ifdef DEBUG
.test: db 'Hello World', 0x0D, 0x0A, 0
%endif
.welcome: db 'Loading EFI emulator', 0x0D, 0x0A, 0
.halted: db 'Halted', 0

    times 446 - ($ - $$) db 0

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
