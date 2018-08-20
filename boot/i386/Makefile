AS = nasm

floppy.img: boot.bin
	dd if=/dev/zero of=floppy.img bs=1024 count=1440
	dd if=boot.bin of=floppy.img seek=0 count=1 conv=notrunc

boot.bin: boot.asm
	$(AS) -f bin -o $@ $<

.PHONY: test
test: floppy.img
	qemu-system-i386 -fda $<

.PHONY: clean
clean:
	rm -f boot.bin
	rm -f floppy.img
