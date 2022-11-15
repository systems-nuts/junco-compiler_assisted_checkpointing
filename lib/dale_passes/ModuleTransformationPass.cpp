/**
 * Does DFS on BB CFG for each Function in Module.
 * For each BB, finds the "modified values" that are stored within the BB via store instructions.
 * Each predecessor BB propagates its "modified values" to all its successor BBs.
 * Modified Values are stored in a map with key as BB and value as set of modified values.
 *
 * To Run:
 * $ opt -enable-new-pm=0 -load /path/to/build/lib/libModuleTransformationPass.so `\`
 *   -module-transformation-pass -S /path/to/input/IR.ll -o /path/to/output/IR.ll
 */

#include "dale_passes/ModuleTransformationPass.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Dominators.h" // test
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Support/Debug.h"

#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/IR/IRBuilder.h"

#include <iostream>
#include <sys/stat.h>
#include <fstream>

#define DEBUG_TYPE "module-transformation-pass"

using namespace llvm;

char ModuleTransformationPass::ID = 0;

// This is the core interface for pass plugins. It guarantees that 'opt' will
// recognize LegacyHelloWorld when added to the pass pipeline on the command
// line, i.e.  via '--legacy-hello-world'
static RegisterPass<ModuleTransformationPass>
    X("module-transformation-pass", "Module Transformation Pass",
      false, // This pass does modify the CFG => false
      false // This pass is not a pure analysis pass => false
    );

namespace llvm {
  ModulePass *createModuleTransformationPass() { return new ModuleTransformationPass(); }
}

///////////////////////////////////////////////////////////////////////////////
// Public API
///////////////////////////////////////////////////////////////////////////////

ModuleTransformationPass::ModuleTransformationPass(void) : ModulePass(ID) {}

void ModuleTransformationPass::getAnalysisUsage(AnalysisUsage &AU) const
{
}

bool ModuleTransformationPass::runOnModule(Module &M)
{
  std::cout << "Module Transformation Pass printout" << std::endl;

  // load Tracked values analysis results.
  FuncBBTrackedValsByName = getAnalysisResultsFromJson("tracked_values.json");
  LiveValues::printJsonMap(FuncBBTrackedValsByName);

  std::cout << "===========\n";

  FuncValuePtrs = getFuncValuePtrsMap(M, FuncBBTrackedValsByName);
  printFuncValuePtrsMap(FuncValuePtrs, M);

  LiveValues::Result funcBBTrackedValsMap = getFuncBBTrackedValsMap(FuncValuePtrs, FuncBBTrackedValsByName, M);
  
  CheckpointsMap = chooseBBWithLeastTrackedVals(funcBBTrackedValsMap);
  printCheckPointBBs(CheckpointsMap, M);

  bool isModified = injectSubroutines(M, CheckpointsMap);


  // return false;
  return isModified;
}


LiveValues::TrackedValuesMap_JSON
ModuleTransformationPass::getAnalysisResultsFromJson(const std::string filename) const
{
  Json::Value root; // root will contain the root value
  LiveValues::TrackedValuesMap_JSON jsonMap;
  struct stat buffer;
  if (stat (filename.c_str(), &buffer) == 0) {
    // file exists; open json file
    std::cout << "JSON File Exists\n";
    std::ifstream json_file(filename, std::ifstream::binary);
    json_file >> root;
    LiveValues::loadTrackedValuesJsonObjToJsonMap(root, jsonMap);
  } else {
    // file does not exist; make new json file
    std::cout << "JSON File does not exist\n";
    throw std::runtime_error("Required JSON file " + filename + " does not exist!");
  }
  return jsonMap;
}

void
ModuleTransformationPass::print(raw_ostream &O, const Function *F) const
{
  // TODO: implement me!
  return;
}

