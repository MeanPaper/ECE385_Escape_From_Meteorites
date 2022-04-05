module select_adder (
	input  [15:0] A, B,
	input         cin,
	output [15:0] S,
	output logic cout
);

    /* TODO
     *
     * Insert code here to implement a CSA adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
	  
	  logic c0, c1, c2;
	  four_bit_adder 			FA(.A(A[3:0]), .B(B[3:0]), .C_in(cin), .S(S[3:0]), .C_out(c0));
	  //second unit
	  four_carry_select		CSA0(.A(A[7:4]), .B(B[7:4]), .c_in(c0), .sum(S[7:4]), .c_out(c1));
	  //third unit
	  four_carry_select		CSA1(.A(A[11:8]), .B(B[11:8]), .c_in(c1), .sum(S[11:8]), .c_out(c2));
	  //fourth unit
	  four_carry_select		CSA2(.A(A[15:12]), .B(B[15:12]), .c_in(c2), .sum(S[15:12]), .c_out(cout));
	  

endmodule


module four_carry_select(
	input 	[3:0] A, B,
	input 	c_in,
	output 	[3:0] sum,
	output 	logic c_out
	
	);
	
	logic [3:0] temp_sum1, temp_sum2;
	logic c1, c2;
	
	//the two 4-bit carry ripple adder of the unit
	four_bit_adder		RA1(.A(A[3:0]), .B(B[3:0]), .C_in(1'b0), .S(temp_sum1[3:0]), .C_out(c1));
	four_bit_adder		RA2(.A(A[3:0]), .B(B[3:0]), .C_in(1'b1), .S(temp_sum2[3:0]), .C_out(c2));
	
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
