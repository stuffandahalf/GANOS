ifndef ARCH
	ARCH=i386
endif
ifndef IMAGETYPE
	IMAGETYPE=hdd
endif

$(ARCH)_$(IMAGETYPE).img: $(ARCH)/Makefile
	cd $(ARCH) && make

.PHONY: clean
clean:
	cd $(ARCH) && make clean
