#ifndef _JSON_HELPER_H
#define _JSON_HELPER_H

#include <iostream>
#include <fstream>
#include <sys/stat.h>

#include "json/json.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"
#include "popcorn_compiler/LiveValues.h"
#include "dale_passes/SubroutineInjection.h"

namespace llvm {

  static const std::string LIVENESS_JSON_PATH = "live_values.json";
  static const std::string TRACKED_VALS_JSON_PATH = "tracked_values.json";
  static const std::string CKPT_SIZES_JSON_PATH = "ckpt_sizes_bytes.json";

class JsonHelper {

public:
    /**
   * Default constructor.
   */
  JsonHelper(void);

  /**
   * Default destructor.
   */
  ~JsonHelper(void) {}

  /* ========== Tracked Vals Data ========== */

  /* Store tracked live values for all functions. */
  using TrackedValuesResult = LiveValues::TrackedValuesResult;
  
  /* Store tracked live values for basic block in json string format */
  using BBTrackedVals_JSON = LiveValues::BBTrackedVals_JSON;
  /* Store tracked live values for all functions in json string format */
  using TrackedValuesMap_JSON = LiveValues::TrackedValuesMap_JSON;

  /* Load tracked values from json file into the in-memory map jsonMap. */
  static void
  loadTrackedValuesJsonObjToJsonMap(Json::Value root, TrackedValuesMap_JSON &jsonMap);

  /* Updates the in-memory map jsonMap with Tracked Values for this function.*/
  static void
  updateJsonMapWithFuncTrackedValues(TrackedValuesMap_JSON &jsonMap,
                                    TrackedValuesResult &trackedValsMap,
                                    Function *F);

  /* Write in-memory map jsonMap back into in-memory json obj*/
  static void
  writeJsonMapToJsonObj(TrackedValuesMap_JSON &jsonMap, Json::Value &root);

  /* Write in-memory json obj to json file. */
  static void
  writeJsonObjToFile(Json::Value &root, std::string filename);

  /* Performs JSON operations to write analysis results to json file. */
  static void
  doTrackedValsJson(std::string filename, TrackedValuesResult &FuncBBTrackedVals,
        TrackedValuesMap_JSON &FuncBBTrackedVals_JSON, Function *F);

  /* Prints in-memory map jsonMap to console. */
  static void
  printJsonMap(TrackedValuesMap_JSON &jsonMap);

  static JsonHelper::TrackedValuesMap_JSON
  getTrackedValuesResultsFromJson(const std::string filename);

  /* Constructs Module-level FuncBBTrackedValsMap from live values in Json */
  static LiveValues::TrackedValuesResult
  getFuncBBTrackedValsMap(
    const SubroutineInjection::FuncValuePtrsMap &funcValuePtrsMap,
    const LiveValues::TrackedValuesMap_JSON &jsonMap,
    Module &M
  );

  /* ========== Live-in Live-out Vals Data ========== */

  /* Store live values for all functions. */
  using LivenessResult = LiveValues::LivenessResult;

  using LiveInOutData_JSON = LiveValues::LiveInOutData_JSON;
  /* Store live values for basic block in json string format */
  using BBLiveVals_JSON = LiveValues::BBLiveVals_JSON;
  /* Store live values for all functions in json string format */
  using LiveValuesMap_JSON = LiveValues::LiveValuesMap_JSON;

  /* Load live values from json file into the in-memory map jsonMap. */
  static void
  loadLiveValuesJsonObjToJsonMap(Json::Value root, LiveValuesMap_JSON &jsonMap);

  /* Updates the in-memory map jsonMap with live Values for this function.*/
  static void
  updateJsonMapWithFuncLiveValues(LiveValuesMap_JSON &jsonMap,
                                  LivenessResult &liveValsMap,
				                          LiveValues::VariableDefMap &mapVars,
                                  Function *F);

  /* Write in-memory map jsonMap back into in-memory json obj*/
  static void
  writeJsonMapToJsonObj(LiveValuesMap_JSON &jsonMap, Json::Value &root);

  static void
  doLiveValsJson(std::string filename, LivenessResult &FuncLiveVals,
                LiveValues::VariableDefMap &mapVars,
                LiveValuesMap_JSON &FuncBBLiveVals_JSON, Function *F);

  static void
  printJsonMap(LiveValuesMap_JSON &json_map);

  static JsonHelper::LiveValuesMap_JSON
  getLiveValuesResultsFromJson(const std::string filename);

  /* 
  * Constructs:
  * 1) Module-level FuncBBLiveValsMap from live values in Json 
  * 2) Module-level FuncVariableDefMap from live values in json. For each function, 
  * this contains the sizes (#bytes) of live-in/out values for all BBs in function.
  */
  static std::pair<LiveValues::LivenessResult, LiveValues::FuncVariableDefMap>
  getFuncBBLiveValsInfo(
    const SubroutineInjection::FuncValuePtrsMap &funcValuePtrsMap,
    const LiveValues::LiveValuesMap_JSON &jsonMap,
    Module &M
  );

  /* ========== Checkpoint Size Data ==========*/

  using CkptSizeMap = std::map<BasicBlock *, int>;
  using FuncCkptSizeMap = std::map<Function *, CkptSizeMap>; 

  static void
  writeFuncCkptSizesToJson(FuncCkptSizeMap funcCkptSizeMap, std::string filename);

  /* ========== Utilility Methods ========== */

  /* 
  Gets the llvm::Value name captured from Value::printAsOperand().
  Value names (e.g. %0) do not exist in memory; they're only generated 
  during the printAsOperand() function call.
  */
  static std::string
  getOpName(const Value *value_ptr, const Module *M);

  /* 
    Gets the llvm::BasicBlock name captured from Value::printAsOperand().
    Value names (e.g. %0) do not exist in memory; they're only generated 
    during the printAsOperand() function call.
  */
  static std::string
  getOpName(const BasicBlock *bb_ptr, const Module *M);

  static std::string
  getOpName(const Function *func_ptr, const Module *M);

};

} /* llvm namespace */

#endif /* _JSON_HELPER_H */
