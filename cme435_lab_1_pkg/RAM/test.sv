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

	logic [3:0] address = 0;
	logic [3:0] data = 0;
	logic wren = 0;

   // NOTE - Compile (do run_test.do) with this set to to 0 to run the READ test,
   // and to 1 to run the WRITE test
	logic test_type = 1;
   
	initial begin
      // READ TEST
	
		if(test_type == 0) begin
	
         // TO DO: Implement the READ TEST

		
		repeat (4) begin
			// Drive the address using input drvr
			$display("RAM address: %h",address);

			env.input_drvr.program_squencer_signals(address,data,wren);

         // Wait...
			repeat (3) begin
            		@(negedge env.input_intf.clk);
         			end

    		#(ns_per_clk/4); // Delay change in address
    
			address = address + 1;
			end

				end
	
      // WRITE TEST	
		if (test_type == 1) begin

         // TO DO: Implement the WRITE TEST
		env.input_drvr.RAM_signals(address,data,wren);

		#(ns_per_clk);
		#(ns_per_clk/8);
		wren =1;
		env.input_drvr.RAM_signals(address,data,wren);
		
		#(ns_per_clk/8);
		address =1;
		env.input_drvr.RAM_signals(address,data,wren);

		#(ns_per_clk);
		wren =0;
		data=1;
		env.input_drvr.RAM_signals(address,data,wren);

		#(ns_per_clk);
		data=2;
		env.input_drvr.RAM_signals(address,data,wren);

		#(ns_per_clk);
		wren =1;
		address=2;
		env.input_drvr.RAM_signals(address,data,wren);

		#(ns_per_clk);
		data=3;
		env.input_drvr.RAM_signals(address,data,wren);

		#(ns_per_clk);
		wren=0;
		env.input_drvr.RAM_signals(address,data,wren);

		#(ns_per_clk/2);
		address=3;
		env.input_drvr.RAM_signals(address,data,wren);

		#(ns_per_clk/2);

		end
	end

	final begin
		$display("Simulation ended at %0dms", $time);
	end

endprogram

