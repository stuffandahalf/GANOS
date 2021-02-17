#ifndef _ALIX_LIBC_STDIO_H
#define _ALIX_LIBC_STDIO_H		1

#ifdef _POSIX_C_SOURCE
#include <sys/types.h>
#endif

#if _POSIX_C_SOURCE >= 200809L
ssize_t getdelim(char **restrict lineptr, size_t *restrict n, int delimiter,
	FILE *restrict stream);
ssize_t getline(char **restrict lineptr, size_t *restrict n,
	FILE *restrict stream);
#endif

#endif

