__asm__(".code16");

#include <stdint.h>

void print(const char *str);

/*void outb(uint8_t port, uint8_t data) {
    __asm__(
        "outb %%al, %%dl\n"
        :
        : "a"(data), "d"(port)
        :
    );
}

void inb(uint8_t port) {
    
}*/

void _start() {
    print("Hello World\r\n");
    print("This is coming from C!!!!!\r\n");
    
    
    
    __asm__(
        "cli\n"
        "hlt\n"
    );
}

void print(const char *str) {
    __asm__(
        "mov %%eax, %%esi\n"
        "movb $0x0E, %%ah\n"
        "0:\n"
        "lodsb\n"
        "testb %%al, %%al\n"
        "je 1f\n"
        "int $0x10\n"
        "jmp 0b\n"
        "1:\n"
        : 
        : "a"(str)
        : "si"
    );
}
