.POSIX:

TARGET=bootld.lde
OBJS=bootld.o

all=$(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -Ttext 0x07e00 --oformat binary -o $(TARGET) $(OBJS)

clean:
	rm -f $(TARGET)
	rm -f $(OBJS)

