.POSIX:

CFLAGS+= -D_POSIX_C_SOURCE=200112L

TARGET=alix-install
OBJS=main.o partman.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $(TARGET) $(OBJS)

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET)
	rm -f $(OBJS)

