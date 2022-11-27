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
1. 

**Usage:**

**Description:**

**Constraints:**