#!/bin/sh

set -e

QEMU_FLAGS="-S -s -display curses"

if [ -z $DEVICE ]; then
	echo "Variable \$DEVICE is not set" >&2
	exit 1
fi

if [ -e ./mnt ]; then
	rmdir ./mnt
fi

make all
cd minikern && make && cd ..
mkdir ./mnt
sudo mount $DEVICE ./mnt
sudo cp ./bootld.sys ./mnt/
sudo cp ./minikern/minikern ./mnt/
sudo umount ./mnt
rmdir ./mnt

qemu-system-i386 -fda $DEVICE $QEMU_FLAGS

