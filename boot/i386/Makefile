.POSIX:
.SUFFIXES:

SUBDIRS=mbr \
		pmbr \
		gptboot
SUBDIR_TARGETS=$(SUBDIRS:=.dir)

all: $(SUBDIR_TARGETS)

$(SUBDIR_TARGETS):
	cd $(@:.dir=); $(MAKE)

clean:
	for SUBDIR in $(SUBDIRS); do \
		cd $$SUBDIR; $(MAKE) clean; cd ..; \
	done

