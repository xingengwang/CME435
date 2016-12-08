// Note: Interface uses external signals as their input ports

interface input_intf_i(input logic clk); // TO DO: Fill in any
                                         // required input ports

	// TO DO: Add any required internal data types
	// These would be modport signals...
                       
	// TO DO: Complete this master modport to which the
	//        input interface driver will be connected
   // NOTE:   The direction is specified with respect to
   //		  the interface module itself. Driven signals
   //		  are outputs (from the interface).


	
	logic sync_reset;
	logic jmp;
	logic jmp_nz;
	logic dont_jmp;
	logic [3:0] jmp_addr;
	
	

   	modport master(input  clk,
			input sync_reset,
			input jmp,
			input jmp_nz,
			input dont_jmp,
			input jmp_addr);
              
endinterface: input_intf_i

