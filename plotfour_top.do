vlib work

vlog -timescale 1ns/1ns plotfour_top.v

vsim plotfour_top

log {/*}
add wave {/*}

#0:  Nothing should be displayed on HEX0, HEX1, HEX2, HEX3, LEDR1, LEDR2, LEDR3, LEDR4
#20: HEX0: 1, LEDR1: 1 and Nothing should be displayed on HEX1, HEX2, HEX3, LEDR2, LEDR3, LEDR4
#30: 
force {KEY}   0000 0,   0100 20 -r 60
force {SW} 	000000 0, 000001 20 -r 20
run 20ns