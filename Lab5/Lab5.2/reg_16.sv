
//16-bit parallel load register

module reg_16 (input  logic Clk, Reset, Load,
              input  logic [15:0]  D,
              output logic [15:0]  Data_Out);

    always_ff @ (posedge Clk)
    begin
	 	 if (Reset) //notice, this is a sycnrhonous reset, which is recommended on the FPGA
			  Data_Out <= 16'h0;
		 else if (Load)
			  Data_Out <= D; //parallel load the data

    end
	
endmodule


//specificaly for ben signal, maybe NZP signals
module reg_1 (input logic Clk, Reset, Load,
				 input logic D,
				 output logic Data_Out);
	 
	 always_ff @ (posedge Clk)
    begin
	 	 if (Reset) //notice, this is a sycnrhonous reset, which is recommended on the FPGA
			  Data_Out <= 1'b0;
		 else if (Load)
			  Data_Out <= D; //parallel load the data

    end

endmodule


//this is for nzp
module reg_3(input logic Clk, Reset, Load,
				 input logic [2:0]D,
				 output logic [2:0]Data_Out);
	 
	 always_ff @ (posedge Clk)
    begin
	 	 if (Reset) //notice, this is a sycnrhonous reset, which is recommended on the FPGA
			  Data_Out <= 3'b000;
		 else if (Load)
			  Data_Out <= D; //parallel load the data

    end

endmodule
