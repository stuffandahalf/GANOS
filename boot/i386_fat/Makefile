AS=nasm
SECTOR_SIZE=512

ifdef DEBUG
override QEMU_DEBUG:=$(QEMU_DEBUG) -d cpu,exec,in_asm
endif

# Connect with gdb to localhost:1234
ifdef GDB
override QEMU_DEBUG:=$(QEMU_DEBUG) -s -S
endif

%.bin %.lst: %.asm
	$(AS) -l $(@:.bin=.lst) -f bin -o $@ $<

%.o: %.c
	~/bin/cross/bin/i686-elf-gcc -c -o $@ $< -ffreestanding -O2 -Wall -Wextra

boot1.bin: boot1.o boot1.ld
	#~/bin/cross/bin/i686-elf-gcc -T boot1.ld -o $@ -ffreestanding -O2 -nostdlib $< -lgcc
	~/bin/cross/bin/i686-elf-gcc -Ttext 0x500 -o boot1.pe $< -nostdlib
	objcopy -O binary boot1.pe $@

#boot.img: boot0.bin hello.bin efi.bin ../../tools/configurator/configure
#	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=262144
#	dd if=boot0.bin of=$@ seek=0 count=1 conv=notrunc
#	../../tools/configurator/configure -d $@ -s $(SECTOR_SIZE)

boot.img: boot0.bin boot1.bin
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=262144
	sgdisk -n 1:2048:133119 -t 1:ef00 -c 1:"EFI System Partition" $@
	dd if=boot0.bin of=$@ bs=$(SECTOR_SIZE) seek=0 count=1 conv=notrunc
	#( echo 'w'; echo 'y' ) | gdisk $@
	sudo losetup -f -o1048576 --sizelimit 67108864 $@
	$(eval LD=`sudo losetup -j $@ | grep -o "/dev/loop[0-9]*"`)
	mkdir -p ./image_mnt
	sudo mkdosfs -F32 $(LD)
	sudo mount $(LD) ./image_mnt
	sudo cp boot1.bin ./image_mnt/
	sudo umount $(LD)
	sudo losetup -d $(LD)
	rmdir ./image_mnt
	$(eval LD=)

boot.vdi: boot.img
	VBoxManage convertfromraw --format VDI $< $@

#.PHONY: mount\
mount: boot.img\
	sudo losetup -f -o1048576 $<\
	$(eval LD=`sudo losetup -j $< | grep -o "/dev/loop[0-9]*"`)\
	mkdir ./image_mnt\
	sudo mount $(LD) ./image_mnt\
\
.PHONY: unmount\
unmount: boot.img\
	echo $(LD)\
	sudo umount $(LD)\
	sudo losetup -d $(LD)\
	rmdir ./image_mnt\
	$(eval LD=)\

../../tools/configurator/configure:
	cd ../../tools/configurator && make

.PHONY: run
run: boot.img
	qemu-system-i386 $(QEMU_DEBUG) -hda $<

.PHONY: clean
clean:
	rm -rf *.bin
	rm -rf *.pe
	rm -rf *.lst
	rm -rf *.o
	rm -rf *.img
	rm -rf *.vdi
	#cd ../../tools/configurator && make clean
