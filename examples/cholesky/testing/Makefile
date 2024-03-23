# run as >> make LLVM=<path/to/llvm/install/>

CC=$(LLVM)/bin/clang++
OPT=$(LLVM)/bin/opt
CFLAGS = -pthread # -O0 #-O1
INJECT?=save_restore
OPTIM?= #-trackingIndex

all : ex
.PHONY : all

cholesky.ll: ../cholesky_kernel_cpu.cpp
	#Dale:
	$(CC) -S $< -emit-llvm -o $@ -fno-discard-value-names -Xclang -disable-O0-optnone

cholesky_restore.ll: ../cholesky_kernel_restore_cpu.cpp
	#Dale:
	$(CC) -S $< -emit-llvm -o $@ -fno-discard-value-names -Xclang -disable-O0-optnone

# split_cholesky_out.ll: cholesky.ll
# 	#Dale:
# 	$(OPT) -enable-new-pm=0 -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libSplitConditionalBB.so -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libLiveValues.so -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libSubroutineInjection.so -split-conditional-bb -S $< -live-values -source ../cholesky_kernel_cpu.cpp -subroutine-injection -o $@ -inject $(INJECT) $(OPTIM)

split_cholesky_out.ll: cholesky.ll
	#Dale:
	$(OPT) -enable-new-pm=0 -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libSplitConditionalBB.so -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libLiveValues.so -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libSubroutineInjection.so -split-conditional-bb -S $< -live-values -source ../cholesky_kernel_cpu.cpp -subroutine-injection -o $@ -inject save $(OPTIM)

split_cholesky_restore_out.ll: cholesky_restore.ll
	#Dale:
	$(OPT) -enable-new-pm=0 -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libSplitConditionalBB.so -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libLiveValues.so -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libSubroutineInjection.so -split-conditional-bb -S $< -live-values -source ../cholesky_kernel_restore_cpu.cpp -subroutine-injection -o $@ -inject restore

my_timer.o: ../my_timer.cpp
	$(CC) -c -o $@ $< $(CFLAGS)

local_support.o: ../local_support_cpu_sequential.cpp #../local_support_cpu.cpp
	$(CC) -c -o $@ $< $(CFLAGS)

cholesky.o: split_cholesky_out.ll
	$(CC) -c $< -o $@ $(CFLAGS)

cholesky_restore.o: split_cholesky_restore_out.ll
	$(CC) -c $< -o $@ $(CFLAGS)

# ex: local_support.o cholesky.o my_timer.o
# 	$(CC) -o $@ $^ $(CFLAGS)

ex: local_support.o cholesky.o cholesky_restore.o my_timer.o
	$(CC) -o $@ $^ $(CFLAGS)

clean:
	rm -f *.o *~ ex *.ll *.json *.txt
