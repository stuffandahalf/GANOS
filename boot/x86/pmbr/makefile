.POSIX:

TARGET=pmbr.bin
OBJS=pmbr.o

LDFLAGS+=-Ttext 0x7c00 --oformat binary

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $(TARGET) $(OBJS)

clean:
	rm -f $(TARGET)
	rm -f $(OBJS)
