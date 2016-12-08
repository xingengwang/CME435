interface in_intf_if(input logic clk,
                     input logic rst_b);
   logic       bnd_plse;
   logic [7:0] data_in;
   logic       ack;

   modport master(input  clk,
                  input  rst_b,
                  output bnd_plse,
                  output data_in,
                  input  ack);
endinterface: in_intf_if

