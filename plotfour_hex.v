//SW[3:0] data inputs

//HEX[6:0] segment display

module plotfour_hex(HEX, SW);
    input [9:0] SW;
    output [6:0] HEX0;

    assign HEX[0] =    ~SW[3] & ~SW[2] & ~SW[1] & SW[0] |
						~SW[3] & SW[2] & ~SW[1] & ~SW[0] |
						SW[3] & ~SW[2] & SW[1] & SW[0] |
						SW[3] & SW[2] & ~SW[1] & SW[0] ;
		
    assign HEX[1] =    ~SW[3] & ~SW[2] & SW[1] & SW[0] |
						~SW[3] & SW[2] & ~SW[1] & SW[0] |                 
						SW[3] & SW[1] & SW[0] |
						SW[2] & SW[1] & ~SW[0] ;

    assign HEX[2] =    SW[3] & SW[2] & ~SW[1] & ~SW[0] |
						SW[3] & SW[2] & SW[1]		|
						~SW[3] & ~SW[2] & SW[1] & ~SW[0];

    assign HEX[3] =    ~SW[3] & ~SW[2] & ~SW[1] & SW[0] |
						~SW[3] & SW[2] & ~SW[1] & ~SW[0] |
						SW[2] & SW[1] & SW[0] |
						SW[3] & ~SW[2] & ~SW[1] & SW[0] |
						SW[3] & ~SW[2] & SW[1] & ~SW[0];

    assign HEX[4] =    ~SW[3] & SW[0] |
						~SW[3] & SW[2] & ~SW[1] |
						SW[3] & ~SW[2] & ~SW[1] & SW[0] ;

    assign HEX[5] =    ~SW[3] & ~SW[2] & SW[0] |
						~SW[3] & ~SW[2] & SW[1] |
						~SW[3] & SW[1] & SW[0] |
						SW[3] & SW[2] & ~SW[1] & SW[0] ;
		
    assign HEX[6] =    ~SW[3] & ~SW[2] & ~SW[1] |
						~SW[3] & SW[2] & SW[1] & SW[0] |
						SW[3] & SW[2] & ~SW[1] & ~SW[0] ;

endmodule

