// The actual test bench (top module and test program)

`include "Timing.vh" // Timing setup for clocking and delays.

class randomtest;
		rand bit sync_reset,jmp,jmp_nz,dont_jmp;
		randc bit [3:0] jmp_addr;

		constraint c1 {
		sync_reset dist {
			0 := 95,
			1 := 5};
			}

		constraint c2 {
		jmp dist {
			0 := 5,
			1 := 5};
			}

		constraint c3 {
		jmp_nz dist {
			0 := 5,
			1 := 5};
			}

endclass

module top();	// The work.top simulation module
	env_m env();
   
	// Instantiate test program (software)
	test_program test();
endmodule

program test_program();
	parameter ns_per_clk = `CLOCK_CYCLE;

	logic [7:0] pm_addr;
	logic [7:0] from_PS;
	logic [7:0] pc;
	
	logic clk;

   // NOTE - Compile (do run_test.do) with this set to to 0 to run the READ test,
   // and to 1 to run the WRITE test




	
   
	initial begin
      // READ TEST
	
	automatic randomtest rt =new();
         	

		
		repeat (1000) begin
			assert(rt.randomize()) else $fatal;


			
			
			// Drive the address using input drvr
			//$display("sync_reset: %h",rt.sync_reset);
			//$display("jmp: %h",rt.jmp);
			//$display("jmp_nz: %h",rt.jmp_nz);
			//$display("dont_jmp: %h",rt.dont_jmp);
			//$display("jmp_addr: %h",rt.jmp_addr);

			#(ns_per_clk);	
			env.input_drvr.program_squencer_signals(rt.sync_reset, rt.jmp, rt.jmp_nz, rt.dont_jmp, rt.jmp_addr);	
			
				

			end

	end
	
      // WRITE TEST	
	/*	if (test_type == 1) begin

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
	end*/

	final begin
		$display("Simulation ended at %0dms", $time);
	end

endprogram

