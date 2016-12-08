`include "output_intf/output_types.sv"

module output_mon_s(output_intf_i.slave intf);

	// TO DO: Implement needed tasks

	task get_q(output [3:0] q);
		q = intf.q;
	endtask

endmodule

