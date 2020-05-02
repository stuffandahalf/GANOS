#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>

const char *const PS1 = "$ ";
const char *const PS2 = "> ";
const char *const PS3 = "";
const char *const PS4 = "+ ";

int process(char *buf, size_t buf_sz);

int
main(int argc, char *argv[])
{
	int escape = 0;
	size_t i = 0;
	size_t buf_sz = 50;
	char *buf = malloc(sizeof(char) * buf_sz);

	write(0, PS1, 2);
	while (read(0, &buf[i], 1) > 0) {
		printf("loop\n");
		if (escape) {
			switch (buf[i]) {
			case '\n':
				write(0, PS2, 2);
				buf[i] = '\0';
				i--;
				break;
			}
			escape = 0;
		} else {
			switch (buf[i]) {
			case '\n':
				buf[i] = '\0';
				process(buf, i + 1);	// i + 1 to include NUL
				for (int j = 0; j < i; j++) {
					printf("%c\t%d\n", buf[j], buf[j]);
				}
				i = -1;
				write(0, PS1, 2);
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

	return 0;
}

int
process(char *buf, size_t buf_sz)
{
	write(0, "reached process\n", 16);
	/*static char nl = '\n';

	for (size_t i = 0; i < buf_sz; i++) {
		write(0, &buf[i], 1);
	}
	write(0, &nl, 1);*/

	int i, ret = 1;
	char *com = NULL;
	char *const *args = NULL;
	int args_sz = 3;
	int argc = 0;

	for (i = 0; i < buf_sz; i++) {
		if (com == NULL) {
			switch (buf[i]) {
			case ' ':
			case '\t':
				break;
			default:
				com = &buf[i];
				break;
			}
		} /*else if (buf[i] == ' ' || buf[i] == '\t') {
			buf[i] = '\0';
		} *//*else {
			if (args == NULL) {
				args = malloc(sizeof(char *) * args_sz);
			}

		}*/
		
		/*else if (args == NULL) {
			if (buf[i] != ' ' && buf[i] != '\t') {
				args = malloc(sizeof(char *) * args_sz);
			}
		} else {
			
		}*/
	}

	pid_t pid = fork();

	switch (pid) {
	case -1:
		write(2, "Failed to execute command\n", 26);
		ret = 0;
		break;
	case 0:
		//com = "/bin/sh";
		execv(com, NULL);
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

	free(args);

	return ret;
}

