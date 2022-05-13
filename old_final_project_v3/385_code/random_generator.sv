module random_generater(input Clk, Reset,
								input object_alive[4],	//activation record
								output[9:0] new_obj_x,	//new position of the objects
								output[3:0] new_x_speed, new_y_speed	//new speed of the objects
								);
		//this would only work when the object is de-activated or the object is out of bounds 
		
		parameter [9:0] scale = 421;
		parameter [9:0] offset = 241;
		//parameter [3:0] obj_number = 4;
		//parameter [2:0] 
		
		
		//a formula to generate random number
		logic [9:0] counter; //a counter to create psuedo randomness		
		always_ff @ (posedge Clk)
		begin
			if(Reset)
				counter <= 0;
			else
				counter <= (scale * counter + offset);
				if(counter > 800)
				begin
					counter <= counter - 800;
				end
		end
		
		assign new_obj_x = counter;
		
		
//		//assign random number
//		always_ff @ (posedge Clk)
//		begin
//			for(int i = 0; i < obj_number; i++)
//			begin
//				if(!object_alive[i])
//				begin				end
//			end
//		end

endmodule
