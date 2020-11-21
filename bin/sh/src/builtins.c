#if defined(__GNUC__) && !defined(__clang__)
#define _POSIX_C_SOURCE 2
#endif

#include <stdio.h>
#include <string.h>
#ifdef _WIN32
#include <direct.h>
#define _chdir chdir
#else
#include <unistd.h>
#endif /* defined(_WIN32) */

#include "builtins.h"
#include "lookup.h"

/* Builtin operations */
static int builtin_cd(int, char **);
static int builtin_exit(int, char **);
static int builtin_set(int, char **);
static int builtin_which(int, char **);

/* This is a naive implementation. */
/* Should reimplement as trie-type structure */
struct lookup_entry {
	const char		*util;
	builtin_util	function;
};

#define BUILTIN_UTIL(u) { #u, builtin_##u }
static struct lookup_entry
lookup_table[] = {
	BUILTIN_UTIL(cd),
	BUILTIN_UTIL(exit),
	BUILTIN_UTIL(set),
	BUILTIN_UTIL(which),
	{ 0 }
};
#undef BUILTIN_UTIL

struct trie_node {
	int i;
	char c;
	struct trie_node *children;
};

builtin_util
builtin_lookup(const char *util)
{
	struct lookup_entry *entry;
	
	for (entry = lookup_table; entry->util != NULL; entry++) {
		if (!strcmp(util, entry->util)) {
			return entry->function;
		}
	}
	return NULL;
}

static int
builtin_cd(int argc, char **argv)
{
	int c;
	
	write(0, "cd called\n", 10);
	
	optind = 1;
	while ((c = getopt(argc, argv, "LP")) != -1) {
		write(0, &c, 1);
	}
	return 0;
}

static int
builtin_exit(int argc, char **argv)
{
	write(0, "exit called\n", 12);
	return 1;
}

static int
builtin_set(int argc, char **argv)
{
	extern char **environ;
	char **sp;

	if (argc == 1) {
		for (sp = environ; *sp != NULL; sp++) {
			printf("%s\n", *sp);
		}
		return 0;
	}
	return 0;
}


static int
builtin_which(int argc, char **argv)
{
	union util_path util;
	const char *short_name = argv[1];

	int type = lookup(short_name, &util);
	switch (type) {
	case UTIL_LOOKUP_BUILTIN:
		printf("%s: shell built-in command\n", short_name);
		break;
	case UTIL_LOOKUP_ALIAS:
		break;
	case UTIL_LOOKUP_PATH:
		break;
	case UTIL_LOOKUP_NOTFOUND:
		break;
	}
	
	return 0;
}

