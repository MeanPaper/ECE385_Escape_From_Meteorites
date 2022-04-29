//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//                                                                       --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 7                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------


module  color_mapper 
							#(parameter obj_num = 4)
							
							( 	input	[9:0] 	BallX, BallY, DrawX, DrawY, BallWidth, BallHeight,
								input 	left_motion, right_motion, //use for right and left motion
								input 	[9:0]	Obj_X[obj_num], Obj_Y[obj_num], Obj_Size[obj_num],
								input 	Obj_act[obj_num], //activation of the objects
								input 	vs,
								input 	[9:0]	bullet_x, bullet_y,	bullet_size,	//the postion of x and y as well as the size
								input			bullet_activate,	  
								input 		ball_activate,
								
								//signal_from the state machine
								input start_screen, game_screen, game_over,
							
								input 		ram_clk, blank, pixel_clk,
                       	output logic [7:0]  Red, Green, Blue);
    
    logic ball_on;
	 
	 
	parameter ADDR_WIDTH = 13;
	parameter BACK_WIDTH = 16;
   parameter DATA_WIDTH =  24;
	parameter left_bound = 214;
	parameter right_bound = 215;
	parameter text_height = 21;
	parameter start_text_x = 320;
	parameter start_text_y = 240;
	//
   
	//palette for the color of the spaceship
	parameter [0:ADDR_WIDTH-1] [DATA_WIDTH-1:0] ROM = {
			24'hFF00FF,
			24'h000000, 
			24'hFFFFFF,
			24'h313129, 
			24'h5A5A52,
			24'h848C73,
			24'h840000, 
			24'hFF0000,
			24'h848400, 
			24'hFFFF00,	//read this 0
			24'hA5AD94, // 1
			24'h0084FF, //read this 2
			24'h0042BD	//read this 3

   };

	parameter [0:15] [DATA_WIDTH-1:0] Back_ROM = { 
			24'h57D3FF, //0
			24'h6AD3FF, //1
			24'h366DB6, //2
			24'h2F7ABD, //3
			24'h67C4FF, //4
			24'h7942B0, //5
			24'h091F73, //6
			24'hD397FF, //7
			24'h1D0063, //8
			24'h9158C7, //9
			24'hAA85ED, //a
			24'h2B1276, //b
			24'h131570,
			24'h48107F,
			24'hE0BBFF,
			24'h00186A};
			
	parameter [0:7] [DATA_WIDTH-1:0] text_color = {24'h000000, 24'hF8F8F8, 24'h780000, 24'hB00000, 24'hF03000, 24'hF89018, 24'hF86800, 24'hF8D030};
	parameter [0:4] [DATA_WIDTH-1:0] asteroid_Rom = {24'hFF00FF, 24'h313129, 24'h5A5A52, 24'h848C73, 24'hA5AD94};
 /* Old Ball: Generated square box by checking if the current pixel is within a square of length
    2*Ball_Size, centered at (BallX, BallY).  Note that this requires unsigned comparisons.
	 
    if ((DrawX >= BallX - Ball_size) &&
       (DrawX <= BallX + Ball_size) &&
       (DrawY >= BallY - Ball_size) &&
       (DrawY <= BallY + Ball_size))

     New Ball: Generates (pixelated) circle by using the standard circle formula.  Note that while 
     this single line is quite powerful descriptively, it causes the synthesis tool to use up three
     of the 12 available multipliers on the chip!  Since the multiplicants are required to be signed,
	  we have to first cast them from logic to int (signed by default) before they are multiplied). */
	  
	  
	logic box_on[obj_num];
	logic bullet_on;
	
    int DistX, DistY; 
//	 int box_X, box_Y, box_size;
	 
	 
	assign DistX = DrawX - BallX;
   assign DistY = DrawY - BallY;


	int bulletX, bulletY, bulletS;
	assign bulletX = DrawX - bullet_x;
	assign bulletY = DrawY - bullet_y;
	assign bulletS = bullet_size;
	
	

//spaceship info start here
	logic [18:0] read_address; //, back_addr;
	logic [3:0]	data_Out;
	//logic [23:0] rgb;
	
spriteROM 	spaceship(
					.we(1'b0),
					.read_address,
					.Clk(ram_clk), //please use the 50MHz //small change
					.data_Out
							);
							
							
	logic [3:0] back_data;
	logic [18:0] index;
	logic[9:0] back_col;
backgroundROM	 background(	//this is the background of ram
						.we(1'b0),
						.read_address(index),
						.Clk(ram_clk),
						.data_Out(back_data)
										);
										
										
//asteroid rom										
	logic [18:0] asteroid_addr;
	logic [18:0] one_asteroid[obj_num]; //keep track of the pixel addr
	logic [3:0]	asteroid_pixel;
	
asteroid_ROM	asteroid(
						.we(1'b0),
						.read_address(asteroid_addr),
						.Clk(ram_clk), //please use the 50MHz //small change
						.data_Out(asteroid_pixel)
					);
// text rom start here
	logic [18:0] text_addr;
	logic [3:0] text_pixel;
text_Rom 	screenText(
					.we(1'b0),
					.read_address(text_addr),
					.Clk(ram_clk), 
					.data_Out(text_pixel)
							);
	
	
	 logic start_text_on;
	
    always_comb
    begin:Ball_on_proc
	 
	 
       if(DrawX >= 106 && DrawX <= 535 && DrawY >= 240 && DrawY <= 261) //draw the text
		 begin
			start_text_on = 1'b1;
		 end
		 else
		 begin
			start_text_on = 1'b0;
		 end
		 
		 
		 
		 if ((DistX >= -17) && (DistX <= 17) && (DistY >= -16) && (DistY <= 16)) 
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;

		if ( ( bulletX * bulletX + bulletY * bulletY) <= (bulletS*bulletS) && bullet_activate)
			bullet_on = 1'b1;
		else
			bullet_on = 1'b0;

		for(int i = 0; i < obj_num; i++)
		begin
			if (Obj_act[i] 	//only draw the box if the object is active 
				&& DrawX >= Obj_X[i] 
				&& DrawX < (Obj_X[i] + Obj_Size[i]) 
				&& DrawY < (Obj_Y[i] + Obj_Size[i]) 
				&& DrawY >= Obj_Y[i] ) //box_on

				box_on[i] = 1'b1;
			else
				box_on[i] = 1'b0;
		end
		//determine the back ground 
		 back_col = DrawX % 160;
		 index = DrawY * 160 + back_col;
		 
		 
		 
		 //this will deal will all the coloring fpr background
//		 if(start_screen)
//		 begin
//			R = 8'hff; 
//			G = 8'hff;
//			B = 8'hff;
//		 end
//		 else if(game_screen)
//		 begin
//			R = Back_ROM[back_data][23:16];
//			G = Back_ROM[back_data][15:8];
//			B = Back_ROM[back_data][7:0];
//		 end
//		 else if(game_over)
//		 begin
//			R = 8'hff;
//			G = 8'h00;
//			B = 8'hff;
//		 end
		 
    end 
	  
	 //if the loop doesn't work then delete the loops
	  
	
	 //handling color drawing, but this is only one color
	 //in future, we need ram to store the data to be drawn
	always_ff @(posedge pixel_clk)
	begin:RGB_Display
		if(!blank) 			//blank and other draw signal should be in the same if else block
		begin					//other check conidition should not change the structure of this if else block
			Red <= 8'h0;
			Blue <= 8'h0;
			Green <= 8'h0;
			//read_address <= 0;
		end
		else
		begin  //do the background

//				Red <= 8'h00; 
//         	Green <= 8'h00;
//         	Blue <= 8'h7f- DrawX[9:3];

		
			if(start_screen)
			begin
				Red <= Back_ROM[back_data][23:16];
				Green <= Back_ROM[back_data][15:8];
				Blue <= Back_ROM[back_data][7:0];
				
				//use the background
				
				if(start_text_on)
				begin
					if(text_pixel)
					begin
//						Red <= 8'h0;
//						Blue <= 8'h0;
//						Green <= 8'h0;
						//do text here
						Red <= text_color[text_pixel][23:16];
						Green <= text_color[text_pixel][15:8];
						Blue <= text_color[text_pixel][7:0];
					end
				end
				/*
				if(text_flash)
				begin
					text_address <= text_address + 1;
					Red <= text_color[text_data][23:16];
					Green <= text_color[text_data][15:8];
					Blue <= text_color[text_data][7:0];
				end
				*/
				
			end
			else if(game_over)
			begin
				Red <= Back_ROM[back_data][23:16];
				Green <= Back_ROM[back_data][15:8];
				Blue <= Back_ROM[back_data][7:0];
				
				//use the background
				/*
				if(text_flash)
				begin
					text_address <= text_address + 1;
					Red <= text_color[text_data][23:16];
					Green <= text_color[text_data][15:8];
					Blue <= text_color[text_data][7:0];
				end
				*/
			end
			
			else if(game_screen)	//only do the drawing when the game is on.
			begin		
				Red <= Back_ROM[back_data][23:16];
				Green <= Back_ROM[back_data][15:8];
				Blue <= Back_ROM[back_data][7:0];
				//small change
				for(int i = 0; i < obj_num; i++) //deal with all the asteroid
				begin				
					if(box_on[i]) //this will only draw box if the box is active
					begin
//						Red <= 8'hff;
//						Green <= 8'h00;
//						Blue <= 8'h00;
						
						asteroid_addr <= one_asteroid[i]; //get the current asteroid pixel addr info
						if(asteroid_pixel) //ignore the pink transparency
						begin
							Red <= asteroid_Rom[asteroid_pixel][23:16];
							Green <= asteroid_Rom[asteroid_pixel][15:8]; 
							Blue <= asteroid_Rom[asteroid_pixel][7:0];
						end
						one_asteroid[i] <= one_asteroid[i] + 1; //address increment
						
						
					end
				end
				
				if (bullet_on) //do the bullet
				begin
					begin
						Red <= 8'hff;
						Green <= 8'hff;
						Blue <= 8'h00;
					end
				end

				if ((ball_on == 1'b1)) //do the ball
				begin 
					if(data_Out)
					begin
	//					Red <= 8'hff;
	//					Green <= 8'hff;
	//					Blue <= 8'h00;
						Red <= ROM[data_Out][23:16];//8'hff;
						Green <= ROM[data_Out][15:8];//8'h55;
						Blue <= ROM[data_Out][7:0];//8'h00;
					end
					read_address <= read_address + 1; //read from the rom
				end
				
			 end
			 

		end
		
		//leave the vertical sync outside of screen logics
		if(!vs) //vertical sync, this is for the plane
		begin
			text_addr <= 0;
			read_address <= 0;
			if(left_motion)
						read_address <= 1155;
			else if(right_motion)
						read_address <= 2310;
			
			
			for(int i = 0; i < obj_num; i++)
			begin
				one_asteroid[i] <= 0; //each asteroid holds it only pixel addr
			end
			//back_addr <= 0;	//initial the back_ground addr
			
			//text_flash <= ~text_flash;
		end
		
	end

	logic text_flash;
	
	  
endmodule
