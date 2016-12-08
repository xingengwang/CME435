`ifndef US_INTF
   `define US_INTF
   `include "./us_intf/us_intf.sv"
`endif

`ifndef US_DRVR
   `define US_DRVR
   `include "./us_intf/us_drvr.sv"
`endif

`ifndef US_MON
   `define US_MON
   `include "./us_intf/us_mon.sv"
`endif

`ifndef DS_INTF
   `define DS_INTF
   `include "./ds_intf/ds_intf.sv"
`endif

`ifndef DS_DRVR
   `define DS_DRVR
   `include "./ds_intf/ds_drvr.sv"
`endif

`ifndef DS_MON
   `define DS_MON
   `include "./ds_intf/ds_mon.sv"
`endif

`ifndef SBIU_MOD
   `define SBIU_MOD
   `include "./sbiu_module/sbiu_module.sv"
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

   // Instantiate SBIU module component
   sbiu_module_c sbiu_module = new();

   // Instantiate upstream interface component
   us_intf_if us_intf(.*);
   us_drvr_c us_drvr = new(us_intf.master);

   class tb_us_mon_c extends us_mon_c;
      function new (virtual us_intf_if ports);
         super.new(ports);
      endfunction

      virtual function void new_trans_rec(us_trans_rec_c tr);
         super.new_trans_rec(tr);
         sbiu_module.add_us_tr(tr);
      endfunction
   endclass

   //us_mon_c us_mon = new(us_intf);
   tb_us_mon_c us_mon = new(us_intf);

   // Instantiate downstream interface component
   ds_intf_if ds_intf(.*);
   ds_drvr_c ds_drvr = new(ds_intf.slave);

   class tb_ds_mon_c extends ds_mon_c;
      function new (virtual ds_intf_if ports);
         super.new(ports);
      endfunction

      virtual function void new_trans_rec(ds_trans_rec_c tr);
         super.new_trans_rec(tr);
         sbiu_module.add_ds_tr(tr);
      endfunction
   endclass

   //ds_mon_c ds_mon = new(ds_intf);
   tb_ds_mon_c ds_mon = new(ds_intf);

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
         us_mon.run();
         ds_drvr.run();
         ds_mon.run();
         sbiu_module.set_enable(1);
      join
   endtask
endmodule

