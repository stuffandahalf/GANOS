#include <stddef.h>
#include <stdint.h>

#define NORETURN __attribute__((noreturn))

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
void printl(long l);
void NORETURN halt();

void clear_screen();

struct display screen;

//void NORETURN entry32(struct video_mode *vmode) {
void NORETURN entry32(struct sys_info *info) {
    init_screen(&info->vmode);
    print("Entered protected mode.\r\n");
    printl(info->memory_entries);
    halt();
}

void init_screen(struct video_mode *vmode) {
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

/*int printf(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    
    uint8_t percent = 0;
    uint8_t l = 0;
    
    const char *c;
    for (c = fmt; *c != '\0'; c++) {
        if (percent) {
            switch (*c) {
            case 'l':
                l = true;
                break;
            case 'd':
                
            }
            
            
            if (*c == 'l') {
                l = true;
            }
            else {
                percent = 0;
            }
        }
        else {
            if (*c == '%') {
                percent = 1;
            }
            else {
                putchar(*c, 0x07);
            }
        }
    }
    
    va_end(args);
}*/

void printl(long l) {
    if (!l) {
        putchar('0', 0x07);
    }
    else {
        int places = 1;
        while ((l / places) != 0) places *= 10;
        
        while (places > 1) {
            places /= 10;
            putchar('0' + (l / places), 0x07);
            l -= l / places * places;
        }
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
