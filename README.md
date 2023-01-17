# llvm-dale
For MInf LLVM Stuff

## Run legacy pass:
`opt-7 -load=libLiveValues.so -live-values -disable-output <input file>`

## Generate IR with human-readable names:
Use the `-fno-discard-value-names` flag, e.g.:
`clang -O1 -S -emit-llvm -fno-discard-value-names blur.cpp -o <path/to/ll/file>`

