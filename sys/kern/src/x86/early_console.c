#include <stddef.h>
#include <stdint.h>

#include <platform/early_console.h>
#include "boot_info.h"

static uint8_t *fb_ptr = (uint8_t *)0xB8000;
static uint16_t rows = 24;
static uint16_t cols = 80;

static uint16_t row = 0;
static uint16_t col = 0;

static inline size_t
fb_index(uint16_t x, uint16_t y)
{
	return y * cols * 2 + x * 2;
}

static void
print_char(char c)
{
	size_t i;
	uint16_t x, y;

	switch (c) {
	case '\n':
		col = 0;
		row++;
		break;
	default:
		i = fb_index(col, row);
		fb_ptr[i] = c;
		fb_ptr[i + 1] = 7;
		col++;
	}

	if (col > cols) {
		row++;
		col = 0;
	}
	if (row > rows) {
		for (y = 1; y < rows; y++) {
			for (x = 0; x < cols; x++) {
				fb_ptr[fb_index(x, y - 1)] = fb_ptr[fb_index(x, y)];
				fb_ptr[fb_index(x, y - 1) + 1] = fb_ptr[fb_index(x, y) + 1];
			}
		}
	}
}

static void
print_str(const char *s)
{
	const char *c;
	uint16_t i, j;
	for (c = s; *c != '\0'; c++) {
		switch (*c) {
		default:
			print_char(*c);
			break;
		}
	}
}

#define PRINT_DEC_NUM(T, suffix) \
	void \
	print_##suffix(T d) \
	{ \
		if (d < 0) { \
			print_char('-'); \
			print_##suffix(d * -1); \
		} else if (d != 0) { \
			print_##suffix(d / 10); \
			print_char('0' + (d % 10)); \
		} \
	}

static
PRINT_DEC_NUM(int64_t, i64)

static
PRINT_DEC_NUM(uint64_t, u64)

static void
clear(void)
{
	int i;
	for (i = 0; i < rows * cols * 2; i++) {
		fb_ptr[i] = 0;
	}

	row = 0;
	col = 0;
}

void
console_init(struct console *c)
{
	c->rows = rows;
	c->cols = cols;
	c->print.c = print_char;
	c->print.s = print_str;
	c->print.i64 = print_i64;
	c->print.u64 = print_u64;
	//c->print.i64 = NULL;
	//c->print.u64 = NULL;
	c->clear = clear;
}

