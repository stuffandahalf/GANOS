AS=nasm
SECTOR_SIZE=512

%.bin: %.asm
	$(AS) -f bin -o $@ $<

boot.img: boot0.bin gpt_header.bin
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=1024
	dd if=boot0.bin of=$@ seek=0 count=1 conv=notrunc
	dd if=gpt_header.bin of=$@ bs=$(SECTOR_SIZE) seek=1 conv=notrunc

.PHONY: run
run: boot.img
	qemu-system-i386 -s -hda $<

.PHONY: clean
clean:
	rm -rf *.bin
	rm -rf *.o
	rm -rf boot.img
