#include <stdio.h>
#include <unistd.h>

int configure(int argc, char **argv);

int main(int argc, char **argv)
{
	if (configure(argc, argv)) {
		return 1;
	}

	printf("Hello World!\n");
	return 0;
}

void copyright(char *name);
void usage(char *name);

int configure(int argc, char **argv)
{
	int c;

	while ((c = getopt(argc, argv, "hct:s:")) != -1) {
		switch (c) {
		case 's':
			/* script mode */
			break;
		case 't':
			/* image type */
			break;
		case 'c':
			/* copyright */
			copyright(argv[0]);
			break;
		case 'h':
		default:
			/* help */
			usage(argv[0]);
			return 1;
		}
	}

	return 0;
}

void copyright(char *name)
{
	printf("%s 1.0.0\n", name);
	printf("Copyright (C) 2021 Gregory Norton <gregory.norton@me.com>\n");
	printf("This is free software; see the source for copying conditions."
		" There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR"
		" A PARTICULAR PURPOSE.\n");
}

void usage(char *name)
{
	fprintf(stderr, "Usage: %s [options] output\n", name);
	fprintf(stderr, "Options:\n");
}

