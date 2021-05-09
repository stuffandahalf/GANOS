.POSIX:

CFLAGS+=-D_POSIX_C_SOURCE=200112L

TARGETS=amake make
amake_SRCS=main.c
amake_OBJS=$(amake_SRCS:.c=.o)

all: $(TARGETS)

amake: $(amake_OBJS)
	$(CC) $(LDFLAGS) -o amake $(amake_OBJS)

$(amake_OBJS): defs.h

make: make.sh
	cp make.sh make
	chmod u+x make

clean:
	rm -f $(TARGETS) $(amake_OBJS)

