`include "input_intf/input_types.sv"

// The driver uses an interface as its argument. In this
// case the master modport defined in the interface.

module input_drvr_m(input_intf_i.master intf);

	// TO DO: Implement signal driving capability task.

	task automatic ROM_signals(input logic [7:0] address);
   
		// TO DO: Drive the signals.
		
      intf.address = address;
		
	endtask

endmodule
