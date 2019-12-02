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

#define REBUILD64_2_32(a, b) ((a << 32) + b)
#define REBUILD64_F(field) REBUILD64_2_32(field##_h, field##_l)

enum memory_type {
    MEMORY_TYPE_FREE = 1,
    MEMORY_TYPE_RESERVED = 2
};

struct smap_entry {
    uint32_t base_l;
    uint32_t base_h;
    uint32_t length_l;
    uint32_t length_h;
    uint32_t type;
    uint32_t acpi;
} PACKED;

struct sys_info {
    struct video_mode vmode;
    struct {
        uint16_t count;
        struct smap_entry entries[16];
    } PACKED memory;
} __attribute__((packed));

void init_screen(struct video_mode *vmode);
void clear_screen(void);
int printf(const char *fmt, ...);

void NORETURN halt(void);

struct display screen;

/*extern struct {
    uint16_t count;
    struct smap_entry entries[16];
} __attribute__((packed)) memory_map;*/

extern struct sys_info system;

void NORETURN entry32(/*struct sys_info *info*/void)
{
    init_screen(&system.vmode);
    
    clear_screen();
    printf("Entered protected mode.\r\n");
    printf("SMAP entries: %d\r\n", system.memory.count);
    size_t available_mem = 0;
    size_t mem_size = 0;
    size_t reclaimable_mem = 0;
    int i;
    for (i = 0; i < system.memory.count; i++) {
        printf("[base: %u, length: %u]\ttype: %u\text_flags: %u\r\n", REBUILD64_F(system.memory.entries[i].base), REBUILD64_F(system.memory.entries[i].length),
            system.memory.entries[i].type, system.memory.entries[i].acpi);
            
        mem_size += REBUILD64_F(system.memory.entries[i].length);
    }
    printf("Total system memory: %u bytes\r\n", mem_size);
    

    struct smbios2_entry_point *smbios_entry = locate_smbios_entry();
    printf("smbios is at address 0x%p\r\n", smbios_entry);
    printf("smbios version is %d.%d\r\n", smbios_entry->major_version, smbios_entry->minor_version);
    
    //printf("argument mmap entries is at %p\r\n", &info->memory_map);
    //printf("real mmap entries is at %p\r\n", &memory_map.entries);
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

#if 0
inline void print(const char *str)
{
    printc(str, CHAR_COLOUR(COLOUR_BLACK, COLOUR_GREY));
}
#endif

#define print_fmt(fmt, T) \
void print##fmt(T t, enum colour colour, bool recurse) \
{ \
    if (t < 0) { \
        putchar('-', colour); \
        print##fmt(t * -1, colour, true); \
    } \
    else if (t > 0) { \
        print##fmt(t / 10, colour, true); \
        putchar('0' + t % 10, colour); \
    } \
    else if (t == 0 && !recurse) { \
        putchar('0', colour); \
    } \
}

print_fmt(ul, unsigned long)
print_fmt(l, long)

#undef print_fmt

#if 0
void printul(unsigned long ul, enum colour colour, bool recurse)
{
    if (ul > 0) {
        printul(ul / 10, colour, true);
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
#endif

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
