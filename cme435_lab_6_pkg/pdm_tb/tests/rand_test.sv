`timescale 1ns/1ns
`include "./env.sv"

module rand_test();
   env_m env();
   rand_test_p rand_test();
endmodule

program rand_test_p();
   initial begin
      env.run();
   end

   initial begin
      // Optional error injection - do not use when running this test to
      // gather functional coverage
      //env.dut.pdm_core_inst.set_data_corruption(1);
      //env.dut.pdm_core_inst.set_bad_routing(1);
      //env.dut.pdm_core_inst.out_drvr_1.set_corrupt_newdata_len(1);
   end

   class valid_in_td_c extends in_td_c;
      constraint keep_valid {
         dst_port inside {[1:4]};

         payload.size() inside {[4:16]};
         (payload.size() % 4) == 0;

         inter_packet_delay inside {[0:2]};
      }
   endclass

   valid_in_td_c valid_in_td;

   initial begin
      for (int i=0; i<$urandom_range(10,15); i++) begin
         valid_in_td = new();
         void'(valid_in_td.randomize());
         env.in_drvr.add_drive_pkt(valid_in_td);
      end
   end
endprogram

