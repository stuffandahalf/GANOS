.POSIX:

SRC_DIR=src/
BUILD_DIR=$(BUILD_DIR)obj/
INSTALL_DIR=$(PREFIX)/bin/

TARGET=$(BUILD_DIR)sh
SRCS=$(SRC_DIR)main.c $(SRC_DIR)builtins.c
OBJS=$(BUILD_DIR)main.o $(BUILD_DIR)builtins.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(TARGET) $(OBJS)
	
$(BUILD_DIR)main.o: $(BUILD_DIR) $(SRC_DIR)main.c $(SRC_DIR)builtins.h
	$(CC) $(CFLAGS) -c -o $(BUILD_DIR)main.o $(SRC_DIR)main.c

$(BUILD_DIR)builtins.o: $(BUILD_DIR) $(SRC_DIR)builtins.c $(SRC_DIR)builtins.h
	$(CC) $(CFLAGS) -c -o $(BUILD_DIR)builtins.o $(SRC_DIR)builtins.c

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(INSTALL_DIR):
	mkdir -p $(INSTALL_DIR)

install: $(INSTALL_DIR) $(TARGET)
	cp $(TARGET) $(INSTALL_DIR)sh

clean:
	rm -f $(TARGET)
	rm -f $(OBJS)
