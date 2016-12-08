`define DEFAULT_DATA_BUS_VALUE 4'h0
`define DEFAULT_REGISTER_VALUE 4'h0

module computational_unit(
	output reg 	r_eq_0,
	output reg [3:0] data_bus,
	output reg [3:0] x0, 
	output reg [3:0] x1, 
	output reg [3:0] y0, 
	output reg [3:0] y1, 
	output reg [3:0] o_reg, 
	output reg [3:0] i, 
	output reg [3:0] m, 
	output reg [3:0] r,
	output reg [7:0] from_CU,

	input	clk, 
	input	sync_reset, 
	input i_sel, 
	input	y_sel, 
	input	x_sel,
	input [3:0] ir_nibble, 
	input [3:0]	source_sel, 
	input [3:0]	dm, 
	input [3:0]	i_pins,
	input [8:0] reg_en
);



/******************************************************************************
		Local nets 
******************************************************************************/
reg [2:0] alu_func;		
reg [3:0] alu_eval;
reg [3:0] x;
reg [3:0] y;
reg [7:0] x_times_y;





/******************************************************************************
	from_CU
	---------
	Passes the signal that results from changes in the exam.
******************************************************************************/
always@*
	from_CU = {x1, x0};

	
/******************************************************************************
	x_times_y
	-----------
	Stores the value of x*y.
******************************************************************************/
always@*
	x_times_y = x * y;

/******************************************************************************
	x
	--
	Set which x is to be used by the ALU
******************************************************************************/
always@*
	if(x_sel == 1'b0)
		x = x0;
	else 
		x = x1;
	
/******************************************************************************
	y
	--
	Set which y is to be used by the ALU
******************************************************************************/	
always@*
	if(y_sel == 1'b0)
		y = y0;
	else 
		y = y1;

/******************************************************************************
	alu_func
	---------
	Wrap ir_nibble[2:0].
******************************************************************************/	
always@*
	alu_func = ir_nibble[2:0];
	

/******************************************************************************
	data_bus
	---------
	Set the value of the data bus.
******************************************************************************/	
always@*
	case(source_sel)
		4'd00 : data_bus = x0;
		4'd01 : data_bus = x1;
		4'd02 : data_bus = y0;
		4'd03 : data_bus = y1;
		4'd04 : data_bus = r;
		4'd05 : data_bus = m;
		4'd06 : data_bus = i;
		4'd07 : data_bus = dm;
		4'd08 : data_bus = ir_nibble;
		4'd09 : data_bus = i_pins;
		4'd10 : data_bus = `DEFAULT_DATA_BUS_VALUE;
		4'd11 : data_bus = `DEFAULT_DATA_BUS_VALUE;
		4'd12 : data_bus = `DEFAULT_DATA_BUS_VALUE;
		4'd13 : data_bus = `DEFAULT_DATA_BUS_VALUE;
		4'd14 : data_bus = `DEFAULT_DATA_BUS_VALUE;
		4'd15 : data_bus = `DEFAULT_DATA_BUS_VALUE;
		default: data_bus = `DEFAULT_DATA_BUS_VALUE;
	endcase

	
/******************************************************************************
	data registers
	---------------
	Write the value on the data bus to the appropriate register.
******************************************************************************/	

/*	x0 */
always@(posedge clk)
	if(reg_en[0])
		x0 = data_bus;
	else
		x0 = x0;

/*	x1 */
always@(posedge clk)
	if(reg_en[1])
		x1 = data_bus;
	else 
		x1 = x1;
		
/*	y0 */
always@(posedge clk)
	if(reg_en[2])
		y0 = data_bus;
	else 
		y0 = y0;

/*	y1 */
always@(posedge clk)
	if(reg_en[3])
		y1 = data_bus;
	else 
		y1 = y1;
		
/*	m */
always@(posedge clk)
	if(reg_en[5])
		m = data_bus;
	else 
		m = m;

/*	i */
always@(posedge clk)
	if(reg_en[6])
		if(i_sel == 1'b0)
			i = data_bus;
		else 
			i = i + m;
	else 
		i = i;
/*	o_reg */
always@(posedge clk)
	if(reg_en[8])
		o_reg = data_bus;
	else 
		o_reg = o_reg;
		
		
/*	r */		
always@(posedge clk)
	if(sync_reset)
		r = 4'h0;	// reset state for r
	else if(reg_en[4])
		if(alu_func == 3'b000 && ir_nibble[3] == 1'b1)	// no-op
			r = r;
		else if(alu_func == 3'b111 && ir_nibble[3] == 1'b1) // no-op
			r = r;
		else
			r = alu_eval;
	else
		r = r;
		
/* r_eq_0 */
always@(posedge clk)
	if(sync_reset)
		r_eq_0 = 1'b1;			// reset state for r_eq_0
	else if(reg_en[4])
		if(alu_func == 3'b000 && ir_nibble[3] == 1'b1)	// no-op
			r_eq_0 = r_eq_0;
		else if(alu_func == 3'b111 && ir_nibble[3] == 1'b1) // no-op
			r_eq_0 = r_eq_0;
		else if(alu_eval == 4'd0)
			r_eq_0 = 1'b1;
		else 
			r_eq_0 = 1'b0;
	else
		r_eq_0 = r_eq_0;
		
		
/******************************************************************************
	alu_eval
	---------
	The result from the combinational ALU.
******************************************************************************/	
always@*
	case(alu_func)
			3'b000: alu_eval = ~x + 4'b1;	// handle no-op in r register
			3'b001: alu_eval = x-y;
			3'b010: alu_eval = x+y;
			3'b011: alu_eval = x_times_y[7:4];
			3'b100: alu_eval = x_times_y[3:0];
			3'b101: alu_eval = x ^ y;
			3'b110: alu_eval = x & y;
			3'b111: alu_eval = ~x;			// handle no-op in r register
			default:
				alu_eval = 4'hF;
		endcase
		
endmodule
