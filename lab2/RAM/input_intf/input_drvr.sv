`include "input_intf/input_types.sv"

module input_drvr_m(input_intf_i.master intf);

	// TO DO: Implement signal driving capability task

	task automatic microprocessor_signals(input logic [3:0] i_pins,
							   input logic reset);
   
		// TO DO: Drive the signals

		intf.i_pins = i_pins;
		intf.reset = reset;
  
   endtask

endmodule

