    [BITS 16]
    org 0x7C00

;%define VERIFY
;%define DEBUG
;%define PRINT

%if 0
sector_size: equ 0x200
target_segment: equ 0x1000
target_offset: equ 0x0000
%endif

STRUC gpt_part
    .part_type_guid: resb 16
    .part_guid: resb 16
    .first_lba: resb 8
    .last_lba: resb 8
    .attribute_flags: resb 8
    .part_name: resw 36
ENDSTRUC

STRUC int13_ext_read_packet
    .size: resb 1
    .unused: resb 1
    .count: resw 1
    .dest_offset: resw 1
    .dest_segment: resw 1
    .lba: resq 1
ENDSTRUC

STRUC int13_ext_param_packet
    .size: resw 1
    .info_flags: resw 1
    .cylinders: resd 1
    .heads: resd 1
    .sectors_per_track: resd 1
    .sectors: resq 1
    .sector_size: resw 1
    .edd_param_ptr: resd 1
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

STRUC vfat_lfn
    .sequence: resb 1
    .name1: resw 5
    .attributes: resb 1
    .type: resb 1
    .checksum: resb 1
    .name2: resw 6
    .first_cluster: resw 1
    .name3: resw 2
ENDSTRUC

STRUC dir_entry
    .lfn: resb vfat_lfn_size
    
    .short_fname: resb 8
    .short_ext: resb 3
    .file_attributes: resb 1
    .user_attributes: resb 1
    .first_char_deleted_file: resb 1
    .timestamp: resw 1
    .creation_date: resw 1
    .owner_id: resw 1
    .first_cluster_high: resw 1
    .last_modified_time: resw 1
    .last_modified_date: resw 1
    .first_cluster_low: resw 1
    .file_size: resd 1
ENDSTRUC

target:
.segment: equ 0x0000
.offset: equ 0x0500

scratch:
.segment: equ 0x0000
.offset: equ 0x7E00

_start:
.setup:
    ; Configure segment registers to point to correct address
    cli
    ;cld
    xor ax, ax
    mov ds, ax
    mov es, ax
    ; initialize stack
    mov ss, ax
    mov sp, _start

    sti

    push ax
    push word .init
    retf

.init:
    mov [data.drive_num], dl    ; Preserve drive number of loading drive

%ifdef PRINT
    mov si, strs.welcome
    call print
%endif

%ifdef VERIFY
; Verify that this is a protective mbr
.verify_mbr:
    mov al, [part_tbl.part1 + part_entry.type]
    cmp al, 0xEE
    jne halt
%endif

.check_int13_extensions:
    mov ah, disk_io.check_extension_function
    mov bx, [boot_sig]
    xchg bl, bh
    int disk_io.interrupt
    jnc .load_gpt_hdr
    jmp halt
    
.read_drive_params:
    ; dl should contain the drive number already
    mov ah, disk_io.ext_param_function
    mov si, scratch.offset
    int disk_io.interrupt
    
    mov ax, [scratch.offset + int13_ext_param_packet.sector_size]
    mov [data.sector_size], ax

; load the gpt from the second sector of the drive
.load_gpt_hdr:
    mov dl, [data.drive_num]
    mov si, data.efi_part_lba
    mov bx, 1
    mov di, scratch.offset
    call load_sectors_lba

%ifdef VERIFY
.verify_gpt:
    ;call validate_gpt_hdr
    mov di, scratch.offset
    mov si, data.efi_part_sig
    mov cl, data.efi_part_sig_len
    call compare_bytes
    cmp ax, 0
    jne halt
%endif

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
    test al, al ; if al == 0
    jne .part_guid_not_zero
    dec bl
    jnz .check_part_guid_zero
    jmp halt

.part_guid_not_zero:
    pop si
    push cx
    mov cl, data.guid_len
    mov di, data.efi_sys_part_guid
    call compare_bytes
    pop cx
    test ax, ax
    je .efi_part_found

.next_gpt_part:
    dec cl
    jnz .find_efi_part_loop
    jmp halt     ; halt if it is not in the first sector

.efi_part_found:
    sub si, data.guid_len   ; go back to address of gpt part entry

.load_boot_parameter_block:
    add si, gpt_part.first_lba
    push dword [si + 4]     ; store the starting lba of the fat partition
    push dword [si]
    mov al, 1
    mov dl, [data.drive_num]
    mov di, scratch.offset
    call load_sectors_lba

.calculate_root_dir_lba:
    ; root dir cluster * sectors per cluster (64-bit)
    xor ebx, ebx
    mov eax, [scratch.offset + fat32_bpb.root_dir_cluster]
    sub eax, 2
    mov bl, [scratch.offset + fat32_bpb.sectors_per_cluster]
    mul ebx
    ; edx:eax = relative root dir sector
    push edx
    push eax
    
    ; number of fats * sectors per fat (64-bit)
    xor ebx, ebx
    mov eax, [scratch.offset + fat32_bpb.sectors_per_fat_32]
    mov bl, [scratch.offset + fat32_bpb.number_of_fats]
    mul ebx
    ; edx:eax = fat sectors (64-bit)
    
    mov si, sp
    call add64
    add sp, 8
    mov si, sp
    call add64
    add sp, 8
    
; add reserved sectors
    xor ebx, ebx
    mov bx, [scratch.offset + fat32_bpb.reserved_sectors]
    call add64_32

%if 0
    cmp eax, 0x1002
    jne halt
    mov eax, (0x0E << 8) + '='
    int 0x10
    jmp halt
