`ifndef DS_TYPES
   `define DS_TYPES
   `include "ds_intf/ds_types.sv"
`endif

class ds_trans_rec_c;
   time       timestamp;
   ds_data_t  src_adr;
   ds_data_t  dst_adr;
   ds_data_t  pkt_type;
   ds_data_t  csum;
   ds_data_t  data[$];
   int        bus_gnt_latency;
   int        wait_asserts[$];
   int        wait_durs[$];
endclass

typedef struct {
   bit        bus_req;
   bit        bus_gnt;
   bit        wait_sig;
   bit        valid;
   ds_data_t  src_adr_out;
   ds_data_t  dst_adr_out;
   ds_data_t  data_out;
} ds_raw_sigs_s;

class ds_mon_c;
   virtual ds_intf_if ports;

   function new (virtual ds_intf_if ports);
      this.ports = ports;
   endfunction

   // This function returns a record of the current state of the downstream
   // interface signals
   function ds_raw_sigs_s capture_sigs();
      ds_raw_sigs_s rs;

      rs.bus_req     = ports.bus_req;
      rs.bus_gnt     = ports.bus_gnt;
      rs.wait_sig    = ports.wait_sig;
      rs.valid       = ports.valid;
      rs.src_adr_out = ports.src_adr_out;
      rs.dst_adr_out = ports.dst_adr_out;
      rs.data_out    = ports.data_out;

      return rs;
   endfunction

   // This function performs protocol checks on the raw signals record and
   // fills in the transaction record based on what was observed
   // NOTE that this function does not currently provide a complete check
   // of the downstream interface protocol
   function void analyze_pkt(ref ds_trans_rec_c tr, ref ds_raw_sigs_s rs[$]);
      int cnt;
      int bus_gnt_assert_idx;
      int valid_assert_idx;

      // Copy the source, desination address to the TR
      tr.src_adr = rs[0].src_adr_out;
      tr.dst_adr = rs[0].dst_adr_out;

      // Copy the packet type, checksum, and data to the TR
      cnt = 0;
      foreach (rs[i]) begin
         if (rs[i].valid == 1) begin
            if (cnt == 0)
               tr.pkt_type = rs[i].data_out;
            else if (cnt == 1)
               tr.csum = rs[i].data_out;
            else
               tr.data.push_back(rs[i].data_out);

            cnt++;
         end
      end

      // Determine the BUS_GNT latency
      cnt = 0;
      foreach (rs[i]) begin
         if (rs[i].bus_gnt != 1)
            cnt++;
         else begin
            tr.bus_gnt_latency = cnt;
            break;
         end
      end

      // Find the wait assertions and their durations
      cnt = 0;
      for (int i=1; i<rs.size(); i++) begin
         if (rs[i-1].wait_sig == 0 && rs[i].wait_sig == 1)
            tr.wait_asserts.push_back(i);
         else if (rs[i-1].wait_sig == 1 && rs[i].wait_sig == 0)
            tr.wait_durs.push_back(i-tr.wait_asserts[$]);
      end

      // Check that VALID was not asserted before BUS_GNT was asserted
      foreach (rs[i]) begin
         if (rs[i].bus_gnt == 1) begin
            bus_gnt_assert_idx = i;
            break;
         end
      end

      foreach (rs[i]) begin
         if (rs[i].valid == 1) begin
            valid_assert_idx = i;
            break;
         end
      end

      assert (bus_gnt_assert_idx < valid_assert_idx) else
         $error("%t ds_mon: VALID asserted before BUS_GNT asserted.",$time);

      // Check that VALID always deasserted one cycle after WAIT asserted
      foreach (rs[i]) begin
         if (rs[i].wait_sig == 1 && (i+1) < rs.size())
            assert (rs[i+1].valid == 0) else
               $error("%t ds_mon: VALID failed to deassert one cycle after WAIT assertion",$time);
      end

      // Check that SRC_ADR_OUT remained asserted for the duration of
      // the packet transfer
      foreach (rs[i]) begin
         assert (rs[i].src_adr_out == rs[0].src_adr_out) else begin
            $error("%t ds_mon: SRC_ADR_OUT deasserted mid-packet.",$time);
            break;
         end
      end

      // Check that DST_ADR_OUT remained asserted for the duration of
      // the packet transfer
      foreach (rs[i]) begin
         assert (rs[i].dst_adr_out == rs[0].dst_adr_out) else begin
            $error("%t ds_mon: DST_ADR_OUT deasserted mid-packet.",$time);
            break;
         end
      end
   endfunction

   virtual function void new_trans_rec(ds_trans_rec_c tr);
      // This function will be extended in a class inherited from ds_mon_c
      // in order to pass the monitor's transaction records to another
      // component such as a module component
   endfunction

   // This task creates a record of a packet driven on the downstream interface,
   // then calls the appropriate functions to analyze the packet and pass it
   // out to any connected device (such as a module component)
   task rcv_pkt();
      ds_trans_rec_c tr = new();
      ds_raw_sigs_s  rs[$];

      // Record the time at which the packet started
      tr.timestamp = $time;

      // Capture the interface signals on every clock cycle until
      // the packet is complete
      while (ports.bus_req == 1) begin
         rs.push_back(capture_sigs());
         @(posedge ports.clk);
      end

      analyze_pkt(tr,rs);
      $display("%t ds_mon: Produced new downstream trans rec",$time);
      $display("%h",tr);
      new_trans_rec(tr);
   endtask

   // This task waits for a downstream packet transfer to start, and checks
   // that BUS_GNT and WAIT are low one cycle after BUS_REQ goes low
   task wait_pkt_start();
      bit bus_req_last_cycle = 0;

      while (1) begin
         @(posedge ports.clk);

         // If BUS_REQ is currently 1 and was 0 on the last cycle, then
         // BUS_REQ has just been asserted
         if (ports.bus_req == 1 && bus_req_last_cycle == 0) begin

            // The rcv_pkt task is spawned off as a separate process so
            // that the task we're currently in can continue monitoring
            // BUS_REQ, BUS_GNT, and WAIT on each clock cycle
            fork
               rcv_pkt();
            join_none
         end
         // Check that BUS_GNT and WAIT are low on any clock cycle subsequent
         // to a cycle on which BUS_REQ was low
         else if (bus_req_last_cycle == 0) begin
            assert (ports.bus_gnt == 0) else
               $error("%t ds_mon: BUS_GNT high more than 1 cycle after BUS_GNT low.",$time);

            assert (ports.wait_sig == 0) else
               $error("%t ds_mon: WAIT high more than 1 cycle after BUS_GNT low.",$time);
         end

         // Update the "value on last clock cycle" variables
         bus_req_last_cycle   = ports.bus_req;
      end
   endtask

   task wait_rst();
      @(negedge ports.rst_b);
      $display("%t ds_mon detected device reset.", $time);
   endtask

   task run();
      $display("%t ds_mon running.",$time);

      while (1) begin
         @(posedge ports.rst_b)
         fork
            wait_pkt_start();
            wait_rst();
         join_any
         disable fork;
      end
   endtask
endclass

