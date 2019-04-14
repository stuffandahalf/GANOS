__asm__(".code16");

#include <stddef.h>
#include <stdint.h>

#define NORETURN __attribute__((noreturn))

void print(const char *str);
void halt();

void NORETURN entry() {
    //print("This is coming from C!!!!!\r\n");
    print("C pointer size is ");
    char *size = "0\r\n";
    size[0] += sizeof(void *);
    print(size);
    halt();
}

void print(const char *str) {
    __asm__(
        "movl %%eax, %%esi\n"
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
