/**
 * Does DFS on BB CFG for each Function in Module.
 * For each BB, finds the "modified values" that are stored within the BB via store instructions.
 * Each predecessor BB propagates its "modified values" to all its successor BBs.
 * Modified Values are stored in a map with key as BB and value as set of modified values.
 */

#include "dale_passes/ModuleTransformationPass.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Dominators.h" // test
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Support/Debug.h"

#include <iostream>

#define DEBUG_TYPE "module-transformation-pass"

using namespace llvm;

char ModuleTransformationPass::ID = 0;

// This is the core interface for pass plugins. It guarantees that 'opt' will
// recognize LegacyHelloWorld when added to the pass pipeline on the command
// line, i.e.  via '--legacy-hello-world'
static RegisterPass<ModuleTransformationPass>
    X("module-transformation-pass", "Module Transformation Pass",
      true, // This pass doesn't modify the CFG => true
      false // This pass is not a pure analysis pass => false
    );

namespace llvm {
  ModulePass *createModuleTransformationPass() { return new ModuleTransformationPass(); }
}

///////////////////////////////////////////////////////////////////////////////
// Public API
///////////////////////////////////////////////////////////////////////////////

ModuleTransformationPass::ModuleTransformationPass(void) : ModulePass(ID) {}

void ModuleTransformationPass::getAnalysisUsage(AnalysisUsage &AU) const
{
  AU.addRequired<LiveValues>();
  AU.addRequired<DominatorTreeWrapperPass>();
  AU.setPreservesAll();
}

bool ModuleTransformationPass::runOnModule(Module &M)
{
  std::cout << "Module Transformation Pass printout" << std::endl;

  for (auto &F : M.getFunctionList())
  {
    // DOES NOT WORK! Cuases segmentation fault.
    getAnalysis<LiveValues>();
  }

  return false;
}

LiveValues::Result
ModuleTransformationPass::getAnalysisResults(const LiveValues::Result &LVResult)
{
    return LVResult;
}

void
ModuleTransformationPass::print(raw_ostream &O, const Function *F) const
{
  // TODO: implement me!
  return;
}

void
ModuleTransformationPass::printTrackedValues(raw_ostream &O, const LiveValues::Result &LVResult) const
{
  LiveValues::Result::const_iterator funcIt;
  LiveValues::BBTrackedVals::const_iterator bbIt;
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