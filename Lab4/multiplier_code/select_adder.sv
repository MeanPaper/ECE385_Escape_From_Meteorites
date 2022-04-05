
//8-bit select adder

module select_adder (
	input  [7:0] A, B,
	input         cin,
	input 		  M,
	//the most significan is sign extension
	output [8:0] S,
	output logic cout

);

    /* TODO
     *
     * Insert code here to implement a CSA adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
	  
	  logic c0;
	  logic [7:0] add_val;
	  
	  
	  //sign extension
	  assign S[8] = S[7];
	  
	  //decide whether to add 0 or add one
	  always_comb
			begin
				case (M):
					1'b0 : add_val = 8'h00;
					1'b1 : add_val = B;
					default: add_val = 8'h00;
				endcase
			end
	  
	  //first 4 bits
	  four_bit_add_sub 			FA(.A(A[3:0]), .B(add_val[3:0]), .C_in(cin), .S(S[3:0]), .C_out(c0));
	  //last 4 bits
	  four_carry_select		CSA0(.A(A[7:4]), .B(add_val[7:4]), .c_in(c0), .sum(S[7:4]), .c_out(cout));
	  

endmodule

//may be should include a select add for doing shit

module four_carry_select(
	input 	[3:0] A, B,
	input 	c_in,
	output 	[3:0] sum,
	output 	logic c_out
	
	);
	
	logic [3:0] temp_sum1, temp_sum2;
	logic c1, c2;
	
	//the two 4-bit carry ripple adder of the unit
	four_bit_add_sub		RA1(.A(A[3:0]), .B(B[3:0]), .C_in(1'b0), .S(temp_sum1[3:0]), .C_out(c1));
	four_bit_add_sub		RA2(.A(A[3:0]), .B(B[3:0]), .C_in(1'b1), .S(temp_sum2[3:0]), .C_out(c2));
	
	//2 to 1 mux for the output
	mux2to1		mux_one(.in_A(temp_sum1[3:0]), .in_B(temp_sum2[3:0]), .select(c_in), .mux_out(sum[3:0]));
	
	
	always_comb
		begin
			c_out = (c_in & c2) | c1;
		end


endmodule


//sum of the full adder with 0 cin, going to in_A
//sum of the full adder with 1 cin, going to in_B
module mux2to1(
	input 	[3:0] in_A,
	input		[3:0]	in_B,
	input		 select,
	output	logic [3:0]	mux_out

);

	always_comb
		begin 
		
			case(select)
				//0 output input A
				//1 output input B
				1'b0 : mux_out[3:0] = in_A[3:0];
				1'b1 : mux_out[3:0] = in_B[3:0];
				
				//default output is input A
				default : mux_out[3:00] = in_A[3:0];
			endcase
		
		end

endmodule
