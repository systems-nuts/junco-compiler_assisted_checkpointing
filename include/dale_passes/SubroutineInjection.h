#ifndef _SUBROUTINE_INJECTION_H
#define _SUBROUTINE_INJECTION_H

#include <map>
#include <set>
#include <limits>

#include "llvm/Pass.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Support/raw_ostream.h"

#include "popcorn_compiler/LiveValues.h"

namespace llvm {

class SubroutineInjection : public ModulePass
{
public:
  static char ID;

  /**
  * Default constructor.
  */
  SubroutineInjection(void);

  /**
  * Default destructor.
  */
  ~SubroutineInjection(void) {}

  /**
  * Register which analysis passes we need.
  * @param AU an analysis usage object
  */
  virtual void getAnalysisUsage(AnalysisUsage &AU) const;

  /**
  * Calculate modified-ness sets for a function.
  * @param M a module for which to calculate modified values.
  * @return false, always
  */
  virtual bool runOnModule(Module &M) override;

  /**
  * Print a human-readable version of the analysis.
  * @param O an output stream
  * @param F the function for which to print analysis
  */
  virtual void print(raw_ostream &O, const Function *F) const;

  /* Maps value pointers to their names */
  typedef std::map<std::string, const Value*> ValuePtrsMap;

  /* Maps function ptr to the map of all values within that function*/
  using FuncValuePtrsMap = std::map<const Function*, ValuePtrsMap>;

  FuncValuePtrsMap FuncValuePtrs;

  /*
    Is the per-function mapping of tracked values (string format) 
    obtained from the tracked values json file.
  */
  LiveValues::TrackedValuesMap_JSON FuncBBTrackedValsByName;

  LiveValues::TrackedValuesMap_JSON
  getTrackedValuesResultsFromJson(const std::string filename) const;

  LiveValues::LiveValuesMap_JSON FuncBBLiveValsByName;

  LiveValues::LiveValuesMap_JSON
  getLiveValuesResultsFromJson(const std::string filename) const;

  void
  printTrackedValues(raw_ostream &O, const LiveValues::TrackedValuesResult &LVResult) const;

private:

  /* Maps tracked values to the checkpointed BBs*/
  typedef std::map<const BasicBlock*, std::set<const Value*>> CheckpointBBMap;

  /* Maps tracked values to the checkpointed BBs in the function */
  using CheckpointFuncBBMap = std::map<const Function*, CheckpointBBMap>;

  /* Stores Checkpoint mappings for all functions in module.*/
  CheckpointFuncBBMap CheckpointsMap;

  /* Gets the map of all values seen in each function (mapped to names for fast lookup)*/
  FuncValuePtrsMap
  getFuncValuePtrsMap(Module &M, LiveValues::TrackedValuesMap_JSON &jsonMap);

  /* Return true if this is the entry block of the containing function.
  * This method can only be used on blocks that have a parent function. 
  * @param B BasicBlock to analyze
  */
  bool isEntryBlock(const BasicBlock* BB) const;

  /* Set every incoming value(s) for block BB to V.
  */
  void setIncomingValueForBlock(PHINode *phi, const BasicBlock *BB, Value *V);

  /* Return true if this block has N predecessors or more. 
  */
  bool hasNPredecessorsOrMore(const BasicBlock* BB, unsigned N);

  template <typename IterTy, typename Pred = bool (*)(const decltype(*std::declval<IterTy>()) &)>
    bool hasNItemsOrMore(IterTy &&Begin, IterTy &&End, unsigned N, Pred &&ShouldBeCounted = [](const decltype(*std::declval<IterTy>()) &) { return true; }, std::enable_if_t<!std::is_base_of<std::random_access_iterator_tag, typename std::iterator_traits<std::remove_reference_t<decltype(Begin)>>::iterator_category>::value, void> * = nullptr) {
    for (; N; ++Begin) {
      if (Begin == End)
        return false; // Too few.
      N -= ShouldBeCounted(*Begin);
    }
  return true;
  };

  void
  printFuncValuePtrsMap(SubroutineInjection::FuncValuePtrsMap map, Module &M);

  long unsigned int
  getMaxNumOfTrackedValsForBBs(LiveValues::BBTrackedVals &bbTrackedVals) const;

