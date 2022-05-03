//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Fall 2014 Distribution                                             --
//                                                                       --
//    For use with ECE 298 Lab 7                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


//this is the module for spaceship
module  ball_two
					#(parameter obj_num = 4)
					( input Reset, frame_clk,
					input [24:0] keycode,
					input [15:0] data_x, data_y,
					input [9:0] enemy_x[obj_num], enemy_y[obj_num], enemy_size[obj_num],
					input enermy_alive[obj_num],
					output Ball_die,
					output left_move, right_move, //this will tell whether the spaceship is moving left or right
               output [9:0]  BallX, BallY, Ball_W, Ball_H);
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
	 
    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min= 9 ;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max= 630;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min= 32;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=473;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis
	 parameter [9:0] Ball_Y_bot = 450;
	 parameter [9:0] Ball_Width = 17;	//center to left / right
	 parameter [9:0] Ball_Height = 16;  //center to top / bottom
	 parameter [9:0] Ball_X_motion_Width = 14; //the move is slightly different
	 //parameter [3:0] obj_num = 4;
	
//	 assign Ball_W = Ball_Width;
	assign Ball_H = Ball_Height;
	always_comb
	begin
		case(left_move || right_move)
			1'b1: Ball_W = Ball_X_motion_Width;
			1'b0: Ball_W = Ball_Width;
		endcase
	end
	
	logic hit[obj_num]; //the ball hit the block
	 
	 
	always_ff @ (posedge Reset or posedge frame_clk)
    begin: Move_Ball
        
		  if (Reset)  // Asynchronous Reset
        begin 
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
				Ball_Y_Pos <= Ball_Y_bot; //initial position of the ball
				Ball_X_Pos <= Ball_X_Center; //initial position of the ball
				Ball_die <= 1'b0;
				//these are the default conditions
//				Ball_W <= Ball_Width;
//				Ball_H <= Ball_Height;
				left_move <= 0;
				right_move <= 0;
        end
		
        else 
        begin
//				Ball_W <= Ball_Width;
//				Ball_H <= Ball_Height;

		  
				if ( (Ball_Y_Pos + Ball_Height) > Ball_Y_Max || (Ball_Y_Pos - Ball_Height) < Ball_Y_Min )  // Ball is at the top/bottom edge, stop!
					Ball_Y_Motion <= 0;  // 2's complement.
					  
				if ( (Ball_X_Pos + Ball_W) > Ball_X_Max || (Ball_X_Pos - Ball_W) < Ball_X_Min)  // Ball is at the Right/left edge, BOUNCE!
					Ball_X_Motion <= 0;  // 2's complement.
				
				//parallel check for keycode A or D
				if(keycode[15:8] == 8'h04 || keycode[7:0] == 8'h04 || keycode[23:16] == 8'h04) //A
				begin
					
					//this only happen when the plane is using horizontal left movement
					//Ball_W <= Ball_X_motion_Width;
					left_move <= 1'b1;
					right_move <= 0;

					if((Ball_X_Pos + Ball_X_Motion) > (Ball_X_Min + Ball_Width))
						Ball_X_Motion <= -3;
				end
				
				else if(keycode[15:8] == 8'h07 || keycode[7:0] == 8'h07 || keycode[23:16] == 8'h07) //D
				begin
					
					//this only happen when the plane is using horizontal right movement
					//Ball_W <= Ball_X_motion_Width;
					right_move <= 1'b1;
					left_move <= 0;

					if((Ball_X_Pos + Ball_X_Motion) < (Ball_X_Max - Ball_Width))
						Ball_X_Motion <= 3;
				end
				else
				begin
					//reset everything if nothing is moving
					Ball_X_Motion <= 0;
					left_move <= 0;
					right_move <= 0;
				end
				
				//parallel check for keycode s or w
				if(keycode[15:8] == 8'h16 || keycode[7:0] == 8'h16 || keycode[23:16] == 8'h16) //S
				begin
					if((Ball_Y_Pos + Ball_Y_Motion) < (Ball_Y_Max - Ball_Height))
						Ball_Y_Motion <= 3;
				end
				
				else if(keycode[15:8] == 8'h1A || keycode[7:0] == 8'h1A || keycode[23:16] == 8'h1A) //W
				begin
					if((Ball_Y_Pos + Ball_Y_Motion) > (Ball_Y_Min + Ball_Height))
						Ball_Y_Motion <= -3;
				end
				else
				begin
					Ball_Y_Motion <= 0;
				end
				
				
				//WA or AW
				//WD or DW
				//SA or AS
				//SD or DS
				//the key are implemented 
				
				Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
				Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
			
		
			for(int i = 0; i<obj_num; i++) //detect whether the ball hit any of the boxes
			begin
				if(enermy_alive[i])
				begin
					if(((BallX - Ball_W) <= (enemy_x[i] + enemy_size[i]) )
						&& ((BallY - Ball_Height) <= (enemy_y[i] + enemy_size[i])) 
						&& (BallX + Ball_W) > enemy_x[i] 
						&& (BallY + Ball_Height) > enemy_y[i])
					begin
						hit[i] <= 1'b1;
						Ball_die <= 1'b1;
					end
					else
					begin
						hit[i] <= 1'b0;
					end
				end
			end
			
		  for(int i = 0; i < obj_num; i++)
		  begin
				if(hit[i]) //when the player hit one of the object
				begin
					Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
					Ball_X_Motion <= 10'd0; //Ball_X_Step;
					
					//to make the ball stop at fix position
					Ball_Y_Pos <= Ball_Y_bot;
					Ball_X_Pos <= Ball_X_Center;
				end
		  end
			
		end  
    end
       
    assign BallX = Ball_X_Pos;
   
    assign BallY = Ball_Y_Pos;
   
//    assign BallS = Ball_Size;
//do not need to fix the speed
//Ball_Y_Pos <= Ball_Y_Pos;
//Ball_X_Pos <= Ball_X_Pos


endmodule
