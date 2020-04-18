SECTOR_SIZE=512

ifndef TOOLCHAIN_DIR
TOOLCHAIN_DIR=~/opt/cross/bin
endif

ifndef NASM
NASM=nasm
endif

ifndef AS
AS=$(TOOLCHAIN_DIR)/$(ARCH)-elf-as
endif

ifndef CC
CC=$(TOOLCHAIN_DIR)/$(ARCH)-elf-gcc
endif

ifndef LD
LD=$(TOOLCHAIN_DIR)/$(ARCH)-elf-ld
endif

ifdef DEBUG
override QEMU_DEBUG:=$(QEMU_DEBUG) -d cpu,exec,in_asm
endif

ifndef 

# Connect with gdb to localhost:1234
ifdef GDB
override QEMU_DEBUG:=$(QEMU_DEBUG) -s -S
endif

BOOTLD_OBJS=boot1.o boot2.o

%.bin %.lst: %.asm
	$(AS) -l $(@:.bin=.lst) -f bin -o $@ $<

%.o: %.asm
	$(AS) -felf32 -o $@ $<

%.o: %.c
	~/bin/cross/bin/i686-elf-gcc -c -o $@ $< -ffreestanding -O2 -Wall -Wextra

all: boot.img

bootld.bin: $(BOOTLD_OBJS)
	#~/bin/cross/bin/i686-elf-gcc -T boot1.ld -o $@ -ffreestanding -O2 -nostdlib $< -lgcc
	$(CC) -Ttext 0x500 -o boot1.pe $(BOOTLD_OBJS) -nostdlib
	objcopy -O binary boot1.pe $@
	rm boot1.pe

#boot.img: boot0.bin hello.bin efi.bin ../../tools/configurator/configure
#	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=262144
#	dd if=boot0.bin of=$@ seek=0 count=1 conv=notrunc
#	../../tools/configurator/configure -d $@ -s $(SECTOR_SIZE)

boot.img: boot0.bin bootld.bin
	dd if=/dev/zero of=$@ bs=$(SECTOR_SIZE) count=262144
	sgdisk -n 1:2048:133119 -t 1:ef00 -c 1:"EFI System Partition" $@
	dd if=boot0.bin of=$@ bs=$(SECTOR_SIZE) seek=0 count=1 conv=notrunc
	#( echo 'w'; echo 'y' ) | gdisk $@
	sudo losetup -f -o1048576 --sizelimit 67108864 $@
	$(eval LD=`sudo losetup -j $@ | grep -o "/dev/loop[0-9]*"`)
	mkdir -p ./image_mnt
	sudo mkdosfs -F32 $(LD)
	sudo mount $(LD) ./image_mnt
	sudo cp bootld.bin ./image_mnt/
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
