#include <stdio.h>
#include <stdlib.h>

#include "lookup.h"

int
lookup(const char *sn, union util_path *out)
{
	const char *path = getenv("PATH");
	fprintf(stderr, "%s\n", path);

	/* Check if is builtin util */
	/* if not, check if is alias */
	/* if not, check if exists in path */
	/* if not, not found */

	out->builtin = builtin_lookup(sn);
	if (out->builtin != NULL) {
		return UTIL_LOOKUP_BUILTIN;
	}

	return UTIL_LOOKUP_NOTFOUND;
}

