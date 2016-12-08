// The actual test bench (top module and test program)

`include "Timing.vh"	// Timing setup for clocking and delays.

module top();
	// Instantiate testbench env (hardware)
	env_m env();
   
	// Instantiate test program (software)
	test_program test();
endmodule

program test_program();
	parameter ns_per_clk = `CLOCK_CYCLE;

	logic [7:0] address = 0;
  
   // This block contains the procedural "meat" of the test 
	initial begin
		address = 0;
		
		repeat (4) begin
			// Drive the address using input drvr
			$display("ROM address: %h",address);

			env.input_drvr.ROM_signals(address);

         // Wait...
			repeat (3) begin
            @(negedge env.input_intf.clk);
         end

    		#(ns_per_clk/4); // Delay change in address
    
			address = address + 1;
		end
	end

	final begin
		$display("Simulation ended at %t", $time);
	end

endprogram
