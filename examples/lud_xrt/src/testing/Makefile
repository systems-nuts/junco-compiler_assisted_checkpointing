# to be placed in the ex<num>/testing dir
# run as >> make LLVM=<path/to/llvm/install/>

CC=$(LLVM)/bin/clang++
CFLAGS = -pthread

all : ex
.PHONY : all

local_support.o: ../local_support.cpp
	$(CC) -c -o $@ $< $(CFLAGS)

lud.o: ../ir/split_lud_out.ll
	$(CC) -c $< -o $@

ex: local_support.o lud.o
	$(CC) -o $@ $^ $(CFLAGS)

clean:
	rm -f *.o *~ ex
