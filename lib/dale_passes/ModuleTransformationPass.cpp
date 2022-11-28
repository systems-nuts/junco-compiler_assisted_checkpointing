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

#include <cstddef>
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

  bool isModified = injectSubroutines(M, funcBBTrackedValsMap);

  // printCheckPointBBs(CheckpointsMap, M);

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
  /** TODO: implement me! */
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
  const LiveValues::Result &map
)
{
  bool isModified = false;
  for (auto &F : M.getFunctionList())
  {
    std::string funcName = LiveValues::getFuncOpName(&F, &M);
    std::cout << "Function " << funcName << " ==== \n";
    if (!map.count(&F))
    {
      std::cout << "No BB tracked values data for '" << funcName << "'\n";
      continue;
    }

    bool hasInjectedSubroutinesForFunc = false;
    long unsigned int defaultMinValsCount = 3;  // set to 3 to test response for split BB
    long unsigned int maxTrackedValsCount = getMaxNumOfTrackedValsForBBsInFunc(&F, map);

    // get vars for instruction building
    LLVMContext &context = F.getContext();
    IRBuilder<> builder(context);

    while(!hasInjectedSubroutinesForFunc && defaultMinValsCount <= maxTrackedValsCount)
    {
      // ## 0: get candidate checkpoint BBs
      std::cout<< "##minValsCount=" << defaultMinValsCount << "\n";
      // filter for BBs that only have one successor.
      LiveValues::Result filteredMap = getBBsWithOneSuccessor(map);
      CheckpointBBMap bbCheckpoints = chooseBBWithLeastTrackedVals(filteredMap, &F, defaultMinValsCount);
      
      if (bbCheckpoints.size() == 0)
      {
        // could not find any BBs with at least defaultMinValsCount tracked values.
        std::cout << "Function '" << funcName
                  << "': could not find any BBs with at least "
                  << defaultMinValsCount << " tracked values. Ignore function.\n";
        break;
      }
      int currMinValsCount = bbCheckpoints.begin()->second.size();
      std::cout<< "#currNumOfTrackedVals=" << currMinValsCount << "\n";

      // ## 1: get pointers to Entry BB and checkpoint BBs
      std::cout << "Checkpoint BBs: \n";
      std::pair<BasicBlock*, std::set<BasicBlock*>> p = getEntryAndCkptBBsInFunc(&F, bbCheckpoints);
      BasicBlock* entryBB = p.first;
      std::set<BasicBlock*> checkpointBBPtrSet = p.second;

      // ## 2. Add block on exit edge of entry block that leads to computation
      BasicBlock *restoreControllerBB = nullptr;
      std::vector<BasicBlock *> usefulSuccessorsList = getNonExitBBSuccessors(entryBB);
      for (uint32_t i = 0; i < usefulSuccessorsList.size(); i ++)
      {
        // Insert the new block into the edge between thisBB and a successorBB:
        BasicBlock *successorBB = usefulSuccessorsList[i];
        std::string restoreControllerBBName = funcName + ".restoreControllerBB";
        restoreControllerBB = splitEdgeWrapper(entryBB, successorBB, restoreControllerBBName, M);
        if (restoreControllerBB)
        {
          isModified = true;
        }
        else
        {
          // Split-edge fails for adding BB after function entry block => skip this function
          continue;
        }
      }

      // ## 3. Add saveBB on exit edge of checkpointed block
      std::map<BasicBlock *, BasicBlock *> saveBBcheckpointBBMap; // store saveBB-checkpointBB pairing
      for (auto bbIter : checkpointBBPtrSet)
      {
        BasicBlock *checkpointBB = &(*bbIter);
        std::string checkpointBBName = LiveValues::getBBOpName(checkpointBB, &M).erase(0,1);
        std::vector<BasicBlock *> checkpointBBSuccessorsList = getBBSuccessors(checkpointBB);
        // insert saveBB on BB's exit edge
        for (uint32_t i = 0; i < checkpointBBSuccessorsList.size(); i ++)
        {
          // Insert the new block into the edge between thisBB and a successorBB:
          BasicBlock *successorBB = checkpointBBSuccessorsList[i];
          BasicBlock *insertedBB = splitEdgeWrapper(checkpointBB, successorBB, checkpointBBName + ".saveBB", M);
          if (insertedBB)
          {
            saveBBcheckpointBBMap.emplace(insertedBB, checkpointBB);
          }
          else
          {
            continue;
          }
        }
        // break;  // DO THIS FOR ONLY ONE CHKPT BB FOR NOW
      }

      // ## 4: Add restoreBBs
      std::map<BasicBlock *, ModuleTransformationPass::CheckpointTopo> checkpointBBTopoMap;
      std::map<BasicBlock *, BasicBlock *>::iterator iter;
      for (iter = saveBBcheckpointBBMap.begin(); iter != saveBBcheckpointBBMap.end(); ++iter)
      {
        BasicBlock *saveBB = iter->first;
        BasicBlock *checkpointBB = iter->second;
        std::string checkpointBBName = LiveValues::getBBOpName(checkpointBB, &M).erase(0,1);
        // create restoreBB for this saveBB
        BasicBlock *restoreBB = BasicBlock::Create(context, checkpointBBName + ".restoreBB", &F, restoreControllerBB);
        builder.SetInsertPoint(restoreBB);
        // create mediator BB as junction to combine output of saveBB and restoreBB
        BasicBlock *resumeBB = *(succ_begin(saveBB)); // saveBBs should only have one successor.
        BasicBlock *junctionBB = splitEdgeWrapper(saveBB, resumeBB, checkpointBBName + ".junctionBB", M);
        if (junctionBB)
        {
          // have successfully inserted all components (BBs) of subroutine
          BranchInst::Create(junctionBB, restoreBB);
          ModuleTransformationPass::CheckpointTopo checkpointTopo = {
            .checkpointBB = checkpointBB,
            .saveBB = saveBB,
            .restoreBB = restoreBB,
            .junctionBB = junctionBB
          };
          checkpointBBTopoMap.emplace(checkpointBB, checkpointTopo);
        }
        else
        {
          // failed to inject mediator BB => skip this checkpoint
          // remove saveBB from saveBBcheckpointBBMap
          saveBBcheckpointBBMap.erase(saveBB);
          /** TODO: remove saveBB and restoreBB for this checkpoint from CFG */
          continue; 
        }
      }

      // ## 5: Add checkpoint IDs to saveBBs and restoreBBs
      CheckpointIdBBMap checkpointIDsaveBBsMap = getCheckpointIdBBMap(checkpointBBTopoMap, M);
      printCheckpointIdBBMap(checkpointIDsaveBBsMap, &F);

      // ## 6: Populate restoreControllerBB with switch instructions.
      /**
        TODO: Implement switch statement to check Checkpoint ID

        a. if CheckpointID indicates no checkpoint has been saved, continue to computation.
        b. if CheckpointID exists, jump to restoreBB for that CheckpointID.
      */

      // ## 7: populate saveBB and restoreBB with load and store instructions.
      /**
        TODO: figure out whether to place this after the checkpointIDsaveBBsMap.size() check or after.
      */


      if (checkpointIDsaveBBsMap.size() == 0)
      {
        // no checkpoints were added for func, try increasing threshold for min-allowed values in BB.
        defaultMinValsCount = currMinValsCount + 1;
      }

      // FOR TESTING:
      hasInjectedSubroutinesForFunc = true;
    }
    if (!hasInjectedSubroutinesForFunc)
    {
      // none of BBs in function lead to successful subroutine injection.
      std::cout << "WARNING: None of BBs in function '" << funcName <<"' result in successful subroutine injection. No checkpoints added to function.\n";
    }
  }
  return isModified;
}

