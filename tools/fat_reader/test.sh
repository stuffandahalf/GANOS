#!/bin/bash

IMAGEDIR=../../boot/i386_fat
IMAGE=${IMAGEDIR}/boot.img

make
if [ ! -f $IMAGE ]; then
    cd ../../boot/i386_fat && make
fi
sudo losetup -f -o1048576 --sizelimit 67108864 $IMAGE
LD=`sudo losetup -j $IMAGE | grep -o "/dev/loop[0-9]*"`
#echo $LD
sudo valgrind ./fat_reader $LD
sudo losetup -d $LD
