module branch(
       input logic LD_CC, LD_BEN, Clk,
		 input logic [15:0] BUS,
       input logic [2:0] IR_11to9,
		 output logic BEN
	);
		
    logic [2:0] nzp_in, nzp_out, ben_out;
    logic ben_data;

    always_comb 
        begin
            if (BUS == 16'b0)
                nzp_in = 3'b010;
            else if (BUS[15] == 1'b0)
                nzp_in = 3'b001;
            else 
                nzp_in = 3'b100;
        end

    reg_3 nzp(
        .D(nzp_in),
        .Load(LD_CC),
        .Reset(1'b0),
        .Clk(Clk),
        .Data_Out(nzp_out)
    );
        assign ben_out = nzp_out & IR_11to9;
        always_comb 
            begin
                if (ben_out == 3'b0)
                    ben_data = 1'b0;
                else
                    ben_data = 1'b1;
            end

    reg_1 ben_reg(
        .D(ben_data),
        .Clk(Clk),
		  .Reset(1'b0),
        .Load(LD_BEN),
        .Data_Out(BEN)
    );

endmodule
