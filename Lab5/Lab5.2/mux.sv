module mux2to1(input logic [15:0] A,B,
									
					input logic select,

					output logic [15:0] out
					
					);
		always_comb
		begin	
			case(select) //output depend on the select bit
			
				1'b0:	out = A; //select = 0
				1'b1:	out = B; //select = 1
				default: out = 16'hxxxx; //default output A
										//changes to don't care
				
			endcase
		end
						


endmodule


//4 to 1 mux, specifically for PC 
module mux4to1(input logic [15:0] IN_0, IN_1, IN_2, IN_3,
									
					input logic [1:0] select,
					
					output logic [15:0] out
					);
	
		always_comb
		begin
			case(select)
					
				2'b00:	out = IN_0;
				2'b01:	out = IN_1;
				2'b10:	out = IN_2;
				2'b11:	out = IN_3;
				default: out = 16'hxxxx; //default output: self increment
											//change to don't care
				
			endcase
		end

endmodule


//the 4 gates for the datapath
module gateMux(input logic [15:0] GATE_0, GATE_1, GATE_2, GATE_3,
					
					input logic [3:0]	select,
					
					output logic [15:0] out
							
					);
					
					
		always_comb
		begin
			case(select)
				
				4'b1000: out = GATE_0; //gate 1 use in part1
				4'b0100: out = GATE_1; //gate 2 use in part2
				4'b0010: out = GATE_2; //gate 3 not use for now
				4'b0001: out = GATE_3; //gate 4 not use for now
				
				default: out = 16'hxxxx; // change from 0s to don't care
				
			endcase
		end 
					
					
endmodule 
