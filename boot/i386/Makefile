AS = nasm

floppy.img: boot0.bin boot1.bin
	dd if=/dev/zero of=floppy.img bs=1024 count=1440
	dd if=boot0.bin of=floppy.img seek=0 count=1 conv=notrunc
	dd if=boot1.bin of=floppy.img seek=1 count=17 conv=notrunc

%.bin: %.asm
	$(AS) -f bin -o $@ $<

.PHONY: run
run: floppy.img
	qemu-system-i386 -fda $<

.PHONY: clean
clean:
	rm -f *.bin
	rm -f floppy.img
