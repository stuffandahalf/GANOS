#include <stdio.h>
#include <unistd.h>
#include <sys/utsname.h>

#define MFLAG	(1 << 0)
#define NFLAG	(1 << 1)
#define RFLAG	(1 << 2)
#define SFLAG	(1 << 3)
#define VFLAG	(1 << 4)

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
		{ SFLAG,	&d.sysname },
		{ NFLAG,	&d.nodename },
		{ RFLAG,	&d.release },
		{ VFLAG,	&d.version },
		{ MFLAG,	&d.machine },
		{ 0, NULL }
	};

	while ((c = getopt(argc, argv, ":amnrsv")) != -1) {
		switch (c) {
		case 'a':
			flags |= (MFLAG | NFLAG | RFLAG | SFLAG | VFLAG);
			break;
		case 'm':
			flags |= MFLAG;
			break;
		case 'n':
			flags |= NFLAG;
			break;
		case 'r':
			flags |= RFLAG;
			break;
		case 's':
			flags |= SFLAG;
			break;
		case 'v':
			flags |= VFLAG;
			break;
		case '?':
			fprintf(stderr, "Unrecognized option: '-%c'\n", c);
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

