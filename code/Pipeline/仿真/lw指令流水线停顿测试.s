ori x29, x0, 12
ori x8, x0, 0x123
ori x9, x0, 0x456
add x7, x8, x9
sub x6, x7, x9
or  x10, x8, x9
and x11, x9, x10
sw x8, 0(x0)
sw x9, 4(x0)
sw x7, 4(x29)
lw x5, 0(x0)
bne x8, x5, _lb2
_lb1:
lw x9, 4(x29)
_lb2:
lw x5, 4(x0)
beq x9, x5, _lb1