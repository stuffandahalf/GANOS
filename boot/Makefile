include ../env.mk

all: $(ARCH)_boot

.PHONY: i386_boot
i386_boot: x86/Makefile
	cd x86 && make all_32

.PHONY: amd64_boot
amd64_boot: x86/Makefile
	cd x86 && make all_64

.PHONY: i486_boot
i486_boot: i386_boot

.PHONY: i586_boot
i586_boot: i386_boot

.PHONY: i686_boot
i686_boot: i386_boot

.PHONY: powerpc_boot
powerpc_boot: powerpc/Makefile
	cd powerpc && make all

.PHONY: clean
clean:
	cd $(ARCH) && make clean
