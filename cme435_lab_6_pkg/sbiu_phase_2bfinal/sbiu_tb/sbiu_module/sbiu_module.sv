`ifndef US_MON
   `define US_MON
   `include "us_intf/us_mon.sv"
`endif

`ifndef DS_MON
   `define DS_MON
   `include "ds_intf/ds_mon.sv"
`endif

class sbiu_mod_rec_c;
   time           timestamp;

   us_trans_rec_c us_tr;
   ds_trans_rec_c ds_tr;

   // Coverage group intended for packets with invalid checksums only. We
   // could put a guard condition (iff (!us_tr.csum_status)) on each
   // coverpoint, or just ensure that we only call sample() on this
   // covergroup when the packet has an invalid checksum. We have done
   // both in this assignment solution.
   covergroup cov_bad_csum_pkt;
      // Cover src_adr with no bins specification
      cp_src_adr: coverpoint us_tr.src_adr iff (!us_tr.csum_status);

      // Cover dst_adr, spread evenly over 16 bins
      cp_dst_adr: coverpoint us_tr.dst_adr iff (!us_tr.csum_status) {
         bins dst_adr_16[16] = {['h00:'hFF]};
      }

      // Cover pkt_type, ignoring values outside the range 0:2
      cp_pkt_type: coverpoint us_tr.pkt_type iff (us_tr.csum_status) {
         ignore_bins ignore_vals = {[3:255]};
      }

      // Cover csum, with a single bin for the 0 value, a single bin for
      // the 0xFF value, and all other values gathered in a default bin.
      cp_csum: coverpoint us_tr.csum iff (!us_tr.csum_status) {
         bins val_0x00 = {'h00};
         bins val_0xFF = {'hFF};
         bins others   = default;
      }

      // Cover payload size, with sizes 0:10 each in their own bin, then
      // capture the ranges 11:15, 16:20, 21:27, 28 each in their own bin.
      // We're covering the data.size() directly, but we could also add
      // a variable to this class for the purpose of covering payload size.
      cp_payload_sz: coverpoint us_tr.data.size() iff (!us_tr.csum_status) {
         bins a[] = {[ 0:10]};
         bins b   = {[11:15]};
         bins c   = {[16:20]};
         bins d   = {[21:27]};
         bins e   = {28};
      }

      // Cover number of RDY deassertions, with values 1 through 4 each
      // in their own bin, and all other values captured in a default bin.
      cp_rdy_low: coverpoint us_tr.rdy_deasserts.size() iff (!us_tr.csum_status) {
         bins low_count[] = {[1:4]};
         bins others      = default;
      }
   endgroup

   // Coverage group intended for packets with valid checksums only. We
   // could put a guard condition (iff (us_tr.csum_status)) on each
   // coverpoint, or just ensure that we only call sample() on this
   // covergroup when the packet has a valid checksum. We have done
   // both in this assignment solution.
   covergroup cov_valid_csum_pkt;
      // Cover all values of src_adr, spread evenly over 16 bins
      cp_src_adr: coverpoint us_tr.src_adr iff (us_tr.csum_status) {
         bins src_adr_16[16] = {['h00:'hFF]};
      }

      // Cover all values of dst_adr, with each value in its own bin.
      cp_dst_adr: coverpoint us_tr.dst_adr iff (us_tr.csum_status) {
         bins dst_adr_individual[] = {['h00:'hFF]};
      }

      // Cover pkt_type, ignoring values outside the range 0:2
      cp_pkt_type: coverpoint us_tr.pkt_type iff (us_tr.csum_status) {
         ignore_bins ignore_vals = {[3:255]};
      }

      // Cross the src_adr, dst_adr, and pkt_type coverpoints, selecting
      // cases where src_adr is in the range 50:75 and dst_adr is in the
      // range 240:255.
      src_x_dst_x_type: cross cp_src_adr, cp_dst_adr, cp_pkt_type
         iff (us_tr.csum_status) {
         bins selective_cross = 
            binsof(cp_src_adr) intersect {[50:75]} &&
            binsof(cp_dst_adr) intersect {[240:255]};
      }
   endgroup

   function new();
      // Allocate memory for the embedded coverage groups. Note that we
      // don't actually create a named instance. We just new() the covergroup
      // directly.
      cov_bad_csum_pkt   = new();
      cov_valid_csum_pkt = new();
   endfunction
endclass

class sbiu_module_c;
   bit enabled = 0;

   sbiu_mod_rec_c in_progress_pkts[$];
   sbiu_mod_rec_c completed_pkts[$];

   function void add_us_tr(us_trans_rec_c us_tr);
      // New mod_rec variable
      sbiu_mod_rec_c new_mod_rec = new();
      new_mod_rec.timestamp      = $time;

      if (enabled) begin
         $display("%t sbiu_module: Received upstream TR",$time);

         // Add the received upstream TR to the new mod_rec
         new_mod_rec.us_tr = us_tr;

         // Push the mod_rec onto the in_progress_pkts queue. In this
         // implementation, we will use the convention that the newest
         // mod_recs are at the front (head) of the queues. Therefore,
         // new mod_recs will be added to the queue with push_front().
         in_progress_pkts.push_front(new_mod_rec);

         // If the packet for which we just created a new mod_rec has
         // a valid checksum, we'll take no further action because we
         // need to wait for a corresponding downstream TR to arrive
         // before the mod_rec, representing an end-to-end packet
         // transmission through the SBIU, is complete.
         //
         // If the packet's checksum is invalid, however, we need to
         // call the completion function on the mod_rec right here
         // because we won't be waiting for a corresponding downstream
         // TR (the SBIU should internally discard the packet).
         if (new_mod_rec.us_tr.csum_status == 0)
            complete_pkt(0); // Calling complete on the mod_rec at
                             // the 0th index in the in_progress_pkts
                             // queue.
      end
   endfunction

   function void add_ds_tr(ds_trans_rec_c ds_tr);
      if (enabled) begin
         $display("%t sbiu_module: Received downstream TR",$time);

         // We just received a downstream TR, and we need to match it to a
         // mod_rec in the in_progress_pkts queue. Because the SBIU always
         // transmits packets out of the downstream interface in the same
         // order that they were received on the upstream interface, this is
         // a simple task: We just add the downstream TR to the oldest mod_rec
         // in the in_progress_pkts queue which, according to our convention,
         // will the the last (tail) entry in the queue.

         // First we'll get fancy and make sure that the in_progress_pkts
         // queue is not empty. Note that this wasn't a requirement of the
         // assignment.
         assert (in_progress_pkts.size() > 0) else
            $error("%t sbiu_module: Received downstream TR when\
                    in_progress_pkts queue empty:\n%h",$time,ds_tr);

         // Add the downstream TR to the oldest "in progress" mod_rec
         in_progress_pkts[$].ds_tr = ds_tr;

         // Call the check_transmission function to check for discrepancies
         // between the us_tr and ds_tr in the mod_rec, which would indicate
         // that the SBIU internally corrupted the packet.
         check_transmission(in_progress_pkts[$]);

         // Call the complete_pkt function, supplying the queue index of
         // the now-complete mod_rec, to gather coverage and move the
         // mod_rec over to a storage queue.
         complete_pkt(in_progress_pkts.size()-1);
      end
   endfunction

   function void check_transmission(sbiu_mod_rec_c mr);
      // The SBIU does not perform any internal data translation. For example,
      // it does not mask off address bits or rearrange payload bytes.
      // Packets that go into upstream interface are supposed to come out of
      // the downstream interface exactly the same. The check for data
      // corruption is therefore simple. We just compare the fields of the
      // upstream TR straight across to the fields of the downstream TR. Note
      // that we only compare the fields that represent the actual packet
      // data: src_adr, dst_adr, pkt_type, csum, and data. We don't compare
      // fields like rdy_low_durs, because that's just interface-specific
      // information for coverage purposes.
      assert (mr.us_tr.src_adr == mr.ds_tr.src_adr) else
         $error("%t sbiu_module: src_adr mismatch in mod_rec:\n%h",$time,mr);

      assert (mr.us_tr.dst_adr == mr.ds_tr.dst_adr) else
         $error("%t sbiu_module: dst_adr mismatch in mod_rec:\n%h",$time,mr);

      assert (mr.us_tr.pkt_type == mr.ds_tr.pkt_type) else
         $error("%t sbiu_module: pkt_type mismatch in mod_rec:\n%h",$time,mr);

      assert (mr.us_tr.csum == mr.ds_tr.csum) else
         $error("%t sbiu_module: csum mismatch in mod_rec:\n%h",$time,mr);

      assert (mr.us_tr.data == mr.ds_tr.data) else
         $error("%t sbiu_module: data mismatch in mod_rec:\n%h",$time,mr);
   endfunction

   // Variables used to facilitate coverage
   int          num_rdy_deasserts;
   bit          csum_status;
   us_data_t    pkt_type;
   int          rdy_deassert_dur;

   // Add coverage groups to the module component class itself
   covergroup cov_num_rdy_deassert;
      // Cover number of RDY deasserts, with values 0 through 4 each in
      // their own bin and all other values captured in a default bin.
      cp_num_rdy_deasserts: coverpoint num_rdy_deasserts {
         bins low_counts[] = {[0:4]};
         bins others       = default;
      }

      // Cover the csum_status.
      cp_csum_status: coverpoint csum_status;

      // Cover the pkt_type, ignoring values outside the range 0:2
      cp_pkt_type: coverpoint pkt_type {
         bins ptype[] = {[0:2]};
         ignore_bins ignore_vals = {[3:255]};
      }

      // Cross the number of RDY deasserts, csum_status, and pkt_type
      // coverpoints, ignoring rdy_deasserts > 3 when the pkt_type is 2.
      rdylow_x_csumstat_x_ptype:
         cross cp_num_rdy_deasserts, cp_csum_status, cp_pkt_type {
         ignore_bins selective_bins =
            binsof(cp_num_rdy_deasserts) intersect {[4:65535]} &&
            binsof(cp_pkt_type)          intersect {2};
         }
      
      /*
         // Apparently Questa doesn't support the $ notation in a bin,
         // but the following is the ideal approach.
         cross cp_num_rdy_deasserts, cp_csum_status, cp_pkt_type {
         bins selective_bins =
            !binsof(cp_num_rdy_deasserts) intersect {[4:$]} &&
            !binsof(cp_pkt_type)          intersect {2};
         }
      */
/*
         // Here's a messier approach that will compile in Questa:
         cross cp_num_rdy_deasserts, cp_csum_status, cp_pkt_type {
            bins selective_bins =
               (
                binsof(cp_num_rdy_deasserts) intersect {[0:2]} &&
                binsof(cp_pkt_type)              intersect {2}
               )
               ||
               (
                !binsof(cp_pkt_type)             intersect {2}
               );
      }
*/
   endgroup

   covergroup cov_rdy_deassert_durs;
      cp_rdy_deassert_dur: coverpoint rdy_deassert_dur;
   endgroup

   // Remember to new() the covergroups in this class
   function new();
      cov_num_rdy_deassert  = new();
      cov_rdy_deassert_durs = new();
   endfunction

   function void complete_pkt(int in_progress_q_idx);
      // TO DO: Add sampling of appropriate coverage groups. Pop completed
      //        mod_rec off the in_progress_pkts queue and push it onto
      //        the completed_pkts queue. Print the size of the completed_pkts
      //        queue.

      // Copy the completed mod_rec to a temporary object so we don't have
      // to repeatedly type the long queue and index names.
      sbiu_mod_rec_c temp_mr;
      temp_mr = in_progress_pkts[in_progress_q_idx];

      // Sample the appropriate embedded coverage group in the mod_rec,
      // depending on whether or not the checksum is valid
      if (temp_mr.us_tr.csum_status == 0)
         temp_mr.cov_bad_csum_pkt.sample();
      else
         temp_mr.cov_valid_csum_pkt.sample();

      // Sample the module component's cov_num_rdy_deassert covergroup. Note
      // that we have to first copy values from the mod_rec to the local
      // coverage-facilitating variables as follows:
      num_rdy_deasserts = temp_mr.us_tr.rdy_deasserts.size();
      csum_status       = temp_mr.us_tr.csum_status;
      pkt_type          = temp_mr.us_tr.pkt_type;
      cov_num_rdy_deassert.sample();

      // Sample the module component's cov_rdy_deassert_durs covergroup. Note
      // the we have to loop through each value in the us_tr's
      // rdy_low_durs queue, copy it to the local coverage-faciliting variable,
      // then sample coverage as follows:
      for (int i=0; i<temp_mr.us_tr.rdy_low_durs.size(); i++) begin
         rdy_deassert_dur = temp_mr.us_tr.rdy_low_durs[i];
         cov_rdy_deassert_durs.sample();
      end

      // Pop the completed mod_rec off the in_progress_pkts queue and push it
      // onto the completed_pkts queue. Because we're not necessarily popping
      // off the front or back of the queue, we'll have to copy by index
      // then use the built-in delete function to get the record out of the
      // in_progress_pkts queue.
      completed_pkts.push_front(in_progress_pkts[in_progress_q_idx]);
      in_progress_pkts.delete(in_progress_q_idx);

      // Print out the number of completed packets
      $display("%t sbiu_module: %d completed packets.",$time,
               completed_pkts.size());
   endfunction

   function void set_enable(bit enable);
      enabled = enable;
      $display("%t sbiu_module: Enable state set to %u",$time,enabled);
   endfunction
endclass

