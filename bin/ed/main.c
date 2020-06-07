#if defined(__GNUC__) && !defined(__clang__)
#ifdef _POSIX_C_SOURCE
#undef _POSIX_C_SOURCE
#endif /* defined(__POSIX_C_SOURCE) */
#define _POSIX_C_SOURCE	2
#endif /* defined(__GNUC__) && !defined(__clang__) */

#include <stdio.h>
#include <unistd.h>

#define BUFFER_SIZE			15
#define LINE_BUFFER_SIZE	50

int configure(int argc, char *argv[]);
void printhelp(void);

const char *prompt = NULL;
size_t address = 0;;
char **buffer = NULL;

int
main(int argc, char *argv[])
{
	printf("%s\n", argv[0]);
	configure(argc, argv);

	return 0;
}

/* Configures the utility */
int
configure(int argc, char *argv[])
{
	int c;
	while ((c = getopt(argc, argv, "hsp:")) != -1) {
		switch (c) {
		case 's':
			break;
		case 'p':
			break;
		case 'h':
		default:
			printhelp();
			break;
		}
	}
	return 1;
}

/* Prints the help command and exits */
void
printhelp(void)
{

}

