# llvm-dale
For MInf LLVM Stuff
## Branches:
1. `main`: llvm14 (llvm7 compatible); selective insertion of save or restore infrastructure.
2. `llvm_14_ver_full_save_restore`: llvm14 (llvm7 compatible); full insertion of both save and restore infrastructure.
3. `llvm_14_ver_auto_select_ckpts`: llvm14; auto-selection of checkpoints based on smallest live-out set size.

## Run legacy pass:
`opt-7 -load=libLiveValues.so -live-values -disable-output <input file>`

## Generate -O0 IR with human-readable names and which allow later optimisations:
1. Use the `-fno-discard-value-names` flag & the `-Xclang -disable-O0-optnone` flags, e.g.:
    `clang++ -O0 -S -emit-llvm -fno-discard-value-names fno-discard-value-names -Xclang -disable-O0-optnone <path/to/cpp/file> -o <path/to/ll/file>`
2. We generate O0 IR because our analysis pass are desgiend to use IR with alloca instructions (pre-`mem2reg`).

## Running instructions:
0. Build llvm-dale:
    1. `cd <build/dir>`
    2. `cmake -DLT_LLVM_INSTALL_DIR=<installation/dir/of/llvm/14> <source/dir/llvm/dale>`
    3. `make`
1. Generate IR of target `.cpp` code:
    `clang++ -O0 -S -emit-llvm -fno-discard-value-names -Xclang -disable-O0-optnone <path/to/cpp/file> -o <path/to/ll/file>`
2. Run -mergereturn to unify function exit nodes such that each function only has 1 exit node:
    `$LLVM/bin/opt -enable-new-pm=0 -mergereturn -S <path/to/input/ll/file> -o <path/to/output/ll/file>`~~
3. Pre-split conditional branch BBs:
    `opt -enable-new-pm=0 -load ./libSplitConditionalBB.so -split-conditional-bb -S <path/to/input/ll/file> -o <path/to/output/ll/file>`
4. Run liveness analysis:
    `opt -enable-new-pm=0 -load ./libLiveValues.so -live-values -analyze <path/to/input/ll/file> -source <path/to/source/cpp/file/of/ll/file>`
5. Run subroutine injection:
    `opt -enable-new-pm=0 -load ./libSubroutineInjection.so -subroutine-injection -S <path/to/input/ll/file> -o <path/to/output/ll/file> -source <path/to/source/cpp/file/of/ll/file> -inject <inject_option>`

    1. `<inject_options>` are:
        1. `save`: injecting only saveBB (no propagate)
        2. `restore`: injecting restoreBB and junctionBB (propagate)
        3. `save_restore`: inject saveBB, restoreBB and junctionBB (propagate)

