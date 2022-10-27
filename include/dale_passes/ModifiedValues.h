#ifndef _MODIFIED_VALUES_H
#define _MODIFIED_VALUES_H

#include <map>
#include <set>
#include "llvm/Pass.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"

namespace llvm {

class ModifiedValues : public FunctionPass
{
public:
    static char ID;

    /**
    * Default constructor.
    */
    ModifiedValues(void);

    /**
    * Default destructor.
    */
    ~ModifiedValues(void) {}

    /**
    * Register which analysis passes we need.
    * @param AU an analysis usage object
    */
    virtual void getAnalysisUsage(AnalysisUsage &AU) const;

    /**
    * Calculate modified-ness sets for a function.
    * @param F a function for which to calculate modified values.
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

    /* Store modified values for basic block. */
    typedef std::map<const BasicBlock *, std::set<const Value *>> BBModifiedVals;
    /* Store modified live values for all functions*/
    std::map<const Function *, BBModifiedVals> FuncBBModifiedVals;

    void doDFS(const Function *F);
    
    /**
    * raw_ostream instance for printing live analysis output 
    */
    llvm::raw_ostream &OS = llvm::outs();
};

} /* llvm namespace */

#endif /* _MODIFIED_VALUES_H */