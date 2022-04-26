module random_generater(input Clk, Reset,
								//input object_alive[4],	//activation record
								output[9:0] new_obj_x,	//new position of the objects
								output[2:0] new_x_speed, new_y_speed	//new speed of the objects
								);
		//this would only work when the object is de-activated or the object is out of bounds 
		
		parameter [9:0] scale = 421;
		parameter [9:0] offset = 313;
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


//this code comes from the following website
//
module LFSR_v1	//the default parameter is 3, but it can be changed
				#(parameter N = 9)
				(
					input Clk, Reset,
					output[N:0] random_position
				 );
				 
				logic [N:0] current;
				logic [N:0] next;
				logic feedback;
                        
			always @(posedge Clk, posedge Reset)
			begin 
				if (Reset)
				begin
					current <= 1; 
        
				end     
				else
					current <= next;
			end

			//// N = 9
			assign feedback = current[9] ^ current[5] ^ current[0];
			assign next = {feedback, current[N:1]};
			assign random_position = current;   
			
				

endmodule
