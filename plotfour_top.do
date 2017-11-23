vlib work

vlog -timescale 1ns/1ns plotfour_top.v

vsim plotfour_top

log {/*}
add wave {/*}

#0:  Nothing should be displayed on HEX0, HEX1, HEX2, HEX3, LEDR1, LEDR2, LEDR3, LEDR4
#20: HEX0: 1 and Nothing should be displayed on HEX1, HEX2, HEX3, LEDR1, LEDR2, LEDR3, LEDR4
#40: HEX0: 1, LEDR1: 1 and Nothing should be displayed on HEX1, HEX2, HEX3, LEDR2, LEDR3, LEDR4
#60: HEX0: 5, LEDR1: 1 and Nothing should be displayed on HEX1, HEX2, HEX3, LEDR2, LEDR3, LEDR4
#80: HEX0: 9, LEDR1: 1 and Nothing should be displayed on HEX1, HEX2, HEX3, LEDR2, LEDR3, LEDR4
#100: HEX0: D, LEDR1: 1 and Nothing should be displayed on HEX1, HEX2, HEX3, LEDR2, LEDR3, LEDR4
#120: HEX0: 1, HEX2: 1, LEDR1: 1, LEDR3: 1 and Nothing should be displayed on HEX2, HEX3, LEDR2, LEDR4

force {KEY}   0000 0, 1100 20, 1101 40, 1100 59, 1101 60, 1100 79, 1101 80, 1100 99, 1101 100, 1100 119, 1101 120 -r 140
force {SW} 	000000 0, 000001 20, 000001 40, 000101 60, 001001 80, 001101 100, 010001 120 -r 140
#force {CLOCK_50} 1 0, 0 21, 1 22, 0 41, 1 42, 0 61, 1 62 -r 140

run 140ns