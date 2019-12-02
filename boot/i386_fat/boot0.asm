    [BITS 16]
    org 0x7C00

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

%if 1
target:
.segment: equ 0x0000
.offset: equ 0x0500
%else
target:
.segment: equ 0x0005
.offset: equ 0x0000
%endif

scratch:
.segment: equ 0x0000
.offset: equ 0x7E00

_start:
.setup:
    ; Configure segment registers to point to correct address
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    ; initialize stack
    mov ss, ax
    mov sp, _start

    sti

    push ax
    push word init
    retf

init:
    mov [data.drive_num], dl    ; Preserve drive number of loading drive

check_int13_extensions:
    mov ah, disk_io.check_extension_function
    mov bx, 0x55AA
    int disk_io.interrupt
    jc halt
        
read_drive_params:
    mov ah, disk_io.ext_param_function
    mov si, scratch.offset
    int disk_io.interrupt
    jc load_gpt_hdr
    
    mov ax, [scratch.offset + int13_ext_param_packet.sector_size]
    mov [data.sector_size], ax

; load the gpt from the second sector of the drive
load_gpt_hdr:
    mov di, scratch.offset
    push di
    xor edx, edx
    mov bx, 1
    movzx eax, bl   ; edx:eax = 1
    call load_sectors_lba_reg

load_part_array:
    mov si, scratch.offset + data.gpt_part_array_lba_offset
    ;mov bx, 1   ; should change this to 31?
    ;add bl, 30
    call load_sectors_lba

find_efi_part:
    mov cl, data.gpt_parts_per_sector
    mov si, di
    mov di, data.efi_sys_part_guid
.next:
    mov cl, data.guid_len
    call compare_bytes
    jnc load_boot_parameter_block
    dec cl
    jz halt
    add si, gpt_part_size
    jmp .next
    
load_boot_parameter_block:
    pop di  ;mov di, scratch.offset
    add si, gpt_part.first_lba
    mov edx, [si + 4]
    mov eax, [si]
    mov bx, 1
    call load_sectors_lba_reg
    
init_fat:
    movzx ebx, word [di + fat32_bpb.reserved_sectors]
    call add64_32
    ; edx:eax = fat lba
    
    mov si, data.fat_lba
    mov [si], eax
    mov [si + 4], edx
    
    ;push di ; preserve fat bpb
    add di, [data.sector_size]
    mov bx, 1
    call load_sectors_lba_reg
    
    ; number of fats * sectors per fat (64-bit)
    xor edx, edx
    mov eax, [scratch.offset + fat32_bpb.sectors_per_fat_32]
    movzx ebx, byte [scratch.offset + fat32_bpb.number_of_fats]
    mul ebx
    call add64
    
    mov [si + 8], eax               ; si = data.fat_lba + 8 = data_lba
    mov [data.data_lba + 12], edx
    
load_root_dir:
    mov eax, [scratch.offset + fat32_bpb.root_dir_cluster]
    call load_file_from_cluster_buffer
    

locate_file:
    mov si, data.target_fname
    push di
    add di, dir_entry.short_fname
    mov cl, data.target_fname_len
.next_file:
    call compare_bytes
    jnc load_file
    add di, dir_entry_size
    test byte [di], 0
    jnz .next_file
    ; Should halt here
    ;call halt
    
load_file:
    push word [di + dir_entry.first_cluster_high - dir_entry.short_fname]
    push word [di + dir_entry.first_cluster_low - dir_entry.short_fname]
    pop eax
    pop si
    mov di, target.offset
    call load_file_from_cluster
    
    ;jmp halt
    jmp target.segment:target.offset

; Disable interrupts and halt the machine
halt:
    ;mov ax, (0x0E << 8) + 'H'
    ;int 0x10
dhalt:
    cli
    hlt
    ;int 0x18


; parameters:
; edx:eax 64-bit base
; si 64-bit operand
; return edx:eax
add64:
    add eax, [si]
    adc edx, [si + 4]
    ret
    
; parameters
; edx:eax 64-bit base
; ebx 32-bit operand
; return edx:eax
add64_32:
    add eax, ebx
    adc edx, 0
    ;jnc .exit
    ;inc edx
;.exit:
    ret

