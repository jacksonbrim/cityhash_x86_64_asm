import gdb
from time import sleep
import logging
import sys


# Define the breakpoints where you want to pause
breakpoints = [
    "_start",
    "cityhash64",
    "weak_hash_len_32_base",
    "weak_hash_len_32_with_seeds",
#    "cityhash64.set_x",
#    "cityhash64.set_y",
#    "cityhash64.set_z",
#    "cityhash64.set_v",
#    "cityhash64.set_w",
    "cityhash64.updated_x",
    "cityhash64.loop",
    "cityhash64.loop.update_x",
    "cityhash64.loop.update_y",
    "cityhash64.loop.second_update_x",
    "cityhash64.loop.second_update_y",
    "cityhash64.loop.update_z",
    "cityhash64.loop.update_v",
    "cityhash64.loop.update_w",
    "cityhash64.loop.update_s",
    "cityhash64.return_above_64_bytes",
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
test_string = "This is a test string to hash that is 3 bytes longer than 64 bytes."
test_string_len = len(test_string)
gdb.execute(f'run "{test_string}"')

