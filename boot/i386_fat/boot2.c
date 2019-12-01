#include <stddef.h>
#include <stdint.h>
#include <stdarg.h>
#include <stdbool.h>

#include "video.h"
#include "smbios.h"

//#define PROTECTED_PRINT

#define NORETURN __attribute__((noreturn))
#define PACKED __attribute__((packed))
#define FLAG(f) ((unsigned int)(f))

enum memory_type {
    MEMORY_TYPE_FREE = 1,
    MEMORY_TYPE_RESERVED = 2
};

struct memory {
    uint64_t base;
    uint64_t length;
    enum memory_type type;
    uint32_t ext_attributes;
} __attribute__((packed));

struct sys_info {
    struct video_mode vmode;
    uint8_t memory_entries;
    struct memory *memory_map;
} __attribute__((packed));

void init_screen(struct video_mode *vmode);
void clear_screen(void);
void printc(const char *str, enum colour colour);
void print(const char *str);
int printf(const char *fmt, ...);
void printl(long l, enum colour colour, bool recurse);

void NORETURN halt(void);

struct display screen;

extern struct {
    uint8_t count;
    struct memory *entries;
} memory_map;

void NORETURN entry32(struct sys_info *info)
{
#if 1
    init_screen(&info->vmode);
    
    clear_screen();
    print("Entered protected mode.\r\n");
    //print("C pointer size is ");
    //char *size = "0 bytes\r\n";
    //size[0] += sizeof(void *);
    //print(size);
    //printf("%c pointer size is %d\r\n", 'C', sizeof(void *));
    printf("%d\r\n", -12345);
    //printc("This is a test\r\n", CHAR_COLOUR(COLOUR_GREEN, COLOUR_BLACK));
    //printf("this should be zero  <%d>\r\n", 0);
    /*printf("memory count: %d\r\n", info->memory_entries);
    printf("test\r\n");
    int i;
    for (i = 0; i < info->memory_entries; i++) {
        printf("%u\t%u\t%u\r\n", info->memory_map[i].base, info->memory_map[i].length, info->memory_map[i].type);
    }*/
#endif

    printf("test hex 0x55: 0x%x\r\n", 0x55);
    printf("test hex 0xaa: 0x%x\r\n", 0xAA);
    printf("test hex 0xAA: 0x%X\r\n", 0xAA);
    //printf("%p\r\n", &memory_map);

    struct smbios2_entry_point *smbios_entry = locate_smbios_entry();
    printf("smbios is at address %d\r\n", (uint32_t)smbios_entry);
    printf("smbios version is %d.%d\r\n", smbios_entry->major_version, smbios_entry->minor_version);
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

struct smbios2_entry_point *locate_smbios_entry(void)
{
    uint8_t *mem = (uint8_t *)0xF0000;
    int length;
    int i;
    
    uint8_t checksum;
    while ((uint32_t)mem < 0x100000) {
        if (mem[0] == '_' && mem[1] == 'S' && mem[2] == 'M' && mem[3] == '_') {
            length = mem[5];
            checksum = 0;
            for (i = 0; i < length; i++) {
                checksum += mem[i];
            }
            if (checksum == 0) {
                return (struct smbios2_entry_point *)mem;
            }
        }
        mem += 16;
    }
    
    return NULL;
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

void printul(unsigned long ul, enum colour colour, bool recurse)
{
    if (ul > 0) {
        printl(ul / 10, colour, true);
        putchar('0' + ul % 10, colour);
    }
    else if (ul == 0 && !recurse) {
        putchar('0', colour);
    }
}

void printl(long l, enum colour colour, bool recurse)
{
    if (l < 0) {
        putchar('-', colour);
        printl(l * -1, colour, true);
    }
    if (l > 0) {
        printl(l / 10, colour, true);
        putchar('0' + l % 10, colour);
    }
    if (l == 0 && !recurse) {
        putchar('0', colour);
    }
}

void printx(unsigned long x, enum colour colour, bool recurse, bool uppercase)
{
    if (x > 0) {
        printx(x / 16, colour, true, uppercase);
        unsigned char d = x % 16;
        if (d < 10) {
            putchar('0' + d, colour);
        }
        else if (uppercase) {
            putchar('A' + d - 10, colour);
        }
        else {
            putchar('a' + d - 10, colour);
        }
    }
    else if (x == 0 && !recurse) {
        putchar('0', colour);
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
    unsigned int uarg;
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
                    printl(darg, colour, false);
                    fmt_specifier = false;
                    break;
                case 'u':
                    uarg = va_arg(args, unsigned int);
                    printul(uarg, colour, false);
                    fmt_specifier = false;
                    break;
                case 'f':
                    break;
                case 'c':
                    putchar((char)va_arg(args, int), colour);
                    fmt_specifier = false;
                    break;
                case 'p':
                case 'X':
                    darg = va_arg(args, unsigned int);
                    printx(darg, colour, false, true);
                    break;
                case 'x':
                    darg = va_arg(args, unsigned int);
                    printx(darg, colour, false, false);
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
