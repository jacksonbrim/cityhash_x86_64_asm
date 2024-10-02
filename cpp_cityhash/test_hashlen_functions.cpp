#include <iostream>
#include <iomanip>
#include <cstring>
#include <stdint.h>
#include <city.h>  // Include the CityHash library

// Declare the assembly function for validation
extern "C" uint64 cityhash64(const char* s, size_t len);
extern "C" uint64 hashlen17to32(const char* s, size_t len);
extern "C" uint64 hashlen33to64(const char* s, size_t len);
extern "C" uint64 hashlen0to16(const char* s, size_t len);
extern "C" uint64 greater_or_equal_to_8(const char* s, size_t len);
extern "C" uint64 len_less_than_8(const char* s, size_t len);
extern "C" uint64 len_less_than_4(const char* s, size_t len);

// Include the C++ CityHash sub-branch functions
extern uint64 HashLen33to64(const char* s, size_t len);
extern uint64 GreaterEq8(const char* s, size_t len);
extern uint64 Len4to7(const char* s, size_t len);
extern uint64 Len0to3(const char* s, size_t len);

// Hash function for strings of length 0 to 16
uint64 hashlen0to16_cpp(const char* s, size_t len) {
    if (len <= 16) {
        return CityHash64(s, len);
    }
    // If the string is not within bounds, return 0 (error case)
    return 0;
}

// Hash function for strings of length 17 to 32
uint64 hashlen17to32_cpp(const char* s, size_t len) {
    if (len > 16 && len <= 32) {
        return CityHash64(s, len);
    }
    // If the string is not within bounds, return 0 (error case)
    return 0;
}
void print_comparison(const std::string &func_name, const std::string input_string, uint64 asm_result, uint64 cpp_result) {
    std::cout << func_name << ":\n\t\t\t\"" << input_string << "\"\n" << std::endl;
    std::cout << "    asm: 0x" << std::hex << std::setw(16) << std::setfill('0') << asm_result << std::endl;
    std::cout << "    cpp: 0x" << std::hex << std::setw(16) << std::setfill('0') << cpp_result << std::endl;

    if (asm_result == cpp_result) {
        std::cout << "    Match" << std::endl;
    } else {
        std::cout << "    Not Match" << std::endl;
    }
    std::cout << std::endl;
}


int main() {
    std::cout << "\nTesting Hashing Functions...\n\n" << std::endl;
    // Example input string (length between 0 and 16)
    const char* input_0to16 = "Hash length 15!";
    uint64 input_length_0to16 = strlen(input_0to16);
    
    // Test function parts for hashlen0to16
    const char* input_0to3 = "abc";
    uint64 input_length_0to3 = strlen(input_0to3);
    uint64 hash_asm_0to3 = len_less_than_4(input_0to3, input_length_0to3);
    uint64 hash_cpp_0to3 = Len0to3(input_0to3, input_length_0to3);

    print_comparison("HashLen0to16.len_less_than_4", input_0to3, hash_asm_0to3, hash_cpp_0to3);

    const char* input_4to7 = "6 char";
    uint64 input_length_4to7 = strlen(input_4to7);
    uint64 hash_asm_4to7 = len_less_than_8(input_4to7, input_length_4to7);
    uint64 hash_cpp_4to7 = Len4to7(input_4to7, input_length_4to7);

    print_comparison("HashLen0to16.len_less_than_8", input_4to7, hash_asm_4to7, hash_cpp_4to7);

    const char* input_ge8 = "8 chars!";
    uint64 input_length_ge8 = strlen(input_ge8);
    uint64 hash_cpp_8 = GreaterEq8(input_ge8, input_length_ge8);
    uint64 hash_asm_8 = greater_or_equal_to_8(input_ge8, input_length_ge8);
    
    print_comparison("HashLen0to16.greater_or_equal_to_8", input_ge8, hash_asm_8, hash_cpp_8);
    
    // CityHash version hash for length 0 to 16
    uint64 hash_city_0to16 = hashlen0to16_cpp(input_0to16, input_length_0to16);

    // Assembly version hash (assume we have the implementation for validation)
    uint64 hash_asm_0to16 = hashlen0to16(input_0to16, input_length_0to16);

    print_comparison("HashLen0to16", input_0to16, hash_asm_0to16, hash_city_0to16);

    // Example input string (length between 17 and 32)
    const char* input_17to32 = "Test string to hash for len 30";
    uint64 input_length_17to32 = strlen(input_17to32);

    // CityHash version hash for length 17 to 32
    uint64 hash_city_17to32 = hashlen17to32_cpp(input_17to32, input_length_17to32);

    // Assembly version hash (assume we have the implementation for validation)
    uint64 hash_asm_17to32 = hashlen17to32(input_17to32, input_length_17to32);

    print_comparison("HashLen17to32", input_17to32, hash_asm_17to32, hash_city_17to32);


    const char* input_33to64 = "Test string to hash that is between 33 and 64 bytes";
    uint64 input_length_33to64 = strlen(input_33to64);
    uint64 hash_asm_33to64 = hashlen33to64(input_33to64, input_length_33to64);
    uint64 hash_cpp_33to64 = HashLen33to64(input_33to64, input_length_33to64);

    print_comparison("HashLen33to64", input_33to64, hash_asm_33to64, hash_cpp_33to64);

    uint64 cityhash64_cpp_0to16 = CityHash64(input_0to16, input_length_0to16);
    uint64 cityhash64_asm_0to16 = cityhash64(input_0to16, input_length_0to16);

    std::cout << "\n\nCityHash64 functions\n\n" << std::endl;

    print_comparison("CityHash64 0to16 bytes", input_0to16, cityhash64_asm_0to16, cityhash64_cpp_0to16);

    uint64 cityhash64_cpp_17to32 = CityHash64(input_17to32, input_length_17to32);
    uint64 cityhash64_asm_17to32 = cityhash64(input_17to32, input_length_17to32);

    print_comparison("CityHash64 17to32 bytes", input_17to32, cityhash64_asm_17to32, cityhash64_cpp_17to32);

    uint64 cityhash64_cpp_33to64 = CityHash64(input_33to64, input_length_33to64);
    uint64 cityhash64_asm_33to64 = cityhash64(input_33to64, input_length_33to64);

    print_comparison("CityHash64 33to64 bytes", input_33to64, cityhash64_asm_33to64, cityhash64_cpp_33to64);

    const char* input_ge65 = "This is a test string to hash that is 3 bytes longer than 64 bytes.";

    uint64 input_length_ge65 = strlen(input_ge65);
    uint64 cityhash64_cpp_ge65 = CityHash64(input_ge65, input_length_ge65);
    uint64 cityhash64_asm_ge65 = cityhash64(input_ge65, input_length_ge65);

    print_comparison("CityHash64 ge65 bytes", input_ge65, cityhash64_asm_ge65, cityhash64_cpp_ge65);


    const char* input_ge100 = "This is a test string to hash that is greater than 100 bytes. It is significantly longer than 64 bytes. As a matter of fact, it should have a total of 161 bytes.";

    uint64 input_length_ge100 = strlen(input_ge100);
    uint64 cityhash64_cpp_ge100 = CityHash64(input_ge100, input_length_ge100);
    uint64 cityhash64_asm_ge100 = cityhash64(input_ge100, input_length_ge100);

    print_comparison("CityHash64 ge100 bytes", input_ge100, cityhash64_asm_ge100, cityhash64_cpp_ge100);

    return 0;
}

