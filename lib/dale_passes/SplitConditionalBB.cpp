/*
 * Split BBs with more than one successor into separate BBs.
 * First half will contain all computation before the conditional branch.
 * Second half will the icmp/fcmp and conditional br instructions.
 * Do not consider entry blocks.
 *
 * To Run:
 * $ opt -enable-new-pm=0 -load /path/to/build/lib/libSplitConditionalBB.so `\`
 *   -split-conditional-bb -S /path/to/input/IR.ll -o /path/to/output/IR.ll
*/

#include "dale_passes/SplitConditionalBB.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/CFG.h"
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Support/Debug.h"

#include <iostream>

#define DEBUG_TYPE "split-conditional-bb-pass"

using namespace llvm;

char SplitConditionalBB::ID = 0;

// This is the core interface for pass plugins. It guarantees that 'opt' will
// recognize SplitConditionalBB when added to the pass pipeline on the command
// line, i.e.  via '--transformation-pass'
static RegisterPass<SplitConditionalBB>
    X("split-conditional-bb", "Split Conditional BBs Pass",
      false, // This pass modifies the CFG => false
      false // This pass is not a pure analysis pass => false
    );

namespace llvm {
  FunctionPass *createSplitConditionalBB() { return new SplitConditionalBB(); }
}

///////////////////////////////////////////////////////////////////////////////
// Public API
///////////////////////////////////////////////////////////////////////////////

SplitConditionalBB::SplitConditionalBB(void) : FunctionPass(ID) {}

void SplitConditionalBB::getAnalysisUsage(AnalysisUsage &AU) const
{
}

bool SplitConditionalBB::runOnFunction(Function &F)
{
  // Check function linkage
  // We do not analyze external functions
  if(F.getLinkage() == F.LinkOnceODRLinkage)
    return false;
  
  std::cout << "SplitConditionalBB Pass printout" << std::endl;
  std::cout << "Transforming function '" << JsonHelper::getOpName(&F, F.getParent()) << "':\n";
  bool isModified = splitCondiBranchBBs(&F);
  return isModified;
}

void
SplitConditionalBB::print(raw_ostream &O, const Function *F) const
{
  // TODO: implement me!
  return;
}


///////////////////////////////////////////////////////////////////////////////
// Private API
///////////////////////////////////////////////////////////////////////////////

bool SplitConditionalBB::isEntryBlock(const BasicBlock* BB) const {
   const Function *F = BB->getParent();
   assert(F && "Block must have a parent function to use this API");
   return BB == &F->getEntryBlock();
}

/**
  TODO: Currently works for conditional branches ONLY!
        Does not yet work for switch, indirectBr, etc.
*/
bool
SplitConditionalBB::splitCondiBranchBBs(Function *F)
{
  bool isModified = false;

  Module *M = F->getParent();
  std::vector<BasicBlock *> originalFuncBBs = getBBsInFunction(F);
  // std::cout<<"### originalFuncBBs size = "<<originalFuncBBs.size()<<std::endl;

  for(long unsigned int i = 0; i < originalFuncBBs.size(); i ++)
  {
    BasicBlock* BB = originalFuncBBs[i];
    std::cout<<"##"<<JsonHelper::getOpName(BB, M)<<"\n";
    Instruction *terminator_instr = BB->getTerminator();
    if (!isEntryBlock(BB) && BB->getTerminator()->getNumSuccessors() > 1)
    {
      // is a conditional terminator (branches to 2 BBs)
      Instruction *cmp_instr = getCmpInstForCondiBrInst(terminator_instr, M);
      if (cmp_instr == nullptr) continue;  // could not resolve condi branch split; ignore this BB
      
      // NOTE: splitBlock does not preserve any passes. to split blocks while keeping loop information consistent, use the SplitBlock utility function
      std::string newBBName = JsonHelper::getOpName(BB, M).erase(0,1) + ".lower";
      BasicBlock *splitBBSecondPart = BB->splitBasicBlock(cmp_instr, newBBName);
      if (!splitBBSecondPart)
      {
        // SplitEdge can fail, e.g. if the successor is a landing pad
        std::cerr << "Split-Basic-Block failed for BB{" 
                  << JsonHelper::getOpName(BB, M) 
                  << "}\n";
        // Don't insert BB if it fails, if this causes 0 ckpts to be added, then choose ckpt of a larger size)
        continue;
      }
      else
      {
        std::string topHalfBBName = JsonHelper::getOpName(BB, M).erase(0,1) + ".upper";
        dyn_cast<Value>(BB)->setName(topHalfBBName);
        isModified = true;
      }
    }
  }
  return isModified;
}

std::vector<BasicBlock *>
SplitConditionalBB::getBBsInFunction(Function *F) const
{
  std::vector<BasicBlock *> list;
  Function::iterator iter;
  for(iter = F->begin(); iter != F->end(); ++iter)
  {
    BasicBlock* BB = &*iter;
    list.push_back(BB);
  }
  return list;
}

/** TODO: remove Module param when removing print statement */
Instruction *
SplitConditionalBB::getCmpInstForCondiBrInst(Instruction *condiBranchInst, Module *M) const
{
  Value *condition = dyn_cast<BranchInst>(condiBranchInst)->getCondition();
  std::cout<<JsonHelper::getOpName(condition, M)<<"\n";
  Instruction *cmp_instr = nullptr;
  Instruction *instr = condiBranchInst;
  while(cmp_instr == nullptr)
  {
    // attempt to find branch instr's corresponding cmp instr
    instr = instr->getPrevNode();
    
    if (instr == nullptr) break;  // have reached list head; desired cmp instr not found
    
    Value *instr_val = dyn_cast<Value>(instr);
    std::cout << "?" << JsonHelper::getOpName(instr_val, M) << "\n";
    if ((isa <ICmpInst> (instr) || isa <FCmpInst> (instr)) && instr == condition)
    {
      cmp_instr = instr;
    }
  }
  // if cannot find compare inst, then just split directly before branch inst
  if (cmp_instr == nullptr) cmp_instr = condiBranchInst;
  return cmp_instr;
}
