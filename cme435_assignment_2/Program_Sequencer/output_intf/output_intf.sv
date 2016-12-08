// Note: Interfaces use external signals as the input ports.

// Interfaces take global signals as arguments. For CME 435 the
// only global input signals are clk (and possibly reset).

interface output_intf_i(input logic clk
); // TO DO: Fill in any 
																					// required input ports.

	// TO DO: Add any required internal data types.
	//		  	These would be modport signals.

	logic [7:0] pm_addr;
	logic [7:0] from_PS;
	logic [7:0] pc;
   
	// TO DO: Complete this slave modport to which the
	//        output interface monitor will be connected.
	//
	// NOTE:  The direction is specified with respect to the
	//		  	modport itself. For the ROM DUT output signals
	//		  	will be modport inputs (except for the global
    //      clock input).

	modport slave(input clk,
	input pm_addr,
	input from_PS,
        input pc);

endinterface: output_intf_i
