# to be placed in the ex<num>/testing dir
# run as >> make LLVM=<path/to/llvm/install/>
# to activate index-tracking optimisation, add: OPTIM=-trackingIndex

CC=$(LLVM)/bin/clang++
# CC=$(LLVM)/bin/clang -cl-std=CL2.0 -x cl
OPT=$(LLVM)/bin/opt
CFLAGS = -pthread #-O1
# INJECT?=save_restore
OPTIM?=

# all : ex
# .PHONY : all

all: split_kernel_out_restore.ll # split_kernel_out_save.ll 

kernel.ll: /home/dale/Documents/junco-compiler_assisted_checkpointing/minimap2-fpga/src/minimap2_opencl.cpp
	$(CC) -S $< -emit-llvm -o $@ -fno-discard-value-names -Xclang -disable-O0-optnone

# split_kernel_out_save.ll: kernel.ll
# 	$(OPT) -enable-new-pm=0 -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libSplitConditionalBB.so -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libLiveValues.so -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libSubroutineInjection.so -split-conditional-bb -S $< -live-values -source /home/dale/Documents/junco-compiler_assisted_checkpointing/minimap2-fpga/src/minimap2_opencl.cpp -subroutine-injection -o $@ -inject save $(OPTIM)

split_kernel_out_restore.ll: kernel.ll
	$(OPT) -enable-new-pm=0 -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libSplitConditionalBB.so -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libLiveValues.so -load=/home/dale/Documents/junco-compiler_assisted_checkpointing/build/lib/libSubroutineInjection.so -split-conditional-bb -S $< -live-values -source /home/dale/Documents/junco-compiler_assisted_checkpointing/minimap2-fpga/src/minimap2_opencl.cpp -subroutine-injection -o $@ -inject restore

# my_timer.o: ../my_timer.cpp
# 	$(CC) -c -o $@ $< $(CFLAGS)

# stb_image_write.o: ../stb_image_write.cpp
# 	$(CC) -c -o $@ $< $(CFLAGS)

# stb_image.o: ../stb_image.cpp
# 	$(CC) -c -o $@ $< $(CFLAGS)

# local_support_cpu.o: ../local_support_cpu_sequential.cpp split_blur_out.ll  #../local_support_cpu.cpp split_blur_out.ll 
# 	python3 extract_mem_ckpt_size.py -i ckpt_sizes_bytes.json -o ../
# 	$(CC) -c -o $@ $< $(CFLAGS)

# blur.o: split_blur_out.ll
# 	$(CC) -c $< -o $@ $(CFLAGS)

# ex: local_support_cpu.o blur.o my_timer.o stb_image.o stb_image_write.o
# 	$(CC) -o $@ $^ $(CFLAGS)

clean:
	rm -f *.o *~ ex *.ll *.json *.txt out.jpg