ModuleTransformationPass::CheckpointIdBBMap
ModuleTransformationPass::getCheckpointIdBBMap(
  std::map<BasicBlock *, ModuleTransformationPass::CheckpointTopo> &checkpointBBTopoMap,
  Module &M
) const
{
  uint8_t checkpointIDCounter = 0;
  CheckpointIdBBMap checkpointIdBBMap;
  std::map<BasicBlock *, ModuleTransformationPass::CheckpointTopo>::iterator iter;
  for (iter = checkpointBBTopoMap.begin(); iter != checkpointBBTopoMap.end(); ++iter)
  {
    ModuleTransformationPass::CheckpointTopo checkpointTopo = iter->second;
    BasicBlock *saveBB = checkpointTopo.saveBB;
    BasicBlock *restoreBB = checkpointTopo.restoreBB;
    BasicBlock *junctionBB = checkpointTopo.junctionBB;
    // append checkpoint id to saveBB and restoreBB names
    std::string saveBBName = LiveValues::getBBOpName(saveBB, &M).erase(0,1) + ".id" + std::to_string(checkpointIDCounter);
    dyn_cast<Value>(saveBB)->setName(saveBBName);
    std::string restoreBBName = LiveValues::getBBOpName(restoreBB, &M).erase(0,1) + ".id" + std::to_string(checkpointIDCounter);
    dyn_cast<Value>(restoreBB)->setName(restoreBBName);
    std::string junctionBBName = LiveValues::getBBOpName(junctionBB, &M).erase(0,1) + ".id" + std::to_string(checkpointIDCounter);
    dyn_cast<Value>(junctionBB)->setName(junctionBBName);

    checkpointIdBBMap.emplace(checkpointIDCounter, checkpointTopo);
    checkpointIDCounter ++;
  }
  return checkpointIdBBMap;
}

