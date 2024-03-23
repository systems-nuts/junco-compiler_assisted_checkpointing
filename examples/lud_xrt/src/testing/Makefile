# to be placed in the ex<num>/testing dir
# run as >> make LLVM=<path/to/llvm/install/>

CC=$(LLVM)/bin/clang++
OPT=$(LLVM)/bin/opt
CFLAGS = -pthread #-O1
INJECT?=save_restore
OPTIM?= #-trackingIndex

all : ex
.PHONY : all

lud.ll: ../lud.cpp
	#Dale:
	$(CC) -S $< -emit-llvm -o $@ -fno-discard-value-names -Xclang -disable-O0-optnone

lud_restore.ll: ../lud_restore.cpp
	$(CC) -S $< -emit-llvm -o $@ -fno-discard-value-names -Xclang -disable-O0-optnone

# split_lud_out.ll: lud.ll
# 	#Dale:
# 	$(OPT) -enable-new-pm=0 -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libSplitConditionalBB.so -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libLiveValues.so -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libSubroutineInjection.so -split-conditional-bb -S $< -live-values -source ../lud.cpp -subroutine-injection -o $@ -inject $(INJECT) $(OPTIM)

split_lud_out.ll: lud.ll
	#Dale:
	$(OPT) -enable-new-pm=0 -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libSplitConditionalBB.so -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libLiveValues.so -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libSubroutineInjection.so -split-conditional-bb -S $< -live-values -source ../lud.cpp -subroutine-injection -o $@ -inject save $(OPTIM)

split_lud_restore_out.ll: lud_restore.ll
	#Dale:
	$(OPT) -enable-new-pm=0 -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libSplitConditionalBB.so -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libLiveValues.so -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libSubroutineInjection.so -split-conditional-bb -S $< -live-values -source ../lud_restore.cpp -subroutine-injection -o $@ -inject restore

my_timer.o: ../my_timer.cpp
	$(CC) -c -o $@ $< $(CFLAGS)

local_support.o: ../local_support_sequential.cpp #../local_support.cpp
	$(CC) -c -o $@ $< $(CFLAGS)

lud.o: split_lud_out.ll
	$(CC) -c $< -o $@ $(CFLAGS)

lud_restore.o: split_lud_restore_out.ll
	$(CC) -c $< -o $@ $(CFLAGS)

# ex: local_support.o lud.o my_timer.o
# 	$(CC) -o $@ $^ $(CFLAGS)

ex: local_support.o lud.o lud_restore.o my_timer.o
	$(CC) -o $@ $^ $(CFLAGS)

clean:
	rm -f *.o *~ ex *.ll *.json *.txt
