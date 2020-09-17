#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <limits.h>

#define MODE_ENV	0
#define MODE_LIB	1

int
main(int argc, char **argv)
{
#ifndef PATH_MAX
	fprintf(stderr, "PATH_MAX not defined\n");
	return 1;
#else
	int c;
	int mode = MODE_ENV;

	while ((c = getopt(argc, argv, "LP")) != -1) {
		switch (c) {
		case 'L':
			mode = MODE_ENV;
			break;
		case 'P':
			mode = MODE_LIB;
			break;
		case '?':
		default:
			fprintf(stderr, "Usage: %s [-L|-P]\n", argv[0]);
			return 1;
			break;
		}
	}
	printf("%s\n", mode ? "MODE_LIB" : "MODE_ENV");
	//if (mode) {

	char buf[PATH_MAX + 1] = { 0 };
	
	realpath(".", buf);
	printf("%s\n", buf);

	return 0;
#endif
}
