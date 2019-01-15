#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define die(fmt, ...) { \
        fprintf(stderr, fmt, ##__VA_ARGS__); \
        exit(1); \
}

struct mbr_partition_entry {
    uint8_t status;
    uint8_t first_chs_address[3];
    uint8_t type;
    uint8_t last_chs_address[3];
    uint32_t first_lba;
    uint32_t sector_count;
};

int main(int argc, char **argv) {
    FILE *device;

    if ((device = fopen(argv[1], "r+")) == NULL) {
        die("Failed to open device file\n");
    }

    

    fclose(device);
    return 0;
}
