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

//this is fixed the newest version
//updated version
module  ball_two ( input Reset, frame_clk,
					input [24:0] keycode,
					input [15:0] data_x, data_y,
					input [9:0] enemy_x[4], enemy_y[4], enemy_size[4],
					input enermy_alive[4],
					output Ball_die,
               output [9:0]  BallX, BallY, Ball_W, Ball_H);
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
	 
    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=6;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=633;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=6;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=473;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis
	 parameter [9:0] Ball_Y_bot = 450;
	 parameter [9:0] Ball_Width = 17;	//center to left / right
	 parameter [9:0] Ball_Height = 16;  //center to top / bottom
	
	
	 assign Ball_W = Ball_Width;
	 assign Ball_H = Ball_Height;
	
	
	logic hit[4]; //the ball hit the block
	
	
	
	always_ff @ (posedge frame_clk)
	begin

	end
    
	 
	 
	always_ff @ (posedge Reset or posedge frame_clk)
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
        begin 
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
				Ball_Y_Pos <= Ball_Y_bot; //initial position of the ball
				Ball_X_Pos <= Ball_X_Center; //initial position of the ball
				Ball_die <= 1'b0;
        end
		
        else 
        begin 
				if ( (Ball_Y_Pos + Ball_Height) > Ball_Y_Max || (Ball_Y_Pos - Ball_Height) < Ball_Y_Min )  // Ball is at the top/bottom edge, stop!
					Ball_Y_Motion <= 0;  // 2's complement.
					  
				if ( (Ball_X_Pos + Ball_Width) > Ball_X_Max || (Ball_X_Pos - Ball_Width) < Ball_X_Min)  // Ball is at the Right/left edge, BOUNCE!
					Ball_X_Motion <= 0;  // 2's complement.
				
				//parallel check for keycode A or D
				if(keycode[15:8] == 8'h04 || keycode[7:0] == 8'h04 || keycode[23:16] == 8'h04) //A
				begin
					if((Ball_X_Pos + Ball_X_Motion) > (Ball_X_Min + Ball_Width))
						Ball_X_Motion <= -3;
				end
				
				else if(keycode[15:8] == 8'h07 || keycode[7:0] == 8'h07 || keycode[23:16] == 8'h07) //D
				begin
					if((Ball_X_Pos + Ball_X_Motion) < (Ball_X_Max - Ball_Width))
						Ball_X_Motion <= 3;
				end
				else
				begin
					Ball_X_Motion <= 0;
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
			
		
			for(int i = 0; i<4; i++) //detect whether the ball hit any of the boxes
			begin
				if(enermy_alive[i])
				begin
					if(((BallX - Ball_Width) <= (enemy_x[i] + enemy_size[i]) )
						&& ((BallY - Ball_Height) <= (enemy_y[i] + enemy_size[i])) 
						&& (BallX + Ball_Width) > enemy_x[i] 
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
			
		  for(int i = 0; i < 4; i++)
		  begin
				if(hit[i]) //when the player hit one of the object
				begin
					Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
					Ball_X_Motion <= 10'd0; //Ball_X_Step;
					
					//to make the ball stop at fix position
					//do not need to fix the speed
					//Ball_Y_Pos <= Ball_Y_Pos;
					//Ball_X_Pos <= Ball_X_Pos
					Ball_Y_Pos <= Ball_Y_Center;
					Ball_X_Pos <= Ball_X_Center;
				end
		  end
			
		end  
    end
       
    assign BallX = Ball_X_Pos;
   
    assign BallY = Ball_Y_Pos;
   
//    assign BallS = Ball_Size;
    

endmodule