%endif

.load_root_dir:
    push edx
    push eax
    mov si, sp
    mov dl, [data.drive_num]
    mov di, scratch.offset
    mov bl, [di + fat32_bpb.sectors_per_cluster]
    xor bh, bh
    add di, [data.sector_size]
    call load_sectors_lba

%ifdef PRINT
    mov si, [data.sector_size]
    add si, dir_entry.short_fname + scratch.offset
    call print
%endif

.locate_file:
    ; use bl as counter for iterating through files
    mov si, di
    mov di, data.target_fname
    mov cl, data.target_fname_len
.next_file:
    push si
    push di
    add si, dir_entry.short_fname
    call compare_bytes
    test ax, ax
    jz .load_file
    pop di
    pop si
    add si, dir_entry_size
    sub bl, dir_entry_size
    jnz .next_file
    jmp halt
    
.load_file:
    push word [si + dir_entry.first_cluster_high]
    push word [si + dir_entry.first_cluster_low]
    pop eax
    sub eax, 2
    
    mul dword [scratch.offset + fat32_bpb.sectors_per_cluster]
    mov ebx, eax
    mov ecx, edx

    mov si, sp
    call add64
    ;add sp, 8

%if 1
    cmp eax, 0x1003
    jne halt
    mov eax, (0x0E << 8) + '='
    int 0x10
    ;jmp halt
%endif

%if 0
    push edx
    push eax
    mov si, sp
    mov dl, [data.drive_num]
    mov di, target.offset
    mov bl, [scratch.offset + fat32_bpb.sectors_per_cluster]
    xor bh, bh
    call load_sectors_lba
%if 0
    jmp target.segment:target.offset
%else
    push word target.segment
    push word target.offset
    retf
%endif
%endif

    ;mov eax, (0x0E << 8) + '?'
    ;int 0x10

; Disable interrupts and halt the machine
halt:
%ifdef PRINT
    cld
    mov si, strs.halted
    call print
%else
    ;mov ax, (0x0E << 8) + 'H'
    ;int 0x10
%endif
    cli
    hlt
    ;int 0x18
    

%ifdef PRINT
; Print a '\0' terminated string
; parameters: si = string address
print:
    push ax
    mov ah, 0x0E
.loop:
    lodsb
    ;cmp al, 0
    test al, al ; if al == 0
    je .end
    int 0x10
    jmp .loop
.end:
    pop ax
    ret
%endif

; parameters:
; edx:eax 64-bit base
; si 64-bit operand
; return edx:eax
; clobbers ebx
add64:
    mov ebx, [si]
    call add64_32
    mov ebx, [si + 4]
    add edx, ebx
    ret
    
; parameters
; edx:eax 64-bit base
; ebx 32-bit operand
; return edx:eax
add64_32:
    add eax, ebx
    jnc .exit
    inc edx
.exit:
    ret

; construct int 13h extended read
; packet on stack and read data
; parameters:
; bx = sector count
; dl = drive num
; [ds:si] = 8 byte lba
; [es:di] = buffer
load_sectors_lba:
    ;push cx

    push dword [si + 4] ; push low 4 bytes
    push dword [si]     ; push high 4 bytes

    push es ; add destination segment
    push di ; add destination offset
    push bx ; add number of sectors to be read
    push word .packet_size  ; add packet size

    mov cl, .retry_counter
.retry:
    mov ah, disk_io.reset_function
    int disk_io.interrupt

    mov si, sp  ; move this?
    mov ah, disk_io.ext_load_function
    int disk_io.interrupt

    jc .fail

    add sp, .packet_size
    ;pop cx
    ret

.fail:
    dec cl
    jz .print_and_exit
    jmp .retry

.print_and_exit:
%ifdef PRINT
    mov si, .fail_message
    call print
%endif
    mov ax, (0x0E << 8) + 'F'
    int 0x10
    jmp halt

.lba_size: equ 4 ; words
.retry_counter: equ 4
.packet_size: equ 0x0010
%ifdef PRINT
;.fail_message: db 'Failed to load sectors', 0x0D, 0x0A, 0
.fail_message: db 'Err', 0x0D, 0x0A, 0
%endif


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

data:
.drive_num: db 0
.sector_size: dw 1
.efi_part_lba: dq 1
%ifdef VERIFY
.efi_part_sig: db 'EFI PART'
.efi_part_sig_len: equ 8
%endif
.efi_sys_part_guid: db 0x28, 0x73, 0x2A, 0xC1, 0x1F, 0xF8, 0xD2, 0x11, 0xBA, 0x4B, 0x00, 0xA0, 0xC9, 0x3E, 0xC9, 0x3B
.guid_len: equ 16
.gpt_parts_per_sector: equ 4
.gpt_part_array_lba_offset: equ 0x48
.target_fname: db 'HELLO   BIN'
.target_fname_len: equ ($ - .target_fname)

%ifdef PRINT
strs:
.welcome: db 'Loading', 0x0D, 0x0A, 0
.test: db 'test', 0x0D, 0x0A, 0
.halted: db 'Halted', 0
%if 0
.true: db 't', 0
.false: db 'f', 0
%endif
%endif

disk_io:
.interrupt: equ 0x13
.reset_function: equ 0
.ext_load_function: equ 0x42
;.parameters_function: equ 0x8
.check_extension_function: equ 0x41
.ext_param_function: equ 0x48

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
