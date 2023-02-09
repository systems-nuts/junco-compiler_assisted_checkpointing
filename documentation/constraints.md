# Constraints for llvm-dale.

## 0. IR code requirements:
- All passes here are designed for IR that's generated with textual labels for Value names.
- Flag to add to clang command: `-fno-discard-value-names`.

## 1. `SplitConditionalBB.cpp`

**Type:**
Transformation pass (Legacy Pass; FunctionPass).

**Function:**
Splits basic blocks with more than one successor into two basic blocks.

**Usage:**
To be used *prior* to liveness analysis.
- Liveness-analysis will be performed on the output of `SplitConditionalBB.cpp`.

**Description:**
- Targets basic blocks with more than one successor, e.g. basic blocks with conditional branches, switch statements, etc.
- Basic block will be split into Upper and Lower blocks such that:
    * Upper Block: contains all IR *before* the compare/branch/switch instructions
    * Lower Block: contains *only* the compare/branch/switch instructions.
- If a Basic Block `%bb` with more than one successor is chosen as a checkpoint BB candidate, then we would need to inject its `saveBB` after the "computation" part of `%bb` but before the switch/branching part. We would thus need to split `%bb` up into two parts, `%bb-upper` and `%bb-lower`.
- This BB splitting is performed prior to liveness-analysis so that any `Value`s internal to `%bb` that are not live-out for `%bb` can be exposed as live-out for `%bb-upper`. This allows us to inject `save` instructions for them in the corresponding `saveBB`.
- It's possible to instead perform the splitting operation *after* the liveness-analysis, but it will require us to process `bb-lower`'s instructions as a "special case", which is less systematic and potentially less maintainable.

**Constraints:**
1. Only performs splits for conditional branches. Will look specifically for `icmp`/`fcmp` and conditional `br` instructions. `bb-lower` will contain these compare and branch instructions. Does not work with other terminator instructions e.g. switch instructions.
2. If `splitBasicBlock` method fails for a BB, this BB will be ignored.

## 2. `LiveValues.cpp`

**Type:**
Analysis Pass (Legacy Pass; FunctionPass).

**Function:**
1. Performs liveness-analysis on input IR files.
2. For each basic block in function, collates set of tracked-values based on the live-in and live-out results. Tracked-values are the set of `Values` that we will save/load for each BB.
3. Writes tracked-values results into temporary JSON file.

**Usage:**
- To be used *after* BB splitting and *prior* to subroutine injection.
- Generated JSON file will be consumed by `SubroutineInjection.cpp`.
- JSON files generated from this analysis pass must be removed from the directory before the pass is run again for a different .ll file.

**Description:**

**Constraints:**
1. Implements liveness-analysis algorithm that only works with reducable CFGs. Does not work with irreducible CFGs.
2. `Function`s, `BasicBlock`s and `Value`s are written to JSON by their *operand name* (as displayed in the IR). This requires the operand names to: 
    1. Be unique within the `Function`'s scope.
    2. Remain consistent after liveness-analysis and before subroutine injection.
(Since `SubroutineInjection.cpp` uses the JSON of operand names to re-construct the "Func-BB-TrackedVals" nested map of pointers *before* any transformation is performed on the CFG, and transformation is performed using pointers, any changes in operand name due to transformation will likely not be an issue.)
3. If input param to kernel/task functions in `kernel.cpp` must specify array size in the function description. e.g. `int task(float mem_ckpt[1024]) {...}` instead of `int task(float *mem_ckpt) {...}`.
4. Users need to provide the source code file path when calling the pass, i.e. `-source <path/to/source/cpp/file/of/input/ll/file>` 
6. In kernel source code, users must specify the length of arrays in **numbers**, e.g. `int arr[1024]`, because the size is calculated by parsing this param signature as a string and running `stoi("1024")`.
7. Pass must be used with -O0 optimisation level IR because it uses alloca instructions to determine Value size. (MFP: With -O1 arrays still use alloca. So only the retrieving of single element variable must be adapted to be -O1 compatible). 
8. Every time the pass is used with a new `input.ll` file, we need to delete live_values.json and tracked_values.json generated from the previous `input.ll` file. => Can delete from within `SubroutineInjection`

## 3. `SubroutineInjection.cpp`

**Type:**
Transformation Pass (Legacy Pass; ModulePass).

**Function:**
1. Reconstructs liveness-analysis results (map of pointers) from `LiveValues.cpp` for entire module.
2. Chooses Basic Blocks for checkpointing (currently based on smallest number of tracked Values).
3. Inserts custom subroutines into CFG: restoreControllerBB, saveBB, restoreBB, etc.

**Usage:**
- To be used *after* running `LiveValues.cpp` to completion.

**Description:**
1. Only BBs with 1 successor are considered for checkpointing.
2. Inserts checkpoints after BBs with the `checkpoint()` directive.
3. For each checkpointBB, inserts saveBB, restoreBB & junctionBB.
4. Inserts restoreControllerBB after entry block of function.
5. ~~Writes `isComplete=1` to checkpoint memory segment at each exit block of function. Can choose to run llvm `-mergereturn` pass (before `SplitConditionalBB.cpp`) to unify function exit nodes such that each function only has 1 exit BB.~~
6. If Value name `== "ckpt_mem"`, it will be ignored from checkpointing (will not be saved/restored). 
7. If Value is a nested pointer type with name that contains substring `ckpt_mem` (e.g. `i32** ckpt_mem.addr`), it will be ignored from checkpointing (will not be saved/restored).

**Constraints:**
1. Only considers functions with `ckpt_mem[<mem_size>]` as function parameter.
2. Only considers BBs with one successor as checkpoint BB candidates.
3. Does not consider functions with total of one BB (after split) for checkpointing.
4. If SplitEdge fails for BB, then this BB will no longer be used for checkpointing.
5. If subroutine insertion fails for selected checkpointBB, then no checkpoints will be inserted.
7. Propagation algorithm currently only works with 1 checkpoint.
8. Users need to provide the source code file path when calling the pass, i.e. `-source <path/to/source/cpp/file/of/input/ll/file>` as variable sizes are re-calculated to find sizes of non-tracked values.
9. Currently tested to work with 1-D arrays using memcpy. Have not confirmed that this method will work for n-dimensional arrays. Serialisation of n-dimensional array contents into 1-D ckpt_mem_seg is possible, but this mechanism has not been implemented yet. Alterantively, we could require the programmer to express n-dimensional arrays as a pseudo-multidimensional array using a simple 1-D array (pre-serialised); this has not been tested with our code yet.
10. Function parameters can be part of the set of saved/restored values. In this case, function parameters cannot be manually overridden to have different values in different instances of execution (e.g. on different threads) of the same function. 
