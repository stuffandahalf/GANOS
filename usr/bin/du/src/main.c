#define _POSIX_C_SOURCE 200112L

#include <locale.h>
#include <stdio.h>
#include <unistd.h>

void parse_args(int argc, char **argv);

static int print_all = 1;

int
main(int argc, char **argv)
{
	setlocale(LC_ALL, "");

	parse_args(argc, argv);

	return 0;
}

void
parse_args(int argc, char **argv)
{
	char c;

	while ((c = getopt(argc, argv, "askxHL")) != -1) {
		switch (c) {
		case 'a':
			break;
		case 's':
			print_all = 0;
			break;
		case 'k':
			break;
		case 'x':
			break;
		case 'H':
			break;
		case 'L':
			break;
		case '?':
		default:
			fprintf(stderr, "Unrecognized option: -%c\n", optopt);
		}
	}
}

