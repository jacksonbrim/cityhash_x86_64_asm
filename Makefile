# Makefile for CityHash Project
# Compiler and linker
ASM = nasm
CXX = g++
LD = ld

# Flags
ASMFLAGS = -f elf64 -I$(SRC_DIR)  # Added -I$(SRC_DIR) to include src/ for includes
LDFLAGS = 
CXXFLAGS = -I/usr/local/include
LIBS = -L/usr/local/lib -lcityhash

# Directories
SRC_DIR = src
OBJ_DIR = obj
OUT_DIR = out
HASHING_UTILS_DIR = $(SRC_DIR)/hashing_utils
CPP_TEST_DIR = cpp_cityhash

# Find all .asm files in SRC_DIR recursively
ASM_SOURCES := $(shell find $(SRC_DIR) -name '*.asm')

# Generate .o file names in OBJ_DIR, maintaining directory structure
OBJ_FILES := $(patsubst $(SRC_DIR)/%.asm,$(OBJ_DIR)/%.o,$(ASM_SOURCES))

# C++ source files for utilities testing
CPP_TEST_FILES = $(CPP_TEST_DIR)/utilities.cpp $(CPP_TEST_DIR)/test_utilities.cpp

# C++ source files for utilities testing
GOOGLE_CITYHASH = $(CPP_TEST_DIR)/cityhash.cpp

# Output executable name
GOOGLE_CITYHASH_EXECUTABLE = $(OUT_DIR)/google_cityhash

# Output executable name
EXECUTABLE = $(OUT_DIR)/cityhash

# Specific assembly files required for testing
TEST_ASM_FILES = $(HASHING_UTILS_DIR)/fetch.asm \
                 $(HASHING_UTILS_DIR)/rotate.asm \
                 $(HASHING_UTILS_DIR)/shiftmix.asm \
                 $(HASHING_UTILS_DIR)/hashlen16.asm \
                 $(HASHING_UTILS_DIR)/hashlen_17_to_32.asm \
                 $(HASHING_UTILS_DIR)/hashlen_33_to_64.asm \
                 $(HASHING_UTILS_DIR)/hashlen_0_to_16.asm \
                 $(HASHING_UTILS_DIR)/weakhashlen32withseeds.asm \
                 $(SRC_DIR)/city_hash.asm

# Object files for testing hashlen function
TEST_OBJ_FILES := $(patsubst $(SRC_DIR)/%.asm,$(OBJ_DIR)/%.o,$(TEST_ASM_FILES))

# C++ test source in the new directory
TEST_CPP_FILE = $(CPP_TEST_DIR)/test_hashlen_functions.cpp $(CPP_TEST_DIR)/utilities.cpp 
CITYHASH64_FILE = $(CPP_TEST_DIR)/cityhash.cpp
TEST_EXECUTABLE = $(OUT_DIR)/test_hashlen
# Test executable for test_utilities.cpp
TEST_UTILS_EXEC = $(OUT_DIR)/test_utilities


# Debug flags (use -g for debugging information)
DEBUG_ASMFLAGS = -f elf64 -g -F dwarf -I$(SRC_DIR)/  # Enable debugging for assembly
DEBUG_CXXFLAGS = -g                                  # Enable debugging for C++
DEBUG_LDFLAGS =                                      # Debugging linker flags (if needed)


# Default target
all: $(EXECUTABLE)

# Rule to create OBJ_DIR and its subdirectories
$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

# Rule to create subdirectories in OBJ_DIR (only for directories)
$(OBJ_DIR)/%/:
	mkdir -p $(OBJ_DIR)/$(dir $*)

# Rule to create OUT_DIR
$(OUT_DIR):
	mkdir -p $(OUT_DIR)

# Rule to build object files from .asm files recursively in src/ and maintain directory structure
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.asm | $(OBJ_DIR)/%/
	$(ASM) $(ASMFLAGS) $< -o $@

# Rule to build the final executable
$(GOOGLE_CITYHASH_EXECUTABLE): $(CITYHASH64_FILE) | $(OUT_DIR)
	$(CXX) $(CXXFLAGS) -o $(GOOGLE_CITYHASH_EXECUTABLE) \
		$(CITYHASH64_FILE) \
		$(LIBS)

# Rule to build the final executable
$(EXECUTABLE): $(OBJ_FILES) | $(OUT_DIR)
	$(LD) $(LDFLAGS) -o $@ $^

# Rule to build the test executable
$(TEST_EXECUTABLE): $(TEST_OBJ_FILES) $(TEST_CPP_FILE) | $(OUT_DIR)
	$(CXX) $(CXXFLAGS) $(DEBUG_CXXFLAGS) -o $(TEST_EXECUTABLE) \
		$(TEST_OBJ_FILES) \
		$(TEST_CPP_FILE) $(LIBS)

# Rule to build and test test_utilities.cpp
$(TEST_UTILS_EXEC): $(CPP_TEST_FILES) $(TEST_OBJ_FILES) | $(OUT_DIR)
	$(CXX) $(CXXFLAGS) $(DEBUG_CXXFLAGS) -o $(TEST_UTILS_EXEC) $(CPP_TEST_FILES) $(TEST_OBJ_FILES)


google_cityhash: $(GOOGLE_CITYHASH_EXECUTABLE)

test_utilities: $(TEST_UTILS_EXEC)
	$(TEST_UTILS_EXEC)


# Target to run the test
test: $(TEST_EXECUTABLE)
	./$(TEST_EXECUTABLE)

# Clean target
clean:
	rm -rf $(OBJ_DIR)/* $(OUT_DIR)/*

# Debug target (optional)
debug: ASMFLAGS = $(DEBUG_ASMFLAGS)
debug: LDFLAGS = $(DEBUG_LDFLAGS)
debug: $(EXECUTABLE)

.PHONY: all clean debug test test_utilities

