`ifndef OUT_TYPES
   `define OUT_TYPES
   `include "out_intf/out_types.sv"
`endif

class out_drvr_c;
   virtual out_intf_if.slave ports;
   int     out_drvr_inst_num;

   int proceed_delay_min = 0;
   int proceed_delay_max = 0;

   // NOTE: Please use "<=" rather than "=" any time you assign a value to
   // one of the nets in the virtual interface. Will be explained subsequently.

   // TO DO: Write constructor (the "new" function) to pull in
   // the in_intf_if master modport. The constructor should take a second
   // argument of type "int" to accept an instance number. Assign this
   // instance number to the out_drvr_inst_num class variable.
   function new (virtual out_intf_if.slave ports, int drvr_inst );
      this.ports <= ports;
	this.out_drvr_inst_num <= drvr_inst;
   endfunction

   // TO DO: Create a set_proceed_delay_range function that takes two ints
   // ("min" and "max") as arguments and pushes these values into class
   // member variables defined above (proceed_delay_min and proceed_delay_max)

   function void set_proceed_delay_range(int min, int max);
      proceed_delay_min = min;
      proceed_delay_max = max;
   endfunction

   // TO DO: Create a drive_proceed task to drive the PROCEED signal high for one
   // cycle, after NEWDATA_LEN has been driven to a non-zero value plus a random
   // delay (bounded by proceed_delay_min and proceed_delay_max)

   task drive_proceed();
      int proceed_delay;

      proceed_delay = $urandom_range(proceed_delay_min, proceed_delay_max);

	while(1) begin
		@(ports.newdata_len)

      		repeat (proceed_delay) begin            
         		@(posedge ports.clk);
     		 end
@(posedge ports.clk);
	ports.proceed = 1;
	@(posedge ports.clk);
	ports.proceed = 0;
	end

   endtask

   // TO DO: Create a wait_rst task that waits for an assertion of rst_b

   task wait_rst();
      @(negedge ports.rst_b);
      $display("%t out_drvr detected device reset.", $time);
   endtask

   // TO DO: Create a run task that initializes the outputs and invokes both
   // drive_proceed and wait_rst, similar to the run task in the SBIU ds_drvr
   task run();
      $display("%t out_drvr running.",$time);

      while (1) begin
         // Initialize all outputs low
         ports.proceed  <= 0;

         @(posedge ports.rst_b)
         fork
            drive_proceed();
            wait_rst();
         join_any
         disable fork;
      end
   endtask

endclass

