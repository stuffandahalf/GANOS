#if defined(__i386__)
#define syscall(call, a0) { \
	__asm__( \
		"int $0x80\r\n" \
		: \
		: "a"(call), "b"(a0) \
	); \
}
#elif defined(__powerpc__)
#define syscall(call, a0) { \
	__asm__( \
		"li 0, %0\r\n" \
		"li 1, %1\r\n" \
		"sc\r\n" \
		: \
		: "i"(call), "i"(a0) \
	); \
}
#else
#define syscall(call, a0)
#endif

void
_start(int argc, char *argv[])
{
	syscall(1, 123);
}

