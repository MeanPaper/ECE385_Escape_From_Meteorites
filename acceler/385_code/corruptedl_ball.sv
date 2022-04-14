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
					input [15:0] keycode,
					input [15:0] data_x, data_y,
					input [9:0] enemy_x, enemy_y, enemy_size,
					output Ball_die,
               output [9:0]  BallX, BallY, BallS );
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Ball_Size;
	 
    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=3;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=636;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=3;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=476;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis

    assign Ball_Size = 8;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
	
	logic [9:0] Ball_r; //ball radius
	assign Ball_r = Ball_Size >> 1;
	
	logic hit; //the ball
	
	
	always_ff @ (posedge frame_clk)
	begin
		if(((BallX - Ball_r) <= (enemy_x + enemy_size) )
			&& ((BallY - Ball_r) <= (enemy_y + enemy_size)) 
			&& (BallX + Ball_r) > enemy_x 
			&& (BallY + Ball_r) > enemy_y)
		begin
			hit <= 1'b1;
			Ball_die <= 1'b1;
		end
		else
		begin
			hit <= 1'b0;
			Ball_die <= 1'b0;
		end
	end
    
	 
	 
	always_ff @ (posedge Reset or posedge frame_clk)
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
        begin 
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
				Ball_Y_Pos <= Ball_Y_Center;
				Ball_X_Pos <= Ball_X_Center;
        end
		  
        else if(hit)
		  begin
				Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
				Ball_Y_Pos <= Ball_Y_Center;
				Ball_X_Pos <= Ball_X_Center;
		  end

		
        else 
        begin 
				if ( (Ball_Y_Pos + Ball_Size) >= Ball_Y_Max || (Ball_Y_Pos - Ball_Size) <= Ball_Y_Min )  // Ball is at the top/bottom edge, stop!
					Ball_Y_Motion <= 0;  // 2's complement.
					  
				if ( (Ball_X_Pos + Ball_Size) >= Ball_X_Max || (Ball_X_Pos - Ball_Size) <= Ball_X_Min)  // Ball is at the Right/left edge, BOUNCE!
					Ball_X_Motion <= 0;  // 2's complement.
				
				
				if(keycode[15:8] == 8'h04 || keycode[7:0] == 8'h04) //A
				begin
					if((Ball_X_Pos + Ball_X_Motion) > (Ball_X_Min + Ball_Size))
						Ball_X_Motion <= -3;
				end
				
				else if(keycode[15:8] == 8'h07 || keycode[7:0] == 8'h07) //D
				begin
					if((Ball_X_Pos + Ball_X_Motion) < (Ball_X_Max - Ball_Size))
						Ball_X_Motion <= 3;
				end
				else
				begin
					Ball_X_Motion <= 0;
				end
				
				
				if(keycode[15:8] == 8'h16 || keycode[7:0] == 8'h16) //S
				begin
					if((Ball_Y_Pos + Ball_Y_Motion) < (Ball_Y_Max - Ball_Size))
						Ball_Y_Motion <= 3;
				end
				
				else if(keycode[15:8] == 8'h1A || keycode[7:0] == 8'h1A) //W
				begin
					if((Ball_Y_Pos + Ball_Y_Motion) > (Ball_Y_Min + Ball_Size))
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
			
		end  
    end
       
    assign BallX = Ball_X_Pos;
   
    assign BallY = Ball_Y_Pos;
   
    assign BallS = Ball_Size;
    

endmodule
