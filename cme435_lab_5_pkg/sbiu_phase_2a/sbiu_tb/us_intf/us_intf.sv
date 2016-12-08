interface us_intf_if(input logic clk,
                     input logic rst_b);
   logic rdy;
   logic frame;
   logic [7:0] adr_data;

   modport master(input  clk,
                  input  rst_b,
                  input  rdy,
                  output frame,
                  output adr_data);
endinterface: us_intf_if

