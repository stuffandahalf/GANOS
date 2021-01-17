#define NORETURN __attribute__((__noreturn__))

unsigned char *vbuf = (unsigned char *)0xb8000;

NORETURN
void halt(void);

void _start(void)
{
	const char *str = "Welcome to minikern!";
	const char *c;
	for (c = str; *c != '\0'; c++) {
		*vbuf++ = *c;
	}

	halt();
}

NORETURN
void halt(void)
{
	__asm__ __volatile__("hlt" : );
	__builtin_unreachable();
}

