// Note: Interface uses external signals as the input ports

interface output_intf_i(input logic clk); // TO DO: Fill in any 
										  // required input ports

	// TO DO: Add any required internal data types
   
	logic [3:0] q;

	// TO DO: Complete this slave modport to which the
	//        output interface monitor will be connected
   // NOTE:   The direction is specified with respect to
   //		  the interface module itself. Monitored signals
   //		  are inputs (to the interface).

	modport slave(input  clk,
	              input q);

endinterface: output_intf_i

