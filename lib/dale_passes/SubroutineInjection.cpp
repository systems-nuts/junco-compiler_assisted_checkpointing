/**
 * Does DFS on BB CFG for each Function in Module.
 * For each BB, finds the "modified values" that are stored within the BB via store instructions.
 * Each predecessor BB propagates its "modified values" to all its successor BBs.
 * Modified Values are stored in a map with key as BB and value as set of modified values.
 *
 * To Run:
 * $ opt -enable-new-pm=0 -load /path/to/build/lib/libSubroutineInjection.so `\`
 *   -module-transformation-pass -S /path/to/input/IR.ll -o /path/to/output/IR.ll
 */

#include "dale_passes/SubroutineInjection.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Dominators.h" // test
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Support/Debug.h"

#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Type.h"
#include "llvm/Analysis/LoopInfo.h"

#include <cstddef>
#include <exception>
#include <iostream>
#include <sys/stat.h>
#include <fstream>

#define DEBUG_TYPE "module-transformation-pass"

using namespace llvm;

char SubroutineInjection::ID = 0;

// This is the core interface for pass plugins. It guarantees that 'opt' will
// recognize LegacyHelloWorld when added to the pass pipeline on the command
// line, i.e.  via '--legacy-hello-world'
static RegisterPass<SubroutineInjection>
    X("subroutine-injection", "Subroutine Injection",
      false, // This pass does modify the CFG => false
      false // This pass is not a pure analysis pass => false
    );

namespace llvm {
  ModulePass *createSubroutineInjection() { return new SubroutineInjection(); }
}

///////////////////////////////////////////////////////////////////////////////
// Public API
///////////////////////////////////////////////////////////////////////////////

SubroutineInjection::SubroutineInjection(void) : ModulePass(ID) {}

void SubroutineInjection::getAnalysisUsage(AnalysisUsage &AU) const
{
}

bool SubroutineInjection::runOnModule(Module &M)
{
  std::cout << "Module Transformation Pass printout" << std::endl;

  // load live values analysis results.
  FuncBBLiveValsByName = getLiveValuesResultsFromJson("live_values.json");
  JsonHelper::printJsonMap(FuncBBLiveValsByName);
  std::cout << "===========\n";

  // load Tracked values analysis results.
  FuncBBTrackedValsByName = getTrackedValuesResultsFromJson("tracked_values.json");
  JsonHelper::printJsonMap(FuncBBTrackedValsByName);
  std::cout << "===========\n";

  FuncValuePtrs = getFuncValuePtrsMap(M, FuncBBTrackedValsByName);
  printFuncValuePtrsMap(FuncValuePtrs, M);

  // re-build tracked values pointer map
  std::cout << "#TRACKED VALUES ======\n";
  LiveValues::TrackedValuesResult funcBBTrackedValsMap = getFuncBBTrackedValsMap(FuncValuePtrs, FuncBBTrackedValsByName, M);
  
  // re-build liveness analysis results pointer map
  std::cout << "#LIVE VALUES ======\n";
  LiveValues::LivenessResult funcBBLiveValsMap = getFuncBBLiveValsMap(FuncValuePtrs, FuncBBLiveValsByName, M);

  bool isModified = injectSubroutines(M, funcBBTrackedValsMap);

  // printCheckPointBBs(CheckpointsMap, M);

  return isModified;
}


LiveValues::TrackedValuesMap_JSON
SubroutineInjection::getTrackedValuesResultsFromJson(const std::string filename) const
{
  Json::Value root; // root will contain the root value
  LiveValues::TrackedValuesMap_JSON jsonMap;
  struct stat buffer;
  if (stat (filename.c_str(), &buffer) == 0)
  {
    // file exists; open json file
    std::cout << "JSON File Exists\n";
    std::ifstream json_file(filename, std::ifstream::binary);
    json_file >> root;
    JsonHelper::loadTrackedValuesJsonObjToJsonMap(root, jsonMap);
  }
  else
  {
    // file does not exist; make new json file
    std::cout << "JSON File does not exist\n";
    throw std::runtime_error("Required JSON file " + filename + " does not exist!");
  }
  return jsonMap;
}

