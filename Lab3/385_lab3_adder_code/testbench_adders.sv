module testbench_adders();

//give a time step
timeunit 10ns;

timeprecision 1ns;

//all the input and output for the adder
logic [15:0] A,B;
logic cin;
logic [15:0] S;
logic cout;


logic [15:0] Sum_ans;
logic cout_ans;

//ripple_adder	CRA0d(.A(A[15:0]), .B(B[15:0]), .cin(cin), .S(S[15:0]), .cout(cout));
select_adder	CSA0(.A(A[15:0]), .B(B[15:0]), .cin(cin), .S(S[15:0]), .cout(cout));	
//lookahead_adder CLA(.A(A[15:0]), .B(B[15:0]), .cin(cin), .S(S[15:0]), .cout(cout));


initial begin: ADDER_TEST
	A = 16'h0000;
	B = 16'h0000;
	cin = 1'b0;
	Sum_ans = A + B;
	cout_ans = 1'b0;
	
	//after 10ns
#1 A = 16'h0ECE;
	B = 16'hBAD0;
	cin = 0;
	Sum_ans = A + B;
	cout_ans = 1'b0;
	
#8 	 
	//check the sum
if(S != Sum_ans)
	$display("Sum1 fail.");
else
	$display("Sum1 pass!");

	//check the carry out
if(cout_ans != cout)
	$display("cout1 fail.");
else
	$display("cout1 pass!");
	


	
#2	A=16'hECEB;
	B=16'h2022;
	Sum_ans = 16'hECEB + 16'h2022;
	cout_ans = 1'b1;
	
#2	
//check the sum
if(S != Sum_ans)
	$display("Sum2 fail.");
else
	$display("Sum2 pass!");

//check the carry out
if(cout_ans != cout)
	$display("cout2 fail.");
else
	$display("cout2 pass!");
	
	
end


endmodule
