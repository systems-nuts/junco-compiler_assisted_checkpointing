/*
 * Calculate live-value sets for functions.
 *
 * Liveness-analysis is based on the non-iterative dataflow algorithm for
 * reducible graphs by Brandner et. al in:
 *
 * "Computing Liveness Sets for SSA-Form Programs"
 * URL: https://hal.inria.fr/inria-00558509v1/document
 * Accessed: 5/19/2016
 *
 * Author: Rob Lyerly <rlyerly@vt.edu>
 * Date: 5/19/2016
 * 
 * Modified by: Dale Huang
 *
 * Run with:
 * <llvm-installation-dir>/bin/opt -enable-new-pm=0 -load \
 *  <path/to/build/libs>/libLiveValues.so -live-values -analyze \
 *  <path/to/input/bc/file>
 */


#include "popcorn_compiler/LiveValues.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/CFG.h"
#include "llvm/Analysis/CFG.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/ADT/PostOrderIterator.h"
#include "llvm/ADT/SCCIterator.h"
#include "llvm/Support/Debug.h"

#include <iostream>

#include <string>
#include <sys/stat.h>
#include <fstream>

#define DEBUG_TYPE "live-values"

using namespace llvm;

char LiveValues::ID = 0;

// This is the core interface for pass plugins. It guarantees that 'opt' will
// recognize LegacyHelloWorld when added to the pass pipeline on the command
// line, i.e.  via '--legacy-hello-world'
static RegisterPass<LiveValues>
    X("live-values", "Live Values Pass",
      true, // This pass doesn't modify the CFG => true
      false // This pass is not a pure analysis pass => false
    );


namespace llvm {
  FunctionPass *createLiveValuesPass() { return new LiveValues(); }
}

///////////////////////////////////////////////////////////////////////////////
// Public API
///////////////////////////////////////////////////////////////////////////////

LiveValues::LiveValues(void)
  : FunctionPass(ID), inlineasm(false), bitcasts(true), comparisons(true),
    constants(false), metadata(false) {}

// This method defines how this pass interacts with other passes
void LiveValues::getAnalysisUsage(AnalysisUsage &AU) const
{
  // Request results from LoopInfoWrapperPass
  AU.addRequired<LoopInfoWrapperPass>();
  // We do not modify the input module
  AU.setPreservesAll();
}

bool LiveValues::runOnFunction(Function &F)
{
  // clear results from previous runs
  FuncBBTrackedVals.clear();
  FuncBBTrackedVals_JSON.clear();

  if(FuncBBLiveIn.count(&F))
  {
    std::cout << "\nFound previous analysis for LiveValues" << std::endl;
  }
  else
  {
    std::cout << "\n********** Beginning LiveValues **********\n"
              << "********** Function: LiveValues **********\n"
              << "\nLiveValues: performing bottom-up dataflow analysis\n" 
              << std::endl;

    LoopNestingForest LNF;
    FuncBBLiveIn.emplace(&F, LiveVals());
    FuncBBLiveOut.emplace(&F, LiveVals());

    /* 1. Compute partial liveness sets using a postorder traversal. */
    dagDFS(F, FuncBBLiveIn[&F], FuncBBLiveOut[&F]);

    std::cout << "LiveValues: constructing loop-nesting forest\n" << std::endl;

    /* 2. Construct loop-nesting forest. */
    constructLoopNestingForest(F, LNF);

    std::cout << "LiveValues: propagating values within loop-nests\n" << std::endl;

    /* 3. Propagate live variables within loop bodies. */
    loopTreeDFS(LNF, FuncBBLiveIn[&F], FuncBBLiveOut[&F]);

    /* 4. Get the tracked values for each BB in this function. */
    getTrackedValues(&F);

    std::cout << "LiveValues: finished analysis\n" << std::endl;

    /* Print out Live-in, Live-out and TrackedValues results. */
    OS << "# Analysis for function '" << F.getName() << "'\n";
    print(OS, &F);

    /* Write/udpate json file with analysis results. */
    doJson("tracked_values.json", &F);  // writes to a file in build/lib
  }

  return false;
}

