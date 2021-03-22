#!/bin/sh
set -e

TARGET=./disk.img
TMP=$PWD

make all
cd ../vbr && make all && cd $TMP
cd minikern && make all && cd ..

dd if=/dev/zero of=$TARGET bs=512 count=2880
mkfs.fat -F12 $TARGET
dd if=../vbr/vbr.bin of=$TARGET bs=512 count=1 conv=notrunc
mkdir -p mnt
sudo mount $TARGET ./mnt
sudo cp ./bootld.sys ./mnt
sudo cp ./minikern/minikern ./mnt
sudo umount ./mnt
rm -r ./mnt

