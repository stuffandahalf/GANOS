all: $(ARCH).dir

SUBDIRS=i386 \
		powerpc

$(ARCH).dir: $(ARCH)/Makefile
	cd $(ARCH); $(MAKE) all

clean:
	for SUBDIR in $(SUBDIRS); do \
		cd $$SUBDIR; $(MAKE) clean; cd ..; \
	done


