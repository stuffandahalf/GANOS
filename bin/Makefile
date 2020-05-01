.POSIX:

SUBDIRS=sh
SUBDIR_TARGETS=$(SUBDIR:=.dir)

all: $(SUBDIR_TARGETS)

$(SUBDIR_TARGETS):
	cd $@; $(MAKE) all

clean:
	for SUBDIR in $(SUBDIRS); do \
		cd $$SUBDIR; $(MAKE) clean; cd ..; \
	done


