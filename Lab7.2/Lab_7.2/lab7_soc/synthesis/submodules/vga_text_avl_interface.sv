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
//`define NUM_REGS 601 //80*30 characters / 4 characters per register
//`define CTRL_REG 600 //index of control register

`define CTRL_REG 8

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
	input  logic [11:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,		// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,		// Avalon-MM Read Data
	
	// Exported Conduit (mapped to VGA port - make sure you export in Platform Designer)
	output logic [3:0]  red, green, blue,	// VGA color channels (mapped to output pins in top-level)
	output logic hs, vs						// VGA HS/VS
);

logic [31:0] Palette  [`CTRL_REG]; // Registers

//logic [31:0] CTRL_REG; //onchip mem for 7.1



//put other local variables here
integer i;
logic [9:0] DrawX_pos, DrawY_pos; //use to contain DrawX and DrawY
logic pixel_clk, blank, sync;		 //other useful variables for VGA
logic [7:0]data; //used by the rom
logic [10:0]addr; //used by the rom

//a used by the avalon
//b used by the vga


//first palette location: 2048 in decimal = hex 800
//logic [3:0] address;
//modify this to get 7.1 working, set ctrl reg when avl_addr == 600
//code deleted
//modify this to get 7.1 working, set ctrl reg when avl_addr == 600
//using one reg

logic [31:0] temp;
logic [31:0] palette_color;
always_ff @(posedge CLK)
begin

if(AVL_CS)
	begin
		if(AVL_ADDR[11])
		begin
			if(AVL_WRITE)
				Palette[AVL_ADDR[2:0]] <= AVL_WRITEDATA; //write the control register based on the calculated index
			else if(AVL_READ)
				palette_color <= Palette[AVL_ADDR[2:0]];  //read the control register based on the calculated index
		end
	end
end

always_comb
begin
	case(AVL_ADDR[11])
		1'b0:	AVL_READDATA = temp;
		1'b1: AVL_READDATA = palette_color;
	endcase
end


//on chip memory
ram_dual  ram( 	.address_a(AVL_ADDR),	//avalon address
						.address_b(num_reg),				
						.byteena_a(AVL_BYTE_EN), //avalon enable	
						.byteena_b(4'b1111),
						.clock(CLK),
						.data_a(AVL_WRITEDATA),	//write data
//						.data_b(),
						.rden_a(AVL_READ),		//read signal a
						.rden_b(1'b1),	
						.wren_a(AVL_WRITE & (~AVL_ADDR[11])),		//write signal a
						.wren_b(1'b0),	
						.q_a(temp),		//data to avalon
						.q_b(char_data));


//Declare submodules..e.g. VGA controller, ROMS, etc
vga_controller	vga(	.Clk(CLK),       // 50 MHz clock
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
					

	logic [12:0] reg_col, reg_row, num_reg, char_row;
	logic [2:0]	char_x;	//the x position of the character bit 
	logic [3:0] char_y;	//the y position of the character bit
	
	//character position in the vram
	//in 7.1 it is mod 4
	//in 7.2 it is mod 2 since one reg has only 2 char
	//logic [1:0] char_pos;
	logic char_pos;
	
	// [15]: IV, [14-8]char, [7-4]for foreground color, [3-0]for background color
	logic [15:0] character_info; 
	
	logic [7:0] character;
	logic [31:0] char_data;
	
	logic [11:0] background;
	logic [11:0] foreground;
	
	//palette index calculation
	//logic [3:0] back_palette_row, fore_palette_row;
	logic back_palette_col, fore_palette_col;
	logic [31:0] palette_back, palette_fore;
	
	always_comb
	begin
		//to make 7.1 work, use the 7.1 code
		
		reg_col = DrawX_pos >> 4;	//because 4 char is slit into two reg, so we need to do 640/16 to find the right index
		reg_row = DrawY_pos >> 4;  //it is still 30 rows
		num_reg = 40 * reg_row  + reg_col; //convension should be modified
		char_row = DrawX_pos >> 3; //640/8
		char_x = DrawX_pos[2:0];	//this is the same as mod 8
		char_y = DrawY_pos[3:0];	//this is the same as mod 16
		char_pos = char_row[0];		//this is the same as mod 2
		
		case(char_pos)
			1'b0: character_info = char_data[15:0];	//the first char
			1'b1: character_info = char_data[31:16];  //the second char
		endcase
		
		//get the character with the inverted bit
		character = character_info[15:8];
		
		//get the address of the rom, note: data (line 62)is the character bit
		addr = {character[6:0],char_y};
		
		//eg. 0101 ---> 010
		//back_palette_row  = character_info[3:1]; //same as right shift 1 or divided by 2  
		back_palette_col = character_info[0];		//mod 2
		//fore_palette_row = character_info[7:5];	
		fore_palette_col = character_info[4];
		
		//take the bits divided by 2
		palette_back = Palette[character_info[3:1]];
		palette_fore = Palette[character_info[7:5]];
		
		case(back_palette_col)
			1'b0: background = palette_back[12:1];
			1'b1: background = palette_back[24:13];
		endcase

		case(fore_palette_col)
			1'b0: foreground = palette_fore[12:1];
			1'b1: foreground = palette_fore[24:13];
		endcase
		
	end
	
	
	
	
//draw the color on the screen
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
						red <= background[11:8];
						green <= background[7:4];
						blue <= background[3:0];
					end
				1'b0: //get foreground if 0
					begin
						red <= foreground[11:8];
						green <= foreground[7:4];
						blue <= foreground[3:0];	
					end
			endcase
			
		end
		
		else
		begin
			case(data[7-char_x])
				1'b1: //get foreground if 1
					begin
						red <= foreground[11:8];
						green <= foreground[7:4];
						blue <= foreground[3:0];		
					end
				1'b0: //get background if not 1
					begin
						red <= background[11:8];
						green <= background[7:4];
						blue <= background[3:0];
					end
			endcase	
		end
		
	end
	
//handle drawing (may either be combinational or sequential - or both).


//	always_comb
//	begin
//		reg_col = DrawX_pos >> 5;	//this is the same as divided by 32 to get pos ition of reg
//		reg_row = DrawY_pos >> 4;  //this is the same as divided by 16
//		char_row = DrawX_pos >> 3;
//		num_reg = 20 * reg_row + reg_col; //row major order: num of cols * row + col = the register to be read
//		char_x = DrawX_pos[2:0];	//this is the same as mod 8
//		char_y = DrawY_pos[3:0];	//this is the same as mod 16
//		char_pos = char_row[1:0];		//this is the same as mod 4
//		
//		case(char_pos)
//			2'h0: character = LOCAL_REG[num_reg][7:0];	//the first char
//			2'h1: character = LOCAL_REG[num_reg][15:8];  //the second char
//			2'h2: character = LOCAL_REG[num_reg][23:16]; //the third char
//			2'h3: character = LOCAL_REG[num_reg][31:24]; //the fourth char
//		endcase
//		
//		addr = {character[6:0],char_y}; //go to the corresponding address of the rom
//		//data[7-char_x] is the pixel bit
//		//character[7] is the inverted bit
////		
//
//		
//	end
//	
	
endmodule
