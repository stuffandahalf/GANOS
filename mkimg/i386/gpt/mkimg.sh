#!/bin/sh
set -e
source ../platform.env

if [ -z "$DEVICE" ]; then
	DEVICE=./disk.img
fi

if [ -z $SIZE ]; then
	if [ ${DEVICE: -4} == ".img" ]; then
		SIZE=4294967296
	else
		SIZE=`wc -c "$DEVICE"`
	fi
fi

build_project boot/x86/pmbr
build_project boot/x86/bootld

copy_targets boot/x86/pmbr .bin
copy_targets boot/x86/bootld .sys

dd if=/dev/zero of="$DEVICE" bs=512 count=`expr $SIZE / 512`
sgdisk -o "$DEVICE"
sgdisk -n 1:2048:1050624 -t 1:ef00 $DEVICE
dd if=./pmbr.bin of="$DEVICE" bs=512 count=1 seek=0 conv=notrunc
if [ ${DEVICE: -4} == ".img" ]; then
	LOOP_DEV=`sudo losetup -Pf --show $DEVICE`
else
	LOOP_DEV=$DEVICE
fi
sudo mkfs.fat -F32 `printf "%sp1" "$LOOP_DEV"`
mkdir -p ./mnt
sudo mount `printf "%sp1" "$LOOP_DEV"` ./mnt
sudo cp ./bootld.sys ./mnt/
sudo umount ./mnt
rmdir ./mnt
if [ ${DEVICE: -4} == ".img" ]; then
	sudo losetup -d $LOOP_DEV
fi
