# THE LIST OF PLUGINS AND THE CORRESPONDING SOURCE FILES
# ======================================================
set(LLVM_DALE_PLUGINS
  ## llvm-tutor passes
  StaticCallCounter
  DynamicCallCounter
  FindFCmpEq
  ConvertFCmpEq
  InjectFuncCall
  MBAAdd
  MBASub
  RIV
  DuplicateBB
  OpcodeCounter
  MergeBB

  ## Liveness Analysis:
  LiveValues
  LoopNestingTree
  ## Modifiedness Analysis:
  ModifiedValues
  TrackValues
  ## Transformation:
  TransformationPass
  ModuleTransformationPass
  ## jsoncpp:
  jsoncpp
  )

set(StaticCallCounter_SOURCES
  StaticCallCounter.cpp)
set(DynamicCallCounter_SOURCES
  llvm_tutor_passes/DynamicCallCounter.cpp)
set(FindFCmpEq_SOURCES
  llvm_tutor_passes/FindFCmpEq.cpp)
set(ConvertFCmpEq_SOURCES
  llvm_tutor_passes/ConvertFCmpEq.cpp)
set(InjectFuncCall_SOURCES
  llvm_tutor_passes/InjectFuncCall.cpp)
set(MBAAdd_SOURCES
  llvm_tutor_passes/MBAAdd.cpp
  llvm_tutor_passes/Ratio.cpp)
set(MBASub_SOURCES
  llvm_tutor_passes/MBASub.cpp
  llvm_tutor_passes/Ratio.cpp)
set(RIV_SOURCES
  llvm_tutor_passes/RIV.cpp)
set(DuplicateBB_SOURCES
  llvm_tutor_passes/DuplicateBB.cpp)
set(OpcodeCounter_SOURCES
  llvm_tutor_passes/OpcodeCounter.cpp)
set(MergeBB_SOURCES
  llvm_tutor_passes/MergeBB.cpp)

## Liveness Analysis:
set(LiveValues_SOURCES
  popcorn_compiler/LiveValues.cpp)
set(LoopNestingTree_SOURCES
  popcorn_compiler/LoopNestingTree.cpp)

## Modifiedness Analysis:
set(ModifiedValues_SOURCES
  dale_passes/ModifiedValues.cpp)
set(TrackValues_SOURCES
  dale_passes/TrackValues.cpp)

## Transformation:
set(TransformationPass_SOURCES
  dale_passes/TransformationPass.cpp)
set(ModuleTransformationPass_SOURCES
  dale_passes/ModuleTransformationPass.cpp)

## jsoncpp:
set(jsoncpp_SOURCES 
  json/jsoncpp.cpp)


# CONFIGURE THE PLUGIN LIBRARIES
# ==============================
foreach( plugin ${LLVM_DALE_PLUGINS} )
    # Create a library corresponding to 'plugin'
    add_library(
      ${plugin}
      SHARED
      ${${plugin}_SOURCES}
      )

    # Configure include directories for 'plugin'
    target_include_directories(
      ${plugin}
      PRIVATE
      "${CMAKE_CURRENT_SOURCE_DIR}/../include"
    )

    # On Darwin (unlike on Linux), undefined symbols in shared objects are not
    # allowed at the end of the link-edit. The plugins defined here:
    #  - _are_ shared objects
    #  - reference symbols from LLVM shared libraries, i.e. symbols which are
    #    undefined until those shared objects are loaded in memory (and hence
    #    _undefined_ during static linking)
    # The build will fail with errors like this:
    #    "Undefined symbols for architecture x86_64"
    # with various LLVM symbols being undefined. Since those symbols are later
    # loaded and resolved at runtime, these errors are false positives.
    # This behaviour can be modified via the '-undefined' OS X linker flag as
    # follows.
    target_link_libraries(
      ${plugin}
      "$<$<PLATFORM_ID:Darwin>:-undefined dynamic_lookup>"
      )
endforeach()

# LINK POPCORN_COMPILER LIBRARIES TOGETHER:
target_link_libraries(LiveValues LoopNestingTree)
target_link_libraries(TrackValues LoopNestingTree)