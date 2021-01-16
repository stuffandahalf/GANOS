.POSIX:

CFLAGS+=-m32 -ffreestanding -std=c99 -fPIE
LDFLAGS+=-m32 -nostdlib -static

TARGET=kern
OBJS=entry.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $(TARGET) $(OBJS)

clean:
	rm -f $(OBJS)
	rm -f $(TARGET)


