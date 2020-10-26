#include <locale.h>
#include <stdio.h>

int
main(int argc, char **argv)
{
	setlocale(LC_ALL, "");

	printf("\033[H\033[J");
	return 0;
}

