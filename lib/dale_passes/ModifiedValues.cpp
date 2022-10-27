/**
 * Does DFS on BB CFG for each Function in Module.
 * For each BB, finds the "modified values" that are stored within the BB via store instructions.
 * Each predecessor BB propagates its "modified values" to all its successor BBs.
 * Modified Values are stored in a map with key as BB and value as set of modified values.
 */

#include "dale_passes/ModifiedValues.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/CFG.h"
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Support/Debug.h"

#include <iostream>

#define DEBUG_TYPE "modified-values"

using namespace llvm;

char ModifiedValues::ID = 0;

// This is the core interface for pass plugins. It guarantees that 'opt' will
// recognize LegacyHelloWorld when added to the pass pipeline on the command
// line, i.e.  via '--legacy-hello-world'
static RegisterPass<ModifiedValues>
    X("modified-values", "Modified Values Pass",
      true, // This pass doesn't modify the CFG => true
      false // This pass is not a pure analysis pass => false
    );

namespace llvm {
  FunctionPass *createModifiedValuesPass() { return new ModifiedValues(); }
}

///////////////////////////////////////////////////////////////////////////////
// Public API
///////////////////////////////////////////////////////////////////////////////

ModifiedValues::ModifiedValues(void) : FunctionPass(ID) {}

void ModifiedValues::getAnalysisUsage(AnalysisUsage &AU) const
{
  AU.addRequired<LoopInfoWrapperPass>();
  AU.setPreservesAll();
}

bool ModifiedValues::runOnFunction(Function &F)
{

    std::cout << "ModifiedValues pass printout" << std::endl;

    ModifiedValues::doDFS(&F);

    ModifiedValues::print(OS, &F);

    return false;
}

void
ModifiedValues::doDFS(const Function *F)
{
    ModifiedValues::ModifiedVals *bbModifiedVals = new ModifiedValues::ModifiedVals();

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
            // O << succ_BB->getName() <<  ", ";

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

void
ModifiedValues::print(raw_ostream &O, const Function *F) const
{
    ModifiedVals::const_iterator bbIt;
    std::set<const Value *>::const_iterator valIt;
    const Module *M = F->getParent();
    
    if (!FuncBBModifiedVals.count(F)) 
    {
        if (F->hasName()) 
        {
            O << "No modifiedness information for function " << F->getName() << "\n";
        }
        else
        {
            O << "No liveness information for requested function\n";
        }
    }
    else
    {
        for(bbIt = FuncBBModifiedVals.at(F).cbegin();
            bbIt != FuncBBModifiedVals.at(F).cend();
            bbIt++)
        {
            const BasicBlock *bb = bbIt->first;
            const std::set<const Value *> &modifiedVals = bbIt->second;

            O << "Results for BB ";
            bb->printAsOperand(O, false, M);
            O << ":";

            O << "\n Modified values:   \n";
            for(valIt = modifiedVals.cbegin(); valIt != modifiedVals.cend(); valIt++)
            {
                O << " ";
                (*valIt)->printAsOperand(O, false, M);
            }

            O << '\n';
        }
    }
}

///////////////////////////////////////////////////////////////////////////////
// Private API
///////////////////////////////////////////////////////////////////////////////