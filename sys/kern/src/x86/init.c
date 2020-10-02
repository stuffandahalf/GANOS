#include <stddef.h>

#include <platform/info.h>
#include <platform/init.h>
#if ALIX_KERNEL_FORMAT_MULTIBOOT
#include <platform/x86/multiboot.h>
extern struct multiboot_info *mb_info;
#endif /* ALIX_KERNEL_FORMAT_MULTIBOOT */

void *platform_info = (void *)0x0;

// load memory map to platform_info
void platform_init(void)
{
	
}

