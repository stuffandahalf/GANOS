#include <stdio.h>
#include <stdint.h>

/*struct bpb {
    uint8_t jmp[3];
    uint8_t oem[8];
    uint16_t bytes_per_sector;
    uint8_t sectors_per_cluster;
    uint16_t reserved_sectors;
    uint8_t number_of_fats;
    uint16_t na_for_fat[2];
    uint16_t sectors_per_track;
    uint16_t number_of_heads;
    uint32_t number_of_hidden_sectors;
    uint32_t number_of_sectors_in_part;
    uint32_t number_of_sectors_per_fat;
    uint16_t flags;
    uint16_t fat32_version;
    uint32_t root_dir_cluster;
    uint16_t filesystem_information_sector;
    uint16_t backup_boot_Sector;
    uint8_t reserved2[12];
    uint8_t logical_drive_number;
    //uint8_t unused;
    uint8_t extended_signature;
    uint32_t serial_number;
    uint8_t volume_name[11];
    uint8_t fat_name[8];
    uint8_t executable[420];
    uint8_t boot_signature[2];
};*/

struct bpb {
    uint8_t jmp[3];
    uint8_t oem[8];
    uint16_t bytes_per_sector;
    uint8_t sectors_per_cluster;
    uint16_t reserved_sectors;
    uint8_t number_of_fats;
    uint16_t number_of_director_entries;
    uint16_t number_of_sectors_in_volume;
    uint8_t media_type;
    uint16_t na;
    uint16_t sectors_per_track;
    uint16_t number_of_heads;
    uint32_t hidden_sectors;
    uint32_t large_sector_count;
    uint32_t sectors_per_fat;
    uint16_t flags;
    uint16_t fat_version;
    uint32_t root_directory_cluster;
    uint16_t fsinfo_sector;
    uint8_t reserved[12];
    uint8_t drive_number;
    uint8_t reserved2;
    uint8_t signature;
    uint32_t serial_number;
    uint8_t volume_name[11];
    uint8_t fat_name[8];
    uint8_t executable[420];
    uint8_t boot_sig[2];
};

int main(int argc, char **argv) {
    argc--; argv++;
    if (argc != 1) {
        fprintf(stderr, "Need an input file.\n");
        return 1;
    }

    FILE *dev = fopen(argv[0], "r");
    if (dev == NULL) {
        fprintf(stderr, "Failed to open device \"%s\".\n", argv[0]);
        return 1;
    }


    struct bpb bpb;
    fread(&bpb, sizeof(uint8_t), sizeof(struct bpb), dev);
    for (int i = 0; i < 8; i++) {
        printf("%c", bpb.oem[i]);
    }
    printf("\n");
    
    for (int i = 0; i < 11; i++) {
        printf("%c", bpb.volume_name[i]);
    }
    printf("\n");

    for (int i = 0; i < 8; i++) {
        printf("%c", bpb.fat_name[i]);
    }
    printf("\n");

    printf("%d\n", *(uint16_t *)bpb.boot_sig);

    fclose(dev);

    return 0;
}
