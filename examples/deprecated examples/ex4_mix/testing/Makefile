# to be placed in the ex<num>/testing dir
# run as >> make LLVM=<path/to/llvm/install/>

CC=$(LLVM)/bin/clang++
CFLAGS = -pthread

all : ex4_mix
.PHONY : all

main.o: ../main.cpp
	$(CC) -c -o $@ $< $(CFLAGS)

kernel.o: split_kernel_out.ll
	$(CC) -c $< -o $@

ex4_mix: main.o kernel.o
	$(CC) -o $@ $^ $(CFLAGS)

clean:
	rm -f *.o *~ ex4_float
