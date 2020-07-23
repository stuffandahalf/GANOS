#ifndef ALIX_BIN_SH_BUILTINS_H
#define ALIX_BIN_SH_BUILTINS_H

typedef int (*builtin_util)(int argc, char *argv[]);

builtin_util builtin_lookup(const char *util);

int cd(int argc, char *argv[]);
int shexit(int argc, char *argv[]);
int which(int argc, char *argv[]);

#endif
