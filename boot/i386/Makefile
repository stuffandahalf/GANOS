.POSIX:
.SUFFIXES:

ROOT_DIR=../..
include $(ROOT_DIR)/tools.mk

SUBDIRS=floppy \
		mbr \
		pmbr \
		gptboot
SUBDIR_TARGETS=$(SUBDIRS:=.dir)

all: $(SUBDIR_TARGETS)

$(SUBDIR_TARGETS):
	cd $(@:.dir=); $(MAKE)

test-pmbr.img: pmbr.dir gptboot.dir
	dd if=/dev/zero of=$@ bs=512 count=262144
	sgdisk -o -n 1:2048:133119 -t 1:ef00 -c 1:"EFI System Partition" $@
	dd if=pmbr/pmbr.bin of=$@ bs=512 count=1 conv=notrunc
	sudo losetup -f -o1048576 --sizelimit 67108864 $@
	mkdir -p ./image_mnt
	sudo mkdosfs -F32 `losetup -j $@ | grep -o "/dev/loop[0-9]*"`
	sudo mount `losetup -j $@ | grep -o "/dev/loop[0-9]*"` ./image_mnt
	sudo cp gptboot/gptboot.com ./image_mnt/
	sudo umount `losetup -j $@ | grep -o "/dev/loop[0-9]*"`
	sudo losetup -d `losetup -j $@ | grep -o "/dev/loop[0-9]*"`
	rmdir ./image_mnt
	unset LP_DEV
	#qemu-system-i386 -hda $@ -display curses

clean:
	for SUBDIR in $(SUBDIRS); do \
		cd $$SUBDIR; $(MAKE) clean; cd ..; \
	done
	rm -f test-*.img
