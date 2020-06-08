.POSIX:

SUBDIRS=\
		echo \
		sh

SUBDIR_TARGETS=$(SUBDIRS:=.dir)

all: $(SUBDIR_TARGETS)

$(SUBDIR_TARGETS):
	cd $(@:.dir=); $(MAKE) all

clean:
	for SUBDIR in $(SUBDIRS); do \
		cd $$SUBDIR; $(MAKE) clean; cd ..; \
	done


