AS = nasm
CC = ~/bin/cross/bin/i686-elf-gcc
CFLAGS = -O0 -g -ffreestanding -m32 -c
LD = ld
LFLAGS = -m elf_i386 -Ttext 0x1000 --oformat binary

floppy.img: boot0.bin boot1.bin
	dd if=/dev/zero of=floppy.img bs=512 count=2880
	dd if=boot0.bin of=floppy.img seek=0 count=1 conv=notrunc
	dd if=boot1.bin of=floppy.img seek=1 count=17 conv=notrunc

%.bin: %.asm
	$(AS) -f bin -o $@ $<

%.o: %.asm
	$(AS) -f elf32 -o $@ $<

%.o: %.c
	$(CC) $(CFLAGS) -o $@ $<

#boot1.bin: boot1.o boot_c.o
#	$(LD) $(LFLAGS) -o $@ boot1.o boot_c.o

.PHONY: run
run: floppy.img
	qemu-system-i386 -s -fda $<

.PHONY: clean
clean:
	rm -f *.bin
	rm -f *.o
	rm -f floppy.img
