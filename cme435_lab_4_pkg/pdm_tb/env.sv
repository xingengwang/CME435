`ifndef IN_INTF
   `define IN_INTF
   `include "./in_intf/in_intf.sv"
`endif

`ifndef IN_DRVR
   `define IN_DRVR
   `include "./in_intf/in_drvr.sv"
`endif

`ifndef OUT_INTF
   `define OUT_INTF
   `include "./out_intf/out_intf.sv"
`endif

`ifndef OUT_DRVR
   `define OUT_DRVR
   `include "./out_intf/out_drvr.sv"
`endif

module env_m();

   logic clk;
   logic rst_b;

   // Instantiate DUT
   // Note how the four sets of output interface signals are wired to the
   // four instances of the out_intf_if.
   pdm dut(
      .clk(clk),
      .rst_b(rst_b),
      .bnd_plse(in_intf.bnd_plse),
      .data_in(in_intf.data_in),
      .ack(in_intf.ack),
      .newdata_len_1(out_intf_p1.newdata_len),
      .proceed_1(out_intf_p1.proceed),
      .data_out_1(out_intf_p1.data_out),
      .newdata_len_2(out_intf_p2.newdata_len),
      .proceed_2(out_intf_p2.proceed),
      .data_out_2(out_intf_p2.data_out),
      .newdata_len_3(out_intf_p3.newdata_len),
      .proceed_3(out_intf_p3.proceed),
      .data_out_3(out_intf_p3.data_out),
      .newdata_len_4(out_intf_p4.newdata_len),
      .proceed_4(out_intf_p4.proceed),
      .data_out_4(out_intf_p4.data_out)
   );

   // Instantiate input interface component
   in_intf_if in_intf(.*);
   in_drvr_c in_drvr = new(in_intf.master);

   // Instantiate output interface components
   out_intf_if out_intf_p1(.*);
   out_intf_if out_intf_p2(.*);
   out_intf_if out_intf_p3(.*);
   out_intf_if out_intf_p4(.*);

   out_drvr_c out_drvr_p1 = new(out_intf_p1.slave, 1);
   out_drvr_c out_drvr_p2 = new(out_intf_p2.slave, 2);
   out_drvr_c out_drvr_p3 = new(out_intf_p3.slave, 3);
   out_drvr_c out_drvr_p4 = new(out_intf_p4.slave, 4);

   // TO DO: Create a gen_clk task that toggles clk to produce a 50MHz frequency
   task gen_clk();
      clk = 0;
      while (1) begin
         #25;
         clk = ~clk;
      end
   endtask

   // TO DO: Create an initial_reset task that initializes rst_b to 0 then
   // deasserts rst_b after a short 65ns delay
   task initial_reset();
      rst_b = 0;
      #65;
      rst_b = 1;
   endtask

   task run();
      fork
         gen_clk();
         initial_reset();
         in_drvr.run();
         out_drvr_p1.run();
         out_drvr_p2.run();
         out_drvr_p3.run();
         out_drvr_p4.run();
      join
   endtask
endmodule

