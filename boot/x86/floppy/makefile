.POSIX:

TARGET=bootsec.bin
OBJS=bootsec.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -Ttext 0x7c00 --oformat binary -o $(TARGET) $(OBJS)

clean:
	rm -f $(TARGET)
	rm -f $(OBJS)

