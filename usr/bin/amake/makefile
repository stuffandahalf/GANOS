.POSIX:

TARGETS=amake make
amake_SRCS=main.c
amake_OBJS=$(amake_SRCS:.c=.o)

all: $(TARGETS)

amake: $(amake_OBJS)
	$(CC) $(LDFLAGS) -o amake $(amake_OBJS)

make: make.sh
	cp make.sh make
	chmod u+x make

clean:
	rm -f $(TARGETS) $(amake_OBJS)

