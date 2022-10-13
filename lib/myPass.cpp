#include "myPass.h"

#include "llvm/Passes/PassBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Transforms/IPO/PassManagerBuilder.h"

using namespace llvm;

// Implementing the pass
PreservedAnalyses MyPass::run(Function &F,
                                      FunctionAnalysisManager &AM) {
  errs() << F.getName() << "\n";
  return PreservedAnalyses::all();
}

// registering the pass
// PassPluginLibraryInfo is provided by llvm/Passes/PassPlugin.h
PassPluginLibraryInfo getMyPassPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "my-pass", LLVM_VERSION_STRING,
          [](PassBuilder &PB) {
            // REGISTRATION FOR "opt -passes=my-pass"
            // Register my-pass so that it can be used when
            // specifying pass pipielines with `-passes=`
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "my-pass") {
                    FPM.addPass(MyPass());
                    return true;
                  }
                  return false;
                });
          }};
}

extern "C" LLVM_ATTRIBUTE_WEAK ::llvm::PassPluginLibraryInfo
llvmGetPassPluginInfo() {
  return getMyPassPluginInfo();
}