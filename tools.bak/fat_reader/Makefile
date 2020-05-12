CC=cc
CFLAGS=-c -Wall

fat_reader: fat_reader.o
	$(CC) -o $@ $<

fat_reader.o: fat_reader.c
	$(CC) $(CFLAGS) $<

.PHONY: clean
clean:
	rm -rf *.o
	rm -rf fat_reader
