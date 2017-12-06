vlib work

vlog -timescale 1ns/1ns plotfourVGA.v

vsim plotfourVGA

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

force {KEY}   1001 0, 0100 20, 1100 40, 0100 59, 1100 60, 0100 79, 1100 80, 0100 99, 1100 100, 0100 119, 1100 120, 0001 139, 0010 140, 1010 160 -r 180
force {SW} 	000000 0, 000001 20, 000000 40, 000111 60, 001110 80, 010101 100, 011000 120, 000001 140, 000001 160 -r 180

run 180ns