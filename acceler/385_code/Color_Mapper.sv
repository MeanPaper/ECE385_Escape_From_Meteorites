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


module  color_mapper ( input        [9:0] BallX, BallY, DrawX, DrawY, Ball_size,
							  input 			[9:0]	Obj_X, Obj_Y, Obj_Size,
							  
							  input 			ball_activate,
							  
							  input 			blank, pixel_clk,
                       output logic [7:0]  Red, Green, Blue);
    
    logic ball_on;
	 
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
	  
	  
	logic box_on;
	
    int DistX, DistY, Size; 
//	 int box_X, box_Y, box_size;
	 
	 
	 assign DistX = DrawX - BallX;
    assign DistY = DrawY - BallY;
    assign Size = Ball_size;
	 
//	assign box_X = Obj_X;
//	assign box_Y = Obj_Y;
//	assign box_size = Obj_S;
	  
    always_comb
    begin:Ball_on_proc
        if ( ( DistX*DistX + DistY*DistY) <= (Size * Size) ) 
            ball_on = 1'b1;
        else 
            ball_on = 1'b0;
				
		if ( DrawX >= Obj_X && DrawX < (Obj_X + Obj_Size) && DrawY < (Obj_Y + Obj_Size) && DrawY >= Obj_Y) //box_on
			box_on = 1'b1;
		else
			box_on = 1'b0;
		
    end 
	  
	  
	  
	
	 //handling color drawing, but this is only one color
	 //in future, we need ram to store the data to be drawn
    always_ff @(posedge pixel_clk)
    begin:RGB_Display
		  if(!blank)
		  begin
				Red <= 8'h0;
				Blue <= 8'h0;
				Green <= 8'h0;
		  end
        else if ((ball_on == 1'b1)) //do the ball
        begin 
            Red <= 8'hff;
            Green <= 8'h55;
            Blue <= 8'h00;
        end
		
		else if ((box_on == 1'b1)) //do the square obstacle
		begin
			Red <= 8'hff;
			Green <= 8'h00; 
			Blue <= 8'h00;
		end
		
		
        else 
        begin //do the background
            Red <= 8'h00; 
            Green <= 8'h00;
            Blue <= 8'h7f- DrawX[9:3];
        end      
    end 
    
endmodule



//       
//    always_comb
//    begin:RGB_Display
//		  if(!blank)
//		  begin
//				Red = 8'h0;
//				Blue = 8'h0;
//				Green = 8'h0;
//		  end
//        else if ((ball_on == 1'b1)) 
//        begin 
//            Red = 8'hff;
//            Green = 8'h55;
//            Blue = 8'h00;
//        end       
//        else 
//        begin 
//            Red = 8'h00; 
//            Green = 8'h00;
//            Blue = 8'h7f; //- DrawX[9:3];
//        end      
//    end 