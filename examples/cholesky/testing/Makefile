# run as >> make LLVM=<path/to/llvm/install/>

CC=$(LLVM)/bin/clang++
OPT=$(LLVM)/bin/opt
CFLAGS = -pthread # -O0 #-O1
INJECT?=save_restore

all : ex
.PHONY : all

cholesky.ll: ../cholesky_kernel_cpu.cpp
	#Dale:
	$(CC) -S $< -emit-llvm -o $@ -fno-discard-value-names -Xclang -disable-O0-optnone
	#Maxime:
	# $(CC) -S $< -emit-llvm -o $@

split_cholesky_out.ll: cholesky.ll
	#Dale:
	$(OPT) -enable-new-pm=0 -load=/home/dalehuang/Documents/junco-compiler_assisted_checkpointing/build/lib/libSplitConditionalBB.so -load=/home/dalehuang/Documents/junco-compiler_assisted_checkpointing/build/lib/libLiveValues.so -load=/home/dalehuang/Documents/junco-compiler_assisted_checkpointing/build/lib/libSubroutineInjection.so -split-conditional-bb -S $< -live-values -source ../cholesky_kernel_cpu.cpp -subroutine-injection -o $@ -inject $(INJECT)
	#Maxime:
	# $(OPT) -load=/home/mfrance/hw-sw-migration/junco-compiler_assisted_checkpointing/build_llvm_7/lib/libSplitConditionalBB.so -load=/home/mfrance/hw-sw-migration/junco-compiler_assisted_checkpointing/build_llvm_7/lib/libLiveValues.so -load=/home/mfrance/hw-sw-migration/junco-compiler_assisted_checkpointing/build_llvm_7/lib/libSubroutineInjection.so -split-conditional-bb -S $< -live-values -source ../cholesky_kernel_cpu.cpp -subroutine-injection -o $@ -inject $(INJECT)

my_timer.o: ../my_timer.cpp
	$(CC) -c -o $@ $< $(CFLAGS)

local_support.o: ../local_support_cpu_sequential.cpp #../local_support_cpu.cpp
	$(CC) -c -o $@ $< $(CFLAGS)

cholesky.o: split_cholesky_out.ll
	$(CC) -c $< -o $@ $(CFLAGS)

ex: local_support.o cholesky.o my_timer.o
	$(CC) -o $@ $^ $(CFLAGS)

clean:
	rm -f *.o *~ ex *.ll *.json *.txt