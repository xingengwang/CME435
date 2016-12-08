`ifndef IN_MON
   `define IN_MON
   `include "in_intf/in_mon.sv"
`endif

`ifndef OUT_MON
   `define OUT_MON
   `include "out_intf/out_mon.sv"
`endif

class pdm_mod_rec_c;
   time            timestamp;
   in_trans_rec_c  in_tr;
   out_trans_rec_c out_tr;

   // TO DO: Create a coverage group called pkt_cov.
   // ---> within this coverage group:
   // - Create a coverpoint called "dst_port" on dst_port in the in_tr, 
   //   with values 1-4 each in their own bin "port[x]" (use bins <name>[]),
   //   and value 0 and those above 4 ignored (ignore_bins).
   // - Create a coverpoint called "payload_size" on payload_size in
   //   the in_tr, with each valid value (4,8,12,16) in its own bin.
   // - Create a cross of the dst_port and payload_size coverpoints
   //   called dst_port_x_payload_sz.
      covergroup pkt_cov;
      // Cover src_adr with no bins specification
      dst_port: coverpoint in_tr.dst_port {
      	bins port[] = {[1:4]};
      	ignore_bins no_care_vals = {0,[5:7]};
      }
		
 		payload_size: coverpoint in_tr.payload_size {
 			bins payload[] = {4,8,12,16};
		}
		
		dst_port_x_payload_sz: cross dst_port, payload_size;
     
   endgroup


   // TO DO: Create a coverage group called in_if_cov.
   // ---> within this coverage group:
   // - Create a coverpoint called "ack_delay" on ack_delay in the
   //   us_tr. Put values 1, 2, and 3 in individual bins called "low[x]",
   //   where "x" is an automatically assigned number (use bins <name>[]).
   //   Place values 4-8 together in one bin called "med", and capture
   //   all other values in a default bin called "high" (use "default" keyword).
	covergroup in_if_cov;
      type_option.merge_instances = 1;

      ack_delay: coverpoint in_tr.ack_delay {
			bins low[] = {1,2,3};
			bins med = {[4:8]};
			bins high = default;
      }
   endgroup


   // TO DO: Create a coverage group called out_if_cov.
   // ---> within this coverage group:
   // - Create a coverpoint called "proceed_delay" on proceed_delay in
   // the ds_tr. Put values 1, 2, and 3 in individual bins called "low[x]",
   // where "x" is an automatically assigned number (use bins <name>[]).
   //   Place values 4-8 together in one bin called "med", and capture
   //   all other values in a default bin called "high" (use "default" keyword).
	covergroup out_if_cov;
		type_option.merge_instances = 1;

		proceed_delay: coverpoint out_tr.proceed_delay {
			bins low[] = {1,2,3};
			bins med = {[4:8]};
			bins high = default;
      }
   endgroup

   // TO DO: Create the class constructor function and
   // instantiate the above three coverage groups
	function new();
      // Allocate memory for the embedded coverage groups. Note that we
      // don't actually create a named instance. We just new() the covergroup
      // directly.
      pkt_cov   = new();
      in_if_cov = new();
      out_if_cov = new();
   endfunction

endclass

class pdm_module_c;
   bit enabled = 0;

   pdm_mod_rec_c in_progress_pkts[$];
   pdm_mod_rec_c completed_pkts[$];

   function void add_in_tr(in_trans_rec_c in_tr);
      // TO DO: Create a new mod_rec variable and fill in its timestamp
		pdm_mod_rec_c	mod_rec = new();
		mod_rec.timestamp = $time;

      if (enabled) begin
         $display("%t pdm_module: Received input TR",$time);

         // TO DO: Add the received input TR to the new mod_rec
			mod_rec.in_tr = in_tr;

         // Push the mod_rec onto the in_progress_pkts queue. In this
         // implementation, we will use the convention that the newest
         // mod_recs are at the front of the queues. Therefore,
         // new mod_recs will be added to the queue with push_front().
			in_progress_pkts.push_front(mod_rec);

      end
   endfunction

   function void add_out_tr(out_trans_rec_c out_tr);
      bit match_found = 0;
      int port_match_idx = 0;
      int i;
      if (enabled) begin
         $display("%t pdm_module: Received output TR",$time);

         // TO DO: Add the received out_tr to the oldest entry
         // in in_progress_pkts[$] whose in_tr.dst_port matches
         // the port in the out_tr
         
         for(i = in_progress_pkts.size()-1; i >=0; i--) begin
         	if(in_progress_pkts[i].in_tr.dst_port == out_tr.port) begin
					in_progress_pkts[i].out_tr = out_tr;
					match_found = 1;
					port_match_idx = i;
					break;
				end
			end
         // Call the check_transmission function to check for discrepancies
         // between the in_tr and out_tr in the mod_rec, which would indicate
         // that the PDM internally corrupted the packet.
         if(match_found) begin
         	check_transmission(in_progress_pkts[port_match_idx]);
         	complete_pkt(port_match_idx);
			end
			else begin
         	$error("%t: No match found", $time, out_tr.port);
         end
         // Call the complete_pkt function, supplying the queue index of
         // the now-complete mod_rec, to gather coverage and move the
         // mod_rec over to a storage queue.
      end
   endfunction

   function void check_transmission(pdm_mod_rec_c mr);
      // TO DO: Check that the dst_port in the in_tr matches the port in the
      // out_tr

		assert (mr.in_tr.dst_port == mr.out_tr.port) else
         $error("%t pdm_module: dst_port mismatch in mod_rec:\n%h",$time,mr);


      // TO DO: Check that the payload in the in_tr matches the payload
      // in the out_tr
		assert (mr.in_tr.payload == mr.out_tr.payload) else
         $error("%t pdm_module: payload mismatch in mod_rec:\n%h",$time,mr);
         
         
      assert (mr.in_tr.payload_size == mr.out_tr.payload_size) else
         $error("%t pdm_module: payload_size mismatch in mod_rec:\n%h",$time,mr);

   endfunction

   function void complete_pkt(int in_progress_q_idx);
      // Pop the completed mod_rec off the in_progress_pkts queue and push it
      // onto the completed_pkts queue. Because we're not necessarily popping
      // off the front or back of the queue, we'll have to copy by index
      // then use the built-in delete function to get the record out of the
      // in_progress_pkts queue.
      completed_pkts.push_front(in_progress_pkts[in_progress_q_idx]);
      in_progress_pkts.delete(in_progress_q_idx);

      // TO DO: Sample all three embedded coverage groups in the completed
      // mod_rec.
      foreach (completed_pkts[i]) begin
      	completed_pkts[i].pkt_cov.sample();
      	completed_pkts[i].in_if_cov.sample();
      	completed_pkts[i].out_if_cov.sample();
      	i++;
      end
      // Print out the number of completed packets
      $display("%t pdm_module: %d completed packets.",$time, completed_pkts.size());
   endfunction

   function void set_enable(bit enable);
      enabled = enable;
      $display("%t pdm_module: Enable state set to %u",$time,enabled);
   endfunction
endclass

