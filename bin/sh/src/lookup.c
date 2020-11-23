#include <stdio.h>
#include <stdlib.h>

#include "lookup.h"

int
lookup(const char *sn, union util_path *out)
{
	int done = 0;
	char *c, *p;
	char *path = getenv("PATH");

	fprintf(stderr, "%s\n", path);

	/* Check if is builtin util */
	/* if not, check if is alias */
	/* if not, check if exists in path */
	/* if not, not found */

	out->builtin = builtin_lookup(sn);
	if (out->builtin != NULL) {
		return UTIL_LOOKUP_BUILTIN;
	} else {
		p = path;
		while (*p) {
			for (c = p; *c != '\0' && *c != ':'; c++);
			if (*c == ':') {
				*c = '\0';
				c++;
			}
			/* lookup */
			printf("current path = %s\n", p);
			p = c;
		}
	}

	return UTIL_LOOKUP_NOTFOUND;
}

