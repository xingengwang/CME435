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
   event       us_cycle_done;
   event       ds_cycle_done;

   task wait_rst();
      @(negedge rst_b)

      // Clear the internal FIFO
      fifo = {};
   endtask

   task rdy_control();
      int bytes_in_fifo;

      repeat (3) begin
         @(posedge clk);
      end

      rdy = 1;

      while (1) begin
         @(posedge clk);
         fork
            @(us_cycle_done);
            @(ds_cycle_done);
         join

         bytes_in_fifo = 0;
         foreach (fifo[i]) begin
            bytes_in_fifo += fifo[i].size();
         end
 
         //$display("%t ------------------------",$time);
         //$display("bytes_in_fifo = %p",bytes_in_fifo);
         //$display("fifo.size = %p",fifo.size());
         //$display("rx_pkt.size = %p",rx_pkt.size());
         //$display("tx_pkt.size = %p",tx_pkt.size());
         bytes_in_fifo = bytes_in_fifo + rx_pkt.size() + tx_pkt.size();
         //$display("Total size = %p",bytes_in_fifo);

         if (bytes_in_fifo > 32)
            rdy = 0;
         else
            rdy = 1;
      end
   endtask

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

   // This allows proper handling of the reactive scheduling when
   // capturing data on the upstream interface.
   task delayed_us_push(logic [7:0] buf_adr_data);
      @(posedge clk);
      rx_pkt.push_back(buf_adr_data);
   endtask

   task us_rx();
      @(posedge clk);

      while (1) begin

         if (frame == 1) begin
            do begin
               fork
                  delayed_us_push(adr_data);
               join_none
               -> us_cycle_done;
               @(posedge clk);
            end while (frame == 1);

            fork
               begin
                  @(posedge clk);
                  //$display("csum pkt = %p",rx_pkt); 
                  if (csum_is_valid(rx_pkt))
                     fifo.push_back(rx_pkt);
                  rx_pkt = {};
               end
            join_none

         end else begin
            -> us_cycle_done;
            @(posedge clk);
         end
      end
   endtask

   task ds_drive_next_cycle(logic valid_val, logic [7:0] data_out_val);
      @(posedge clk);
      valid    = valid_val;
      data_out = data_out_val;
   endtask

   task ds_tx();
      @(posedge clk);

      while (1) begin
         if (fifo.size() > 0) begin
            tx_pkt = fifo.pop_front();

            // Assert the bus request and src/dst addresses
            bus_req = 1;
            src_adr_out = tx_pkt.pop_front();
            dst_adr_out = tx_pkt.pop_front();

            // Wait for a bus grant
            do begin
               -> ds_cycle_done;
               @(posedge clk);
            end while (bus_gnt != 1);

            do begin
               if (wait_sig == 1) begin
                  fork
                     ds_drive_next_cycle(0,data_out);
                  join_none;

                  do begin
                     -> ds_cycle_done;
                     @(posedge clk);
                  end while (wait_sig != 0);
               end

               fork
                  ds_drive_next_cycle(1,tx_pkt.pop_front());
               join_none
               -> ds_cycle_done;
               @(posedge clk);
            end while (tx_pkt.size() > 0);

            -> ds_cycle_done;
            @(posedge clk);
            bus_req     <= 0;
            valid       <= 0;
            src_adr_out <= 0;
            dst_adr_out <= 0;
            data_out    <= 0;

            do begin
               @(posedge clk);
            end while (bus_gnt != 0);
            @(posedge clk);

         end else begin
            -> ds_cycle_done;
            @(posedge clk);
         end
      end
   endtask

   initial begin
      while (1) begin
         // Initialize all outputs low
         rdy         <= 0;
         bus_req     <= 0;
         valid       <= 0;
         src_adr_out <= 0;
         dst_adr_out <= 0;
         data_out    <= 0;

         @(posedge rst_b);
         fork
            wait_rst();
            rdy_control();
            us_rx();
            ds_tx();
         join_any
         disable fork;
      end
   end

endmodule

