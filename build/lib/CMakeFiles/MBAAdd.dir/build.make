# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.22

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/dalehuang/Documents/llvm-dale

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/dalehuang/Documents/llvm-dale/build

# Include any dependencies generated for this target.
include lib/CMakeFiles/MBAAdd.dir/depend.make
# Include any dependencies generated by the compiler for this target.
include lib/CMakeFiles/MBAAdd.dir/compiler_depend.make

# Include the progress variables for this target.
include lib/CMakeFiles/MBAAdd.dir/progress.make

# Include the compile flags for this target's objects.
include lib/CMakeFiles/MBAAdd.dir/flags.make

lib/CMakeFiles/MBAAdd.dir/llvm_tutor_passes/MBAAdd.cpp.o: lib/CMakeFiles/MBAAdd.dir/flags.make
lib/CMakeFiles/MBAAdd.dir/llvm_tutor_passes/MBAAdd.cpp.o: ../lib/llvm_tutor_passes/MBAAdd.cpp
lib/CMakeFiles/MBAAdd.dir/llvm_tutor_passes/MBAAdd.cpp.o: lib/CMakeFiles/MBAAdd.dir/compiler_depend.ts
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/dalehuang/Documents/llvm-dale/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object lib/CMakeFiles/MBAAdd.dir/llvm_tutor_passes/MBAAdd.cpp.o"
	cd /home/dalehuang/Documents/llvm-dale/build/lib && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -MD -MT lib/CMakeFiles/MBAAdd.dir/llvm_tutor_passes/MBAAdd.cpp.o -MF CMakeFiles/MBAAdd.dir/llvm_tutor_passes/MBAAdd.cpp.o.d -o CMakeFiles/MBAAdd.dir/llvm_tutor_passes/MBAAdd.cpp.o -c /home/dalehuang/Documents/llvm-dale/lib/llvm_tutor_passes/MBAAdd.cpp

lib/CMakeFiles/MBAAdd.dir/llvm_tutor_passes/MBAAdd.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/MBAAdd.dir/llvm_tutor_passes/MBAAdd.cpp.i"
	cd /home/dalehuang/Documents/llvm-dale/build/lib && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/dalehuang/Documents/llvm-dale/lib/llvm_tutor_passes/MBAAdd.cpp > CMakeFiles/MBAAdd.dir/llvm_tutor_passes/MBAAdd.cpp.i

lib/CMakeFiles/MBAAdd.dir/llvm_tutor_passes/MBAAdd.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/MBAAdd.dir/llvm_tutor_passes/MBAAdd.cpp.s"
	cd /home/dalehuang/Documents/llvm-dale/build/lib && /usr/bin/c++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/dalehuang/Documents/llvm-dale/lib/llvm_tutor_passes/MBAAdd.cpp -o CMakeFiles/MBAAdd.dir/llvm_tutor_passes/MBAAdd.cpp.s

# Object files for target MBAAdd
MBAAdd_OBJECTS = \
"CMakeFiles/MBAAdd.dir/llvm_tutor_passes/MBAAdd.cpp.o"

# External object files for target MBAAdd
MBAAdd_EXTERNAL_OBJECTS =

lib/libMBAAdd.so: lib/CMakeFiles/MBAAdd.dir/llvm_tutor_passes/MBAAdd.cpp.o
lib/libMBAAdd.so: lib/CMakeFiles/MBAAdd.dir/build.make
lib/libMBAAdd.so: lib/CMakeFiles/MBAAdd.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/dalehuang/Documents/llvm-dale/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX shared library libMBAAdd.so"
	cd /home/dalehuang/Documents/llvm-dale/build/lib && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/MBAAdd.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
lib/CMakeFiles/MBAAdd.dir/build: lib/libMBAAdd.so
.PHONY : lib/CMakeFiles/MBAAdd.dir/build

lib/CMakeFiles/MBAAdd.dir/clean:
	cd /home/dalehuang/Documents/llvm-dale/build/lib && $(CMAKE_COMMAND) -P CMakeFiles/MBAAdd.dir/cmake_clean.cmake
.PHONY : lib/CMakeFiles/MBAAdd.dir/clean

lib/CMakeFiles/MBAAdd.dir/depend:
	cd /home/dalehuang/Documents/llvm-dale/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/dalehuang/Documents/llvm-dale /home/dalehuang/Documents/llvm-dale/lib /home/dalehuang/Documents/llvm-dale/build /home/dalehuang/Documents/llvm-dale/build/lib /home/dalehuang/Documents/llvm-dale/build/lib/CMakeFiles/MBAAdd.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : lib/CMakeFiles/MBAAdd.dir/depend

