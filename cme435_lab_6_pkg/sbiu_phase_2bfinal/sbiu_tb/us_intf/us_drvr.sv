`ifndef US_TYPES
   `define US_TYPES
   `include "us_intf/us_types.sv"
`endif

class us_td_c;
   rand us_data_t        src_adr;
   rand us_data_t        dst_adr;
   rand us_pkt_type_t    pkt_type;
   rand int              len;
   rand us_data_t        data[];
   rand bit              csum_status;
   rand int              inter_packet_delay;
endclass

class us_drvr_c;
   virtual us_intf_if.master ports;
   us_td_c pkts_to_drive[$];

   function new (virtual us_intf_if.master ports);
      this.ports = ports;
   endfunction

   function void add_drive_pkt(us_td_c td);
      pkts_to_drive.push_back(td);
   endfunction

   function void calc_csum(ref us_data_t pkt_q[$], input bit status);
      us_data_t csum = 0;

      // Compute the modulo-2 sum of the raw packet data
      foreach (pkt_q[i]) begin
         csum += pkt_q[i];
      end

      // Invert the checksum (one's complement)
      csum = ~csum;

      // If the descriptor indicates that the packet is to have
      // a bad checksum, randomly corrupt the checksum. Ensure that
      // a non-zero value is added to the checksum.
      if (status == 0) begin
         csum += $urandom_range(1,255);
      end

      pkt_q.insert(3,csum);
   endfunction

   task drive_pkt();
      us_td_c   td;
      us_data_t pkt_q[$];
      int       delay_cnt = 0;

      while (1) begin
         @(posedge ports.clk);

         delay_cnt++;

         if ((pkts_to_drive.size() > 0) &&
             (delay_cnt >= pkts_to_drive[$].inter_packet_delay)) begin
            td = pkts_to_drive.pop_front();
            pkt_q = {};

            // Push packet data into a queue for easy driving
            pkt_q.push_back(td.src_adr);
            pkt_q.push_back(td.dst_adr);
            pkt_q.push_back(td.pkt_type);
            pkt_q = {pkt_q[0:$], td.data};

            // Insert the checksum into the packet queue
            calc_csum(pkt_q,td.csum_status);

            // Sync up to the clock and wait for RDY
            while (ports.rdy != 1) begin
               @(posedge ports.clk);
            end

            #1;ports.frame = 1;
            foreach (pkt_q[i]) begin
               #1;ports.adr_data = pkt_q[i];
               @(posedge ports.clk);
            end
      
            #1;
            ports.frame    <= 0;
            ports.adr_data <= 0;

            delay_cnt = 0;
         end
      end
   endtask

   task wait_rst();
      @(negedge ports.rst_b);
      $display("%t us_drvr detected device reset.", $time);
   endtask

   task run();
      $display("%t us_drvr running.",$time);

      while (1) begin
         // Initialize all outputs low
         ports.frame    <= 0;
         ports.adr_data <= 0;

         @(posedge ports.rst_b)
         fork
            drive_pkt();
            wait_rst();
         join_any
         disable fork;
      end
   endtask
endclass