void
ModuleTransformationPass::printTrackedValues(raw_ostream &O, const LiveValues::Result &LVResult) const
{
  LiveValues::Result::const_iterator funcIt;
  LiveValues::BBTrackedVals::const_iterator bbIt;
  std::set<const Value *>::const_iterator valIt;

  O << "Results from LiveValues tracked-value analysis\n";

  for (funcIt = LVResult.cbegin(); funcIt != LVResult.cend(); funcIt++)
  {
    const Function *F = funcIt->first;
    const LiveValues::BBTrackedVals *bbTrackedVals = &funcIt->second;
    const Module *M = F->getParent();

    O << "For function " << F->getName() << ":\n";

    for (bbIt = bbTrackedVals->cbegin(); bbIt != bbTrackedVals->cend(); bbIt++)
    {
      const BasicBlock *BB = bbIt->first;
      const std::set<const Value *> &trackedVals = bbIt->second;

      O << "Results for BB ";
      BB->printAsOperand(O, false, M);
      O << ":";

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

///////////////////////////////////////////////////////////////////////////////
// Private API
///////////////////////////////////////////////////////////////////////////////

bool
ModuleTransformationPass::injectSubroutines(
  Module &M,
  ModuleTransformationPass::CheckpointFuncBBMap &checkpointsMap
)
{
  bool isModified = false;
  for (auto &F : M.getFunctionList())
  {
    if (!checkpointsMap.count(&F))
    {
      std::cerr << "No BB Checkpointing data for '" << LiveValues::getFuncOperandName(&F, &M) << "'\n";
      continue;
    }
    CheckpointBBMap bbCheckpoints = checkpointsMap.at(&F);

    // get pointer to Entry BB and checkpoint BBs
    std::cout << "Checkpoint BBs: \n";
    BasicBlock* entryBBPtr;
    std::set<BasicBlock*> checkpointBBPtrSet;
    Function::iterator funcIter;
    for (funcIter = F.begin(); funcIter != F.end(); ++funcIter)
    {
      BasicBlock* bb_ptr = &(*funcIter);
      if (bb_ptr->isEntryBlock())
      {
        entryBBPtr = bb_ptr;
      }
      if (bbCheckpoints.count(bb_ptr))
      {
        checkpointBBPtrSet.insert(bb_ptr);
        std::cout<<LiveValues::getBBOperandName(bb_ptr, &M)<<"\n";
      }
    }

    // add block on exit edge of entry block that leads to computation
    std::vector<BasicBlock *> usefulSuccessorsList;
    for (auto sit = succ_begin(entryBBPtr); sit != succ_end(entryBBPtr); ++sit)
    {
      BasicBlock *successor = *sit;
      const Instruction *TI = successor->getTerminator();
      int grandChildCount = TI->getNumSuccessors();
      if (grandChildCount > 0)
      {
        usefulSuccessorsList.push_back(successor);
      }
    }
    for (uint32_t i = 0; i < usefulSuccessorsList.size(); i ++)
    {
      // Insert the new block into the edge between thisBB and a successorBB:
      BasicBlock *insertedBB = SplitEdge(entryBBPtr, usefulSuccessorsList[i]);
      if (!insertedBB)
      {
        // SplitEdge can fail, e.g. if the successor is a landing pad
        std::cerr << "Split-edge failed between BB{" 
                  << LiveValues::getBBOperandName(entryBBPtr, &M) 
                  << "} and BB{" 
                  << LiveValues::getBBOperandName(usefulSuccessorsList[i], &M)
                  <<"}\n";
      // TODO: figure out what to do here
      }
      else
      {
        isModified = true;
        // Put instructions into new BB
        BasicBlock::iterator IP = insertedBB->getFirstInsertionPt();
        IRBuilder<> Builder(&(*IP));
      }
    }

    // add block on exit edge of checkpointed block
    for (auto itr : checkpointBBPtrSet)
    {
      BasicBlock *checkpointBBPtr = &(*itr);
      std::vector<BasicBlock *> checkpointBBSuccessorsList;
      for (auto sit = succ_begin(checkpointBBPtr); sit != succ_end(checkpointBBPtr); ++sit)
      {
        BasicBlock *successor = *sit;
        checkpointBBSuccessorsList.push_back(successor);
      }
      for (uint32_t i = 0; i < checkpointBBSuccessorsList.size(); i ++)
      {
        // Insert the new block into the edge between thisBB and a successorBB:
        BasicBlock *insertedBB = SplitEdge(checkpointBBPtr, checkpointBBSuccessorsList[i]);
        if (!insertedBB)
        {
          // SplitEdge can fail, e.g. if the successor is a landing pad
          std::cerr << "Split-edge failed between BB{" 
                    << LiveValues::getBBOperandName(checkpointBBPtr, &M) 
                    << "} and BB{" 
                    << LiveValues::getBBOperandName(checkpointBBSuccessorsList[i], &M)
                    <<"}\n";
          // TODO: figure out what to do here
        }
        else
        {
          isModified = true;
          // Put instructions into new BB
          BasicBlock::iterator IP = insertedBB->getFirstInsertionPt();
          IRBuilder<> Builder(&(*IP));
        }
      }
      break;  // DO THIS FOR ONLY ONE CHKPT BB FOR NOW
    }
  }

  return isModified;
}

LiveValues::Result
ModuleTransformationPass::getFuncBBTrackedValsMap(
  const ModuleTransformationPass::FuncValuePtrsMap &funcValuePtrsMap,
  const LiveValues::TrackedValuesMap_JSON &jsonMap,
  Module &M
)
{
  LiveValues::Result funcBBTrackedValsMap;
  for (auto &F : M.getFunctionList())
  {
    std::string funcName = LiveValues::getFuncOperandName(&F, &M);
    std::cout<<"\n"<<funcName<<":\n";
    if (jsonMap.count(funcName) && funcValuePtrsMap.count(&F))
    {
      // std::cout<<LiveValues::getFuncOperandName(&F, &M)<<"\n";
      ValuePtrsMap valuePtrsMap = funcValuePtrsMap.at(&F);
      LiveValues::BBTrackedVals_JSON bbTrackedVals_json = jsonMap.at(funcName);
      LiveValues::BBTrackedVals bbTrackedValsMap;
      Function::iterator bbIter;
      for (bbIter = F.begin(); bbIter != F.end(); ++bbIter)
      {
        const BasicBlock* bbPtr = &(*bbIter);
        std::string bbName = LiveValues::getBBOperandName(bbPtr, &M);
        std::cout<<"  "<<bbName<<":\n   ";
        std::set<const Value*> trackedVals;
        if (bbTrackedVals_json.count(bbName))
        {
          // get names of tracked values in this BB from json map
          std::set<std::string> trackedVals_json = bbTrackedVals_json.at(bbName);
          std::set<std::string>::const_iterator valIt;
          for (valIt = trackedVals_json.cbegin(); valIt != trackedVals_json.cend(); valIt++)
          {
            std::string valName = *valIt;
            if (valuePtrsMap.count(valName))
            {
              // get pointers to values corresponding to value name
              const Value* valPtr = valuePtrsMap.at(valName);
              trackedVals.insert(valPtr);
              std::cout<<LiveValues::getValueOperandName(valPtr, &M)<< " ";
            }
          }
          std::cout<<"\n";
        }
        bbTrackedValsMap.emplace(bbPtr, trackedVals);
      }
      std::cout<<"\n";
      funcBBTrackedValsMap.emplace(&F, bbTrackedValsMap);
    }
    else
    {
      std::cerr << "No tracked values analysis data for '" << funcName << "'\n";
    }
  }
  return funcBBTrackedValsMap;
}


ModuleTransformationPass::FuncValuePtrsMap
ModuleTransformationPass::getFuncValuePtrsMap(Module &M, LiveValues::TrackedValuesMap_JSON &jsonMap)
{
  ModuleTransformationPass::FuncValuePtrsMap funcValuePtrsMap;
  for (auto &F : M.getFunctionList())
  {
    std::string funcName = LiveValues::getFuncOperandName(&F, &M);
    if (!jsonMap.count(funcName))
    {
      std::cerr << "No BB Analysis data for function '" << funcName << "'\n";
      continue;
    }
    LiveValues::BBTrackedVals bbTrackedVals;
    
    // std::set<const Value*> valuePtrsSet;
    std::map<std::string, const Value*> valuePtrsMap;

    Function::iterator bbIter;
    for (bbIter = F.begin(); bbIter != F.end(); ++bbIter)
    {
      const BasicBlock* bbPtr = &(*bbIter);
      std::set<const Value*> trackedVals;
      BasicBlock::const_iterator instrIter;
      for (instrIter = bbPtr->begin(); instrIter != bbPtr->end(); ++instrIter)
      {
        User::const_op_iterator operand;
        for (operand = instrIter->op_begin(); operand != instrIter->op_end(); ++operand)
        {
          const Value *valuePtr = *operand;
          std::string valName = LiveValues::getValueOperandName(valuePtr, &M);

          // valuePtrsSet.insert(valuePtr);
          valuePtrsMap.emplace(valName, valuePtr);
        }
      }
    }
    funcValuePtrsMap.emplace(&F, valuePtrsMap);
  }
  /*  FOR TESTING: CHECK THAT SIZE OF POINTERS SET == SIZE OF POINTERS MAP (i.e. all Value pointers in Func are unique) */
  // for (auto value : valuePtrsSet)
  // {
  //   std::string valName = LiveValues::getValueOperandName(value, &M);
  //   std::cout << valName << " ";
  // }
  // std::cout << "## size = " << valuePtrsSet.size() << "\n";
  // std::cout<<"\n";
  return funcValuePtrsMap;
}

void
ModuleTransformationPass::printFuncValuePtrsMap(ModuleTransformationPass::FuncValuePtrsMap map, Module &M)
{
  ModuleTransformationPass::FuncValuePtrsMap::const_iterator iter;
  for (iter = map.cbegin(); iter != map.cend(); ++iter)
  {
    const Function *func = iter->first;
    std::map<std::string, const Value*> valuePtrsMap = iter->second;
    std::cout << func->getName().str() << ":\n";

    std::map<std::string, const Value*>::iterator it;
    for (it = valuePtrsMap.begin(); it != valuePtrsMap.end(); ++it)
    {
      std::string valName = it->first;
      const Value* valPtr = it->second;
      std::cout << "  " << valName << " {" << LiveValues::getValueOperandName(valPtr, &M) << "}\n";
    }
    // std::cout << "## size = " << valuePtrsMap.size() << "\n";
  }

}

ModuleTransformationPass::CheckpointFuncBBMap
ModuleTransformationPass::chooseBBWithLeastTrackedVals(const LiveValues::Result &map) const
{ 
  CheckpointFuncBBMap cpFuncBBMap;
  
  LiveValues::Result::const_iterator funcIter;
  for (funcIter = map.cbegin(); funcIter != map.cend(); funcIter++)
  {
    CheckpointBBMap cpBBMap;
    const Function *funcPtr = funcIter->first;
    LiveValues::BBTrackedVals bbTrackedVals = funcIter->second;

    // Find min number of live values that is > 0 (search across all BBs)
    auto minElem = std::min_element(bbTrackedVals.cbegin(), bbTrackedVals.cend(),
                    [](const auto &a,
                       const auto &b)
                       {
                        // return true if a < b:
                        // ignore entry blocks
                        if (a.first->isEntryBlock()) return false;
                        if (b.first->isEntryBlock()) return true;
                        // ignore blocks with no tracked values
                        if (a.second.size() == 0) return false;
                        if (b.second.size() == 0) return true;
                        return a.second.size() < b.second.size();
                       });

    std::cout << "(" << funcPtr->getName().str() << " BB minSize=" << (minElem->second).size() << ")\n";
    auto minSize = (minElem->second).size();
    if (minSize != 0)
    {
      // For each BB with this number of live values, add entry into cpBBMap.
      LiveValues::BBTrackedVals::const_iterator bbIt;
      for (bbIt = bbTrackedVals.cbegin(); bbIt != bbTrackedVals.cend(); bbIt++)
      {
        const BasicBlock *bbPtr = bbIt->first;
        const std::set<const Value *> &trackedVals = bbIt->second;
        // get element of trackedVals with smallest set size
        if (trackedVals.size() == minSize)
        {
          cpBBMap.emplace(bbPtr, trackedVals);
        }
      }
    } // emplace empty map if no BBs in func have live values.
    cpFuncBBMap.emplace(funcPtr, cpBBMap);
  }
  return cpFuncBBMap;
}

void
ModuleTransformationPass::printCheckPointBBs(const CheckpointFuncBBMap &fBBMap, Module &M) const
{
  CheckpointFuncBBMap::const_iterator funcIt;
  CheckpointBBMap::const_iterator bbIt;
  std::set<const Value *>::const_iterator valIt;
  for (funcIt = fBBMap.cbegin(); funcIt != fBBMap.cend(); funcIt++){
    const Function *funcPtr = funcIt->first;
    const CheckpointBBMap bbMap = funcIt->second;

    std::cout << "Checkpoint candidate BBs for '" << LiveValues::getFuncOperandName(funcPtr, &M) << "':\n";
    for (bbIt = bbMap.cbegin(); bbIt != bbMap.cend(); bbIt++)
    {
      const BasicBlock *bbPtr = bbIt->first;
      const std::set<const Value *> vals = bbIt->second;
      std::cout << "  BB: " << LiveValues::getBBOperandName(bbPtr, &M) << "\n    ";
    
      for (valIt = vals.cbegin(); valIt != vals.cend(); valIt++)
      {
        const Value *valPtr = *valIt;
        std::cout << LiveValues::getValueOperandName(valPtr, &M) << " ";
      }
      std::cout << '\n';
    }
    std::cout << "\n";
  }

  return;
}