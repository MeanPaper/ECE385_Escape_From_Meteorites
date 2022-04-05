/************************************************************************
Avalon-MM Interface VGA Text mode display

Register Map:
0x000-0x0257 : VRAM, 80x30 (2400 byte, 600 word) raster order (first column then row)
0x258        : control register

VRAM Format:
X->
[ 31  30-24][ 23  22-16][ 15  14-8 ][ 7    6-0 ]
[IV3][CODE3][IV2][CODE2][IV1][CODE1][IV0][CODE0]

IVn = Draw inverse glyph
CODEn = Glyph code from IBM codepage 437

Control Register Format:
[[31-25][24-21][20-17][16-13][ 12-9][ 8-5 ][ 4-1 ][   0    ] 
[[RSVD ][FGD_R][FGD_G][FGD_B][BKG_R][BKG_G][BKG_B][RESERVED]

VSYNC signal = bit which flips on every Vsync (time for new frame), used to synchronize software
BKG_R/G/B = Background color, flipped with foreground when IVn bit is set
FGD_R/G/B = Foreground color, flipped with background when Inv bit is set

************************************************************************/
`define NUM_REGS 601 //80*30 characters / 4 characters per register
`define CTRL_REG 600 //index of control register

module vga_text_avl_interface (
	// Avalon Clock Input, note this clock is also used for VGA, so this must be 50Mhz
	// We can put a clock divider here in the future to make this IP more generalizable
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,					// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,			// Avalon-MM Byte Enable
	input  logic [9:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);

logic [31:0] LOCAL_REG       [`NUM_REGS]; // Registers
//put other local variables here

//logic ONE_ACTIVE;	
//assign ONE_ACTIVE = AVL_READ ^ AVL_WRITE; // only allow one of the operation: either read or write
//logic [31:0] temp_reg;
integer i;
logic [9:0] DrawX_pos, DrawY_pos; //use to contain DrawX and DrawY
logic pixel_clk, blank, sync;		 //other useful variables for VGA
logic [7:0]data; //used by the rom
logic [10:0]addr; //used by the rom
//logic [7:0]Red, Green, Blue; //used by color mapper
//logic [9:0]BallX, BallY, Ball_size;


//Declare submodules..e.g. VGA controller, ROMS, etc
vga_controller	vga(		.Clk(CLK),       // 50 MHz clock
                     .Reset(RESET),   // reset signal
												  // output are the followings
						   .hs(hs),         // Horizontal sync pulse.  Active low
						   .vs(vs),         // Vertical sync pulse.  Active low
				         .pixel_clk,      // 25 MHz pixel clock output
							.blank,          // Blanking interval indicator.  Active low.
							.sync,           // Composite Sync signal.  Active low.  We don't use it in this lab,
										        // but the video DAC on the DE2 board requires an input for it.
							.DrawX(DrawX_pos), // horizontal coordinate
						   .DrawY(DrawY_pos)
					);
					
//question on the rom, what does the rom take					
font_rom 	rom(.addr,			//addr of the character
					 .data			//data of the character
					);
				
//color_mapper	mapper( .BallX, 
//							  .BallY, 
//							  .DrawX(DrawX_pos), 
//							  .DrawY(DrawY_pos), 
//							  .Ball_size,
//                       .Red, 
//							  .Green, 
//							  .Blue
//							 );					

// Read and write from AVL interface to register block, note that READ waitstate = 1, so this should be in always_ff
always_ff @(posedge CLK) begin
	
	if(RESET)
	begin
		for(i = 0; i < `NUM_REGS; i = i + 1)
		begin
			LOCAL_REG[i] <= 32'b0;
		end
	end
	//otherwise see if there is a read or a write
	else if(AVL_CS)
	begin

//		if(ONE_ACTIVE && AVL_READ)
//		begin
//			AVL_READDATA <= LOCAL_REG[AVL_ADDR];
//		end
		
		if(AVL_WRITE) //ONE_ACTIVE && 
		begin	
			case(AVL_BYTE_EN)
				4'b1111: LOCAL_REG[AVL_ADDR] <= AVL_WRITEDATA; //reg = wr
				4'b1100:	LOCAL_REG[AVL_ADDR][31:16] <= AVL_WRITEDATA[31:16]; //reg = wr[31:16] + reg[15:0]
				4'b0011:	LOCAL_REG[AVL_ADDR][15:0] <= AVL_WRITEDATA[15:0]; //reg = reg[31:16] + wr[15:0]
				4'b1000: LOCAL_REG[AVL_ADDR][31:24] <= AVL_WRITEDATA[31:24]; //reg = wr[31:24] + reg[23:0]
				4'b0100: LOCAL_REG[AVL_ADDR][23:16] <= AVL_WRITEDATA[23:16]; //reg = reg[31:24] + wr[23:16] + reg[15:0]
				4'b0010: LOCAL_REG[AVL_ADDR][15:8] <= AVL_WRITEDATA[15:8]; //reg = reg[31:16] + wr[15:8] + reg[7:0] 
				4'b0001:	LOCAL_REG[AVL_ADDR][7:0] <= AVL_WRITEDATA[7:0]; //reg = reg[31:8] + wr[7:0]
			endcase
		end
		
		else if(AVL_READ) //ONE_ACTIVE &&
		begin
			AVL_READDATA <= LOCAL_REG[AVL_ADDR];
		end
		
	end
	
end
	
	/*
		reg col = drawX >> 3;
		reg row = drawY >> 4;
		num_reg = 20 * reg_row  + reg_col;
		
		
		draw within the reg
		character drawing
		char_x = drawX[2:0]; //this is the same as mod 8
		char_y = drawY[3:0]; //this is the same as mod 16
		char_pos = reg_col[1:0];
		addr = {reg[the corresponding char], char_y};
		
		the pxiel of the character is char_x 
	*/
	
	logic [9:0] reg_col, reg_row, num_reg, char_row;
	logic [2:0]	char_x;	//the x position of the character bit 
	logic [3:0] char_y;	//the y position of the character bit
	logic [1:0] char_pos; //character position in the vram
	logic [7:0] character;
	always_comb
	begin
		reg_col = DrawX_pos >> 5;	//this is the same as divided by 32 to get pos ition of reg
		reg_row = DrawY_pos >> 4;  //this is the same as divided by 16
		char_row = DrawX_pos >> 3;
		num_reg = 20 * reg_row + reg_col; //row major order: num of cols * row + col = the register to be read
		char_x = DrawX_pos[2:0];	//this is the same as mod 8
		char_y = DrawY_pos[3:0];	//this is the same as mod 16
		char_pos = char_row[1:0];		//this is the same as mod 4
		
		case(char_pos)
			2'h0: character = LOCAL_REG[num_reg][7:0];	//the first char
			2'h1: character = LOCAL_REG[num_reg][15:8];  //the second char
			2'h2: character = LOCAL_REG[num_reg][23:16]; //the third char
			2'h3: character = LOCAL_REG[num_reg][31:24]; //the fourth char
		endcase
		
		addr = {character[6:0],char_y}; //go to the corresponding address of the rom
		//data[7-char_x] is the pixel bit
		//character[7] is the inverted bit
//		

		
	end
	
	always_ff @(posedge pixel_clk)
	begin		
		if(!blank)
		begin
			red <= 4'b0;
			green <= 4'b0;
			blue <= 4'b0;
		end

		else if(character[7])	//if invert
		begin
			
			case(data[7-char_x])
				1'b1: //get background if 1
					begin
						red <= LOCAL_REG[`CTRL_REG][12:9];
						green <= LOCAL_REG[`CTRL_REG][8:5];
						blue <= LOCAL_REG[`CTRL_REG][4:1];
					end
				1'b0: //get foreground if 0
					begin
						red <= LOCAL_REG[`CTRL_REG][24:21];
						green <= LOCAL_REG[`CTRL_REG][20:17];
						blue <= LOCAL_REG[`CTRL_REG][16:13];	
					end
			endcase
			
		end
		
		else
		begin
			case(data[7-char_x])
				1'b1: //get foreground if 1
					begin
						red <= LOCAL_REG[`CTRL_REG][24:21];
						green <= LOCAL_REG[`CTRL_REG][20:17];
						blue <= LOCAL_REG[`CTRL_REG][16:13];	
					end
				1'b0: //get background if not 1
					begin
						red <= LOCAL_REG[`CTRL_REG][12:9];
						green <= LOCAL_REG[`CTRL_REG][8:5];
						blue <= LOCAL_REG[`CTRL_REG][4:1];
					end
			endcase	
		end
		
	end
	
//handle drawing (may either be combinational or sequential - or both).
	/*
		0 is the background in a char
		1 is the foreground in a char
		
		0 is not inverted
		1 is inverted, 0 get foregound, 1 get background
		
		if(character[7])
			if(data[7-char_x]) 	rgb gets background
			else			 		rgb gets foreground
		else
			if(data[7-char_x]) 	rgb gets foreground
			else			 		rgb gets background
	*/
	
//		if(!blank)
//		begin
//			red = 4'b0;
//			green = 4'b0;
//			blue = 4'b0;
//		end
//
//		else if(character[7])	//if invert
//		begin
//			
//			case(data[7-char_x])
//				1'b1: //get background if 1
//					begin
//						red = LOCAL_REG[`CTRL_REG][12:9];
//						green = LOCAL_REG[`CTRL_REG][8:5];
//						blue = LOCAL_REG[`CTRL_REG][4:1];
//					end
//				1'b0: //get foreground if 0
//					begin
//						red = LOCAL_REG[`CTRL_REG][24:21];
//						green = LOCAL_REG[`CTRL_REG][20:17];
//						blue = LOCAL_REG[`CTRL_REG][16:13];	
//					end
//			endcase
//			
//		end
//		
//		else
//		begin
//			case(data[7-char_x])
//				1'b1: //get foreground if 1
//					begin
//						red = LOCAL_REG[`CTRL_REG][24:21];
//						green = LOCAL_REG[`CTRL_REG][20:17];
//						blue = LOCAL_REG[`CTRL_REG][16:13];	
//					end
//				1'b0: //get background if not 1
//					begin
//						red = LOCAL_REG[`CTRL_REG][12:9];
//						green = LOCAL_REG[`CTRL_REG][8:5];
//						blue = LOCAL_REG[`CTRL_REG][4:1];
//					end
//			endcase
//			
//		end
endmodule
