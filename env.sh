#!/bin/sh

MAKEFLAGS="$MAKEFLAGS AS=~/opt/cross/bin/i686-elf-as"
MAKEFLAGS="$MAKEFLAGS LD=~/opt/cross/bin/i686-elf-ld"
export MAKEFLAGS
