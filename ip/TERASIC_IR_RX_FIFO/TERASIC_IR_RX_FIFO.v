

module TERASIC_IR_RX_FIFO(
	clk,  // must be 50 MHZ
	reset_n,
	
	// interrrupt
	irq,
	
	// avalon slave
	s_address,
	s_cs_n,
	s_read,
	s_readdata,
	s_write,
	s_writedata,
	
	// export
	ir
	
);

`define IR_RX_DATA_REG 	0
`define IR_RX_CS_REG   	1

input                   s_address;
input			clk;
input			reset_n;
output	reg		irq;
input			s_cs_n;
input			s_read;
output 	[31:0]      	s_readdata;
input			s_write;
input	[31:0]	        s_writedata;
input			ir;

reg     [31:0] 	        s_readdata;
reg			fifo_clear;
wire    [7:0]           use_dw;
wire    [31:0]          writedata;
wire    [31:0]          readdata;


// write to clear interrupt
wire data_ready;
//always @ (posedge clk or posedge data_ready or negedge reset_n)
reg	pre_data_ready;
always @ (posedge clk or negedge reset_n)
begin
	if (~reset_n)
		pre_data_ready <= 1'b0;
	else
		pre_data_ready <= data_ready;
end


///////// interupt
always @ (posedge clk or negedge reset_n)
begin
	if (~reset_n)
		irq <= 1'b0;
	else if (~pre_data_ready & data_ready )
		irq <= 1'b1;
	else if (s_write && (s_address == `IR_RX_CS_REG))
		irq <=~s_writedata[1]; 
end


////////// fifo clear
always @ (clk)
begin
	if (~reset_n)
		fifo_clear <= 1'b0;
	else if (s_write && (s_address == `IR_RX_CS_REG))
		fifo_clear <= s_writedata[0];
	else if (fifo_clear)
		fifo_clear <= 1'b0;
end





assign   read= ( s_read && (s_address == `IR_RX_DATA_REG) ) ?1:0;
always @ (clk)
begin
	if (~reset_n)
		 s_readdata <=32'b0;
	else if (s_read && (s_address == `IR_RX_CS_REG))
		s_readdata <= use_dw;
	
	else if (read && (s_address == `IR_RX_DATA_REG ))
	   s_readdata <= readdata;
		
	else
		 s_readdata <=32'b0;


end

reg    write;
always @ (posedge clk or negedge reset_n)
begin
	if (~reset_n)
		write <= 1'b0;
	else if (~pre_data_ready & data_ready )
		write <= 1'b1;
	else if (write)
		write <=0; 
end



ir_fifo ir_fifo_inst(
	.aclr(fifo_clear),
	
	.data(writedata),
	.wrclk(clk),
	.wrreq(write),

   .rdclk(clk),
	.rdreq(read),
	.q(readdata),
	.rdusedw(use_dw),
	.rdempty()
	
);

IRDA_RECEIVE_Terasic IRDA_RECEIVE_Terasic_inst(
					.iCLK(clk),         //clk   50MHz
					.iRST_n(reset_n),       //reset
					
					.iIRDA(ir),        //IRDA code input
					
				   .oDATA_REAY(data_ready),	  //data ready
					.oDATA(writedata)         //decode data output
					);


endmodule