; eax = cluster
; es:di = scratch (1xsector) + buffer (sectors_per_cluster)
; returns ecx = sectors read
;         di = file
load_file_from_cluster_buffer:
    mov cx, [data.sector_size]
    mov si, di                  ; si = scratch buffer
    ;add di, [data.sector_size]  ; di = destination
    add di, cx
load_file_from_cluster:
    push di
    
.loop:
    push eax
    sub eax, 2
    movzx ebx, byte [scratch.offset + fat32_bpb.sectors_per_cluster]
    mul ebx
    ; edx:eax = relative sector
    
    push si
    mov si, data.data_lba
    call add64
    ; edx:eax = absolute cluster lba
    pop si
    ;movzx bx, byte [scratch.offset + fat32_bpb.sectors_per_cluster]
    ; ebx still sectors per cluster
    call load_sectors_lba_reg
    
    ;movzx eax, word [data.sector_size]
    movzx eax, cx
    shr ax, 2   ; ax = (ax / sizeof(entry)) = ax / 4 = ax >> 2
    ; ax = entries per sector
    
    xor edx, edx
    pop ebx
    xchg eax, ebx
    div ebx
    ; eax = page / sector offsets
    ; edx = offset / index
    
    push di
    push edx
    xor edx, edx
    mov di, si
    mov si, data.fat_lba
    call add64
    mov si, di
    
    mov bx, 1
    call load_sectors_lba_reg

    pop eax
    shl eax, 2  ; index * sizeof(entry)
    mov eax, [edi + eax]
    pop di
    
    cmp eax, data.fat_terminator
    jae .exit
    ;add di, [data.sector_size]
    add di, cx
    jmp .loop
    
.exit:
    pop di
    ret

; parameters:
; edx:eax = 64-bit lba
; bx = sector count (max 127)
; [es:di] = buffer
load_sectors_lba_reg:
    push si
    push edx
    push eax
    mov si, sp
    call load_sectors_lba
    ;add sp, 8
    pop eax
    pop edx
    pop si
    ret

; construct int 13h extended read
; packet on stack and read data
; parameters:
; bx = sector count (max 127)
; [ds:si] = 8 byte lba
; [es:di] = buffer
load_sectors_lba:
    ;push si
    
.load:
    push dword [si + 4] ; push low 4 bytes
    push dword [si]     ; push high 4 bytes
    push es             ; add destination segment
    push di             ; add destination offset
    push bx             ; add number of sectors to be read
    push word .packet_size  ; add packet size

    mov si, sp
    ;mov cl, .retry_counter
;.retry:
    mov dl, [data.drive_num]
%if 0
    mov ah, disk_io.reset_function
    int disk_io.interrupt
%endif

    mov ah, disk_io.ext_load_function
    int disk_io.interrupt

    ;jc .fail

    add sp, .packet_size
    ;pop si
    ret

;.fail:
    ;dec cl
    ;jnz .retry

.print_and_exit:
%if 0
    ;mov ax, (0x0E << 8) + 'F'
    ;int 0x10
%endif
    ;cli
    ;hlt

.lba_size: equ 4 ; words
.retry_counter: equ 4
.packet_size: equ int13_ext_read_packet_size


; Validate that loaded sector is a gpt header
;validate_gpt_hdr:
; ds:si = address of first set of bytes
; ds:di = address of second set of bytes
; cl = number of bytes to compare
; carry flag set if false
compare_bytes:
    push si
    push di
.loop:
    lodsb   ; load al with next character from required header
    cmp [di], al
    jne .fail
    inc di  ; go to next character in loaded header

    dec cl
    jnz .loop

.success:
    clc
    jmp .exit

.fail:
    stc
.exit:
    pop di
    pop si
    ret

data:
.drive_num: db 0x80
.sector_size: dw 512
.fat_terminator: equ 0x0FFFF7   ; ja to test
.fat_lba: dq 0
.data_lba: dq 0
.efi_sys_part_guid: db 0x28, 0x73, 0x2A, 0xC1, 0x1F, 0xF8, 0xD2, 0x11, 0xBA, 0x4B, 0x00, 0xA0, 0xC9, 0x3E, 0xC9, 0x3B
.guid_len: equ 16
.gpt_parts_per_sector: equ 4
.gpt_part_array_lba_offset: equ 0x48
.target_fname: db 'BOOTLD  BIN'
.target_fname_len: equ ($ - .target_fname)

disk_io:
.interrupt: equ 0x13
.reset_function: equ 0
.ext_load_function: equ 0x42
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
