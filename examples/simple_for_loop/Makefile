CC=$(LLVM)/bin/clang++
OPT=$(LLVM)/bin/opt
CFLAGS = -pthread -O1
INJECT?=save_restore

all : ex
.PHONY : all

foo.ll: ./foo.cpp
	$(CC) -S $< -emit-llvm -o $@ -fno-discard-value-names -Xclang -disable-O0-optnone

split_foo_out.ll: ./foo.ll
	$(OPT) -enable-new-pm=0 -load=/home/dalehuang/Documents/llvm-dale/build/lib/libSplitConditionalBB.so -load=/home/dalehuang/Documents/llvm-dale/build/lib/libLiveValues.so -load=/home/dalehuang/Documents/llvm-dale/build/lib/libSubroutineInjection.so -split-conditional-bb -S $< -live-values -source ./foo.cpp -subroutine-injection -o $@ -inject $(INJECT)

foo.o: ./split_foo_out.ll
	$(CC) -c $< -o $@ $(CFLAGS)

ex: ./foo.o
	$(CC) -o $@ $^ $(CFLAGS)

clean:
	rm -f *.o *~ ex *.ll *.json