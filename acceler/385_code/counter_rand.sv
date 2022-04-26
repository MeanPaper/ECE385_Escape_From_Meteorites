module counter_rand(input Clk, Reset,
						  output[9:0] new_pos,
						  output[2:0] x_speed,
						  output[2:0] y_speed,
						  output sign
						  );
		 logic [31:0] counter;
		 
		 always_ff @ (posedge Clk)
		 begin
			if(Reset)
			begin
				counter <= 0;
			end
			else 
			begin
				counter <= counter + 1;
			end
		 end
		 
		 assign new_pos = counter[9:0];
		 assign sign = counter[4];
		 assign x_speed = counter[2:0];
		 assign y_speed = counter[8:6];
		 
endmodule
