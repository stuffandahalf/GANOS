AS=nasm
SECTOR_SIZE=512

%.bin: %.asm
	$(AS) -f bin -o $@ $<

boot.img: boot0.bin efi.bin ../../tools/configurator/configure
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=1024
	dd if=boot0.bin of=$@ seek=0 count=1 conv=notrunc
	../../tools/configurator/configure -d $@ -s $(SECTOR_SIZE)

../../tools/configurator/configure:
	cd ../../tools/configurator && make

.PHONY: run
run: boot.img
	qemu-system-i386 -s -hda $<

.PHONY: clean
clean:
	rm -rf *.bin
	rm -rf *.o
	rm -rf boot.img
	cd ../../tools/configurator && make clean
