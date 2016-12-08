// The actual test bench (top module and test program)

`include "Timing.vh" // Timing setup for clocking and delays.

class randomtest;
		rand bit [3:0] i_pins_dm;
		rand bit [3:0] i_pins_i;
		constraint c1 {
		i_pins_dm != i_pins_i;
			}
covergroup cover_me;
  i_pins_dm_cp : coverpoint i_pins_dm;
  i_pins_i_cp : coverpoint i_pins_i;

  dm_i_cross: cross i_pins_dm_cp,  i_pins_i_cp {
    			ignore_bins holes =	(binsof(i_pins_i_cp) intersect { 0} && binsof(i_pins_dm_cp) intersect { 0}) ||
						(binsof(i_pins_i_cp) intersect { 1} && binsof(i_pins_dm_cp) intersect { 1}) ||
						(binsof(i_pins_i_cp) intersect { 2} && binsof(i_pins_dm_cp) intersect { 2}) ||
						(binsof(i_pins_i_cp) intersect { 3} && binsof(i_pins_dm_cp) intersect { 3}) ||
						(binsof(i_pins_i_cp) intersect { 4} && binsof(i_pins_dm_cp) intersect { 4}) ||
						(binsof(i_pins_i_cp) intersect { 5} && binsof(i_pins_dm_cp) intersect { 5}) ||
						(binsof(i_pins_i_cp) intersect { 6} && binsof(i_pins_dm_cp) intersect { 6}) ||
						(binsof(i_pins_i_cp) intersect { 7} && binsof(i_pins_dm_cp) intersect { 7}) ||
						(binsof(i_pins_i_cp) intersect { 8} && binsof(i_pins_dm_cp) intersect { 8}) ||
						(binsof(i_pins_i_cp) intersect { 9} && binsof(i_pins_dm_cp) intersect { 9}) ||
						(binsof(i_pins_i_cp) intersect { 10} && binsof(i_pins_dm_cp) intersect { 10}) ||
						(binsof(i_pins_i_cp) intersect { 11} && binsof(i_pins_dm_cp) intersect { 11}) ||
						(binsof(i_pins_i_cp) intersect { 12} && binsof(i_pins_dm_cp) intersect { 12}) ||
						(binsof(i_pins_i_cp) intersect { 13} && binsof(i_pins_dm_cp) intersect { 13}) ||
						(binsof(i_pins_i_cp) intersect { 14} && binsof(i_pins_dm_cp) intersect { 14}) ||
						(binsof(i_pins_i_cp) intersect { 15} && binsof(i_pins_dm_cp) intersect { 15});
	}
endgroup
	function new();

		cover_me = new();
	endfunction
	
		
endclass



module top();	// The work.top simulation module
	// Instantiate testbench env (hardware)
	env_m env();
   
	// Instantiate test program (software)
	test_program test();
endmodule

program test_program();
	parameter ns_per_clk = `CLOCK_CYCLE;

	logic [3:0] i;
	logic [3:0] dm;
	logic reset = 1;
	randomtest rt = new();
   // NOTE - Compile (do run_test.do) with this set to to 0 to run the READ test,
   // and to 1 to run the WRITE test
   
	initial begin
		
		
		
      		env.input_drvr.microprocessor_signals(i,reset);

		#(ns_per_clk);

		reset = 0;
		repeat(5000) begin
			#(ns_per_clk);
			rt.randomize();
			i= rt.i_pins_i;
			dm= rt.i_pins_dm;
			env.input_drvr.microprocessor_signals(i,reset);	
			#(ns_per_clk);
			env.input_drvr.microprocessor_signals(dm,reset);

			rt.cover_me.sample();	

		end
	end

	final begin
		$display("Simulation ended at %0dms", $time);
	end

endprogram

