#if defined(__GNUC__) && !defined(__clang__)
#define _POSIX_C_SOURCE 2
#endif

#include <string.h>
#ifdef _WIN32
#include <direct.h>
#define _chdir chdir
#else
#include <unistd.h>
#endif /* defined(_WIN32) */
#include "builtins.h"

/* This is a naive implementation. */
/* Should reimplement as trie-type structure */
struct lookup_entry {
	const char		*util;
	builtin_util	function;
};

static struct lookup_entry
lookup[] = {
	{ "cd",		cd },
	{ "exit",	shexit },
	{ 0 }
};

builtin_util
builtin_lookup(const char *util)
{
	struct lookup_entry *entry;
	
	for (entry = lookup; entry->util != NULL; entry++) {
		if (!strcmp(util, entry->util)) {
			return entry->function;
		}
	}
	return NULL;
}

int
cd(int argc, char *argv[])
{
	int c;
	
	write(0, "cd called\n", 10);
	
	optind = 1;
	while ((c = getopt(argc, argv, "LP")) != -1) {
		printf("%c\n", c);
	}
	return 0;
}

int
shexit(int argc, char *argv[])
{
	write(0, "exit called\n", 12);
	return 1;
}

