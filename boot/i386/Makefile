.POSIX:
.SUFFIXES:

SUBDIRS=pmbr gptboot
SUBDIR_TARGETS=$(SUBDIRS:=.dir)

all: $(SUBDIR_TARGETS)

$(SUBDIR_TARGETS):
	cd $(@:.dir=) && $(MAKE)

clean:
	for SUBDIR in $(SUBDIRS); do \
		cd $$SUBDIR && make clean && cd ..; \
	done

