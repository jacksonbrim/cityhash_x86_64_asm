import gdb
from time import sleep
import logging
import sys


# Define the breakpoints where you want to pause
breakpoints = [
    "main()",
    "cityhash64",
    "weak_hash_len_32_base",
    "weak_hash_len_32_with_seeds",
    "cityhash64.set_x",
    "cityhash64.set_y",
    "cityhash64.set_z",
    "cityhash64.set_v",
    "cityhash64.set_w",
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
gdb.execute('file out/test_hashlen')


# Setup all breakpoints
setup_breakpoints(breakpoints)

# Run the test function
gdb.execute(f'run')

