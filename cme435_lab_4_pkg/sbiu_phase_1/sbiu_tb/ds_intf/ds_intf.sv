interface ds_intf_if(input logic clk,
                     input logic rst_b);

   logic       bus_req;
   logic       bus_gnt;
   logic       wait_sig;
   logic       valid;
   logic [7:0] src_adr_out;
   logic [7:0] dst_adr_out;
   logic [7:0] data_out;

   modport slave(input  clk,
                 input  rst_b,
                 input  bus_req,
                 input  valid,
                 input  src_adr_out,
                 input  dst_adr_out,
                 input  data_out,
                 output bus_gnt,
                 output wait_sig);
endinterface: ds_intf_if

