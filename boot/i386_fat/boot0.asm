    [BITS 16]
    org 0x7C00

;%define DEBUG
;%define USE_LBA

;target_segment: equ 0x1000

%macro LOCATE 0
    push si
    mov si, strs.locate
    call print
    pop si
%endmacro

%macro TST 2
    push si
    cmp %1, %2
    jne %%notequal
    mov si, strs.equal
    call print
    jmp %%end
%%notequal:
    mov si, strs.nequal
    call print
%%end:
    pop si
%endmacro

STRUC gpt_part
    .part_type_guid: resb 16
    .part_guid: resb 16
    .first_lba: resb 8
    .last_lba: resb 8
    .attribute_flags: resb 8
    .part_name: resw 36
ENDSTRUC

stage2_segment: equ 0x1000
stage2_offset: equ 0x0000

gpt_hdr:
.offset: equ 0x1000
.part_array_lba_offset: equ 0x48
.part_entry_size: equ 0x80

_start:
.setup:
    ; Configure segment registers to point to correct address
    mov ax, cs
    mov ds, ax
    ; initialize stack
    mov ax, 0x07C0
    mov ss, ax
    xor sp, sp

    mov [data.drive_num], dl    ; Preserve drive number of loading drive

    mov si, strs.welcome
    call print

; Verify that this is a protective mbr
.verify_mbr:
    mov al, [part_tbl.part1 + part_entry.type]
    cmp al, 0xEE
    jne halt

; load the gpt from the second sector of the drive
.load_gpt_hdr:
%ifndef USE_LBA
    mov al, 1                   ; one sector
    mov ch, 0                   ; cylinder 0
    mov cl, 2                   ; from sector 2
    mov dh, 0                   ; head 0
    mov dl, [data.drive_num]    ; restore the original drive number
    mov bx, gpt_hdr.offset      ; then move the offset to bx
    call load_sectors_chs
%else
    mov si, data.gpt_hdr_lba
    mov al, 1
    mov di, gpt_hdr.offset
    call load_sectors_lba
%endif

.verify_gpt:
    ;call validate_gpt_hdr
    mov di, gpt_hdr.offset
    mov si, data.efi_part_sig
    mov cl, data.efi_part_sig_len
    call compare_bytes
    cmp ax, 0
    jne halt

.load_part_array:
    mov si, gpt_hdr.offset + gpt_hdr.part_array_lba_offset
    ;push si
    mov dl, [data.drive_num]
    mov al, 1
    mov di, gpt_hdr.offset
    call load_sectors_lba

.find_efi_part:
    mov cl, data.gpt_parts_per_sector
.find_efi_part_loop:
    xor ax, ax
    mov al, data.gpt_parts_per_sector
    sub al, cl
    mov bl, gpt_part_size
    mul bl
    add ax, gpt_hdr.offset

    mov si, ax
    push si
    mov bl, data.guid_len

.check_part_guid_zero:
    lodsb
    cmp al, 0
    jne .part_guid_not_zero
    dec bl
    jnz .check_part_guid_zero
    jz halt

.part_guid_not_zero:
    pop si
    push cx
    mov cl, data.guid_len
    mov di, data.efi_sys_part_guid
    call compare_bytes
    pop cx
    cmp ax, 0
    je .efi_part_found

.next_gpt_part:
    dec cl
    jnz .find_efi_part_loop
    jz halt     ; halt if it is not in the first sector

.efi_part_found:
    mov si, strs.found_efi
    call print

    sub si, data.guid_len   ; go back to address of gpt part entry


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


; Algorithm from http://www.osdever.net/tutorials/view/lba-to-chs
; Convert the lba stored at [ds:si] to chs
; for use with int 13h
; parameters:
; al = sector count
; dl = drive num
; [ds:si] = 8 byte lba
; [ds:di] = buffer
load_sectors_lba:
.check_lba_range:
    push di     ; save the destination offset
    push ax     ; save sector count
    push si     ; preserve the first lba address
    add si, 2   ; move on to the next word
    mov cx, 3   ; number of words to check
