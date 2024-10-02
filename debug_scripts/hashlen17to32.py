import gdb
from time import sleep
import logging
import sys


# Define the breakpoints where you want to pause
breakpoints = [
    "_start",
    "cityhash",
    "hashlen17to32",
]

# Setup breakpoints in GDB
def setup_breakpoints(breakpoints):
    for label in breakpoints:
        gdb.Breakpoint(label)

# Run to the next breakpoint
def run_to_next_breakpoint():
    gdb.execute('continue')

# GDB command to run the script
gdb.execute('file out/cityhash')


# Setup all breakpoints
setup_breakpoints(breakpoints)

# Run the program with a sample input
test_string = "This is a 30 byte test string."
test_string_len = len(test_string)
gdb.execute(f'run "{test_string_len}"')



