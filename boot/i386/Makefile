.POSIX:
.SUFFIXES:

SUBDIRS=pmbr gptboot
SUBDIR_TARGETS=$(SUBDIRS:=.dir)

all: $(SUBDIR_TARGETS)

$(SUBDIR_TARGETS):
	cd $(@:.dir=) && $(MAKE)

clean:
	cd pmbr && make clean && cd ..
	cd gptboot && make clean && cd ..

