module instruction_decoder(
	output reg jmp,
	output reg jmp_nz,
	output reg i_sel,
	output reg y_sel,
	output reg x_sel,
	output reg [3:0] ir_nibble,
	output reg [3:0] source_sel,
	output reg [7:0] ir,
	output reg [8:0] reg_en,
	output reg [7:0] from_ID,
	
	input clk,
	input sync_reset,
	input [7:0] next_instr
);
	
	

/******************************************************************************
	Instruction Fields
	-------------------
	Local wires which specify the different fields inside an instruction.
	
	Parameters:
		ir :: set in this file.
******************************************************************************/
wire[2:0] DST_LOAD;	// destination for load instruction
wire[2:0] DST_MOVE;	// destination for move instruction
wire[2:0] SRC_MOVE;	// source for move instruction

wire X_ALU;				// x select in ALU instruction
wire Y_ALU;				// y select in ALU instruction
	
// assign these fields their value	
assign DST_LOAD = ir[6:4];
assign DST_MOVE = ir[5:3];
assign SRC_MOVE = ir[2:0];
assign X_ALU = ir[4];
assign Y_ALU = ir[3];
			

/******************************************************************************
	ID Parameters
	-------------------
	Local parameters which are used to replace "magic numbers"
******************************************************************************/

// destination register ID's
localparam x0_reg_ID = 3'd0;
localparam x1_reg_ID = 3'd1;
localparam y0_reg_ID = 3'd2;
localparam y1_reg_ID = 3'd3;
localparam o_reg_ID	= 3'd4;
localparam m_reg_ID 	= 3'd5;
localparam i_reg_ID 	= 3'd6;
localparam dm_reg_ID	= 3'd7;

// register enable ID's
localparam x0_reg_EN = 9'b000000001;
localparam x1_reg_EN = 9'b000000010;
localparam y0_reg_EN = 9'b000000100;
localparam y1_reg_EN = 9'b000001000;
localparam r_reg_EN 	= 9'b000010000;
localparam o_reg_EN 	= 9'b100000000;
localparam m_reg_EN 	= 9'b000100000;
localparam i_reg_EN 	= 9'b001000000;
localparam dm_reg_EN = 9'b010000000;

// source select ID's
localparam x0_sel_ID 			= 4'd0;
localparam x1_sel_ID 			= 4'd1;
localparam y0_sel_ID 			= 4'd2;
localparam y1_sel_ID 			= 4'd3;
localparam r_sel_ID 				= 4'd4;
localparam m_sel_ID 				= 4'd5;
localparam i_sel_ID 				= 4'd6;
localparam dm_sel_ID				= 4'd7;
localparam ir_nibble_sel_ID 	= 4'd8;
localparam pm_data_sel_ID 		= 4'd8;
localparam i_pins_sel_ID 		= 4'd9;
localparam null_sel_ID 			= 4'd10;



/******************************************************************************
	from_ID
	-------------------
	Passe's signals that result from changes made in the exam.
	
	Parameters:
		reg_en :: set in this file.
******************************************************************************/
always@*
	from_ID = reg_en[7:0];
	
	
	
/******************************************************************************
	ir
	-------------------
	Instruction register. The current instruction to be executed.
	
	Parameters:
		next_instr :: equal to pm_data from program_memory.v (ROM). Direct from
						  ROM.
******************************************************************************/
	always@(posedge clk)
		ir[7:0] = next_instr[7:0];
	
	
	
/******************************************************************************
	ir_nibble
	-------------------
	Nibble of instruction register. Least significant.
******************************************************************************/
always@*
		ir_nibble[3:0] = ir[3:0];
	
