.POSIX:

TARGET=sh
SRCS=main.c
OBJS=$(SRCS:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

clean:
	rm -f $(TARGET)
	rm -f $(OBJS)
