#include ../../env.mk

ifdef DEBUG
QEMU_DEBUG+= -d cpu,exec,in_asm
endif

# Connect with gdb to localhost:1234
ifdef GDB
QEMU_DEBUGr+:= -s -S
endif

TARGETS=pmbr.bin gptboot.com

.PHONY: all
all: $(TARGETS)

pmbr.bin: pmbr.o
	$(LD) -Ttext 0x7c00 --oformat binary -o pmbr.bin pmbr.o

gptboot.com: gptboot.o
	$(LD) -Ttext 0x0100 --oformat binary -o gptboot.com gptboot.o

pmbr.o: pmbr.s
	$(AS) -o pmbr.o pmbr.s

gptboot.o: gptboot.s
	$(AS) -o gptboot.o gptboot.s

.PHONY: run_pmbr
run_pmbr: pmbr.bin
	qemu-system-i386 $(QEMU_DEBUG) -hda $<

.PHONY: clean
clean:
	rm -rf *.o
	rm -rf *.bin
	rm -rf *.com
