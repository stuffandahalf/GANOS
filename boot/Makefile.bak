SUBDIRS=i386 \
		powerpc

all: $(SUBDIRS:=.dir)

i386.dir: i386/Makefile
	cd i386; $(MAKE) all

powerpc.dir: powerpc/Makefile
	cd powerpc; $(MAKE) all

clean:
	for SUBDIR in $(SUBDIRS); do \
		cd $$SUBDIR; $(MAKE) clean; cd ..; \
	done


