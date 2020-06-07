#if defined(__GNUC__) && !defined(__clang__)
#ifdef __POSIX_C_SOURCE
#undef __POSIX_C_SOURCE
#endif /* defined(__POSIX_C_SOURCE) */
#define __POSIX_C_SOURCE	2
#endif /* defined(__GNUC__) && !defined(__clang__)

#include <stdio.h>
#include <unistd.h>

int configure(int argc, char *argv[]);
void printhelp();

const char *prompt = "";
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

