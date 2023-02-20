#include "dale_passes/StripExternalDependancies.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/CFG.h"
#include "llvm/Analysis/CFG.h"
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/Support/Debug.h"

#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Type.h"
#include "llvm/Analysis/LoopInfo.h"

#include "llvm/IR/Dominators.h" // test
#include "llvm/Transforms/Utils/Local.h"
#include "llvm/IR/Instruction.h"

#include <asm-generic/errno.h>
#include <cstddef>
#include <exception>
#include <iostream>
#include <sys/stat.h>
#include <fstream>
#include <cmath>


#define DEBUG_TYPE "module-transformation-pass"

using namespace llvm;

char StripExternalDependancies::ID = 0;

// This is the core interface for pass plugins. It guarantees that 'opt' will
// recognize LegacyHelloWorld when added to the pass pipeline on the command
// line, i.e.  via '--legacy-hello-world'
static RegisterPass<StripExternalDependancies>
    X("stripExternalDependancies", "stripExternalDependancies",
      false, // This pass does modify the CFG => false
      false // This pass is not a pure analysis pass => false
    );

namespace llvm {
  ModulePass *createStripExternalDependancies() { return new StripExternalDependancies(); }
}

///////////////////////////////////////////////////////////////////////////////
// Public API
///////////////////////////////////////////////////////////////////////////////

StripExternalDependancies::StripExternalDependancies(void) : ModulePass(ID) {}

void StripExternalDependancies::getAnalysisUsage(AnalysisUsage &AU) const
{
  AU.addRequired<DominatorTreeWrapperPass>();
}

bool StripExternalDependancies::runOnModule(Module &M)
{
  std::cout << "Module Transformation Pass printout" << std::endl;

  bool isModified = stripDependancies(M);

  return isModified;
}

void
StripExternalDependancies::print(raw_ostream &O, const Function *F) const
{
  /** TODO: implement me! */
  return;
}


int StripExternalDependancies::stripDependancies(Module &M)
{
  std::vector<std::string> depFunList;
  std::vector<Instruction*> instrList;
  depFunList.push_back(std::string("SpecArrayDimSize"));
  Function::iterator BBIter;
  for (auto &F : M.getFunctionList()){
    for (BBIter = F.begin(); BBIter != F.end(); ++BBIter){
	BasicBlock* BB = &(*BBIter);
	BasicBlock::iterator instrIter;
	for (instrIter = BB->begin(); instrIter != BB->end(); ++instrIter){
	    Instruction* I =  &(*instrIter);
	    if (auto *CB = dyn_cast<llvm::CallInst>(I)) {
	      
	      //I->print(errs());
	      //printf("\n");
	      
	      StringRef name = CB->getCalledFunction()->getName();
	      for(std::string s : depFunList){
		if (name.str().find(s) != std::string::npos) {
		  instrList.push_back(I);
		  break;
		}
	      }
	    }
	}
    }
  }
  for(Instruction* inst : instrList){
    inst->eraseFromParent();
  }
  return 1;
}