.loop:
    lodsw       ; load the next word
    cmp ax, 0   ; verify that it contains zeros
    jne halt
    dec cx      ; decrement the counter
    jnz .loop   ; repeat

    pop si      ; restore the location of the lba
    lodsw       ; ax now contains the 16-bit lba

.retrieve_drive_data:
    push dx             ; save drive number
    push ax             ; save lba
    mov ah, disk_io.parameters_function
    xor di, di          ; clear es:di
    mov es, di
    int disk_io.interrupt   ; call disk io interrupt

    jc halt
    pop ax              ; restore lba

.convert:
    push dx         ; preserve number of heads

    xor dx, dx
    mov bx, cx      ; load sectors per track
    and bx, 0x3F    ; isolate sectors per track
    div bx
    inc dx
    pop bx          ; remove number of heads briefly
    push dx         ; save sector
    mov dx, bx      ; move number of heads back to dx

    xor bx, bx
    mov bl, dl      ; move number of heads into bx
    xor dx, dx      ; clear dx
    inc bl
    div bx
    ; ax = cylinder
    ; dx = head
    ; top of stack = sector

    mov ch, al
    mov cl, ah
    shl cl, 6
    pop ax
    or cl, al      ; cx = cylinder + sector

    mov dh, dl      ; dh = head
    pop ax
    mov dl, al      ; dl = drive number

    pop ax          ; al = number of sectors to read

    mov bx, ds
    mov es, bx      ; set es to point to ds
    pop bx          ; restore the destination offset

    ; fall through to chs load routine

; Load the given sectors
; retrying 3 times on failure
; parameters: same as int 13h
load_sectors_chs:
.init:
    mov byte [.retry_counter], 3
    ;mov [.cylinder_and_sector_address], cx
    push cx
.reset_disk:
    mov ah, disk_io.reset_function
    int disk_io.interrupt
    jc .fail
.load:
    mov ah, disk_io.load_function
    ;mov cx, [.cylinder_and_sector_address]
    pop cx
    int disk_io.interrupt

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

.retry_counter: db 0
;.cylinder_and_sector_address: dw 0
.fail_message: db 'Failed to load sectors', 0x0D, 0x0A, 0



; Validate that loaded sector is a gpt header
;validate_gpt_hdr:
; ds:si = address of first set of bytes
; ds:di = address of second set of bytes
; cl = number of bytes to compare
compare_bytes:
.loop:
    lodsb   ; load al with next character from required header
    cmp [di], al
    jne .fail
    inc di  ; go to next character in loaded header

    dec cl
    jnz .loop

.success:
    xor ax, ax
    ret

.fail:
    mov ax, 1
    ret

; Disable interrupts and halt the machine
halt:
    cld
    mov si, strs.halted
    call print
    cli
    hlt

data:
.drive_num: db 0
.heads: db 0
.total_cylinders_and_spt: dw 0  ; spt = sectors per track
%ifdef USE_LBA
.gpt_hdr_lba: dq 1
%endif
.gpt_array_lba: db 8
.efi_part_sig: db 'EFI PART'
.efi_part_sig_len: equ 8
.efi_sys_part_guid: db 0x28, 0x73, 0x2A, 0xC1, 0x1F, 0xF8, 0xD2, 0x11, 0xBA, 0x4B, 0x00, 0xA0, 0xC9, 0x3E, 0xC9, 0x3B
.guid_len: equ 16
.gpt_parts_per_sector: equ 4
.efi_exec_name: db 'EFI.BIN'
.efi_exec_name_len: equ 7

strs:
%ifdef DEBUG
.test: db 'Hello World', 0x0D, 0x0A, 0
.locate: db 'Here?', 0x0D, 0x0A, 0
.equal: db 'register is equal', 0x0D, 0x0A, 0
.nequal: db 'register is not equal', 0x0D, 0x0A, 0
%endif
.welcome: db 'Loading EFI emulator', 0x0D, 0x0A, 0
.found_efi: db 'Found EFI partition', 0x0D, 0x0A, 0
.halted: db 'Halted', 0

disk_io:
.interrupt: equ 0x13
.reset_function: equ 0
.load_function: equ 0x2
.parameters_function: equ 0x8

    ;times 446 - ($ - $$) db 0

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
