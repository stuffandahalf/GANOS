AS=as
LD=ld

%.o: %.S
	$(AS) -o $@ $<

boot0.bin: boot0.o
	$(LD) -Ttext 0x7c00 --oformat=binary -o $@ $<

.PHONY: clean
clean:
	rm -f *.o
	rm -f *.bin

.PHONY: run
run: boot0.bin
	qemu-system-i386 -fda $<
