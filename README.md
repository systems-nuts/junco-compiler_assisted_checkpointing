# `junco-compiler_assisted_checkpointing`

## Overview:
This repository contains the source code for the compiler support component of the fine-trained CPU-FPGA task migration system. This compiler support was developed as part of an MInf Part 1 Dissertation titled "Compiler Support for Software Checkpoint-Restore for C/C++ Kernel Code, for Increased QoS in FPGA-Accelerated Systems in HPC Contexts" by Huang Zihan (University of Edinburgh) under the supervision of Dr. Maxime France-Pillois and Dr. Antonio Barbalace of ICSA, University of Edinburgh. This source code was developed under LLVM14, but is LLVM7-compatible. All commands use the Legacy Pass Manager.

## Dissertation Report:
The dissertation report accompanying this project can be found [here](documentation/s1901023_minf1_project_report_v3.pdf).

## Branches:
1. `main`: <br/> 
    * Is the most updated version of the compiler support source code.
    * llvm14 (llvm7 compatible)
    * user-directed checkpoint selection
    * selective partial insertion of save/restore infrastructure.
    * unified restoraiton policy
4. `llvm_14_ver_full_save_restore_mixed_policy_multi_ckpt_propagation`: <br/>
    * llvm14 (llvm7 compatible)
    * user-directed checkpoint selection
    * selective partial insertion of save/restore infrastructure
    * mixed restoration policy.
2. `llvm_14_ver_full_save_restore`: <br/>
    * llvm14 (llvm7 compatible)
    * user-directed checkpoint selection
    * full insertion of both save and restore infrastructure.
3. `llvm_14_ver_auto_select_ckpts`: <br/>
    * llvm14
    * auto-selection of checkpoints based on smallest live-out set size.

## Running a pass via LLVM Legacy Pass Manager:
`opt-7 -load=libLiveValues.so -live-values -disable-output <input file>`

## Generate -O0 IR with human-readable names:
1. Use the `-fno-discard-value-names` flag & the `-Xclang -disable-O0-optnone` flags, e.g.:
    `clang++ -O0 -S -emit-llvm -fno-discard-value-names fno-discard-value-names -Xclang -disable-O0-optnone <path/to/cpp/file> -o <path/to/ll/file>`
2. We generate O0 IR because our analysis pass are desgiend to use IR with alloca instructions (pre-`mem2reg`).

## Running Compiler Passes:
1. Build `junco-compiler_assisted_checkpointing`:
    1. `cd <path/to/junco-compiler_assisted_checkpointing>`
    2. `mkdir <build/dir>`
    3. `cd <build/dir>`
    4. `cmake -DLT_LLVM_INSTALL_DIR=<installation/dir/of/llvm/14> <source/dir/of/junco-compiler_assisted_checkpointing>`
    5. `make`
1. Generate IR of target `.cpp` code:
    `clang++ -O0 -S -emit-llvm -fno-discard-value-names -Xclang -disable-O0-optnone <path/to/cpp/file> -o <path/to/ll/file>`
3. Pre-split conditional branch BBs:
    1. `cd <build/dir>/lib`
    2. `opt -enable-new-pm=0 -load ./libSplitConditionalBB.so -split-conditional-bb -S <path/to/input/ll/file> -o <path/to/output/ll/file>`
4. Run liveness analysis:
    1. `cd <build/dir>/lib`
    2. `opt -enable-new-pm=0 -load ./libLiveValues.so -live-values -analyze <path/to/input/ll/file> -source <path/to/source/cpp/file/of/ll/file>`
5. Run subroutine injection:
    1. `cd <build/dir>/lib`
    2. `opt -enable-new-pm=0 -load ./libSubroutineInjection.so -subroutine-injection -S <path/to/input/ll/file> -o <path/to/output/ll/file> -source <path/to/source/cpp/file/of/ll/file> -inject <inject_option>`

    * Note: `<inject_options>` are:
        * `save`: injecting only saveBB (no propagate)
        * `restore`: injecting restoreBB and junctionBB (propagate)
        * `save_restore`: inject saveBB, restoreBB and junctionBB (propagate)

## Running CPU-only Tests:

These test examples here are pre-configured to the default test cases, and will run out of the box. To modify the test setups, modify the relevant `.h`/`.hpp` and `.cpp` files within the `junco-compiler_assisted_checkpointing/examples/<kernel>/` directories for each kernel. Also modify the `local_support` `.h`/`.cpp` files, and/or the `local_support_sequential.cpp` files for each test case, where appropriate. Refer to the `Makefile` for each test setup for information on which files are used.

### LUD CPU checkpoint-restore:
1. `cd junco-compiler_assisted_checkpointing/examples/lud_xrt/src/testing/`
2. Update paths used in `Makefile` to those used on your local machine.
3. `make clean && make`
4. `./ex`

### Blur CPU checkpoint-restore:
1. `cd junco-compiler_assisted_checkpointing/examples/blur_xrt/src/testing/`
2. Update paths used in `Makefile` to those used on your local machine.
3. `make clean && make`
4. `./ex Bridge_2200x1650.jpg`

### Cholesky CPU checkpoint-restore:
1. `cd junco-compiler_assisted_checkpointing/examples/cholesky/testing/`
2. Update paths used in `Makefile` to those used on your local machine.
3. `make clean && make`
4. `./ex`

## External Sources:
* The CMake files and high-level project directory layouts used in this repository are based on those used in https://github.com/banach-space/llvm-tutor.
* The LiveValues pass is adapted from https://github.com/ssrg-vt/popcorn-compiler.
* This project uses parts of the JsonCpp library from https://github.com/open-source-parsers/jsoncpp.