/** TODO: remove Module param when removing print statement */
Instruction *
ModuleTransformationPass::getCmpInstForCondiBrInst(Instruction *condiBranchInst, Module &M) const
{
  Value* condition = dyn_cast<BranchInst>(condiBranchInst)->getCondition();
  Instruction *cmp_instr = nullptr;
  while(cmp_instr == nullptr)
  {
    // attempt to find branch instr's corresponding cmp instr
    Instruction *instr = condiBranchInst->getPrevNode();
    
    if (instr == nullptr) break;  // have reached list head; desired cmp instr not found
    
    Value *instr_val = dyn_cast<Value>(instr);
    std::cout << "?" << LiveValues::getValueOpName(instr_val, &M) << "\n";
    if ((isa <ICmpInst> (instr) || isa <FCmpInst> (instr)) && instr == condition)
    {
      cmp_instr = instr;
    }
  }
  return cmp_instr;
}

std::pair<BasicBlock *, std::set<BasicBlock*>>
ModuleTransformationPass::getEntryAndCkptBBsInFunc(Function *F, CheckpointBBMap &bbCheckpoints) const
{
  BasicBlock* entryBB;
  std::set<BasicBlock*> checkpointBBPtrSet;

  Function::iterator funcIter;
  for (funcIter = F->begin(); funcIter != F->end(); ++funcIter)
  {
    BasicBlock* bb_ptr = &(*funcIter);
    if (bb_ptr->isEntryBlock())
    {
      entryBB = bb_ptr;
    }
    if (bbCheckpoints.count(bb_ptr))
    {
      checkpointBBPtrSet.insert(bb_ptr);
      Module *M = F->getParent();
      std::cout<<LiveValues::getBBOpName(bb_ptr, M)<<"\n";
    }
  }
  std::pair<BasicBlock *, std::set<BasicBlock*>> pair(entryBB, checkpointBBPtrSet);
  return pair;
}

std::vector<BasicBlock *>
ModuleTransformationPass::getBBSuccessors(BasicBlock *BB) const
{
  std::vector<BasicBlock *> BBSuccessorsList;
  // find successors to this checkpoint BB
  for (auto sit = succ_begin(BB); sit != succ_end(BB); ++sit)
  {
    BasicBlock *successor = *sit;
    BBSuccessorsList.push_back(successor);
  }
  return BBSuccessorsList;
}

std::vector<BasicBlock *>
ModuleTransformationPass::getNonExitBBSuccessors(BasicBlock *BB) const
{
  std::vector<BasicBlock *> BBSuccessorsList;
  // find BBs that are not the exit block
  for (auto sit = succ_begin(BB); sit != succ_end(BB); ++sit)
  {
    BasicBlock *successor = *sit;
    const Instruction *TI = successor->getTerminator();
    int grandChildCount = TI->getNumSuccessors();
    if (grandChildCount > 0)
    {
      BBSuccessorsList.push_back(successor);
    }
  }
  return BBSuccessorsList;
}

