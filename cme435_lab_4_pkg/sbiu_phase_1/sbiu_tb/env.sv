`ifndef US_INTF
   `define US_INTF
   `include "./us_intf/us_intf.sv"
`endif

`ifndef US_DRVR
   `define US_DRVR
   `include "./us_intf/us_drvr.sv"
`endif

`ifndef DS_INTF
   `define DS_INTF
   `include "./ds_intf/ds_intf.sv"
`endif

`ifndef DS_DRVR
   `define DS_DRVR
   `include "./ds_intf/ds_drvr.sv"
`endif

module env_m();

   logic clk;
   logic rst_b;

   // Instantiate DUT
   sbiu dut(
      .clk(clk),
      .rst_b(rst_b),
      .rdy(us_intf.rdy),
      .frame(us_intf.frame),
      .adr_data(us_intf.adr_data),
      .bus_req(ds_intf.bus_req),
      .bus_gnt(ds_intf.bus_gnt),
      .wait_sig(ds_intf.wait_sig),
      .valid(ds_intf.valid),
      .src_adr_out(ds_intf.src_adr_out),
      .dst_adr_out(ds_intf.dst_adr_out),
      .data_out(ds_intf.data_out)
   );

   // Instantiate upstream interface component
   us_intf_if us_intf(.*);
   us_drvr_c us_drvr = new(us_intf.master);

   // Instantiate downstream interface component
   ds_intf_if ds_intf(.*);
   ds_drvr_c ds_drvr = new(ds_intf.slave);

   task gen_clk();
      clk = 0;
      while (1) begin
         #25;
         clk = ~clk;
      end
   endtask

   task initial_reset();
      rst_b = 0;
      #65;
      rst_b = 1;
   endtask

   task run();
      fork
         gen_clk();
         initial_reset();
         us_drvr.run();
         ds_drvr.run();
      join
   endtask
endmodule