// NEW:
void
LiveValues::getTrackedValues(const Function *F)
{
  LiveVals::const_iterator bbIt;
  std::set<const Value *>::const_iterator valIt;

  if(FuncBBLiveOut.count(F))
  {
    LiveValues::BBTrackedVals *bbTrackedVals = new LiveValues::BBTrackedVals();

    // iterate through BBs in function F
    for(bbIt = FuncBBLiveOut.at(F).cbegin();
        bbIt != FuncBBLiveOut.at(F).cend();
        bbIt++)
    {
      const BasicBlock *BB = bbIt->first;
      const std::set<const Value *> &liveOutVals = bbIt->second;
      
      std::set<const Value *> *trackedVals = new std::set<const Value *>;
      
      // iterate through live-out vals in BB
      for(valIt = liveOutVals.cbegin(); valIt != liveOutVals.cend(); valIt++)
      {
        trackedVals->insert(*valIt);
      }
      bbTrackedVals->emplace(BB, *trackedVals);
    }
    FuncBBTrackedVals.emplace(F, *bbTrackedVals);
  }
}

/* ===================== JSON Driver Start ===================== */
// NEW:
/*
 * Every time we analyse a function, we:
 * 1. Read from JSON file
 * 2. Add entry to JSON-derived map
 * 3. Write new map to JSON file
 */
void
LiveValues::doJson(std::string filename, Function *F) {
  Json::Value root; // root will contain the root value

  struct stat buffer;
  if (stat (filename.c_str(), &buffer) == 0) {
    // file exists; open json file
    std::cout << "JSON File Exists\n";
    std::ifstream json_file(filename, std::ifstream::binary);
    json_file >> root;
    loadTrackedValuesJsonObjToJsonMap(root, FuncBBTrackedVals_JSON);
  } else {
    // file does not exist; make new json file
    std::cout << "JSON File does not exist\n";
    Json::Value emptyRoot = Json::objectValue;
    writeJsonObjToFile(emptyRoot, filename);
  }

  // Update JsonMap with tracked values information from this func:
  updateJsonMapWithFuncTrackedValues(FuncBBTrackedVals_JSON, FuncBBTrackedVals, F);
  // printJsonMap(FuncBBTrackedVals_JSON);

  // Write (overwrite) updated FunBBTrackedVals_JSON back to json file:
  writeJsonMapToJsonObj(FuncBBTrackedVals_JSON, root);
  writeJsonObjToFile(root, filename);
}

// NEW:
void
LiveValues::loadTrackedValuesJsonObjToJsonMap(
  Json::Value root,
  LiveValues::TrackedValuesMap_JSON &jsonMap)
{
  // read json data into map.
  Json::Value::const_iterator root_itr;
  Json::Value::const_iterator func_iter;
  Json::Value::const_iterator bb_iter;
  // iterate over funcs in json:
  for (root_itr = root.begin(); root_itr != root.end() ; root_itr++) 
  {
    std::string funcName = root_itr.key().asString();
    Json::Value funcBBs = root[funcName];
    // iterate over BBs in func:
    BBTrackedVals_JSON bbTrackedVals;
    for (func_iter = funcBBs.begin(); func_iter != funcBBs.end(); func_iter++) 
    {
      std::string bbName = func_iter.key().asString();
      Json::Value bbVals = funcBBs[bbName];
      // iterate over tracked vals in BB:
      std::set<std::string> trackedVals;
      for (bb_iter = bbVals.begin(); bb_iter != bbVals.end(); bb_iter++) 
      {
        std::string valName = bb_iter.key().asString();
        trackedVals.emplace(valName);
      }
      bbTrackedVals.emplace(bbName, trackedVals);
    }
    jsonMap.emplace(funcName, bbTrackedVals);
  }
}

// NEW:
void
LiveValues::updateJsonMapWithFuncTrackedValues(
  LiveValues::TrackedValuesMap_JSON &jsonMap,
  LiveValues::Result &trackedValsMap,
  Function *F)
{
  const Module *M = F->getParent();
  LiveVals::const_iterator bbIt;
  std::set<const Value *>::const_iterator valIt;
  if (trackedValsMap.count(F))
  {
    BBTrackedVals_JSON jsonBBTrackedVals;
    const std::string funcName = getFuncOpName(F, M);
    for(bbIt = trackedValsMap.at(F).cbegin();
        bbIt != trackedValsMap.at(F).cend();
        bbIt++)
    {
      std::set<std::string> jsonTrackedVals;
      std::string bbName = getBBOpName(bbIt->first, M);
      const std::set<const Value *> &trackedVals = bbIt->second;
      for(valIt = trackedVals.cbegin(); valIt != trackedVals.cend(); valIt++)
      {        
        // Capture printAsOperand output, since value names don't actually 
        // exist and are allocated only during printing.
        std::string valName = getValueOpName(*valIt, M);
        jsonTrackedVals.emplace(valName);
      }
      jsonBBTrackedVals.emplace(bbName, jsonTrackedVals);
    }
    // update / add to json map:
    jsonMap[funcName] = jsonBBTrackedVals;
  }
}

