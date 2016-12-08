module Program_Memory_ROM (
	input clock,
	input[7:0] address,
	output reg [7:0] q
	);

	reg [7:0] ROM_Data [0:255];
	reg [7:0] i, initial_data;

	initial begin
		i = 0;
		initial_data = 8'HF0;
		repeat (256) begin
			ROM_Data[i] = initial_data;
			initial_data = initial_data + 1;
			i = i + 1;
		end
	end

	always @ (posedge clock)
		q <= ROM_Data[address];

endmodule