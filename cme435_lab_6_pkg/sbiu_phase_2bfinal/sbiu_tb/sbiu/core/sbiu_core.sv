`timescale 1ns/1ns

module sbiu_core(
   input  wire        clk,
   input  wire        rst_b,

   output logic       rdy,
   input  wire        frame,
   input  wire  [7:0] adr_data,

   output logic       bus_req,
   input  wire        bus_gnt,
   output logic       valid,
   input  wire        wait_sig,
   output logic [7:0] src_adr_out,
   output logic [7:0] dst_adr_out,
   output logic [7:0] data_out
);

   logic [7:0] fifo[$][$];
   logic [7:0] rx_pkt[$];
   logic [7:0] tx_pkt[$];

   int rdy_delay_min       = 3;
   int rdy_delay_max       = 3;
   bit no_bus_gnt_wait     = 0;
   bit ignore_wait         = 0;
   bit src_early_deassert  = 0;
   bit dst_early_deassert  = 0;
   bit src_adr_corruption  = 0;
   bit dst_adr_corruption  = 0;
   bit pkt_type_corruption = 0;
   bit csum_corruption     = 0;
   bit data_corruption     = 0;
   bit drop_good_pkt       = 0;
   bit pass_bad_pkt        = 0;

   function void set_rdy_delay_range(int min, int max);
      rdy_delay_min = min; 
      rdy_delay_max = max;
   endfunction

   function void set_no_bus_gnt_wait(bit val);
      no_bus_gnt_wait = val;
   endfunction

   function void set_ignore_wait(bit val);
      ignore_wait = val;
   endfunction

   function void set_src_early_deassert(bit val);
      src_early_deassert = val;
   endfunction

   function void set_dst_early_deassert(bit val);
      dst_early_deassert = val;
   endfunction

   function void set_src_adr_corruption(bit val);
      src_adr_corruption = val;
   endfunction

   function void set_dst_adr_corruption(bit val);
      dst_adr_corruption = val;
   endfunction

   function void set_pkt_type_corruption(bit val);
      pkt_type_corruption = val;
   endfunction

   function void set_csum_corruption(bit val);
      csum_corruption = val;
   endfunction

   function void set_data_corruption(bit val);
      data_corruption = val;
   endfunction

   function void set_drop_good_pkt(bit val);
      drop_good_pkt = val;
   endfunction

   function void set_pass_bad_pkt(bit val);
      pass_bad_pkt = val;
   endfunction

   function int csum_is_valid(logic [7:0] pkt[$]);
      logic [7:0] csum;

      csum = 0;
      foreach (pkt[i]) begin
         if (i==3)
            continue;

         csum += pkt[i];
      end

      csum = ~csum;

      if (csum == pkt[3])
         return 1;
      else
         return 0;
   endfunction

   task us_rx();
      static int us_state = 0;
      int csum_valid;

      case(us_state)
         0:
         if (frame == 1) begin
            rx_pkt.push_back(adr_data);
            us_state = 1;
         end

         1:
         if (frame == 1) begin
            rx_pkt.push_back(adr_data);
         end else begin
            csum_valid = csum_is_valid(rx_pkt);
            if ((csum_valid  && !drop_good_pkt) ||
                (!csum_valid && pass_bad_pkt))
               fifo.push_back(rx_pkt);
            rx_pkt = {};

            us_state = 0;
         end
      endcase
   endtask

   task ds_tx();
      static int ds_state = 0;
      static int pkt_idx;

      case(ds_state)
         0:
         if (fifo.size() > 0) begin
            tx_pkt = fifo.pop_front();

            #1;
            bus_req     <= 1;
            if (src_adr_corruption)
               src_adr_out <= (tx_pkt.pop_front() + 1);
            else
               src_adr_out <= tx_pkt.pop_front();

            if (dst_adr_corruption)
               dst_adr_out <= (tx_pkt.pop_front() + 1);
            else
               dst_adr_out <= tx_pkt.pop_front();

            pkt_idx  = 2;
            ds_state = 1;
         end

         1:
         if ((bus_gnt == 1  || no_bus_gnt_wait) &&
             (wait_sig == 0 || ignore_wait)) begin
            #1;
            valid    <= 1;
            if ((pkt_idx == 2 && pkt_type_corruption) ||
                (pkt_idx == 3 && csum_corruption)     ||
                (pkt_idx >  3 && data_corruption))
               data_out <= (tx_pkt.pop_front() + 1);
            else
               data_out <= tx_pkt.pop_front();

            pkt_idx++;

            if (src_early_deassert)
               src_adr_out = 0;

            if (dst_early_deassert)
               dst_adr_out = 0;

            if (tx_pkt.size() == 0)
               ds_state = 2;
         end else begin
            valid <= 0;
         end

         2:
         begin
            #1;
            bus_req     <= 0;
            valid       <= 0;
            src_adr_out <= 0;
            dst_adr_out <= 0;
            data_out    <= 0;

            ds_state = 0;
         end
      endcase
   endtask

   task rdy_control();
      static int rdy_state = 0;
      static int rdy_delay;
      static int rdy_cnt;
      int bytes_in_fifo;

      case(rdy_state)
         0:
         begin
            // Generate RDY delay
            rdy_delay = $urandom_range(rdy_delay_min, rdy_delay_max);
            rdy_cnt++;
            if (rdy_cnt >= rdy_delay) begin
               #1; rdy = 1;
               rdy_state = 2;
            end
            rdy_state = 1;
         end

         1:
         begin
            rdy_cnt++;
            if (rdy_cnt >= rdy_delay) begin
               #1; rdy = 1;
               rdy_state = 2;
            end
         end

         2:
         begin
            bytes_in_fifo = 0;
            foreach (fifo[i]) begin
               bytes_in_fifo += fifo[i].size();
            end

            bytes_in_fifo = bytes_in_fifo + rx_pkt.size() + tx_pkt.size();

            //FFSTONY - Don't deassert RDY when FIFO contains more than 32B
            if (bytes_in_fifo > 32) begin
               #1; rdy = 0;
            end else begin
               #1; rdy = 1;
            end
         end
      endcase
   endtask

   task wait_rst();
      @(negedge rst_b)

      // Clear the internal FIFO
      //FFSTONY - optionally don't clear the FIFO
      fifo = {};
   endtask

   task pkt_handle();
      while (1) begin
         @(posedge clk);
         us_rx();
         ds_tx();
         rdy_control();
      end
   endtask

   initial begin
      while (1) begin
         rdy         <= 0;
         bus_req     <= 0;
         valid       <= 0;
         src_adr_out <= 0;
         dst_adr_out <= 0;
         data_out    <= 0;

         @(posedge rst_b);
         fork
            wait_rst();
            pkt_handle();
         join_any
         disable fork;
      end
   end

endmodule

