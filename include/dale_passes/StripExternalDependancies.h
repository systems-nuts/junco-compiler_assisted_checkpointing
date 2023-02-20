#ifndef _LOG_MEM_WRITES_H
#define _LOG_MEM_WRITES_H

#include <map>
#include <set>
#include <limits>

#include "llvm/Pass.h"
#include "llvm/IR/DerivedTypes.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Support/raw_ostream.h"


namespace llvm {

class StripExternalDependancies : public ModulePass
{
public:
  static char ID;

  /**
  * Default constructor.
  */
  StripExternalDependancies(void);

  /**
  * Default destructor.
  */
  ~StripExternalDependancies(void) {}

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

private:
  
  int stripDependancies(Module &M);

};

} /* llvm namespace */

#endif /* _LOG_MEM_WRITES_H */
