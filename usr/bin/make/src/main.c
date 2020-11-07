#include <locale.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "dynarray.h"

#define XSI_CONFORMANT 1
#define streq(s1, s2) !strcmp(s1, s2)

#define CONFIG_FLAG_ENV_VARS			1
#define CONFIG_FLAG_IGNORE_ERR_CODES	2
#define CONFIG_FLAG_NO_EXEC				4
#define CONFIG_FLAG_PRINT_DEFNS			8

struct char_tree {
	char c;
	const char *value;
	struct char_tree **children;
};

const char *mf_paths[] = {
	"./makefile",
	"./Makefile"
#ifdef XSI_CONFORMANT
	,
	"./s.makefile",
	"SCSS/s.makefile",
	"./s.Makefile",
	"SCSS/s.Makefile",
	NULL
#endif	/* XSI_CONFORMANT */
};

const char *s_tgt[] = {
	".DEFAULT",
	".IGNORE",
	".POSIX",
	".PRECIOUS",
	".SCCS_GET",
	".SILENT",
	".SUFFIXES"
};

int configure(int argc, char **argv);

DYNARRAY(char *) in_makefiles;
const char *mf_name = NULL;
unsigned int flags = 0;

void
release_mem(void)
{
	int i;
	
	for (i = 0; i < in_makefiles.len; i++) {
		free(in_makefiles.array[i]);
	}
	dynarray_release(in_makefiles);
}

int
main(int argc, char **argv)
{
	int i;
	const char **mf_path;

	setlocale(LC_ALL, "");
	atexit(release_mem);
	
	dynarray_init(char *, in_makefiles);
	
	if (!configure(argc, argv)) {
		return EXIT_FAILURE;
	}

	if (in_makefiles.len == 0) {
		for (mf_path = mf_paths; *mf_path != NULL && mf_name == NULL; mf_path++) {
			printf("searching for \"%s\"\n", *mf_path);
			// test 
		}
		if (mf_name == NULL) {
			fprintf(stderr, "*** No makefile found\n");
			return EXIT_FAILURE;
		}
	} else {
		for (i = 0; i < in_makefiles.len; i++) {
			printf("searching for \'%s\"\n", in_makefiles.array[i]);
		}
	}
	
	return EXIT_SUCCESS;
}

int
configure(int argc, char **argv)
{	
	char c;
	char *s;
	size_t sz;
	
	while ((c = getopt(argc, argv, "ef:hiknpqrSst")) != -1) {
		switch (c) {
		case 'e':
			flags |= CONFIG_FLAG_ENV_VARS;
			break;
		case 'f':
			//printf("input makefile %s\n", optarg);
			sz = strlen(optarg) + 1;
			s = malloc(sizeof(char) * sz);
			if (s == NULL) {
				fprintf(stderr, "Failed to allocate string buffer\n");
				return 0;
			}
			strcpy(s, optarg);
			dynarray_append(in_makefiles, s);
			s = NULL;
			//custom_makefiles[custom_makefiles_count.
			break;
		case 'i':
			flags |= CONFIG_FLAG_IGNORE_ERR_CODES;
			break;
		case 'k':
			break;
		case 'n':
			flags |= CONFIG_FLAG_NO_EXEC;
			break;
		case 'p':
			flags |= CONFIG_FLAG_PRINT_DEFNS;
			break;
		case 'q':
			break;
		case 'r':
			break;
		case 'S':
			break;
		case 's':
			break;
		case 't':
			break;
		case 'h':
		case '?':
		default:
			fprintf(stderr, "Usage: %s [-einpqrst][-f makefile]... [ -k| -S]"
				"[macro=value]... [target_name...]\n", argv[0]);
			return 0;
		}
	}
	
	return 1;
}
