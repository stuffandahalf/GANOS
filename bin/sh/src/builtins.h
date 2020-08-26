#ifndef ALIX_BIN_SH_BUILTINS_H
#define ALIX_BIN_SH_BUILTINS_H	1

typedef int (*builtin_util)(int argc, char *argv[]);

builtin_util builtin_lookup(const char *util);

#endif /* ALIX_BIN_SH_BUILTINS_H */
