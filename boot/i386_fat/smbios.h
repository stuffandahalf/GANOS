#ifndef SMBIOS_H
#define SMBIOS_H

struct smbios2_header;

struct smbios2_entry_point {
    char entry_str[4];
    uint8_t checksum;
    uint8_t length;
    uint8_t major_version;
    uint8_t minor_version;
    uint16_t max_struct_size;
    uint8_t revision;
    char formatted_area[5];
    char entry_str2[5];
    uint8_t checksum2;
    uint16_t table_length;
    struct smbios2_header *table_address;
    uint16_t number_of_structures;
    uint8_t bcd_revision;
} __attribute__((packed));

enum smbios2_header_type {
    SMBIOS_TYPE_INFO_BIOS = 0,
    SMBIOS_TYPE_INFO_SYSTEM = 1,
    SMBIOS_TYPE_INFO_MAINBOARD = 2,
    SMBIOS_TYPE_INFO_CHASIS = 3,
    SMBIOS_TYPE_INFO_CPU = 4,
    SMBIOS_TYPE_INFO_CACHE = 7,
    SMBIOS_TYPE_INFO_SLOTS = 9,
    SMBIOS_TYPE_PHYSICAL_MEMORY_ARRAY = 16,
    SMBIOS_TYPE_INFO_MEMORY_DEVICE = 17,
    SMBIOS_TYPE_ADDRESS_MEMORY_ARRAY_MAPPED = 19,
    SMBIOS_TYPE_ADDRESS_MEMORY_DEVICE_MAPPED = 20,
    SMBIOS_TYPE_INFO_BOOT = 32
};

struct smbios2_header {
    uint8_t type;
    uint8_t length;
    uint16_t handle;
} __attribute__((packed));

struct smbios2_entry_point *locate_smbios_entry(void);

#endif
