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
      //TO DO: Capture and return the raw signals currently on the interface
      in_raw_sigs_s rs;
		
		rs.bnd_plse = ports.bnd_plse;
		rs.data_in = ports.data_in;
		rs.ack = ports.ack;
      return rs;
   endfunction

   function void analyze_pkt(ref in_trans_rec_c tr, ref in_raw_sigs_s rs[$]);
      // HINT: Add any local variables that will help in your packet analysis
		int cnt;
		int ack_delay_count;
		cnt = 0;
      // TO DO: Fill in the TR's destination port and payload fields
      tr.dst_port = rs.pop_front().data_in;
      while(!rs[0].bnd_plse) begin
        tr.payload.push_back(rs.pop_front().data_in);
        cnt++;
      end

      tr.payload.push_back(rs.pop_front().data_in);
      cnt++;

      // TO DO: Fill in the TR payload size
		tr.payload_size = cnt; 

      // TO DO: Check for valid packet length
      assert (tr.payload_size inside {4,8,12,16}) else begin
         $error("%t in_mon: Invalid packet length %d in TR:",$time,tr.payload_size);
         $display("%h",tr);
      end

      // TO DO: Determine the ACK delay, fill in the TR field
		ack_delay_count = 0;
		while(!rs[0].ack) begin
			ack_delay_count++;
			rs.pop_front();
		end
		ack_delay_count++;
		rs.pop_front();
      
      
      tr.ack_delay = ack_delay_count;

      // TO DO: Check that the ACK delay did not exceed 4 cycles
      assert (tr.ack_delay <=4) else begin
         $error("%t in_mon: Invalid ack_delay %u in TR:",$time,tr.ack_delay);
         $display("%h",tr);
      end

      // TO DO: Check that ACK was only asserted for one cycle
      
      
      assert (rs.size() == 0) else begin
         $error("in_mon: ack assert more than one cycle");
      end
      
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

      // TO DO: Capture and push the raw signals into rs[$] until ACK is asserted
      // AND deasserted

      while(ports.ack == 1) begin
         rs.push_back(capture_sigs());
         @(posedge ports.clk);
      end

		while(ports.ack == 0) begin
			rs.push_back(capture_sigs());
			@(posedge ports.clk);
		end

		while(ports.ack == 1) begin
			rs.push_back(capture_sigs());
			@(posedge ports.clk);
		end
    

      analyze_pkt(tr,rs);
      $display("%t in_mon: Produced new input trans rec",$time);
      $display("%h",tr);
      new_trans_rec(tr);            
   endtask

   task wait_pkt_start();
      // NOTE: This task has already been completed for you. It handles
      // the gotcha that BND_PLSE can go high for the start of a new
      // packet on the same clock that ACK goes low for the previous
      // packet. That is why a separate process (rcv_pkt()) is spawned
      // off to actually record each packet.

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

