#if defined(__GNUC__) && !defined(__clang__)
#ifdef _POSIX_C_SOURCE
#undef _POSIX_C_SOURCE
#endif /* defined(__POSIX_C_SOURCE) */
#define _POSIX_C_SOURCE	2
#endif /* defined(__GNUC__) && !defined(__clang__) */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define DEFAULT_BUFFER_CAPACITY			15
#define DEFAULT_LINE_BUFFER_CAPACITY	50

struct line_buffer {
	size_t capacity;
	size_t length;
	char *buffer;
};

int configure(int argc, char *argv[]);
void release_buffer(void);

const char *prompt = NULL;
size_t address = 0;
size_t file_buffer_capacity = DEFAULT_BUFFER_CAPACITY;
size_t file_buffer_size = 0;
struct line_buffer *file_buffer = NULL;

int
main(int argc, char *argv[])
{
	int running = 1;

	char input_buffer[50];

	if (!configure(argc, argv)) {
		return 1;
	}
	
	file_buffer = calloc(DEFAULT_BUFFER_CAPACITY, sizeof(struct line_buffer));
	if (file_buffer == NULL) {
		fprintf(stderr, "Failed to allocate line buffer\n");
		exit(1);
	}

	while (running) {
		printf("%s", prompt);
		if (fgets(input_buffer, 50, stdin) == NULL) {
			release_buffer();
			fprintf(stderr, "Failed to read from stdin\n");
			return 1;
		}
	}

	return 0;
}

/* Configures the utility */
int
configure(int argc, char *argv[])
{
	int c;
	while ((c = getopt(argc, argv, "hsp:")) != -1) {
		switch (c) {
		case 's':
			break;
		case 'p':
			prompt = optarg;
			break;
		case '?':
			fprintf(stderr, "Unrecognized argument \"%c\"\n", c);
			/* FALL THROUGH */
		case 'h':
		default:
			fprintf(stderr, "Usage: %s [-s] [-p PROMPT] [FILE]\n", argv[0]);
			return 0;
		}
	}
	return 1;
}

void
release_buffer(void)
{
	size_t i;
	for (i = 0; i < file_buffer_size; i++) {
		free(file_buffer[i].buffer);
	}
	free(file_buffer);
}

