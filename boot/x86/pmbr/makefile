.POSIX:

TARGET=pmbr.bin
OBJS=pmbr.o

LDFLAGS+=-Ttext 0x0800 --oformat binary

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -o $(TARGET) $(OBJS)

clean:
	rm -f $(TARGET)
	rm -f $(OBJS)
