`ifndef IN_INTF
   `define IN_INTF
   `include "./in_intf/in_intf.sv"
`endif

`ifndef IN_DRVR
   `define IN_DRVR
   `include "./in_intf/in_drvr.sv"
`endif

`ifndef IN_MON
   `define IN_MON
   `include "./in_intf/in_mon.svp"
`endif

`ifndef OUT_INTF
   `define OUT_INTF
   `include "./out_intf/out_intf.sv"
`endif

`ifndef OUT_DRVR
   `define OUT_DRVR
   `include "./out_intf/out_drvr.sv"
`endif

`ifndef OUT_MON
   `define OUT_MON
   `include "./out_intf/out_mon.svp"
`endif

`ifndef PDM_MOD
   `define PDM_MOD
   `include "./pdm_module/pdm_module.svp"
`endif

module env_m();

   logic clk;
   logic rst_b;

   // Instantiate DUT
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

   // Instantiate PDM module component
   pdm_module_c pdm_module = new();

   // Instantiate input interface component
   in_intf_if in_intf(.*);
   in_drvr_c  in_drvr = new(in_intf.master);

   class tb_in_mon_c extends in_mon_c;
      function new (virtual in_intf_if ports);
         super.new(ports);
      endfunction

      virtual function void new_trans_rec(in_trans_rec_c tr);
         super.new_trans_rec(tr);
         pdm_module.add_in_tr(tr);
      endfunction
   endclass

   tb_in_mon_c in_mon = new(in_intf);

   // Instantiate output interface components
   out_intf_if out_intf_p1(.*);
   out_intf_if out_intf_p2(.*);
   out_intf_if out_intf_p3(.*);
   out_intf_if out_intf_p4(.*);

   out_drvr_c out_drvr_p1 = new(out_intf_p1.slave, 1);
   out_drvr_c out_drvr_p2 = new(out_intf_p2.slave, 2);
   out_drvr_c out_drvr_p3 = new(out_intf_p3.slave, 3);
   out_drvr_c out_drvr_p4 = new(out_intf_p4.slave, 4);

   class tb_out_mon_c extends out_mon_c;
      function new (virtual out_intf_if ports, int inst_num);
         super.new(ports, inst_num);
      endfunction

      virtual function void new_trans_rec(out_trans_rec_c tr);
         super.new_trans_rec(tr);
         pdm_module.add_out_tr(tr);
      endfunction
   endclass

   tb_out_mon_c  out_mon_p1  = new(out_intf_p1, 1);
   tb_out_mon_c  out_mon_p2  = new(out_intf_p2, 2);
   tb_out_mon_c  out_mon_p3  = new(out_intf_p3, 3);
   tb_out_mon_c  out_mon_p4  = new(out_intf_p4, 4);

   task gen_clk();
      clk = 0;
      while (1) begin
         #10;
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
         in_drvr.run();
         in_mon.run();
         out_drvr_p1.run();
         out_drvr_p2.run();
         out_drvr_p3.run();
         out_drvr_p4.run();
         out_mon_p1.run();
         out_mon_p2.run();
         out_mon_p3.run();
         out_mon_p4.run();
         pdm_module.set_enable(1);
      join
   endtask
endmodule