BasicBlock*
ModuleTransformationPass::splitEdgeWrapper(BasicBlock *edgeStartBB, BasicBlock *edgeEndBB, std::string checkpointName, Module &M) const
{
  /** TODO: figure out whether to specify DominatorTree, LoopInfo and MemorySSAUpdater params */
  BasicBlock *insertedBB = SplitEdge(edgeStartBB, edgeEndBB, nullptr, nullptr, nullptr, checkpointName);
  if (!insertedBB)
  {
    // SplitEdge can fail, e.g. if the successor is a landing pad
    std::cerr << "Split-edge failed between BB{" 
              << LiveValues::getBBOpName(edgeStartBB, &M) 
              << "} and BB{" 
              << LiveValues::getBBOpName(edgeEndBB, &M)
              <<"}\n";
    // Don't insert BB if it fails, if this causes 0 ckpts to be added, then choose ckpt of a larger size)
    return nullptr;
  }
  else
  {
    return insertedBB;
  }
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
    std::string funcName = LiveValues::getFuncOpName(&F, &M);
    std::cout<<"\n"<<funcName<<":\n";
    if (jsonMap.count(funcName) && funcValuePtrsMap.count(&F))
    {
      // std::cout<<LiveValues::getFuncOpName(&F, &M)<<"\n";
      ValuePtrsMap valuePtrsMap = funcValuePtrsMap.at(&F);
      LiveValues::BBTrackedVals_JSON bbTrackedVals_json = jsonMap.at(funcName);
      LiveValues::BBTrackedVals bbTrackedValsMap;
      Function::iterator bbIter;
      for (bbIter = F.begin(); bbIter != F.end(); ++bbIter)
      {
        const BasicBlock* bb = &(*bbIter);
        std::string bbName = LiveValues::getBBOpName(bb, &M);
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
              const Value* val = valuePtrsMap.at(valName);
              trackedVals.insert(val);
              std::cout<<LiveValues::getValueOpName(val, &M)<< " ";
            }
          }
          std::cout<<"\n";
        }
        bbTrackedValsMap.emplace(bb, trackedVals);
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
    std::string funcName = LiveValues::getFuncOpName(&F, &M);
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
      const BasicBlock* bb = &(*bbIter);
      std::set<const Value*> trackedVals;
      BasicBlock::const_iterator instrIter;
      for (instrIter = bb->begin(); instrIter != bb->end(); ++instrIter)
      {
        User::const_op_iterator operand;
        for (operand = instrIter->op_begin(); operand != instrIter->op_end(); ++operand)
        {
          const Value *value = *operand;
          std::string valName = LiveValues::getValueOpName(value, &M);

          // valuePtrsSet.insert(valuePtr);
          valuePtrsMap.emplace(valName, value);
        }
      }
    }
    funcValuePtrsMap.emplace(&F, valuePtrsMap);
  }
  return funcValuePtrsMap;
}

long unsigned int
ModuleTransformationPass::getMaxNumOfTrackedValsForBBsInFunc(Function *F, const LiveValues::Result &map) const
{
  if (map.count(F))
  {    
    LiveValues::BBTrackedVals bbTrackedVals = map.at(F);
    auto maxElem = std::max_element(bbTrackedVals.cbegin(), bbTrackedVals.cend(),
                                    [](const auto &a, const auto &b)
                                      {
                                      return a.second.size() < b.second.size();
                                      });
    return (maxElem->second).size();
  }
  else
  { 
    // No tracked values analysis info available for function.
    return 0;
  }
}

ModuleTransformationPass::CheckpointBBMap
ModuleTransformationPass::chooseBBWithLeastTrackedVals(const LiveValues::Result &map, Function *F, long unsigned int minValsCount) const
{ 
  CheckpointBBMap cpBBMap;
  LiveValues::Result::const_iterator funcIter;
  const Module *M = F->getParent();
  if (map.count(F))
  {
    long unsigned int maxSize = getMaxNumOfTrackedValsForBBsInFunc(F, map);
    std::cout << "MaxSize=" << maxSize << "\n";
    if (maxSize < minValsCount)
    {
      // function does not contain BBs that have at least minValsCount tracked values.
      std::cout << "Function '" << LiveValues::getFuncOpName(F, M) 
                << "' does not have BBs with at least " << minValsCount 
                << " tracked values. BB ignored.\n";
      // short circuit return empty map
      return cpBBMap;
    }

    // Find min number of tracked values that is >= minValsCount (search across all BBs)
    LiveValues::BBTrackedVals bbTrackedVals = map.at(F);
    auto minElem = std::min_element(bbTrackedVals.cbegin(), bbTrackedVals.cend(),
                                    [=](const auto &a, const auto &b)
                                      {
                                      // return true if a < b:
                                      // ignore entry blocks
                                      if (a.first->isEntryBlock()) return false;
                                      if (b.first->isEntryBlock()) return true;
                                      // ignore blocks with fewer tracked values than the minValsCount
                                      if (a.second.size() < minValsCount) return false;
                                      if (b.second.size() < minValsCount) return true;
                                      return a.second.size() < b.second.size();
                                      });
    long unsigned int minSize = (minElem->second).size();
    std::cout << "(" << F->getName().str() << " min num of tracked vals per BB = " << minSize << ")\n";

    if (minSize >= minValsCount)
    {
      // For each BB with this number of live values, add entry into cpBBMap.
      LiveValues::BBTrackedVals::const_iterator bbIt;
      for (bbIt = bbTrackedVals.cbegin(); bbIt != bbTrackedVals.cend(); bbIt++)
      {
        const BasicBlock *bb = bbIt->first;
        const std::set<const Value *> &trackedVals = bbIt->second;
        // get elements of trackedVals with min number of tracked values that is at least minValCount
        if (trackedVals.size() == minSize)
        {
          cpBBMap.emplace(bb, trackedVals);
        }
      }
    }
    else
    {
      std::cout << "Unable to find checkpoint BB candidates for function '" << LiveValues::getFuncOpName(F, M) << "'\n";
    }
  }
  else
  {
    std::cout << "Unable to find tracked values information for function '" << LiveValues::getFuncOpName(F, M) << "'\n";
  }
  return cpBBMap;
}

