# to be placed in the ex<num>/testing dir
# run as >> make LLVM=<path/to/llvm/install/>

CC=$(LLVM)/bin/clang++
OPT=$(LLVM)/bin/opt
CFLAGS = -pthread #-O1
INJECT?=save_restore

all : ex
.PHONY : all

../ir/blur.ll: ../blur.cpp
	#Dale:
	$(CC) -S $< -emit-llvm -o $@ -fno-discard-value-names -Xclang -disable-O0-optnone
	#Maxime:
	#$(CC) -S $< -emit-llvm -o $@ #-fno-discard-value-names

../ir/split_blur_out.ll: ../ir/blur.ll
	#Dale:
	$(OPT) -enable-new-pm=0 -load=/home/dalehuang/Documents/junco-compiler_assisted_checkpointing/build/lib/libSplitConditionalBB.so -load=/home/dalehuang/Documents/junco-compiler_assisted_checkpointing/build/lib/libLiveValues.so -load=/home/dalehuang/Documents/junco-compiler_assisted_checkpointing/build/lib/libSubroutineInjection.so -split-conditional-bb -S $< -live-values -source ../blur.cpp -subroutine-injection -o $@ -inject $(INJECT)
	#Maxime:
	#$(OPT) -load=/home/mfrance/hw-sw-migration/junco-compiler_assisted_checkpointing/build_llvm_7/lib/libSplitConditionalBB.so -load=/home/mfrance/hw-sw-migration/junco-compiler_assisted_checkpointing/build_llvm_7/lib/libLiveValues.so -load=/home/mfrance/hw-sw-migration/junco-compiler_assisted_checkpointing/build_llvm_7/lib/libSubroutineInjection.so -split-conditional-bb -S $< -live-values -source ../blur.cpp -subroutine-injection -o $@

my_timer.o: ../my_timer.cpp
	$(CC) -c -o $@ $< $(CFLAGS)

stb_image_write.o: ../stb_image_write.cpp
	$(CC) -c -o $@ $< $(CFLAGS)

stb_image.o: ../stb_image.cpp
	$(CC) -c -o $@ $< $(CFLAGS)

local_support_cpu.o: ../local_support_cpu_sequential.cpp ../ir/split_blur_out.ll  #../local_support_cpu.cpp ../ir/split_blur_out.ll 
	python3 extract_mem_ckpt_size.py -i ckpt_sizes_bytes.json -o ../
	$(CC) -c -o $@ $< $(CFLAGS)

blur.o: ../ir/split_blur_out.ll
	$(CC) -c $< -o $@ $(CFLAGS)

ex: local_support_cpu.o blur.o my_timer.o stb_image.o stb_image_write.o
	$(CC) -o $@ $^ $(CFLAGS)

clean:
	rm -f *.o *~ ex ../ir/* *.json *.txt
