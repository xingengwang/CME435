module microprocessor(
	output zero_flag,
	output [3:0] x0,
	output [3:0] x1,
	output [3:0] y0,
	output [3:0] y1,
	output [3:0] o_reg,
	output [3:0] i,
	output [3:0] m,
	output [3:0] r,
	output [7:0] from_CU,
	output [7:0] pm_data,
	output [7:0] pm_address,
	output [7:0] from_PS,
	output [7:0] pc,
	output [7:0] from_ID,
	output [7:0] ir,
	
	input reset,
	input clk,
	input [3:0] i_pins
);

/******************************************************************************
	Local nets
	-----------
	Wires and registers for local nets.
******************************************************************************/
reg sync_reset;


wire 	jmp_nz;
wire 	jump;
wire	conditional_jump;
wire	i_mux_select;
wire	y_reg_select;
wire	x_reg_select;
wire [3:0] LS_nibble_ir;
wire [3:0] source_select;
wire [3:0] data_mem_addr;
wire [3:0] data_bus;
wire [3:0] dm;			
wire [8:0] 	reg_enables;

assign i = data_mem_addr;




/******************************************************************************
									Program Memory -- ROM
******************************************************************************/		
program_memory prog_mem( .q (pm_data),			// output

								 .clock  (~clk),				// inputs
							    .address (pm_address)	
);


/******************************************************************************
									Instruction Decoder
******************************************************************************/											
instruction_decoder next_decoder( .jmp (jump),						// outputs
											 .jmp_nz (conditional_jump),
											 .i_sel (i_mux_select),
											 .y_sel (y_reg_select),
											 .x_sel (x_reg_select),
											 .ir_nibble (LS_nibble_ir),
											 .source_sel(source_select),
											 .ir (ir),
											 .reg_en	(reg_enables),
											 .from_ID (from_ID),						 

											 .clk (clk),						// inputs
											 .sync_reset (sync_reset),
											 .next_instr (pm_data)									
);
												
												
/******************************************************************************
									Program Sequencer
******************************************************************************/	
program_sequencer prog_sequencer( .pm_addr (pm_address),	// outputs
											 .from_PS (from_PS),
											 .pc (pc),
											 
											 .clk (clk),				// inputs
											 .sync_reset (sync_reset),
											 .jmp (jump),
											 .jmp_nz (conditional_jump),
											 .dont_jmp (zero_flag),
											 .jmp_addr (LS_nibble_ir)
);			
					
					
/******************************************************************************
									Computational Unit
******************************************************************************/				
computational_unit comp_unit(	.r_eq_0 (zero_flag),			// outputs
										.data_bus (data_bus),
										.x0 (x0), 
										.x1 (x1), 
										.y0 (y0), 
										.y1 (y1), 
										.o_reg (o_reg),
										.i (data_mem_addr),
										.m (m), 
										.r (r),
										.from_CU (from_CU),
										
										.clk (clk),						// inputs
										.sync_reset (sync_reset),
										.i_sel (i_mux_select),
										.y_sel (y_reg_select),
										.x_sel (x_reg_select),
										.ir_nibble (LS_nibble_ir),
										.source_sel (source_select),
										.dm (dm),
										.i_pins (i_pins),
										.reg_en (reg_enables)
);
					
					
					
/******************************************************************************
									Data Memory -- RAM
******************************************************************************/	
/*data_memory data_mem( .data_out(dm),				// outputs

							 .clk(~clk),					// inputs
							 .addr(data_mem_addr),
							 .data_in(data_bus),
							 .w_en(reg_enables[7])	
);											
	*/											

Data_Memory_RAM data_mem( .q(dm),				// outputs

							 .clock(~clk),					// inputs
							 .address(data_mem_addr),
							 .data(data_bus),
							 .wren(reg_enables[7])	
);			
			
/******************************************************************************
	sync_reset
	-----------
	flag for synchronous reset
******************************************************************************/
always@(posedge clk)
	sync_reset = reset;
												

endmodule
