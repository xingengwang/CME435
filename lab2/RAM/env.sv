// This module represents the testbench environment. The verification
// components and DUT are instantiated and wired up within this module.
// Additionally, the environment provides signals from the "system-level"
// (i.e. common signals that would not come from the DUT nor our
// verification components). Namely, clk and reset are driven by the
// environment module.

`include "Timing.vh"	// Timing setup for clock and delays.

module env_m();
	parameter ns_per_clk = `CLOCK_CYCLE;

	reg clk;
	//reg reset; // Don;t need this for ROM and RAM

	// TO DO: Instantiate the input interface block
	input_intf_i input_intf(clk);

	// TO DO: Instantiate the input driver module
	input_drvr_m input_drvr(input_intf);

	// TO DO: Instantiate the output interface block
	output_intf_i output_intf_DUT(clk);
	output_intf_i output_intf_GOLD(clk);

	// TO DO: Instantiate the output monitor module
	output_mon_s output_mon(output_intf_GOLD);
   
	// TO DO: Instantiate the DUT(s)
	// Note: Will get warnings for unconnected signals.

	microprocessor GOLD (
		.clk(clk),
		.reset(input_intf.reset),
		.i_pins(input_intf.i_pins),
		.o_reg(output_intf_GOLD.o_reg)
		);

	// Generate clock waveform by toggling the reg value

	initial begin
		clk = 0;
		forever begin
			#(ns_per_clk/2)
			clk = ~clk;
		end
	end

	// Deassert reset shortly after beginning of simulation
	// Specifically half way through the last half of the cycle.
	// NOTE: The ROM and RAM module do not need a reset!

	//initial begin
	//	reset = 1;
	//	#((ns_per_clk/2)+(ns_per_clk/4))            
	//	reset = 0;
	//end
   
	// Start the reactive (slave) output driver/monitor

	//initial begin
		//output_mon.watch();
	//end

endmodule

