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



   // NOTE: Please use "<=" rather than "=" any time you assign a value to
   // one of the nets in the virtual interface. Will be explained subsequently.

   // TO DO: Write constructor (the "new" function) to pull in
   // the in_intf_if master modport.
   function new (virtual in_intf_if.master ports);
      this.ports <= ports;
   endfunction

   // TO DO: Create an add_drive_pkt function to allow a testcase
   // to drop packets into this driver.

   function void add_drive_pkt(in_td_c td);
      pkts_to_drive.push_back(td);
   endfunction

   // TO DO: Create a drive_pkt task to drive packets according
   // to the PDM input interface protocol.

   task drive_pkt();
      in_td_c   td;
      in_data_t pkt_q[$];
      int       delay_cnt = 0;

      while (1) begin
         @(posedge ports.clk);

         delay_cnt++;
         if ((pkts_to_drive.size() > 0) &&
             (delay_cnt >= pkts_to_drive[$].inter_packet_delay)) begin
            $display("%t in_drvr transmitting a packet!.",$time);
            td = pkts_to_drive.pop_front();
            pkt_q = {};

            // Push packet data into a queue for easy driving
            pkt_q.push_back(td.dst_port);
            pkt_q = {pkt_q[0:$], td.payload};


            foreach (pkt_q[i]) begin
		begin
			ports.data_in = pkt_q[i];
			if((i==0)||(i==(pkt_q.size()-1)))
				ports.bnd_plse = 1;
			else
				ports.bnd_plse = 0;
		end
		@(posedge ports.clk);
            end
            ports.bnd_plse = 0;
            
            ports.data_in = 0;

            delay_cnt = 0;
         end
      end
   endtask

   // TO DO: Create a wait_rst task that waits for an assertion of rst_b

   task wait_rst();
      @(negedge ports.rst_b);
      $display("%t in_drvr detected device reset.", $time);
   endtask
   // TO DO: Create a run task that initializes the outputs and invokes both
   // drive_pkt and wait_rst, similar to the run task in the SBIU us_drvr

   task run();
      $display("%t in_drvr running.",$time);

      while (1) begin
         // Initialize all outputs low
         ports.bnd_plse = 0;
         ports.data_in <= 0;

         @(posedge ports.rst_b)
         fork
            drive_pkt();
            wait_rst();
         join_any
         disable fork;
      end
   endtask

endclass

