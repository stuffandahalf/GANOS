#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>

#define die(fmt, ...) { \
    fprintf(stderr, fmt, ##__VA_ARGS__); \
    exit(1); \
}
#define MBR_SIZE 512

struct mbr_partition_entry {
    uint8_t status;
    uint8_t first_chs_address[3];
    uint8_t type;
    uint8_t last_chs_address[3];
    uint32_t first_lba;
    uint32_t sector_count;
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

    
    /*// update gpt header
    fseek(device.fptr, device.sector_size, SEEK_SET);
    
    // Add gpt entry for boot partition
    struct gpt_partition_entry efi_part = {
        .partition_type_guid = { 0xC1, 0x2A, 0x73, 0x28, 0xF8, 0x1F, 0x11, 0xD2, 0xBA, 0x4B, 0x00, 0xA0, 0xC9, 0x3E, 0xC9, 0x3B },
        .unique_partition_guid = { 0 },
        .first_lba = 2,
        .last_lba = 5,
        .attribute_flags = 1,
        partition_name = "EFI System Partition"
    }*/

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
