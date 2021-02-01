#include <stdio.h>
#include <unistd.h>

int configure(int argc, char **argv);

int main(int argc, char **argv)
{
	printf("Hello World!\n");
	if (!configure(argc, argv)) {
		return 1;
	}

	return 0;
}

int configure(int argc, char **argv)
{
	int c;
	while ((c = getopt(argc, argv, "h")) != -1) {
		switch (c) {
		case 'h':
		case '?':
		default:
			fprintf(stderr, "Usage: %s [-h]\n", argv[0]);
			return 0;
		}
	}
	return 1;
}

