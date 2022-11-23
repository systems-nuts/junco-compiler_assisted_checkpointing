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
  const LiveValues::Result &map
)
{
  bool isModified = false;
  uint8_t CheckpointIDCounter = 0;
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
    long unsigned int defaultMinValsCount = 1;
    long unsigned int maxTrackedValsCount = getMaxNumOfTrackedValsForBBsInFunc(&F, map);

    while(!hasInjectedSubroutinesForFunc && defaultMinValsCount <= maxTrackedValsCount)
    {
      // ## 0: get candidate checkpoint BBs
      std::cout<< "##minValsCount=" << defaultMinValsCount << "\n";
      CheckpointBBMap bbCheckpoints = chooseBBWithLeastTrackedVals(map, &F, defaultMinValsCount);
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
      bool hasInsertedPostEntryRestoreBB = false;
      BasicBlock *restoreControllerBB = nullptr;
      std::vector<BasicBlock *> usefulSuccessorsList = getNonExitBBSuccessors(entryBB);
      for (uint32_t i = 0; i < usefulSuccessorsList.size(); i ++)
      {
        // Insert the new block into the edge between thisBB and a successorBB:
        BasicBlock *successorBB = usefulSuccessorsList[i];
        restoreControllerBB = splitEdgeWrapper(entryBB, successorBB, "restore.controller", M);
        if (restoreControllerBB)
        {
          isModified = true;
          hasInsertedPostEntryRestoreBB = true;
        }
        else
        {
          // Split-edge fails for adding BB after function entry block => skip this function
          continue;
        }
      }

      // ## 3. Add block on exit edge of checkpointed block
      ModuleTransformationPass::CheckpointIDsMap saveBBsMap;
      for (auto bbIter : checkpointBBPtrSet)
      {
        BasicBlock *checkpointBB = &(*bbIter);
        std::vector<BasicBlock *> checkpointBBSuccessorsList = getBBSuccessors(checkpointBB);

        // Check if terminator of checkpointBB is conditional branch instruction:
        Instruction *terminator_instr = checkpointBB->getTerminator();
        if (terminator_instr->getNumSuccessors() == 1)
        {
          // is not a conditional terminator (branches to 1 BB)
          // insert saveBB on BB's exit edge
          for (uint32_t i = 0; i < checkpointBBSuccessorsList.size(); i ++)
          {
            // Insert the new block into the edge between thisBB and a successorBB:
            BasicBlock *successorBB = checkpointBBSuccessorsList[i];
            BasicBlock *insertedBB = splitEdgeWrapper(checkpointBB, successorBB, "saveBB", M);
            if (insertedBB)
            {
              saveBBsMap.emplace(CheckpointIDCounter, insertedBB);
              CheckpointIDCounter ++;
            }
            else
            {
              continue;
            }
          }
        }
        else
        {
          // is a conditional terminator (branches to 2 BBs)
          // split BB before compare instruction and insert saveBB between these two
          
          /* 
          TODO: Currently works for conditional branches ONLY!
                Does not yet work for switch, indirectBr, etc.
          */
          Instruction *cmp_instr = getCmpInstForCondiBrInst(terminator_instr, M);
          if (cmp_instr == nullptr) continue;  // could not resolve condi branch split; ignore this checkpoint BB

          std::string checkpointName = LiveValues::getBBOpName(checkpointBB, &M).erase(0,1) + ".part2";
          // NOTE: splitBlock does not preserve any passes. to split blocks while keeping loop information consistent, use the SplitBlock utility function
          BasicBlock *splitBBSecondPart = checkpointBB->splitBasicBlock(cmp_instr, checkpointName, false);
          if (!splitBBSecondPart)
          {
            // SplitEdge can fail, e.g. if the successor is a landing pad
            std::cerr << "Split-Basic-Block failed for BB{" 
                      << LiveValues::getBBOpName(checkpointBB, &M) 
                      << "}\n";
            // Don't insert BB if it fails, if this causes 0 ckpts to be added, then choose ckpt of a larger size)
            continue;
          }
          else
          {
            // insert saveBB between split BBs
            BasicBlock *insertedBB = splitEdgeWrapper(checkpointBB, splitBBSecondPart, "saveBB", M);
            if (insertedBB)
            {
              saveBBsMap.emplace(CheckpointIDCounter, insertedBB);
              CheckpointIDCounter ++;
            }
            else
            {
              continue;
            }
          }
        }

        // get vars for instruction building
        LLVMContext &context = F.getContext();
        IRBuilder<> builder(context);

        // ## 4: Add restoreBBs
        std::map<BasicBlock *, BasicBlock *> restoreBBsMap; // store restoreBB-saveBB pairing
        CheckpointIDsMap::iterator i;
        for (i = saveBBsMap.begin(); i != saveBBsMap.end(); ++i)
        {
          uint8_t checkpointID = i->first;
          BasicBlock *saveBB = i->second;
          // create restoreBB for this saveBB
          std::string restoreBBName = LiveValues::getBBOpName(saveBB, &M).erase(0,1) + "restoreBB.id" + std::to_string(checkpointID);
          BasicBlock *restoreBB = BasicBlock::Create(context, restoreBBName, &F, restoreControllerBB);
          restoreBBsMap.emplace(restoreBB, saveBB);
          // add instructions to this restoreBB
          builder.SetInsertPoint(restoreBB);
          BasicBlock *resumeBB = *(succ_begin(saveBB)); // saveBBs should only have one successor.
          Instruction *directBranchInst = BranchInst::Create(resumeBB, restoreBB);
        }


        // ## 5: Populate restoreControllerBB with switch instructions.
        /**
          TODO: Implement switch statement to check Checkpoint ID

          a. if CheckpointID indicates no checkpoint has been saved, continue to computation.
          b. if CheckpointID exists, jump to restoreBB for that CheckpointID.
        */




        // break;  // DO THIS FOR ONLY ONE CHKPT BB FOR NOW
      }
      if (saveBBsMap.size() == 0)
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
ModuleTransformationPass::splitEdgeWrapper(BasicBlock *edgeStartBB, BasicBlock *edgeEndBB, std::string nameSuffix, Module &M) const
{
  // TODO: figure out whether to specify DominatorTree, LoopInfo and MemorySSAUpdater params 
  std::string checkpointName = LiveValues::getBBOpName(edgeStartBB, &M).erase(0,1) + "." + nameSuffix;
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
        const Instruction *firstInstr = &*bb->begin();
        // get elements of trackedVals with min number of tracked values that is at least minValCount
        if (trackedVals.size() == minSize && isa<PHINode>(firstInstr))
        {
          // ignore BBs where 1st instruction is PHI node.
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