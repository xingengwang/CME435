// Note: Interfaces use external signals as their input ports.

// Interfaces take global signals as arguments. For CME 435 the
// only global input signals are clk (and possibly reset).

interface input_intf_i(input logic clk); // TO DO: Fill in any
																				 // required input ports.

	// TO DO: Add any required internal data types.
	// These would be modport signals...

  logic [7:0] address;
	
	// TO DO: Complete this master modport to which the
	// 				input interface driver will be connected.
	//
	// NOTE:  The direction is specified with respect to the
	//				modport itself. For the ROM DUT input signals
	//		  	will be modport outputs (except for the global
  //        clock input).

	modport master(
								 input  clk,
								 output address
								 );
              
endinterface: input_intf_i
