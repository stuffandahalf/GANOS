AS=nasm
SECTOR_SIZE=512

ifdef DEBUG
	QEMU_DEBUG=-d cpu,exec,in_asm -S
endif

%.bin %.lst: %.asm
	$(AS) -l $(@:.bin=.lst) -f bin -o $@ $<

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
	qemu-system-i386 -s $(QEMU_DEBUG) -hda $<

.PHONY: clean
clean:
	rm -rf *.bin
	rm -rf *.lst
	rm -rf *.o
	rm -rf *.img
	rm -rf *.vdi
	#cd ../../tools/configurator && make clean
