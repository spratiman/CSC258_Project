vlib work

vlog -timescale 1ns/1ns plotfour_top.v

vsim datapath

log {/*}
add wave {/*}

force {clock} 0 0,1 5 -r 10
force {reset_n} 0
force {enable} 1
force {data_in} 6'b010100
force {p_1} 1
force {p_2} 0
run 200ns