  /**
  * Filters for BBs that only have one successor.
  */
  LiveValues::BBTrackedVals
  getBBsWithOneSuccessor(LiveValues::BBTrackedVals bbTrackedVals) const;

  /**
  * Chooses BBs for checkpointing based on least number of tracked values in BB.
  * Only considers BBs with at least minValsCount number of tracked values.
  */
  CheckpointBBMap
  chooseBBWithLeastTrackedVals(LiveValues::BBTrackedVals bbTrackedVals, Function *F,
                              long unsigned int minValsCount) const;

  /**
  * Chooses BB for checkpointing if it contains the `checkpoint()` function call.
  */
  CheckpointBBMap
  chooseBBWithCheckpointDirective(LiveValues::BBTrackedVals bbTrackedVals, Function *F) const;
  
  /**
  * Prints the chosen checkpoint BBs and their tracked values.
  */
  void
  printCheckPointBBs(const CheckpointFuncBBMap &fBBMap,  Module &M) const;

  /**
  * Gets the Value* for the float pointer to ckpt memory segment `float *<segment_name>`
  */
  Value *
  getCkptMemSegmentPtr(Function *F, StringRef segment_name, Type *type) const;

  /**
  * Get list of successor BBs for given BB
  */
  std::vector<BasicBlock *>
  getBBPredecessors(BasicBlock *BB) const;

  /**
  * Get list of successor BBs for given BB 
  */
  std::vector<BasicBlock *>
  getBBSuccessors(BasicBlock *BB) const;

  /**
  * Get list of successor BBs for given BB that are not exit blocks
  */
  std::vector<BasicBlock *>
  getNonExitBBSuccessors(BasicBlock *BB) const;

  /**
  * Get the entry and checkpoint BBs for the given function.
  */
  std::set<BasicBlock*>
  getCkptBBsInFunc(Function *F, CheckpointBBMap &bbCheckpoints) const;

  /**
  * Attempt to find the corresponding compare instruction for the given conditional branch instruction.
  * Returns null if compare instruction not found.
  */
  Instruction *
  getCmpInstForCondiBrInst(Instruction *condiBranchInst, Module &M) const;

  /**
  * Inserts saveBB on edge between startBB and endBB
  */
  BasicBlock*
  splitEdgeWrapper(BasicBlock *edgeStartBB, BasicBlock *edgeEndBB, std::string nameSuffix, Module &M) const;

  /**
  * Stores Basic Blocks that are part of subroutine inserted for CheckpointBB:
  * 1. checkpointBB
  * 2. saveBB
  * 3. restoreBB 
  * 4. junctionBB
  */
  typedef struct {
    BasicBlock *checkpointBB;
    BasicBlock *saveBB;
    BasicBlock *restoreBB;
    BasicBlock *junctionBB;
    BasicBlock *resumeBB;
  } CheckpointTopo;

  /**
  * Maps checkpoint ID to Checkpoint Topo struct
  */
  typedef std::map<uint8_t, SubroutineInjection::CheckpointTopo> CheckpointIdBBMap;

  /**
  * Allocates Checkpoint IDs to Checkpoints.
  */
  CheckpointIdBBMap
  getCheckpointIdBBMap(
    std::map<BasicBlock *, SubroutineInjection::CheckpointTopo> &checkpointBBTopoMap,
    Module &M
  ) const;

  void
  printCheckpointIdBBMap(SubroutineInjection::CheckpointIdBBMap map, Function *F);

  /**
  * For each module, selects and constructs additional BBs for checkpointing & restoration:
  * 0. Obtains candidate checkpoint BBs.
  * 1. Get pointers to entry BB and checkpoint BBs.
  * 2. Add block on exit edge of entry block that leads to computation.
  * 3. Add saveBB on exit edge of checkpointed block.
  * 4. Add restoreBBs and junctionBBs for each checkpointed block.
  * 5. Add checkpointIDs to saveBBs and restoreBBs.
  * 6. Populate saveBB and restoreBB with load and store instructions.
  * 7. Propagate loaded values from restoreBB across CFG.
  * 8. Populate restoreControllerBB with switch instructions.
  */
  bool
  injectSubroutines(
    Module &M,
    const LiveValues::TrackedValuesResult &funcBBTrackedValsMap,
    const LiveValues::LivenessResult &funcBBLiveValsMap
  );

