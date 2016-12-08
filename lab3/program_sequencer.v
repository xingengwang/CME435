module program_sequencer(
	output reg [7:0] pm_addr,
	output reg [7:0] from_PS,
	output reg [7:0] pc,
	
	input clk,
	input sync_reset,
	input jmp,
	input jmp_nz,
	input dont_jmp,
	input [3:0] jmp_addr
);


/******************************************************************************
	from_PS
	--------
	Passes signals that results from changes made during the exam.
******************************************************************************/						
always@*
	from_PS = pc;
	
	
/******************************************************************************
	pc
	--------
	Program counter. Points to the next program memory address.
******************************************************************************/	
always@(posedge clk)
	pc = pm_addr;

	
/******************************************************************************
	pm_addr
	--------
	Program memory address. The memory address of the current instruction.
******************************************************************************/
always@*
	if(sync_reset)
		pm_addr = 8'h00;
	else if(jmp)
		pm_addr = {jmp_addr, 4'h0};
	else if(jmp_nz && ~dont_jmp)
		pm_addr = {jmp_addr, 4'h0};
	else
		pm_addr = pc + 8'h01;
			
endmodule