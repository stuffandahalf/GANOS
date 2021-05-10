#ifndef DEFS_H
#define DEFS_H

#define LINE_LENGTH 200

struct macro {
	char *name;
	char *value;
	struct macro *next;
};

struct str {
	char *value;
	struct str *next;
};

//extern const char *mkfiles[];

#endif //DEFS_H
