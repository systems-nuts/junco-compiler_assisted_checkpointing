/**
 * Does DFS on BB CFG for each Function in Module.
 * For each BB, finds the "modified values" that are stored within the BB via store instructions.
 * Each predecessor BB propagates its "modified values" to all its successor BBs.
 * Modified Values are stored in a map with key as BB and value as set of modified values.
 */

#include "dale_passes/ModuleTransformationPass.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Dominators.h" // test
#include "llvm/ADT/DepthFirstIterator.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Support/Debug.h"

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
      true, // This pass doesn't modify the CFG => true
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
  AU.addRequired<LiveValues>();
  AU.addRequired<DominatorTreeWrapperPass>();
  AU.setPreservesAll();
}

bool ModuleTransformationPass::runOnModule(Module &M)
{
  std::cout << "Module Transformation Pass printout" << std::endl;

  // load Tracked values analysis results.
  FuncBBTrackedValsByName = getAnalysisResultsFromJson("tracked_values.json");
  LiveValues::printJsonMap(FuncBBTrackedValsByName);

  std::cout << "===========\n";
  CheckpointsMap = chooseBBWithLeastTrackedVals(FuncBBTrackedValsByName);
  printCheckPointBBs(CheckpointsMap);

  for (auto &F : M.getFunctionList())
  {
    std::string funcName = F.getName().str();
    if (!CheckpointsMap.count(funcName))
    {
      std::cerr << "No BB Checkpointing data for '" << funcName << "'\n";
      continue;
    }
    CheckpointBBMap bbCheckpoints = CheckpointsMap.at(funcName);
    
    // Do name matching (check Value name against checkpointed BB name)
  }

  return false;
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

ModuleTransformationPass::CheckpointFuncBBMap
ModuleTransformationPass::chooseBBWithLeastTrackedVals(const LiveValues::TrackedValuesMap_JSON &jsonMap) const
{ 
  CheckpointFuncBBMap cpFuncBBMap;
  
  LiveValues::TrackedValuesMap_JSON::const_iterator funcIter;
  for (funcIter = jsonMap.cbegin(); funcIter != jsonMap.cend(); funcIter++)
  {
    CheckpointBBMap cpBBMap;
    std::string funcName = funcIter->first;
    LiveValues::BBTrackedVals_JSON bbTrackedVals = funcIter->second;

    // Find min number of live values that is > 0 (search across all BBs)
    auto minElem = std::min_element(bbTrackedVals.cbegin(), bbTrackedVals.cend(),
                    [](const auto &a,
                       const auto &b)
                       {
                        // return true if a < b
                        if (a.second.size() == 0) return false;
                        if (b.second.size() == 0) return true;
                        return a.second.size() < b.second.size();
                       });

    std::cout << "(" << funcName << " BB minSize=" << (minElem->second).size() << ")\n";
    auto minSize = (minElem->second).size();
    if (minSize != 0)
    {
      // For each BB with this number of live values, add entry into cpBBMap.
      LiveValues::BBTrackedVals_JSON::const_iterator bbIt;
      std::set<std::string>::const_iterator valIt;
      for (bbIt = bbTrackedVals.cbegin(); bbIt != bbTrackedVals.cend(); bbIt++)
      {
        std::string bbName = bbIt->first;
        const std::set<std::string> &trackedVals = bbIt->second;
        // get element of trackedVals with smallest set size
        if (trackedVals.size() == minSize)
        {
          cpBBMap.emplace(bbName, trackedVals);
        }
      }
    } // emplace empty map if no BBs in func have live values.
    cpFuncBBMap.emplace(funcName, cpBBMap);
  }
  return cpFuncBBMap;
}

void
ModuleTransformationPass::printCheckPointBBs(const CheckpointFuncBBMap &fBBMap) const
{
  CheckpointFuncBBMap::const_iterator funcIt;
  CheckpointBBMap::const_iterator bbIt;
  std::set<std::string>::const_iterator valIt;
  for (funcIt = fBBMap.cbegin(); funcIt != fBBMap.cend(); funcIt++){
    const std::string funcName = funcIt->first;
    const CheckpointBBMap bbMap = funcIt->second;

    std::cout << "Checkpoint candidate BBs for '" << funcName << "':\n";
    for (bbIt = bbMap.cbegin(); bbIt != bbMap.cend(); bbIt++)
    {
      const std::string bbName = bbIt->first;
      const std::set<std::string> vals = bbIt->second;
      std::cout << "  BB: " << bbName << "\n    ";
    
      for (valIt = vals.cbegin(); valIt != vals.cend(); valIt++)
      {
        std::string valName = *valIt;
        std::cout << valName << " ";
      }
      std::cout << '\n';
    }
    std::cout << "\n";
  }

  return;
}