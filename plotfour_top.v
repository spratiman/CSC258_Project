
module plotfour_top (
	CLOCK_50,								// On Board 50 MHz
	KEY,									// KEY[3]: START, KEY[1]: P_one, KEY[2]: P_two, KEY[0]: resetn 
	SW,										// SW[0:5]: Input square number
	HEX0,
	HEX1,
	LEDR
	// The ports below are for the VGA output.  Do not change.
	//VGA_CLK,   								//	VGA Clock
	//VGA_HS,									//	VGA H_SYNC
	//VGA_VS,									//	VGA V_SYNC
	//VGA_BLANK_N,							//	VGA BLANK
	//VGA_SYNC_N,								//	VGA SYNC
	//VGA_R,   								//	VGA Red[9:0]
	//VGA_G,	 								//	VGA Green[9:0]
	//VGA_B   								//	VGA Blue[9:0] 
	);
	
	input 			CLOCK_50;				//50 MHz
	input  [5:0] 	SW;						// SW[5:0]: Square number
	input  [0:3] 	KEY;					// KEY[3]: START, KEY[1]: p_one, KEY[2]: p_two, KEY[0]: Reset
	//P square selection
	output  [6:0] 	HEX0;
	output  [6:0] 	HEX1;
	output  [0:4] 	LEDR;					// LEDR[1]: p_one turn, LEDR[2]: p_two turn, LEDR[3]: p_one_win, LEDR[4]: p_two_win
	
	// Do not change the following outputs
	/*output			VGA_CLK;   				//	VGA Clock      
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;			//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0] */
	
	wire resetn, start, p_one, p_two, p_one_win, p_two_win;
	assign resetn = KEY[0];
	assign start = KEY[3];					//Game is by default in START mode if unpressed, if pressed game is in STOP mode
	assign p_one = ~KEY[1];
	assign p_two = ~KEY[2];
	assign p_one_win = LEDR[3];
	assign p_two_win = LEDR[4];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	/*wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire enable,ld_x,ld_y,ld_c;*/
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	/*vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			/*.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";*/
	
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
		
	wire [19:0] blue_square;
	wire [19:0] red_square;
	wire turn;
		
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
		.turn(turn)
	);

endmodule

module fsm_controller (resetn, p_one, p_two, start, square, p_one_win, p_two_win, blue, red, turn);
	
	input [5:0] square;
	input resetn, p_one, p_two, start;
	output reg p_one_win, p_two_win;
	output reg turn;
	output reg [19:0] blue, red;
	
	always @(*)
	begin
		if(resetn)
		begin
			blue 		<= 1'b0;
			red  		<= 1'b0;
			p_one_win 	<= 0;
			p_two_win   <= 0;
			turn        <= 0;
		end
		else if (!start)
		begin
			p_one_win <= 0;
			p_two_win <= 0;
			turn      <= 1;
		end
		else if (start)
		begin
			if(!p_one_win && !p_two_win)
			begin
				case(square)
					5'b00000: if(turn == 1 && blue[0]==0 && red[0]==0) 	 begin blue[0]<=1;  turn<=0; end
					5'b00001: if(turn == 1 && blue[1]==0 && red[1]==0) 	 begin blue[1]<=1;  turn<=0; end
					5'b00010: if(turn == 1 && blue[2]==0 && red[2]==0) 	 begin blue[2]<=1;  turn<=0; end
					5'b00011: if(turn == 1 && blue[3]==0 && red[3]==0) 	 begin blue[3]<=1;  turn<=0; end
					5'b00100: if(turn == 1 && blue[4]==0 && red[4]==0) 	 begin blue[4]<=1;  turn<=0; end
					5'b00101: if(turn == 1 && blue[5]==0 && red[5]==0) 	 begin blue[5]<=1;  turn<=0; end
					5'b00110: if(turn == 1 && blue[6]==0 && red[6]==0) 	 begin blue[6]<=1;  turn<=0; end
					5'b00111: if(turn == 1 && blue[7]==0 && red[7]==0) 	 begin blue[7]<=1;  turn<=0; end
					5'b01000: if(turn == 1 && blue[8]==0 && red[8]==0) 	 begin blue[8]<=1;  turn<=0; end
					5'b01001: if(turn == 1 && blue[9]==0 && red[9]==0) 	 begin blue[9]<=1;  turn<=0; end
					5'b01010: if(turn == 1 && blue[10]==0 && red[10]==0) begin blue[10]<=1; turn<=0; end
					5'b01011: if(turn == 1 && blue[11]==0 && red[11]==0) begin blue[11]<=1; turn<=0; end
					5'b01100: if(turn == 1 && blue[12]==0 && red[12]==0) begin blue[12]<=1; turn<=0; end
					5'b01101: if(turn == 1 && blue[13]==0 && red[13]==0) begin blue[13]<=1; turn<=0; end
					5'b01110: if(turn == 1 && blue[14]==0 && red[14]==0) begin blue[14]<=1; turn<=0; end
					5'b01111: if(turn == 1 && blue[15]==0 && red[15]==0) begin blue[15]<=1; turn<=0; end
					5'b10000: if(turn == 1 && blue[16]==0 && red[16]==0) begin blue[16]<=1; turn<=0; end
					5'b10001: if(turn == 1 && blue[17]==0 && red[17]==0) begin blue[17]<=1; turn<=0; end
					5'b10010: if(turn == 1 && blue[18]==0 && red[18]==0) begin blue[18]<=1; turn<=0; end
					5'b10011: if(turn == 1 && blue[19]==0 && red[19]==0) begin blue[19]<=1; turn<=0; end
				endcase
			end
		end
	end
	
	always @(*)
		begin
			if(blue[0] == 1 && blue[5] == 1 && blue[10] == 1 && blue[15] == 1)
			begin p_one_win <= 1; end
			else if (blue[0] == 1 && blue[4] == 1 && blue[8] == 1 && blue[12] == 1)
			begin p_one_win <= 1; end
			else if (blue[1] == 1 && blue[5] == 1 && blue[9] == 1 && blue[13] == 1)
			begin p_one_win <= 1; end
			else if (blue[2] == 1 && blue[6] == 1 && blue[10] == 1 && blue[14] == 1)
			begin p_one_win <= 1; end
			else if (blue[3] == 1 && blue[7] == 1 && blue[11] == 1 && blue[15] == 1)
			begin p_one_win <= 1; end
			else
			begin p_one_win <= 0; end
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
	