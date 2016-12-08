`ifndef US_TYPES
   `define US_TYPES
   `include "us_intf/us_types.sv"
`endif

class us_trans_rec_c;
   time       timestamp;
   us_data_t  src_adr;
   us_data_t  dst_adr;
   us_data_t  pkt_type;
   us_data_t  csum;
   us_data_t  data[$];
   bit        csum_status;
   int        rdy_deasserts[$];
   int        rdy_low_durs[$];
endclass

typedef struct {
   bit       rdy;
   bit       frame;
   us_data_t adr_data;
} us_raw_sigs_s;

class us_mon_c;
   virtual us_intf_if ports;

   function new (virtual us_intf_if ports);
      this.ports = ports;
   endfunction

   task check_rdy_delay();
      int rdy_delay_cnt;

      rdy_delay_cnt = 0;
      @(posedge ports.clk);

      while (ports.rdy != 1) begin
         @(posedge ports.clk);
         rdy_delay_cnt++;

         assert (rdy_delay_cnt <= 3) else begin
            $error("%t us_mon: Post-reset RDY delay exceeded 3 cycles!:",$time);
         end
      end

      while (1) begin
         @(posedge ports.clk);
      end
   endtask

   task check_frame_against_rdy();
      while (1) begin
         @(posedge ports.clk);
         if (ports.frame == 1) begin
            assert (ports.rdy == 1) else begin
               $error("%t us_mon: FRAME asserted when RDY low",$time);
            end            
         end

         do begin
            @(posedge ports.clk);
         end while (ports.frame == 1);
      end
   endtask

   // This function returns a record of the current state of the upstream
   // interface signals
   function us_raw_sigs_s capture_sigs();
      us_raw_sigs_s rs;

      rs.rdy      = ports.rdy;
      rs.frame    = ports.frame;
      rs.adr_data = ports.adr_data;

      return rs;
   endfunction

   // Given a queue of raw sigs recs representing a complete upstream
   // packet transfer, this function returns an indication of whether
   // the packet checksum is valid.
   function bit is_csum_valid(us_raw_sigs_s rs[$]);
      us_data_t csum = 0;

      // Compute the modulo-2 sum of the packet bytes, excluding the fourth
      // (checksum) byte
      foreach (rs[i]) begin
         if (i == 3)
            continue;

         csum += rs[i].adr_data;
      end

      // Invert the checksum (one's complement)
      csum = ~csum;

      // Compare the computed checksum to the checksum in the packet,
      // and set the return value accordingly
      if (csum == rs[3].adr_data)
         return 1;
      else
         return 0;
   endfunction

   function void analyze_pkt(ref us_trans_rec_c tr, ref us_raw_sigs_s rs[$]);
      int cnt;

      // Copy the packet bytes to the appropriate fields in the TR
      cnt = 0;
      foreach (rs[i]) begin
         case(cnt)
            0:       tr.src_adr  = rs[i].adr_data;
            1:       tr.dst_adr  = rs[i].adr_data;
            2:       tr.pkt_type = rs[i].adr_data;
            3:       tr.csum     = rs[i].adr_data;
            default: tr.data.push_back(rs[i].adr_data);
         endcase
         cnt++;
      end

      // Determine whether the packet's checksum is valid
      tr.csum_status = is_csum_valid(rs);

      // Find the RDY deassertions and their durations
      // Start by checking the special case where RDY goes low
      // coincident with FRAME being asserted high (i.e. RDY
      // is low in the first raw sigs rec).
      if (rs[0].rdy == 0)
         tr.rdy_deasserts.push_back(0);

      for (int i=1; i<rs.size(); i++) begin
         if (rs[i-1].rdy == 1 && rs[i].rdy == 0)
            tr.rdy_deasserts.push_back(i);
         else if (rs[i-1].rdy == 0 && rs[i].rdy == 1)
            tr.rdy_low_durs.push_back(i-tr.rdy_deasserts[$]);
      end

      // Check that the packet type is valid
      assert (tr.pkt_type inside {[0:2]}) else begin
         $error("%t us_mon: Invalid packet type %u in TR:",$time,tr.pkt_type);
         $display("%h",tr);
      end

      // Check that the payload size is valid for the packet type
      assert (((tr.pkt_type == 0) && (tr.data.size() inside {[0:28]})) ||
              ((tr.pkt_type == 1) && (tr.data.size() == 2))            ||
              ((tr.pkt_type == 2) && (tr.data.size() == 0))) else begin
         $error("%t us_mon: Illegal payload size %u in TR:",$time,tr.data.size());
         $display("%h",tr);
      end
   endfunction

   virtual function void new_trans_rec(us_trans_rec_c tr);
      // This function will be extended in a class inherited from us_mon_c
      // in order to pass the monitor's transaction records to another
      // component such as a module component
   endfunction

   task rcv_pkts();
      us_trans_rec_c tr;
      us_raw_sigs_s  rs[$];

      while (1) begin
         @(posedge ports.clk);
         if (ports.frame == 1) begin

            tr = new();
            rs = {};
            tr.timestamp = $time;

            while (ports.frame == 1) begin
               rs.push_back(capture_sigs());
               @(posedge ports.clk);
            end

            analyze_pkt(tr,rs);
            $display("%t us_mon: Produced new upstream trans rec",$time);
            $display("%h",tr);
            new_trans_rec(tr);            
         end
      end
   endtask

   task wait_rst();
      @(negedge ports.rst_b);
      $display("%t us_mon detected device reset.", $time);
   endtask

   task run();
      $display("%t us_mon running.",$time);

      while (1) begin
         @(posedge ports.rst_b)
         fork
            check_rdy_delay();
            check_frame_against_rdy();
            rcv_pkts();
            wait_rst();
         join_any
         disable fork;
      end
   endtask
endclass

