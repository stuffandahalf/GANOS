.POSIX:

LLVM_SRC_URL="https://github.com/stuffandahalf/llvm-project/releases/download/llvmorg-12.0.0-alix-beta2/llvm-project-12.0.0-alix-beta2.tar.xz"

all: cross

cross: cross/.cross.dir cross/.clang.target cross/.lld.target cross/.compiler-rt.target

cross/.cross.dir:
	mkdir cross
	touch cross/.cross.dir

cross/.clang.target: cross/.cross.dir llvm
	touch cross/.clang.target

cross/.lld.target: cross/.cross.dir llvm
	touch cross/.lld.target

cross/.compiler-rt.target: cross/.cross.dir cross/.clang.target cross/.lld.target llvm


