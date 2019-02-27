#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

struct bpb {
    uint8_t jmp[3];
    uint8_t oem[8];
    
    uint16_t bytes_per_sector;
    uint8_t sectors_per_cluster;
    uint16_t reserved_sectors;
    uint8_t number_of_fats;
    uint16_t number_of_directory_entries;
    uint16_t number_of_sectors_in_volume;
    uint8_t media_type;
    uint16_t na;
    
    uint16_t sectors_per_track;
    uint16_t heads;
    uint32_t dont_use;
    uint32_t total_logical_sectors;
    
    uint32_t sectors_per_fat;
    uint16_t flags;
    uint16_t version;
    uint32_t root_dir_cluster;
    uint16_t fs_info_sector;
    uint16_t fat_copy_sector;
    uint8_t reserved1[12];
    uint8_t drive_num;
    uint8_t reserved2;
    uint8_t extended_boot_sig;
    uint32_t volume_id;
    uint8_t volume_label[11];
    uint8_t fs_type[8];
    
    uint8_t boot_code[420];
    
    uint8_t boot_sig[2];
} __attribute__((packed));

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
    
    printf("%X\n", bpb.number_of_sectors_in_volume);
    
    for (int i = 0; i < 11; i++) {
        printf("%c", bpb.volume_label[i]);
    }
    printf("\n");

    for (int i = 0; i < 8; i++) {
        printf("%c", bpb.fs_type[i]);
    }
    printf("\n");

    printf("%ld\n", sizeof(struct bpb));
    printf("%X\n", *(uint16_t *)bpb.boot_sig);
    
    printf("%X\n", bpb.root_dir_cluster);
    
    
    size_t cluster_size = bpb.sectors_per_cluster * bpb.bytes_per_sector;
    printf("Cluster Size: %ld\n", cluster_size);
    printf("offset: %d\n", (bpb.reserved_sectors * bpb.bytes_per_sector) + (bpb.root_dir_cluster * cluster_size));
    fseek(dev, (bpb.reserved_sectors + (bpb.number_of_fats * bpb.sectors_per_fat)) * bpb.bytes_per_sector, SEEK_SET);
    uint8_t *root_cluster = malloc(sizeof(uint8_t) * cluster_size);
    if (root_cluster == NULL) {
        fprintf(stderr, "Failed to allocate memory for root directory cluster.\n");
        return 1;
    }
    fread(root_cluster, sizeof(uint8_t), cluster_size, dev);
    /*for(int i = 0; i < cluster_size; i++) {
        printf("%d\n", root_cluster[i]);
    }*/
    
    // SUCCESS
    
    free(root_cluster);
    
    /*uint32_t *fat = malloc(bpb.sectors_per_fat * bpb.bytes_per_sector);
    if (fat == NULL) {
        fprintf(stderr, "Failed to allocate memory for FAT.\n");
        return 1;
    }
    
    fseek(dev, bpb.reserved_sectors * bpb.bytes_per_sector, SEEK_SET);
    fread(fat, sizeof(uint8_t), bpb.sectors_per_fat * bpb.bytes_per_sector, dev);
    
    size_t bytes = bpb.sectors_per_fat * bpb.bytes_per_sector;
    for (int i = 0; bytes != 0 && fat[i] != 0; i++) {
        printf("%X\n", fat[i]);
        bytes -= sizeof(uint32_t);
    }
    free(fat);*/

    fclose(dev);

    return 0;
}
