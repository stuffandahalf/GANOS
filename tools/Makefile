.POSIX:

TOOLS=llvm
BUILD_DIRS=$(TOOLS:=.build)
SRC_DIRS=$(TOOLS:=.src)

all: $(TOOLS)

llvm: llvm.build
	cd llvm.build; \
		$(MAKE) install

llvm.build: llvm.src
	mkdir $@
	cd $@; \
		cmake ../llvm.src/llvm -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../llvm

llvm.src:
	git clone https://github.com/llvm/llvm-project $@
	
clean:
	rm -rf $(BUILD_DIRS)
	rm -rf $(SRC_DIRS)
	rm -rf $(TOOLS)


