# `junco-compiler_assisted_checkpointing`
This repository contains the source code for the compiler support component of the fine-trained CPU-FPGA task migration system. This compiler support was developed as part of an MInf Part 1 Dissertation titled "Compiler Support for Software Checkpoint-Restore for C/C++ Kernel Code, for Increased QoS in FPGA-Accelerated
Systems in HPC Contexts" by Huang Zihan (University of Edinburgh) under the supervision of Dr. Maxime France-Pillois and Dr. Antonio Barbalace of ICSA, University of Edinburgh. This source code was developed under LLVM14, but is LLVM7-compatible. All commands use the Legacy Pass Manager.

## Branches:
1. `main`: llvm14 (llvm7 compatible); user-directed checkpoint selection, selective insertion of save/restore infrastructure. Is the most updated version of the compiler support source code. 
4. `llvm_14_ver_full_save_restore_mixed_policy_multi_ckpt_propagation`: llvm14 (llvm7 compatible); user-directed checkpoint selection, selective insertion of save/restore infrastructure, non-unified restoration policy.
2. `llvm_14_ver_full_save_restore`: llvm14 (llvm7 compatible); user-directed checkpoint selection, full insertion of both save and restore infrastructure.
3. `llvm_14_ver_auto_select_ckpts`: llvm14; auto-selection of checkpoints based on smallest live-out set size.

## Running a pass via LLVM Legacy Pass Manager:
`opt-7 -load=libLiveValues.so -live-values -disable-output <input file>`

## Generate -O0 IR with human-readable names:
1. Use the `-fno-discard-value-names` flag & the `-Xclang -disable-O0-optnone` flags, e.g.:
    `clang++ -O0 -S -emit-llvm -fno-discard-value-names fno-discard-value-names -Xclang -disable-O0-optnone <path/to/cpp/file> -o <path/to/ll/file>`
2. We generate O0 IR because our analysis pass are desgiend to use IR with alloca instructions (pre-`mem2reg`).

## Running Compiler Passes:
1. Build `junco-compiler_assisted_checkpointing`:
    1. `cd <path/to/junco-compiler_assisted_checkpointing>`
    2. `mkdir build`
    3. `cd <build/dir>`
    4. `cmake -DLT_LLVM_INSTALL_DIR=<installation/dir/of/llvm/14> <source/dir/of/junco-compiler_assisted_checkpointing>`
    5. `make`
1. Generate IR of target `.cpp` code:
    `clang++ -O0 -S -emit-llvm -fno-discard-value-names -Xclang -disable-O0-optnone <path/to/cpp/file> -o <path/to/ll/file>`
3. Pre-split conditional branch BBs:
    1. `cd build/lib`
    2. `opt -enable-new-pm=0 -load ./libSplitConditionalBB.so -split-conditional-bb -S <path/to/input/ll/file> -o <path/to/output/ll/file>`
4. Run liveness analysis:
    1. `cd build/lib`
    2. `opt -enable-new-pm=0 -load ./libLiveValues.so -live-values -analyze <path/to/input/ll/file> -source <path/to/source/cpp/file/of/ll/file>`
5. Run subroutine injection:
    1. `cd build/lib`
    2. `opt -enable-new-pm=0 -load ./libSubroutineInjection.so -subroutine-injection -S <path/to/input/ll/file> -o <path/to/output/ll/file> -source <path/to/source/cpp/file/of/ll/file> -inject <inject_option>`

    * Note: `<inject_options>` are:
        * `save`: injecting only saveBB (no propagate)
        * `restore`: injecting restoreBB and junctionBB (propagate)
        * `save_restore`: inject saveBB, restoreBB and junctionBB (propagate)

## Running Tests (CPU):

These test examples here are pre-configured to the default test cases, and will run out of the box. To modify the test setups, please edit the `local_suppport.h`, `local_support.cpp` and `local_support_sequential` files, as well as the relevant `.h`/`.hpp` and `.cpp` files within `junco-compiler_assisted_checkpointing/examples/<kernel>/src/` for each associated kernel.

### LUD:
1. `cd junco-compiler_assisted_checkpointing/examples/lud_xrt/src/testing/`
2. Update paths used in `Makefile` to those used on your local machine.
3. `make clean && make`
4. `./ex`

### Blur:
1. `cd junco-compiler_assisted_checkpointing/examples/blur_xrt/src/testing/`
2. Update paths used in `Makefile` to those used on your local machine.
3. `make clean && make`
4. `./ex Bridge_2200x1650.jpg`

### Cholesky:
1. `cd junco-compiler_assisted_checkpointing/examples/cholesky/testing/`
2. Update paths used in `Makefile` to those used on your local machine.
3. `make clean && make`
4. `./ex`