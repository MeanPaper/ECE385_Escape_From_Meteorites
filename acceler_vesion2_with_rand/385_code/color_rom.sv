module color_rom ( input [3:0]	addr,  //{character, row} = {frist 7 bit, last 4 bit}
						output [23:0]	data
					 );

	parameter ADDR_WIDTH = 13;
   parameter DATA_WIDTH =  24;
	logic [ADDR_WIDTH-1:0] addr_reg;
				
	// ROM definition				
	parameter [0:ADDR_WIDTH-1] [DATA_WIDTH-1:0] ROM = {
			24'hFF00FF,
			24'h000000, 
			24'hFFFFFF,
			24'h313129, 
			24'h5A5A52,
			24'h848C73,
			24'h840000, 
			24'hFF0000,
			24'h848400, 
			24'hFFFF00,
			24'hA5AD94, 
			24'h0084FF, 
			24'h0042BD

        };

	assign data = ROM[addr];

endmodule  