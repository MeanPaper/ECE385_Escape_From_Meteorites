

//the 16-bit ripple adder may not be use in this project

module ripple_adder
(
	input  [7:0] a, b,
	input         cin,
	input 			M,
	output [8:0] s,
	output logic cout
);

    /* todo
     *
     * insert code here to implement a ripple adder.
     * your code should be completly combinational (don't use always_ff or always_latch).
     * feel free to create sub-modules or other files. */
	  
	  logic co1,c2;
	  logic [7:0] add_val;
	 
	  
	  always_comb
			begin
				//conditional addition
				case(M)
					1'b0 : add_val = 8'b0; 
					//conditional invert, for subtraction or do nothing
					1'b1 : add_val = (b ^ {8{cin}});
					default: add_val = 8'b0;
				endcase
			end 
	  
	  
	  
	  //4*2 cra unit
	  four_bit_add_sub	cra0(.A(a[3:0]), .B(add_val[3:0]), .C_in(cin), .S(s[3:0]), .C_out(co1));
	  four_bit_add_sub	cra1(.A(a[7:4]), .B(add_val[7:4]), .C_in(co1), .S(s[7:4]), .C_out(c2));
	  //calculate the sign bit
	  unit_full_adder  cra2(.a(a[7]), .b(add_val[7]), .c(c2), .s(s[8]), .c_out(cout));



endmodule


//create an full adder
module unit_full_adder( //this is a unit subtractor
	input 		a,b,
	input			c,
	output 		logic s,
	output 		logic c_out
);

	
	always_comb
	begin
				
			//logic for calculating the sum
			s = a ^ b ^ c;
			
			//the carry out logic
			c_out = (a & b)|(b & c)|(a & c);
		
	end
	


endmodule


//4 bit carry ripple adder
module four_bit_add_sub(
	input 		[3:0]A,
	input			[3:0]B,
	input			C_in,
	output 		[3:0]S,
	output		logic C_out
);

	logic c1, c2, c3;
	
	//chain 4 1-bit full adder together
	unit_full_adder		AS0(.a(A[0]), .b(B[0]), .c(C_in), .s(S[0]), .c_out(c1));
	unit_full_adder		AS1(.a(A[1]), .b(B[1]), .c(c1), .s(S[1]), .c_out(c2));
	unit_full_adder		AS2(.a(A[2]), .b(B[2]), .c(c2), .s(S[2]), .c_out(c3));
	unit_full_adder		AS3(.a(A[3]), .b(B[3]), .c(c3), .s(S[3]), .c_out(C_out));

	

endmodule



