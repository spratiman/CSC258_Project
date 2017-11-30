vlib work

vlog -timescale 1ns/1ns plotfour_top.v

vsim plotfour_top

log {/*}
add wave {/*}

#0:  Nothing should be displayed on HEX0, HEX1, HEX2, HEX3, LEDR1, LEDR2, LEDR3, LEDR4
#20: HEX0: 1 and Nothing should be displayed on HEX1, HEX2, HEX3, LEDR1, LEDR2, LEDR3, LEDR4
#40: HEX0: 0, LEDR1: 1 and Nothing should be displayed on HEX1, HEX2, HEX3, LEDR2, LEDR3, LEDR4
#60: HEX0: 6, LEDR1: 1 and Nothing should be displayed on HEX1, HEX2, HEX3 LEDR2, LEDR3, LEDR4
#80: HEX0: 1, HEX1: 2 LEDR1: 1 and Nothing should be displayed on HEX2, HEX3, LEDR2, LEDR3, LEDR4
#100: HEX0: 1, HEX1: 8, HEX2: 1, LEDR1: 1, LEDR3: 1 and Nothing should be displayed on HEX3, LEDR2, LEDR4
#120: HEX0: 1, HEX1: 8, LEDR1: 1, LEDR3: 1 and Nothing should be displayed on HEX2, HEX3, LEDR2, LEDR4

#140: HEX0: 1 and Nothing should be displayed on HEX1, LEDR1, LEDR2, LEDR3, LEDR4
#160: HEX0: 1, LEDR2: 1 and Nothing should be displayed on HEX1, LEDR1, LEDR3, LEDR4

force {KEY}   1111 0, 0010 20, 0011 40, 0010 59, 0011 60, 0010 79, 0011 80, 0010 99, 0011 100, 0010 119, 0011 120, 1111 139, 0100 140, 0101 160 -r 180
force {SW} 	000000 0, 000001 20, 000000 40, 000110 60, 001100 80, 010010 100, 011000 120, 000001 140, 000001 160 -r 180

run 180ns