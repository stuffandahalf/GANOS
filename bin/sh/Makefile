.POSIX:

TARGET=sh
SRCS=main.c builtins.c
OBJS=$(SRCS:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJS)
	
main.o: main.c builtins.h
	$(CC) $(CFLAGS) -c $(@:.o=.c)

builtins.o: builtins.c builtins.h
	$(CC) $(CFLAGS) -c $(@:.o=.c)

clean:
	rm -f $(TARGET)
	rm -f $(OBJS)
