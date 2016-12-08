`ifndef IN_TYPES
   `define IN_TYPES
   `include "in_intf/in_types.sv"
`endif


interface in_intf_if(input logic clk,
                     input logic rst_b);

   logic ack;
   logic bnd_plse;
   logic [7:0] data_in;

   modport master(input  clk,
                  input  rst_b,
                  input  ack,
                  output bnd_plse,
                  output data_in);
endinterface: in_intf_if

// TO DO: Create an interface called "in_intf_if", with a modport
// called "master" to which the input interface driver will hook up.
// Remember to use the typedefs from in_types.sv where appropriate.

