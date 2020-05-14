.POSIX:

PLATFORM=$(ARCH)-none
AS=$(ROOT_DIR)/tools/llvm/bin/clang -c --target=$(PLATFORM)
LD=$(ROOT_DIR)/tools/llvm/bin/ld.lld
CC=$(ROOT_DIR)/tools/llvm/bin/clang --target=$(PLATFORM)

