CC=g++
CFLAGS= -pthread

all : ex1
.PHONY : all

main.o: main.cpp	
	$(CC) -c -o $@ $< $(CFLAGS)

kernel.o: kernel.cpp
	$(CC) -c -o $@ $< $(CFLAGS)

ex1: main.o kernel.o
	$(CC) -o $@ $^ $(CFLAGS)

clean:
	rm -f *.o *~ ex1 
