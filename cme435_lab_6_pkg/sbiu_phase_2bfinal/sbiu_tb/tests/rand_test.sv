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
      //env.ds_drvr.set_bus_gnt_delay_range(1, 1);
      //env.ds_drvr.set_wait_assert_prob(40);
      //env.ds_drvr.set_wait_dur_range(1, 3);

      env.dut.sbiu_core_inst.set_rdy_delay_range(3, 3);
      env.dut.sbiu_core_inst.set_no_bus_gnt_wait(0);
      env.dut.sbiu_core_inst.set_ignore_wait(0);
      env.dut.sbiu_core_inst.set_src_early_deassert(0);
      env.dut.sbiu_core_inst.set_dst_early_deassert(0);

      env.dut.sbiu_core_inst.set_src_adr_corruption(0);
      env.dut.sbiu_core_inst.set_dst_adr_corruption(0);
      env.dut.sbiu_core_inst.set_pkt_type_corruption(0);
      env.dut.sbiu_core_inst.set_csum_corruption(0);
      env.dut.sbiu_core_inst.set_data_corruption(0);
      env.dut.sbiu_core_inst.set_drop_good_pkt(0);
      env.dut.sbiu_core_inst.set_pass_bad_pkt(0);
   end

   // Inherited class from the base us_td_c that constrains the packet
   // type and payload size to be valid, with invalid checksums 15% of
   // the time.
   class valid_us_td_c extends us_td_c;
      constraint keep_valid {
         // NOTE: TD should really have a random variable "len"
         //       so that pkt_type can be generated before len, then
         //       len can be used to set the data size. Right now,
         //       the constraints will be satisfied, but most packets
         //       will be TX_DATA because the data size seems to be
         //       generated first, and then the pkt_type has to be
         //       set accordingly. Since every size other than 0 and 2
         //       is only valid for TX_DATA, there's a much higher
         //       probability of the TX_DATA type being generated.
         pkt_type inside {[0:2]};

         (pkt_type == 0) -> (data.size() inside {[0:28]});
         (pkt_type == 1) -> (data.size() == 2);
         (pkt_type == 2) -> (data.size() == 0);
      }

      constraint bad_csum_15pct {
         csum_status dist {0 := 15,
                           1 := 85};
      }

      constraint ipkt_delay {
         inter_packet_delay inside {[1:2]};
      }
   endclass

   // Second-level inherited class that is constrained to TX_DATA packets only
   class tx_data_us_td_c extends valid_us_td_c;
      constraint tx_data_only {
         pkt_type == 0;

         data.size() dist {[0:10]  :/ 40,
                           [11:20] :/ 30,
                           [21:28] :/ 30};

         foreach (data[i])
            !(data[i] inside {['hF0:'hFF]});
      }
   endclass

   // Second-level inherited class that is constrained to CMD packets only
   class cmd_us_td_c extends valid_us_td_c;
      constraint cmd_only {
         pkt_type == 1;

         (src_adr < 'h20) -> (dst_adr inside {['h00:'h7F]});
      }
   endclass

   // Second-level inherited class that is constrained to HBEAT packets only
   class hbeat_us_td_c extends valid_us_td_c;
      function new();
         // Disable parent class constraint on checksum status
         bad_csum_15pct.constraint_mode(0);
      endfunction

      constraint hbeat_only {
         pkt_type == 2;
      }

      /*
      // Redefining/overriding the parent's constraint block
      // seems to be a valid approach as well
      constraint bad_csum_15pct {
         csum_status dist {0 := 90,
                           1 := 10};
      }
      */

      constraint bad_csum_30pct {
         csum_status dist {0 := 30,
                           1 := 70};
      }
   endclass

   valid_us_td_c   valid_us_td;
   tx_data_us_td_c tx_data_us_td;
   cmd_us_td_c     cmd_us_td;
   hbeat_us_td_c   hbeat_us_td;

   initial begin
      // Loop that iterates between 2-5 times, generating random valid
      // packet descriptors
      for (int i=0; i<$urandom_range(5,2); i++) begin
         valid_us_td = new(); // Allocate memory for each new descriptor
         void'(valid_us_td.randomize()); // Randomize the descriptor
         env.us_drvr.add_drive_pkt(valid_us_td); // Drive the descriptor
      end

      // This random sequence is capable of driving all possible pair
      // combinations of packet types
      randsequence(main)
         main:     one two complete;
         one:      tx_data | cmd | hbeat;
         two:      tx_data | cmd | hbeat;
         tx_data:  {
                     tx_data_us_td = new();
                     void'(tx_data_us_td.randomize());
                     env.us_drvr.add_drive_pkt(tx_data_us_td);
                   };
         cmd:      {
                     cmd_us_td = new();
                     void'(cmd_us_td.randomize());
                     env.us_drvr.add_drive_pkt(cmd_us_td);
                   };
         hbeat:    {
                     hbeat_us_td = new();
                     void'(hbeat_us_td.randomize());
                     env.us_drvr.add_drive_pkt(hbeat_us_td);
                   };
         complete: {$display("Sequence completed.");};
      endsequence
   end

   /////////////////////////////////////////////////////////////////////////////
   // Examples of working code to change the random number generator's seed
   /////////////////////////////////////////////////////////////////////////////
   /*
   // OPTION 1 - Call built-in srandom function for an object. Note that if
   //            the srandom() call with a literal argument is placed in a loop,
   //            the object will randomize to the same values every time!
   initial begin
      valid_us_td_c valid_us_td;

      valid_us_td = new();
      valid_us_td.srandom(88); // srandom is built-in class function
      void'(valid_us_td.randomize());
      env.us_drvr.add_drive_pkt(valid_us_td);
   end
   */

   /*
   // OPTION 2 - Create a "feeder" object whose seed is set with srandom().
   //            Create a series of separate objects that are shallow copies
   //            of the feeder object each time the feeder is re-randomized.
   initial begin
      valid_us_td_c feeder;
      valid_us_td_c td_to_drive;

      feeder = new();
      feeder.srandom(99);

      for (int i=0; i<$urandom_range(5,2); i++) begin
         void'(feeder.randomize()); // Randomize the feeder object
         td_to_drive = new feeder; // Create a new TD as a shallow copy
                                   // of the feeder object
         env.us_drvr.add_drive_pkt(td_to_drive); // Drive the td_to_drive
      end
   end
   */

   /*
   // OPTION 3 - Get a handle to the current process and seed the process
   initial begin
      valid_us_td_c valid_us_td;

      process p; // Process handle
      p = process::self(); // Process handle points to current process
      p.srandom(4); // Seed the current process

      // Loop that iterates between 2-5 times, generating random valid
      // packets
      for (int i=0; i<$urandom_range(5,2); i++) begin
         valid_us_td = new();
         void'(valid_us_td.randomize());
         env.us_drvr.add_drive_pkt(valid_us_td);
      end
   end
   */

   /*
   // OPTION 4 - Seed the root thread from the command line using the
   //            following switch when vsim is invoked:
   // vsim -sv_seed <value>
   */

endprogram

