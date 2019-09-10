#include <stddef.h>
#include <stdint.h>
#include <stdarg.h>
#include <stdbool.h>

#define NORETURN __attribute__((noreturn))
#define PACKED __attribute__((packed))
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

void printc(const char *str, enum colour colour);
void print(const char *str);
int printf(const char *fmt, ...);
void NORETURN halt(void);

struct video_mode {
    uint8_t mode;
    uint8_t columns;
    uint8_t active_page;
} __attribute__((packed));

struct display {
    volatile uint8_t *buffer;
    uint16_t index;
    uint16_t width;
    uint16_t height;
} __attribute__((packed));

struct memory {
    uint64_t base;
    uint64_t length;
    uint32_t type;
    uint32_t ext_attributes;
} __attribute__((packed));

struct sys_info {
    struct video_mode vmode;
    uint8_t memory_entries;
    struct memory *memory_map;
} __attribute__((packed));

void init_screen(struct video_mode *vmode);
void print(const char *str);
void printl(long l, enum colour colour);
void NORETURN halt(void);

void clear_screen(void);

struct display screen;

void NORETURN entry32(struct sys_info *info)
{
    init_screen(&info->vmode);
    
    clear_screen();
    print("Entered protected mode.\r\n");
    //print("C pointer size is ");
    //char *size = "0 bytes\r\n";
    //size[0] += sizeof(void *);
    //print(size);
    printf("%c pointer size is %d\r\n", 'C', sizeof(void *));
    printf("%d\r\n", -12345);
    printc("This is a test\r\n", CHAR_COLOUR(COLOUR_GREEN, COLOUR_BLACK));
    halt();
}


void init_screen(struct video_mode *vmode)
{
    screen.index = 0;
    if (vmode->mode > 0x10) {
        screen.buffer = NULL;
    }
    else if (vmode->mode >= 0x0D) {
        screen.buffer = (uint8_t *)0xA0000;
    }
    else if (vmode->mode >= 0x07) {
        screen.buffer = (uint8_t *)0xB0000;
    }
    else {
        screen.buffer = (uint8_t *)0xB8000;
    }
    
    switch(vmode->mode) {
    case 0:
    case 1:
        screen.width = 40;
        screen.height = 25;
        break;
    case 2:
    case 3:
    case 7:
        screen.width = 80;
        screen.height = 25;
        break;
    case 4:
    case 5:
    case 9:
    case 0x0D:
        screen.width = 320;
        screen.height = 200;
        break;
    case 6:
    case 0x0A:
    case 0x0E:
        screen.width = 640;
        screen.height = 200;
        break;
    case 8:
        screen.width = 160;
        screen.height = 200;
        break;
    case 0x0F:
    case 0x10:
        screen.width = 640;
        screen.height = 350;
        break;
    }
    
    clear_screen();
}

void clear_screen(void)
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

void printl(long l, enum colour colour)
{
    if (l < 0) {
        putchar('-', colour);
        printl(l * -1, colour);
    }
    if (l > 0) {
        printl(l / 10, colour);
        putchar('0' + l % 10, colour);
    }
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
                    printl(darg, colour);
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
