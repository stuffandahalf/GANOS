/* System info structure derived from multiboot */

#ifndef ALIX_SYS_SYSTEM_H
#define ALIX_SYS_SYSTEM_H	1

#include <stdint.h>

struct system_mmap;
struct system_bus;

struct system_info {
	/* memory map */
	int32_t mmap_length;
	struct system_mmap *mmap;
	
	uint32_t bus_count;
	struct system_bus *busses;
	
	struct system_framebuffer *fb
};

#define ALIX_MEMORY_AVAILABLE			0
#define ALIX_MEMORY_RESERVED			1
#define ALIX_MEMORY_ACPI_RECLAIMABLE	3
#define ALIX_MEMORY_NVS					4
#define ALIX_MEMORY_BADRAM				5
struct system_mmap {
	uint8_t type;
	uint64_t len;
	void *start;
} __attribute__((packed));

#define ALIX_BUS_MMIO	1		/* memory mapped IO */
#define ALIX_BUS_IOBUS	2		/* dedicated IO bus */
#define ALIX_BUS_ISA	3		/* ISA bus */
struct system_bus {
	uint8_t type;
	
};

#define ALIX_FRAMEBUFFER_EGA_TEXT	1
#define ALIX_FRAMEBUFFER_RGB_
struct system_framebuffer {
	uint8_t type;		/* framebuffer type */
	void *address;		/* starting address */
	uint32_t width;		/* number of addressable columns */
	uint32_t height;	/* number of addressable rows */
	uint32_t pitch;		/* width * bytes per unit */
};

#endif
