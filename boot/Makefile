-include ../env.mk

.PHONY: $(ARCH)
$(ARCH): $(ARCH)/Makefile
	cd $(ARCH) && make all

.PHONY: clean
clean:
	cd $(ARCH) && make clean
