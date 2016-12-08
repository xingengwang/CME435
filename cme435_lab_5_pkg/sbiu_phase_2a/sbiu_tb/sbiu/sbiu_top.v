`timescale 1ns/1ns

module sbiu (
   clk,
   rst_b,
   rdy,
   frame,
   adr_data,
   bus_req,
   bus_gnt,
   wait_sig,
   valid,
   src_adr_out,
   dst_adr_out,
   data_out
);

// Input Ports
input        clk;
input        rst_b;
input        frame;
input  [7:0] adr_data;
input        bus_gnt;
input        wait_sig;

// Output Ports
output       rdy;
output       bus_req;
output       valid;
output [7:0] src_adr_out;
output [7:0] dst_adr_out;
output [7:0] data_out;

// Core Instance
sbiu_core sbiu_core_inst(
   .clk(clk),
   .rst_b(rst_b),
   .frame(frame),
   .adr_data(adr_data),
   .bus_gnt(bus_gnt),
   .wait_sig(wait_sig),
   .rdy(rdy),
   .bus_req(bus_req),
   .valid(valid),
   .src_adr_out(src_adr_out),
   .dst_adr_out(dst_adr_out),
   .data_out(data_out)
);

endmodule

