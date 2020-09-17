#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

#include "builtins.h"

const char *const PS1_USR = "$ ";
const char *const PS1_ROOT = "# ";

const char *PS1 = NULL;
const char *PS2 = "> ";
const char *PS3 = "";
const char *PS4 = "+ ";

int process(char *buf, size_t buf_sz);

int
main(int argc, char **argv)
{
	int escape = 0;
	size_t i = 0;
	size_t buf_sz = 50;
	char *buf = malloc(sizeof(char) * buf_sz);

	if (geteuid() == 0) {
		PS1 = PS1_ROOT;
	} else {
		PS1 = PS1_USR;
	}

	printf("%s", PS1);
	fflush(stdout);
	while (read(0, &buf[i], 1) > 0) {
		if (escape) {
			switch (buf[i]) {
			case '\n':
				printf("%s", PS2);
				fflush(stdout);
				buf[i] = '\0';
				i--;
				break;
			}
			escape = 0;
		} else {
			switch (buf[i]) {
			case '\n':
				buf[i] = '\0';
				process(buf, i + 1);	// i + 1 to include '\0'
				i = -1;
				printf("%s", PS1);
				fflush(stdout);
				break;
			case '\\':
				escape = 1;
				buf[i] = '\0';
				i--;
				break;
			}
		}

		i++;
		if (i == buf_sz) {
			buf = realloc(buf, (buf_sz += 50));
		}
	}

	free(buf);

	printf("\n");
	return 0;
}

int
process(char *buf, size_t buf_sz)
{
	printf("reached process\n");
	/*static char nl = '\n';

	for (size_t i = 0; i < buf_sz; i++) {
		write(0, &buf[i], 1);
	}
	write(0, &nl, 1);*/

	int i, j, newarg = 0, ret = 1;
	char *com = NULL;
	char **args = NULL;
	int args_sz = 3;
	int argc = 0;

	args = malloc(sizeof(char *) * args_sz);
	for (j = 0; j < args_sz; j++) {
		args[j] = NULL;
	}

	for (i = 0; i < buf_sz; i++) {
		if (com == NULL) {
			switch (buf[i]) {
			case ' ':
			case '\t':
				break;
			default:
				com = &buf[i];
				args[argc++] = com;
				break;
			}
		} else if (buf[i] == ' ' || buf[i] == '\t') {
			buf[i] = '\0';
			newarg = 1;
		} else {
			if (argc == args_sz - 1) {
				args = realloc(args, sizeof(char *) * (args_sz += 3));
				for (j = argc; j < args_sz; j++) {
					args[j] = NULL;
				}
			}
			if (newarg) {
				args[argc++] = &buf[i];
				newarg = 0;
			}
		}
		
		/*else if (args == NULL) {
			if (buf[i] != ' ' && buf[i] != '\t') {
				args = malloc(sizeof(char *) * args_sz);
			}
		} else {
			
		}*/
	}
	
	builtin_util builtin_func = builtin_lookup(com);
	
	if (builtin_func) {
		builtin_func(argc, args);
	} else {
		pid_t pid = fork();

		switch (pid) {
		case -1:
			fprintf(stderr, "Failed to execute command\n");
			ret = 0;
			break;
		case 0:
			//com = "/bin/sh";
			printf("EXECUTING %s\n", com);
			printf("PASSING ARGUMENTS\n");
			for (char **cpp = args; *cpp != NULL; cpp++) {
				printf("%s\n", *cpp);
			}
			char *test[] = { com, NULL };
			if (execv(com, args) == -1)
			//if (execv(com, test) == -1)
			{
				perror(NULL);
				exit(1);
			}
			//execv(com, args);
			//printf("%s\n", com);
			/*for (char *c = com; *c != '\0'; c++) {
				printf("%d\t%c\n", *c, *c);
			}*/
			break;
		default:
			waitpid(pid, NULL, 0);
			break;
		}
	}

	free(args);

	return ret;
}

