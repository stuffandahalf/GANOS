#include <stdint.h>

//uint16_t *fb_ptr = (uint16_t*)0xB8000;
//uint16_t *fb_ptr = (uint16_t*)0xB0000;
uint16_t *fb_ptr = (uint16_t*)0xB8000;

enum vga_color {
	VGA_COLOR_BLACK = 0,
	VGA_COLOR_BLUE = 1,
	VGA_COLOR_GREEN = 2,
	VGA_COLOR_CYAN = 3,
	VGA_COLOR_RED = 4,
	VGA_COLOR_MAGENTA = 5,
	VGA_COLOR_BROWN = 6,
	VGA_COLOR_LIGHT_GREY = 7,
	VGA_COLOR_DARK_GREY = 8,
	VGA_COLOR_LIGHT_BLUE = 9,
	VGA_COLOR_LIGHT_GREEN = 10,
	VGA_COLOR_LIGHT_CYAN = 11,
	VGA_COLOR_LIGHT_RED = 12,
	VGA_COLOR_LIGHT_MAGENTA = 13,
	VGA_COLOR_LIGHT_BROWN = 14,
	VGA_COLOR_WHITE = 15,
};
 
static inline uint8_t vga_entry_color(enum vga_color fg, enum vga_color bg) 
{
	return fg | bg << 4;
}

void
print(const char *s)
{
	const char *c;
	for (c = s; *c != '\0'; c++) {
		*fb_ptr++ = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK) << 8 | *c;
	}
}

void
kernel_main()
{
	//print("Hello World!\r\n");
	*fb_ptr = (VGA_COLOR_LIGHT_GREY | VGA_COLOR_BLACK << 4) << 8 | '!';
}
