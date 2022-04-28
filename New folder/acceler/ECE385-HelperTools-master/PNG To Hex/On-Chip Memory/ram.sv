/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  spriteROM
(
		input [4:0] data_In,
		input [18:0] write_address, 
		input [18:0]read_address,
		input we, 
		input Clk,

		output logic [3:0] data_Out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [0:3464];

initial
begin
	//$readmemh("sprite_bytes/spaceship_motion.txt", mem);
	 $readmemh("sprite_bytes/spaceship.txt", mem, 19'd0, 19'd1154);
	 $readmemh("sprite_bytes/spaceshipLeft.txt", mem, 19'd1155, 19'd2309); //left motion start at 1155
	 $readmemh("sprite_bytes/spaceshipRight.txt", mem, 19'd2310, 19'd3464); //right motion start at 2112
end


always_ff @ (posedge Clk) begin
	if (we)
		mem[write_address] <= data_In;
	data_Out<= mem[read_address];
end

endmodule


module  asteroid_ROM
(
		input [4:0] data_In,
		input [18:0] write_address, 
		input [18:0]read_address,
		input we, 
		input Clk,

		output logic [3:0] data_Out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [900];

initial
begin
	 $readmemh("sprite_bytes/asteroid.txt", mem);
end


always_ff @ (posedge Clk) begin
	if (we)
		mem[write_address] <= data_In;
	data_Out<= mem[read_address];
end

endmodule


module  text_Rom
(
		input [4:0] data_In,
		input [18:0] write_address, 
		input [18:0]read_address,
		input we, 
		input Clk,

		output logic [3:0] data_Out
);

// mem has width of 3 bits and a total of 400 addresses
logic [3:0] mem [9438];

initial
begin
	 $readmemh("sprite_bytes/textBegin.txt", mem);
end


always_ff @ (posedge Clk) begin
	if (we)
		mem[write_address] <= data_In;
	data_Out<= mem[read_address];
end

endmodule
