`ifndef OUT_TYPES
   `define OUT_TYPES
   `include "out_intf/out_types.sv"
`endif

class out_drvr_c;
   virtual out_intf_if.slave ports;
   int     out_drvr_inst_num;

   int proceed_delay_min = 0;
   int proceed_delay_max = 0;
   bit drive_two_proceed_cycles = 0;

   function new (virtual out_intf_if.slave ports, int inst_num);
      this.ports = ports;
      this.out_drvr_inst_num = inst_num;
   endfunction

   function void set_proceed_delay_range(int min, int max);
      proceed_delay_min = min;
      proceed_delay_max = max;
   endfunction

   function void set_drive_two_proceed_cycles(bit val);
      drive_two_proceed_cycles = val;
   endfunction

   task drive_proceed();
      int proceed_delay;

      while (1) begin

         // Wait for NEWDATA_LEN to be asserted with a non-zero value
         do begin
            @(posedge ports.clk);
         end while (ports.newdata_len == 0);

         // Generate a delay value and wait for the generated number of delay
         // cycles before asserting PROCEED
         proceed_delay = $urandom_range(proceed_delay_min, proceed_delay_max);
         repeat (proceed_delay) begin            
            @(posedge ports.clk);
         end
         ports.proceed <= 1;

         // Wait one cycle, then drive PROCEED low
         @(posedge ports.clk);
	      if (drive_two_proceed_cycles)
            @(posedge ports.clk);
         ports.proceed <= 0;
      end
   endtask

   task wait_rst();
      @(negedge ports.rst_b);
      $display("%t out_drvr %p detected device reset.", $time, out_drvr_inst_num);
   endtask

   task run();
      $display("%t out_drvr %p running.", $time, out_drvr_inst_num);

      while (1) begin
         // Initialize all outputs low
         ports.proceed <= 0;

         @(posedge ports.rst_b)
         fork
            drive_proceed();
            wait_rst();
         join_any
         disable fork;
      end
   endtask

endclass

