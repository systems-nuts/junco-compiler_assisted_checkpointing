# run as >> make LLVM=<path/to/llvm/install/>

CC=$(LLVM)/bin/clang++
OPT=$(LLVM)/bin/opt
CFLAGS = -pthread # -O1 # -O1
INJECT?=save_restore

all : ex
.PHONY : all

cholesky.ll: ../cholesky_kernel_cpu.cpp
	#Dale:
	$(CC) -S -O0 $< -emit-llvm -o $@ -fno-discard-value-names -Xclang -disable-O0-optnone

split_cholesky_out.ll: cholesky.ll
	#Dale:
	$(OPT) -enable-new-pm=0 -load=/home/dalehuang/Documents/junco-compiler_assisted_checkpointing/build/lib/libSplitConditionalBB.so -split-conditional-bb -S $< -o $@

my_timer.o: ../my_timer.cpp
	$(CC) -c -o $@ $< $(CFLAGS)

local_support.o: ../local_support_cpu_sequential.cpp #../local_support_cpu.cpp
	$(CC) -c -o $@ $< $(CFLAGS)

cholesky.o: cholesky.ll  # split_cholesky_out.ll #
	$(CC) -c $< -o $@ $(CFLAGS)

ex: local_support.o cholesky.o my_timer.o
	$(CC) -o $@ $^ $(CFLAGS)

clean:
	rm -f *.o *~ ex *.ll *.json *.txt