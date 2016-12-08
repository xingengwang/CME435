`ifndef IN_TYPES
   `define IN_TYPES
   `include "in_intf/in_types.sv"
`endif

class in_td_c;
   rand in_data_t        dst_port;
   rand in_data_t        payload[];
   rand int              inter_packet_delay;
endclass

class in_drvr_c;

   virtual in_intf_if.master ports;
   in_td_c pkts_to_drive[$];

   function new (virtual in_intf_if.master ports);
      this.ports = ports;
   endfunction

   function void add_drive_pkt(in_td_c td);
      pkts_to_drive.push_back(td);
   endfunction

   task drive_bnd_plse();
      ports.bnd_plse <= 1;
      @(posedge ports.clk);
      ports.bnd_plse <= 0;
   endtask

   task drive_pkt();
      in_td_c   td;
      in_data_t pkt_q[$];
      int       delay_cnt = 0;

      // Sync up to clock
      @(posedge ports.clk);
      while (1) begin
         delay_cnt++;

         if ((pkts_to_drive.size() > 0) &&
             (delay_cnt >= pkts_to_drive[$].inter_packet_delay)) begin

            td = pkts_to_drive.pop_front();
            pkt_q = {};

            // Push packet data into a queue for easy driving
            pkt_q.push_back(td.dst_port);
            pkt_q = {pkt_q[0:$], td.payload};

            // Frame the start of the packet with a one-cycle assertion of BND_PLSE
            fork
               drive_bnd_plse();
            join_none

            while (pkt_q.size() > 0) begin
               // Assert BND_PLSE for one cycle coincident with the last packet byte
               if (pkt_q.size() == 1) begin
                  fork
                     drive_bnd_plse();
                  join_none
               end

               ports.data_in <= pkt_q.pop_front();
               @(posedge ports.clk);
            end

            ports.data_in <= 0;

            // Wait for ACK to be asserted. Note that it could be asserted
            // now (i.e. the cycle on which BND_PLSE was lowered)
            while (ports.ack != 1) begin
               @(posedge ports.clk);
            end

            delay_cnt = 0;
         end else begin
            @(posedge ports.clk);
         end
      end
   endtask

   task wait_rst();
      @(negedge ports.rst_b);
      $display("%t in_drvr detected device reset.", $time);
   endtask

   task run();
      $display("%t in_drvr running.",$time);

      while (1) begin
         // Initialize all outputs low
         ports.bnd_plse <= 0;
         ports.data_in  <= 0;

         @(posedge ports.rst_b)
         fork
            drive_pkt();
            wait_rst();
         join_any
         disable fork;
      end
   endtask

endclass

