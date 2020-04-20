.POSIX:
.SUFFIXES:

SUBDIRS=pmbr gptboot

.PHONY: all
all: subdirs

.PHONY: subdirs $(SUBDIRS)
subdirs: $(SUBDIRS)

$(SUBDIRS):
	cd $@ && $(MAKE)

clean:
	cd pmbr && make clean && cd ..
	cd gptboot && make clean && cd ..

