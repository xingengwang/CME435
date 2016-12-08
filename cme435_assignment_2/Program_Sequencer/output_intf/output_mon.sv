`include "output_intf/output_types.sv"

// The monitor uses an interface as its argument. In this
// case the slave modport defined in the interface.

module output_mon_s(output_intf_i.slave intf);

	// TO DO: Implement needed tasks.

	
	task automatic watch(output [7:0] pm_addr, output [7:0] from_PS, output [7:0] pc);
		pm_addr = intf.pm_addr;
		from_PS = intf.from_PS;
		pc = intf.pc;
		
	endtask

endmodule
