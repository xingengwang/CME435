// This module represents the testbench environment. The verification
// components and DUT are instantiated and wired up within this module.
// Additionally, the environment provides signals from the "system-level"
// (i.e. common signals that would not come from the DUT nor our CME 435
// verification components). Namely, clk and reset are driven by the
// environment module.

`include "Timing.vh"	// Timing setup for clocking and delays.

module env_m();
	parameter ns_per_clk = `CLOCK_CYCLE;

	reg clk;
	//reg reset; // Don't need this for ROM and RAM.

	// TO DO: Instantiate the input interface block.
	input_intf_i input_intf(clk);

	// TO DO: Instantiate the input driver module.
	input_drvr_m input_drvr(input_intf);
	
	// TO DO: Instantiate the output interface block.
  	output_intf_i output_intf(clk);

	output_mon_s output_mon(output_intf);

	
	// TO DO: Instantiate the DUT(s).
	// Note: Will get warnings for unconnected signals.

	program_sequencer DUT (
		.clk(clk),
		.sync_reset(env.input_intf.sync_reset),
		.jmp(env.input_intf.jmp),
		.jmp_nz(env.input_intf.jmp_nz),
		.dont_jmp(env.input_intf.dont_jmp),
		.jmp_addr(env.input_intf.jmp_addr),
		.pm_addr(env.output_intf.pm_addr),
		.from_PS(env.output_intf.from_PS),
		.pc(env.output_intf.pc)
	);
	
	// Generate clock waveform by toggling the clk reg value.
	// The clk ALWAYS starts low and goes high.

	initial begin
		clk = 0;            // Low at t=0
		forever begin
			#(ns_per_clk/2)	// Toggle every half cycle
			clk = ~clk;
			
			if(env.input_intf.sync_reset)
			begin
				assert(env.output_intf.pm_addr != 0) $fatal;
			end
			else if (env.input_intf.jmp)
			begin
				assert(env.output_intf.pm_addr == {env.input_intf.jmp_addr,4'H00}) else $fatal;
			end
			else if (env.input_intf.jmp_nz && !(env.input_intf.dont_jmp))
			begin
				assert(env.output_intf.pm_addr == {env.input_intf.jmp_addr,4'H00}) else $fatal;
			end
			


			
		end
	end

	// Deassert reset shortly after beginning of simulation.
	// This is done 3/4 of a clock cycle after t=0.
	// The reset signal asserts high and deasserts low for micro.
	// NOTE: Program_Sequencer is the ONLY module using reset!

	//initial begin
		//reset = 1;                        // High at t=0
		//#((ns_per_clk/2)+(ns_per_clk/4))	// 3/4 of a cycle
		//reset = 0;
	//end
   
	// Start the reactive (slave) output monitor.



endmodule
