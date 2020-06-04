#!/bin/sh

#DEBUG=true
echo_debug()
{
	if [ "$DEBUG" = true ]; then
		echo $@ 1>&2
	fi
}

get_field()
{
	echo "$FIELDS" | grep "^$1\s*=\s*" | sed -n -e "s/^$1\s*=\s*//p"
}

IN_FILE=make.mg
OUT_FILE=Makefile
BUILD_DIR=build

FIELDS=`cat "$IN_FILE"`
echo_debug "$FIELDS"

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

if [ -e $OUT_FILE ]; then
	rm $OUT_FILE
fi

touch $OUT_FILE
echo ".POSIX:" 												>> $OUT_FILE
echo ""														>> $OUT_FILE
echo "TARGET=$BUILD_DIR/$TARGET"							>> $OUT_FILE
echo ""														>> $OUT_FILE
echo "all: \$(TARGET)"										>> $OUT_FILE
echo "	"													>> $OUT_FILE
echo ""														>> $OUT_FILE
echo "\$(TARGET): $BUILD_DIR $OBJS"							>> $OUT_FILE
echo "	$LINKER \$(CFLAGS) \$(LDFLAGS) -o \$(TARGET) $OBJS"	>> $OUT_FILE
echo ""														>> $OUT_FILE
for SRC_FILE in $SRCS; do

	case $SRC_FILE in
	*.c)
		BASEDIR=`dirname $SRC_FILE`
		INCLUDES=`cat $SRC_FILE | grep "^\s*#\s*include\s\+\".*\"" | \
			sed -n -e "s/^\s*#\s*include\s\+\"/$BASEDIR\//p" | sed -n -e 's/\"\s*$//p' | tr '\r\n' '\n' | tr '\n' ' '`
		echo_debug "Include files for $SRC_FILE"
		echo_debug "$INCLUDES"
		echo_debug ""
	
		echo "$BUILD_DIR/`echo $SRC_FILE | tr '/' '.'`.o: $BUILD_DIR $SRC_FILE $INCLUDES" 	>> $OUT_FILE
		echo "	\$(CC) \$(CFLAGS) -c -o $BUILD_DIR/`echo $SRC_FILE | tr '/' '.'`.o $SRC_FILE" >> $OUT_FILE
		echo "" >> $OUT_FILE
		unset INCLUDES
		;;
	*.s)
		echo "$BUILD_DIR/`echo $SRC_FILE | tr '/' '.'`.o: $BUILD_DIR $SRC_FILE" >> $OUT_FILE
		echo "	\$(AS) \$(ASFLAGS) -o $BUILD_DIR/`echo $SRC_FILE | tr '/' '.'`.o $SRC_FILE" >> $OUT_FILE
		;;
	*)
		echo "ERROR: $SRC_FILE has an unsupported file extension" 1>&2
		exit 1
		;;
	esac
done
echo "$BUILD_DIR:"											>> $OUT_FILE
echo "	mkdir -p $BUILD_DIR"								>> $OUT_FILE
echo ""														>> $OUT_FILE
echo "install: $PREFIX$INSTALL_DIR \$(TARGET)"				>> $OUT_FILE
echo "	cp \$(TARGET) $PREFIX$INSTALL_DIR"					>> $OUT_FILE
echo ""														>> $OUT_FILE
echo "$PREFIX$INSTALL_DIR:"									>> $OUT_FILE
echo "	mkdir -p $PREFIX$INSTALL_DIR"						>> $OUT_FILE
echo ""														>> $OUT_FILE
echo "clean:"												>> $OUT_FILE
echo "	rm -rf $BUILD_DIR"									>> $OUT_FILE
echo ""														>> $OUT_FILE

echo ""														>> $OUT_FILE

