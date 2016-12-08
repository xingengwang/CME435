`ifndef DS_TYPES
   `define DS_TYPES
   `include "ds_intf/ds_types.sv"
`endif

class ds_drvr_c;

   virtual ds_intf_if.slave ports;

   int bus_gnt_delay_min = 0;
   int bus_gnt_delay_max = 0;
   int wait_assert_prob  = 0;
   int wait_dur_min      = 1;
   int wait_dur_max      = 1;

   function new (virtual ds_intf_if.slave ports);
      this.ports = ports;
   endfunction

   function void set_bus_gnt_delay_range(int min, int max);
      bus_gnt_delay_min = min;
      bus_gnt_delay_max = max;
   endfunction

   function void set_wait_assert_prob(int prob);
      wait_assert_prob = prob;
   endfunction

   function void set_wait_dur_range(int min, int max);
      wait_dur_min = min;
      wait_dur_max = max;
   endfunction

   task drive_bus_gnt();
      int bus_gnt_delay;

      bus_gnt_delay = $urandom_range(bus_gnt_delay_min, bus_gnt_delay_max);

      repeat (bus_gnt_delay) begin            
         @(posedge ports.clk);
      end
      ports.bus_gnt = 1;

      while (1) begin
         @(posedge ports.clk);
      end
   endtask

   task drive_wait();
      int wait_dur;

      while (1) begin
         if ($urandom_range(1,100) < wait_assert_prob) begin
            wait_dur = $urandom_range(wait_dur_min, wait_dur_max);

            ports.wait_sig = 1;
            repeat (wait_dur) begin
               @(posedge ports.clk);
            end
            ports.wait_sig = 0;
         end

         @(posedge ports.clk);
      end
   endtask

   task wait_bus_req_deassert();
      do begin
         @(posedge ports.clk);
      end while (ports.bus_req != 0);
   endtask

   task rcv_pkt();
      while (1) begin
         @(posedge ports.clk);

         if (ports.bus_req == 1) begin
            fork
               drive_bus_gnt();
               drive_wait();
               wait_bus_req_deassert();
            join_any
            disable fork;
            
            ports.wait_sig <= 0;
            ports.bus_gnt  <= 0;
         end
      end
   endtask

   task wait_rst();
      @(negedge ports.rst_b);
      $display("%t ds_drvr detected device reset.", $time);
   endtask

   task run();
      $display("%t ds_drvr running.",$time);

      while (1) begin
         // Initialize all outputs low
         ports.bus_gnt  <= 0;
         ports.wait_sig <= 0;

         @(posedge ports.rst_b)
         fork
            rcv_pkt();
            wait_rst();
         join_any
         disable fork;
      end
   endtask
endclass

