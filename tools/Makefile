.POSIX:

ARCHIVES=llvm.tar.xz
SRC_DIRS=$(ARCHIVES:.tar.xz=.src)
BUILD_DIRS=$(SRC_DIRS:.src=.build)
TOOLS=$(BUILD_DIRS:.build=)

#LLVM_SRC_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-10.0.0/llvm-project-10.0.0.tar.xz"

LLVM_SRC_URL="https://github.com/stuffandahalf/llvm-project/releases/download/llvmorg-12.0.0-alix-beta2/llvm-project-12.0.0-alix-beta2.tar.xz"

all: $(TOOLS)

llvm: llvm.build
	cd llvm.build; \
		$(MAKE) install; \
		cd ..; \
		touch $@

llvm.build: llvm.src
	mkdir $@
	cd $@; \
		cmake ../llvm.src/llvm -DLLVM_ENABLE_PROJECTS="clang;lld" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=../llvm; \
		$(MAKE)

llvm.src: llvm.tar.xz
	unxz < llvm.tar.xz | tar x -f-
	mv llvm-project-12.0.0-alix-beta2 $@
	touch -m $@

llvm.tar.xz:
	curl -L -o $@ -O $(LLVM_SRC_URL) || wget -O $@ $(LLVM_SRC_URL)

clean:
	rm -rf $(ARCHIVES)
	rm -rf $(SRC_DIRS)
	rm -rf $(BUILD_DIRS)
	rm -rf $(TOOLS)


