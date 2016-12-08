`ifndef OUT_TYPES
   `define OUT_TYPES
   `include "out_intf/out_types.sv"
`endif

interface out_intf_if(input logic clk,
                     input logic rst_b);

   logic       proceed;
   logic [4:0] newdata_len;
   logic [7:0] data_out;

   modport slave(input  clk,
                 input  rst_b,
                 input  data_out,
		 input newdata_len,
                 output proceed);
endinterface: out_intf_if


// TO DO: Create an interface called "out_intf_if", with a modport
// called "slave" to which the output interface driver will hook up.
// Remember to use the typedefs from out_types.sv where appropriate.

