//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Lab 6 Given Code - Incomplete ISDU
// Module Name:    ISDU - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 02-13-2017
//    Spring 2017 Distribution
//------------------------------------------------------------------------------


module ISDU (   input logic         Clk, 
									Reset,
									Run,
									Continue,
									
				input logic[3:0]    Opcode, 
				input logic         IR_5,
				input logic         IR_11,
				input logic         BEN,
				  
				output logic        LD_MAR,
									LD_MDR,
									LD_IR,
									LD_BEN,
									LD_CC,
									LD_REG,
									LD_PC,
									LD_LED, // for PAUSE instruction
									
				output logic        GatePC,
									GateMDR,
									GateALU,
									GateMARMUX,
									
				output logic [1:0]  PCMUX,
				output logic        DRMUX,
									SR1MUX,
									SR2MUX,
									ADDR1MUX,
				output logic [1:0]  ADDR2MUX,
									ALUK,
				  
				output logic        Mem_OE,
									Mem_WE
				);

	enum logic [4:0] {  Halted, 
						PauseIR1, 
						PauseIR2,
						S_18, 
						S_33_1, 
						S_33_2,
						S_33_3,
						S_35, 
						S_32, 
						
						S_5,	//and
						S_9,	//not
							
						S_6,	//ldr
						S_25_1, //ldr wait for mem 
						S_25_2,
						S_25_3,
						S_27,
							
						//str state 
						S_7,
						S_23,
						S_16_1, //str wait for mem
						S_16_2,
						S_16_3,
							
						//jsr
						S_4,
						S_21, 
							
						//jmp
						S_12,
							
						//BR
						S_0,
						S_22,
							
							
						S_01}   State, Next_state;   // Internal state logic
		
	always_ff @ (posedge Clk)
	begin
		if (Reset) 
			State <= Halted;
		else 
			State <= Next_state;
	end
   
	always_comb
	begin 
		// Default next state is staying at current state
		Next_state = State;
		
		// Default controls signal values
		LD_MAR = 1'b0;
		LD_MDR = 1'b0;
		LD_IR = 1'b0;
		LD_BEN = 1'b0;
		LD_CC = 1'b0;
		LD_REG = 1'b0;
		LD_PC = 1'b0;
		LD_LED = 1'b0;
		 
		GatePC = 1'b0;
		GateMDR = 1'b0;
		GateALU = 1'b0;
		GateMARMUX = 1'b0;
		 
		ALUK = 2'b00;
		 
		PCMUX = 2'b00;
		DRMUX = 1'b0;
		SR1MUX = 1'b0;
		SR2MUX = 1'b0;
		ADDR1MUX = 1'b0;
		ADDR2MUX = 2'b00;
		 
		Mem_OE = 1'b0;
		Mem_WE = 1'b0;
	
		// Assign next state
		unique case (State)
			Halted : 
				if (Run) 
					Next_state = S_18;                      
			S_18 : 
				Next_state = S_33_1;
			// Any states involving SRAM require more than one clock cycles.
			// The exact number will be discussed in lecture.
			S_33_1 : 
				Next_state = S_33_3; 
			
			S_33_3:
				Next_state = S_33_2; //add one more state
			
			S_33_2 : 
				Next_state = S_35;
			S_35 : 
				Next_state = S_32;
				
			// PauseIR1 and PauseIR2 are only for Week 1 such that TAs can see 
			// the values in IR.
			
			PauseIR1 : 
				if (~Continue) 
					Next_state = PauseIR1;
				else 
					Next_state = PauseIR2;
			PauseIR2 : 
				if (Continue) 
					Next_state = PauseIR2;
				else 
					Next_state = S_18;
					
					
			S_32 : 
				case (Opcode)
					4'b0001 : Next_state = S_01;//add

					// You need to finish the rest of opcodes.....
					
					//here are the opcode jump
					4'b0101: Next_state = S_5;		//And
					4'b1001:	Next_state = S_9;		//Not
					4'b0110:	Next_state = S_6;		//Ldr
					4'b0111:	Next_state = S_7;		//Str
					4'b0100:	Next_state = S_4;		//Jsr
					4'b1100:	Next_state = S_12;	//jmp
					4'b0000:	Next_state = S_0;		//branch
					
					4'b1101:	Next_state = PauseIR1;		//pause
					

					default : 
						Next_state = S_18;
				endcase
				
			S_01 : 
				Next_state = S_18;

			// You need to finish the rest of states.....
			
			
			S_5 :
				Next_state = S_18;
			
			S_9 : 
				Next_state = S_18;
			
			
			S_6 :
				Next_state = S_25_1;
			S_25_1 :
				Next_state = S_25_2;
			S_25_2 :
				Next_state = S_25_3;
			S_25_3 :
				Next_state = S_27;
			S_27:
				Next_state = S_18;
				
				
			S_7:
				Next_state = S_23;
			S_23:
				Next_state = S_16_1;
			S_16_1:
				Next_state = S_16_2;
			S_16_2:
				Next_state = S_16_3;
			S_16_3:
				Next_state = S_18;
				
				
			S_4:
				Next_state = S_21;
			S_21:
				Next_state = S_18;
				
				
			S_12:
				Next_state = S_18;
			
			//BEN
			S_0:
				begin
					if(BEN)
						Next_state = S_22;
					else
						Next_state = S_18;
				end
				
			S_22: Next_state = S_18;
			

			default: ;

		endcase
		
		// Assign control signals based on current state
		case (State)
			Halted: ;
			S_18 : 
				begin 
					GatePC = 1'b1;
					LD_MAR = 1'b1;
					PCMUX = 2'b00;
					LD_PC = 1'b1;
				end
				
				
			S_33_1, //additional state for delay
			S_33_3: 
				Mem_OE = 1'b1;
				
				
			S_33_2 : 
				begin 
					Mem_OE = 1'b1;
					LD_MDR = 1'b1;
				end
				
			S_35 : 
				begin 
					GateMDR = 1'b1;
					LD_IR = 1'b1;
				end
					
			PauseIR1: 
				LD_LED = 1'b1;
			PauseIR2: ;
			
			S_32 : 
				LD_BEN = 1'b1;
			
			S_01 : //add 
				begin 
					SR2MUX = IR_5; //determine imm5 or source register
					ALUK = 2'b00; //add mode
					GateALU = 1'b1; //alu gate on
					LD_REG = 1'b1; //load
					
					//find destination reg IR[11:9]
					DRMUX = 1'b0; //by default
					
					//set cc
					LD_CC = 1'b1;
					//find_source reg
					SR1MUX = 1'b1; //IR[8:6]
					
					// incomplete...
				end
				
			S_5: //And
				begin
					DRMUX = 1'b0;//by default DRmux pick IR[11:9]
					LD_REG = 1'b1; //load reg
					ALUK = 2'b01;  //and mode
					LD_CC = 1'b1;	//set cc
					SR1MUX = 1'b1; //IR[8:6]
					SR2MUX = IR_5; //imm5 or source
					GateALU = 1'b1; //alu gate on
				end

				
			S_9:
				begin
					DRMUX = 1'b0;//by default DRmux pick IR[11:9]
					LD_REG = 1'b1; //load reg
					ALUK = 2'b10;  //not mode
					LD_CC = 1'b1;  //set cc
					SR1MUX = 1'b1;	//IR[8:6]
					SR2MUX = IR_5; //technically you can set it to 1
					GateALU = 1'b1;
				end 
				
				
			S_6: //MAR <- B + off6
				begin
					LD_MAR = 1'b1; //load MAR
					SR1MUX = 1'b1; //IR[8:6]
					GateMARMUX = 1'b1; //open marmux gate
					ADDR2MUX = 2'b01; //sext6
					ADDR1MUX = 1'b1; //use sr
				end 
			
			S_25_1,
			S_25_2: //25: MDR <- M[MAR] 
				Mem_OE = 1'b1;
			
			S_25_3:
			begin
				Mem_OE = 1'b1;
				LD_MDR = 1'b1;	
			end
			
			S_27:	//27: DR<-MDR and set CC
				begin
					LD_REG = 1'b1;
					GateMDR = 1'b1;
					LD_CC = 1'b1;
				end
				
			//str
			S_7: //MAR <- B + off6
				begin
					SR1MUX = 1'b1;
					LD_MAR = 1'b1;
					GateMARMUX = 1'b1;
					ADDR2MUX = 2'b01;
					ADDR1MUX = 1'b1;
				end
				
			S_23: //MDR <- SR
				begin
					LD_MDR = 1'b1;
					ALUK = 2'b11;
					SR1MUX = 1'b0; //by default SR1MUX is on IR[11:9]
					GateALU = 1'b1;
				end
			
			S_16_1, //wait signal
			S_16_2: 
				Mem_WE = 1'b1;
			
			S_16_3: //M[MAR]<- MDR
				Mem_WE = 1'b1;
			
			//JSR
			S_4:
			begin
				LD_REG = 1'b1;
				GatePC = 1'b1;
				DRMUX = 1'b1;
			end
			
			S_21:
			begin
				LD_PC = 1'b1;
				PCMUX = 2'b10;
				ADDR2MUX = 2'b11;
				ADDR1MUX = 1'b0; //by default it is 0
 			end
			
			//JMP
			S_12:
			begin
				LD_PC = 1'b1;
				SR1MUX = 1'b1;
				PCMUX = 2'b10;
				ADDR1MUX = 1'b1;
				ADDR2MUX = 2'b00;
			end
			
			//BEN state
			S_0: ;//no control signal
			
			S_22:
			begin
				ADDR2MUX = 2'b10;
				ADDR1MUX = 1'b0; //it is 0 by default
				LD_PC = 1'b1;
				PCMUX = 2'b10;
			end
			
				
			
			// You need to finish the rest of states.....
			default : ;
		endcase
	end 

	
endmodule