// NEW:
void
LiveValues::writeJsonMapToJsonObj(
  LiveValues::TrackedValuesMap_JSON &jsonMap, 
  Json::Value &root)
{
  TrackedValuesMap_JSON::const_iterator f_it;
  for (f_it = jsonMap.cbegin(); f_it != jsonMap.cend(); f_it++)
  {
    std::string funcName = f_it->first;
    BBTrackedVals_JSON bbTrackedVals = f_it->second;
    BBTrackedVals_JSON::const_iterator bb_it;
    if (bbTrackedVals.empty()) {
      root[funcName] = Json::objectValue;
      continue;
    }
    for (bb_it = bbTrackedVals.cbegin(); bb_it != bbTrackedVals.cend(); bb_it++)
    {
      std::string bbName = bb_it->first;
      std::set<std::string> trackedValsNames = bb_it->second;
      if (trackedValsNames.empty()) {
        root[funcName][bbName] = Json::objectValue;
        continue;
      }
      for (std::string valName : trackedValsNames)
      {
        std::string size = "";
        std::string type = "";
        root[funcName][bbName][valName]["size"] = size;
        root[funcName][bbName][valName]["type"] = type;
      }
    }
  }
}

// NEW:
void
LiveValues::writeJsonObjToFile(Json::Value &root, std::string filename)
{
  Json::StyledWriter styledWriter;
  std::ofstream outfile(filename);
  outfile << styledWriter.write(root);
  outfile.close();
}

// NEW:
std::string
LiveValues::getValueOpName(const Value *value_ptr, const Module *M)
{
  std::string valNameStr;
  raw_string_ostream rso(valNameStr);
  value_ptr->printAsOperand(rso, false, M);
  return rso.str();
}

// NEW:
std::string
LiveValues::getBBOpName(const BasicBlock *bb_ptr, const Module *M)
{
  std::string bbNameStr;
  raw_string_ostream rso(bbNameStr);
  bb_ptr->printAsOperand(rso, false, M);
  return rso.str();
}

std::string
LiveValues::getFuncOpName(const Function *func_ptr, const Module *M)
{
  std::string funcNameStr;
  raw_string_ostream rso(funcNameStr);
  func_ptr->printAsOperand(rso, false, M);
  return rso.str();
}

// NEW:
void
LiveValues::printJsonMap(TrackedValuesMap_JSON &json_map)
{
  TrackedValuesMap_JSON::const_iterator f_it;
  for (f_it = json_map.cbegin(); f_it != json_map.cend(); f_it++)
  {
    std::string funcName = f_it->first;
    BBTrackedVals_JSON bbTrackedVals = f_it->second;
    std::cout << funcName << ": \n";

    BBTrackedVals_JSON::const_iterator bb_it;
    for (bb_it = bbTrackedVals.cbegin(); bb_it != bbTrackedVals.cend(); bb_it++)
    {
      std::string bbName = bb_it->first;
      std::set<std::string> trackedVals = bb_it->second;
      std::cout << "  " << bbName << ": \n    ";

      for (std::string val : trackedVals)
      {
        std::cout << val << " ";
      }
      std::cout << "\n";
    }
  }
}
/* ===================== JSON Driver End ===================== */

