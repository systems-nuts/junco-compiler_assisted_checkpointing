/**
 * Does DFS on BB CFG for each Function in Module.
 * For each BB, finds the "modified values" that are stored within the BB via store instructions.
 * Each predecessor BB propagates its "modified values" to all its successor BBs.
 * Modified Values are stored in a map with key as BB and value as set of modified values.
 */

#include "dale_passes/TransformationPass.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/CFG.h"
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Support/Debug.h"

#include <iostream>

#define DEBUG_TYPE "transformation-pass"

using namespace llvm;

char TransformationPass::ID = 0;

// This is the core interface for pass plugins. It guarantees that 'opt' will
// recognize LegacyHelloWorld when added to the pass pipeline on the command
// line, i.e.  via '--legacy-hello-world'
static RegisterPass<TransformationPass>
    X("transformation-pass", "Transformation Pass",
      true, // This pass doesn't modify the CFG => true
      false // This pass is not a pure analysis pass => false
    );

namespace llvm {
  FunctionPass *createTransformationPass() { return new TransformationPass(); }
}

///////////////////////////////////////////////////////////////////////////////
// Public API
///////////////////////////////////////////////////////////////////////////////

TransformationPass::TransformationPass(void) : FunctionPass(ID) {}

void TransformationPass::getAnalysisUsage(AnalysisUsage &AU) const
{
  AU.addRequired<LiveValues>();
  AU.setPreservesAll();
}

bool TransformationPass::runOnFunction(Function &F)
{

    std::cout << "Transformation Pass printout" << std::endl;

    LiveValues::Result trackedValsMap = getAnalysisResults(getAnalysis<LiveValues>().getTrackedValuesMap());

    printTrackedValues(OS, trackedValsMap);

    return false;
}

LiveValues::Result
TransformationPass::getAnalysisResults(const LiveValues::Result &LVResult)
{
    return LVResult;
}

void
TransformationPass::print(raw_ostream &O, const Function *F) const
{
  // TODO: implement me!
  return;
}

void
TransformationPass::printTrackedValues(raw_ostream &O, const LiveValues::Result &LVResult) const
{
  LiveValues::Result::const_iterator funcIt;
  LiveValues::LiveVals::const_iterator bbIt;
  std::set<const Value *>::const_iterator valIt;

  O << "Results from LiveValues tracked-value analysis\n";

  for (funcIt = LVResult.cbegin(); funcIt != LVResult.cend(); funcIt++)
  {
    const Function *F = funcIt->first;
    const LiveValues::BBTrackedVals *bbTrackedVals = &funcIt->second;
    const Module *M = F->getParent();

    O << "For function " << F->getName() << ":\n";

    for (bbIt = bbTrackedVals->cbegin(); bbIt != bbTrackedVals->cend(); bbIt++)
    {
      const BasicBlock *BB = bbIt->first;
      const std::set<const Value *> &trackedVals = bbIt->second;

      O << "Results for BB ";
      BB->printAsOperand(O, false, M);
      O << ":";

      O << "\n  Tracked:\n    ";
      for(valIt = trackedVals.cbegin(); valIt != trackedVals.cend(); valIt++)
      {
        (*valIt)->printAsOperand(O, false, M);
        O << " ";
      }

      O << "\n";

    }
  }
}

///////////////////////////////////////////////////////////////////////////////
// Private API
///////////////////////////////////////////////////////////////////////////////