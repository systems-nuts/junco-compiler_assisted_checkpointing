//========================================================================
// FILE:
//    InjectFuncCall.cpp
//
// DESCRIPTION:
//    For each function defined in the input IR module, InjectFuncCall inserts
//    a call to printf (from the C standard I/O library). The injected IR code
//    corresponds to the following function call in ANSI C:
//    ```C
//      printf("(llvm-tutor) Hello from: %s\n(llvm-tutor)   number of arguments: %d\n",
//             FuncName, FuncNumArgs);
//    ```
//    This code is inserted at the beginning of each function, i.e. before any
//    other instruction is executed.
//
//    To illustrate, for `void foo(int a, int b, int c)`, the code added by InjectFuncCall
//    will generated the following output at runtime:
//    ```
//    (llvm-tutor) Hello World from: foo
//    (llvm-tutor)   number of arguments: 3
//    ```
//
// USAGE:
//    2. New pass maanger:
//      $ opt -load-pass-plugin <BUILD_DIR>/lib/libInjectFunctCall.so `\`
//        -passes=-"inject-func-call" <bitcode-file>
//
// License: MIT
//========================================================================
#include "llvm_tutor_passes/InjectFuncCall.h"

#include "llvm/IR/IRBuilder.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Passes/PassBuilder.h"

using namespace llvm;

#define DEBUG_TYPE "inject-func-call"

//-----------------------------------------------------------------------------
// InjectFuncCall implementation
//-----------------------------------------------------------------------------
// contains the main logic of the pass
bool InjectFuncCall::runOnModule(Module &M) {
  bool InsertedAtLeastOnePrintf = false;

  auto &CTX = M.getContext();
  // construct a pointer to an obj of the specified type (int8) in the default address space
  PointerType *PrintfArgTy = PointerType::getUnqual(Type::getInt8Ty(CTX));

  // STEP 1: Inject the declaration of printf
  // ----------------------------------------
  // Create (or _get_ in cases where it's already available) the following
  // declaration in the IR module:
  //    declare i32 @printf(i8*, ...)
  // It corresponds to the following C declaration:
  //    int printf(char *, ...)
  FunctionType *PrintfTy = FunctionType::get( // construct a FunctionType (pointer to a func)
      IntegerType::getInt32Ty(CTX),
      PrintfArgTy,
      /*IsVarArgs=*/true);
  // FunctionCallee is a container for the FunctionType + Callee-pointer pair
  FunctionCallee Printf = M.getOrInsertFunction("printf", PrintfTy);

  // Set attributes as per inferLibFuncAttributes in BuildLibCalls.cpp
  Function *PrintfF = dyn_cast<Function>(Printf.getCallee()); // gets FunctionCallee ptr and casts to Function ptr
  PrintfF->setDoesNotThrow();
  PrintfF->addParamAttr(0, Attribute::NoCapture); // adds attribute to the list of attributes for the given argNo.
  PrintfF->addParamAttr(0, Attribute::ReadOnly);


  // STEP 2: Inject a global variable that will hold the printf format string
  // ------------------------------------------------------------------------
  // construct a ConstantDataSequence and inits it with given text string (our format string).
  // ConstantDataArray class is a subclass of ConstantDataSequence 
  llvm::Constant *PrintfFormatStr = llvm::ConstantDataArray::getString(
      CTX, "(llvm-tutor) Hello from: %s\n(llvm-tutor)   number of arguments: %d\n");

  // gets/inserts a global variable to store the format string
  Constant *PrintfFormatStrVar =
      M.getOrInsertGlobal("PrintfFormatStr", PrintfFormatStr->getType());
  dyn_cast<GlobalVariable>(PrintfFormatStrVar)->setInitializer(PrintfFormatStr);

  // STEP 3: For each function in the module, inject a call to printf
  // ----------------------------------------------------------------
  for (auto &F : M) {
    // ignore declarations
    if (F.isDeclaration())
      continue;

    // Get an IR builder. Sets the insertion point to the top of the function
    IRBuilder<> Builder(&*F.getEntryBlock().getFirstInsertionPt());

    // Inject a global variable that contains the function name
    auto FuncName = Builder.CreateGlobalStringPtr(F.getName());

    // Printf requires i8*, but PrintfFormatStrVar is an array: [n x i8]. Add
    // a cast: [n x i8] -> i8*
    llvm::Value *FormatStrPtr = Builder.CreatePointerCast(PrintfFormatStrVar, PrintfArgTy, "formatStr");

    // The following is visible only if you pass -debug on the command line
    // *and* you have an assert build.
    LLVM_DEBUG(dbgs() << " Injecting call to printf inside " << F.getName()
                      << "\n");

    // Finally, inject a call to printf
    Builder.CreateCall(Printf, {FormatStrPtr, FuncName, Builder.getInt32(F.arg_size())});

    InsertedAtLeastOnePrintf = true;
  }

  return InsertedAtLeastOnePrintf;
}

// this is the pass "wrapper" that calls runOnModule
PreservedAnalyses InjectFuncCall::run(llvm::Module &M,
                                       llvm::ModuleAnalysisManager &) {
  bool Changed = runOnModule(M);

  // returns whether the code has been changed or not
  return (Changed ? llvm::PreservedAnalyses::none()
                  : llvm::PreservedAnalyses::all());
}

//-----------------------------------------------------------------------------
// New PM Registration
//-----------------------------------------------------------------------------
llvm::PassPluginLibraryInfo getInjectFuncCallPluginInfo() {
  return {LLVM_PLUGIN_API_VERSION, "inject-func-call", LLVM_VERSION_STRING,
          [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, ModulePassManager &MPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                  if (Name == "inject-func-call") {
                    MPM.addPass(InjectFuncCall());
                    return true;
                  }
                  return false;
                });
          }};
}

extern "C" LLVM_ATTRIBUTE_WEAK ::llvm::PassPluginLibraryInfo
llvmGetPassPluginInfo() {
  return getInjectFuncCallPluginInfo();
}