// MODIFIED:
void
LiveValues::print(raw_ostream &O, const Function *F) const
{
  LiveVals::const_iterator bbIt;
  std::set<const Value *>::const_iterator valIt;
  const Module *M = F->getParent();

  O << "LiveValues: results of live-value analysis\n";

  if(!FuncBBLiveIn.count(F) || !FuncBBLiveOut.count(F))
  {
    if(F->hasName())
      O << "No liveness information for function " << F->getName() << "\n";
    else
      O << "No liveness information for requested function\n";
  }
  else
  {
    for(bbIt = FuncBBLiveIn.at(F).cbegin();
        bbIt != FuncBBLiveIn.at(F).cend();
        bbIt++)
    {
      const BasicBlock *BB = bbIt->first;
      const std::set<const Value *> &liveInVals = bbIt->second;
      const std::set<const Value *> &liveOutVals = FuncBBLiveOut.at(F).at(BB);

      O << "Results for BB ";
      BB->printAsOperand(O, false, M);
      O << ":";
      
      O << "\n  Live-in:\n    ";
      for(valIt = liveInVals.cbegin(); valIt != liveInVals.cend(); valIt++)
      {
        (*valIt)->printAsOperand(O, false, M);
        O << " ";
      }

      O << "\n  Live-out:\n    ";
      for(valIt = liveOutVals.cbegin(); valIt != liveOutVals.cend(); valIt++)
      {
        (*valIt)->printAsOperand(O, false, M);
        O << " ";
      }

      const std::set<const Value *> trackedVals = FuncBBTrackedVals.at(F).at(BB);
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

std::set<const Value *> *LiveValues::getLiveIn(const BasicBlock *BB) const
{
  const Function *F = BB->getParent();
  return new std::set<const Value *>(FuncBBLiveIn.at(F).at(BB));
}

std::set<const Value *> *LiveValues::getLiveOut(const BasicBlock *BB) const
{
  const Function *F = BB->getParent();
  return new std::set<const Value *>(FuncBBLiveOut.at(F).at(BB));
}

std::set<const Value *>
*LiveValues::getLiveValues(const Instruction *inst) const
{
  const BasicBlock *BB = inst->getParent();
  const Function *F = BB->getParent();
  BasicBlock::const_reverse_iterator ri, rie;
  std::set<const Value *> *live = nullptr;

  // Note: some functions have unreachable basic blocks (e.g., functions that
  // call exit and then return a value).  If we don't have analysis for the
  // block, return an empty set.
  const LiveVals &Blocks = FuncBBLiveOut.at(F);
  if(Blocks.count(BB)) live = new std::set<const Value *>(Blocks.at(BB));
  else return new std::set<const Value *>;

  for(ri = BB->rbegin(), rie = BB->rend(); ri != rie; ri++)
  {
    if(&*ri == inst) break;

    live->erase(&*ri);
    for(User::const_op_iterator op = ri->op_begin();
        op != ri->op_end();
        op++)
      if(includeVal(*op))
        live->insert(*op);
  }

  live->erase(&*ri);
  for(User::const_op_iterator op = ri->op_begin();
      op != ri->op_end();
      op++)
    if(includeVal(*op))
      live->insert(*op);

  return live;
}

///////////////////////////////////////////////////////////////////////////////
// Private API
///////////////////////////////////////////////////////////////////////////////

bool LiveValues::includeVal(const llvm::Value *val) const
{
  bool include = true;

  // TODO other values that should be filtered out?
  if(isa<BasicBlock>(val))
    include = false;
  else if(isa<InlineAsm>(val) && !inlineasm)
    include = false;
  else if(isa<BitCastInst>(val) && !bitcasts)
    include = false;
  else if(isa<CmpInst>(val) && !comparisons)
    include = false;
  else if(isa<Constant>(val) && !constants)
    include = false;
  else if(isa<MetadataAsValue>(val) && !metadata)
    include = false;

  return include;
}

unsigned LiveValues::phiUses(const BasicBlock *B,
                             const BasicBlock *S,
                             std::set<const Value *> &uses)
{
  const PHINode *phi;
  unsigned added = 0;

  for(BasicBlock::const_iterator it = S->begin(); it != S->end(); it++)
  {
    if((phi = dyn_cast<PHINode>(&*it))) {
      for(unsigned i = 0; i < phi->getNumIncomingValues(); i++)
        if(phi->getIncomingBlock(i) == B &&
           includeVal(phi->getIncomingValue(i)))
          if(uses.insert(phi->getIncomingValue(i)).second)
            added++;
    }
    else break; // phi-nodes are always at the start of the basic block
  }

  return added;
}

unsigned LiveValues::phiDefs(const BasicBlock *B,
                             std::set<const Value *> &uses)
{
  const PHINode *phi;
  unsigned added = 0;

  for(BasicBlock::const_iterator it = B->begin(); it != B->end(); it++)
  {
    if((phi = dyn_cast<PHINode>(&*it))) {
      if(includeVal(phi))
        if(uses.insert(&*it).second)
          added++;
    }
    else break; // phi-nodes are always at the start of the basic block
  }

  return added;
}

void LiveValues::dagDFS(Function &F, LiveVals &liveIn, LiveVals &liveOut)
{
  std::set<const Value *> live, phiDefined;
  std::set<Edge> loopEdges;
  SmallVector<Edge, 16> loopEdgeVec;

  /* Find loop edges & convert to set for existence checking. */
  FindFunctionBackedges(F, loopEdgeVec);
  for(SmallVectorImpl<Edge>::const_iterator eit = loopEdgeVec.begin();
      eit != loopEdgeVec.end();
      eit++)
    loopEdges.insert(*eit);

  /* Calculate partial liveness sets for CFG nodes. */
  for(auto B = po_iterator<const BasicBlock *>::begin(&F.getEntryBlock());
      B != po_iterator<const BasicBlock *>::end(&F.getEntryBlock());
      B++)
  {
    /* Calculate live-out set (lines 4-7 of Algorithm 2). */
    for(auto S = succ_begin(*B); S != succ_end(*B); S++)
    {
      // Note: skip self-loop-edges, as adding values from phi-uses of this
      // block causes use-def violations, and LLVM will complain.  This
      // shouldn't matter, as phi-defs will cover this case.
      if(*S == *B) continue;

      phiUses(*B, *S, live);
      if(!loopEdges.count(Edge(*B, *S)))
      {
        phiDefs(*S, phiDefined);
        for(std::set<const Value *>::const_iterator vi = liveIn[*S].begin();
            vi != liveIn[*S].end();
            vi++)
          if(!phiDefined.count(*vi) && includeVal(*vi)) live.insert(*vi);
        phiDefined.clear();
      }
    }
    liveOut.insert(LiveValsPair(*B, std::set<const Value *>(live)));

    /* Calculate live-in set (lines 8-11 of Algorithm 2). */
    for(BasicBlock::const_reverse_iterator inst = (*B)->rbegin();
        inst != (*B)->rend();
        inst++)
    {
      if(isa<PHINode>(&*inst)) break;

      live.erase(&*inst);
      for(User::const_op_iterator op = inst->op_begin();
          op != inst->op_end();
          op++)
        if(includeVal(*op)) live.insert(*op);
    }
    phiDefs(*B, live);
    liveIn.insert(LiveValsPair(*B, std::set<const Value *>(live)));

    live.clear();
  }
}

void LiveValues::constructLoopNestingForest(Function &F,
                                            LoopNestingForest &LNF)
{
  LoopInfo &LI = getAnalysis<LoopInfoWrapperPass>().getLoopInfo();

  for(scc_iterator<Function *> scc = scc_begin(&F);
      scc != scc_end(&F);
      ++scc)
  {
    const std::vector<BasicBlock *> &SCC = *scc;
    LNF.emplace_back(SCC, LI);

    std::cout << "Loop nesting tree: " << LNF.back().size() << " node(s), loop-nesting depth: " << LNF.back().depth() << std::endl;
  }
}

void LiveValues::propagateValues(const LoopNestingTree &loopNest,
                                 LiveVals &liveIn,
                                 LiveVals &liveOut)
{
  std::set<const Value *> liveLoop, phiDefined;

  /* Iterate over all loop nodes. */
  for(LoopNestingTree::loop_iterator loop = loopNest.loop_begin();
      loop != loopNest.loop_end();
      loop++)
  {
    /* Calculate LiveLoop (lines 3 & 4 of Algorithm 3). */
    phiDefs(*loop, phiDefined);
    for(std::set<const Value *>::const_iterator it = liveIn[*loop].begin();
        it != liveIn[*loop].end();
        it++)
      if(!phiDefined.count(*it) && includeVal(*it))
        liveLoop.insert(*it);

    /* Propagate values to children (lines 5-8 of Algorithm 3). */
    for(LoopNestingTree::child_iterator child = loopNest.children_begin(loop);
        child != loopNest.children_end(loop);
        child++) {
      for(std::set<const Value *>::const_iterator it = liveLoop.begin();
          it != liveLoop.end();
          it++) {
        liveIn[*child].insert(*it);
        liveOut[*child].insert(*it);
      }
    }

    liveLoop.clear();
  }
}

void LiveValues::loopTreeDFS(LoopNestingForest &LNF,
                             LiveVals &liveIn,
                             LiveVals &liveOut)
{
  LoopNestingForest::const_iterator it;
  for(it = LNF.begin(); it != LNF.end(); it++)
    propagateValues(*it, liveIn, liveOut);
}
