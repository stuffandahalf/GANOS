#!/bin/sh

OS_NAME=GANIX
OUT_FILE=env.sh

ERROR="ERROR"
WARN="WARN"
DEBUG="DEBUG"
STAGE=1

echo "Welcome to $OS_NAME environment configuration script"
echo "This will produce a file called '$OUT_FILE' which when imported into the current shell, will set the MAKEFLAGS environment variable to build $OS_NAME"

if test -f "$OUT_FILE"; then
	VALID_INPUT=false
	while test $VALID_INPUT != true; do
		read -p "[$WARN] $OUT_FILE already exists. Would you like to remove it? [yn] " PROMPT
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
			echo "[$WARN] Invalid input. Please type one of [yn]."
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

ARCHITECTURES="i386 amd64 powerpc powerpc64 armhf aarch64"
VALID_ARCH=false
echo "[$STAGE] Available architectures: $ARCHITECTURES"
while test $VALID_ARCH != true; do
	read -p "[$STAGE] Select a target architecture? " ARCH
	case $ARCH in
	i386)
		VALID_ARCH=true
		;;
	amd64)
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
	aarch64)
		VALID_ARCH=true
		;;
	*)
		echo "[$WARN] Invalid architecture selected" 2>&2
		;;
	esac
done
unset VALID_ARCH
STAGE=`expr $STAGE + 1`

read -p "[$STAGE] Enter path for toolchain prefix or blank for make defaults? " TOOLCHAIN_PREFIX
if test -n "$TOOLCHAIN_PREFIX"; then
	TOOLCHAIN_PREFIX=${TOOLCHAIN_PREFIX/#~\//$HOME\/}
	echo "[$STAGE] Updated toolchain prefix ($TOOLCHAIN_PREFIX)"
	STAGE=`expr $STAGE + 1`

	VALID_TOOLCHAIN=false
	while test $VALID_TOOLCHAIN != true; do
		read -p "[$STAGE] Is the toolchain gcc or llvm? " TOOLCHAIN_TYPE
		case $TOOLCHAIN_TYPE in
		gcc)
			VALID_TOOLCHAIN=true
			;;
		llvm)
			VALID_TOOLCHAIN=true
			echo "LLVM cross-toolchains are not currently supported." 1>&2
			exit
			;;
		*)
			echo "[$WARN] Please enter one of gcc or llvm" 1>&2
			;;
		esac
	done
	unset VALID_TOOLCHAIN
	STAGE=`expr $STAGE + 1`

	echo "[$STAGE] Detecting development tools"
	TOOL_ARCH=$ARCH
	if test "$TOOL_ARCH" == "i386"; then
		TOOL_ARCH=i[3456]86
	fi
	case $TOOLCHAIN_TYPE in
	gcc)
		AS="$TOOLCHAIN_PREFIX/$TOOL_ARCH-elf-as"
		LD="$TOOLCHAIN_PREFIX/$TOOL_ARCH-elf-ld"
		CC="$TOOLCHAIN_PREFIX/$TOOL_ARCH-elf-gcc"
		;;
	llvm)
		AS=""
		LD=""
		CC=""
		;;
	esac
	unset TOOL_ARCH

	for TOOL in $AS $LD $CC; do
		if test -f "$TOOL"; then
			echo "[$STAGE] Found $TOOL"
		else
			echo "[$ERROR] $TOOL not found" 1>&2
			exit 1
		fi
	done
	STAGE=`expr $STAGE + 1`
else
	STAGE=`expr $STAGE + 1`
fi

echo "[$STAGE] Generating environment shell script"
touch "$OUT_FILE"
chmod u+x "$OUT_FILE"
echo "#!/bin/sh" >> "$OUT_FILE"
echo "MAKEFLAGS=\"\"" >> "$OUT_FILE"
echo "MAKEFLAGS=\"\$MAKEFLAGS ARCH=$ARCH\"" >> "$OUT_FILE"
echo "MAKEFLAGS=\"\$MAKEFLAGS CFLAGS=-O\ -ffrestanding\"" >> "$OUT_FILE"
if test -n "$TOOLCHAIN_PREFIX"; then
	echo "MAKEFLAGS=\"\$MAKEFLAGS TOOLCHAIN_PREFIX=$TOOLCHAIN_PREFIX\"" >> "$OUT_FILE"
	echo "MAKEFLAGS=\"\$MAKEFLAGS AS=$AS\"" >> "$OUT_FILE"
	echo "MAKEFLAGS=\"\$MAKEFLAGS LD=$LD\"" >> "$OUT_FILE"
	echo "MAKEFLAGS=\"\$MAKEFLAGS CC=$CC\"" >> "$OUT_FILE"
fi
echo "export MAKEFLAGS" >> "$OUT_FILE"
STAGE=`expr $STAGE + 1`

echo "[$STAGE] Done! You may now build $OS_NAME"

