.POSIX:
.SUFFIXES:

TARGET=pmbr.bin
SRCS=pmbr.s
OBJS=$(SRCS:.s=.o)

.SUFFIXES: .s .o

.s.o:
	$(AS) $(ASFLAGS) -o $@ $<

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -Ttext 0x7c00 --oformat binary -o $@ $(OBJS)

clean:
	rm -f *.o
	rm -f $(TARGET)

