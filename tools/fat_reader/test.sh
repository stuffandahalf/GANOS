#!/bin/bash

IMAGE=../../boot/i386_fat/boot.img

make
sudo losetup -f -o1048576 --sizelimit 67108864 $IMAGE
LD=`sudo losetup -j $IMAGE | grep -o "/dev/loop[0-9]*"`
#echo $LD
sudo valgrind ./fat_reader $LD
sudo losetup -d $LD
