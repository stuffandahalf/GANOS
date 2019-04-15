//__asm__(".code16");

#include <stddef.h>
#include <stdint.h>

#define NORETURN __attribute__((noreturn))

void print(const char *str);
void NORETURN halt();

void clear_screen();

void NORETURN entry32() {
    clear_screen();
    //print("Entered protected mode.\r\n");
    print("C pointer size is ");
    char *size = "0 bytes\r\n";
    size[0] += sizeof(void *);
    print(size);
    halt();
}

struct display {
    volatile uint8_t *buffer;
    uint16_t index;
    uint16_t width;
    uint16_t height;
};

struct display screen = { .buffer = (uint8_t *)0xB8000, .index = 0, .width = 80, .height = 25 };

void clear_screen() {
    for (screen.index = 0; screen.index < (screen.width * screen.height * 2); screen.index++) {
        screen.buffer[screen.index] = 0;
    }
    screen.index = 0;
}

void putchar(char c, uint8_t colour) {
    screen.buffer[screen.index++] = c;
    screen.buffer[screen.index++] = colour;
    if (screen.index == (screen.width * screen.height) << 1) {
        screen.index = 0;
    }
}

void print(const char *str) {
    int i;
    const char *c;
    for (c = str; *c != '\0'; c++) {
        switch (*c) {
        case '\t':
            for (i = 0; i < 4; i++) {
                putchar(0, 0);
            }
            break;
        case '\r':
            screen.index -= (screen.index % (screen.width * 2));
            break;
        case '\n':
            screen.index += (screen.width << 1);
            break;
        default:
            putchar(*c, 7);
        }
    }
}
