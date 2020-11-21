.POSIX:

TARGET=make
OBJS=main.o

all: $(TARGET)

clean:
	rm -f $(TARGET)
	rm -f $(OBJS)

run: $(TARGET)
	./$(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $(TARGET) $(OBJS)

main.o: main.c dynarray.h static_assert.h
	$(CC) $(CFLAGS) -c main.c

