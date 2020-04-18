ifndef ARCH
	ARCH=i386
endif
ifndef IMAGETYPE
	IMAGETYPE=hdd
endif

ifdef DEBUG
	QEMU_DEBUG=-d cpu,exec,in_asm
endif

$(ARCH)_$(IMAGETYPE).img: boot/$(ARCH)/$(ARCH)_$(IMAGETYPE).img
	cp $< ./

boot/$(ARCH)/$(ARCH)_$(IMAGETYPE).img: boot/Makefile
	cd boot/ && make

.PHONY: run
run: $(ARCH)_$(IMAGETYPE).img
	qemu-system-$(ARCH) -s $(QEMU_DEBUG) -hda $<

.PHONY: clean
clean:
	cd boot && make clean

