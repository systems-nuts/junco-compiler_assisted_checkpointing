 /*
 * Calculate tracked-value sets for functions.
 *
 * Tracked values (for each BB) are:
 *   1. Values contained in the live-out set but not the live-in set.
 *   2. Modified values.
 *
 * Modified values (for each BB) are:
 *   1. Values involved in store operations within a BB.
 *   2. Modified values for all predecessor BBs backtrack-able from the current BB.
 *
 * Liveness-analysis is based on the non-iterative dataflow algorithm for
 * reducible graphs by Brandner et. al in:
 *
 * "Computing Liveness Sets for SSA-Form Programs"
 * URL: https://hal.inria.fr/inria-00558509v1/document
 * Accessed: 5/19/2016
 *
 * Original Author: Rob Lyerly <rlyerly@vt.edu>
 * Date: 5/19/2016
 *
 * Modified By: Dale Huang
 *
 * Run with:
 * <llvm-installation-dir>/bin/opt -enable-new-pm=0 -load \
 * <path/to/build/libs>/libTrackValues.so -track-values -analyze \
 * <path/to/input/bc/file>
 */


#include "dale_passes/TrackValues.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/CFG.h"
#include "llvm/Analysis/CFG.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/ADT/SCCIterator.h"
#include "llvm/Support/Debug.h"

#include <iostream>

#define DEBUG_TYPE "track-values"

using namespace llvm;

char TrackValues::ID = 0;

// This is the core interface for pass plugins. It guarantees that 'opt' will
// recognize LegacyHelloWorld when added to the pass pipeline on the command
// line, i.e.  via '--legacy-hello-world'
static RegisterPass<TrackValues>
    X("track-values", "Track Values Pass",
      true, // This pass doesn't modify the CFG => true
      false // This pass is not a pure analysis pass => false
    );


namespace llvm {
  FunctionPass *createTrackValuesPass() { return new TrackValues(); }
}

///////////////////////////////////////////////////////////////////////////////
// Public API
///////////////////////////////////////////////////////////////////////////////

TrackValues::TrackValues(void)
  : FunctionPass(ID), inlineasm(false), bitcasts(true), comparisons(true),
    constants(false), metadata(false) {}

void TrackValues::getAnalysisUsage(AnalysisUsage &AU) const
{
  AU.addRequired<LoopInfoWrapperPass>();
  AU.setPreservesAll();
}

// MODIFIED:
bool TrackValues::runOnFunction(Function &F)
{
  if(FuncBBLiveIn.count(&F))
  {
    std::cout << "\nFound previous analysis for TrackValues" << std::endl;
  }
  else
  {
    std::cout << "\n********** Beginning TrackValues **********\n"
              << "********** Function: TrackValues **********\n"
              << "\nTrackValues: performing bottom-up dataflow analysis\n" 
              << std::endl;

    LoopNestingForest LNF;
    FuncBBLiveIn.emplace(&F, LiveVals());
    FuncBBLiveOut.emplace(&F, LiveVals());

    /* 1. Compute partial liveness sets using a postorder traversal. */
    dagDFS(F, FuncBBLiveIn[&F], FuncBBLiveOut[&F]);

    std::cout << "TrackValues: constructing loop-nesting forest\n" << std::endl;

    /* 2. Construct loop-nesting forest. */
    constructLoopNestingForest(F, LNF);

    std::cout << "TrackValues: propagating values within loop-nests\n" << std::endl;

    /* 3. Propagate live variables within loop bodies. */
    loopTreeDFS(LNF, FuncBBLiveIn[&F], FuncBBLiveOut[&F]);

    /* 4. Get the tracked live values for each BB in this function. */
    TrackValues::getLiveValsDiff(&F);

    /* 5. Get the tracked modified values for each BB in this function. */
    TrackValues::doModifiedValsDFS(&F);

    /* 6. Merge tracked live values with tracked modified values for each BB. */
    TrackValues::mergeTrackedLiveModifiedValues(&F);

    std::cout << "TrackValues: finished analysis\n" << std::endl;

    /* Print out Live-in and Live-out results. */
    OS << "# Analysis for function '" << F.getName() << "'\n";
    TrackValues::print(OS, &F);
  }

  return false;
}

