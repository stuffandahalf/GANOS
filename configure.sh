#!/bin/sh

OUT_FILE=env.mk

ERROR="[ERROR]"
WARN="[WARN]"
DEBUG="[DEBUG]"

echo "Welcome to GANIX configuration script"
echo "This will produce the file 'env.mk' which will be used to configure make"
echo ""

if test -f "$OUT_FILE"; then
	VALID_INPUT=false
	while test $VALID_INPUT != true ; do
		read -p "$WARN $OUT_FILE already exists. Would you like to overwrite it? [yn] " PROMPT
		case $PROMPT in
		y)
			echo "$WARN Deleting $OUT_FILE"
			rm -f "$OUT_FILE"
			VALID_INPUT=true
			;;
		n)
			echo "ERROR Aborting configuration"
			exit 1
			;;
		*)
			echo "$WARN Invalid input. type [yn]."
			;;
		esac
	done
	unset VALID_INPUT
fi

STAGE="[1]"
echo "$STAGE Checking for make"
MAKE=`which make 2> /dev/null`
if test $MAKE != ""; then
	echo "$STAGE make detected ($MAKE)"
else
	echo "$ERROR make not found" 1>&2
	exit 1
fi

STAGE="[2]"
echo "$STAGE Checking for GNU make"
IS_GNU_MAKE=`$MAKE --version 2> /dev/null | grep "GNU Make" > /dev/null 2> /dev/null && echo 1 || echo 0`
if test $IS_GNU_MAKE -eq 1; then
	echo "$STAGE GNU Make detected"
else
	echo "$STAGE UNIX Make detected"
fi

STAGE="[3]"
ARCHITECTURES="i[3456]86 x86_64 powerpc powerpc64 armhf arm64"
echo "$STAGE Available Architectures: $ARCHITECTURES"
read -p "$STAGE Select a target architecture " ARCH
case $ARCH in
i[3456]86)
	;;
x86_64)
	;&
powerpc)
	;&
powerpc64)
	;&
armhf)
	;&
arm64)
	;&
*)
	echo "$ERROR Invalid Architecture selected" 1>&2
	exit 1
	;;
esac
echo "$STAGE Selected target $ARCH"

STAGE="[4]"
TOOLCHAIN_PREFIX=~/opt/cross/bin
read -p "$STAGE Enter path for toolchain prefix or blank for default ($TOOLCHAIN_PREFIX) " NEW_TOOLCHAIN_PREFIX
if test -n "$NEW_TOOLCHAIN_PREFIX"; then
	TOOLCHAIN_PREFIX=$NEW_TOOLCHAIN_PREFIX
	echo "$STAGE Updated toolchain prefix ($TOOLCHAIN_PREFIX)"
	unset NEW_TOOLCHAIN_PREFIX
fi

STAGE="[5]"
echo "$STAGE Detecting development tools"
AS="$TOOLCHAIN_PREFIX/$ARCH-elf-as"
LD="$TOOLCHAIN_PREFIX/$ARCH-elf-ld"
CC="$TOOLCHAIN_PREFIX/$ARCH-elf-gcc"
for TOOL in $AS $LD $CC; do
	if test -f "$TOOL"; then
		echo "$STAGE Found $TOOL"
	else
		echo "$ERROR $TOOL not found" 1>&2
		exit 1
	fi
done

STAGE="[6]"
echo "$STAGE Generating make configuration file"
touch "$OUT_FILE"
echo "TOOLCHAIN_PREFIX=$TOOLCHAIN_PREFIX" >> "$OUT_FILE"
echo "IS_GNU_MAKE=$IS_GNU_MAKE" >> "$OUT_FILE"
echo "ARCH=$ARCH" >> "$OUT_FILE"
echo "AS=$AS" >> "$OUT_FILE"
echo "LD=$LD" >> "$OUT_FILE"
echo "CC=$CC" >> "$OUT_FILE"

STAGE="[7]"
echo "$STAGE Done!. You may now build Ganix"

