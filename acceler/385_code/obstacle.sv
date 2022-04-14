module obstacle(input Reset, frame_clk,

					 output [9:0] object_Size, //object size
					 output [9:0] object_X, object_Y, //object location
					 output obstacle_activate		  //the object is on, this is important
													  //if the object hit the bottom, then
													  //it will be deactivated
					);	
					
    parameter [9:0] Obj_X_Min=3;       // Leftmost point on the X axis
    parameter [9:0] Obj_X_Max=636;     // Rightmost point on the X axis
    parameter [9:0] Obj_Y_Min=3;       // Topmost point on the Y axis
    parameter [9:0] Obj_Y_Max=476;     	// Bottommost point on the Y axis
    parameter [9:0] Obj_X_Step=1;      // Step size on the X axis
    parameter [9:0] Obj_Y_Step=1;      // Step size on the Y axis
	 parameter int speed = 1;
	 
	 logic [9:0] obj_x_pos, obj_y_pos;
	 logic [9:0] x_motion, y_motion;
	 
	 //default position, use for testing
		assign object_Size = 20;
		assign object_X = obj_x_pos; //9'd200;
		assign object_Y = obj_y_pos; //9'd200;
	 
	 
	 always_ff @(posedge Reset or posedge frame_clk)
	 begin
		if(Reset)
		begin
			obj_x_pos <= 9'd200;
			obj_y_pos <= Obj_Y_Min;
		end
		
		else
		begin
			if( obj_y_pos > (Obj_Y_Max - object_Size))
			begin
				obj_x_pos <= 9'd200;
				obj_y_pos <= Obj_Y_Min;
			end 
			else 
			begin
				obj_y_pos <=  obj_y_pos + speed;
			end
		end
		

	 end
	 
	 //mem x,y,size, sprite, tile, presents
	 /*
	 always_ff
	 for()
		A[1] <= 0
		A[2] <= 1
	 */

	 


endmodule
