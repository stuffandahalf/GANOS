//__asm__(".code16");

#include <stddef.h>
#include <stdint.h>
#include <stdarg.h>
#include <stdbool.h>

#define NORETURN __attribute__((noreturn))
#define FLAG(f) ((unsigned int)(f))

enum colour {
    COLOUR_BLACK,
    COLOUR_BLUE,
    COLOUR_GREEN,
    COLOUR_CYAN,
    COLOUR_RED,
    COLOUR_PURPLE,
    COLOUR_BROWN,
    COLOUR_GREY,
    COLOUR_DARK_GREY,
    COLOUR_LIGHT_BLUE,
    COLOUR_LIGHT_GREEN,
    COLOUR_LIGHT_CYAN,
    COLOUR_LIGHT_RED,
    COLOUR_LIGHT_PURPLE,
    COLOUR_YELLOW,
    COLOUR_WHITE
};

#define CHAR_COLOUR(bg, fg) ((FLAG(bg) << 4) | FLAG(fg))

bool x = true;
void printc(const char *str, enum colour colour);
void print(const char *str);
int printf(const char *fmt, ...);
void NORETURN halt();

void clear_screen();

void NORETURN entry32()
{
    clear_screen();
    print("Entered protected mode.\r\n");
    //print("C pointer size is ");
    //char *size = "0 bytes\r\n";
    //size[0] += sizeof(void *);
    //print(size);
    printf("%c pointer size is %d\r\n", 'C', sizeof(void *));
    printc("This is a test\r\n", CHAR_COLOUR(COLOUR_GREEN, COLOUR_BLACK));
    halt();
}

struct display {
    volatile uint8_t *buffer;
    uint16_t index;
    uint16_t width;
    uint16_t height;
};

struct display screen = { .buffer = (uint8_t *)0xB8000, .index = 0, .width = 80, .height = 25 };

void clear_screen()
{
    for (screen.index = 0; screen.index < (screen.width * screen.height * 2); screen.index++) {
        screen.buffer[screen.index] = 0;
    }
    screen.index = 0;
}

void putchar(char c, enum colour colour)
{
    screen.buffer[screen.index++] = c;
    screen.buffer[screen.index++] = (uint8_t)colour;
    if (screen.index == (screen.width * screen.height) << 1) {
        screen.index = 0;
    }
}

void printc(const char *str, enum colour colour)
{
    int i;
    const char *c;
    for (c = str; *c != '\0'; c++) {
        switch (*c) {
            case '\t':
                for (i = 0; i < 4; i++) {
                    putchar(0, colour);
                }
                break;
            case '\r':
                screen.index -= (screen.index % (screen.width * 2));
                break;
            case '\n':
                screen.index += (screen.width << 1);
                break;
            default:
                putchar(*c, colour);
        }
    }
}

inline void print(const char *str)
{
    printc(str, CHAR_COLOUR(COLOUR_BLACK, COLOUR_GREY));
}


int printf(const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);

    enum colour colour = CHAR_COLOUR(COLOUR_BLACK, COLOUR_GREY);

    bool escape = false;
    bool fmt_specifier = false;
    int darg;
    const char *c;
    for (c = fmt; *c; c++) {
        switch (*c) {
        case '\r':
            screen.index -= (screen.index % (screen.width * 2));
            break;
        case '\n':
            screen.index += (screen.width << 1);
            break;
        case '\t':
            for (int i = 0; i < 4; i++) {
                putchar(0, colour);
            }
            break;
        case '\\':
            escape = true;
            break;
        case '%':
            fmt_specifier = true;
            break;
        default:
            if (fmt_specifier) {
                switch (*c) {
                case 'd':
                    darg = va_arg(args, int);
                    do {
                        putchar('0' + darg % 10, colour);
                        darg /= 10;
                    } while (darg != 0);
                    fmt_specifier = false;
                    break;
                case 'u':
                    break;
                case 'f':
                    break;
                case 'c':
                    putchar((char)va_arg(args, int), colour);
                    fmt_specifier = false;
                    break;
                }
            }
            else {
                putchar(*c, colour);
            }
            break;
        }
    }
    va_end(args);

    return 0;
}