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



//the module below are designed specifically for register files 

//for the output of the register file
//8 to 1 mux, 16-bit stream
module mux8to1(input logic [15:0] in[8], //an array of size 8 with 16-bit elements
					input logic [2:0]	select,
					output logic [15:0] out
					);
					
		always_comb
		begin
			case(select)
				3'b000: out = in[0][15:0]; //port 0: first input
				3'b001: out = in[1][15:0];				
				3'b010: out = in[2][15:0];			
				3'b011: out = in[3][15:0];				
				3'b100: out = in[4][15:0];
				3'b101: out = in[5][15:0];
				3'b110: out = in[6][15:0];
				3'b111: out = in[7][15:0]; //port 7: 8th input
				
				default: out = 16'hxxxx;
				endcase
		end
		

endmodule


//for the selection of the register file
//2 to 1 mux with 3 bit inputs and outputs
module mux3bit(input logic [2:0] in0, in1,
					input logic select,
					output logic [2:0] out
					);
					
		always_comb
		begin
			case(select)
				1'b0: out = in0;
				1'b1: out = in1;
				
				default: out = 3'bxxx;
			endcase
		end
		
endmodule


//to select the register to be load
//3bit input decoder
module decoder3bit(input logic [2:0] in,
						 input logic enable,  //in reg files, this connect to LD.REG
						 output logic [7:0] out //8 bit output
						);
		always_comb
		begin
			
			if(enable)
			begin
				
				//use decimals if the binary is to annoying
				case(in)
					3'b000: out = 8'h01; //8'h01 1st 0000 0001
					3'b001: out = 8'h02; //8'h02 2nd 0000 0010
					3'b010: out = 8'h04; //8'h04 3rd 0000 0100
					3'b011: out = 8'h08; //8'h08 4th 0000 1000
					3'b100: out = 8'h10; //8'h10 5th 0001 0000
					3'b101: out = 8'h20; //8'h20 6th 0010 0000
					3'b110: out = 8'h40; //8'h40 7th 0100 0000
					3'b111: out = 8'h80; //8'h80 8th 1000 0000
					
					default: out = 8'hxx; //for debug purpose
				endcase 
				
			end
				
			
			else
			begin
				out = 8'h00;
			end
			
		end
		
endmodule 
