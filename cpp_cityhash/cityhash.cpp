#include <iostream>
#include <string>
#include <city.h>  // CityHash header
#include <cstdlib> // For std::atoi

void print_usage() {
    std::cout << "Usage: ./city_hash_cpp <string_to_hash> [--hex|--dec]" << std::endl;
}

int main(int argc, char *argv[]) {
    if (argc < 2 || argc > 3) {
        print_usage();
        return 1;
    }

    // Get the input string from the command line argument
    std::string input = argv[1];

    // Calculate the CityHash64 of the string
    uint64_t hash = CityHash64(input.c_str(), input.length());

    // Check if the user wants hex or decimal output
    if (argc == 3 && std::string(argv[2]) == "--hex") {
        // Print the hash in hexadecimal format
        std::cout << "Hash of '" << input << "' (hex): 0x" << std::hex << hash << std::endl;
    } else {
        // Default to decimal output if no valid format is provided
        std::cout << "Hash of '" << input << "' (decimal): " << std::dec << hash << std::endl;
    }

    return 0;
}

