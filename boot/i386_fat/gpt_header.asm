signature: db 'EFI PART'
revision: db 0x00, 0x00, 0x01, 0x00
header_size: times 4 db 0   ; little endian
header_CRC32_zlib: times 4 db 0     ; little endian
reserved: times 4 db 0
current_lba: times 8 db 0
backup_lba: times 8 db 0
first_partition_lba: times 8 db 0
last_partition_lba: times 8 db 0
UUID: times 16 db 0
first_part_entry_lba: times 8 db 0
part_entry_count: times 4 db 0
part_entry_size: times 4 db 0
part_array_CRC32_zlib: times 4 db 0     ; little endian
