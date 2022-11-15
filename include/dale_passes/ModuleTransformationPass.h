#ifndef _MODIFIED_VALUES_H
#define _MODIFIED_VALUES_H

#include <map>
#include <set>
#include "llvm/Pass.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"

#include "popcorn_compiler/LiveValues.h"

namespace llvm {

class ModuleTransformationPass : public ModulePass
{
public:
  static char ID;

  /**
  * Default constructor.
  */
  ModuleTransformationPass(void);

  /**
  * Default destructor.
  */
  ~ModuleTransformationPass(void) {}

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

  /*
    Is the per-function mapping of tracked values (string format) 
    obtained from the tracked values json file.
  */
  LiveValues::TrackedValuesMap_JSON FuncBBTrackedValsByName;

  LiveValues::TrackedValuesMap_JSON
  getAnalysisResultsFromJson(const std::string filename) const;

  void
  printTrackedValues(raw_ostream &O, const LiveValues::Result &LVResult) const;

  private:

  /* Maps tracked values to the checkpointed BBs*/
  typedef std::map<const BasicBlock*, std::set<const Value*>> CheckpointBBMap;

  /* Maps tracked values to the checkpointed BBs in the function */
  using CheckpointFuncBBMap = std::map<const Function*, CheckpointBBMap>;

  /* Stores Checkpoint mappings for all functions in module.*/
  CheckpointFuncBBMap CheckpointsMap;

  /* Maps value pointers to their names */
  typedef std::map<std::string, const Value*> ValuePtrsMap;

  /* Maps function ptr to the map of all values within that function*/
  using FuncValuePtrsMap = std::map<const Function*, ValuePtrsMap>;

  FuncValuePtrsMap FuncValuePtrs;

  /* Gets the map of all values seen in each function (mapped to names for fast lookup)*/
  FuncValuePtrsMap
  getFuncValuePtrsMap(Module &M, LiveValues::TrackedValuesMap_JSON &jsonMap);

  void
  printFuncValuePtrsMap(ModuleTransformationPass::FuncValuePtrsMap map, Module &M);

  /* Constructs Module-level FuncBBTrackedValsMap from live values in Json*/
  LiveValues::Result
  getFuncBBTrackedValsMap(
  const ModuleTransformationPass::FuncValuePtrsMap &funcValuePtrsMap,
  const LiveValues::TrackedValuesMap_JSON &jsonMap,
  Module &M
  );

  /**
  * Chooses BBs for checkpointing based on least number of tracked values in BB.
  * Ignores BB with 0 tracked values.
  */
  CheckpointFuncBBMap
  chooseBBWithLeastTrackedVals(const LiveValues::Result &map) const;
  /**
  * Prints the chosen checkpoint BBs and their tracked values.
  */
  void
  printCheckPointBBs(const CheckpointFuncBBMap &fBBMap,  Module &M) const;
  
  
  bool
  injectSubroutines(
    Module &M,
    ModuleTransformationPass::CheckpointFuncBBMap &checkpointsMap
  );


  /**
  * raw_ostream instance for printing live analysis output 
  */
  llvm::raw_ostream &OS = llvm::outs();
};

} /* llvm namespace */

#endif /* _MODIFIED_VALUES_H */