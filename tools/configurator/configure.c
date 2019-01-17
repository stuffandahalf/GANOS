#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stddef.h>
#include <unistd.h>
#include <zlib.h>

#define die(fmt, ...) { \
    fprintf(stderr, fmt, ##__VA_ARGS__); \
    exit(1); \
}
#define MBR_SIZE 512

#define PART_DATA_LBA 34

#define CYLINDERS 32
#define HEADS 2
#define SECTORS_PER_HEAD 16

#define PART_ARRAY_SLOTS 128

const uint64_t LBA_COUNT = CYLINDERS * HEADS * SECTORS_PER_HEAD;

struct mbr_partition_entry {
    uint8_t status;
    uint8_t first_chs_address[3];
    uint8_t type;
    uint8_t last_chs_address[3];
    uint32_t first_lba;
    uint32_t sector_count;
} __attribute__((packed));

struct gpt_header {
    uint8_t signature[8];
    uint8_t revision[4];
    uint32_t header_size;
    uint32_t crc32_zlib;
    uint8_t reserved[4];
    uint64_t current_lba;
    uint64_t backup_lba;
    uint64_t first_usable_lba;
    uint64_t last_usable_lba;
    uint8_t disk_guid[16];
    uint64_t part_array_lba;
    uint32_t part_entry_count;
    uint32_t part_entry_size;
    uint32_t crc32_zlib_part_array;
} __attribute__((packed));

struct gpt_partition_entry {
    uint8_t partition_type_guid[16];
    uint8_t unique_partition_guid[16];
    uint32_t first_lba; // little endian
    uint32_t last_lba; // inclusive, usually odd, little endian
    uint32_t attribute_flags;
    uint16_t partition_name[36];
} __attribute__((packed));

void configure(int argc, char **argv);
size_t fsize(FILE *fptr);

struct {
    char *dev_name;
    size_t sector_size;
} configuration = { NULL, 0 };

int main(int argc, char **argv) {    
    printf("%ld\n", LBA_COUNT);
    configure(argc, argv);
    
    if (configuration.dev_name == NULL) {
        die("Missing device argument\n");
    }
    if (configuration.sector_size == 0) {
        die("Missing sector size\n");
    }
    
    struct {
        FILE *fptr;
        size_t size;
        size_t sector_size;
    } device = { NULL, 0, configuration.sector_size };

    if ((device.fptr = fopen(configuration.dev_name, "r+")) == NULL) {
        die("Failed to open device file\n");
    }
    device.size = fsize(device.fptr);

    printf("%ld\n", device.size);
    
    // Add protective mbr partition entry
    fseek(device.fptr, MBR_SIZE - sizeof(struct mbr_partition_entry) * 4 - 2, SEEK_SET);
    struct mbr_partition_entry block_part = {
        .status = 0x80,
        .first_chs_address = { 0, 2, 0 },
        .type = 0xEE,
        .last_chs_address = { 2, 32, 16 },
        .first_lba = 1,
        .sector_count = device.size / device.sector_size
    };
    fwrite(&block_part, sizeof(struct mbr_partition_entry), 1, device.fptr);

    // Create gpt partition array
    struct gpt_partition_entry part_array[PART_ARRAY_SLOTS] = { 0 };
    struct gpt_partition_entry efi_part = {
        .partition_type_guid = { 0xC1, 0x2A, 0x73, 0x28, 0xF8, 0x1F, 0x11, 0xD2, 0xBA, 0x4B, 0x00, 0xA0, 0xC9, 0x3E, 0xC9, 0x3B },
        .unique_partition_guid = { 0 },
        .first_lba = PART_DATA_LBA,
        .last_lba = PART_DATA_LBA + 3,
        .attribute_flags = 1,
        //.partition_name = "EFI System Partition"
        .partition_name = { 'H', 'E', 'L', 'L', 'O' }
    };
    efi_part.partition_name[35] = '?';
    part_array[0] = efi_part;

    struct gpt_header primary_gpt_hdr = {
        .signature = { 'E', 'F', 'I', ' ', 'P', 'A', 'R', 'T' },
        .revision = { 0x00, 0x00, 0x01, 0x00 },
        .header_size = sizeof(struct gpt_header),
        .crc32_zlib = 0,
        .reserved = { 0 },
        .current_lba = 1,
        .backup_lba = LBA_COUNT - 1,
        .first_usable_lba = PART_DATA_LBA,
        .last_usable_lba = LBA_COUNT - PART_DATA_LBA,
        .disk_guid = { 0 },
        .part_array_lba = 3,
        .part_entry_count = PART_ARRAY_SLOTS,//1,
        .part_entry_size = sizeof(struct gpt_partition_entry),
        .crc32_zlib_part_array = crc32(0L, (void *)&part_array, PART_ARRAY_SLOTS * sizeof(struct gpt_partition_entry))
    };
    
    primary_gpt_hdr.crc32_zlib = crc32(0L, (void *)&primary_gpt_hdr, sizeof(struct gpt_header));
    
    struct gpt_header backup_gpt_hdr = primary_gpt_hdr;
    backup_gpt_hdr.current_lba = primary_gpt_hdr.backup_lba;
    backup_gpt_hdr.backup_lba = primary_gpt_hdr.current_lba;
    backup_gpt_hdr.part_array_lba = LBA_COUNT - PART_DATA_LBA;
    backup_gpt_hdr.crc32_zlib = 0;
    backup_gpt_hdr.crc32_zlib = crc32(0L, (void *)&backup_gpt_hdr, sizeof(struct gpt_header)),
    
    
    // write primary gpt header and partition table
    fseek(device.fptr, device.sector_size * primary_gpt_hdr.current_lba, SEEK_SET);
    fwrite(&primary_gpt_hdr, sizeof(struct gpt_header), 1, device.fptr);
    fseek(device.fptr, device.sector_size * primary_gpt_hdr.part_array_lba, SEEK_SET);
    fwrite(part_array, sizeof(struct gpt_partition_entry), PART_ARRAY_SLOTS, device.fptr);
    
    // write backup gpt header and partition table
    fseek(device.fptr, device.sector_size * backup_gpt_hdr.part_array_lba, SEEK_SET);
    fwrite(part_array, sizeof(struct gpt_partition_entry), PART_ARRAY_SLOTS, device.fptr);
    fseek(device.fptr, device.sector_size * backup_gpt_hdr.current_lba, SEEK_SET);
    fwrite(&backup_gpt_hdr, sizeof(struct gpt_header), 1, device.fptr);

    fclose(device.fptr);
    return 0;
}

void configure(int argc, char **argv) {
    char *end_ptr;
    int c;
    while ((c = getopt(argc, argv, "d:s:")) != -1) {
        switch (c) {
        case 'd':
            configuration.dev_name = optarg;
            break;
        case 's':
            configuration.sector_size = strtol(optarg, &end_ptr, 0);
            if (end_ptr == optarg) {
                die("Failed to get sector size\n");
            }
            break;
        }
    }
}

size_t fsize(FILE *fptr) {
    size_t tmp = ftell(fptr);
    fseek(fptr, 0L, SEEK_END);
    size_t size = ftell(fptr);
    fseek(fptr, tmp, SEEK_SET);
    return size;
}
