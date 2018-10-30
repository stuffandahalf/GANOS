struct vga_char {
    unsigned char c;
    unsigned char colour;
} __attribute ((packed));

void put_char(char c);
void write_string(const char *str);

volatile unsigned char *video_buffer = (volatile unsigned char *)0xB8000;


void p_main() {
    *((int*)0xb8000)=0x07690748;
    //write_string("Hello protected world");
}

void write_string(const char *str) {
    while (*str != '\0') {
        *video_buffer++ = *str++;
        *video_buffer++ = 0x07;
    }
}
