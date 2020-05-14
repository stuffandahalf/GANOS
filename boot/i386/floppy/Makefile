.POSIX:

ARCH=i386
ROOT_DIR=../../..
include $(ROOT_DIR)/tools.mk

TARGET=mbr.bin
SRCS=mbr.s
OBJS=$(SRCS:.s=.o)

.SUFFIXES: .s .o

.s.o:
	$(AS) $(ASFLAGS) -o $@ $<

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -Ttext 0x7c00 --oformat binary -o $@ $(OBJS)

clean:
	rm -f $(OBJS)
	rm -f $(TARGET)


