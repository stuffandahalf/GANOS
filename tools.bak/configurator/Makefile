CC=cc
CFLAGS=-c -Wall
LFLAGS=

OBJS=configure.o

%.o: %.c
	$(CC) $(CFLAGS) $<

configure: $(OBJS)
	$(CC) -o $@ $(OBJS) -lz

.PHONY: clean
clean:
	rm -rf *.o
	rm -rf configure
