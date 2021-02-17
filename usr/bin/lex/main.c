/*
 * SPDX-License-Identifier: GPL-3.0-only
 *
 * Copyright (C) 2021 Gregory Norton <gregory.norton@me.com>
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
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
#include <errno.h>
#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#define SECTION_DEFINITIONS	0
#define SECTION_RULES		1
#define SECTION_SUBROUTINES	2
#define SECTION_MAX			2

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

char *
strip_ws_trailing(char *str)
{
	char *c;
	for (c = str; *c != '\0'; c++);
	c--;
	for(; str != c && isspace(*c); c--) {
		*c = '\0';
	}
	return str;
}

char *
strip_ws_leading(char *str)
{
	char *c;
	for (c = str; *c != '\0' && isspace(*c); c++);
	return c;
	
}

char *
strip_ws(char *str)
{
	str = strip_ws_leading(str);
	str = strip_ws_trailing(str);
	return str;
}

#if _POSIX_C_SOURCE < 200809L
ssize_t
getline(char **buffer, size_t *buffer_sz, FILE *fp)
{
	char *c;
	ssize_t line_sz = 0;
	
	if (buffer == NULL || buffer_sz == NULL) {
		errno = EINVAL;
		return -1;
	}
	
	if (!*buffer || !*buffer_sz) {
		*buffer_sz = CHUNK_SIZE;
		*buffer = calloc(*buffer_sz, sizeof(char));
		if (!*buffer) {
			errno = ENOMEM;
			return -1;
		}
	}
	
	if (!fgets(*buffer, *buffer_sz, fp)) {
		return -1;
	}
	
	line_sz = strlen(*buffer);
	while (!feof(fp) && !strchr(*buffer, '\n')) {
		if (*buffer_sz - line_sz - 1 == 0) {
			*buffer_sz += CHUNK_SIZE;
			*buffer = realloc(*buffer, *buffer_sz);
			if (!*buffer) {
				errno = ENOMEM;
				return -1;
			}
		}
		for (c = *buffer; *c != '\0'; c++);
		fgets(c, *buffer_sz - line_sz, fp);
		line_sz = strlen(*buffer);
	}
	
	return line_sz;
}
#endif

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
	char *buffer = NULL;
	size_t buffer_sz = 0;
	ssize_t line_len;
	
	while ((line_len = getline(&buffer, &buffer_sz, fp)) != -1) {
		line++;
		fprintf(stderr, "%s\n", buffer);
		if (section <= SECTION_MAX && buffer[0] == '%' && buffer[1] == '%' &&
			isspace(buffer[2])) {
			section++;
		} else {
			parsesec[section](fp, buffer);
		}
	}
	free(buffer);
	if (ferror(fp)) {
		perror(NULL);
		return 0;
	}
	return 1;
}

int
parse_definitions(FILE *fp, char *buffer)
{
	fprintf(stderr, "parse_definitions\n");
	for (; *buffer != '\0' && isspace(*buffer); buffer++);
	if (*buffer == '%') {
		// command sequence
	} else {
		// macro
	}
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
	fprintf(outf, "%s", buffer);
	return 1;
}

