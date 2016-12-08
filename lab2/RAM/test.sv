// The actual test bench (top module and test program)

`include "Timing.vh" // Timing setup for clocking and delays.

module top();	// The work.top simulation module
	// Instantiate testbench env (hardware)
	env_m env();
   
	// Instantiate test program (software)
	test_program test();
endmodule

program test_program();
	parameter ns_per_clk = `CLOCK_CYCLE;

	logic [3:0] i_pins;
	logic [3:0] oreg;
	logic reset = 1;

   // NOTE - Compile (do run_test.do) with this set to to 0 to run the READ test,
   // and to 1 to run the WRITE test
   
	initial begin
		
      		env.input_drvr.microprocessor_signals(i_pins,reset);

		#(ns_per_clk);

		reset = 0;
		env.input_drvr.microprocessor_signals(i_pins,reset);
		repeat(16) begin
			i_pins=0;
			env.input_drvr.microprocessor_signals(i_pins,reset);	
			repeat (16) begin
				@(env.output_intf_GOLD.o_reg);
				i_pins = i_pins + 4'H01;
				env.input_drvr.microprocessor_signals(i_pins,reset);
			end
		end
	end

	final begin
		$display("Simulation ended at %0dms", $time);
	end

endprogram

