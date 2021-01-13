.POSIX:

TARGET=bootld.sys
OBJS=bootld.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(LD) $(LDFLAGS) -Ttext 0x0600 --oformat binary -o $(TARGET) $(OBJS)

clean:
	rm -f $(TARGET)
	rm -f $(OBJS)

