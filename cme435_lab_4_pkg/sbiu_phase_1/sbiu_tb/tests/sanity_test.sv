`timescale 1ns/1ns
`include "./env.sv"

module sanity_test();
   env_m env();
   sanity_test_p sanity_test();
endmodule

program sanity_test_p();
   initial begin
      env.run();
   end

   initial begin
      //env.ds_drvr.set_wait_assert_prob(100);
      //env.ds_drvr.set_wait_dur_range(1,3);
   end

   initial begin
      us_td_c td = new();

      td.src_adr  = 4;
      td.dst_adr  = 8;
      td.pkt_type = TX_DATA;
      td.data     = {1,2,3,4,5};
      td.csum_status = 1;
      td.inter_packet_delay = 1;

      env.us_drvr.add_drive_pkt(td);
      env.us_drvr.add_drive_pkt(td);
      env.us_drvr.add_drive_pkt(td);
      env.us_drvr.add_drive_pkt(td);
   end
endprogram

