`include "output_intf/output_types.sv"

// The monitor uses an interface as its argument. In this
// case the slave modport defined in the interface.

module output_mon_s(output_intf_i.slave intf);

	// TO DO: Implement needed tasks.

	task automatic watch();
	
		forever begin
			// TO DO: Wait for the "DUT" q output to change

			@(intf.q);
            
			// TO DO: Do something (i.e., display signal and time).

        $display("q: %h @ %t", intf.q, $time);
            
		end
		
	endtask

endmodule
