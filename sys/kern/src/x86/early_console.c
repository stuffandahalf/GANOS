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

uint16_t row = 0;
uint16_t col = 0;

static inline size_t
fb_index(uint16_t x, uint16_t y)
{
	return y * cols * 2 + x * 2;
}

void
put_char(char c)
{
	size_t i = fb_index(col, row);
	uint16_t x, y;
	fb_ptr[i] = c;
	fb_ptr[i + 1] = 7;
	col++;
	if (col > cols) {
		row++;
		col = 0;
	}
	if (row > rows) {
		for (y = 1; y < rows; y++) {
			for (x = 0; x < cols; x++) {
				fb_ptr[fb_index(x, y - 1)] = fb_ptr[fb_index(x, y)];
				fb_ptr[fb_index(x, y - 1) + 1] = fb_ptr[fb_index(x, y) + 1];
			}
		}
	}
}

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

void
early_console_clear(void)
{
	int i;
	for (i = 0; i < rows * cols * 2; i++) {
		fb_ptr[i] = 0;
	}

	row = 0;
	col = 0;
}

void
early_console_print(const char *msg)
{
	const char *c;
	uint16_t i, j;
	for (c = msg; *c != '\0'; c++) {
		switch (*c) {
		default:
			//*fb_ptr++ = *c;
			//*fb_ptr++ = 7;
			//col++;
			put_char(*c);
			break;
		}
		//*(fb_ptr++) = *(uint16_t *)&fbc;
	}
}

