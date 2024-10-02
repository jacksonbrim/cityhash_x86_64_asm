#include <iostream>
#include <iomanip>
#include <cstdint>
#include <cstring>  // For memcpy
#include <city.h>

// Declare the assembly functions
extern "C" uint64 fetch64(const char *p);
extern "C" uint32 fetch32(const char *p);
extern "C" uint64 rotate(uint64 val, int shift);
extern "C" uint64 shiftmix(uint64 val);
extern "C" uint64 hashlen16(uint64 u, uint64 v, uint64 mul);
extern "C" uint64 hashlen16_128to64(uint64 u, uint64 v);
extern "C" std::pair<uint64, uint64>  weak_hash_len_32_base(const char *s, uint64 a, uint64 b);

// Include the C++ utility functions
extern uint64 Fetch64(const char *p);
extern uint32 Fetch32(const char *p);
extern uint64 Rotate(uint64 val, int shift);
extern uint64 ShiftMix(uint64 val);
extern uint64 HashLen16(uint64 u, uint64 v, uint64 mul);
extern uint64 HashLen16(uint64 u, uint64 v);
extern std::pair<uint64, uint64> WeakHashLen32WithSeeds(const char* s, uint64 a, uint64 b);
extern std::pair<uint64, uint64> WeakHashLen32WithSeeds(uint64 w, uint64 x, uint64 y, uint64 z, uint64 a, uint64 b);

void print_comparison(const std::string &func_name, uint64 asm_result, uint64 cpp_result) {
    std::cout << func_name << std::endl;
    std::cout << "    asm: 0x" << std::hex << std::setw(16) << std::setfill('0') << asm_result << std::endl;
    std::cout << "    cpp: 0x" << std::hex << std::setw(16) << std::setfill('0') << cpp_result << std::endl;

    if (asm_result == cpp_result) {
        std::cout << "    Match" << std::endl;
    } else {
        std::cout << "    Not Match" << std::endl;
    }
    std::cout << std::endl;
}

void print_comparison32(const std::string &func_name, uint32 asm_result, uint32 cpp_result) {
    std::cout << func_name << std::endl;
    std::cout << "    asm: 0x" << std::hex << std::setw(8) << std::setfill('0') << asm_result << std::endl;
    std::cout << "    cpp: 0x" << std::hex << std::setw(8) << std::setfill('0') << cpp_result << std::endl;

    if (asm_result == cpp_result) {
        std::cout << "    Match" << std::endl;
    } else {
        std::cout << "    Not Match" << std::endl;
    }
    std::cout << std::endl;
}



int main() {
    // Test input
    const char *data = "This is a test string!";
    uint64 val1 = 0x1234567890abcdef;
    uint64 val2 = 0xfedcba9876543210;
    uint64 mul = 0xc3a5c85c97cb3127;

    // Test Fetch64 
    uint64 fetch64_asm_result = fetch64(data);
    uint64 fetch64_cpp_result = Fetch64(data);
    print_comparison("Fetch64", fetch64_asm_result, fetch64_cpp_result);

    // Test Fetch32
    uint32 fetch32_asm_result = fetch32(data);
    uint32 fetch32_cpp_result = Fetch32(data);
    print_comparison32("Fetch32", fetch32_asm_result, fetch32_cpp_result);

    // Test Rotate (64-bit)
    int shift = 13;
    uint64 rotate_asm_result = rotate(val1, shift);
    uint64 rotate_cpp_result = Rotate(val1, shift);
    print_comparison("Rotate", rotate_asm_result, rotate_cpp_result);

    // Test ShiftMix
    uint64 shiftmix_asm_result = shiftmix(val1);
    uint64 shiftmix_cpp_result = ShiftMix(val1);
    print_comparison("ShiftMix", shiftmix_asm_result, shiftmix_cpp_result);

    // Test HashLen16
    uint64 hashlen16_asm_result = hashlen16(val1, val2, mul);
    uint64 hashlen16_cpp_result = HashLen16(val1, val2, mul);
    print_comparison("HashLen16", hashlen16_asm_result, hashlen16_cpp_result);

    // Test HashLen16 
    uint64 hashlen16_128to64_asm_result = hashlen16_128to64(val1, val2);
    uint64 hashlen16_128to64_cpp_result = HashLen16(val1, val2);
    print_comparison("HashLen16_128to64", hashlen16_128to64_asm_result, hashlen16_128to64_cpp_result);


    // for strings over 64 bytes
    const char *test_str = "This is a test string that contains more than 64 characters to test the WeakHashLen32WithSeeds functions.";
    uint64 input_length_ge64 = strlen(test_str);
    uint64 z = HashLen16(Fetch64(test_str + input_length_ge64 - 48) + input_length_ge64, Fetch64(test_str + input_length_ge64 - 24));

    std::pair<uint64, uint64> weakhash32_asm_result = weak_hash_len_32_base(test_str + input_length_ge64 - 64, input_length_ge64, z);
    std::pair<uint64, uint64> weakhash32_cpp_result = WeakHashLen32WithSeeds(test_str + input_length_ge64 - 64, input_length_ge64, z);

    print_comparison("WeakHashLen32WithSeeds.first", weakhash32_asm_result.first, weakhash32_cpp_result.first);
    print_comparison("WeakHashLen32WithSeeds.second", weakhash32_asm_result.second, weakhash32_cpp_result.second);

    return 0;
}

