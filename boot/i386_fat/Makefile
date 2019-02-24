AS=nasm
SECTOR_SIZE=512

ifdef DEBUG
	QEMU_DEBUG=-d cpu,exec,in_asm
endif

%.bin: %.asm
	$(AS) -f bin -o $@ $<

#boot.img: boot0.bin hello.bin efi.bin ../../tools/configurator/configure
#	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=262144
#	dd if=boot0.bin of=$@ seek=0 count=1 conv=notrunc
#	../../tools/configurator/configure -d $@ -s $(SECTOR_SIZE)

boot.img: boot0.bin hello.bin
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=262144
	sgdisk -n 1:2048:133119 -t 1:ef00 -c 1:"EFI System Partition" $@
	dd if=boot0.bin of=$@ seek=0 count=1 conv=notrunc
	( echo 'w'; echo 'y' ) | gdisk $@
	sudo losetup -o1048576 /dev/loop16 $@
	sudo mkdosfs -F32 /dev/loop16
	mkdir ./image_mnt
	sudo mount /dev/loop16 ./image_mnt
	sudo cp hello.bin ./image_mnt/
	sudo umount /dev/loop16
	sudo losetup -d /dev/loop16
	rmdir ./image_mnt


../../tools/configurator/configure:
	cd ../../tools/configurator && make

.PHONY: run
run: boot.img
	qemu-system-i386 -s $(QEMU_DEBUG) -hda $<

.PHONY: clean
clean:
	rm -rf *.bin
	rm -rf *.o
	rm -rf *.img
	#cd ../../tools/configurator && make clean
