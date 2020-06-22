TYPE=prog
TARGET=pmbr.bin
SRCS=src/*.s
INSTALL_DIR=/boot/i386/
LINKER=$(LD)
LDFLAGS=-Ttext 0x7c00 --oformat binary

