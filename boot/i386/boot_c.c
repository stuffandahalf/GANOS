__asm__ (".code16\n");

void __attribute__((noinline)) tst() {
    extern char boot_str[];
    boot_str[0] = 'X';
}
