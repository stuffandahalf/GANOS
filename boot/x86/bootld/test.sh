#!/bin/sh

set -e

QEMU_FLAGS="-S -s -display curses"

if [ -z $DEVICE ]; then
	echo "Variable \$DEVICE is not set" >&2
	exit 1
fi

qemu-system-i386 -fda $DEVICE $QEMU_FLAGS

