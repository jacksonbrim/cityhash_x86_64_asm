import gdb
from time import sleep
import logging
import sys


# Define the breakpoints where you want to pause
breakpoints = [
    "_start",
    "hashlen33to64",
    "hashlen33to64.set_mul",
    "hashlen33to64.a_set",
    "hashlen33to64.b_set",
    "hashlen33to64.e_set",
    "hashlen33to64.f_set",
    "hashlen33to64.g_set",
    "hashlen33to64.c_set",
    "hashlen33to64.d_set",
    "hashlen33to64.h_set",
    "hashlen33to64.u_set",
    "hashlen33to64.v_set",
    "hashlen33to64.w_set",
    "hashlen33to64.y_set",
    "hashlen33to64.x_set",
    "hashlen33to64.z_set",
    "hashlen33to64.finalize_a",
    "hashlen33to64.finalize_b",
    "hashlen33to64.return"
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
test_string = "This is a 40 character long test string."
test_string_len = len(test_string)
gdb.execute('run "This is a 40 character long test string."')


run_to_next_breakpoint()

run_to_next_breakpoint()
gdb.execute('printf".set_mul:\\n"')
gdb.execute('set $len = $rsi')
gdb.execute('set $k2 = $rcx')
gdb.execute('set $s = $rdi')
gdb.execute('set $mul = $r15')

run_to_next_breakpoint()
gdb.execute('printf".set_a:\\n"')
gdb.execute('set $a = $r8')

run_to_next_breakpoint()
gdb.execute('printf".set_b:\\n"')
gdb.execute('set $b = $r9')
gdb.execute('printf"$rdi = "')
gdb.execute('p/x $rdi')
gdb.execute('printf"$s + 8 = "')
gdb.execute('p/x $s + 8')
gdb.execute('printf"($s + 8) == $rdi = "')
gdb.execute('p (($s + 8) == $rdi) ? "Equal" : "Not Equal"')


run_to_next_breakpoint()
gdb.execute('printf".set_e:\\n"')
gdb.execute('set $e = $r12')
gdb.execute('printf"$rdi = "')
gdb.execute('p/x $rdi')
gdb.execute('printf"$s + 16 = "')
gdb.execute('p/x $s + 16')
gdb.execute('printf"($s + 16) == $rdi = "')
gdb.execute('p (($s + 16) == $rdi) ? "Equal" : "Not Equal"')


sleep(0.5)
run_to_next_breakpoint()
gdb.execute('printf".set_f:\\n"')
gdb.execute('set $f = $r13')
gdb.execute('printf"$rdi = "')
gdb.execute('p/x $rdi')
gdb.execute('printf"$s + 24 = "')
gdb.execute('p/x $s + 24')
gdb.execute('printf"($s + 24) == $rdi = "')
gdb.execute('p (($s + 24) == $rdi) ? "Equal" : "Not Equal"')


sleep(0.5)
run_to_next_breakpoint()
gdb.execute('printf".set_g:\\n"')
gdb.execute('set $g = $r14')
gdb.execute('printf"$rdi = "')
gdb.execute('p/x $rdi')
gdb.execute('printf"$s + $len - 8 = "')
gdb.execute('p/x $s + $len - 8')
gdb.execute('printf"($s + $len - 8) == $rdi = "')
gdb.execute('p (($s + $len - 8) == $rdi) ? "Equal" : "Not Equal"')



sleep(0.5)
run_to_next_breakpoint()
gdb.execute('printf".set_c:\\n"')
gdb.execute('set $c = $r10')
gdb.execute('printf"$rdi = "')
gdb.execute('p/x $rdi')
gdb.execute('printf"$s + $len - 24 = "')
gdb.execute('p/x $s + $len - 24')
gdb.execute('printf"($s + $len - 24) == $rdi = "')
gdb.execute('p (($s + $len - 24) == $rdi) ? "Equal" : "Not Equal"')


sleep(0.5)
run_to_next_breakpoint()
gdb.execute('printf".set_d:\\n"')
gdb.execute('set $d = $r11')
gdb.execute('printf"$rdi = "')
gdb.execute('p/x $rdi')
gdb.execute('printf"$s + $len - 32 = "')
gdb.execute('p/x $s + $len - 32')
gdb.execute('printf"($s + $len - 32) == $rdi = "')
gdb.execute('p (($s + $len - 32) == $rdi) ? "Equal" : "Not Equal"')


sleep(0.5)
run_to_next_breakpoint()
gdb.execute('printf".set_h:\\n"')
gdb.execute('set $h = $rbx')
gdb.execute('printf"$rdi = "')
gdb.execute('p/x $rdi')
gdb.execute('printf"$s + $len - 16 = "')
gdb.execute('p/x $s + $len - 16')
gdb.execute('printf"($s + $len - 16) == $rdi = "')
gdb.execute('p (($s + $len - 16) == $rdi) ? "Equal" : "Not Equal"')

# check next calculations dependencies
# a
gdb.execute('printf"($a == $r8) = "')
gdb.execute('p ($a == $r8) ? "Equal" : "Not Equal"')

# g
gdb.execute('printf"($g == $r14) = "')
gdb.execute('p ($g == $r14) ? "Equal" : "Not Equal"')

# b
gdb.execute('printf"($b == $r9) = "')
gdb.execute('p ($b == $r9) ? "Equal" : "Not Equal"')

# c
gdb.execute('printf"($c == $r10) = "')
gdb.execute('p ($c == $r10) ? "Equal" : "Not Equal"')


sleep(0.5)
run_to_next_breakpoint()
gdb.execute('printf".set_u:\\n"')
gdb.execute('set $u = $rcx')
# check next calculations dependencies
# a
gdb.execute('printf"($a == $r8) = "')
gdb.execute('p ($a == $r8) ? "Equal" : "Not Equal"')

# g
gdb.execute('printf"($g == $r14) = "')
gdb.execute('p ($g == $r14) ? "Equal" : "Not Equal"')

# d
gdb.execute('printf"($d == $r11) = "')
gdb.execute('p ($d == $r11) ? "Equal" : "Not Equal"')

# f
gdb.execute('printf"($f == $r13) = "')
gdb.execute('p ($f == $r13) ? "Equal" : "Not Equal"')

sleep(0.5)
run_to_next_breakpoint()
gdb.execute('printf".set_v:\\n"')
gdb.execute('set $v = $rdx')
# check next calculations dependencies
# u
gdb.execute('printf"($u == $rcx) = "')
gdb.execute('p ($u == $rcx) ? "Equal" : "Not Equal"')

# v
gdb.execute('printf"($v == $rdx) = "')
gdb.execute('p ($v == $rdx) ? "Equal" : "Not Equal"')

# mul
gdb.execute('printf"($mul == $r15) = "')
gdb.execute('p ($mul == $r15) ? "Equal" : "Not Equal"')

# h
gdb.execute('printf"($h == $rbx) = "')
gdb.execute('p ($h == $rbx) ? "Equal" : "Not Equal"')

sleep(0.5)
run_to_next_breakpoint()
gdb.execute('printf".set_w:\\n"')
gdb.execute('set $w = $rcx')
# check next calculations dependencies
# v
gdb.execute('printf"($v == $rdx) = "')
gdb.execute('p ($v == $rdx) ? "Equal" : "Not Equal"')

# w
gdb.execute('printf"($w == $rcx) = "')
gdb.execute('p ($w == $rcx) ? "Equal" : "Not Equal"')

# g
gdb.execute('printf"($g == $r14) = "')
gdb.execute('p ($g == $r14) ? "Equal" : "Not Equal"')

# mul
gdb.execute('printf"($mul == $r15) = "')
gdb.execute('p ($mul == $r15) ? "Equal" : "Not Equal"')


sleep(0.5)
run_to_next_breakpoint()
gdb.execute('printf".set_y:\\n"')
gdb.execute('set $y = $rcx')
# check next calculations dependencies
# e
gdb.execute('printf"($e == $r12) = "')
gdb.execute('p ($e == $r12) ? "Equal" : "Not Equal"')

# f
gdb.execute('printf"($f == $r13) = "')
gdb.execute('p ($f == $r13) ? "Equal" : "Not Equal"')

# c
gdb.execute('printf"($c == $r10) = "')
gdb.execute('p ($c == $r10) ? "Equal" : "Not Equal"')

sleep(0.5)
run_to_next_breakpoint()
gdb.execute('printf".set_x:\\n"')
gdb.execute('set $x = $r13')
gdb.execute('set $ef = $r12')
# check next calculations dependencies
# ef
gdb.execute('printf"($ef == $12) = "')
gdb.execute('p ($ef == $r12) ? "Equal" : "Not Equal"')

# c
gdb.execute('printf"($c == $r10) = "')
gdb.execute('p ($c == $r10) ? "Equal" : "Not Equal"')

sleep(0.5)
run_to_next_breakpoint()
gdb.execute('printf".set_z:\\n"')
gdb.execute('set $z = $r12')
# check next calculations dependencies

# x
gdb.execute('printf"($x == $r13) = "')
gdb.execute('p ($x == $r13) ? "Equal" : "Not Equal"')

# z
gdb.execute('printf"($z == $r12) = "')
gdb.execute('p ($z == $r12) ? "Equal" : "Not Equal"')

# mul
gdb.execute('printf"($mul == $r15) = "')
gdb.execute('p ($mul == $r15) ? "Equal" : "Not Equal"')
# y
gdb.execute('printf"($y == $rcx) = "')
gdb.execute('p ($y == $rcx) ? "Equal" : "Not Equal"')

# b
gdb.execute('printf"($b == $r9) = "')
gdb.execute('p ($b == $r9) ? "Equal" : "Not Equal"')

sleep(0.5)
run_to_next_breakpoint()
gdb.execute('printf".finalize_a:\\n"')
gdb.execute('set $a = $r10')
# check next calculations dependencies

# z
gdb.execute('printf"($z == $r12) = "')
gdb.execute('p ($z == $r12) ? "Equal" : "Not Equal"')

# a
gdb.execute('printf"($a == $r10) = "')
gdb.execute('p ($a == $r10) ? "Equal" : "Not Equal"')

# mul
gdb.execute('printf"($mul == $r15) = "')
gdb.execute('p ($mul == $r15) ? "Equal" : "Not Equal"')

# d
gdb.execute('printf"($d == $r11) = "')
gdb.execute('p ($d == $r11) ? "Equal" : "Not Equal"')

# h
gdb.execute('printf"($h == $rbx) = "')
gdb.execute('p ($h == $rbx) ? "Equal" : "Not Equal"')

sleep(0.5)
run_to_next_breakpoint()
gdb.execute('printf".finalize_a:\\n"')
gdb.execute('set $b = $rax')
# check next calculations dependencies

# x
gdb.execute('printf"($x == $r13) = "')
gdb.execute('p ($x == $r13) ? "Equal" : "Not Equal"')


sleep(0.5)
run_to_next_breakpoint()
gdb.execute('printf".return:\\n"')
# x
gdb.execute('printf"($rax == ($b + $x)) = "')
gdb.execute('p ($rax == ($b + $x)) ? "Equal" : "Not Equal"')


