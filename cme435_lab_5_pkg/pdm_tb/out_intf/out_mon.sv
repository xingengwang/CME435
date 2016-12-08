`ifndef OUT_TYPES
   `define OUT_TYPES
   `include "out_intf/out_types.sv"
`endif

class out_trans_rec_c;
   time       timestamp;
   int        port;
   out_data_t payload[$];
   int        payload_size;
   int        proceed_delay;
endclass

typedef struct {
   out_len_t  newdata_len;
   out_data_t data_out;
   bit        proceed;
} out_raw_sigs_s;

class out_mon_c;
   virtual out_intf_if ports;
   int     out_mon_inst_num;

   function new (virtual out_intf_if ports, int inst_num);
      this.ports = ports;
      this.out_mon_inst_num = inst_num;
   endfunction

   // This function returns a record of the current state of the output
   // interface signals
   function out_raw_sigs_s capture_sigs();
      // TO DO: Capture and return the raw signals on the interface
      out_raw_sigs_s rs;
      
      rs.newdata_len     = ports.newdata_len;
      rs.data_out     = ports.data_out;
      rs.proceed    = ports.proceed;
      
      return rs;
   endfunction

   function void analyze_pkt(ref out_trans_rec_c tr, ref out_raw_sigs_s rs[$]);
      // HINT: Add any local variables that will help in the packet analysis
		int cnt;
		int cnt_proceed;
		cnt_proceed =0;
		//out_raw_sigs_s temp[$] =rs;
      // TO DO: Fill in the TR's port with the monitor instance
      tr.port = this.out_mon_inst_num;

     
      cnt = 0;
      
      while(rs[0].proceed == 0)
      begin
        cnt++;
        rs.pop_front();
      end
      rs.pop_front();
		tr.proceed_delay =cnt;
 		// TO DO: Check that the PROCEED delay did not exceed 4 cycles
      assert (tr.proceed_delay inside {0,1,2,3,4}) else
               $error("%t out_mon: Illegal proceed_delay %d.",$time ,tr.proceed_delay );
      // TO DO: Check that PROCEED was only asserted for one cycle
		assert (rs[0].proceed == 0) else
               $error("%t out_mon: PROCEED asserted more than one cycle %d.",$time,cnt_proceed );

		// TO DO: Fill in the TR's payload field
		rs.pop_front();
      while(rs.size() > 0)
      begin
			tr.payload.push_back(rs.pop_front().data_out);
      end
		tr.payload_size = tr.payload.size();
      // TO DO: Check for valid packet length (4,8,12,16 only)
		assert (tr.payload_size inside {4,8,12,16}) else
               $error("%t out_mon: Illegal payload size %d.",$time ,tr.payload_size );
   endfunction

   virtual function void new_trans_rec(out_trans_rec_c tr);
      // This function will be extended in a class inherited from out_mon_c
      // in order to pass the monitor's transaction records to another
      // component such as a module component
   endfunction

   task rcv_pkts();
      out_trans_rec_c tr;
      out_raw_sigs_s  rs[$];
      int capture_len;
      int cnt=0;
      int begin_c=0;
      int proceed_h=0;

      while (1) begin
         @(posedge ports.clk);

         // TO DO: Capture the raw sigs for the packet, starting with
         // NEWDATA_LEN !=0, ending after the number of bytes specified
         // by NEWDATA_LEN have been driven out
         if (ports.newdata_len != 0) begin
            tr = new();
            rs = {};
            tr.timestamp = $time; 
            

            // FILL IN THE REST HERE
            capture_len = ports.newdata_len;
				while(cnt<capture_len)
				begin
					rs.push_back(capture_sigs());
					if(begin_c) begin	
						cnt++;
					end
					
					if(proceed_h) begin
						begin_c=1;
					end
					
					if(ports.proceed)
					begin
						proceed_h=1;
					end

					@(posedge ports.clk);
				end				
			
				
            analyze_pkt(tr,rs);
            $display("%t out_mon %p: Produced new output trans rec",$time, out_mon_inst_num);
            $display("%h",tr);
            new_trans_rec(tr);            
         end
      end

   endtask

   task wait_rst();
      @(negedge ports.rst_b);
      $display("%t out_mon %p detected device reset.", $time, out_mon_inst_num);
   endtask

   task run();
      $display("%t out_mon %p running.",$time, out_mon_inst_num);

      while (1) begin
         @(posedge ports.rst_b)
         fork
            rcv_pkts();
            wait_rst();
         join_any
         disable fork;
      end
   endtask
endclass

