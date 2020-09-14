#include <stddef.h>

#include <platform/info.h>
#include <platform/init.h>
#ifdef ALIX_KERNEL_FORMAT_MULTIBOOT
#include <platform/x86/multiboot.h>
//struct multiboot_info *mb_info = NULL;
#endif /* ALIX_KERNEL_FORMAT_MULTIBOOT */

void platform_init(void)
{
/*#ifdef ALIX_KERNEL_FORMAT_MULTIBOOT
	uint32_t ebx;
	__asm__ __volatile__ ("" : "=b"(ebx));
	mb_info = (void *)ebx;
#endif*/ /* ALIX_KERNEL_FORMAT_MULTIBOOT */
}

