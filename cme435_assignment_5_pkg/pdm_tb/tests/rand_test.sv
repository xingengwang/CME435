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
      // Optional error injection
      //env.out_drvr_p2.set_proceed_delay_range(5,5);
      //env.dut.pdm_core_inst.set_ack_delay_range(5,5);
      //env.dut.pdm_core_inst.set_drive_ack_two_cycles(1);
      //env.dut.pdm_core_inst.set_data_corruption(1);
      //env.dut.pdm_core_inst.set_bad_routing(1);
   end

   // TO DO: Create a class called "valid_in_td_c" that inherits
   // (extends) from the in_td_c class. Within this inherited class
   // add the following constraints:
   // - Keep dst_port within the valid range for the PDM (1-4).
   // - Keep the payload size valid for the PDM (from functional
   //   description in Lab 4: payload ranges from 4-16, in multiples
   //   of 4 only).
   // - Keep the inter_packet_delay in the range 0-3.
   //
   // Sample structure for creating an inherited transaction descriptor:
   //
	class valid_in_td_c extends in_td_c;
		constraint keep_valid {
		 dst_port inside {[1:4]};
		 payload.size() inside {4,8,12,16};
		 inter_packet_delay inside {[0:3]};
	}
	endclass
   

   // TO DO: Create a class called "short_in_td_c" that inherits
   // from the valid_in_td_c class that you created above. Within
   // short_in_td_c, set a constraint to keep the payload size
   // equal to 4 at all times.
   class short_in_td_c extends valid_in_td_c;
		constraint keep_payload_size_4 {
		 payload.size() inside {4};
	}
	endclass

   // TO DO: Create a class called "odd_port_in_td_c" that inherits
   // from the valid_in_td_c class. Within odd_port_in_td_c, set a
   // constraint to keep dst_port equal to either 1 or 3.
   class odd_port_in_td_c extends valid_in_td_c;
		constraint keep_payload_size_4 {
		 dst_port inside {1,3};
	}
	endclass

   // TO DO: Create instances of the three inherited classes that
   // you defined above. Note - it is not necessary to new() the
   // instances here as they will be "new()" each time we
   // randomize them and pass them to the input driver.
   valid_in_td_c valid_in_td_c_inst;
   short_in_td_c short_in_td_c_inst;
   odd_port_in_td_c odd_port_in_td_c_inst;

   initial begin
      // TO DO: In a loop that iterates randomly between 5-7 times,
      // new() the valid_in_td instance, randomize it, and pass it
      // to the input driver.
      for (int i=0; i<$urandom_range(5,7); i++) begin
      	valid_in_td_c_inst = new();
      	void'(valid_in_td_c_inst.randomize());
      	env.in_drvr.add_drive_pkt(valid_in_td_c_inst);
      end

      // TO DO: Create a randsequence block, with labeled sequences
      // "main", "one", "two", "short", "odd_port", "regular", and
      // "complete". The sequences should then perform the following:
      // - main:     jump to labels one, two, one, two, complete
      // - one:      randomly jump to either label short or regular
      // - two:      randomly jump to either label odd_port or regular
      // - short:    new(), randomize, and drive a short_in_td
      // - odd_port: new(), randomize, and drive an odd_port_in_td
      // - regular:  new(), randomize, and drive a valid_in_td
      // - complete: display a message indicating that the sequence
      //             is complete
      randsequence(main)
      	main		: one two one two complete;
      	one      : short | regular;
      	two      : odd_port | regular;
      	short    : {short_in_td_c_inst = new();void'(short_in_td_c_inst.randomize());env.in_drvr.add_drive_pkt(short_in_td_c_inst);};
      	odd_port : {odd_port_in_td_c_inst = new();void'(odd_port_in_td_c_inst.randomize());env.in_drvr.add_drive_pkt(odd_port_in_td_c_inst);};
      	regular	: {valid_in_td_c_inst = new();void'(valid_in_td_c_inst.randomize());env.in_drvr.add_drive_pkt(valid_in_td_c_inst);};
      	complete : {$display("Sequence completed.");};
      endsequence
   end
endprogram

