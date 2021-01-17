.POSIX:

CFLAGS+=-ffreestanding -fPIE -m32 
LDFLAGS+=-nostdlib -static -pie -m32

TARGET=minikern
OBJS=entry.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $(TARGET) $(OBJS)

clean:
	rm -f $(OBJS)
	rm -f $(TARGET)


