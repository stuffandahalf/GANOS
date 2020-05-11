.POSIX:

SUBDIRS=bin \
		boot \
		sys \
		usr.bin

all:

clean:
	for SUBDIR in $(SUBDIRS); do \
		cd $$SUBDIR; $(MAKE) clean; cd ..; \
	done

