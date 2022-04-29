

//a random number generator base on an upcounter
module counter_rand(input Clk, Reset,
						  input frame_Clk,
						  output[9:0] new_pos,
						  output[2:0] x_speed,
						  output[2:0] y_speed,
						  output sign
						  );
		 logic [31:0] counter;
		 logic [1:0] pos_neg;
		 always_ff @ (posedge Clk)
		 begin
			if(Reset)
			begin
				counter <= 0;
				//pos_neg <= 0;
			end
			else 
			begin
				counter <= counter + 1;
				//pos_neg <= pos_neg + 1;
			end
		 end
		 
		 assign new_pos = counter[9:0];
		 //assign sign = counter[31];
		 assign x_speed = counter[3:1];
		 assign y_speed = counter[6:4];

		 
		 always_ff @ (posedge frame_Clk or posedge Reset)
		 begin
			if(Reset)
				pos_neg <= 0;
			else
				pos_neg <= pos_neg + 1;
		 end
//		 
		 assign sign = pos_neg[0];
			
endmodule

