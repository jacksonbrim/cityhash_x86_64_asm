#!/bin/bash
make debug
gdb -q -x debug_commands.gdb
