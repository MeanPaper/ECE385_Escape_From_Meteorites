module lookahead_adder (
	input  [15:0] A, B,
	input         cin,
	output [15:0] S,
	output logic  cout //there is no keyword logic initially
);
    /* TODO
     *
     * Insert code here to implement a CLA adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
	
	
	
	logic c4, c8, c12, c16;
	logic P0, P4, P8, P12, G0, G4, G8, G12;

	//assign cin = 0;
	four_lookahead_adder		CLA0(.A(A[3:0]), .B(B[3:0]), .c_in(cin), .S(S[3:0]), .P(P0), .G(G0));
	four_lookahead_adder		CLA1(.A(A[7:4]), .B(B[7:4]), .c_in(c4), .S(S[7:4]), .P(P4), .G(G4));
	four_lookahead_adder		CLA2(.A(A[11:8]), .B(B[11:8]), .c_in(c8), .S(S[11:8]), .P(P8), .G(G8));
	four_lookahead_adder		CLA3(.A(A[15:12]), .B(B[15:12]), .c_in(c12), .S(S[15:12]), .P(P12), .G(G12));	
	

	
	always_comb
		begin
			c4 = G0 |(cin & P0);
			c8 = G4 |(G0 & P4)|(cin & P0 & P4);
			c12 = G8 | (G4 & P8) | (G0 & P8 & P4) | (cin & P8 & P4 & P0);
			cout = G12 | (G8 & P12) | (G4 & P12 & P8) | (G0 & P12 & P8 & P4) | (cin & P12 & P8 & P4 & P0);
			
		end
	


endmodule

//1 bit carry lookahead 
module unit_lookahead_adder(
	input a,b,
	input c,
	output logic s, p, g
);

	//look ahead adder unit
	always_comb
		begin
			s = a ^ b ^ c;
			p = a ^ b;
			g = a & b;
		end

endmodule


//4 bit carry lookahead
module four_lookahead_adder(
	input [3:0] A,B,
	input c_in,
	output [3:0]S,
	output logic P,G
);

	logic c1, c2, c3;
	logic p0, p1, p2, p3, g0, g1, g2, g3;
	
	
	//0th bit adder
	unit_lookahead_adder LA0(.a(A[0]),.b(B[0]), .c(c_in), .s(S[0]), .p(p0), .g(g0));
	//1st bit adder
	unit_lookahead_adder LA1(.a(A[1]),.b(B[1]), .c(c1), .s(S[1]), .p(p1), .g(g1));
	//2nd bit adder
	unit_lookahead_adder LA2(.a(A[2]),.b(B[2]), .c(c2), .s(S[2]), .p(p2), .g(g2));
	//3rd bit adder
	unit_lookahead_adder LA3(.a(A[3]),.b(B[3]), .c(c3), .s(S[3]), .p(p3), .g(g3));
	
	
	always_comb
		begin
			//get carry for 1 bit adder
			c1 = (c_in & p0) | g0;
	
			//get carry for 2 bit adder
			c2 = (c_in & p0 & p1) | (g0 & p1) | g1;
	
			//get carry for 3 bit adder
			c3 = (c_in & p0 & p1 & p2) | (g0 & p1 & p2) | (g1 & p2) | g2; 
	
	
			//get P and G for the 4 bit lookahead adder 
			P = p0 & p1 & p2 & p3;
			G = g3 | (g2 & p3) | (g1 & p3 & p2) |(g0 & p3 & p2 & p1);
			
		end
	

endmodule 
