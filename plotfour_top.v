
module plotfour_top (
	CLOCK_50,								// On Board 50 MHz
	KEY,									// KEY[3]: START, KEY[1]: P_one, KEY[2]: P_two, KEY[0]: resetn 
	SW,										// SW[0:5]: Input square number
	HEX0,
	HEX1,
	HEX2,
	HEX3,
	LEDR
	// The ports below are for the VGA output.  Do not change.
	VGA_CLK,   								//	VGA Clock
	VGA_HS,									//	VGA H_SYNC
	VGA_VS,									//	VGA V_SYNC
	VGA_BLANK_N,							//	VGA BLANK
	VGA_SYNC_N,								//	VGA SYNC
	VGA_R,   								//	VGA Red[9:0]
	VGA_B   								//	VGA Blue[9:0] 
	);
	
	input 			CLOCK_50;				//50 MHz
	input  [5:0] 	SW;						// SW[5:0]: Square number
	input  [0:3] 	KEY;					// KEY[3]: START, KEY[1]: p_one, KEY[2]: p_two, KEY[0]: Reset
	//P square selection
	output  [6:0] 	HEX0;
	output  [6:0] 	HEX1;
	//P_one_score
	output 	[6:0]	HEX2;
	//P-two_score
	output 	[6:0]	HEX3;
	output  [0:4] 	LEDR;					// LEDR[1]: p_one turn, LEDR[2]: p_two turn, LEDR[3]: p_one_win, LEDR[4]: p_two_win
	
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock      
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;			//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0] 
	
	wire resetn, start, p_one, p_two, p_one_win, p_two_win;
	assign resetn = KEY[0];
	assign start = KEY[3];					//Game is by default in START mode if unpressed, if pressed game is in STOP mode
	assign p_one = ~KEY[1];
	assign p_two = ~KEY[2];
	assign p_one_win = LEDR[3];
	assign p_two_win = LEDR[4];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire enable;
	
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
		
	// Instansiate datapath
    datapath d0(SW[5:0], CLOCK_50, KEY[0], KEY[1], KEY[2], enable, x, y, colour);

    // Instansiate FSM control
    control c0(~KEY[1], ~KEY[2], KEY[0], CLOCK_50, enable, writeEn);
	
	/* Player turn indicator [START] */
	reg p_one_status, p_two_status;
	
	always @(*) 
	begin
		if(start && p_one)
		begin
			p_one_status <= 1;
		end
		else if (!start)
		begin
			p_one_status <= 0;
		end
	end
	always @(*)
	begin
		if(start && p_two)
		begin
			p_two_status <= 1;
		end
		else if (!start)
		begin
			p_two_status <= 0;
		end
	end
	
	assign LEDR[1] = p_one_status;
	assign LEDR[2] = p_two_status;
	/* Player turn indicator [END] */
	
	/* Player square selection indicator [START] */
	wire [7:0] hex_digit_wire;
	assign hex_digit_wire[7:5] = {2'b0, SW[5]};
	assign hex_digit_wire[4:0] = SW[4:0];
	
	hex_decoder h0(
		.hex_digit(hex_digit_wire[3:0]),
		.segments(HEX0)
	);
	hex_decoder h1(
		.hex_digit(hex_digit_wire[7:4]),
		.segments(HEX1)
	);
	/* Player square selection indicator [END] */
		
	wire [41:0] blue_square;
	wire [41:0] red_square;
	wire turn; 
	wire [3:0] p_one_score, p_two_score;
		
	fsm_controller fsm(
		.resetn(resetn),
		.p_one(p_one),
		.p_two(KEY[2]),
		.start(start),
		.square(SW[5:0]),
		.p_one_win(LEDR[3]),
		.p_two_win(LEDR[4]),
		.blue(blue_square),
		.red(red_square),
		.turn(turn),
		.p_one_score(p_one_score),
		.p_two_score(p_two_score)
	);
	
	hex_decoder h2(
		.hex_digit(p_one_score),
		.segments(HEX2)
	);

endmodule

module fsm_controller (resetn, p_one, p_two, start, square, p_one_win, p_two_win, blue, red, turn, p_one_score, p_two_score);
	
	input [5:0] square;
	input resetn, p_one, p_two, start;
	output reg [3:0] p_one_score, p_two_score;
	output reg p_one_win, p_two_win;
	output reg turn;
	output reg [41:0] blue, red;
	
	always @(*)
	begin
		if(resetn)
		begin
			blue 		<= 1'b0;
			red  		<= 1'b0;
			p_one_win 	<= 0;
			p_two_win   <= 0;
			turn        <= 0;
			p_one_score <= 4'h0;
			p_two_score <= 4'h0;
		end
		else if (!start)
		begin
			p_one_win <= 0;
			p_two_win <= 0;
			turn      <= 1;
		end
		else if (start==1 && p_one_win==0 && p_two_win==0)
		begin
			if (p_one==1)
			begin
				case(square)
					6'b000000: if(turn == 1 && blue[0]==0  && red[0]==0) 	 begin blue[0]<=1;  turn<=0; end
					6'b000001: if(turn == 1 && blue[1]==0  && red[1]==0) 	 begin blue[1]<=1;  turn<=0; end
					6'b000010: if(turn == 1 && blue[2]==0  && red[2]==0) 	 begin blue[2]<=1;  turn<=0; end
					6'b000011: if(turn == 1 && blue[3]==0  && red[3]==0) 	 begin blue[3]<=1;  turn<=0; end
					6'b000100: if(turn == 1 && blue[4]==0  && red[4]==0) 	 begin blue[4]<=1;  turn<=0; end
					6'b000101: if(turn == 1 && blue[5]==0  && red[5]==0) 	 begin blue[5]<=1;  turn<=0; end
					6'b000110: if(turn == 1 && blue[6]==0  && red[6]==0) 	 begin blue[6]<=1;  turn<=0; end
					6'b000111: if(turn == 1 && blue[7]==0  && red[7]==0) 	 begin blue[7]<=1;  turn<=0; end
					6'b001000: if(turn == 1 && blue[8]==0  && red[8]==0) 	 begin blue[8]<=1;  turn<=0; end
					6'b001001: if(turn == 1 && blue[9]==0  && red[9]==0) 	 begin blue[9]<=1;  turn<=0; end
					6'b001010: if(turn == 1 && blue[10]==0 && red[10]==0) 	 begin blue[10]<=1; turn<=0; end
					6'b001011: if(turn == 1 && blue[11]==0 && red[11]==0) 	 begin blue[11]<=1; turn<=0; end
					6'b001100: if(turn == 1 && blue[12]==0 && red[12]==0) 	 begin blue[12]<=1; turn<=0; end
					6'b001101: if(turn == 1 && blue[13]==0 && red[13]==0) 	 begin blue[13]<=1; turn<=0; end
					6'b001110: if(turn == 1 && blue[14]==0 && red[14]==0) 	 begin blue[14]<=1; turn<=0; end
					6'b001111: if(turn == 1 && blue[15]==0 && red[15]==0) 	 begin blue[15]<=1; turn<=0; end
					6'b010000: if(turn == 1 && blue[16]==0 && red[16]==0) 	 begin blue[16]<=1; turn<=0; end
					6'b010001: if(turn == 1 && blue[17]==0 && red[17]==0) 	 begin blue[17]<=1; turn<=0; end
					6'b010010: if(turn == 1 && blue[18]==0 && red[18]==0) 	 begin blue[18]<=1; turn<=0; end
					6'b010011: if(turn == 1 && blue[19]==0 && red[19]==0) 	 begin blue[19]<=1; turn<=0; end
					6'b010100: if(turn == 1 && blue[20]==0 && red[20]==0) 	 begin blue[20]<=1; turn<=0; end
					6'b010101: if(turn == 1 && blue[21]==0 && red[21]==0) 	 begin blue[21]<=1; turn<=0; end
					6'b010110: if(turn == 1 && blue[22]==0 && red[22]==0) 	 begin blue[22]<=1; turn<=0; end
					6'b010111: if(turn == 1 && blue[23]==0 && red[23]==0) 	 begin blue[23]<=1; turn<=0; end
					6'b011000: if(turn == 1 && blue[24]==0 && red[24]==0) 	 begin blue[24]<=1; turn<=0; end
					6'b011001: if(turn == 1 && blue[25]==0 && red[25]==0) 	 begin blue[25]<=1; turn<=0; end
					6'b011010: if(turn == 1 && blue[26]==0 && red[26]==0) 	 begin blue[26]<=1; turn<=0; end
					6'b011011: if(turn == 1 && blue[27]==0 && red[27]==0) 	 begin blue[27]<=1; turn<=0; end
					6'b011100: if(turn == 1 && blue[28]==0 && red[28]==0) 	 begin blue[28]<=1; turn<=0; end
					6'b011101: if(turn == 1 && blue[29]==0 && red[29]==0) 	 begin blue[29]<=1; turn<=0; end
					6'b011110: if(turn == 1 && blue[30]==0 && red[30]==0) 	 begin blue[30]<=1; turn<=0; end
					6'b011111: if(turn == 1 && blue[31]==0 && red[31]==0) 	 begin blue[31]<=1; turn<=0; end
					6'b100000: if(turn == 1 && blue[32]==0 && red[32]==0) 	 begin blue[32]<=1; turn<=0; end
					6'b100001: if(turn == 1 && blue[33]==0 && red[33]==0) 	 begin blue[33]<=1; turn<=0; end
					6'b100010: if(turn == 1 && blue[34]==0 && red[34]==0) 	 begin blue[34]<=1; turn<=0; end
					6'b100011: if(turn == 1 && blue[35]==0 && red[35]==0) 	 begin blue[35]<=1; turn<=0; end
					6'b100100: if(turn == 1 && blue[36]==0 && red[36]==0) 	 begin blue[36]<=1; turn<=0; end
					6'b100101: if(turn == 1 && blue[37]==0 && red[37]==0) 	 begin blue[37]<=1; turn<=0; end
					6'b100110: if(turn == 1 && blue[38]==0 && red[38]==0) 	 begin blue[38]<=1; turn<=0; end
					6'b100111: if(turn == 1 && blue[39]==0 && red[39]==0) 	 begin blue[39]<=1; turn<=0; end
					6'b101000: if(turn == 1 && blue[40]==0 && red[40]==0) 	 begin blue[40]<=1; turn<=0; end
					6'b101001: if(turn == 1 && blue[41]==0 && red[41]==0) 	 begin blue[41]<=1; turn<=0; end
				endcase
			end
			else
			begin
			p_two_win <= 1;
				case(square)
					6'b000000: if(turn == 1 && blue[0]==0  && red[0]==0) 	 begin red[0]<=1;  turn<=0; end
					6'b000001: if(turn == 1 && blue[1]==0  && red[1]==0) 	 begin red[1]<=1;  turn<=0; end
					6'b000010: if(turn == 1 && blue[2]==0  && red[2]==0) 	 begin red[2]<=1;  turn<=0; end
					6'b000011: if(turn == 1 && blue[3]==0  && red[3]==0) 	 begin red[3]<=1;  turn<=0; end
					6'b000100: if(turn == 1 && blue[4]==0  && red[4]==0) 	 begin red[4]<=1;  turn<=0; end
					6'b000101: if(turn == 1 && blue[5]==0  && red[5]==0) 	 begin red[5]<=1;  turn<=0; end
					6'b000110: if(turn == 1 && blue[6]==0  && red[6]==0) 	 begin red[6]<=1;  turn<=0; end
					6'b000111: if(turn == 1 && blue[7]==0  && red[7]==0) 	 begin red[7]<=1;  turn<=0; end
					6'b001000: if(turn == 1 && blue[8]==0  && red[8]==0) 	 begin red[8]<=1;  turn<=0; end
					6'b001001: if(turn == 1 && blue[9]==0  && red[9]==0) 	 begin red[9]<=1;  turn<=0; end
					6'b001010: if(turn == 1 && blue[10]==0 && red[10]==0) 	 begin red[10]<=1; turn<=0; end
					6'b001011: if(turn == 1 && blue[11]==0 && red[11]==0) 	 begin red[11]<=1; turn<=0; end
					6'b001100: if(turn == 1 && blue[12]==0 && red[12]==0) 	 begin red[12]<=1; turn<=0; end
					6'b001101: if(turn == 1 && blue[13]==0 && red[13]==0) 	 begin red[13]<=1; turn<=0; end
					6'b001110: if(turn == 1 && blue[14]==0 && red[14]==0) 	 begin red[14]<=1; turn<=0; end
					6'b001111: if(turn == 1 && blue[15]==0 && red[15]==0) 	 begin red[15]<=1; turn<=0; end
					6'b010000: if(turn == 1 && blue[16]==0 && red[16]==0) 	 begin red[16]<=1; turn<=0; end
					6'b010001: if(turn == 1 && blue[17]==0 && red[17]==0) 	 begin red[17]<=1; turn<=0; end
					6'b010010: if(turn == 1 && blue[18]==0 && red[18]==0) 	 begin red[18]<=1; turn<=0; end
					6'b010011: if(turn == 1 && blue[19]==0 && red[19]==0) 	 begin red[19]<=1; turn<=0; end
					6'b010100: if(turn == 1 && blue[20]==0 && red[20]==0) 	 begin red[20]<=1; turn<=0; end
					6'b010101: if(turn == 1 && blue[21]==0 && red[21]==0) 	 begin red[21]<=1; turn<=0; end
					6'b010110: if(turn == 1 && blue[22]==0 && red[22]==0) 	 begin red[22]<=1; turn<=0; end
					6'b010111: if(turn == 1 && blue[23]==0 && red[23]==0) 	 begin red[23]<=1; turn<=0; end
					6'b011000: if(turn == 1 && blue[24]==0 && red[24]==0) 	 begin red[24]<=1; turn<=0; end
					6'b011001: if(turn == 1 && blue[25]==0 && red[25]==0) 	 begin red[25]<=1; turn<=0; end
					6'b011010: if(turn == 1 && blue[26]==0 && red[26]==0) 	 begin red[26]<=1; turn<=0; end
					6'b011011: if(turn == 1 && blue[27]==0 && red[27]==0) 	 begin red[27]<=1; turn<=0; end
					6'b011100: if(turn == 1 && blue[28]==0 && red[28]==0) 	 begin red[28]<=1; turn<=0; end
					6'b011101: if(turn == 1 && blue[29]==0 && red[29]==0) 	 begin red[29]<=1; turn<=0; end
					6'b011110: if(turn == 1 && blue[30]==0 && red[30]==0) 	 begin red[30]<=1; turn<=0; end
					6'b011111: if(turn == 1 && blue[31]==0 && red[31]==0) 	 begin red[31]<=1; turn<=0; end
					6'b100000: if(turn == 1 && blue[32]==0 && red[32]==0) 	 begin red[32]<=1; turn<=0; end
					6'b100001: if(turn == 1 && blue[33]==0 && red[33]==0) 	 begin red[33]<=1; turn<=0; end
					6'b100010: if(turn == 1 && blue[34]==0 && red[34]==0) 	 begin red[34]<=1; turn<=0; end
					6'b100011: if(turn == 1 && blue[35]==0 && red[35]==0) 	 begin red[35]<=1; turn<=0; end
					6'b100100: if(turn == 1 && blue[36]==0 && red[36]==0) 	 begin red[36]<=1; turn<=0; end
					6'b100101: if(turn == 1 && blue[37]==0 && red[37]==0) 	 begin red[37]<=1; turn<=0; end
					6'b100110: if(turn == 1 && blue[38]==0 && red[38]==0) 	 begin red[38]<=1; turn<=0; end
					6'b100111: if(turn == 1 && blue[39]==0 && red[39]==0) 	 begin red[39]<=1; turn<=0; end
					6'b101000: if(turn == 1 && blue[40]==0 && red[40]==0) 	 begin red[40]<=1; turn<=0; end
					6'b101001: if(turn == 1 && blue[41]==0 && red[41]==0) 	 begin red[41]<=1; turn<=0; end
				endcase
			end
		end
	end
	
	always @(*)
		begin
			if(blue[0] == 1 && blue[6] == 1 && blue[12] == 1 && blue[18] == 1)
			begin p_one_win <= 1; end
			else if (blue[6] == 1 && blue[12] == 1 && blue[18] == 1 && blue[24] == 1)
			begin p_one_win <= 1; end
			else if (blue[12] == 1 && blue[18] == 1 && blue[24] == 1 && blue[30] == 1)
			begin p_one_win <= 1; end
			else if (blue[18] == 1 && blue[24] == 1 && blue[30] == 1 && blue[36] == 1)
			begin p_one_win <= 1; end
			else if (blue[0] == 1 && blue[1] == 1 && blue[2] == 1 && blue[3] == 1)
			begin p_one_win <= 1; end
			else
			begin p_one_win <= 0; end
		end
	
	always @(posedge p_one_win)
		begin
			p_one_score <= p_one_score + 4'h1;
		end
		
	always @(*)
		begin
			if(red[0] == 1 && red[6] == 1 && red[12] == 1 && red[18] == 1)
			begin p_two_win <= 1; end
			else if (red[6] == 1 && red[12] == 1 && red[18] == 1 && red[24] == 1)
			begin p_two_win <= 1; end
			else if (red[12] == 1 && red[18] == 1 && red[24] == 1 && red[30] == 1)
			begin p_two_win <= 1; end
			else if (red[18] == 1 && red[24] == 1 && red[30] == 1 && red[36] == 1)
			begin p_two_win <= 1; end
			else if (red[0] == 1 && red[1] == 1 && red[2] == 1 && red[3] == 1)
			begin p_two_win <= 1; end
			else
			begin p_two_win <= 0; end
		end
	
	always @(posedge p_two_win)
		begin
			p_two_score <= p_two_score + 4'h1;
		end

	
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
	wire	[1:0] 	controlA, controlB, controlC;

	always @ (posedge clock) begin
        if (reset_n) begin
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
				y1 <= 7'b0010101;
			end
			else if (data_in == 6'b001000) begin		// BOX 8
				x1 <= 8'b00011000;
				y1 <= 7'b0010101;
			end
			else if (data_in == 6'b001001) begin		// BOX 9
				x1 <= 8'b00101110;
				y1 <= 7'b0010101;
			end
			else if (data_in == 6'b001010) begin		// BOX 10
				x1 <= 8'b01000100;
				y1 <= 7'b0010101;
			end
			else if (data_in == 6'b001011) begin		// BOX 11
				x1 <= 8'b01011010;
				y1 <= 7'b0010101;
			end
			else if (data_in == 6'b001100) begin		// BOX 12
				x1 <= 8'b01110000;
				y1 <= 7'b0010101;
			end
			else if (data_in == 6'b001101) begin		// BOX 13
				x1 <= 8'b10000110;
				y1 <= 7'b0010101;
			end
			else if (data_in == 6'b001110) begin		// BOX 14
				x1 <= 8'b00000010;
				y1 <= 7'b0101000;
			end
			else if (data_in == 6'b001111) begin		// BOX 15
				x1 <= 8'b00011000;
				y1 <= 7'b0101000;
			end
			else if (data_in == 6'b010000) begin		// BOX 16
				x1 <= 8'b00101110;
				y1 <= 7'b0101000;
			end
			else if (data_in == 6'b010001) begin		// BOX 17
				x1 <= 8'b01000100;
				y1 <= 7'b0101000;
			end
			else if (data_in == 6'b010010) begin		// BOX 18
				x1 <= 8'b01011010;
				y1 <= 7'b0101000;
			end
			else if (data_in == 6'b010011) begin		// BOX 19
				x1 <= 8'b01110000;
				y1 <= 7'b0101000;
			end
			else if (data_in == 6'b010100) begin		// BOX 20
				x1 <= 8'b10000110;
				y1 <= 7'b0101000;
			end
			else if (data_in == 6'b010101) begin		// BOX 21
				x1 <= 8'b00000010;
				y1 <= 7'b0111011;
			end
			else if (data_in == 6'b010110) begin		// BOX 22
				x1 <= 8'b00011000;
				y1 <= 7'b0111011;
			end
			else if (data_in == 6'b010111) begin		// BOX 23
				x1 <= 8'b00101110;
				y1 <= 7'b0111011;
			end
			else if (data_in == 6'b011000) begin		// BOX 24
				x1 <= 8'b01000100;
				y1 <= 7'b0111011;
			end
			else if (data_in == 6'b011001) begin		// BOX 25
				x1 <= 8'b01011010;
				y1 <= 7'b0111011;
			end
			else if (data_in == 6'b011010) begin		// BOX 26
				x1 <= 8'b01110000;
				y1 <= 7'b0111011;
			end
			else if (data_in == 6'b011011) begin		// BOX 27
				x1 <= 8'b10000110;
				y1 <= 7'b0111011;
			end
			else if (data_in == 6'b011100) begin		// BOX 28
				x1 <= 8'b00000010;
				y1 <= 7'b1001110;
			end
			else if (data_in == 6'b011101) begin		// BOX 29
				x1 <= 8'b00011000;
				y1 <= 7'b1001110;
			end
			else if (data_in == 6'b011110) begin		// BOX 30
				x1 <= 8'b00101110;
				y1 <= 7'b1001110;
			end
			else if (data_in == 6'b011111) begin		// BOX 31
				x1 <= 8'b01000100;
				y1 <= 7'b1001110;
			end
			else if (data_in == 6'b100000) begin		// BOX 32
				x1 <= 8'b01011010;
				y1 <= 7'b1001110;
			end
			else if (data_in == 6'b100001) begin		// BOX 33
				x1 <= 8'b01110000;
				y1 <= 7'b1001110;
			end
			else if (data_in == 6'b100010) begin		// BOX 34
				x1 <= 8'b10000110;
				y1 <= 7'b1001110;
			end
			else if (data_in == 6'b100011) begin		// BOX 35
				x1 <= 8'b00000010;
				y1 <= 7'b1100001;
			end
			else if (data_in == 6'b100100) begin		// BOX 36
				x1 <= 8'b00011000;
				y1 <= 7'b1100001;
			end
			else if (data_in == 6'b100101) begin		// BOX 37
				x1 <= 8'b00101110;
				y1 <= 7'b1100001;
			end
			else if (data_in == 6'b100110) begin		// BOX 38
				x1 <= 8'b01000100;
				y1 <= 7'b1100001;
			end
			else if (data_in == 6'b100111) begin		// BOX 39
				x1 <= 8'b01011010;
				y1 <= 7'b1100001;
			end
			else if (data_in == 6'b101000) begin		// BOX 40
				x1 <= 8'b01110000;
				y1 <= 7'b1100001;
			end
			else if (data_in == 6'b101001) begin		// BOX 41
				x1 <= 8'b10000110;
				y1 <= 7'b1100001;
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
	output reg [1:0] q;

	always @(posedge clock) begin
		if (reset_n == 1'b0) begin
			q <= 2'b00;
		end
		else if (enable == 1'b1) begin
			if (q == 2'b11) begin
				q <= 2'b00;
			end
		  	else begin
			  	q <= q + 1'b1;
			end
		end
	end
endmodule

module rate_counter(clock, reset_n, enable, q);
	input clock, reset_n, enable;
	output reg [1:0] q;

	always @(posedge clock) begin
		if (reset_n == 1'b0) begin
			q <= 2'b11;
		end
		else if (enable == 1'b1) begin
		   	if (q == 2'b00) begin
				q <= 2'b11;
			end
			else begin
				q <= q - 1'b1;
			end
		end
	end
endmodule

module control (go_p1, go_p2, reset_n, clock, enable, plot);
	input go_p1, go_p2, reset_n, clock;
	output reg enable, plot;

	always@(*) begin
		// By default make all our signals 0
		enable = 1'b0;
		plot = 1'b0;

		if (go_p1 || go_p2) begin
			plot = 1'b1;
			enable = 1'b1;
		end
	end
endmodule


module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
	begin
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
	end

endmodule
	