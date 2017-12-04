module plotfourVGA
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]

	wire resetn, p1, p2;
	assign resetn = KEY[0];
	assign p1 = KEY[1];
	assign p2 = KEY[2];

	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn, enable;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "grid.mif";

	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.

    // Instansiate datapath
      datapath d0(SW[5:0], CLOCK_50, KEY[0], KEY[1], KEY[2], enable, x, y, colour);

    // Instansiate FSM control
    control c0(~KEY[1], ~KEY[2], KEY[0], CLOCK_50, enable, writeEn);
endmodule

module datapath(data_in, clock, reset_n, p_1, p_2, enable, X, Y, Colour);
	input 			reset_n, enable, clock, p_1, p_2;
	input 	[5:0] 	data_in;
	output 	[8:0] 	X;
	output 	[7:0] 	Y;
	output 	[2:0]	Colour;
	reg 	[8:0] 	x1;
	reg		[7:0]   y1;
	reg 	[2:0]   c1;
	wire	[3:0] 	controlA, controlB, controlC;

	always @ (posedge clock) begin
        if (!reset_n) begin
            x1 <= 8'b0;
            y1 <= 7'b0;
			c1 <= 3'b0;
        end
        else begin
			if (p_1) begin								// PLAYER 1 IS ALWAYS RED
				c1 <= 100;
			end
			if (p_2) begin								// PLAYER 2 IS ALWAYS BLUE
				c1 <= 001;
			end
			if (data_in == 6'b000000) begin				// BOX 0
				x1 <= 8'b00000010;
				y1 <= 7'b0000010;
			end
			else if (data_in == 6'b000001) begin		// BOX 1
				x1 <= 8'b00011000;
				y1 <= 7'b0000010;
			end
			else if (data_in == 6'b000010) begin		// BOX 2
				x1 <= 8'b00101110;
				y1 <= 7'b0000010;
			end
			else if (data_in == 6'b000011) begin		// BOX 3
				x1 <= 8'b01000100;
				y1 <= 7'b0000010;
			end
			else if (data_in == 6'b000100) begin		// BOX 4
				x1 <= 8'b01011010;
				y1 <= 7'b0000010;
			end
			else if (data_in == 6'b000101) begin		// BOX 5
				x1 <= 8'b01110000;
				y1 <= 7'b0000010;
			end
			else if (data_in == 6'b000110) begin		// BOX 6
				x1 <= 8'b10000110;
				y1 <= 7'b0000010;
			end
			else if (data_in == 6'b000111) begin		// BOX 7
				x1 <= 8'b00000010;
				y1 <= 7'b0010110;
			end
			else if (data_in == 6'b001000) begin		// BOX 8
				x1 <= 8'b00011000;
				y1 <= 7'b0010110;
			end
			else if (data_in == 6'b001001) begin		// BOX 9
				x1 <= 8'b00101110;
				y1 <= 7'b0010110;
			end
			else if (data_in == 6'b001010) begin		// BOX 10
				x1 <= 8'b01000100;
				y1 <= 7'b0010110;
			end
			else if (data_in == 6'b001011) begin		// BOX 11
				x1 <= 8'b01011010;
				y1 <= 7'b0010110;
			end
			else if (data_in == 6'b001100) begin		// BOX 12
				x1 <= 8'b01110000;
				y1 <= 7'b0010110;
			end
			else if (data_in == 6'b001101) begin		// BOX 13
				x1 <= 8'b10000110;
				y1 <= 7'b0010110;
			end
			else if (data_in == 6'b001110) begin		// BOX 14
				x1 <= 8'b00000010;
				y1 <= 7'b0101010;
			end
			else if (data_in == 6'b001111) begin		// BOX 15
				x1 <= 8'b00011000;
				y1 <= 7'b0101010;
			end
			else if (data_in == 6'b010000) begin		// BOX 16
				x1 <= 8'b00101110;
				y1 <= 7'b0101010;
			end
			else if (data_in == 6'b010001) begin		// BOX 17
				x1 <= 8'b01000100;
				y1 <= 7'b0101010;
			end
			else if (data_in == 6'b010010) begin		// BOX 18
				x1 <= 8'b01011010;
				y1 <= 7'b0101010;
			end
			else if (data_in == 6'b010011) begin		// BOX 19
				x1 <= 8'b01110000;
				y1 <= 7'b0101010;
			end
			else if (data_in == 6'b010100) begin		// BOX 20
				x1 <= 8'b10000110;
				y1 <= 7'b0101010;
			end
			else if (data_in == 6'b010101) begin		// BOX 21
				x1 <= 8'b00000010;
				y1 <= 7'b0111110;
			end
			else if (data_in == 6'b010110) begin		// BOX 22
				x1 <= 8'b00011000;
				y1 <= 7'b0111110;
			end
			else if (data_in == 6'b010111) begin		// BOX 23
				x1 <= 8'b00101110;
				y1 <= 7'b0111110;
			end
			else if (data_in == 6'b011000) begin		// BOX 24
				x1 <= 8'b01000100;
				y1 <= 7'b0111110;
			end
			else if (data_in == 6'b011001) begin		// BOX 25
				x1 <= 8'b01011010;
				y1 <= 7'b0111110;
			end
			else if (data_in == 6'b011010) begin		// BOX 26
				x1 <= 8'b01110000;
				y1 <= 7'b0111110;
			end
			else if (data_in == 6'b011011) begin		// BOX 27
				x1 <= 8'b10000110;
				y1 <= 7'b0111110;
			end
			else if (data_in == 6'b011100) begin		// BOX 28
				x1 <= 8'b00000010;
				y1 <= 7'b1010001;
			end
			else if (data_in == 6'b011101) begin		// BOX 29
				x1 <= 8'b00011000;
				y1 <= 7'b1010001;
			end
			else if (data_in == 6'b011110) begin		// BOX 30
				x1 <= 8'b00101110;
				y1 <= 7'b1010001;
			end
			else if (data_in == 6'b011111) begin		// BOX 31
				x1 <= 8'b01000100;
				y1 <= 7'b1010001;
			end
			else if (data_in == 6'b100000) begin		// BOX 32
				x1 <= 8'b01011010;
				y1 <= 7'b1010001;
			end
			else if (data_in == 6'b100001) begin		// BOX 33
				x1 <= 8'b01110000;
				y1 <= 7'b1010001;
			end
			else if (data_in == 6'b100010) begin		// BOX 34
				x1 <= 8'b10000110;
				y1 <= 7'b1010001;
			end
			else if (data_in == 6'b100011) begin		// BOX 35
				x1 <= 8'b00000010;
				y1 <= 7'b1100101;
			end
			else if (data_in == 6'b100100) begin		// BOX 36
				x1 <= 8'b00011000;
				y1 <= 7'b1100101;
			end
			else if (data_in == 6'b100101) begin		// BOX 37
				x1 <= 8'b00101110;
				y1 <= 7'b1100101;
			end
			else if (data_in == 6'b100110) begin		// BOX 38
				x1 <= 8'b01000100;
				y1 <= 7'b1100101;
			end
			else if (data_in == 6'b100111) begin		// BOX 39
				x1 <= 8'b01011010;
				y1 <= 7'b1100101;
			end
			else if (data_in == 6'b101000) begin		// BOX 40
				x1 <= 8'b01110000;
				y1 <= 7'b1100101;
			end
			else if (data_in == 6'b101001) begin		// BOX 41
				x1 <= 8'b10000110;
				y1 <= 7'b1100101;
			end
        end
    end

	counter m0 (clock, reset_n, enable, controlA);
	rate_counter m1 (clock, reset_n, enable, controlB);
	assign enable_1 = (controlB == 2'b00) ? 1 : 0;
	counter m2 (clock, reset_n, enable_1, controlC);

	assign X = x1 + controlA;
	assign Y = y1 + controlC;
	assign Colour = c1;
endmodule

module counter(clock, reset_n, enable, q);
	input clock, reset_n, enable;
	output reg [3:0] q;

	always @(posedge clock) begin
		if (reset_n == 1'b0) begin
			q <= 4'b0000;
		end
		else if (enable == 1'b1) begin
			if (q == 4'b1111) begin
				q <= 4'b0000;
			end
		  	else begin
			  	q <= q + 3'b111;
			end
		end
	end
endmodule

module rate_counter(clock, reset_n, enable, q);
	input clock, reset_n, enable;
	output reg [3:0] q;

	always @(posedge clock) begin
		if (reset_n == 1'b0) begin
			q <= 4'b1111;
		end
		else if (enable == 1'b1) begin
		   	if (q == 4'b0000) begin
				q <= 4'b1111;
			end
			else begin
				q <= q - 3'b111;
			end
		end
	end
endmodule

module control (go_p1, go_p2, reset_n, clock, enable, plot);
	input go_p1, go_p2, reset_n, clock;
	output reg enable, plot;

	always@(*) begin
		enable = 1'b0;
		plot = 1'b0;

		if (go_p1 || go_p2) begin
			plot = 1'b1;
			enable = 1'b1;
		end
	end
endmodule
