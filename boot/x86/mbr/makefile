.POSIX:

LDFLAGS+=-Ttext 0x7a00 --oformat binary

TARGET=mbr.bin
OBJS=mbr.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $(TARGET) $(OBJS)

clean:
	rm -f $(TARGET)
	rm -f $(OBJS)

