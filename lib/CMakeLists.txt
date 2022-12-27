# THE LIST OF PLUGINS AND THE CORRESPONDING SOURCE FILES
# ======================================================
set(LLVM_DALE_PLUGINS
  ## Pre-analysis transformation:
  SplitConditionalBB

  ## Liveness Analysis:
  LiveValues
  LoopNestingTree

  ## Transformation:
  SubroutineInjection

  ## jsoncpp:
  jsoncpp
  JsonHelper
  )

## Pre-analysis transformation:
set(SplitConditionalBB_SOURCES
  dale_passes/SplitConditionalBB.cpp)

## Liveness Analysis:
set(LiveValues_SOURCES
  popcorn_compiler/LiveValues.cpp)
set(LoopNestingTree_SOURCES
  popcorn_compiler/LoopNestingTree.cpp)

## Transformation:
set(SubroutineInjection_SOURCES
  dale_passes/SubroutineInjection.cpp)

## jsoncpp:
set(jsoncpp_SOURCES 
  json/jsoncpp.cpp)
set(JsonHelper_SOURCES
  json/JsonHelper.cpp)


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
target_link_libraries(SplitConditionalBB LiveValues)
target_link_libraries(JsonHelper jsoncpp)
target_link_libraries(LiveValues LoopNestingTree jsoncpp JsonHelper)
target_link_libraries(SubroutineInjection LiveValues jsoncpp JsonHelper)