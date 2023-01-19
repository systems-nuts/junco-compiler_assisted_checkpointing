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
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/CFG.h"
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/Support/Debug.h"

#include "llvm/Transforms/Utils/BasicBlockUtils.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Type.h"
#include "llvm/Analysis/LoopInfo.h"

#include "llvm/IR/Dominators.h" // test
#include "llvm/Transforms/Utils/Local.h"

#include "json/JsonHelper.h"

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
  AU.addRequired<DominatorTreeWrapperPass>();
}

bool SubroutineInjection::runOnModule(Module &M)
{
  std::cout << "Module Transformation Pass printout" << std::endl;

  // load live values analysis results.
  FuncBBLiveValsByName = JsonHelper::getLiveValuesResultsFromJson("live_values.json");
  JsonHelper::printJsonMap(FuncBBLiveValsByName);
  std::cout << "===========\n";

  // load Tracked values analysis results.
  FuncBBTrackedValsByName = JsonHelper::getTrackedValuesResultsFromJson("tracked_values.json");
  JsonHelper::printJsonMap(FuncBBTrackedValsByName);
  std::cout << "===========\n";

  FuncValuePtrs = getFuncValuePtrsMap(M, FuncBBTrackedValsByName);
  printFuncValuePtrsMap(FuncValuePtrs, M);

  // re-build tracked values pointer map
  std::cout << "#TRACKED VALUES ======\n";
  LiveValues::TrackedValuesResult funcBBTrackedValsMap = JsonHelper::getFuncBBTrackedValsMap(FuncValuePtrs, FuncBBTrackedValsByName, M);
  
  // re-build liveness analysis results pointer map
  std::cout << "#LIVE VALUES ======\n";
  LiveValues::LivenessResult funcBBLiveValsMap = JsonHelper::getFuncBBLiveValsMap(FuncValuePtrs, FuncBBLiveValsByName, M);

  bool isModified = injectSubroutines(M, funcBBTrackedValsMap, funcBBLiveValsMap);

  // printCheckPointBBs(CheckpointsMap, M);

  return isModified;
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

bool SubroutineInjection::isEntryBlock(const BasicBlock* BB) const {
   const Function *F = BB->getParent();
   assert(F && "Block must have a parent function to use this API");
   return BB == &F->getEntryBlock();
}

/// Set every incoming value(s) for block \p BB to \p V.
void SubroutineInjection::setIncomingValueForBlock(PHINode *phi, const BasicBlock *BB, Value *V) {
    assert(BB && "PHI node got a null basic block!");
    bool Found = false;
    for (unsigned Op = 0, NumOps = phi->getNumOperands(); Op != NumOps; ++Op)
      if (phi->getIncomingBlock(Op) == BB) {
        Found = true;
        phi->setIncomingValue(Op, V);
      }
    (void)Found;
    assert(Found && "Invalid basic block argument to set!");
}

bool SubroutineInjection::hasNPredecessorsOrMore(const BasicBlock* BB, unsigned N) {
  return hasNItemsOrMore(pred_begin(BB), pred_end(BB), N);
}

bool
SubroutineInjection::injectSubroutines(
  Module &M,
  const LiveValues::TrackedValuesResult &funcBBTrackedValsMap,
  const LiveValues::LivenessResult &funcBBLiveValsMap
)
{
  bool isModified = false;
  for (auto &F : M.getFunctionList())
  {

    // Check function linkage
    // We do not analyze external functions
    if(F.getLinkage() == F.LinkOnceODRLinkage)
      continue;
    
    std::string funcName = JsonHelper::getOpName(&F, &M);
    std::cout << "\nFunction " << funcName << " ==== \n";
    if (!funcBBTrackedValsMap.count(&F))
    {
      std::cout << "No BB tracked values data for '" << funcName << "'\n";
      continue;
    }

    bool hasInjectedSubroutinesForFunc = false;
    long unsigned int defaultMinValsCount = 3;  // set to 3 to test response for split BB
    long unsigned int maxTrackedValsCount = getMaxNumOfTrackedValsForBBsInFunc(&F, funcBBTrackedValsMap);

    // get vars for instruction building
    LLVMContext &context = F.getContext();
    IRBuilder<> builder(context);

    while(!hasInjectedSubroutinesForFunc && defaultMinValsCount <= maxTrackedValsCount)
    {
      // ## 0: get candidate checkpoint BBs
      std::cout<< "##minValsCount=" << defaultMinValsCount << "\n";
      // filter for BBs that only have one successor.
      LiveValues::TrackedValuesResult filteredMap = getBBsWithOneSuccessor(funcBBTrackedValsMap);
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
      // store new added BBs (saveBB, restoreBB, junctionBB) for this current checkpoint, and the restoreControllerBB
      std::set<BasicBlock *> newBBs;

      // =============================================================================
      // ## 1: get pointers to Entry BB and checkpoint BBs
      std::cout << "Checkpoint BBs: \n";
      std::pair<BasicBlock*, std::set<BasicBlock*>> p = getEntryAndCkptBBsInFunc(&F, bbCheckpoints);
      BasicBlock* entryBB = p.first;
      std::set<BasicBlock*> checkpointBBPtrSet = p.second;

      // =============================================================================
      // ## 2. Add block on exit edge of entry block that leads to computation
      BasicBlock *restoreControllerBB = nullptr;
      BasicBlock *restoreControllerSuccessor = nullptr;
      std::vector<BasicBlock *> usefulSuccessorsList = getNonExitBBSuccessors(entryBB);
      for (uint32_t i = 0; i < usefulSuccessorsList.size(); i ++)
      {
        // Insert the new block into the edge between thisBB and a successorBB:
        BasicBlock *successorBB = usefulSuccessorsList[i];
        std::cout<<"successorBB = "<<JsonHelper::getOpName(successorBB, &M)<<"\n";
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

      // =============================================================================
      // ## 3: Add subroutines for each checkpoint BB, one checkpoint at a time:
      // store saveBB-checkpointBB pairing
      std::map<BasicBlock *, BasicBlock *> saveBBcheckpointBBMap;
      // store subroutine BBs for each checkpoint
      std::map<BasicBlock *, CheckpointTopo> checkpointBBTopoMap;

      // store live-out data for all saveBBs, restoreBBs and junctionBBs in current function.
      std::map<BasicBlock *, std::set<const Value *>> funcSaveBBsLiveOutMap;
      std::map<BasicBlock *, std::set<const Value *>> funcRestoreBBsLiveOutMap;
      std::map<BasicBlock *, std::set<const Value *>> funcJunctionBBsLiveOutMap;

      // store map<junctionBB, map<trackedVal, phi>>
      std::map<BasicBlock *, std::map<Value *, PHINode *>> funcJunctionBBPhiValsMap;

      for (auto bbIter : checkpointBBPtrSet)
      {
        BasicBlock *checkpointBB = &(*bbIter);
        std::string checkpointBBName = JsonHelper::getOpName(checkpointBB, &M).erase(0,1);
        std::vector<BasicBlock *> checkpointBBSuccessorsList = getBBSuccessors(checkpointBB);
        
        // -----------------------------------------------------------------------------
        // ### 3.1: Add saveBB on exit edge of checkpointed block
        for (auto succIter : checkpointBBSuccessorsList)
        {
          // Insert the new saveBB into the edge between thisBB and a successorBB:
          BasicBlock *successorBB = &*succIter;
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

          // -----------------------------------------------------------------------------
          // ### 3.2: For each successful saveBB, add restoreBBs and junctionBBs
          std::string checkpointBBName = JsonHelper::getOpName(checkpointBB, &M).erase(0,1);
          // create mediator BB as junction to combine output of saveBB and restoreBB
          BasicBlock *resumeBB = *(succ_begin(saveBB)); // saveBBs should only have one successor.
          BasicBlock *junctionBB = splitEdgeWrapper(saveBB, resumeBB, checkpointBBName + ".junctionBB", M);
          BasicBlock *restoreBB;
          if (junctionBB)
          {
            // create restoreBB for this saveBB
            restoreBB = BasicBlock::Create(context, checkpointBBName + ".restoreBB", &F, nullptr);
            // have successfully inserted all components (BBs) of subroutine
            BranchInst::Create(junctionBB, restoreBB);
            CheckpointTopo checkpointTopo = {
              .checkpointBB = checkpointBB,
              .saveBB = saveBB,
              .restoreBB = restoreBB,
              .junctionBB = junctionBB,
              .resumeBB = resumeBB
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
            /** TODO: remove saveBB for this checkpoint from CFG */
            continue; 
          }

          // ### 3.3: Populate saveBB and restoreBB with load and store instructions.
          std::set<const Value *> trackedVals = bbCheckpoints.at(checkpointBB);
        
          std::set<const Value *> saveBBLiveOutSet;
          std::set<const Value *> restoreBBLiveOutSet;
          std::set<const Value *> junctionBBLiveOutSet;

          // stores map<trackedVal, phi> pairings for current junctionBB
          std::map<Value *, PHINode *> trackedValPhiValMap;

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
            AllocaInst *allocaInstSave = new AllocaInst(valType, 0, "store."+valName+"_address", saveBBTerminator);   /** TODO: is placeholder for store address*/
            /** TODO: write save-address for value to file */
            StoreInst *storeInst = new StoreInst(trackedVal, allocaInstSave, false, saveBBTerminator);
            saveBBLiveOutSet.insert(storeInst);

            // Create instructions to load value from memory.
            Instruction *restoreBBTerminator = restoreBB->getTerminator();
            /** TODO: read save-address for value from file */
            AllocaInst *allocaInstRestore = new AllocaInst(valType, 0, "load."+valName+"_address", restoreBBTerminator);  /** TODO: is placeholder for load address*/
            LoadInst *loadInst = new LoadInst(valType, allocaInstRestore, "loaded." + valName, restoreBBTerminator);
            restoreBBLiveOutSet.insert(loadInst);

            // #### 3.1: Add phi node into junctionBB to merge loaded val & original val
            PHINode *phi = PHINode::Create(loadInst->getType(), 2, "new."+valName, junctionBB->getTerminator());
            phi->addIncoming(trackedVal, saveBB);
            phi->addIncoming(loadInst, restoreBB);
            junctionBBLiveOutSet.insert(phi);
            trackedValPhiValMap[trackedVal] = phi; 
          }

          funcSaveBBsLiveOutMap[saveBB] = saveBBLiveOutSet;
          funcRestoreBBsLiveOutMap[restoreBB] = restoreBBLiveOutSet;
          funcJunctionBBsLiveOutMap[junctionBB] = junctionBBLiveOutSet;

          funcJunctionBBPhiValsMap[junctionBB] = trackedValPhiValMap;

          // -----------------------------------------------------------------------------
          // ### 3.4: Propagate loaded values from restoreBB across CFG.
          for (auto iter : trackedVals)
          {
            Value *trackedVal = const_cast<Value*>(&*iter); /** TODO: verify safety of cast to non-const!! this is dangerous*/
            std::string valName = JsonHelper::getOpName(trackedVal, &M).erase(0,1);
            
            // for each BB, keeps track of versions of values that have been encountered in this BB (including the original value)
            std::map<BasicBlock *, std::set<Value *>> visitedBBs;

            // get phi value in junctionBB that merges original & loaded versions of trackVal
            PHINode *phi = funcJunctionBBPhiValsMap.at(junctionBB).at(trackedVal);

            propagateRestoredValuesBFS(resumeBB, junctionBB, trackedVal, phi,
                                      &newBBs, &visitedBBs,
                                      funcBBLiveValsMap, funcSaveBBsLiveOutMap, 
                                      funcRestoreBBsLiveOutMap, funcJunctionBBsLiveOutMap);
          }

          // clear newBBs set after this checkpoint has been processed (to prepare for next checkpoint)
          newBBs.erase(saveBB);
          newBBs.erase(restoreBB);
          newBBs.erase(junctionBB);
        }
        break; // FOR TESTING (limits to 1 checkpoint)
      }

      // =============================================================================
      // ## 4: Add checkpoint IDs to saveBBs and restoreBBs
      CheckpointIdBBMap checkpointIDsaveBBsMap = getCheckpointIdBBMap(checkpointBBTopoMap, M);
      printCheckpointIdBBMap(checkpointIDsaveBBsMap, &F);

      // =============================================================================
      // ## 5: Populate restoreControllerBB with switch instructions.
      /**
        TODO: Implement switch statement to load & check Checkpoint ID
        a. if CheckpointID indicates no checkpoint has been saved, continue to computation.
        b. if CheckpointID exists, jump to restoreBB for that CheckpointID.
      */
      
      // =============================================================================
      /** TODO: load CheckpointID from memory*/
      Instruction *terminatorInst = restoreControllerBB->getTerminator();
      /** TODO: insert instruction to load checkpoint ID into checkpointIDValue*/
      AllocaInst *allocaCheckpointID = new AllocaInst(Type::getInt8Ty(context), 0, "load.CheckpointID_address", terminatorInst);  /** TODO: is placeholder for loaded checkpoint id value*/
      LoadInst *loadCheckpointID = new LoadInst(Type::getInt8Ty(context), allocaCheckpointID, "loaded.CheckpointID", terminatorInst);

      // =============================================================================      
      // ## 6: create switch instruction in restoreControllerBB
      unsigned int numCases = checkpointIDsaveBBsMap.size();
      SwitchInst *switchInst = builder.CreateSwitch(loadCheckpointID, restoreControllerSuccessor, numCases);
      ReplaceInstWithInst(terminatorInst, switchInst);
      for (auto iter : checkpointIDsaveBBsMap)
      {
        ConstantInt *checkpointID = ConstantInt::get(Type::getInt8Ty(context), iter.first);
        CheckpointTopo checkpointTopo = iter.second;
        BasicBlock *restoreBB = checkpointTopo.restoreBB;
        switchInst->addCase(checkpointID, restoreBB); // insert new jump to basic block
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
SubroutineInjection::propagateRestoredValuesBFS(BasicBlock *startBB, BasicBlock *prevBB, Value *oldVal, Value *newVal,
                                                std::set<BasicBlock *> *newBBs,
                                                // std::set<BasicBlock *> *visitedBBs,
                                                std::map<BasicBlock *, std::set<Value *>> *visitedBBs,
                                                const LiveValues::LivenessResult &funcBBLiveValsMap,
                                                std::map<BasicBlock *, std::set<const Value *>> &funcSaveBBsLiveOutMap,
                                                std::map<BasicBlock *, std::set<const Value *>> &funcRestoreBBsLiveOutMap,
                                                std::map<BasicBlock *, std::set<const Value *>> &funcJunctionBBsLiveOutMap)
{
  std::queue<SubroutineInjection::BBUpdateRequest> q;

  // track versions of values in current "thread/path" of propagation
  std::set<Value *> valueVersions;
  valueVersions.insert(oldVal);
  valueVersions.insert(newVal);

  SubroutineInjection::BBUpdateRequest updateRequest = {
    .startBB = startBB,
    .currBB = startBB,
    .prevBB = prevBB,
    .oldVal = oldVal,
    .newVal = newVal,
    .valueVersions = valueVersions
  };
  q.push(updateRequest);
  
  while(!q.empty())
  {
    SubroutineInjection::BBUpdateRequest updateRequest = q.front();
    q.pop();
    processUpdateRequest(updateRequest, &q, newBBs, visitedBBs,
                        funcBBLiveValsMap, funcSaveBBsLiveOutMap,
                        funcRestoreBBsLiveOutMap, funcJunctionBBsLiveOutMap);
  }
}

void
SubroutineInjection::processUpdateRequest(SubroutineInjection::BBUpdateRequest updateRequest,
                                          std::queue<SubroutineInjection::BBUpdateRequest> *q,
                                          std::set<BasicBlock *> *newBBs,
                                          // std::set<BasicBlock *> *visitedBBs,
                                          std::map<BasicBlock *, std::set<Value *>> *visitedBBs,
                                          const LiveValues::LivenessResult &funcBBLiveValsMap,
                                          std::map<BasicBlock *, std::set<const Value *>> &funcSaveBBsLiveOutMap,
                                          std::map<BasicBlock *, std::set<const Value *>> &funcRestoreBBsLiveOutMap,
                                          std::map<BasicBlock *, std::set<const Value *>> &funcJunctionBBsLiveOutMap)
{
  BasicBlock *startBB = updateRequest.startBB;
  BasicBlock *currBB = updateRequest.currBB;
  BasicBlock *prevBB = updateRequest.prevBB;
  Value *oldVal = updateRequest.oldVal;
  Value *newVal = updateRequest.newVal;
  std::set<Value *> valueVersions = updateRequest.valueVersions;

  Function *F = currBB->getParent();
  LLVMContext &context = F->getContext();
  Module *M = F->getParent();

  std::cout<<"---\n";
  std::cout<<"prevBB:{"<<JsonHelper::getOpName(prevBB, M)<<"}\n";
  std::cout<<"currBB:{"<<JsonHelper::getOpName(currBB, M)<<"}\n";
  std::cout<<"oldVal="<<JsonHelper::getOpName(oldVal, M)<<"; newVal="<<JsonHelper::getOpName(newVal, M)<<"\n";

  // stop after we loop back to (and re-process) startBB
  bool isStop = currBB == startBB && visitedBBs->count(currBB);
  std::cout<<"isStop="<<isStop<<"\n";

  // tracks versions of values that have been encountered in this BB
  std::set<Value *> bbValueVersions = getOrDefault(currBB, visitedBBs);  // mark BB as visited (if not already)
  bbValueVersions.insert(oldVal); // if bbValueVersions was default (empty), then this will insert oldVal for the first time

  std::cout<<"@@@ valueVersions: (";
  for (auto valIter : valueVersions)
  {
    Value *val = &*valIter;
    std::cout<<JsonHelper::getOpName(val, M)<<", ";
  }
  std::cout<<")"<<std::endl;

  std::cout<<"@@@ bbValueVersions: (";
  for (auto valIter : bbValueVersions)
  {
    Value *val = &*valIter;
    std::cout<<JsonHelper::getOpName(val, M)<<", ";
  }
  std::cout<<")"<<std::endl;

  // return if val versions in valueVersions and bbValueVersions match exactly.
  bool isAllContained = true;
  for (auto valIter : bbValueVersions)
  {
    isAllContained = isAllContained && valueVersions.count(&*valIter);
  }
  if (isAllContained && bbValueVersions.size() == valueVersions.size()) isStop = true;

  // if reached exit BB, do not process request
  if (currBB->getTerminator()->getNumSuccessors() == 0) return;

  if (!newBBs->count(currBB) 
      && hasNPredecessorsOrMore(currBB, 2)
      && numOfPredsWithVarInLiveOut(currBB, oldVal, funcBBLiveValsMap, funcSaveBBsLiveOutMap, funcRestoreBBsLiveOutMap, funcJunctionBBsLiveOutMap))
  {

    if (isPhiInstExistForIncomingBBForTrackedVal(valueVersions, currBB, prevBB))
    {
      std::cout<<"MODIFY EXISTING PHI NODE\n";
      // modify existing phi input from %oldVal to %newVal
      PHINode *targetPhi = nullptr;
      for (auto phiIter = currBB->phis().begin(); phiIter != currBB->phis().end(); phiIter++)
      {
        PHINode *phi = &*phiIter;
        for (unsigned i = 0; i < phi->getNumIncomingValues(); i++)
        {
          Value *incomingValue = phi->getIncomingValue(i);
          BasicBlock *incomingBB = phi->getIncomingBlock(i);
          if (incomingBB == prevBB && valueVersions.count(incomingValue))
          {
            if (incomingValue == newVal)
            {
              // we've already updated this phi instruction to use newVal in a previous traversal path
              // do not add successors to BFS queue again.
              isStop = true;
            }
            else
            {
              targetPhi = phi;
              setIncomingValueForBlock(phi, incomingBB, newVal);
              valueVersions.insert(targetPhi); // if-condi ensures that targetPhi is never null
              bbValueVersions.insert(targetPhi);
              bbValueVersions.insert(newVal);
              updateMapEntry(currBB, bbValueVersions, visitedBBs);

              std::string phiName = JsonHelper::getOpName(phi, M);
              std::string incomingBBName = JsonHelper::getOpName(incomingBB, M);
              std::string valueName = JsonHelper::getOpName(incomingValue, M);
              std::string newValName = JsonHelper::getOpName(newVal, M);
              std::cout<<"modify "<<phiName<<": change ["<<valueName<<", "<<incomingBBName<<"] to ["<<newValName<<", "<<incomingBBName<<"]\n";
            }
          }
        }
      }
      
      if (!isStop)
      {
        // add direct successors of BB to queue (convert oldVal to newVal)
        for (BasicBlock *succBB : getBBSuccessors(currBB))
        {
          if (succBB != currBB)
          {
            SubroutineInjection::BBUpdateRequest newUpdateRequest = {
            .startBB = startBB,
            .currBB = succBB,
            .prevBB = currBB,
            .oldVal = oldVal,
            .newVal = targetPhi, // if-condi ensures that targetPhi is never null
            .valueVersions = valueVersions
            };
            q->push(newUpdateRequest);
          }
        }
      }

    }
    else
    {
      std::cout<<"ADD NEW PHI NODE\n";      
      // make new phi node
      std::string bbName = JsonHelper::getOpName(currBB, M).erase(0,1);
      std::string newValName = JsonHelper::getOpName(newVal, M).erase(0,1);
      std::vector<BasicBlock *> predecessors = getBBPredecessors(currBB);
      Instruction *firstInst = &*(currBB->begin());
      PHINode *phiOutput = PHINode::Create(oldVal->getType(), predecessors.size(), newValName + ".phi", firstInst);
      std::cout<<"added new phi: "<<JsonHelper::getOpName(dyn_cast<Value>(phiOutput), M)<<"\n";
      for (BasicBlock *predBB : predecessors)
      {
        // if pred has exit edge to startBB, add new entry in new phi instruction.
        Value *phiInput = (predBB == prevBB) ? newVal : oldVal;
        std::cout<<"  add to phi: {"<<JsonHelper::getOpName(phiInput, M)<<", "<<JsonHelper::getOpName(predBB, M)<<"}\n";
        phiOutput->addIncoming(phiInput, predBB);
        bbValueVersions.insert(phiInput);
      }

      // update each subsequent instruction in this BB from oldVal to phiOutput
      for (auto instIter = currBB->begin(); instIter != currBB->end(); instIter++)
      {
        Instruction *inst = &*instIter;
        if (inst != dyn_cast<Instruction>(phiOutput))
        {
          std::cout<<"  try updating inst '"<<JsonHelper::getOpName(dyn_cast<Value>(inst), M)<<"'\n";
          // don't update new phi instruction
          replaceOperandsInInst(inst, oldVal, phiOutput);
        }
        if (valueVersions.count(inst)) isStop = true;  // inst is a definition of one of the value versions.
      }
      valueVersions.insert(phiOutput);
      bbValueVersions.insert(phiOutput);
      updateMapEntry(currBB, bbValueVersions, visitedBBs);

      if (!isStop)
      {
        // add direct successors of BB to queue (convert oldVal to phiOutput)
        for (BasicBlock *succBB : getBBSuccessors(currBB))
        {
          if (succBB != currBB)
          {
            SubroutineInjection::BBUpdateRequest newUpdateRequest = {
              .startBB = startBB,
              .currBB = succBB,
              .prevBB = currBB,
              .oldVal = oldVal,
              .newVal = phiOutput,
              .valueVersions = valueVersions
            };
            q->push(newUpdateRequest);
          }
        }
      }
    }

  }
  else
  {
    // update instructions in BB
    for (auto instIter = currBB->begin(); instIter != currBB->end(); instIter++)
    {
      Instruction *inst = &*instIter;
      replaceOperandsInInst(inst, oldVal, newVal);
      if (valueVersions.count(inst)) isStop = true;  // inst is a definition of one of the value versions.
    }
    bbValueVersions.insert(newVal);
    updateMapEntry(currBB, bbValueVersions, visitedBBs);

    if (!isStop)
    {
      // add direct successors of BB to queue (convert oldVal to newVal)
      for (BasicBlock *succBB : getBBSuccessors(currBB))
      {
        if (succBB != currBB)
        {
          SubroutineInjection::BBUpdateRequest newUpdateRequest = {
            .startBB = startBB,
            .currBB = succBB,
            .prevBB = currBB,
            .oldVal = oldVal,
            .newVal = newVal,
            .valueVersions = valueVersions
          };
          q->push(newUpdateRequest);
        }
      }
    }
  }
}

void
SubroutineInjection::updateMapEntry(BasicBlock *key, std::set<Value *> newVal, std::map<BasicBlock *, std::set<Value *>> *map)
{
  if (map->count(key))
  {
    // map::emplace will silently fail if key already exists in map, so we delete the key first.
    map->erase(key);
  }
  map->emplace(key, newVal);
}

std::set<Value *>
SubroutineInjection::getOrDefault(BasicBlock *key, std::map<BasicBlock *, std::set<Value *>> *map)
{
  if (!map->count(key))
  {
    // if key not present, emplace and initialise key-value pair
    std::set<Value *> emptySet;
    map->emplace(key, emptySet);
  }
  return map->at(key);
}

unsigned
SubroutineInjection::numOfPredsWithVarInLiveOut(BasicBlock *BB, Value *val, const LiveValues::LivenessResult &funcBBLiveValsMap,
                                                std::map<BasicBlock *, std::set<const Value *>> &funcSaveBBsLiveOutMap,
                                                std::map<BasicBlock *, std::set<const Value *>> &funcRestoreBBsLiveOutMap,
                                                std::map<BasicBlock *, std::set<const Value *>> &funcJunctionBBsLiveOutMap)
{
  unsigned count = 0;
  Function *F = BB->getParent();
  for (auto iter = pred_begin(BB); iter != pred_end(BB); iter++)
  {
    BasicBlock *pred = *iter;
    std::set<const Value *> liveOutSet;
    if (funcJunctionBBsLiveOutMap.count(pred))
    {
      // pred is a junctionBB
      liveOutSet = funcJunctionBBsLiveOutMap.at(pred);
    }
    else if (funcSaveBBsLiveOutMap.count(pred)) {
      // pred is a saveBB
      liveOutSet = funcSaveBBsLiveOutMap.at(pred);
    }
    else if (funcRestoreBBsLiveOutMap.count(pred))
    {
      // pred is a restoreBB
      liveOutSet = funcRestoreBBsLiveOutMap.at(pred);
    }
    else if (funcBBLiveValsMap.at(F).count(pred))
    {
      // pred is an original BB
      liveOutSet = funcBBLiveValsMap.at(F).at(pred).liveOutVals;
    }

    if (liveOutSet.count(val)) count ++;
  }
  return count;
}

bool
SubroutineInjection::isPhiInstExistForIncomingBBForTrackedVal(std::set<Value *> valueVersions, BasicBlock *currBB, BasicBlock *prevBB)
{
  for (auto phiIter = currBB->phis().begin(); phiIter != currBB->phis().end(); phiIter++)
  {
    PHINode *phi = &*phiIter;
    for (unsigned i = 0; i < phi->getNumIncomingValues(); i++)
    {
      Value *incomingValue = phi->getIncomingValue(i);
      BasicBlock *incomingBB = phi->getIncomingBlock(i);
      if (incomingBB == prevBB && valueVersions.count(incomingValue))
      {
        return true;
      }
    }
  }
  return false;
}

bool
SubroutineInjection::isPhiInstForValExistInBB(Value *val, BasicBlock *BB)
{
  for (auto phiIter = BB->phis().begin(); phiIter != BB->phis().end(); phiIter++)
  {
    PHINode *phi = &*phiIter;
    User::op_iterator operandIter;
    for (operandIter = phi->op_begin(); operandIter != phi->op_end(); operandIter++)
    {
      const Value *operand = *operandIter;
      if (operand == val) return true; 
    }
  }
  return false;
}

bool
SubroutineInjection::replaceOperandsInInst(Instruction *inst, Value *oldVal, Value *newVal)
{
  bool hasReplaced = false;
  Module *M = inst->getParent()->getParent()->getParent();
  User::op_iterator operandIter;
  for (operandIter = inst->op_begin(); operandIter != inst->op_end(); operandIter++)
  {
    const Value *value = *operandIter;
    std::string valName = JsonHelper::getOpName(value, M);
    // std::cout<<"\n\n*** "<<JsonHelper::getOpName(value, M)<<"\n\n";
    if (value == oldVal)
    {
      // replace old operand with new operand
      *operandIter = newVal;
      hasReplaced = true;
      std::string newValName = JsonHelper::getOpName(*operandIter, M);
      std::cout << "Replacement: OldVal=" << valName << "; NewVal=" << newValName << "\n";
    }
  }
  return hasReplaced;
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
    if (isEntryBlock(bb_ptr))
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
SubroutineInjection::getBBPredecessors(BasicBlock *BB) const
{
  std::vector<BasicBlock *> BBPredecessorsList;
  for (auto pit = pred_begin(BB); pit != pred_end(BB); pit++)
  {
    BasicBlock *pred = *pit;
    BBPredecessorsList.push_back(pred);
  }
  return BBPredecessorsList;
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
    int grandChildCount = successor->getTerminator()->getNumSuccessors();
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
  //BasicBlock *insertedBB = SplitEdge(edgeStartBB, edgeEndBB, nullptr, nullptr, nullptr, checkpointName);
  BasicBlock *insertedBB = SplitEdge(edgeStartBB, edgeEndBB, nullptr, nullptr);
  insertedBB->setName(checkpointName);
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
                                      if (isEntryBlock(a.first)) return false;
                                      if (isEntryBlock(b.first)) return true;
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
      if (BB->getTerminator()->getNumSuccessors() == 1)
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
