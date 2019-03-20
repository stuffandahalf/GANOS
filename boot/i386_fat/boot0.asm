    [BITS 16]
    org 0x7C00

;%define DEBUG

sector_size: equ 0x200
target_segment: equ 0x1000
target_offset: equ 0x0000

STRUC gpt_part
    .part_type_guid: resb 16
    .part_guid: resb 16
    .first_lba: resb 8
    .last_lba: resb 8
    .attribute_flags: resb 8
    .part_name: resw 36
ENDSTRUC

STRUC int13_ext_packet
    .size: resb 1
    .unused: resb 1
    .count: resw 1
    .dest_offset: resw 1
    .dest_segment: resw 1
    .lba: resq 1
ENDSTRUC

STRUC fat32_bpb
    .jmp: resb 3
    .oem: resb 8
    .bytes_per_sector: resw 1
    .sectors_per_cluster: resb 1
    .reserved_sectors: resw 1
    .number_of_fats: resb 1
    .max_root_dir_entries: resw 1
    .total_sectors: resw 1
    .media_descriptor: resb 1
    .sectors_per_fat: resw 1
    
    .sectors_per_track: resw 1
    .heads: resw 1
    .hidden_sectors: resd 1
    .total_sectors_32: resd 1
    
    .sectors_per_fat_32: resd 1
    .drive_description: resw 1
    .version: resw 1
    .root_dir_cluster: resd 1
    .fs_info_sector: resw 1
    .backup_boot_sector: resw 1
    .reserved: resb 12
    .drive_num: resb 1
    .general_purpse: resb 1
    .extended_boot_sig: resb 1
    .volume_id: resd 1
    .volume_label: resb 11
    .fs_type: resb 8
ENDSTRUC

;stage2_segment: equ 0x1000
;stage2_offset: equ 0x0000
stage2:
.segment: equ 0x0000
.offset: equ 0x0500

scratch:
.segment: equ 0x0000
.offset: equ 0x7E00

_start:
.setup:
    ; Configure segment registers to point to correct address
    cli
    cld
    ;mov ax, cs    
    xor ax, ax
    mov ds, ax
    mov es, ax
    ; initialize stack
    mov ss, ax
    mov sp, _start
    
    sti

    ;jmp ax:.init
    push ax
    push word .init
    retf

.init:
    mov [data.drive_num], dl    ; Preserve drive number of loading drive

    mov si, strs.welcome
    call print

; Verify that this is a protective mbr
.verify_mbr:
    mov al, [part_tbl.part1 + part_entry.type]
    cmp al, 0xEE
    jne halt

.check_int13_extensions:
    mov ah, disk_io.check_extension_function
    mov bx, [boot_sig]
    xchg bl, bh
    int disk_io.interrupt
    jnc .load_gpt_hdr
    jmp halt

; load the gpt from the second sector of the drive
.load_gpt_hdr:
    mov dl, [data.drive_num]
    mov si, data.efi_part_lba
    mov bx, 1
    mov di, scratch.offset
    call load_sectors_lba

.verify_gpt:
    ;call validate_gpt_hdr
    mov di, scratch.offset
    mov si, data.efi_part_sig
    mov cl, data.efi_part_sig_len
    call compare_bytes
    cmp ax, 0
    jne halt
    

.load_part_array:
    mov si, scratch.offset + data.gpt_part_array_lba_offset
    mov bx, 1
    mov dl, [data.drive_num]
    mov di, scratch.offset
    call load_sectors_lba

.find_efi_part:
    mov cl, data.gpt_parts_per_sector
.find_efi_part_loop:
    xor ax, ax
    mov al, data.gpt_parts_per_sector
    sub al, cl
    mov bl, gpt_part_size
    mul bl
    add ax, scratch.offset

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
%ifdef DEBUG
    push si
    mov si, strs.found_efi
    call print
    pop si
%endif

    sub si, data.guid_len   ; go back to address of gpt part entry

