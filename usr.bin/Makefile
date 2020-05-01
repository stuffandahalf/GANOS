.POSIX:

SUBDIRS=make
SUBDIR_TARGETS=$(SUBDIRS:=.dir)

all: $(SUBDIR_TARGETS)

$(SUBDIR_TARGETS):
	cd $(@:.dir=); make all

clean:
	for SUBDIR in $(SUBDIRS); do \
		cd $$SUBDIR; $(MAKE) clean; \
	done


