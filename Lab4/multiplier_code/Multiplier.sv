
//Always use input/output logic types when possible, prevents issues with tools that have strict type enforcement

module Multiplier (input logic   Clk,     // Internal
                                Reset,   // Push button 0
                                ClearA_LoadB,   // Push button 1
                                Run, // Push button 3
                  
						//more data input
						input  logic [7:0]  SW,     // input data
   
                  
						output [8:0] Sum, //DEBUG
						//output logic x, //DEBUG
						//output logic m, //DEBUG
						//output logic c_in, as, ms, ss, //DEBUG

						//more LED
						//output logic [7:0]  LED,     // DEBUG
                  output logic [7:0]  Aval,    // DEBUG
												  Bval,    // DEBUG
						
                  output logic [6:0]  HEX0, //HEX drivers
										 HEX1, 
										 HEX2, 
										 HEX3);
										 //HEX4);
										 //HEX5);

	 //the reset switch and other buttons
	 logic Reset_SH, ClearA_LoadB_SH, Run_SH;
	 
	 //the sign bit
	 logic x_val,c_sub;
	 
	 
	 //clear_signal for a
	 logic reset_a;

	 
	 
	 //copy of the control signal
	 logic add_s, minus_s, shift_s, clear; 
	 
	 //the result of the adder
	 logic [8:0] sum_result;
	 
	 
	 //logic newA, newB, opA, opB, bitA, bitB, Shift_En;
	 
	 //value to hold A, B, and switch input
	 logic [7:0] A, B, SW_S;
	 
	 //chain last bit of A to most significance bit of B 
	 logic A_to_B;
	 
	 
	 //if reset is pressed or clearA_LoadB or...
	 
//	 assign c_in = c_sub; //debug
//	 assign x = x_val; 	 //debug
	 assign Sum = sum_result; //debug 
//	 assign as =add_s;	//debug 
//	 assign ms = minus_s;	//debug 
//	 assign ss = shift_s;	//debug 
	 assign m = B[0];		//debug
	 assign Aval = A;		//debug
	 assign Bval = B;		//debug
	 
	 //subtract mode
	 //try to determine what to do 
	 assign c_sub = minus_s & (B[0]);
	 
	 //a will be clear if 
	 //button is pressed / reset is switch is set / control clears it 
	 assign reset_a = ClearA_LoadB_SH | Reset | clear; //e


	 //We can use the "assign" statement to do simple combinational logic

	 //assign LED = {Execute_SH,LoadA_SH,LoadB_SH,Reset_SH}; //Concatenate is a common operation in HDL
	 
	 
	 //Instantiation of modules here
	 
	 //the control unit
	 control          control_unit (
                        .Clk(Clk),
                        .Reset(ClearA_LoadB_SH),
                        .Run(Run_SH),
                        .Shift_En(shift_s),
                        .Add(add_s),
                        .Minus(minus_s),
								.cleara(clear)
								);
								//.cleara_ldb(cleara_ldb),
								
								
								
	 //adder							
	 ripple_adder	adder1(
								.a(A),
								.b(SW_S),
								.cin(c_sub),
								.M(B[0]),
								.s(sum_result[8:0]),
								.cout()
									);
	  
	 
	 //register for sign extension
	 reg_1				X_bit(
								.Clk(Clk),
								.Reset(reset_a),
								.Load(add_s),
								.D(sum_result[8]),
								.Data_Out(x_val)
									);
	 						
	 
	 //load when add is complete
	 //shift during shift state
		
	 /***************DEBUG*****************/
	 //only do shift
	 //load happen when the button is push
	 
	 //it can pass the testbench if all the SH are replace with the normal one
	 
	 //the mistery of button ClearA_LoadB
	 //using ClearA_LoadB H will not work
	 /***************DEBUG*****************/

	 
	 //register a
	  reg_8				reg_A(
								.Clk(Clk),
								.Reset(reset_a),
								.Shift_In(x_val),
								.Load(add_s),
								.Shift_En(shift_s),
								.D(sum_result[7:0]),
								.Shift_Out(A_to_B),
								.Data_Out(A)								
									);	 
	 
	 
	 
	 //register b
	 reg_8				reg_B(
								.Clk(Clk),
								.Reset(Reset),
								.Shift_In(A_to_B),
								.Load(ClearA_LoadB_SH),
								.Shift_En(shift_s),
								.D(SW_S),
								.Shift_Out(),
								.Data_Out(B)							
									);
									

	 

		
	 						
								
		HexDriver		BHex0 (
								.In0(B[3:0]),
								.Out0(HEX0) );
								
		HexDriver		BHex1 (
								.In0(B[7:4]),
								.Out0(HEX1) );
								
		HexDriver		AHex0 (
								.In0(A[3:0]),
								.Out0(HEX2) );
								
		HexDriver		AHex1 (
								.In0(A[7:4]),
								.Out0(HEX3) );
								
										
//		HexDriver		XHex0 (
//								.In0({3'b0, x_val}),
//								.Out0(HEX4) );
//		HexDriver 		hexdr(
//								.In0({4'b0}),
//								.Out0(HEX5));
		
								
//	//no change for the hex driver
//	 HexDriver        HexAL (
//                        .In0(A[3:0]),
//                        .Out0(AhexL) );
//	 HexDriver        HexBL (
//                        .In0(B[3:0]),
//                        .Out0(BhexL) );
//								
//	 //When you extend to 8-bits, you will need more HEX drivers to view upper nibble of registers, for now set to 0
//	 HexDriver        HexAU (
//                        .In0(A[7:4]),
//                        .Out0(AhexU) );	
//	 HexDriver        HexBU (
//                       .In0(B[7:4]),
//                        .Out0(BhexU) );
								
	  //Input synchronizers required for asynchronous inputs (in this case, from the switches)
	  //These are array module instantiations
	  //Note: S stands for SYNCHRONIZED, H stands for active HIGH
	  //Note: We can invert the levels inside the port assignments
	  
	  sync button_sync[2:0] (Clk, {Reset, ~ClearA_LoadB, ~Run}, {Reset_SH, ClearA_LoadB_SH, Run_SH});
	  sync SW_sync[7:0] (Clk, SW, SW_S);

endmodule
