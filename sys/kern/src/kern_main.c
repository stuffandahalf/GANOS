#include <platform/init.h>
#include <platform/early_console.h>

#define VGA_COLOR_LIGHT_GREY	7
#define VGA_COLOR_BLACK		0

void kernel_main(void)
{
	platform_init();
	early_console_init();
	early_console_print("ALiX 0.0.1 is booted!");
}