LiveValues::LiveValuesMap_JSON
SubroutineInjection::getLiveValuesResultsFromJson(const std::string filename) const
{
  Json::Value root;
  LiveValues::LiveValuesMap_JSON jsonMap;
  struct stat buffer;
  if (stat (filename.c_str(), &buffer) == 0)
  {
    // file exists; open json file
    std::cout << "JSON File Exists\n";
    std::ifstream json_file(filename, std::ifstream::binary);
    json_file >> root;
    JsonHelper::loadLiveValuesJsonObjToJsonMap(root, jsonMap);
  }
  else
  {
    // file does not exist; make new json file
    std::cout << "JSON File does not exist\n";
    throw std::runtime_error("Required JSON file " + filename + " does not exist!");
  }
  return jsonMap;
}

void
SubroutineInjection::print(raw_ostream &O, const Function *F) const
{
  /** TODO: implement me! */
  return;
}

void
SubroutineInjection::printTrackedValues(raw_ostream &O, const LiveValues::TrackedValuesResult &LVResult) const
{
  LiveValues::TrackedValuesResult::const_iterator funcIt;
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
SubroutineInjection::injectSubroutines(
  Module &M,
  const LiveValues::TrackedValuesResult &map
)
{
  bool isModified = false;
  for (auto &F : M.getFunctionList())
  {
    std::string funcName = JsonHelper::getOpName(&F, &M);
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
      LiveValues::TrackedValuesResult filteredMap = getBBsWithOneSuccessor(map);
      CheckpointBBMap bbCheckpoints = chooseBBWithLeastTrackedVals(filteredMap, &F, defaultMinValsCount);
      
      if (bbCheckpoints.size() == 0)
      {
        // Could not find any BBs with at least defaultMinValsCount
        // tracked values, try again with larger min count value.
        std::cout << "Function '" << funcName
                  << "': could not find any BBs with at least "
                  << defaultMinValsCount << " tracked values. Ignore function.\n";
        break;
      }
      int currMinValsCount = bbCheckpoints.begin()->second.size();
      std::cout<< "#currNumOfTrackedVals=" << currMinValsCount << "\n";
      std::set<BasicBlock *> newBBs;

      // ## 1: get pointers to Entry BB and checkpoint BBs
      std::cout << "Checkpoint BBs: \n";
      std::pair<BasicBlock*, std::set<BasicBlock*>> p = getEntryAndCkptBBsInFunc(&F, bbCheckpoints);
      BasicBlock* entryBB = p.first;
      std::set<BasicBlock*> checkpointBBPtrSet = p.second;

      // ## 2. Add block on exit edge of entry block that leads to computation
      BasicBlock *restoreControllerBB = nullptr;
      BasicBlock *restoreControllerSuccessor = nullptr;
      std::vector<BasicBlock *> usefulSuccessorsList = getNonExitBBSuccessors(entryBB);
      for (uint32_t i = 0; i < usefulSuccessorsList.size(); i ++)
      {
        // Insert the new block into the edge between thisBB and a successorBB:
        BasicBlock *successorBB = usefulSuccessorsList[i];
        std::string restoreControllerBBName = funcName.erase(0,1) + ".restoreControllerBB";
        restoreControllerBB = splitEdgeWrapper(entryBB, successorBB, restoreControllerBBName, M);
        if (restoreControllerBB)
        {
          isModified = true;
          restoreControllerSuccessor = restoreControllerBB->getSingleSuccessor();
          std::cout<<"successor of restoreControllerBB=" << JsonHelper::getOpName(restoreControllerSuccessor, &M) << "\n";
          newBBs.insert(restoreControllerBB);
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
        std::string checkpointBBName = JsonHelper::getOpName(checkpointBB, &M).erase(0,1);
        std::vector<BasicBlock *> checkpointBBSuccessorsList = getBBSuccessors(checkpointBB);
        // insert saveBB on BB's exit edge
        for (uint32_t i = 0; i < checkpointBBSuccessorsList.size(); i ++)
        {
          // Insert the new saveBB into the edge between thisBB and a successorBB:
          BasicBlock *successorBB = checkpointBBSuccessorsList[i];
          BasicBlock *saveBB = splitEdgeWrapper(checkpointBB, successorBB, checkpointBBName + ".saveBB", M);
          if (saveBB)
          {
            saveBBcheckpointBBMap.emplace(saveBB, checkpointBB);
            newBBs.insert(saveBB);
          }
          else
          {
            continue;
          }
        }
        // break;  // DO THIS FOR ONLY ONE CHKPT BB FOR NOW
      }

      // ## 4: Add restoreBBs and junctionBBs
      std::map<BasicBlock *, CheckpointTopo> checkpointBBTopoMap;
      std::map<BasicBlock *, BasicBlock *>::iterator iter;
      for (iter = saveBBcheckpointBBMap.begin(); iter != saveBBcheckpointBBMap.end(); ++iter)
      {
        BasicBlock *saveBB = iter->first;
        BasicBlock *checkpointBB = iter->second;
        std::string checkpointBBName = JsonHelper::getOpName(checkpointBB, &M).erase(0,1);
        // create restoreBB for this saveBB
        BasicBlock *restoreBB = BasicBlock::Create(context, checkpointBBName + ".restoreBB", &F, restoreControllerBB);
        // create mediator BB as junction to combine output of saveBB and restoreBB
        BasicBlock *resumeBB = *(succ_begin(saveBB)); // saveBBs should only have one successor.
        BasicBlock *junctionBB = splitEdgeWrapper(saveBB, resumeBB, checkpointBBName + ".junctionBB", M);
        if (junctionBB)
        {
          // have successfully inserted all components (BBs) of subroutine
          BranchInst::Create(junctionBB, restoreBB);
          CheckpointTopo checkpointTopo = {
            .checkpointBB = checkpointBB,
            .saveBB = saveBB,
            .restoreBB = restoreBB,
            .junctionBB = junctionBB
          };
          checkpointBBTopoMap.emplace(checkpointBB, checkpointTopo);
          newBBs.insert(restoreBB);
          newBBs.insert(junctionBB);
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

      // ## 6: populate saveBB and restoreBB with load and store instructions.
      /**
        TODO: figure out whether to place this after the checkpointIDsaveBBsMap.size() check or after.
      */
      for (auto iter : checkpointIDsaveBBsMap)
      {
        CheckpointTopo checkpointTopo = iter.second;
        BasicBlock *checkpointBB = checkpointTopo.checkpointBB;
        BasicBlock *saveBB = checkpointTopo.saveBB;
        BasicBlock *restoreBB = checkpointTopo.restoreBB;
        BasicBlock *junctionBB = checkpointTopo.junctionBB;

        std::set<const Value*> trackedVals = bbCheckpoints.at(checkpointBB);
        for (auto iter : trackedVals)
        {
          /** TODO: replace placeholders with actual code */

          // Set up vars used for instruction creation
          Value *trackedVal = const_cast<Value*>(&*iter); /** TODO: verify safety of cast to non-const!! this is dangerous*/
          std::string valName = JsonHelper::getOpName(trackedVal, &M).erase(0,1);
          Type *valType = trackedVal->getType();
          Value *address = ConstantInt::get(Type::getInt8Ty(context), 0); /** TODO: is placeholder */

          // Create instructions to store value to memory.
          Instruction *saveBBTerminator = saveBB->getTerminator();
          AllocaInst *allocaInstSave = new AllocaInst(valType, 0, "store."+valName, saveBBTerminator);   /** TODO: is placeholder */
          StoreInst *storeInst = new StoreInst(trackedVal, allocaInstSave, false, saveBBTerminator);

          // Create instructions to load value from memory.
          Instruction *restoreBBTerminator = restoreBB->getTerminator();
          AllocaInst *allocaInstRestore = new AllocaInst(valType, 0, "load."+valName, restoreBBTerminator);  /** TODO: is placeholder */
          /** TODO: figure out how to load into existing Value ptr => LLVM is SSA, so need to add phi node to junction */
          LoadInst *loadInst = new LoadInst(valType, allocaInstSave, valName, restoreBBTerminator);


          // ## 6.1: Propagate loaded values from restoreBB across CFG.
          /**
            TODO: Implement propagation function.
          */
          propagateRestoredValues(junctionBB, newBBs, trackedVal, loadInst);

        }
      }


      // ## 8: Populate restoreControllerBB with switch instructions.
      /**
        TODO: Implement switch statement to load & check Checkpoint ID
        a. if CheckpointID indicates no checkpoint has been saved, continue to computation.
        b. if CheckpointID exists, jump to restoreBB for that CheckpointID.
      */
      
      /** TODO: load CheckpointID from memory*/
      Instruction *terminatorInst = restoreControllerBB->getTerminator();
      Value *checkpointIDValue = ConstantInt::get(Type::getInt8Ty(context), 0);

      /** TODO: insert instruction to load checkpoint ID into checkpointIDValue*/
      // LoadInst *loadCheckpointID = builder.CreateLoad(Type::getInt8PtrTy(context), checkpointIDValue, "CheckpointID");
      
      // create switch instruction
      unsigned int numCases = checkpointIDsaveBBsMap.size();
      SwitchInst *switchInst = builder.CreateSwitch(checkpointIDValue, restoreControllerSuccessor, numCases);
      ReplaceInstWithInst(terminatorInst, switchInst);
      for (auto iter : checkpointIDsaveBBsMap)
      {
        ConstantInt *checkpointID = ConstantInt::get(Type::getInt8Ty(context), iter.first);
        CheckpointTopo checkpointTopo = iter.second;
        BasicBlock *restoreBB = checkpointTopo.restoreBB;
        // switchInst->addCase(checkpointID, restoreBB);
      }


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

void
SubroutineInjection::propagateRestoredValues(BasicBlock *startBB, std::set<BasicBlock *> newBBs, Value *oldVal, Value *newVal)
{
  Module *M = startBB->getParent()->getParent();
  if(startBB->hasNPredecessors(1))
  {
    for (BasicBlock *succBB : getBBSuccessors(startBB))
    {
      BasicBlock::iterator instrIter;
      for (instrIter = succBB->begin(); instrIter != succBB->end(); instrIter++)
      {
        Instruction *instr = &*instrIter;
        User::op_iterator operandIter;
        for (operandIter = instrIter->op_begin(); operandIter != instrIter->op_end(); operandIter++)
        {
          const Value *value = *operandIter;
          std::string valName = JsonHelper::getOpName(value, M);
          if (value == oldVal)
          {
            // replace old operand with new operand
            *operandIter = newVal;
            std::string newValName = JsonHelper::getOpName(*operandIter, M);
            std::cout << "OldVal=" << valName << "; NewVal=" << newValName << "\n";
          }
        }
      }
      // recursive call on successor(s) of startBB
      propagateRestoredValues(succBB, newBBs, oldVal, newVal);
    }
  }
  else
  {

    if (!newBBs.count(startBB)) // && var is live-in of startBB
    {

    }
  }


}

SubroutineInjection::CheckpointIdBBMap
SubroutineInjection::getCheckpointIdBBMap(
  std::map<BasicBlock *, SubroutineInjection::CheckpointTopo> &checkpointBBTopoMap,
  Module &M
) const
{
  uint8_t checkpointIDCounter = 0;
  CheckpointIdBBMap checkpointIdBBMap;
  std::map<BasicBlock *, SubroutineInjection::CheckpointTopo>::iterator iter;
  for (iter = checkpointBBTopoMap.begin(); iter != checkpointBBTopoMap.end(); ++iter)
  {
    SubroutineInjection::CheckpointTopo checkpointTopo = iter->second;
    BasicBlock *saveBB = checkpointTopo.saveBB;
    BasicBlock *restoreBB = checkpointTopo.restoreBB;
    BasicBlock *junctionBB = checkpointTopo.junctionBB;
    // append checkpoint id to saveBB and restoreBB names
    std::string saveBBName = JsonHelper::getOpName(saveBB, &M).erase(0,1) + ".id" + std::to_string(checkpointIDCounter);
    dyn_cast<Value>(saveBB)->setName(saveBBName);
    std::string restoreBBName = JsonHelper::getOpName(restoreBB, &M).erase(0,1) + ".id" + std::to_string(checkpointIDCounter);
    dyn_cast<Value>(restoreBB)->setName(restoreBBName);
    std::string junctionBBName = JsonHelper::getOpName(junctionBB, &M).erase(0,1) + ".id" + std::to_string(checkpointIDCounter);
    dyn_cast<Value>(junctionBB)->setName(junctionBBName);

    checkpointIdBBMap.emplace(checkpointIDCounter, checkpointTopo);
    checkpointIDCounter ++;
  }
  return checkpointIdBBMap;
}

/** TODO: remove Module param when removing print statement */
Instruction *
SubroutineInjection::getCmpInstForCondiBrInst(Instruction *condiBranchInst, Module &M) const
{
  Value* condition = dyn_cast<BranchInst>(condiBranchInst)->getCondition();
  Instruction *cmp_instr = nullptr;
  while(cmp_instr == nullptr)
  {
    // attempt to find branch instr's corresponding cmp instr
    Instruction *instr = condiBranchInst->getPrevNode();
    
    if (instr == nullptr) break;  // have reached list head; desired cmp instr not found
    
    Value *instr_val = dyn_cast<Value>(instr);
    std::cout << "?" << JsonHelper::getOpName(instr_val, &M) << "\n";
    if ((isa <ICmpInst> (instr) || isa <FCmpInst> (instr)) && instr == condition)
    {
      cmp_instr = instr;
    }
  }
  return cmp_instr;
}

std::pair<BasicBlock *, std::set<BasicBlock*>>
SubroutineInjection::getEntryAndCkptBBsInFunc(Function *F, CheckpointBBMap &bbCheckpoints) const
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
      std::cout<<JsonHelper::getOpName(bb_ptr, M)<<"\n";
    }
  }
  std::pair<BasicBlock *, std::set<BasicBlock*>> pair(entryBB, checkpointBBPtrSet);
  return pair;
}

std::vector<BasicBlock *>
SubroutineInjection::getBBSuccessors(BasicBlock *BB) const
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
SubroutineInjection::getNonExitBBSuccessors(BasicBlock *BB) const
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
SubroutineInjection::splitEdgeWrapper(BasicBlock *edgeStartBB, BasicBlock *edgeEndBB, std::string checkpointName, Module &M) const
{
  /** TODO: figure out whether to specify DominatorTree, LoopInfo and MemorySSAUpdater params */
  BasicBlock *insertedBB = SplitEdge(edgeStartBB, edgeEndBB, nullptr, nullptr, nullptr, checkpointName);
  if (!insertedBB)
  {
    // SplitEdge can fail, e.g. if the successor is a landing pad
    std::cerr << "Split-edge failed between BB{" 
              << JsonHelper::getOpName(edgeStartBB, &M) 
              << "} and BB{" 
              << JsonHelper::getOpName(edgeEndBB, &M)
              <<"}\n";
    // Don't insert BB if it fails, if this causes 0 ckpts to be added, then choose ckpt of a larger size)
    return nullptr;
  }
  else
  {
    return insertedBB;
  }
}

LiveValues::TrackedValuesResult
SubroutineInjection::getFuncBBTrackedValsMap(
  const SubroutineInjection::FuncValuePtrsMap &funcValuePtrsMap,
  const LiveValues::TrackedValuesMap_JSON &jsonMap,
  Module &M
)
{
  LiveValues::TrackedValuesResult funcBBTrackedValsMap;
  for (auto &F : M.getFunctionList())
  {
    std::string funcName = JsonHelper::getOpName(&F, &M);
    std::cout<<"\n"<<funcName<<":\n";
    if (jsonMap.count(funcName) && funcValuePtrsMap.count(&F))
    {
      // std::cout<<JsonHelper::getOpName(&F, &M)<<"\n";
      ValuePtrsMap valuePtrsMap = funcValuePtrsMap.at(&F);
      LiveValues::BBTrackedVals_JSON bbTrackedVals_json = jsonMap.at(funcName);
      LiveValues::BBTrackedVals bbTrackedValsMap;
      Function::iterator bbIter;
      for (bbIter = F.begin(); bbIter != F.end(); ++bbIter)
      {
        const BasicBlock* bb = &(*bbIter);
        std::string bbName = JsonHelper::getOpName(bb, &M);
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
              std::cout<<JsonHelper::getOpName(val, &M)<< " ";
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

LiveValues::LivenessResult
SubroutineInjection::getFuncBBLiveValsMap(
  const SubroutineInjection::FuncValuePtrsMap &funcValuePtrsMap,
  const LiveValues::LiveValuesMap_JSON &jsonMap,
  Module &M
)
{
  LiveValues::LivenessResult funcBBLiveValsMap;
  for (auto &F : M.getFunctionList())
  {
    std::string funcName = JsonHelper::getOpName(&F, &M);
    std::cout<<"\n"<<funcName<<":\n";
    if (jsonMap.count(funcName) && funcValuePtrsMap.count(&F))
    {
      // std::cout<<JsonHelper::getOpName(&F, &M)<<"\n";
      ValuePtrsMap valuePtrsMap = funcValuePtrsMap.at(&F);
      LiveValues::BBLiveVals_JSON bbLiveVals_json = jsonMap.at(funcName);
      LiveValues::BBLiveVals bbLiveValsMap;
      Function::iterator bbIter;
      for (bbIter = F.begin(); bbIter != F.end(); ++bbIter)
      {
        const BasicBlock* bb = &(*bbIter);
        std::string bbName = JsonHelper::getOpName(bb, &M);
        std::cout<<"  "<<bbName<<":\n";
        std::set<const Value*> liveInVals;
        std::set<const Value*> liveOutVals;
        if (bbLiveVals_json.count(bbName))
        {
          // get names of live-in/out values in this BB from json map
          std::set<std::string> liveInVals_json = bbLiveVals_json.at(bbName).liveInVals_json;
          std::set<std::string> liveOutVals_json = bbLiveVals_json.at(bbName).liveOutVals_json;

          // process live-in values
          std::cout<<"    live-in\n        ";
          std::set<std::string>::const_iterator valIt;
          for (valIt = liveInVals_json.cbegin(); valIt != liveInVals_json.cend(); valIt++)
          {
            std::string valName = *valIt;
            if (valuePtrsMap.count(valName))
            {
              // get pointers to values corresponding to value name
              const Value* val = valuePtrsMap.at(valName);
              liveInVals.insert(val);
              std::cout<<JsonHelper::getOpName(val, &M)<< " ";
            }
          }
          std::cout<<"\n";

          // process live-out values
          std::cout<<"    live-out\n        ";
          for (valIt = liveOutVals_json.cbegin(); valIt != liveOutVals_json.cend(); valIt++)
          {
            std::string valName = *valIt;
            if (valuePtrsMap.count(valName))
            {
              // get pointers to values corresponding to value name
              const Value* val = valuePtrsMap.at(valName);
              liveOutVals.insert(val);
              std::cout<<JsonHelper::getOpName(val, &M)<< " ";
            }
          }
          std::cout<<"\n";
        }
        LiveValues::LiveInOutData liveInOutData = {
          .liveInVals = liveInVals,
          .liveOutVals = liveOutVals
        };
        bbLiveValsMap.emplace(bb, liveInOutData);
      }
      std::cout<<"\n";
      funcBBLiveValsMap.emplace(&F, bbLiveValsMap);
    }
    else
    {
      std::cerr << "No tracked values analysis data for '" << funcName << "'\n";
    }
  }
  return funcBBLiveValsMap;
}


SubroutineInjection::FuncValuePtrsMap
SubroutineInjection::getFuncValuePtrsMap(Module &M, LiveValues::TrackedValuesMap_JSON &jsonMap)
{
  SubroutineInjection::FuncValuePtrsMap funcValuePtrsMap;
  for (auto &F : M.getFunctionList())
  {
    std::string funcName = JsonHelper::getOpName(&F, &M);
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
          std::string valName = JsonHelper::getOpName(value, &M);

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
SubroutineInjection::getMaxNumOfTrackedValsForBBsInFunc(Function *F, const LiveValues::TrackedValuesResult &map) const
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

SubroutineInjection::CheckpointBBMap
SubroutineInjection::chooseBBWithLeastTrackedVals(const LiveValues::TrackedValuesResult &map, Function *F, long unsigned int minValsCount) const
{ 
  CheckpointBBMap cpBBMap;
  LiveValues::TrackedValuesResult::const_iterator funcIter;
  const Module *M = F->getParent();
  if (map.count(F))
  {
    long unsigned int maxSize = getMaxNumOfTrackedValsForBBsInFunc(F, map);
    std::cout << "MaxSize=" << maxSize << "\n";
    if (maxSize < minValsCount)
    {
      // function does not contain BBs that have at least minValsCount tracked values.
      std::cout << "Function '" << JsonHelper::getOpName(F, M) 
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
      std::cout << "Unable to find checkpoint BB candidates for function '" << JsonHelper::getOpName(F, M) << "'\n";
    }
  }
  else
  {
    std::cout << "Unable to find tracked values information for function '" << JsonHelper::getOpName(F, M) << "'\n";
  }
  return cpBBMap;
}

LiveValues::TrackedValuesResult
SubroutineInjection::getBBsWithOneSuccessor(LiveValues::TrackedValuesResult funcBBTrackedVals) const
{
  LiveValues::TrackedValuesResult filteredFuncBBTrackedVals;
  LiveValues::TrackedValuesResult::const_iterator iter;
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
SubroutineInjection::printCheckPointBBs(const CheckpointFuncBBMap &fBBMap, Module &M) const
{
  CheckpointFuncBBMap::const_iterator funcIt;
  CheckpointBBMap::const_iterator bbIt;
  std::set<const Value *>::const_iterator valIt;
  for (funcIt = fBBMap.cbegin(); funcIt != fBBMap.cend(); funcIt++){
    const Function *func = funcIt->first;
    const CheckpointBBMap bbMap = funcIt->second;

    std::cout << "Checkpoint candidate BBs for '" << JsonHelper::getOpName(func, &M) << "':\n";
    for (bbIt = bbMap.cbegin(); bbIt != bbMap.cend(); bbIt++)
    {
      const BasicBlock *bb = bbIt->first;
      const std::set<const Value *> vals = bbIt->second;
      std::cout << "  BB: " << JsonHelper::getOpName(bb, &M) << "\n    ";
    
      for (valIt = vals.cbegin(); valIt != vals.cend(); valIt++)
      {
        const Value *val = *valIt;
        std::cout << JsonHelper::getOpName(val, &M) << " ";
      }
      std::cout << '\n';
    }
    std::cout << "\n";
  }

  return;
}

void
SubroutineInjection::printCheckpointIdBBMap(SubroutineInjection::CheckpointIdBBMap map, Function *F)
{
  Module *M = F->getParent();
  std::cout << "\n----CHECKPOINTS for '" << JsonHelper::getOpName(F, M) << "'----\n";
  SubroutineInjection::CheckpointIdBBMap::const_iterator iter;
  for (iter = map.cbegin(); iter != map.cend(); ++iter)
  {
    uint8_t id = iter->first;
    CheckpointTopo topo = iter->second;
    std::cout << "ID = " << std::to_string(id) << "\n";
    std::cout << "CheckpointBB = " << JsonHelper::getOpName(topo.checkpointBB, M) << "\n";
    std::cout << "SaveBB = " << JsonHelper::getOpName(topo.saveBB, M) << "\n";
    std::cout << "RestoreBB = " << JsonHelper::getOpName(topo.restoreBB, M) << "\n";
    std::cout << "JunctionBB = " << JsonHelper::getOpName(topo.junctionBB, M) << "\n";
    std::cout << "\n";
  }
}

void
SubroutineInjection::printFuncValuePtrsMap(SubroutineInjection::FuncValuePtrsMap map, Module &M)
{
  SubroutineInjection::FuncValuePtrsMap::const_iterator iter;
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
      std::cout << "  " << valName << " {" << JsonHelper::getOpName(val, &M) << "}\n";
    }
    // std::cout << "## size = " << valuePtrsMap.size() << "\n";
  }
}