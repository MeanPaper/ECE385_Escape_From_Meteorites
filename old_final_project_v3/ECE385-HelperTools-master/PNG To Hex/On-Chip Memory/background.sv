//this is the background rom
module  backgroundROM
(
		input [4:0] data_In,
		input [18:0] write_address, 
		input [18:0]read_address,
		input we, 
		input Clk,

		output logic [3:0] data_Out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] memory [76800];

initial
begin
	 $readmemh("sprite_bytes/background.txt", memory);
end


always_ff @ (posedge Clk) begin
	if (we)
		memory[write_address] <= data_In;
	data_Out<= memory[read_address];
end

endmodule
