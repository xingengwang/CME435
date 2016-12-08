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
      // TO DO: Uncomment the following error injection settings
      // one-at-a-time, verify that your monitor or module
      // component raises the appropriate error:

      // Input interface error injection
      //env.dut.pdm_core_inst.set_ack_delay_range(5,5);
      //env.dut.pdm_core_inst.set_drive_ack_two_cycles(1);

      // Output interface error injection
      //env.out_drvr_p2.set_proceed_delay_range(5,5);
      //env.out_drvr_p3.set_drive_two_proceed_cycles(1);


      // Try the following two error injection routines. Your interface monitors
      // can't detect these bugs. A module component will eventually be needed
      // for end-to-end checking of packet traffic passing *through* the PDM.
      //env.dut.pdm_core_inst.set_data_corruption(1);
      //env.dut.pdm_core_inst.set_bad_routing(1);
      //env.dut.pdm_core_inst.out_drvr_1.set_corrupt_newdata_len(1);
   end

	initial begin
      #1000 $stop;
   end

   initial begin
      in_td_c td;

      // TO DO: After trying out the error injection scenarios above, modify the payload
      // in one of the following packets such that the payload size is invalid (i.e. not
      // a multiple of 4 in the range [4,16]). See if your interface monitor reports the
      // invalid payload size.

      // Drive packet to output port 1
      td = new();
      td.dst_port = 1;
      td.payload  = {1,2,3,4};
      env.in_drvr.add_drive_pkt(td);

      // Drive packet to output port 2
      td = new();
      td.dst_port = 2;
      td.payload  = {5,6,7,8};
      env.in_drvr.add_drive_pkt(td);

      // Drive packet to output port 3
      td = new();
      td.dst_port = 3;
      td.payload  = {9,10,11,12,13,14,15,16};
      env.in_drvr.add_drive_pkt(td);

      // Drive packet to output port 4
      td = new();
      td.dst_port = 4;
      td.payload  = {17,18,19,20,21,22,23,24};
      env.in_drvr.add_drive_pkt(td);

   end
endprogram

