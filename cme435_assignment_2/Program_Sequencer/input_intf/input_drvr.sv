`include "input_intf/input_types.sv"

module input_drvr_m(input_intf_i.master intf);

	// TO DO: Implement signal driving capability task

	task automatic program_squencer_signals(input logic sync_reset,
		input logic jmp,
		input logic jmp_nz,
		input logic dont_jmp,
		input logic [3:0] jmp_addr);
   
		// TO DO: Drive the signals


		intf.sync_reset = sync_reset;
		intf.jmp = jmp;
		intf.jmp_nz = jmp_nz;
		intf.dont_jmp = dont_jmp;
		intf.jmp_addr = jmp_addr;
  
   endtask

endmodule