  /**
  * Propagate loaded values from restoreBB across CFG to restore
  * Values while maintaining SSA form.
  */
  void
  propagateRestoredValuesBFS(BasicBlock *startBB, BasicBlock *prevBB, Value *oldVal, Value *newVal,
                            std::set<BasicBlock *> *newBBs,
                            // std::set<BasicBlock *> *visitedBBs,
                            std::map<BasicBlock *, std::set<Value *>> *visitedBBs,
                            const LiveValues::LivenessResult &funcBBLiveValsMap,
                            std::map<BasicBlock *, std::set<const Value *>> &funcSaveBBsLiveOutMap,
                            std::map<BasicBlock *, std::set<const Value *>> &funcRestoreBBsLiveOutMap,
                            std::map<BasicBlock *, std::set<const Value *>> &funcJunctionBBsLiveOutMap);

  typedef struct {
    BasicBlock *startBB;
    BasicBlock *currBB;
    BasicBlock *prevBB;   // is the direct previous BB that was processed
    Value *oldVal;
    Value *newVal;        // is the value that we want to propagate
    // keeps track of existing propagated verions of the current trackedVal in the current "path/branch" of traversal 
    std::set<Value *> valueVersions; 
  } BBUpdateRequest;

  void
  processUpdateRequest(BBUpdateRequest updateRequest,
                      std::queue<BBUpdateRequest> *q,
                      std::set<BasicBlock *> *newBBs,
                      // std::set<BasicBlock *> *visitedBBs,
                      std::map<BasicBlock *, std::set<Value *>> *visitedBBs,
                      const LiveValues::LivenessResult &funcBBLiveValsMap,
                      std::map<BasicBlock *, std::set<const Value *>> &funcSaveBBsLiveOutMap,
                      std::map<BasicBlock *, std::set<const Value *>> &funcRestoreBBsLiveOutMap,
                      std::map<BasicBlock *, std::set<const Value *>> &funcJunctionBBsLiveOutMap);

  void
  updateMapEntry(BasicBlock *key, std::set<Value *> newVal, std::map<BasicBlock *, std::set<Value *>> *map);

  /**
  * Gets value for corresponding key in map.
  * If key is not in map, a key-value entry is initialised and added to map; value is empty set.
  */
  std::set<Value *>
  getOrDefault(BasicBlock *key, std::map<BasicBlock *, std::set<Value *>> *map);

  /**
  * Counts how many of BB's predecessors has val in their live-out set
  */
  unsigned
  numOfPredsWhereVarIsLiveOut(BasicBlock *BB, Value *val, const LiveValues::LivenessResult &funcBBLiveValsMap,
                              std::map<BasicBlock *, std::set<const Value *>> &funcSaveBBsLiveOutMap,
                              std::map<BasicBlock *, std::set<const Value *>> &funcRestoreBBsLiveOutMap,
                              std::map<BasicBlock *, std::set<const Value *>> &funcJunctionBBsLiveOutMap);

  /**
  * Checks if currBB contains a phi instruction with incoming entry [value, prevBB],
  * where value is in valueVersions (i.e. value is a version of the currently-tracked value)
  */
  bool
  isPhiInstExistForIncomingBBForTrackedVal(std::set<Value *> valueVersions, BasicBlock *currBB, BasicBlock *prevBB);

  /**
  * Checks if val is an operand of a phi instruction in BB.
  */
  bool
  isPhiInstForValExistInBB(Value *val, BasicBlock *BB);

  /**
  * Replaces occurrences of oldVal in inst to newVal.
  * Returns true if replacement has occured.
  */
  bool
  replaceOperandsInInst(Instruction *inst, Value *oldVal, Value *newVal);

  BasicBlock*
  SplitEdgeCustom(BasicBlock *BB, BasicBlock *Succ, DominatorTree *DT, LoopInfo *LI) const;

  /**
  * raw_ostream instance for printing live analysis output 
  */
  llvm::raw_ostream &OS = llvm::outs();
};

} /* llvm namespace */

#endif /* _SUBROUTINE_INJECTION_H */
