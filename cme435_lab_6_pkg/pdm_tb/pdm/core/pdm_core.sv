`timescale 1ns/1ns

module pdm_core_out_drvr(
   input  wire        clk,
   input  wire        rst_b,
  
   output logic [4:0] newdata_len,
   input  wire        proceed,
   output logic [7:0] data_out
);

   logic [7:0] out_fifo[$][$];
   event reset_event;
   bit corrupt_newdata_len = 0;

   function void add_pkt(logic [7:0] pkt[$]);
      out_fifo.push_back(pkt);
   endfunction

   function void set_corrupt_newdata_len(bit val);
      corrupt_newdata_len = val;
   endfunction

   task out_tx();
      logic [7:0] tx_pkt[$];

      while (1) begin
         @(posedge clk);

         if (out_fifo.size() > 0) begin
            tx_pkt = out_fifo.pop_front();

            // Configurable option - drive incorrect length value
            if (corrupt_newdata_len) begin
               newdata_len = (tx_pkt.size() + 4) % 16;
            end else begin
               newdata_len = tx_pkt.size();
            end

            do begin
               @(posedge clk);
               newdata_len = 0;
            end while (proceed != 1);

            @(posedge clk);

            while (tx_pkt.size() > 0) begin
               data_out = tx_pkt.pop_front();
               @(posedge clk);
            end

            data_out = 0;
         end
      end
   endtask

   task wait_rst();
      @(reset_event);
      out_fifo = {};
   endtask

   initial begin
      while (1) begin
         // Initialize all outputs low
         newdata_len <= 0;
         data_out    <= 0;

         @(posedge rst_b);
         fork
            wait_rst();
            out_tx();
         join_any
         disable fork;
      end
   end

endmodule

module pdm_core(
   input  wire        clk,
   input  wire        rst_b,

   input  wire        bnd_plse,
   input  wire  [7:0] data_in,
   output logic       ack,

   output logic [4:0] newdata_len_1,
   input  wire        proceed_1,
   output logic [7:0] data_out_1,

   output logic [4:0] newdata_len_2,
   input  wire        proceed_2,
   output logic [7:0] data_out_2,

   output logic [4:0] newdata_len_3,
   input  wire        proceed_3,
   output logic [7:0] data_out_3,

   output logic [4:0] newdata_len_4,
   input  wire        proceed_4,
   output logic [7:0] data_out_4
);

   logic [7:0] in_fifo[$];
   int ack_delay_min = 1;
   int ack_delay_max = 1;
   bit drive_ack_two_cycles = 0;
   bit data_corruption = 0;
   bit bad_routing = 0;

   pdm_core_out_drvr out_drvr_1(
      .clk(clk),
      .rst_b(rst_b),
      .newdata_len(newdata_len_1),
      .proceed(proceed_1),
      .data_out(data_out_1)
   );

   pdm_core_out_drvr out_drvr_2(
      .clk(clk),
      .rst_b(rst_b),
      .newdata_len(newdata_len_2),
      .proceed(proceed_2),
      .data_out(data_out_2)
   );

   pdm_core_out_drvr out_drvr_3(
      .clk(clk),
      .rst_b(rst_b),
      .newdata_len(newdata_len_3),
      .proceed(proceed_3),
      .data_out(data_out_3)
   );

   pdm_core_out_drvr out_drvr_4(
      .clk(clk),
      .rst_b(rst_b),
      .newdata_len(newdata_len_4),
      .proceed(proceed_4),
      .data_out(data_out_4)
   );

   function void set_ack_delay_range(int min, int max);
      ack_delay_min = min;
      ack_delay_max = max;
   endfunction

   function void set_drive_ack_two_cycles(bit val);
      drive_ack_two_cycles = val;
   endfunction

   function void set_data_corruption(bit val);
      data_corruption = val;
   endfunction

   function void set_bad_routing(bit val);
      bad_routing = val;
   endfunction

   task wait_rst();
      @(negedge rst_b)

      // Clear the internal FIFOs
      in_fifo    = {};
      -> out_drvr_1.reset_event;
      -> out_drvr_2.reset_event;
      -> out_drvr_3.reset_event;
      -> out_drvr_4.reset_event;
   endtask

   task ack_control();
      automatic bit toggle_bit = 1;
      int ack_delay;

      @(posedge clk);

      while (1) begin
         if (bnd_plse == 1) begin
            toggle_bit = ~toggle_bit;

            if (toggle_bit == 1) begin
               // Configurable option - vary ACK latency
               ack_delay = $urandom_range(ack_delay_min, ack_delay_max);

               repeat (ack_delay) begin
                  @(posedge clk);
               end

               ack = 1;
               @(posedge clk);
               // Configurable option - drive ACK for two cycles to violate protocol spec
               if (drive_ack_two_cycles)
                  @(posedge clk);
               ack = 0;
            end else begin
               @(posedge clk);
            end

         end else begin
            @(posedge clk);
         end

/*
            if (toggle_bit == 1) begin
               @(posedge clk);
               ack = 1;
               @(posedge clk);
               ack = 0;
            end else begin
               @(posedge clk);
            end

         end else begin
            @(posedge clk);
         end
*/
      end
   endtask

   task in_rx();
      int dst_port;

      while (1) begin
         @(posedge clk);
         if (bnd_plse == 1) begin
            in_fifo.push_back(data_in);

            do begin
               @(posedge clk);
               in_fifo.push_back(data_in);
            end while (bnd_plse == 0);

            dst_port = in_fifo.pop_front();
            // Brief delay to ensure that the out_drvr doesn't start driving the packet
            // on this same clock cycle if its clock-triggered behavior hasn't been executed
            // yet on the current simulation cycle.
            #1

            // Configurable option - corrupt the received payload data
            if (data_corruption) begin
               foreach (in_fifo[i]) begin
                  in_fifo[i]++;
               end
               $display("in_fifo = %p",in_fifo);
            end

            // Configurable option - route to the wrong output port
            if (bad_routing) begin
               dst_port++;
               if (dst_port == 5)
                  dst_port = 1; 
            end

            case (dst_port)
               1: out_drvr_1.add_pkt(in_fifo);
               2: out_drvr_2.add_pkt(in_fifo);
               3: out_drvr_3.add_pkt(in_fifo);
               4: out_drvr_4.add_pkt(in_fifo);
            endcase
            in_fifo = {};
         end
      end
   endtask

   initial begin
      while (1) begin
         // Initialize all outputs low
         ack           <= 0;

         @(posedge rst_b);
         fork
            wait_rst();
            ack_control();
            in_rx();
         join_any
         disable fork;
      end
   end

endmodule

