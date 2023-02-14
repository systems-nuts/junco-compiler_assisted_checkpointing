# to be placed in the ex<num>/testing dir
# run as >> make LLVM=<path/to/llvm/install/>

CC=$(LLVM)/bin/clang++
OPT=$(LLVM)/bin/opt
CFLAGS = -pthread

all : ex
.PHONY : all

../ir/lud.ll: ../lud.cpp
	$(CC) -S $< -emit-llvm -o $@ #-fno-discard-value-names

../ir/split_lud_out.ll: ../ir/lud.ll
	$(OPT) -load=/home/mfrance/hw-sw-migration/llvm-dale/build_llvm_7/lib/libSplitConditionalBB.so -load=/home/mfrance/hw-sw-migration/llvm-dale/build_llvm_7/lib/libLiveValues.so -load=/home/mfrance/hw-sw-migration/llvm-dale/build_llvm_7/lib/libSubroutineInjection.so -split-conditional-bb -S $< -live-values -source ../lud.cpp -subroutine-injection -o $@

local_support.o: ../local_support.cpp
	$(CC) -c -o $@ $< $(CFLAGS)

lud.o: ../ir/split_lud_out.ll
	$(CC) -c $< -o $@

ex: local_support.o lud.o
	$(CC) -o $@ $^ $(CFLAGS)

clean:
	rm -f *.o *~ ex ../ir/*
