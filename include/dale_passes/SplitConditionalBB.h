#ifndef _SPLIT_CONDITIONAL_BB_H
#define _SPLIT_CONDITIONAL_BB_H

#include <map>
#include <set>
#include "llvm/Pass.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"

#include "popcorn_compiler/LiveValues.h"

namespace llvm {

class SplitConditionalBB : public FunctionPass
{
public:
  static char ID;

  /**
  * Default constructor.
  */
  SplitConditionalBB(void);

  /**
  * Default destructor.
  */
  ~SplitConditionalBB(void) {}

  /**
  * Register which analysis passes we need.
  * @param AU an analysis usage object
  */
  virtual void getAnalysisUsage(AnalysisUsage &AU) const;

  /**
  * Calculate modified-ness sets for a function.
  * @param F a function for which to perform transformation.
  * @return false, always
  */
  virtual bool runOnFunction(Function &F) override;

  /**
  * Print a human-readable version of the analysis.
  * @param O an output stream
  * @param F the function for which to print analysis
  */
  virtual void print(raw_ostream &O, const Function *F) const;

  private:

  std::vector<BasicBlock *>
  getBBsInFunction(Function *F) const;

  /**
  * Attempt to find the corresponding compare instruction for the given conditional branch instruction.
  * Returns null if compare instruction not found.
  */
  Instruction *
  getCmpInstForCondiBrInst(Instruction *condiBranchInst, Module *M) const;

  /**
  * Spits BBs with conditional branches into two BBs.
  * Lower half will only contain the icmp/fcmp and br instructions.
  */
  bool
  splitCondiBranchBBs(Function *F);

  /**
  * raw_ostream instance for printing live analysis output 
  */
  llvm::raw_ostream &OS = llvm::outs();
};

} /* llvm namespace */

#endif /* SPLIT_CONDITIONAL_BB */

