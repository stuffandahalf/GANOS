#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <locale.h>

#include "defs.h"

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
int parse_file(FILE *fp);

struct str *paths = NULL;
struct str *targets = NULL;

void
cleanup(void)
{
	struct str *s = paths;
	while (s) {
		struct str *next = s->next;
		free(s->value);
		free(s);
		s = next;
	}
}

int
main(int argc, char **argv)
{
	const char **path;
	struct str *s;
	FILE *fp = NULL;

	setlocale(LC_ALL, "");
	atexit(cleanup);

	if (configure(argc, argv)) {
		return 1;
	}

	for (path = mkfiles; !paths && *path != NULL; path++) {
		if (access(*path, F_OK)) {
			continue;
		}
		struct str *p = malloc(sizeof(struct str));
		if (!p) {
			fprintf(stderr, "ERROR: Failed to allocate path buffer\n");
			return 1;
		}
		p->value = strdup(*path);
		if (!p->value) {
			fprintf(stderr, "ERROR: Failed to duplicate file path\n");
			free(p);
			return 1;
		}
		paths = p;
	}

	if (!paths) {
		fprintf(stderr, "ERROR: No makefiles found\n");
		return 1;
	}

	for (s = paths; s != NULL; s = s->next) {
		printf("%s\n", s->value);
		fp = fopen(s->value, "r");
		if (!fp) {
			fprintf(stderr, "ERROR: Failed to open file \"%s\"\n", s->value);
			return 1;
		}

		parse_file(fp);
		fclose(fp);
	}

	return 0;
}

int
configure(int argc, char **argv)
{
	struct str *pend = paths;
	struct str *p = NULL;

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
			p = malloc(sizeof(struct str));
			if (!p) {
				fprintf(stderr, "ERROR: Failed to allocate path buffer\n");
				return 1;
			}
			p->value = malloc(sizeof(char) * (strlen(optarg) + 1));
			if (!p->value) {
				fprintf(stderr, "ERROR: Failed to allocate path buffer\n");
				free(p);
				return 1;
			}
			strcpy(p->value, optarg);
			p->next = NULL;

			if (pend) {
				pend->next = p;
			}
			if (!paths) {
				paths = p;
			}
			pend = p;

			break;
		case 'k':
			break;
		case 'S':
			break;
		case 'h':
		case '?':
			fprintf(stderr, "Usage: %s [-einpqrst] [-f makefile]... [-k|-S] "
				"[macro=value...] [target_name...]\n", argv[0]);
			return 1;
			break;
		}
	}
	
	return 0;
}

int
parse_file(FILE *fp)
{
	int c;
	size_t bufsz = LINE_LENGTH;
	size_t bufln = 0;
	char *buf = malloc(sizeof(char) * bufsz);
	if (!buf) {
		fprintf(stderr, "ERROR: Failed to allocate line buffer\n");
		return 1;
	}
	
	while ((c = fgetc(fp)) != EOF) {
		printf("%c", c);
	}
	
	return 0;
}

int
evaluate_rules(void)
{
	return 0;
}
