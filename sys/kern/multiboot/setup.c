#include <stdint.h>
#include <sys/multiboot.h>
#include <sys/system.h>

static void memory(struct multiboot_mmap_entry *, struct system_mmap *);

static void *next_ptr;

void
setup(struct multiboot_info *mb_info, struct system_info *sys_info)
{
	void *mb_ptr;
	
	next_ptr = sys_info + sizeof(struct system_info);
	
	if (mb_info->flags & MULTIBOOT_INFO_MEM_MAP) {
		sys_info->mmap_length = mb_info->mmap_length;
		sys_info->mmap = next_ptr;
		mb_ptr = (void *)mb_info->mmap_addr;
		memory(mb_ptr, sys_info->mmap);
	} else {
		sys_info->mmap_length = -1;
		sys_info->mmap = NULL;
	}
	
	if (mb_info->flags & MULTIBOOT_INFO_FRAMEBUFFER_INFO) {
		framebuffer(struct multiboot_info *mb_info, next_ptr);
		next_ptr
	}
}

static void
memory(struct multiboot_mmap_entry *mb_mmap, struct system_mmap *sys_mmap)
{
	int i;
	for (i = 0; i < mb_info->mmap_length; i++) {
		switch (mb_mmap[i].type) {
		case MULTIBOOT_MEMORY_AVAILABLE:
			sys_mmap[i].type = ALIX_MEMORY_AVAILABLE;
			break;
		case MULTIBOOT_MEMORY_RESERVED:
			sys.mmap[i].type = ALIX_MEMORY_RESERVED;
			break;
		case MULTIBOOT_MEMORY_ACPI_RECLAIMABLE:
			sys.mmap[i].type = ALIX_MEMORY_ACPI_RECLAIMABLE;
			break;
		case MULTIBOOT_MEMORY_NVS:
			sys.mmap[i].type = ALIX_MEMORY_NVS;
			break;
		case MULTIBOOT_MEMORY_BADRAM:
			sys.mmap[i].type = ALIX_MEMORY_BADRAM;
			break;
		}
		next_ptr = &sys_mmap[i + 1];
	}
}

static void
framebuffer(struct multiboot_info *mb_info, struct system_framebuffer *
