module reg_file(input logic Clk, LD_REG, Reset,
					 
					 input logic DR,
					 
					 //the ir data are used in DR mux and SR1mux
					 input logic [2:0]IR_11to9,
					 input logic [2:0]IR_8to6,
					 
					 input logic SR1,
					 input logic [2:0] SR2, //this come from IR[2:0]
					 
					 input logic [15:0] Data_in,
					 
					 output logic[15:0] SR1_out,
					 output logic[15:0] SR2_out
					 
					 );
		
		
		logic [7:0] reg_load; //store info about which reg to be load
		logic [2:0] destinate;//the number of destination register, 3-bit total: 8 registers
		logic [15:0] reg_out[8];
		logic [2:0]	SR_One;
		
		
		//please refer to the control signals in ece120 lc3 handout
		//DR = 1, load to R7, DR = 0, load to regular register IR[11:9]
		mux3bit			DRmux( .in0(IR_11to9), .in1(3'b111), .select(DR), .out(destinate) );
		//output of the register file
		//SR1mux on the datapath SR1 = 1: IR[8:6], SR1 = 0: IR[11:9]
		mux3bit			SR1mux( .in0(IR_11to9), .in1(IR_8to6), .select(SR1), .out(SR_One));
		
		//decode based on the info of destinate
		decoder3bit		decode( .in(destinate), .enable(LD_REG), .out(reg_load) );

		//registers in the register file
		reg_16	reg0(.Clk, .Reset, .Load(reg_load[0]), .D(Data_in), .Data_Out(reg_out[0][15:0]));

		reg_16 	reg1(.Clk, .Reset, .Load(reg_load[1]), .D(Data_in), .Data_Out(reg_out[1][15:0]));

		reg_16	reg2(.Clk, .Reset, .Load(reg_load[2]), .D(Data_in), .Data_Out(reg_out[2][15:0]));

		reg_16 	reg3(.Clk, .Reset, .Load(reg_load[3]), .D(Data_in), .Data_Out(reg_out[3][15:0]));

		reg_16	reg4(.Clk, .Reset, .Load(reg_load[4]), .D(Data_in), .Data_Out(reg_out[4][15:0]));

		reg_16 	reg5(.Clk, .Reset, .Load(reg_load[5]), .D(Data_in), .Data_Out(reg_out[5][15:0]));

		reg_16	reg6(.Clk, .Reset, .Load(reg_load[6]), .D(Data_in), .Data_Out(reg_out[6][15:0]));

		reg_16 	reg7(.Clk, .Reset, .Load(reg_load[7]), .D(Data_in), .Data_Out(reg_out[7][15:0]));
		
		
		
		

		
	
		//output of source registers
		mux8to1			SR1_data(.reg_out, .select(SR_One), .out(SR1_out));
		mux8to1			SR2_data(.reg_out, .select(SR2), .out(SR2_out));


endmodule


//the module below are designed specifically for register files 

//for the output of the register file
//8 to 1 mux, 16-bit stream
module mux8to1(input logic [15:0] reg_out[8], //an array of size 8 with 16-bit elements
					input logic [2:0]	select,
					output logic [15:0] out
					);
					
		always_comb
		begin
			case(select)
				3'b000: out = reg_out[0]; //port 0: first input
				3'b001: out = reg_out[1];
				3'b010: out = reg_out[2];
				3'b011: out = reg_out[3];				
				3'b100: out = reg_out[4];
				3'b101: out = reg_out[5];
				3'b110: out = reg_out[6];
				3'b111: out = reg_out[7]; //port 7: 8th input
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
					3'b000: out = 8'b00000001; //8'h01 1st 0000 0001
					3'b001: out = 8'b00000010; //8'h02 2nd 0000 0010
					3'b010: out = 8'b00000100; //8'h04 3rd 0000 0100
					3'b011: out = 8'b00001000; //8'h08 4th 0000 1000
					3'b100: out = 8'b00010000; //8'h10 5th 0001 0000
					3'b101: out = 8'b00100000; //8'h20 6th 0010 0000
					3'b110: out = 8'b01000000; //8'h40 7th 0100 0000
					3'b111: out = 8'b10000000; //8'h80 8th 1000 0000
				endcase 
			end
				
			
			else
			begin
				out = 8'h00;
			end
			
		end
		
endmodule 


