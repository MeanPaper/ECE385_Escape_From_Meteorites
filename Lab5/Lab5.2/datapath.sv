module datapath( 	input logic Clk, Reset,
						input logic LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC, LD_LED,
						input logic GatePC, GateMDR, GateALU, GateMARMUX,
						input logic [1:0] PCMUX, ADDR2MUX, ALUK,
						input logic DRMUX, SR1MUX, SR2MUX, ADDR1MUX, MARMUX, //sr2 mux is the one before ALU
						input logic MIO_EN,
						input logic [15:0]MDR_In,
						output logic BEN,
						output logic [9:0]LED,
						output logic [15:0]MAR, MDR, IR, PC	
					);

					
					
					//dl35 create the following block
//=================================================================
logic [15:0] PC_MUX_OUT; //output of PC mux

logic [15:0] PC_MUX_IN;
logic [15:0] PC_GATE_IN;	//the PC output to the gate	
assign PC_MUX_IN = PC_GATE_IN + 1; //self increment of PC
logic [15:0] MEM_MUX_OUT;	//the mux output before the MDR
logic [15:0] MDR_GATE_IN;	//MDR output before gate

logic [3:0] GATE_S;	
assign GATE_S = {GatePC, GateMDR, GateALU, GateMARMUX};

logic [15:0] BUS;
assign PC = PC_GATE_IN;

//========= PART 2 ============================
//for register files outputs
logic [15:0]SR1_Data;
logic [15:0]SR2_Data;

//for the address MUXs
logic [15:0]addr1mux_out;
logic [15:0]addr2mux_out;
logic [15:0]addr_sum;
//the adder after the addr MUXs
assign addr_sum = addr1mux_out + addr2mux_out;

//SR2 mux output
logic [15:0]sr2mux_out;

//ALU output
logic [15:0]ALU_out;
//==============================================


	reg_16	MAR_reg(	.Clk, 
							.Reset, 
							.Load(LD_MAR),
							.D(BUS),
							.Data_Out(MAR));

	reg_16	MDR_reg(	.Clk, 
							.Reset, 
							.Load(LD_MDR),
							.D(MEM_MUX_OUT),
							.Data_Out(MDR));
	
	reg_16	PC_reg(	.Clk, 
							.Reset, 
							.Load(LD_PC),
							.D(PC_MUX_OUT),  //output from the PC mux
							.Data_Out(PC_GATE_IN)); //output the data of pc reg and connects to gates
	
	reg_16 	IR_reg(	.Clk, 
							.Reset, 
							.Load(LD_IR),
							.D(BUS),
							.Data_Out(IR));
							
	mux2to1	MDR_mux(	.A(BUS), 	//select 0
							.B(MDR_In),			//select 1
							.select(MIO_EN),
							.out(MEM_MUX_OUT));
	
	//the mux before the PC_reg
	mux4to1	PC_mux(.IN_0(PC_MUX_IN),
						 .IN_1(BUS), //change from 0s to don't care
						 .IN_2(addr_sum),
						 .IN_3(16'hxxxx),
						 .select(PCMUX),
						 .out(PC_MUX_OUT));
						 
						 
	gateMux 	gates(.GATE_0(PC_GATE_IN), //gatePC
						.GATE_1(MDR),	 		//gateMDR
						.GATE_2(ALU_out), 	//gateALU
						.GATE_3(addr_sum), 	//gateMarMUX
						.select(GATE_S),		//change from 0s to don't care
						.out(BUS));
//====================================================================	

	
//=================PART 2 START HERE==================================

	reg_file	register_file(
					.Clk, .LD_REG, .Reset,
					.DR(DRMUX),	//DRMUX is signal for selecting the destination reg
					.IR_11to9(IR[11:9]),
					.IR_8to6(IR[8:6]),
					.SR1(SR1MUX),
					.SR2(IR[2:0]), //this come from IR[2:0]
					.Data_in(BUS),
					.SR1_out(SR1_Data),
					.SR2_out(SR2_Data)
				);
				
	//this is the ADDR2MUX on lc3 datapath	
	//{n{IR[x]}} n-bit extend using IR[x]
	mux4to1	addr2mux(
					.IN_0(16'h0000), 
					.IN_1( { {10{IR[5]}},IR[5:0]} ), 
					.IN_2( { {7{IR[8]}},IR[8:0]} ), 
					.IN_3( { {5{IR[10]}},IR[10:0]} ),
					.select(ADDR2MUX),
					.out(addr2mux_out)
				);
	
	//this is the ADDR1MUX on lc3 datapath
	//select = 0, out = A = PC, select = 1, out = B = SR1_data
	mux2to1	addr1mux( .A(PC), .B(SR1_Data), .select(ADDR1MUX), .out(addr1mux_out));
	
	//SR2 mux on the datapath
	//the one above the alu on the datapath
	mux2to1	sr2mux(.A(SR2_Data), .B({ {11{IR[5]}},IR[4:0]}), .select(IR[5]) , .out(sr2mux_out));
	
	//ALU of the slc3 
	ALU	alu_unit(.A(SR1_Data), .B(sr2mux_out), .ALUK, .out(ALU_out));


//====================================================================	

endmodule 