/******************************************************************************
	reg_en
	-------------------
	Handles the registers enables for all instructions.
	
	Special cases:
		i_reg is enabled whenever "dm" is the "src" or "dst" with the exception 
		of where "src" == "dm" and "dst" = "i"
	
	Parameters:
		ir	::	set in this  file.
******************************************************************************/
always@*
	if(sync_reset) /*	Reset */
		reg_en[8:0] = 9'h1FF;
		
	else if(ir[7] == 0) /*	Load instruction */
		case(DST_LOAD)
			x0_reg_ID : reg_en = x0_reg_EN;
			x1_reg_ID : reg_en = x1_reg_EN;
			y0_reg_ID : reg_en = y0_reg_EN;
			y1_reg_ID : reg_en = y1_reg_EN;
			o_reg_ID  : reg_en = o_reg_EN;
			m_reg_ID  : reg_en = m_reg_EN;
			i_reg_ID  : reg_en = i_reg_EN;
			dm_reg_ID : reg_en = (dm_reg_EN | i_reg_EN); /* Auto increment case */
			default 	 : reg_en = 9'b0;
		endcase	
		
	else if(ir[6] == 0) 	/*	Move instruction */
		if(DST_MOVE == dm_reg_ID || SRC_MOVE == dm_reg_ID)
			case(DST_MOVE)  /* Auto increment case */
				x0_reg_ID : reg_en = (x0_reg_EN | i_reg_EN);
				x1_reg_ID : reg_en = (x1_reg_EN | i_reg_EN);
				y0_reg_ID : reg_en = (y0_reg_EN | i_reg_EN);
				y1_reg_ID : reg_en = (y1_reg_EN | i_reg_EN);
				o_reg_ID  : reg_en = (o_reg_EN  | i_reg_EN);
				m_reg_ID  : reg_en = (m_reg_EN  | i_reg_EN);
				i_reg_ID  : reg_en = (i_reg_EN);
				dm_reg_ID : reg_en = (dm_reg_EN | i_reg_EN);
				default 	 : reg_en = 9'b0;
			endcase 
		else 
			case(DST_MOVE)  /* No auto increment case */
				x0_reg_ID 	: reg_en[8:0] = x0_reg_EN;
				x1_reg_ID 	: reg_en[8:0] = x1_reg_EN;
				y0_reg_ID 	: reg_en[8:0] = y0_reg_EN;
				y1_reg_ID 	: reg_en[8:0] = y1_reg_EN;
				o_reg_ID 	: reg_en[8:0] = o_reg_EN;
				m_reg_ID 	: reg_en[8:0] = m_reg_EN;
				i_reg_ID 	: reg_en[8:0] = i_reg_EN;
				dm_reg_ID 	: reg_en[8:0] = (dm_reg_EN | i_reg_EN); // shouldnt ever happen
				default 		: reg_en[8:0] = 9'b0;
			endcase 
			
	else if(ir[5] == 0)	/*	ALU instruction */
		reg_en[8:0] = r_reg_EN;	
		
	else	/*	Jump or Jump_nz instruction */
		reg_en[8:0] = 9'b0;
			

/******************************************************************************
	source_sel
	-------------------
	Handles the source select for selecting the value to be written to the 
	data_bus in the computational unit.
	
	Special cases:
		if "src" == "dst" != "o_reg" then source_sel = "src" or "dst"
		
		if "src" == "dst" == 3'd4 then source_sel = "r"
	
	Parameters:
		ir	::	set in this  file.
******************************************************************************/
always@*
	if(sync_reset)	/*	Reset */
		source_sel[3:0] = 4'd10;
		
	else if(ir[7] == 0)	/*	Load instruction */
		source_sel[3:0] = ir_nibble_sel_ID;
		
	else if(ir[6] == 0)	/*	Move instruction */
		if(DST_MOVE == SRC_MOVE && DST_MOVE == o_reg_ID) /* dst == src == 3'd4 */
			source_sel[3:0] = r_sel_ID;
		else if(DST_MOVE == SRC_MOVE) /* dst == src */
			source_sel[3:0] = i_pins_sel_ID;
		else
			source_sel[3:0] = SRC_MOVE;
			
	else 	/*	Doesn't matter case */
		source_sel[3:0] = null_sel_ID;
		
		
/******************************************************************************
	i_sel
	-------------------
	Select for i register MUX. 
******************************************************************************/
always@*
	if(sync_reset)	/*	Reset */
		i_sel = 1'b0;
	else if( {DST_MOVE, SRC_MOVE} == 6'b110111 && ir[7:6] == 2'b10) /* No auto increment case */
		i_sel = 1'b0; 
	else if(((DST_MOVE == dm_reg_ID || SRC_MOVE == dm_reg_ID) && ir[7:6] == 2'b10) || 
				(DST_LOAD == dm_reg_ID && ir[7] == 1'b0) ) /* Auto increment case */
		i_sel = 1'b1; 
	else /* No auto increment case */
		i_sel = 1'b0; 
		
		
/******************************************************************************
	x_sel
	-------------------
	Select for which x to use for ALU instruction
******************************************************************************/
always@*
	if(sync_reset)	/*	Reset */
		x_sel = 1'b0;
	else if(ir[7:5] == 3'b110)	/* ALU operation */
		x_sel = X_ALU;
	else	/* everything else */
		x_sel = 1'b0;
		
/******************************************************************************
	y_sel
	-------------------
	Select for which y to use for ALU instruction
******************************************************************************/
always@*
	if(sync_reset) /* Reset */
		y_sel = 1'b0;
	else if(ir[7:5] == 3'b110)	/* ALU operation */
		y_sel = Y_ALU;
	else	/* everything else */
		y_sel = 1'b0;
		

/******************************************************************************
	jmp
	-------------------
	Flag for unconditional jump instruction.
******************************************************************************/
always@*
	if(ir[7:4] == 4'b1110)
		jmp = 1'b1;
	else 
		jmp = 1'b0;
		
		
/******************************************************************************
	jmp_nz
	-------------------
	Flag for conditional jump instruction.
******************************************************************************/
always@*
	if(ir[7:4] == 4'b1111)
		jmp_nz = 1'b1;
	else 
		jmp_nz = 1'b0;
		
		
	
endmodule
	
			