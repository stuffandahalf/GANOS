.POSIX:

LDFLAGS+=-Ttext 0x7c00 --oformat binary

TARGET=vbr.bin
OBJS=vbr.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $(TARGET) $(OBJS)

clean:
	rm -f $(TARGET)
	rm -f $(OBJS)

