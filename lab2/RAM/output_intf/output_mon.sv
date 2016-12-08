`include "output_intf/output_types.sv"

module output_mon_s(output_intf_i.slave intf);

	// TO DO: Implement needed tasks

	task get_o_reg(output [3:0] o_reg);
		o_reg = intf.o_reg;
	endtask

endmodule

