#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

#define CHUNK_SIZE 12

#if __STDC_VERSION__ < 199901L
#define restrict
#endif

ssize_t
getdelim(char **restrict lineptr, size_t *restrict n, int delimiter,
	FILE *restrict stream)
{
	int c = 0;
	ssize_t len = 0;
	
	if (!lineptr || !n) {
		errno = EINVAL;
		return -1;
	}
	
	if (!*lineptr || !*n) {
		*lineptr = malloc(sizeof(char) * CHUNK_SIZE);
		if (!*lineptr) {
			errno = ENOMEM;
			return -1;
		}
		*n = CHUNK_SIZE;
	}
	
	while (c != delimiter && (c = fgetc(stream)) != EOF) {
		if (len == *n - 2) {
			*lineptr = realloc(*lineptr, sizeof(char) * (*n + CHUNK_SIZE));
			if (!*lineptr) {
				errno = ENOMEM;
				return -1;
			}
			*n += CHUNK_SIZE;
		}
		(*lineptr)[len++] = c;
		if (c == delimiter) {
			(*lineptr)[len] = '\0';
		}
	}
	if (!len && c == EOF) {
		return -1;
	}
	
	return len;
}

ssize_t
getline(char **restrict lineptr, size_t *restrict n, FILE *restrict stream)
{
	return getdelim(lineptr, n, '\n', stream);
}
