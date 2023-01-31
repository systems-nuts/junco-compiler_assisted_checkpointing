# llvm-dale
For MInf LLVM Stuff

## Run legacy pass:
`opt-7 -load=libLiveValues.so -live-values -disable-output <input file>`

## Generate IR with human-readable names:
Use the `-fno-discard-value-names` flag, e.g.:
`clang -O1 -S -emit-llvm -fno-discard-value-names <path/to/cpp/file> -o <path/to/ll/file>`

## Running instructions:
0. Build llvm-dale:
    1. `cd <build/dir>`
    2. `cmake -DLT_LLVM_INSTALL_DIR=<installation/dir/of/llvm/14> <source/dir/llvm/dale>`
    3. `make`
1. Pre-split conditional branch BBs:
    `opt -enable-new-pm=0 -load ./libSplitConditionalBB.so -split-conditional-bb -S <path/to/input/ll/file> -o <path/to/output/ll/file>`
2. Run liveness analysis:
    `opt -enable-new-pm=0 -load ./libLiveValues.so -live-values -analyze <path/to/input/ll/file> -source <path/to/source/cpp/file/of/ll/file>`
3. Run subroutine injection:
    `opt -enable-new-pm=0 -load ./libSubroutineInjection.so -subroutine-injection -S <path/to/input/ll/file> -o <path/to/output/ll/file>`

