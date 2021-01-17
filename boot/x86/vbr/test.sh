#!/bin/sh
set -e

export QEMU_FLAGS="-S -s -display curses"

if [ -z $DEVICE ]; then
	echo "Variable \$DEVICE is not set" >&2
	exit 1
fi

make
sudo dd if=bootsec.bin of=$DEVICE bs=512 count=1 conv=notrunc
sudo qemu-system-i386 -fda $DEVICE $QEMU_FLAGS

