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

copy_targets boot/x86/pmbr .bin

dd if=/dev/zero of="$DEVICE" bs=512 count=`expr $SIZE / 512`
sgdisk -o "$DEVICE"
sgdisk -n 1:2048:1050624 -t 1:ef00 $DEVICE
if [ ${DEVICE: -4} == ".img" ]; then
	LOOP_DEV=`sudo losetup -P --fine --show $DEVICE`
else
	LOOP_DEV=$DEVICE
fi
sudo mkfs.fat -F32 $LOOP_DEVp1
if [${DEVICE: -4} == ".img" ]; then
	sudo losetup -d $LOOP_DEV
fi
