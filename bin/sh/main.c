#include <stdlib.h>
#include <unistd.h>

const char *const PS1 = "$ ";
const char *const PS2 = "> ";
const char *const PS3 = "";
const char *const PS4 = "+ ";

int process(const char *buf, size_t buf_sz);

int
main(int argc, char *argv[])
{
	int escape = 0;
	size_t i = 0;
	size_t buf_sz = 50;
	char *buf = malloc(sizeof(char) * buf_sz);

	write(0, PS1, 2);

	while (read(0, &buf[i], 1) > 0) {
		//buf[i]
		if (escape) {
			switch (buf[i]) {
			case '\n':
				write(0, PS2, 2);
				break;
			}
			escape = 0;
		} else {
			switch (buf[i]) {
			case '\n':
				process(buf, i);	// Not i + 1 to ignore newline char
				write(0, PS1, 2);
				break;
			case '\\':
				escape = 1;
				break;
			}
		}

		i++;
		if (i == buf_sz) {
			buf = realloc(buf, (buf_sz += 50));
		}
	}

	return 0;
}

int process(const char *buf, size_t buf_sz)
{
	static char nl = '\n';

	for (size_t i = 0; i < buf_sz; i++) {
		write(0, &buf[i], 1);
	}
	write(0, &nl, 1);
	return 1;
}