// NEW:
void
TrackValues::getLiveValsDiff(const Function *F)
{
  BBTrackedVals::const_iterator bbIt;
  std::set<const Value *>::const_iterator valIt;

  if(FuncBBLiveIn.count(F) && FuncBBLiveOut.count(F))
  {
    TrackValues::BBTrackedVals *bbTrackedVals = new TrackValues::BBTrackedVals();

    // iterate through BBs in function F
    for(bbIt = FuncBBLiveIn.at(F).cbegin();
        bbIt != FuncBBLiveIn.at(F).cend();
        bbIt++)
    {
      const BasicBlock *BB = bbIt->first;
      const std::set<const Value *> &liveInVals = bbIt->second;
      const std::set<const Value *> &liveOutVals = FuncBBLiveOut.at(F).at(BB);
      
      std::set<const Value *> *liveDiffSet = new std::set<const Value *>;
      
      // iterate through live-out vals in BB
      for(valIt = liveOutVals.cbegin(); valIt != liveOutVals.cend(); valIt++)
      {
        if (!liveInVals.count(*valIt))
        {
          // val is not in live-in set
          liveDiffSet->insert(*valIt);
        }
      }
      bbTrackedVals->emplace(BB, *liveDiffSet);
    }
    FuncBBTrackedVals.emplace(F, *bbTrackedVals);
  }
}

// NEW:
void
TrackValues::doModifiedValsDFS(const Function *F)
{
    TrackValues::BBModifiedVals *bbModifiedVals = new TrackValues::BBModifiedVals();

    // perform DFS traversal
    for (auto BB : depth_first(F))
    {
        std::set<const Value *> *modifiedVals = nullptr;
        if (bbModifiedVals->count(BB)) modifiedVals = &bbModifiedVals->at(BB);
        else modifiedVals = new std::set<const Value *>;
        
        // 1. iterate through instructions in BB to find modified vals (store instr):
        for (auto Inst = BB->begin(); Inst != BB->end(); ++Inst)
        {
            if (isa<StoreInst>(Inst))
            {
                // second operand is the stored var name.
                Value* storedVal = Inst->getOperand(1);
                modifiedVals->insert(storedVal);
            }
        }
        bbModifiedVals->emplace(BB, *modifiedVals);

        // 2. propagate modified values from this BB to successor BBs:
        for (auto sit = succ_begin(BB); sit != succ_end(BB); ++sit)
        {
            const BasicBlock *succ_BB = dyn_cast<BasicBlock>(*sit);

            // get modified vals set for succ_BB
            std::set<const Value *> *succ_modifiedVals = nullptr;
            if (bbModifiedVals->count(succ_BB)) succ_modifiedVals = &bbModifiedVals->at(succ_BB);
            else succ_modifiedVals = new std::set<const Value *>;

            // insert BB's modified vals to succ_BB's modified vals set
            succ_modifiedVals->insert(modifiedVals->begin(), modifiedVals->end());
            bbModifiedVals->emplace(succ_BB, *succ_modifiedVals);
        }
    }
    FuncBBModifiedVals.emplace(F, *bbModifiedVals);
}

// NEW:
void
TrackValues::mergeTrackedLiveModifiedValues(const Function *F)
{
  BBTrackedVals::const_iterator bbIt;

  if (FuncBBTrackedVals.count(F) && FuncBBModifiedVals.count(F))
  {
    // iterate through BBs in function F
    BBTrackedVals *bbTrackedVals = &FuncBBTrackedVals.at(F);
    for(bbIt = bbTrackedVals->cbegin();
        bbIt != bbTrackedVals->cend();
        bbIt++)
    {
      const BasicBlock *BB = bbIt->first;
      std::set<const Value *> trackedVals = bbIt->second;
      const std::set<const Value *> *modifiedVals = &FuncBBModifiedVals.at(F).at(BB);

      // merge contents of modifiedVals into trackedVals:
      trackedVals.insert(modifiedVals->begin(), modifiedVals->end());

      // emplace new trackedVals set into map:
      BBTrackedVals::iterator iter = bbTrackedVals->find(BB);
      if (iter != bbTrackedVals->end()) iter->second = trackedVals;
    }
  }
}

