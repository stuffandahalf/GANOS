#ifndef ALIX_KERNEL_PLATFORM_EARLY_CONSOLE_H
#define ALIX_KERNEL_PLATFORM_EARLY_CONSOLE_H	1

#include <stdint.h>

//void early_console_clear(void);
//void early_console_init(void);
//void early_console_print(const char *i);


struct console {
	uint16_t rows;
	uint16_t cols;
	struct {
		void (*c)(char);
		void (*s)(const char *);
		void (*i64)(int64_t);
		void (*u64)(uint64_t);
	} print;
	void (*clear)(void);
};

void console_init(struct console *c);

#endif

