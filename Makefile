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
	for SUBDIR in $(SUBDIRS); do \
		cd $$SUBDIR; $(MAKE) ARCH=i386; cd ..; \
	done

amd64.all: toolchain
	for SUBDIR in $(SUBDIRS); do \
		cd $$SUBDIR; $(MAKE) ARCH=amd64; cd..; \
	done

powerpc.all: toolchain
	for SUBDIR in $(SUBDIRS); do \
		cd $$SUBDIR; $(MAKE) ARCH=powerpc; cd..; \
	done

powerpc64.all: toolchain
	for SUBDIR in $(SUBDIRS); do \
		cd $$SUBDIR; $(MAKE) ARCH=powerpc64; cd..; \
	done

clean:
	for SUBDIR in $(SUBDIRS); do \
		cd $$SUBDIR; $(MAKE) clean; cd ..; \
	done
	cd tools; $(MAKE) clean


