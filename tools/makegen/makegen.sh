#!/bin/sh

DEBUG=false
echo_debug()
{
	if [ "$DEBUG" = true ]; then
		echo $@ 1>&2
	fi
}

get_field()
{
	echo "$FIELDS" | grep "^$1[[:space:]]*=[[:space:]]*" | sed -n -e "s/^$1[[:space:]]*=[[:space:]]*//p"
}

emit()
{
	echo "$@" >> $OUT_FILE
}

# from https://stackoverflow.com/questions/3915040/bash-fish-command-to-print-absolute-path-to-a-filehttps://stackoverflow.com/questions/3915040/bash-fish-command-to-print-absolute-path-to-a-file
realpath()
{
	echo "$(cd "$(dirname "$1")"; pwd -P)/$(basename "$1")"
}

# $1 = source file
emit_compile()
{
	SRC_FILE=$1
	case $SRC_FILE in
	*.c)
		BASEDIR=`dirname $SRC_FILE`
		INCLUDES=`cat $SRC_FILE | \
			grep "^\s*#\s*include\s\+\".*\"" | \
			sed -n -e "s/^\s*#\s*include\s\+\"/$BASEDIR\//p" | \
			sed -n -e 's/\"\s*$//p' | \
			tr '\r\n' '\n' | tr '\n' ' '`
		echo_debug "Include files for $SRC_FILE"
		echo_debug "$INCLUDES"
		echo_debug ""
	
		emit "$BUILD_DIR/`echo $SRC_FILE | tr '/' '.'`.o: $BUILD_DIR $SRC_FILE $INCLUDES"
		emit "	\$(CC) \$(CFLAGS) -c -o $BUILD_DIR/`echo $SRC_FILE | tr '/' '.'`.o $SRC_FILE"
		emit ""
		unset INCLUDES
		;;
	*.s)
		emit "$BUILD_DIR/`echo $SRC_FILE | tr '/' '.'`.o: $BUILD_DIR $SRC_FILE"
		emit "	\$(AS) \$(ASFLAGS) -o $BUILD_DIR/`echo $SRC_FILE | tr '/' '.'`.o $SRC_FILE"
		;;
	*)
		echo "ERROR: $SRC_FILE has an unsupported file extension" 1>&2
		rm "$OUT_FILE"
		exit 1
		;;
	esac
}

write_prog()
{
	emit ".POSIX:"
	emit ""
	emit "TARGET=$BUILD_DIR/$TARGET"
	emit ""
	emit "all: \$(TARGET)"
	emit "	"
	emit ""
	emit "\$(TARGET): $BUILD_DIR $OBJS"
	emit "	$LINKER \$(CFLAGS) \$(LDFLAGS) -o \$(TARGET) $OBJS"
	emit ""
	for SRC_FILE in $SRCS; do
		emit_compile $SRC_FILE
	done
	emit "$BUILD_DIR:"
	emit "	mkdir -p $BUILD_DIR"
	emit ""
	emit "install: $PREFIX$INSTALL_DIR \$(TARGET)"
	emit "	cp \$(TARGET) $PREFIX$INSTALL_DIR"
	emit ""
	emit "$PREFIX$INSTALL_DIR:"
	emit "	mkdir -p $PREFIX$INSTALL_DIR"
	emit ""
	emit "clean:"
	emit "	rm -rf $BUILD_DIR"
	emit ""
	emit ""
}

write_lib()
{
	emit ".POSIX:"
	emit ""
	emit "TARGET=$TARGET"
	emit ""
	emit "all: \$(TARGET)"
	emit ""
	emit "\$(TARGET): $OBJS"
	emit "	"
	emit ""
	for SRC_FILE in $SRCS; do
		emit_compile $SRC_FILE
	done
	emit "$BUILD_DIR:"
	emit "	mkdir -p $BUILD_DIR"
	emit ""
	emit "install: $PREFIX$INSTALL_DIR \$(TARGET)"
	emit "	cp \$(TARGET) $PREFIX$INSTALL_DIR"
	emit ""
	emit "$PREFIX$INSTALL_DIR:"
	emit "	mkdir -p $PREFIX$INSTALL_DIR"
	emit ""
	emit "clean:"
	emit "	rm -rf $BUILD_DIR"
	emit ""
	emit ""
}

write_meta()
{
	emit ".POSIX:"
	emit ""
	emit "all: $SUBDIR_TARGETS"
	emit ""
	for SUBDIR in $SUBDIRS; do
		emit "$SUBDIR.dir: $SUBDIR"
		emit "	cd $SUBDIR; \$(MAKE) all"
		emit ""
	done
	emit "install: $SUBDIR_TARGETS"
	for SUBDIR in $SUBDIRS; do
		emit "	cd $SUBDIR; \$(MAKE) install"
	done
	emit ""
	emit "clean:"
	for SUBDIR in $SUBDIRS; do
		emit "	cd $SUBDIR; \$(MAKE) clean"
	done
	emit ""
}

IN_FILE=make.mg
OUT_FILE=Makefile
BUILD_DIR=build

FIELDS=`cat "$IN_FILE"`
echo_debug "$FIELDS"

MG_TYPE=`get_field TYPE`

if [ -e $OUT_FILE ]; then
	rm $OUT_FILE
fi
touch $OUT_FILE

case $MG_TYPE in
meta)
	SUBDIRS=`get_field SUBDIRS`
	SUBDIR_TARGETS=""
	for SUBDIR in $SUBDIRS; do
		SUBDIR_TARGETS="$SUBDIR_TARGETS $SUBDIR.dir"
	done
	
	write_meta
	for SUBDIR in $SUBDIRS; do
		RETURN_DIR=`echo $PWD`
		cd $SUBDIR; ../$0; cd $RETURN_DIR
		unset RETURN_DIR
	done
	;;
prog)
	TARGET=`get_field TARGET`
	SRCS=`get_field SRCS`
	SRCS=`echo $SRCS`
	INSTALL_DIR=`get_field INSTALL_DIR`
	LINKER=`get_field LINKER`
	if [ -z "$LINKER" ]; then
		LINKER="\$(CC)"
	fi

	echo_debug "\$TARGET has value '$TARGET'"
	echo_debug "\$SRCS has value '$SRCS'"

	OBJS=
	for SRC_FILE in $SRCS; do
		OBJS="$OBJS build/`echo $SRC_FILE | tr '/' '.'`.o"
	done

	echo_debug $PREFIX
	if [ "{$PREFIX#${PREFIX%?}}" != / ]; then
		PREFIX=$PREFIX/
	fi
	if [ "{$INSTALL_DIR#${INSTALL_DIR%?}}" != / ]; then
		INSTALL_DIR=$INSTALL_DIR/
	fi

	write_prog
	;;
lib)
	TARGET=`get_field TARGET`
	
	write_lib
	;;
*)
	echo "`realpath $IN_FILE`: Invalid TYPE field or TYPE field missing" 1>&2
	;;
esac

