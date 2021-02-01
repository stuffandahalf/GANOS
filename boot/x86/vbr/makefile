.POSIX:

LDFLAGS+=-Ttext 0x0a00 --oformat binary
#LDFLAGS+=-Ttext 0x0500 --oformat binary

TARGET=vbr.bin
OBJS=vbr.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $(TARGET) $(OBJS)

clean:
	rm -f $(TARGET)
	rm -f $(OBJS)

