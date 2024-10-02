##!/bin/bash
make clean

if [ "$1" == "33to64" ]; then
    make debug
    gdb -q -x debug_scripts/hashlen33to64.py
elif [ "$1" == "17to32" ]; then
    make debug
    gdb -q -x debug_scripts/hashlen17to32.py
elif [ "$1" == "ge64" ]; then
    make debug
    gdb -q -x debug_scripts/cityhash_ge64bytes.py
elif [ "$1" == "test" ]; then
    make test
    gdb -q -x debug_scripts/test_hashlen_function.py
else
    echo "Usage: $0 {33to64: hashlen33to64 | 17to32: hashlen17to32 | ge64: cityhash_ge64bytes | test: test_hashlen_function.cpp}"
    exit 1
fi
