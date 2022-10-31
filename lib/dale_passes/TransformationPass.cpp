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

    LiveValues::Result trackedValsMap = getAnalysis<LiveValues>().getTrackedValuesMap();
    printTrackedValues(OS, trackedValsMap);

    TransformationPass::CheckpointBBMap checkPtBBMap = chooseBBWithLeastTrackedVals(&F, trackedValsMap);
    printCheckPointBBs(OS, &F, checkPtBBMap);

    return false;
}


TransformationPass::CheckpointBBMap
TransformationPass::chooseBBWithLeastTrackedVals(Function *F, const LiveValues::Result &LVResult) const
{ 
  TransformationPass::CheckpointBBMap *cpBBMap = new CheckpointBBMap();

  if (LVResult.count(F))
  {
    LiveValues::BBTrackedVals bbTrackedVals = LVResult.at(F);

    // Find min number of live values that is > 0 (search across all BBs)
    auto minElem = std::min_element(bbTrackedVals.cbegin(), bbTrackedVals.cend(),
                    [](const auto &a,
                       const auto &b)
                       {
                        // return true if a < b
                        if (a.second.size() == 0) return false;
                        if (b.second.size() == 0) return true;
                        return a.second.size() < b.second.size();
                       });

    std::cout << "(minSize=" << (minElem->second).size() << ")\n";
    auto minSize = (minElem->second).size();
    // return empty map if no BBs have live values.
    if (minSize == 0) return *cpBBMap; 

    // For each BB with this number of live values, add entry into cpBBMap.
    LiveValues::BBTrackedVals::const_iterator bbIt;
    std::set<const Value *>::const_iterator valIt;
    for (bbIt = LVResult.at(F).cbegin(); bbIt != LVResult.at(F).cend(); bbIt++)
    {
      const BasicBlock *BB = bbIt->first;
      const std::set<const Value *> &trackedVals = bbIt->second;
      // get element of trackedVals with smallest set size
      if (trackedVals.size() == minSize)
      {
        cpBBMap->emplace(BB, trackedVals);
      }
    }
  }
  return *cpBBMap;
}


void
TransformationPass::print(raw_ostream &O, const Function *F) const
{
  // TODO: implement me!
  return;
}

void
TransformationPass::printCheckPointBBs(raw_ostream &O, Function *F, const TransformationPass::CheckpointBBMap map) const
{
  CheckpointBBMap::const_iterator bbIt;
  std::set<const Value *>::const_iterator valIt;
  const Module *M = F->getParent();

  O << "Checkpoint candidate BBs: \n";
  for (bbIt = map.cbegin(); bbIt != map.cend(); bbIt++)
  {
    const BasicBlock *BB = bbIt->first;
    const std::set<const Value *> vals = bbIt->second;
    O << "  BB: ";
    BB -> printAsOperand(O, false, M);
    O << "\n    ";
  
  for (valIt = vals.cbegin(); valIt != vals.cend(); valIt++)
    {
      (*valIt)->printAsOperand(O, false, M);
      O << " ";
    }
    O << "\n";
  }
  O << "\n";
  
  return;
}

void
TransformationPass::printTrackedValues(raw_ostream &O, const LiveValues::Result &LVResult) const
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

    O << "\n## For function " << F->getName() << ":\n";

    for (bbIt = bbTrackedVals->cbegin(); bbIt != bbTrackedVals->cend(); bbIt++)
    {
      const BasicBlock *BB = bbIt->first;
      const std::set<const Value *> &trackedVals = bbIt->second;

      O << "Results for BB ";
      BB->printAsOperand(O, false, M);
      O << ":";

      O << "\n  Tracked Value:\n    ";
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