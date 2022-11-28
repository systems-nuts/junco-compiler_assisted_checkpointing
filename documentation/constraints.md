# Constraints for llvm-dale.

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
  - Upper Block: contains all IR *before* the compare/branch/switch instructions
  - Lower Block: contains *only* the compare/branch/switch instructions.
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
- Generated JSON file will be consumed by `ModuleTransformationPass.cpp`.

**Description:**

**Constraints:**
1. `Function`s, `BasicBlock`s and `Value`s are written to JSON by their *operand name* (as displayed in the IR). This requires the operand names to: 
  1. Be unique within the `Function`'s scope.
  2. Remain consistent after liveness-analysis and before subroutine injection.
(Since `ModuleTransformationPass.cpp` uses the JSON of operand names to re-construct the "Func-BB-TrackedVals" nested map of pointers *before* any transformation is performed on the CFG, and transformation is performed using pointers, any changes in operand name due to transformation will likely not be an issue.)

## 3. `ModuleTransformationPass.cpp`

**Type:**
Transformation Pass (Legacy Pass; ModulePass).

**Function:**
1. Reconstructs liveness-analysis results (map of pointers) from `LiveValues.cpp` for entire module.
2. Chooses Basic Blocks for checkpointing (currently based on smallest number of tracked Values).
3. Inserts custom subroutines into CFG: restoreControllerBB, saveBB, restoreBB, etc.

**Usage:**
- To be used *after* running `LiveValues.cpp` to completion.

**Description:**
1. If BB is an entry block, it is not considered for checkpointing.
2. Only BBs with 1 successor are considered for checkpointing.
3. Chooses checkpoint BB candidates based on the number of tracked values a BB has.
  1. Say we have a found a set `K` of checkpoint BBs with at least `x` tracked values, each with `y = x + 2` tracked values.
  2. For any BB `bb` in set `K`: if subroutine injection fails for `bb`, then `bb` is ignored.
  3. If subroutine injection fails for all BBs in set `K`, then we retry with a new set of checkpoint BBs with at least `y + 1` tracked values.
  4. Will stop retrying when `y` reaches the maximum number of tracked values for any BB in the function. In this case, no checkpoints will be inserted for this function.

**Constraints:**
1. Only considers BBs with one successor as checkpoint BB candidates.
2. If SplitEdge fails for BB, then this BB will no longer be used for checkpointing.
3. If subroutine insertion fails for all checkpoint BB candidates in a set of BBs with at least `x` tracked values, then the algorithm will retry with a new set of checkpoint candidate BBs that have at least `x+1` tracked values. 