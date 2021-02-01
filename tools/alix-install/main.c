#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <unistd.h>
#include <fcntl.h>

#include "partman.h"

int configure(int argc, char **argv);

//char device[PATH_MAX + 1];
size_t dev_path_len = 0;
char *dev_path = NULL;
int fd = -1;

void release(void)
{
	if (dev_path) {
		free(dev_path);
	}
}

int main(int argc, char **argv)
{
	char *c;
	
	atexit(release);
	
	if (!configure(argc, argv)) {
		return 1;
	}
	
	if (fd < 0) {
		if ((dev_path = malloc(sizeof(char) * (PATH_MAX + 1))) == NULL) {
			fprintf(stderr, "Failed to allocate buffer for device path\n");
			return 1;
		}
		printf("Enter target device name: ");
		if ((fgets(dev_path, PATH_MAX + 1, stdin)) == NULL) {
			fprintf(stderr, "Failed to read target device\n");
			return 1;
		}
		for (c = dev_path; *c != '\n' && *c != '\0'; c++) {
			dev_path_len++;
		}
		*c = '\0';
		dev_path = realloc(dev_path, sizeof(char) * (dev_path_len + 1));
		if ((fd = open(dev_path, O_RDWR | O_CREAT)) == -1) {
			fprintf(stderr, "Failed to open device file for modification\n");
			return 1;
		}
	}
	
	format(fd);
	
	close(fd);

	return 0;
}

int configure(int argc, char **argv)
{
	int c;
	while ((c = getopt(argc, argv, "hd:p:a:")) != -1) {
		switch (c) {
		case 'd':
			fd = open(optarg, O_RDWR | O_CREAT);
			break;
		case 'p':
			
			break;
		case 'h':
		case '?':
		default:
			fprintf(stderr, "Usage: %s [-h] [-d DEVICE] [-p PATH] [-a ARCH]\n",
				argv[0]);
			return 0;
		}
	}
	return 1;
}

