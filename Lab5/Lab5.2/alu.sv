module ALU(	input logic[15:0] A,
				input logic[15:0]	B,
				input logic[1:0] ALUK,
				output logic[15:0] out
				);
				
		//00 -> add
		//01 -> and
		//10 -> not
		//11 -> pass A, the data of sr1
		always_comb
		begin
			case(ALUK)
				2'b00 : out = A + B;
				2'b01 : out = A & B;
				2'b10 : out = ~A;
				2'b11 : out = A;
			endcase
		end

endmodule
