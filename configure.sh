#!/bin/sh

OUT_FILE=env.mk

ERROR="ERROR"
WARN="WARN"
DEBUG="DEBUG"
STAGE=1

echo "Welcome to GANIX configuration script"
echo "This will produce the file 'env.mk' which will be used to configure make"
echo ""

if test -f "$OUT_FILE"; then
	VALID_INPUT=false
	while test $VALID_INPUT != true; do
		read -p "[$WARN] $OUT_FILE already exists. Would you like to overwrite it? [yn] " PROMPT
		case $PROMPT in
		y)
			echo "[$WARN] Deleting $OUT_FILE"
			rm -f "$OUT_FILE"
			VALID_INPUT=true
			;;
		n)
			echo "[$ERROR] Aborting configuration"
			exit 1
			;;
		*)
			echo "[$WARN] Invalid input. type [yn]."
			;;
		esac
	done
	unset PROMPT
	unset VALID_INPUT
fi

echo "[$STAGE] Checking for make"
MAKE=`which make 2> /dev/null`
if test $MAKE != ""; then
	echo "[$STAGE] make detected ($MAKE)"
else
	echo "[$ERROR] make not found" 1>&2
	exit 1
fi

STAGE=`expr $STAGE + 1`
echo "[$STAGE] Checking for GNU make"
IS_GNU_MAKE=`$MAKE --version 2> /dev/null | grep "GNU Make" > /dev/null 2> /dev/null && echo 1 || echo 0`
if test $IS_GNU_MAKE -eq 1; then
	echo "[$STAGE] GNU Make detected"
else
	echo "[$STAGE] UNIX Make detected"
fi

STAGE=`expr $STAGE + 1`
ARCHITECTURES="i386 x86_64 powerpc powerpc64 armhf arm64"
VALID_ARCH=false
echo "[$STAGE] Available Architectures: $ARCHITECTURES"
while test $VALID_ARCH != true; do
  read -p "[$STAGE] Select a target architecture " ARCH
  case $ARCH in
  i386)
  	VALID_ARCH=true
  	;;
  x86_64)
  	VALID_ARCH=true
  	;;
  powerpc)
  	VALID_ARCH=true
  	;;
  powerpc64)
  	VALID_ARCH=true
  	;;
  armhf)
  	VALID_ARCH=true
  	;;
  arm64)
  	VALID_ARCH=true
  	;;
  *)
  	echo "[$ERROR] Invalid architecture selected" 1>&2
  	;;
  esac
done
unset VALID_ARCH
echo "[$STAGE] Selected target $ARCH"

STAGE=`expr $STAGE + 1`
TOOLCHAIN_PREFIX=""
read -p "[$STAGE] Enter path for toolchain prefix or blank for make default " NEW_TOOLCHAIN_PREFIX
if test -n "$NEW_TOOLCHAIN_PREFIX"; then
	TOOLCHAIN_PREFIX=${NEW_TOOLCHAIN_PREFIX/#~\//$HOME\/}
	echo "[$STAGE] Updated toolchain prefix ($TOOLCHAIN_PREFIX)"

  STAGE=`expr $STAGE + 1`
  VALID_TOOLCHAIN=false
  while test $VALID_TOOLCHAIN != true; do
    read -p "[$STAGE] Is the toolchain gcc or llvm " TOOLCHAIN_TYPE
    case $TOOLCHAIN_TYPE in
    gcc)
      VALID_TOOLCHAIN=true
      ;;
    llvm)
      VALID_TOOLCHAIN=true
      ;;
    *)
      echo "Please enter one of gcc or llvm" 1>&2
      ;;
    esac
  done
  unset VALID_TOOLCHAIN

  STAGE=`expr $STAGE + 1`
  echo "[$STAGE] Detecting development tools"
  case $TOOLCHAIN_TYPE in
  gcc)
    AS="$TOOLCHAIN_PREFIX/$ARCH-elf-as"
    LD="$TOOLCHAIN_PREFIX/$ARCH-elf-ld"
    CC="$TOOLCHAIN_PREFIX/$ARCH-elf-gcc"
    ;;
  llvm)
    echo "LLVM toolchain is not currently supported" 1>&2
    exit 1
    ;;
  esac

  for TOOL in $AS $LD $CC; do
    if test -f "$TOOL"; then
      echo "[$STAGE] Found $TOOL"
    else
      echo "[$ERROR] $TOOL not found" 1>&2
      exit 1
    fi
  done
fi

STAGE=`expr $STAGE + 1`
echo "[$STAGE] Generating make configuration file"
touch "$OUT_FILE"
echo "#This make include file was auto generated on `date`" >> "$OUT_FILE"
echo "IS_GNU_MAKE=$IS_GNU_MAKE" >> "$OUT_FILE"
echo "ARCH=$ARCH" >> "$OUT_FILE"
if test -n "$NEW_TOOLSHAIN_PREFIX"; then
  echo "TOOLCHAIN_PREFIX=$TOOLCHAIN_PREFIX" >> "$OUT_FILE"
  echo "AS=$AS" >> "$OUT_FILE"
  echo "LD=$LD" >> "$OUT_FILE"
  echo "CC=$CC" >> "$OUT_FILE"
fi

STAGE=`expr $STAGE + 1`
echo "[$STAGE] Done! You may now build Ganix"

