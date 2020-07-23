#ifndef ALIX_BIN_SH_LOOKUP_H
#define ALIX_BIN_SH_LOOKUP_H	1

#include "builtins.h"

#define UTIL_LOOKUP_NOTFOUND	0
#define UTIL_LOOKUP_BUILTIN		1
#define UTIL_LOOKUP_ALIAS		2
#define UTIL_LOOKUP_PATH		3

union util_path {
	const char *path;
	builtin_util builtin;
};

int lookup(const char *sn, union util_path *out);

#endif

