#include <string.h>
#include <unistd.h>
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
	write(0, "cd called\n", 10);
	return 0;
}

int
shexit(int argc, char *argv[])
{
	write(0, "exit called\n", 12);
	return 1;
}

