#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

#define CHUNK_SIZE 12

ssize_t
getline(char **buffer, size_t *buffer_sz, FILE *fp)
{
	char *c;
	ssize_t line_sz = 0;
	
	if (buffer == NULL || buffer_sz == NULL) {
		errno = EINVAL;
		return -1;
	}
	
	if (!*buffer || !*buffer_sz) {
		*buffer_sz = CHUNK_SIZE;
		*buffer = calloc(*buffer_sz, sizeof(char));
		if (!*buffer) {
			//perror("Failed to allocate line buffer");
			errno = ENOMEM;
			return -1;
		}
	}
	
	if (!fgets(*buffer, *buffer_sz, fp)) {
		return -1;
	}
	
	line_sz = strlen(*buffer);
	while (!feof(fp) && !strchr(*buffer, '\n')) {
		if (*buffer_sz - line_sz - 1 == 0) {
			*buffer_sz += CHUNK_SIZE;
			*buffer = realloc(*buffer, *buffer_sz);
			if (!*buffer) {
				errno = ENOMEM;
				return -1;
			}
		}
		for (c = *buffer; *c != '\0'; c++);
		fgets(c, *buffer_sz - line_sz, fp);
		line_sz = strlen(*buffer);
	}
	
	return line_sz;
}
