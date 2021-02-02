#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int verbose = 0;
int closeout = 1;
FILE *outf = NULL;
int infiles = -1;

int configure(int argc, char **argv);
int parse(FILE *fp);

void release(void)
{
	if (closeout) {
		fclose(outf);
	}
}

int
main(int argc, char **argv)
{
	setlocale(LC_ALL, "");
	atexit(release);

	if (!configure(argc, argv))
		return 1;
	if (!outf) {
		outf = fopen("lex.yy.c", "w");
	}

	if (infnames) {
		int i;
		for (i = infiles; i < argv; i++) {
			if (!strcmp("-", argv[i])) {
				fp = stdin;
			} else {
				FILE *fp = fopen(argv[i], "r");
				if (!fp) {
					fprintf(stderr, "Failed to open file %s\n", *fname);
					return 1;
				}
			}
			parse(fp);
			fclose(fp);
		}
	} else {
		parse(stdin);
	}

	return 0;
}

int
configure(int argc, char **argv)
{
	int c, i, j;

	while ((c = getopt(argc, argv, "htnv")) != -1) {
		switch (c) {
		case 't':
			outf = stdout;
			closeout = 0;
			break;
		case 'n':
			verbose = 0;
			break;
		case 'v':
			verbose = 1;
			break;
		case 'h':
		case '?':
		default:
			fprintf(stderr, "Usage: %s [-h] [-t] [-n|-v] [file ...]\n",
				argv[0]);
			return 0;
		}
	}

	if (argc - optind) {
		infiles = optind;
	}

	return 1;
}

int
parse(FILE *fp)
{
	return 1;
}

