// Note: Interface uses external signals as their input ports

interface input_intf_i(input logic clk); // TO DO: Fill in any
                                         // required input ports

	// TO DO: Add any required internal data types
	// These would be modport signals...

	logic [3:0] address;
	logic [3:0] data;
	logic wren;
                       
	// TO DO: Complete this master modport to which the
	//        input interface driver will be connected
   // NOTE:   The direction is specified with respect to
   //		  the interface module itself. Driven signals
   //		  are outputs (from the interface).

   	modport master(input  clk,
                   output address,
				   output data,
				   output wren);
              
endinterface: input_intf_i

