interface out_intf_if(input logic clk,
                      input logic rst_b);

   logic [4:0] newdata_len;
   logic       proceed;
   logic [7:0] data_out;

   modport slave(input  clk,
                 input  rst_b,
                 input  newdata_len,
                 output proceed,
                 input  data_out);
endinterface: out_intf_if

