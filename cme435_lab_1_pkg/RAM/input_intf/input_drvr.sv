`include "input_intf/input_types.sv"

module input_drvr_m(input_intf_i.master intf);

	// TO DO: Implement signal driving capability task

	task automatic RAM_signals(input logic [3:0] address,
							   input logic [3:0] data,
							   input logic wren);
   
		// TO DO: Drive the signals

		intf.address = address;
		intf.data = data;
		intf.wren = wren;
  
   endtask

endmodule