// MODIFIED:
void
TrackValues::print(raw_ostream &O, const Function *F) const
{
  BBTrackedVals::const_iterator bbIt;
  std::set<const Value *>::const_iterator valIt;
  const Module *M = F->getParent();

  O << "TrackValues: results of live-value analysis\n";

  if(!FuncBBLiveIn.count(F) || !FuncBBLiveOut.count(F))
  {
    if(F->hasName())
      O << "No liveness information for function " << F->getName() << "\n";
    else
      O << "No liveness information for requested function\n";
  }
  else
  {
    for(bbIt = FuncBBLiveIn.at(F).cbegin();
        bbIt != FuncBBLiveIn.at(F).cend();
        bbIt++)
    {
      const BasicBlock *bb = bbIt->first;
      const std::set<const Value *> &liveInVals = bbIt->second;
      const std::set<const Value *> &liveOutVals = FuncBBLiveOut.at(F).at(bb);

      O << "Results for BB ";
      bb->printAsOperand(O, false, M);
      O << ":";
      
      O << "\n  Live-in:\n    ";
      for(valIt = liveInVals.cbegin(); valIt != liveInVals.cend(); valIt++)
      {
        (*valIt)->printAsOperand(O, false, M);
        O << " ";
      }

      O << "\n  Live-out:\n    ";
      for(valIt = liveOutVals.cbegin(); valIt != liveOutVals.cend(); valIt++)
      {
        (*valIt)->printAsOperand(O, false, M);
        O << " ";
      }

      const std::set<const Value *> trackedVals = FuncBBTrackedVals.at(F).at(bb);
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

std::set<const Value *> *TrackValues::getLiveIn(const BasicBlock *BB) const
{
  const Function *F = BB->getParent();
  return new std::set<const Value *>(FuncBBLiveIn.at(F).at(BB));
}

std::set<const Value *> *TrackValues::getLiveOut(const BasicBlock *BB) const
{
  const Function *F = BB->getParent();
  return new std::set<const Value *>(FuncBBLiveOut.at(F).at(BB));
}

std::set<const Value *>
*TrackValues::getLiveValues(const Instruction *inst) const
{
  const BasicBlock *BB = inst->getParent();
  const Function *F = BB->getParent();
  BasicBlock::const_reverse_iterator ri, rie;
  std::set<const Value *> *live = nullptr;

  // Note: some functions have unreachable basic blocks (e.g., functions that
  // call exit and then return a value).  If we don't have analysis for the
  // block, return an empty set.
  const LiveVals &Blocks = FuncBBLiveOut.at(F);
  if(Blocks.count(BB)) live = new std::set<const Value *>(Blocks.at(BB));
  else return new std::set<const Value *>;

  for(ri = BB->rbegin(), rie = BB->rend(); ri != rie; ri++)
  {
    if(&*ri == inst) break;

    live->erase(&*ri);
    for(User::const_op_iterator op = ri->op_begin();
        op != ri->op_end();
        op++)
      if(includeVal(*op))
        live->insert(*op);
  }

  live->erase(&*ri);
  for(User::const_op_iterator op = ri->op_begin();
      op != ri->op_end();
      op++)
    if(includeVal(*op))
      live->insert(*op);

  return live;
}


///////////////////////////////////////////////////////////////////////////////
// Private API
///////////////////////////////////////////////////////////////////////////////

bool TrackValues::includeVal(const llvm::Value *val) const
{
  bool include = true;

  // TODO other values that should be filtered out?
  if(isa<BasicBlock>(val))
    include = false;
  else if(isa<InlineAsm>(val) && !inlineasm)
    include = false;
  else if(isa<BitCastInst>(val) && !bitcasts)
    include = false;
  else if(isa<CmpInst>(val) && !comparisons)
    include = false;
  else if(isa<Constant>(val) && !constants)
    include = false;
  else if(isa<MetadataAsValue>(val) && !metadata)
    include = false;

  return include;
}

unsigned TrackValues::phiUses(const BasicBlock *B,
                             const BasicBlock *S,
                             std::set<const Value *> &uses)
{
  const PHINode *phi;
  unsigned added = 0;

  for(BasicBlock::const_iterator it = S->begin(); it != S->end(); it++)
  {
    if((phi = dyn_cast<PHINode>(&*it))) {
      for(unsigned i = 0; i < phi->getNumIncomingValues(); i++)
        if(phi->getIncomingBlock(i) == B &&
           includeVal(phi->getIncomingValue(i)))
          if(uses.insert(phi->getIncomingValue(i)).second)
            added++;
    }
    else break; // phi-nodes are always at the start of the basic block
  }

  return added;
}

unsigned TrackValues::phiDefs(const BasicBlock *B,
                             std::set<const Value *> &uses)
{
  const PHINode *phi;
  unsigned added = 0;

  for(BasicBlock::const_iterator it = B->begin(); it != B->end(); it++)
  {
    if((phi = dyn_cast<PHINode>(&*it))) {
      if(includeVal(phi))
        if(uses.insert(&*it).second)
          added++;
    }
    else break; // phi-nodes are always at the start of the basic block
  }

  return added;
}

void TrackValues::dagDFS(Function &F, LiveVals &liveIn, LiveVals &liveOut)
{
  std::set<const Value *> live, phiDefined;
  std::set<Edge> loopEdges;
  SmallVector<Edge, 16> loopEdgeVec;

  /* Find loop edges & convert to set for existence checking. */
  FindFunctionBackedges(F, loopEdgeVec);
  for(SmallVectorImpl<Edge>::const_iterator eit = loopEdgeVec.begin();
      eit != loopEdgeVec.end();
      eit++)
    loopEdges.insert(*eit);

  /* Calculate partial liveness sets for CFG nodes. */
  for(auto B = po_iterator<const BasicBlock *>::begin(&F.getEntryBlock());
      B != po_iterator<const BasicBlock *>::end(&F.getEntryBlock());
      B++)
  {
    /* Calculate live-out set (lines 4-7 of Algorithm 2). */
    for(auto S = succ_begin(*B); S != succ_end(*B); S++)
    {
      // Note: skip self-loop-edges, as adding values from phi-uses of this
      // block causes use-def violations, and LLVM will complain.  This
      // shouldn't matter, as phi-defs will cover this case.
      if(*S == *B) continue;

      phiUses(*B, *S, live);
      if(!loopEdges.count(Edge(*B, *S)))
      {
        phiDefs(*S, phiDefined);
        for(std::set<const Value *>::const_iterator vi = liveIn[*S].begin();
            vi != liveIn[*S].end();
            vi++)
          if(!phiDefined.count(*vi) && includeVal(*vi)) live.insert(*vi);
        phiDefined.clear();
      }
    }
    liveOut.insert(LiveValsPair(*B, std::set<const Value *>(live)));

    /* Calculate live-in set (lines 8-11 of Algorithm 2). */
    for(BasicBlock::const_reverse_iterator inst = (*B)->rbegin();
        inst != (*B)->rend();
        inst++)
    {
      if(isa<PHINode>(&*inst)) break;

      live.erase(&*inst);
      for(User::const_op_iterator op = inst->op_begin();
          op != inst->op_end();
          op++)
        if(includeVal(*op)) live.insert(*op);
    }
    phiDefs(*B, live);
    liveIn.insert(LiveValsPair(*B, std::set<const Value *>(live)));

    live.clear();
  }
}

void TrackValues::constructLoopNestingForest(Function &F,
                                            LoopNestingForest &LNF)
{
  LoopInfo &LI = getAnalysis<LoopInfoWrapperPass>().getLoopInfo();

  for(scc_iterator<Function *> scc = scc_begin(&F);
      scc != scc_end(&F);
      ++scc)
  {
    const std::vector<BasicBlock *> &SCC = *scc;
    LNF.emplace_back(SCC, LI);

    std::cout << "Loop nesting tree: " << LNF.back().size() << " node(s), loop-nesting depth: " << LNF.back().depth() << std::endl;
  }
}

void TrackValues::propagateValues(const LoopNestingTree &loopNest,
                                 LiveVals &liveIn,
                                 LiveVals &liveOut)
{
  std::set<const Value *> liveLoop, phiDefined;

  /* Iterate over all loop nodes. */
  for(LoopNestingTree::loop_iterator loop = loopNest.loop_begin();
      loop != loopNest.loop_end();
      loop++)
  {
    /* Calculate LiveLoop (lines 3 & 4 of Algorithm 3). */
    phiDefs(*loop, phiDefined);
    for(std::set<const Value *>::const_iterator it = liveIn[*loop].begin();
        it != liveIn[*loop].end();
        it++)
      if(!phiDefined.count(*it) && includeVal(*it))
        liveLoop.insert(*it);

    /* Propagate values to children (lines 5-8 of Algorithm 3). */
    for(LoopNestingTree::child_iterator child = loopNest.children_begin(loop);
        child != loopNest.children_end(loop);
        child++) {
      for(std::set<const Value *>::const_iterator it = liveLoop.begin();
          it != liveLoop.end();
          it++) {
        liveIn[*child].insert(*it);
        liveOut[*child].insert(*it);
      }
    }

    liveLoop.clear();
  }
}

void TrackValues::loopTreeDFS(LoopNestingForest &LNF,
                             LiveVals &liveIn,
                             LiveVals &liveOut)
{
  LoopNestingForest::const_iterator it;
  for(it = LNF.begin(); it != LNF.end(); it++)
    propagateValues(*it, liveIn, liveOut);
}
