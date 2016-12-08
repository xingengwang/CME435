module Data_Memory_RAM (
						input clock,
						input [3:0] address,
						input [3:0] data,
						output reg [3:0] q,
						input wren
					   );

	reg [3:0] RAM_Data [0:15];
	reg [3:0] addr, dm_data;

	initial begin
		addr = 0;
		dm_data = 4'HF;
		repeat (16) begin
			RAM_Data[addr] = dm_data;
			dm_data = dm_data - 1;
			addr = addr + 1;
		end
	end

	always @ (negedge clock)
		if (wren == 1'b1)
			RAM_Data[address] <= data;
		else
			RAM_Data[address] <= RAM_Data[address];

	always @ (posedge clock)
		if (wren == 1'b1)
			q <= data;
		else
			q <= RAM_Data[address];

endmodule
