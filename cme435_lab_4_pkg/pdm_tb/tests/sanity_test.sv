`timescale 1ns/1ns
`include "./env.sv"

module sanity_test();
   env_m env();
   sanity_test_p sanity_test();
endmodule

program sanity_test_p();
   initial begin
      env.run(); // Can't forget to call the environment's run() function!
   end

   initial begin
      // Uncomment the following line when you reach lab Step 8
      env.dut.pdm_core_inst.enable_dut_bugs();
   end

   // TO DO: Write an initial begin block in which you create a new in_td_c
   // transaction descriptor and push the transaction descriptor into the
   // in_drvr using the in_drvr's add_drive_pkt function. The transaction
   // descriptor should cause the in_drvr to drive a packet with:
   // - destination port set to 2
   // - payload set to {1,2,3,4}
   // When you reach lab step 8, vary the parameters of this TD to identify the DUT bugs

initial begin
      automatic in_td_c td = new();
      td.dst_port  = 4;
      td.payload  = {1,2,3,4};
	td.inter_packet_delay=1;

      env.in_drvr.add_drive_pkt(td);

   end

endprogram

