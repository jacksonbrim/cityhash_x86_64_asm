# CityHash64 x86_64 Assembly Implementation
A pure assembly implementation of the cityhash64 hashing algorithm made
by [google](https://github.com/google/cityhash).


Note:
* Binary Currently only available on x86_64 linux systems due to linux
  specific syscalls for printing
* Library use of cityhash64 function is currently only available on systems using the System
  V AMD64 ABI (Solaris, Linux, FreeBSD, macOS).

Features:
* Pure x86-64 Assembly implementation.
* Implements the CityHash64 function.
* Includes tests comparing the assembly implementation with the original C++ CityHash.
* GDB debug scripts

Requirements:
* x86_64 architecture.
* Linux operating system.
* NASM assembler (version 2.14 or later).
* GCC/G++ compiler.
* GNU linker (ld).
* Google CityHash library installed. (for tests)

Installation:

Install NASM:

On Ubuntu/Debian: 
```
sudo apt update sudo apt install nasm
```

Install GCC/G++:

On Ubuntu/Debian: 
```
sudo apt update sudo apt install build-essential
```

Building the Project:

Clone the repository: 
```
git clone https://github.com/jacksonbrim/cityhash_x86_64_asm.git cd cityhash_x86_64_asm
```

Build the executable and the .o files:
The executable will be located in the out/ directory.
```
make
```
Clean up ./out/ and ./obj/ directories.
```
make clean
```

For debugging: 
Executable at out/cityhash with gdb symbols
```
make debug
```
Run gdb debug scripts to automatically set breakpoints for various
functions.
```
./debug.sh
```

Running Tests: Ensure the Google CityHash library is installed.
Builds the test_hashlen executable at ./out/test_hashlen and runs the
tests.
```
make test
```
Builds the test_utilities executable at ./out/test_utilities and runs the
tests.
```
make test_utilities
```
To run a cpp version that uses the original google cityhash64 function:
```
make google_cityhash
out/google_cityhash "hello world"
```


## Using cityhash64 as a library
To call from a cpp program:

```cpp
#include <cstring>
#include <iostream>
#include <cstdlib> // For std::atoi
extern "C" uint64_t cityhash64(const char* s, size_t len);

int main() {
    const char* input = "Hello World!";

    uint64_t my_cityhash = cityhash64(input, 12);
    std::cout << "cityhash64: 0x" << std::hex << my_cityhash << std::endl;
   
    return 0;
}
```
Link the .o file
```
g++ -o myProgram main.cpp /path/to/cityhash_x86_64_asm/obj/city_hash.o
/path/to/cityhash_x86_64_asm/obj/hashing_utils/*
```


Usage: After building, use the cityhash executable to compute CityHash64 hashes. Example: ./out/cityhash "your_input_string"


