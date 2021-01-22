.POSIX:

CFLAGS+= -D_POSIX_C_SOURCE=200112L

TARGET=mkimg
OBJS=main.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $(TARGET) $(OBJS)

clean:
	rm -f $(TARGET)
	rm -f $(OBJS)


