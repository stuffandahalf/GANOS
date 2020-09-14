#include <stddef.h>
#include <stdint.h>

#include <platform/early_console.h>
#include "boot_info.h"

//uint16_t *fb_ptr = NULL;
//uint16_t rows = 0;
//uint16_t cols = 0;

uint8_t *fb_ptr = (uint8_t *)0xB8000;
uint16_t rows = 24;
uint16_t cols = 80;

void
early_console_init(void)
{
/*#ifdef ALIX_KERNEL_FORMAT_MULTIBOOT
	if (mb_info->flags & MULTIBOOT_INFO_FRAMEBUFFER_TABLE_FLAG) {
		fb_ptr = (uint16_t *)mb_info->framebuffer_addr;
		rows = mb_info->framebuffer_height;
		cols = mb_info->framebuffer_width;
	}
#endif*/ /* ALIX_KERNEL_FORMAT_MULTIBOOT */
	early_console_clear();
}

void early_console_clear(void)
{
	int i;
	for (i = 0; i < rows * cols * 2; i++) {
		fb_ptr[i] = 0;
	}
}

void
early_console_print(const char *msg)
{
	const char *c;
	for (c = msg; *c != '\0'; c++) {
		*fb_ptr++ = *c;
		*fb_ptr++ = 7;
		//*(fb_ptr++) = *(uint16_t *)&fbc;
	}
}

