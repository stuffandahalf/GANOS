unsigned char *vbuf = (void *)0xb8000;

void halt(void);

void _start(void)
{
	const char *str = "Kernel loaded";
	const char *c;
	for (c = str; *c != '\0'; c++) {
		*vbuf++ = *c;
	}

	halt();
}

void halt(void)
{
	__asm__("hlt");
}