LiveValues::Result
ModuleTransformationPass::getBBsWithOneSuccessor(LiveValues::Result funcBBTrackedVals) const
{
  LiveValues::Result filteredFuncBBTrackedVals;
  LiveValues::Result::const_iterator iter;
  for (iter = funcBBTrackedVals.cbegin(); iter != funcBBTrackedVals.cend(); ++iter)
  {
    const Function *F = iter->first;
    LiveValues::BBTrackedVals bbTrackedVals = iter->second;

    LiveValues::BBTrackedVals filteredBBTrackedVals;
    LiveValues::BBTrackedVals::const_iterator funcIter;
    for (funcIter = bbTrackedVals.cbegin(); funcIter != bbTrackedVals.cend(); ++funcIter)
    {
      const BasicBlock *BB = funcIter->first;
      const std::set<const Value *> &trackedValues = funcIter->second;
      const Instruction *TI = BB->getTerminator();
      if (TI->getNumSuccessors() == 1)
      {
        filteredBBTrackedVals.emplace(BB, trackedValues);
      }
    }
    filteredFuncBBTrackedVals.emplace(F, filteredBBTrackedVals);
  }
  return filteredFuncBBTrackedVals;
}

void
ModuleTransformationPass::printCheckPointBBs(const CheckpointFuncBBMap &fBBMap, Module &M) const
{
  CheckpointFuncBBMap::const_iterator funcIt;
  CheckpointBBMap::const_iterator bbIt;
  std::set<const Value *>::const_iterator valIt;
  for (funcIt = fBBMap.cbegin(); funcIt != fBBMap.cend(); funcIt++){
    const Function *func = funcIt->first;
    const CheckpointBBMap bbMap = funcIt->second;

    std::cout << "Checkpoint candidate BBs for '" << LiveValues::getFuncOpName(func, &M) << "':\n";
    for (bbIt = bbMap.cbegin(); bbIt != bbMap.cend(); bbIt++)
    {
      const BasicBlock *bb = bbIt->first;
      const std::set<const Value *> vals = bbIt->second;
      std::cout << "  BB: " << LiveValues::getBBOpName(bb, &M) << "\n    ";
    
      for (valIt = vals.cbegin(); valIt != vals.cend(); valIt++)
      {
        const Value *val = *valIt;
        std::cout << LiveValues::getValueOpName(val, &M) << " ";
      }
      std::cout << '\n';
    }
    std::cout << "\n";
  }

  return;
}

void
ModuleTransformationPass::printCheckpointIdBBMap(ModuleTransformationPass::CheckpointIdBBMap map, Function *F)
{
  Module *M = F->getParent();
  std::cout << "\n----CHECKPOINTS for '" << LiveValues::getFuncOpName(F, M) << "'----\n";
  ModuleTransformationPass::CheckpointIdBBMap::const_iterator iter;
  for (iter = map.cbegin(); iter != map.cend(); ++iter)
  {
    uint8_t id = iter->first;
    ModuleTransformationPass::CheckpointTopo topo = iter->second;
    std::cout << "ID = " << std::to_string(id) << "\n";
    std::cout << "CheckpointBB = " << LiveValues::getBBOpName(topo.checkpointBB, M) << "\n";
    std::cout << "SaveBB = " << LiveValues::getBBOpName(topo.saveBB, M) << "\n";
    std::cout << "RestoreBB = " << LiveValues::getBBOpName(topo.restoreBB, M) << "\n";
    std::cout << "JunctionBB = " << LiveValues::getBBOpName(topo.junctionBB, M) << "\n";
    std::cout << "\n";
  }
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
      const Value* val = it->second;
      std::cout << "  " << valName << " {" << LiveValues::getValueOpName(val, &M) << "}\n";
    }
    // std::cout << "## size = " << valuePtrsMap.size() << "\n";
  }
}