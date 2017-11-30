vlib work

vlog -timescale 1ns/1ns plotfour_top.v

vsim control

log {/*}
add wave {/*}
force {go_p1} 0
force {go_p2} 1 0, 0 20 -r 40
force {reset_n} 0 0,1 40
force {clock} 0 0,1 10 -r 20
run 500ns
