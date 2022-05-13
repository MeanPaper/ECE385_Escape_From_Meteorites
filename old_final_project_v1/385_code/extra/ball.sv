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


module  ball ( input Reset, frame_clk,
					input [15:0] keycode,
					input [15:0] data_x, data_y,
               output [9:0]  BallX, BallY, BallS );
    
    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion, Ball_Size;
	 
    parameter [9:0] Ball_X_Center=320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center=240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min=0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max=639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min=0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max=479;     // Bottommost point on the Y axis
    parameter [9:0] Ball_X_Step=1;      // Step size on the X axis
    parameter [9:0] Ball_Y_Step=1;      // Step size on the Y axis

    assign Ball_Size = 8;  // assigns the value 4 as a 10-digit binary number, ie "0000000100"
   
    always_ff @ (posedge Reset or posedge frame_clk )
    begin: Move_Ball
        if (Reset)  // Asynchronous Reset
        begin 
            Ball_Y_Motion <= 10'd0; //Ball_Y_Step;
				Ball_X_Motion <= 10'd0; //Ball_X_Step;
				Ball_Y_Pos <= Ball_Y_Center;
				Ball_X_Pos <= Ball_X_Center;
        end
           
        else 
        begin 
				 if ( (Ball_Y_Pos + Ball_Size) >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
					  Ball_Y_Motion <= 0;  // 2's complement.
					  
				 if ( (Ball_Y_Pos - Ball_Size) <= Ball_Y_Min )  // Ball is at the top edge, BOUNCE!
					  Ball_Y_Motion <= 0;
					  
				 if ( (Ball_X_Pos + Ball_Size) >= Ball_X_Max )  // Ball is at the Right edge, BOUNCE!
					  Ball_X_Motion <= 0;  // 2's complement.
					  
				 if ( (Ball_X_Pos - Ball_Size) <= Ball_X_Min )  // Ball is at the Left edge, BOUNCE!
					  Ball_X_Motion <= 0;
					  
//				 else 
//					  Ball_Y_Motion <= Ball_Y_Motion;  // Ball is somewhere in the middle, don't bounce, just keep moving
					  
					  
				//bounds check using software
				
				
				//if(keycode == A) do something
				//if(keycode == W) do something
				 case (keycode[15:0])
					16'h0400 : begin
								if((Ball_X_Pos + Ball_X_Motion) > (Ball_X_Min + Ball_Size))
									begin
										Ball_X_Motion <= -2;//A
										//Ball_Y_Motion<= 0;
									end
								else
									begin
										Ball_X_Motion <= 0;//if the ball is out of bounds
										//Ball_Y_Motion<= 0; //the ball will never move
									end
									
							  end
					        
					16'h0700 : begin
								if((Ball_X_Pos + Ball_X_Motion) < (Ball_X_Max - Ball_Size))
									begin
										Ball_X_Motion <= 2;//D
										//Ball_Y_Motion <= 0;
									end
								else
									begin
										Ball_X_Motion <= 0;//if the ball is out of bounds
										//Ball_Y_Motion<= 0; //the ball will never move
									end
							  end

							  
					16'h1600 : begin
								if((Ball_Y_Pos + Ball_Y_Motion) < (Ball_Y_Max - Ball_Size))
									begin
										Ball_Y_Motion <= 2;//S
										//Ball_X_Motion <= 0;
									end
								else
									begin
										//Ball_X_Motion <= 0;//if the ball is out of bounds
										Ball_Y_Motion<= 0; //the ball will never move
									end
							 end
							  
					16'h1A00 : begin
								if((Ball_Y_Pos + Ball_Y_Motion) > (Ball_Y_Min + Ball_Size))
									begin
										Ball_Y_Motion <= -2;//W
										//Ball_X_Motion <= 0;
									end
								else
									begin
										//Ball_X_Motion <= 0;//if the ball is out of bounds
										Ball_Y_Motion<= 0; //the ball will never move
									end
							 end	  
							 
							 
					//16'h041A: begin
					
					
					
					
					default: begin
									Ball_X_Motion <= 0;//if the ball is out of bounds
									Ball_Y_Motion<= 0; //the ball will never move;
							   end
			   endcase
				 
				 Ball_Y_Pos <= (Ball_Y_Pos + Ball_Y_Motion);  // Update ball position
				 Ball_X_Pos <= (Ball_X_Pos + Ball_X_Motion);
			
      
			
		end  
    end
       
    assign BallX = Ball_X_Pos;
   
    assign BallY = Ball_Y_Pos;
   
    assign BallS = Ball_Size;
    

endmodule
