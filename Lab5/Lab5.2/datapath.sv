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

					
					

logic [15:0] PC_MUX_OUT; //output of PC mux

logic [15:0] PC_MUX_IN;
logic [15:0] PC_GATE_IN;	//the PC output to the gate	
logic [15:0] MEM_MUX_OUT;	//the mux output before the MDR
logic [15:0] MDR_GATE_IN;	//MDR output before gate

logic [3:0] GATE_S;	

logic [15:0] BUS;
assign PC = PC_GATE_IN;

//PART 2 added signal
//for register files outputs
logic [15:0]SR1_Data;
logic [15:0]SR2_Data;

//for the address MUXs
logic [15:0]addr1mux_out;
logic [15:0]addr2mux_out;
logic [15:0]addr_sum;


//SR2 mux output
logic [15:0]sr2mux_out;

//ALU output
logic [15:0]ALU_out;

//Branch enable signal to the ben_reg
logic BR_data;

//nzp signals
//have to figure out the value using some logic
//set cc is related to the last assess destination reg
logic [2:0]nzp_in, nzp_out;


assign PC_MUX_IN = PC_GATE_IN + 16'h0001; //self increment of PC
assign GATE_S = {GatePC, GateMDR, GateALU, GateMARMUX}; //assign the gate signals
assign addr_sum = addr1mux_out + addr2mux_out;		
//please beware that this is verify in BR (opcode: 0000)
//assign BR_data = (IR[11:9] & nzp_out != 3'b000);
//		
//	always_comb
//		begin//bus data is only valid and will be load to nzp reg in specific state
//		if(BUS == 16'h0000)
//				nzp_in = 3'b010; //zero
//		else if (BUS[15])
//				nzp_in = 3'b100; //negative
//		else 
//				nzp_in = 3'b001; //positive 
//		
//	end
	
//	//Branch required reg
//	reg_1		Ben_reg(	.Clk,
//							.Reset,
//							.Load(LD_BEN),
//							.D(BR_data),
//							.Data_Out(BEN));
//							
//							
//	reg_3		nzp_reg(	.Clk,
//							.Reset,
//							.Load(LD_CC),
//							.D(nzp_in),
//							.Data_Out(nzp_out));
//	//Branch required materil end here			
	
	branch	BR_branch(.Clk, .LD_BEN, .LD_CC, .BUS, .IR_11to9(IR[11:9]), .BEN(BEN));
							
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
						 .IN_3(),
						 .select(PCMUX),
						 .out(PC_MUX_OUT));
						 
						 
	gateMux 	gates(.GATE_0(PC_GATE_IN), //gatePC
						.GATE_1(MDR),	 		//gateMDR
						.GATE_2(ALU_out), 	//gateALU
						.GATE_3(addr_sum), 	//gateMarMUX
						.select(GATE_S),		//change from 0s to don't care
						.out(BUS));	
	
//Part 2==========================================================
	reg_file	register_file(
					.Clk, .LD_REG(LD_REG), .Reset(Reset),
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
					.IN_1( { {10{IR[5]}}, IR[5:0]} ), 
					.IN_2( { {7{IR[8]}}, IR[8:0]} ), 
					.IN_3( { {5{IR[10]}}, IR[10:0]} ),
					.select(ADDR2MUX),
					.out(addr2mux_out)
				);
	
	//this is the ADDR1MUX on lc3 datapath
	//select = 0, out = A = PC, select = 1, out = B = SR1_data
	mux2to1	addr1mux( .A(PC_GATE_IN), .B(SR1_Data), .select(ADDR1MUX), .out(addr1mux_out));
	
	//SR2 mux on the datapath
	//the one above the alu on the datapath
	mux2to1	sr2mux(.A(SR2_Data), .B({ {11{IR[4]}},IR[4:0]}), .select(SR2MUX) , .out(sr2mux_out));
	
	//ALU of the slc3 
	ALU	alu_unit(.A(SR1_Data), .B(sr2mux_out), .ALUK(ALUK), .out(ALU_out));
	
	
	always_ff @(posedge Clk) 
	begin
		if(LD_LED)
			LED <= IR[9:0];
		else
			LED <= 10'b0;
	end

endmodule 