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
		
		
		logic [15:0] reg_load; //store info about which reg to be load
		logic [2:0] destinate;//the number of destination register, 3-bit total: 8 registers
		logic [15:0] reg_out[8];
		logic [2:0]	SR_reg1;
		
		
		//please refer to the control signals in ece120 lc3 handout
		//DR = 1, load to R7, DR = 0, load to regular register IR[11:9]
		mux3bit			DRmux( .in0(IR_11to9), .in1(3'b111), .select(DR), .out(destinate) );
		
		//decode based on the info of destinate
		decoder3bit		decode( .in(destinate), .enable(LD_REG), .out(reg_load) );

		//registers in the register file
		reg_16	reg0(.Clk, .Reset, .Load(reg_load[0]), .D(Data_in), .Data_Out(reg_out[0]));

		reg_16 	reg1(.Clk, .Reset, .Load(reg_load[1]), .D(Data_in), .Data_Out(reg_out[1]));

		reg_16	reg2(.Clk, .Reset, .Load(reg_load[2]), .D(Data_in), .Data_Out(reg_out[2]));

		reg_16 	reg3(.Clk, .Reset, .Load(reg_load[3]), .D(Data_in), .Data_Out(reg_out[3]));

		reg_16	reg4(.Clk, .Reset, .Load(reg_load[4]), .D(Data_in), .Data_Out(reg_out[4]));

		reg_16 	reg5(.Clk, .Reset, .Load(reg_load[5]), .D(Data_in), .Data_Out(reg_out[5]));

		reg_16	reg6(.Clk, .Reset, .Load(reg_load[6]), .D(Data_in), .Data_Out(reg_out[6]));

		reg_16 	reg7(.Clk, .Reset, .Load(reg_load[7]), .D(Data_in), .Data_Out(reg_out[7]));
		
		
		
		
		//output of the register file
		//SR1mux on the datapath SR1 = 1: IR[8:6], SR1 = 0: IR[11:9]
		mux3bit			SR1mux( .in0(IR_11to9), .in1(IR_8to6), .select(SR1), .out(SR_reg1));
		
	
		//output of source registers
		mux8to1			SR1_data(.in(reg_out), .select(SR_reg1), .out(SR1_out));
		mux8to1			SR2_data(.in(reg_out), .select(SR2), .out(SR2_out));


endmodule
