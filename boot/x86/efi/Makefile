.POSIX:

ARCH=i386
ROOT_DIR=../../..

#include $(ROOT_DIR)/tools.mk

TARGET=efildr.efi
SRCS=efildr.c
OBJS=$(SRCS:.c=.o)

CC=$(ROOT_DIR)/tools/llvm/bin/clang
LD=$(ROOT_DIR)/tools/llbm/bin/ld.lld
CFLAGS=--target=$(ARCH)-unknown-windows -ffreestanding -fshort-wchar
LDFLAGS=--target=$(ARCH)-unknown-windows -nostdlib -Wl,-entry:efi_main \
	-Wl,-subsystem:efi_application \
	-fuse-ld=$(ROOT_DIR)/tools/llvm/bin/ld.lld

.SUFFIXES: .c .o

.c.o:
	$(CC) $(CFLAGS) -I$(ROOT_DIR)/include/EFI --target=i386-unknown-windows -o $@ $<

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $(TARGET) $(OBJS)

clean:
	rm -rf $(TARGET)
	rm -rf $(OBJS)

