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

i386.all: i386.boot i386.kernel i386.userland

i386.boot: toolchain
	cd boot; $(MAKE) $(@:.boot=.dir)

i386.kernel: toolchain
	cd sys; $(MAKE) all ARCH=i386

i386.userland: toolchain
	cd bin; $(MAKE) all ARCH=i386
	cd usr.bin; $(MAKE) all ARCH=i386

amd64.all: amd64.boot amd64.kernel amd64.userland

amd64.boot: toolchain
	cd boot; $(MAKE) $(@:.boot=.dir)

amd64.kernel: toolchain
	cd sys; $(MAKE) all ARCH=amd64

amd64.userland: toolchain
	cd bin; $(MAKE) all ARCH=amd64
	cd usr.bin; $(MAKE) all ARCH=amd64

powerpc.all: powerpc.boot powerpc.kernel powerpc.userland

powerpc.boot: toolchain
	cd boot; $(MAKE) $(@:.boot=.dir)

powerpc.kernel: toolchain
	cd sys; $(MAKE) all ARCH=powerpc

powerpc.userland: toolchain
	cd bin; $(MAKE) all ARCH=powerpc
	cd usr.bin; $(MAKE) all ARCH=powerpc

powerpc64.all: powerpc64.boot powerpc64.kernel powerpc64.userland

powerpc64.boot: toolchain
	cd boot; $(MAKE) $(@:.boot=.dir)

powerpc64.kernel: toolchain
	cd sys; $(MAKE) all ARCH=powerpc64

powerpc64.userland: toolchain
	cd bin; $(MAKE) all ARCH=powerpc64
	cd usr.bin; $(MAKE) all ARCH=powerpc64

clean:
	for SUBDIR in $(SUBDIRS); do \
		cd $$SUBDIR; $(MAKE) clean; cd ..; \
	done

clean-all: clean
	cd tools; $(MAKE) clean


