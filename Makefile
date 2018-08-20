ARCH=i386

BOOT_SECTOR=sys/boot/$(ARCH)/boot.bin

floppy.img: $(BOOT_SECTOR)
	dd if=/dev/zero of=$@ bs=1024 count=1440
	dd if=$(BOOT_SECTOR) of=$@ seek=0 count=1 conv=notrunc
	
