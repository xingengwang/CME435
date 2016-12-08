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
      out_raw_sigs_s rs;

      rs.newdata_len = ports.newdata_len;
      rs.data_out    = ports.data_out;
      rs.proceed     = ports.proceed;

      return rs;
   endfunction

   function void analyze_pkt(ref out_trans_rec_c tr, ref out_raw_sigs_s rs[$]);
      int proceed_assert_idx;

      // Fill in the TR's port with the monitor instance
      tr.port = out_mon_inst_num;

      // Fill in the TR's payload field
      foreach (rs[i]) begin
         if (rs[i].proceed == 1) begin
            proceed_assert_idx = i;
            break;
         end
      end

      for (int i = proceed_assert_idx+1; i<rs.size(); i++) begin
         tr.payload.push_back(rs[i].data_out);
      end

      // Easy to fill in the payload size
      tr.payload_size = tr.payload.size();

      // Check for valid packet length
      assert (tr.payload_size <= 16 && (tr.payload_size % 4) == 0) else begin
         $error("%t out_mon %p: Invalid packet length %u in TR:",$time, out_mon_inst_num, tr.payload_size);
         $display("%h",tr);
      end
      // Determine the PROCEED delay
      foreach (rs[i]) begin
         if (rs[i].proceed == 1) begin
            tr.proceed_delay = i;
            break;
         end
      end

      // Check that the PROCEED delay did not exceed 4 cycles
      assert (tr.proceed_delay <= 4) else begin
         $error("%t out_mon %p: PROCEED delay exceed 4 cycles in TR:",$time, out_mon_inst_num);
         $display("%h",tr);
      end

      // Check that PROCEED was only asserted for one cycle
      assert (rs[tr.proceed_delay+1].proceed == 0) else
         $error("%t out_mon %p: PROCEED asserted for more than one cycle.",$time, out_mon_inst_num);
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

      while (1) begin
         @(posedge ports.clk);

         if (ports.newdata_len != 0) begin
            tr = new();
            rs = {};
            tr.timestamp = $time;         

            rs.push_back(capture_sigs());
            capture_len = ports.newdata_len;

            // Wait for PROCEED to be asserted
            do begin
               @(posedge ports.clk);
               rs.push_back(capture_sigs());
            end while (ports.proceed != 1);

            // Capture the number of packet bytes previously indicated
            // on the NEWDATA_LEN bus
            repeat (capture_len) begin
               @(posedge ports.clk);
               rs.push_back(capture_sigs());
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

