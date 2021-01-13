#!/bin/sh
set -e

TARGET=./disk.img
TMP=$PWD

#cd ../bootld && make all && cd $TMP
cd ../floppy && make all && cd $TMP
dd if=/dev/zero of=$TARGET bs=512 count=2880
mkfs.fat -F12 $TARGET
dd if=../floppy/bootsec.bin of=$TARGET bs=512 count=1 conv=notrunc