.load_stage2:
    add si, gpt_part.first_lba
    mov al, 1
    mov dl, [data.drive_num]
    mov di, scratch.offset
    call load_sectors_lba

    mov si, strs.test
    call print

    ; Conversion seems to fail with larger offsets
    mov si, scratch.offset + fat32_bpb.fs_type
    call print

    mov si, strs.test
    call print

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

%if 0
printl:
    push ax
.loop:
    lodsw
    cmp al, 0
    je .end
    mov ah, 0x0E
    int 0x10
    jmp .loop
.end:
    pop ax
    ret
%endif

; construct int 13h extended read
; packet on stack and read data
; parameters:
; bx = sector count
; dl = drive num
; [ds:si] = 8 byte lba
; [es:di] = buffer
load_sectors_lba:
    push cx
    mov cl, .lba_size
    
    std
    add si, .lba_size * 2 - 2
.lba_loop:
    lodsw
    push ax ; add 2 bytes of LBA
    dec cl
    jnz .lba_loop
    
    cld
    
    push es ; add destination segment
    push di ; add destination offset
    push bx ; add number of sectors to be read
    ;push byte 0
    push word .packet_size  ; add packet size
    
    mov cl, .retry_counter
.retry:
    mov ah, disk_io.reset_function
    int disk_io.interrupt

    mov si, sp
    mov ah, disk_io.ext_load_function
    int disk_io.interrupt
    
    jc .fail
    
    add sp, .packet_size
    pop cx
    ret

.fail:
    dec cl
    jz .print_and_exit
    jmp .retry
    
.print_and_exit:
    mov si, .fail_message
    call print
    jmp halt

.lba_size: equ 4 ; words
.retry_counter: equ 4
.packet_size: equ 0x0010
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
.cluster_size: db 8
%ifdef SIZE_MATTERS
.sector_size: dw 512
%endif
;.gpt_array_lba: db 8
.efi_part_lba: dq 1
.efi_part_sig: db 'EFI PART'
.efi_part_sig_len: equ 8
.efi_sys_part_guid: db 0x28, 0x73, 0x2A, 0xC1, 0x1F, 0xF8, 0xD2, 0x11, 0xBA, 0x4B, 0x00, 0xA0, 0xC9, 0x3E, 0xC9, 0x3B
.guid_len: equ 16
.gpt_parts_per_sector: equ 4
.gpt_part_array_lba_offset: equ 0x48
;.efi_exec_name: db 'EFI.BIN'
;.efi_exec_name_len: equ 7

strs:
;.welcome: db 'Loading EFI emulator', 0x0D, 0x0A, 0
;.found_efi: db 'Found EFI partition', 0x0D, 0x0A, 0
.welcome: db 'Loading', 0x0D, 0x0A, 0
%ifdef DEBUG
;.found_efi: db 'Found part', 0x0D, 0x0A, 0
%endif
.test: db 'test', 0x0D, 0x0A, 0
.halted: db 'Halted', 0

disk_io:
.interrupt: equ 0x13
.reset_function: equ 0
.ext_load_function: equ 0x42
;.parameters_function: equ 0x8
.check_extension_function: equ 0x41
.extended_parameters_function: equ 0x48

    times 446 - ($ - $$) db 0

STRUC part_entry
    .status: resb 1
    .first_chs_address: resb 3
    .type: resb 1
    .last_chs_address: resb 3
    .first_lba: resd 1
    .sector_count: resd 1
ENDSTRUC

part_tbl:
%if 0
;.part1: times part_entry_size db 0
%endif
.part1:
ISTRUC part_entry
    at part_entry.status, db 0x80
    at part_entry.first_chs_address, db 0x00, 0x01, 0x00
    at part_entry.type, db 0xEE
    at part_entry.last_chs_address, db 0xFF, 0xFF, 0xFF
    at part_entry.first_lba, dd 0x00000000
    at part_entry.sector_count, dd 0xFFFFFFFF
IEND
.part2: times part_entry_size db 0
.part3: times part_entry_size db 0
.part4: times part_entry_size db 0

boot_sig:
    db 0x55
    db 0xAA
