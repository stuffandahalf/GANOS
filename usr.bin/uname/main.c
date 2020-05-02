#include <stdio.h>
#include <unistd.h>
#include <sys/utsname.h>

#define UNAME_FLAG_MACHINE	(1 << 0)
#define UNAME_FLAG_NODE		(1 << 1)
#define UNAME_FLAG_RELEASE	(1 << 2)
#define UNAME_FLAG_SYSNAME	(1 << 3)
#define UNAME_FLAG_VERSION	(1 << 4)
#define UNAME_FLAG_ALL		((1 << 5) - 1)

struct field {
	int flag;
	char (*value)[];
};

int
main(int argc, char **argv)
{
	int c;
	int flags = 0;
	struct utsname d;
	struct field *f;
	struct field fields[] = {
		{ UNAME_FLAG_SYSNAME,	&d.sysname },
		{ UNAME_FLAG_NODE,		&d.nodename },
		{ UNAME_FLAG_RELEASE,	&d.release },
		{ UNAME_FLAG_VERSION,	&d.version },
		{ UNAME_FLAG_MACHINE,	&d.machine },
		{ 0, NULL }
	};

	while ((c = getopt(argc, argv, ":amnrsv")) != -1) {
		switch (c) {
		case 'a':
			flags |= UNAME_FLAG_ALL;
			break;
		case 'm':
			flags |= UNAME_FLAG_MACHINE;
			break;
		case 'n':
			flags |= UNAME_FLAG_NODE;
			break;
		case 'r':
			flags |= UNAME_FLAG_RELEASE;
			break;
		case 's':
			flags |= UNAME_FLAG_SYSNAME;
			break;
		case 'v':
			flags |= UNAME_FLAG_VERSION;
			break;
		case '?':
			fprintf(stderr, "Unrecognized option: '-%c'\n", optopt);
			break;
		}	
	}

	uname(&d);

	if (!flags) {
		printf("%s\n", d.sysname);
	} else {
		for (f = fields; f->flag != 0; f++) {
			if (flags & f->flag) {
				printf("%s", *f->value);
				flags &= ~f->flag;
				if (flags) {
					printf(" ");
				}
			}
		}
		printf("\n");
	}

	return 0;
}
