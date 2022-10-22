#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/PassManager.h"
#include "llvm/IR/CallingConv.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IR/IRPrintingPasses.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

Module* makeLLVMModule(); // is func prototype

int main(int argc, char** argv) {

  /*
  Create an llvm module. Modules represent single units of code that will be processed together.
  A module contains things like global variables, function declarations, and implementations.
  */  
  Module* Mod = makeLLVMModule();

  /*
  Verify our newly created module.
  Verifyer will print an err msg if llvm module is malformed in any way.
  */
  // verifyModule(*Mod, PrintMessageAction);


  /* Instantiate a llvm pass manager and run the PrintModulePass on our module to print it out. */
  PassManager PM;
  PM.add(createPrintModulePass(&outs()));
  PM.run(*Mod);
}

Module* makeLLVMModule() {
  /* Instantiate a module and give it a name. */
  Modue* mod = new Module("build-mul-add-func", getGlobalContext());

  /* Construct function; returns cast of existing function if function already existed with different protoype. */
  Constant* c = mod->getOrInsertFunction("mul_add",
                                          IntegerType::get(32), // return type
                                          IntegerType::get(32), // args types
                                          IntegerType::get(32),
                                          IntegerType::get(32),
                                          NULL);                // varargs terminated with null

  // Since we know that there's not already a mul_add function, we can just safely cast c to a Function*
  Function* mul_add = cast<Function>(c);
  // Set calling convention for func to be the C calling convention to ensure it interoperates properly with c code.
  mul_add->setCallingConv(CallingConv::C);

  /*
  Give names to parameters; makes it easier to tell what's going on in the generated IR code.
  Iterate over the arguments of our function and call setName() on them.
  */
  Function::arg_iterator args_iter = mul_add->arg_begin();
  Value* x = args++;  // get ptr to arg, then post-increment arg
  x->setName("x"); 
  Value* y = args++;
  y->setName("y");
  Value* z = args++;
  z->setName("z");
  
  /* Create basic blocks to populate our function body */
  BasicBlock* block = BasicBlock::Create(getGlobalContext(), "entry", mul_add);
  IRBuilder<> builder(block); // helps with creating instructions and appending them to the end of a block.
  
  /*
  Create instructions of the basic block.
  IRBuilder gives us a simple interface for constructing these instructions and appending them to the "entry" block.
  Each call to IRBuilder returns a Value* representing the value yielded by the instruction.
  */
  Value* mul_result = builder.CreateBinOp(Instruction::Mul, x, y, "mul_result");
  Value* add_result = buider.CreateBinOp(Instruction::Add, mul_result, z, "add_result");

  builder.CreateRet(add_result);

  return mod;
}