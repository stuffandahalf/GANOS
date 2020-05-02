.POSIX:
.SUFFIXES: .c .o

TARGET=make
SRCS=main.c
OBJS=$(SRCS:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS)

clean:
	rm -f $(TARGET)
	rm -f $(OBJS)


