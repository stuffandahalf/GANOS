#include ../../env.mk

SRC_DIR=src
OBJ_DIR=objs
OUT_DIR=out

TARGETS=$(OUT_DIR)/pmbr.bin $(OUT_DIR)/gptboot.com

.PHONY: all
all: $(TARGETS)

$(OUT_DIR)/pmbr.bin: $(OBJ_DIR)/pmbr.o $(OUT_DIR)
	$(LD) -Ttext 0x7c00 --oformat binary -o $(OUT_DIR)/pmbr.bin $(OBJ_DIR)/pmbr.o

$(OUT_DIR)/gptboot.com: $(OBJ_DIR)/gptboot.o $(OUT_DIR)
	$(LD) -Ttext 0x0100 --oformat binary -o $(OUT_DIR)/gptboot.com $(OBJ_DIR)/gptboot.o

$(OBJ_DIR)/pmbr.o: $(SRC_DIR)/pmbr.s $(OBJ_DIR)
	$(AS) -o $(OBJ_DIR)/pmbr.o $(SRC_DIR)/pmbr.s

$(OBJ_DIR)/gptboot.o: $(SRC_DIR)/gptboot.s $(OBJ_DIR)
	$(AS) -o $(OBJ_DIR)/gptboot.o $(SRC_DIR)/gptboot.s

$(OBJ_DIR):
	mkdir $(OBJ_DIR)

$(OUT_DIR):
	mkdir $(OUT_DIR)

.PHONY: run_pmbr
run_pmbr: $(OUT_DIR)/pmbr.bin
	qemu-system-i386 -hda $<

.PHONY: clean
clean:
	rm -rf $(OBJ_DIR)
	rm -rf $(OUT_DIR)
