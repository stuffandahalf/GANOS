#!/bin/sh
set -e

TARGET=./disk.img
TMP=$PWD

if [ -e ./mnt ]; then
	rmdir ./mnt
fi

cd ../bootld && make all && cd $TMP
dd if=/dev/zero of=$TARGET bs=512 count=2880
mkfs.fat -F12 $TARGET
mkdir ./mnt
sudo mount $TARGET ./mnt
sudo cp ../bootld/bootld.sys ./mnt/
sudo umount ./mnt
rmdir ./mnt

