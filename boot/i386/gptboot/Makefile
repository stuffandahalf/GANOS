.POSIX:
.SUFFIXES:

TARGET=gptboot.com
SRCS=gptboot.s
OBJS=$(SRCS:.s=.o)

.SUFFIXES: .s .o

.s.o:
	$(AS) $(ASFLAGS) -o $@ $<

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -Ttext 0x0100 --oformat binary -o $@ $(OBJS)

clean:
	rm -f $(OBJS)
	rm -f $(TARGET)

