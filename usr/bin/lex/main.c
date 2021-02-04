/*
 * SPDX-License-Identifier: GPL-3.0-only
 *
 * Copyright (C) 2021 Gregory Norton <gregory.norton@me.com>
 * This program is free software: you can redistribute it and/or modify it under * the terms of the GNU General Public License as published by the Free Software
 * Foundation, version 3
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY of FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <https://www.gnu.org/licenses/>.
 */

#include <ctype.h>
#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define SECTION_DEFINITIONS	0
#define SECTION_RULES		1
#define SECTION_SUBROUTINES	2

//#define CHUNK_SIZE	64
#define CHUNK_SIZE	12

int verbose = 0;
int closeout = 1;
FILE *outf = NULL;
int infiles = -1;
int section = SECTION_DEFINITIONS;
char *fname = NULL;
size_t line = 1;
size_t col = 1;

int configure(int argc, char **argv);
int parse(FILE *fp);
int parse_definitions(FILE *fp, char *buffer);
int parse_rules(FILE *fp, char *buffer);
int parse_subroutines(FILE *fp, char *buffer);

int (*parsesec[])(FILE *fp, char *buffer) = {
	parse_definitions,
	parse_rules,
	parse_subroutines
};

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

	if (!configure(argc, argv)) {
		return 1;
	}
	if (!outf) {
		outf = fopen("lex.yy.c", "w");
	}

	if (infiles > 0) {
		int i;
		for (i = infiles; i < argc; i++) {
			if (argv[i][0] == '-' && argv[i][1] == '\0') {
				fname = "<stdin>";
				parse(stdin);
			} else {
				FILE *fp = fopen(argv[i], "r");
				if (!fp) {
					fprintf(stderr, "Failed to open file %s: ", argv[i]);
					perror(NULL);
					return 1;
				}
				fname = argv[i];
				parse(fp);
				fclose(fp);
			}
		}
	} else {
		fname = "<stdin>";
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
	char chunk[CHUNK_SIZE];
	size_t buffersz = CHUNK_SIZE;
	char *line = malloc(sizeof(char) * buffersz);
	if (!line) {
		perror("Failed to allocate line buffer");
		return 0;
	}
	while (fgets(line, buffersz, fp)) {
		char *c;
		size_t linesz = strlen(line);

		while (!strchr(line, '\n') && !feof(fp)) {
			if ((buffersz - linesz - 1) == 0) {
				buffersz += CHUNK_SIZE;
				line = realloc(line, sizeof(char) * buffersz);
			}
			char *eol;
			for (eol = line; *eol != '\0'; eol++);
			if (!fgets(eol, buffersz - linesz/* - 1*/, fp)) {
				fprintf(stderr, "Failed to read line\n");
				return 0;
			}
			linesz = strlen(line);
		}
		
		/* strip whitespace from end of line */	
		for (c = line; *c != '\0'; c++);
		for (c--; isspace(*c); c--) {
			*c = '\0';
		}
		printf("%s\n", line);


		if (!parsesec[section](fp, line)) {
			return 0;
		}
//		line++;
	}
	printf("line address is %p\n", line);
	free(line);
	/*perror(NULL);*/
	return 1;
}

int
parse_definitions(FILE *fp, char *buffer)
{
	fprintf(stderr, "parse_definitions\n");
	return 1;
}

int
parse_rules(FILE *fp, char *buffer)
{
	fprintf(stderr, "parse_rules\n");
	return 1;
}

int
parse_subroutines(FILE *fp, char *buffer)
{
	fprintf(stderr, "parse_subroutines\n");
	return 1;
}

