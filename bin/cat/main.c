#include <errno.h>
#include <locale.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

void cat_file(FILE *fp);

int
main(int argc, char *argv[])
{
	int i, skip_nl = 0, rval = 0;
	char c;
	FILE *fp;

	setlocale(LC_ALL, "");

	while ((c = getopt(argc, argv, "uh")) != -1) {
		switch (c) {
		case 'u':
			setvbuf(stdout, NULL, _IONBF, 0);
			break;
		case 'h':
		case '?':
		default:
			fprintf(stderr, "usage: %s [-u] [-h] [files...]\n", argv[0]);
			return 1;
		}
	}

	if (optind == argc) {
		cat_file(stdin);
	} else {
		for (i = optind; i < argc; i++) {
			skip_nl = 0;
			if (!strcmp("-", argv[i])) {
				fp = stdin;
			} else {
				fp = fopen(argv[i], "r");
			}
			if (fp == NULL) {
				fprintf(stderr, "%s: %s: %s\n", argv[0], argv[i],
					strerror(errno));
				skip_nl = 1;
				rval = 1;
				continue;
			}
			
			cat_file(fp);
		}
	}

	return rval;
}

void
cat_file(FILE *fp)
{
	char c;
	while (fread(&c, sizeof(char), 1, fp) > 0) {
		printf("%c", c);
	}
}
