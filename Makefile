.POSIX:

TARGETS=i386 \
	amd64 \
	powerpc \
	powerpc64

SUBDIRS=bin \
	boot \
	sys \
	usr.bin

all: $(TARGETS:=.all)

toolchain: tools/Makefile
	cd tools; $(MAKE) all

i386.all: toolchain

amd64.all: toolchain

powerpc.all: toolchain

powerpc64.all: toolchain

clean:
	for SUBDIR in $(SUBDIRS); do \
		cd $$SUBDIR; $(MAKE) clean; cd ..; \
	done

