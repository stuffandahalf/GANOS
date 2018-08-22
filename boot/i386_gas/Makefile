AS=as
LD=ld

%.o: %.S
	$(AS) -o $@ $<

boot0.bin: boot0.o
	$(LD) -Ttext 0x7c00 --oformat=binary -o $@ $<

boot1.bin: boot1.o
	$(LD) -Ttext 0x1000 --oformat=binary -o $@ $<

floppy.img: boot0.bin boot1.bin
	dd if=/dev/zero of=$@ bs=512 count=2880
	dd if=boot0.bin of=$@ seek=0 count=1 conv=notrunc
	dd if=boot1.bin of=$@ seek=1 count=17 conv=notrunc

.PHONY: clean
clean:
	rm -f *.o
	rm -f *.bin
	rm -f *.img

.PHONY: run
run: boot0.bin
	qemu-system-i386 -fda $<

.PHONY: test
test: floppy.img
	qemu-system-i386 -fda $<
