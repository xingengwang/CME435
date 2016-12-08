`ifndef IN_TYPES
   `define IS_TYPES
   `include "in_intf/in_types.sv"
`endif

class in_trans_rec_c;
   time       timestamp;
   in_data_t  dst_port;
   in_data_t  payload[$];
   int        payload_size;
   int        ack_delay;
endclass

typedef struct {
   bit       bnd_plse;
   in_data_t data_in;
   bit       ack;
} in_raw_sigs_s;

class in_mon_c;
   virtual in_intf_if ports;

   function new (virtual in_intf_if ports);
      this.ports = ports;
   endfunction

   // This function returns a record of the current state of the input
   // interface signals
   function in_raw_sigs_s capture_sigs();
      in_raw_sigs_s rs;

      rs.bnd_plse = ports.bnd_plse;
      rs.data_in  = ports.data_in;
      rs.ack      = ports.ack;

      return rs;
   endfunction

   function void analyze_pkt(ref in_trans_rec_c tr, ref in_raw_sigs_s rs[$]);
      int bnd_high_cnt;
      int end_bnd_high_idx;
      int ack_high_idx;

      // Fill in the TR's destination port and payload fields
      foreach (rs[i]) begin
         if (i == 0)
            tr.dst_port = rs[i].data_in;
         else
            tr.payload.push_back(rs[i].data_in);

         // Is this the last packet byte?
         if (rs[i].bnd_plse == 1 && i != 0)
            break;
      end

      // Easy to fill in the payload size
      tr.payload_size = tr.payload.size();

      // Check for valid packet length
      assert (tr.payload_size <= 16 && (tr.payload_size % 4) == 0) else begin
         $error("%t in_mon: Invalid packet length %u in TR:",$time, tr.payload_size);
         $display("%h",tr);
      end

      // Determine the ACK delay
      bnd_high_cnt = 0;
      foreach (rs[i]) begin
         if (rs[i].bnd_plse == 1) begin
            bnd_high_cnt++;

            if (bnd_high_cnt == 2)
               end_bnd_high_idx = i;
         end
      end

      foreach (rs[i]) begin
         if (rs[i].ack == 1) begin
            ack_high_idx = i;
            break;
         end
      end
      tr.ack_delay = ack_high_idx - end_bnd_high_idx;

      // Check that the ACK delay did not exceed 4 cycles
      assert (tr.ack_delay <= 4) else begin
         $error("%t in_mon: ACK delay exceed 4 cycles in TR:",$time);
         $display("%h",tr);
      end

      // Check that ACK was only asserted for one cycle
      assert (rs[ack_high_idx+1].ack == 0) else
         $error("%t in_mon: ACK asserted for more than one cycle.",$time);
   endfunction

   virtual function void new_trans_rec(in_trans_rec_c tr);
      // This function will be extended in a class inherited from in_mon_c
      // in order to pass the monitor's transaction records to another
      // component such as a module component
   endfunction

   task rcv_pkt();
      in_trans_rec_c tr;
      in_raw_sigs_s  rs[$];

      tr = new();
      rs = {};
      tr.timestamp = $time;

      do begin
         rs.push_back(capture_sigs());
         @(posedge ports.clk);
      end while (ports.bnd_plse != 1);

      // Capture the last data byte, asserted coincident with
      // the second assertion of BND_PLSE
      rs.push_back(capture_sigs());

      // Keep capturing raw sigs until ACK is asserted and deasserted
      do begin
         @(posedge ports.clk);
         rs.push_back(capture_sigs());
      end while (ports.ack != 1);

      do begin
         @(posedge ports.clk);
         rs.push_back(capture_sigs());
      end while (ports.ack != 0);

      analyze_pkt(tr,rs);
      $display("%t in_mon: Produced new input trans rec",$time);
      $display("%h",tr);
      new_trans_rec(tr);            
   endtask

   task wait_pkt_start();
      while (1) begin
         @(posedge ports.clk);

         // Wait for the start of a packet
         if (ports.bnd_plse == 1) begin
            // Record the packet in a separate thread
            fork
               rcv_pkt();
            join_none

            // Wait for the packet to end
            do begin
               @(posedge ports.clk);
            end while (ports.bnd_plse != 1);
         end
      end
   endtask

   task wait_rst();
      @(negedge ports.rst_b);
      $display("%t in_mon detected device reset.", $time);
   endtask

   task run();
      $display("%t in_mon running.",$time);

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

