#include <stdio.h>
#include <unistd.h>

struct var {
	char *name;
	char *value;
};

struct rule {
	char *name;
	char **commands;
};

const char *mkfiles[] = {
	"./makefile",
	"./Makefile",
#ifdef XSI_CONFORMANT
	"./s.makefile",
	"SCCS/s.makefile",
	"./s.Makefile",
	"SCCS/s.Makefile",
#endif
	NULL
};

int configure(int argc, char **argv);

int
main(int argc, char **argv)
{
	const char **path;

	for (path = mkfiles; *path != NULL; path++) {
		fprintf(stderr, "%s\n", *path);
	}

	return 0;
}

int
configure(int argc, char **argv)
{
	char c;
	while ((c = getopt(argc, argv, "einpqrstf:kS")) != -1) {
		switch (c) {
		case 'e':
			break;
		case 'i':
			break;
		case 'n':
			break;
		case 'p':
			break;
		case 'q':
			break;
		case 'r':
			break;
		case 's':
			break;
		case 't':
			break;
		case 'f':
			break;
		case 'k':
			break;
		case 'S':
			break;
		case 'h':
		case '?':
			break;
		}
	}
}

int
parse_file(const char *fpath)
{
	
}

