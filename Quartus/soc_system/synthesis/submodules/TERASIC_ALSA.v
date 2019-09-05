//`default_nettype none
module TERASIC_ALSA(
	input 		clk, // Interface clock
	input 		reset_n, // asynchronous, active low

	// APB
	input 	[4:0]		output_paddr, // apb address
	input 				output_penable, // apb enable
	input 				output_pwrite,	// apb write strobe
	input  	[31:0]	output_pwdata, // apb data in
	input 				output_psel, // apb select
	output 	[31:0]	output_prdata, // apb data out
	output 				output_pready, // apb ready

	input		[4:0]		clkctrl_paddr, // apb address
	input					clkctrl_penable, // apb enable
	input					clkctrl_pwrite,	// apb write strobe
	input 	[31:0]	clkctrl_pwdata, // apb data in
	input					clkctrl_psel, // apb select
	output 	[31:0]	clkctrl_prdata, // apb data out
	output				clkctrl_pready, // apb ready

	// connect to host (e.g. HPS)
	input					clk_48, // clock Input// this clock, divided by mclk_devisor, should be 22.
	input					clk_44, // clock Input


	output 				playback_dma_req,
	input 				playback_dma_ack,

	output 				capture_dma_req,
	input 				capture_dma_ack,


	// audio codec chip
	input						AUD_ADCDAT,
	inout						AUD_ADCLRCK,
	inout						AUD_BCLK,
	output					AUD_DACDAT,
	inout						AUD_DACLRCK,
	output					AUD_XCK

);


wire	clock_bridge_0_out_clk_clk;
wire 	clock_bridge_48_out_clk_clk;
wire 	clock_bridge_44_out_clk_clk;
assign clock_bridge_0_out_clk_clk = clk;
assign clock_bridge_48_out_clk_clk = clk_48;
assign clock_bridge_44_out_clk_clk = clk_44;


/////////////////////////////////////////////
	wire	[63:0]	i2s_output_apb_0_playback_fifo_data;
	wire				i2s_output_apb_0_playback_fifo_read;
	wire				i2s_output_apb_0_playback_fifo_empty;
	wire				i2s_output_apb_0_playback_fifo_full;
	wire				i2s_output_apb_0_playback_fifo_clk;
	wire				i2s_output_apb_0_playback_dma_enable;
	wire				i2s_playback_enable;
	wire	[63:0]	i2s_output_apb_0_capture_fifo_data;
	wire				i2s_output_apb_0_capture_fifo_write;
	wire				i2s_output_apb_0_capture_fifo_empty;
	wire				i2s_output_apb_0_capture_fifo_full;
	wire				i2s_output_apb_0_capture_fifo_clk;
	wire				i2s_output_apb_0_capture_dma_enable;
	wire				i2s_capture_enable;

	wire				i2s_clkctrl_apb_0_ext_bclk;
	wire				i2s_clkctrl_apb_0_ext_playback_lrclk;
	wire				i2s_clkctrl_apb_0_ext_capture_lrclk;
	wire				i2s_clkctrl_apb_0_conduit_master_slave_mode;
	wire				i2s_clkctrl_apb_0_conduit_clk_sel_48_44;
	wire				i2s_clkctrl_apb_0_conduit_bclk;
	wire				i2s_clkctrl_apb_0_conduit_playback_lrclk;
	wire				i2s_clkctrl_apb_0_conduit_capture_lrclk;
	wire				i2s_clkctrl_apb_0_mclk_clk;



/////////////////////////////////////////////

i2s_output_apb i2s_output_apb_inst(
	.clk(clk), // Interface clock
	.reset_n(reset_n), // asynchronous, active low
	// APB
	.paddr(output_paddr), // apb address
	.penable(output_penable), // apb enable
	.pwrite(output_pwrite),	// apb write strobe
	.pwdata(output_pwdata), // apb data in
	.psel(output_psel), // apb select
	.prdata(output_prdata), // apb data out
	.pready(output_pready), // apb ready
	// FIFO interface to playback shift register
	.playback_fifo_data(i2s_output_apb_0_playback_fifo_data),
	.playback_fifo_read(i2s_output_apb_0_playback_fifo_read),
	.playback_fifo_empty(i2s_output_apb_0_playback_fifo_empty),
	.playback_fifo_full(i2s_output_apb_0_playback_fifo_full),
	.playback_fifo_clk(i2s_output_apb_0_playback_fifo_clk),
	// DMA interface, SOCFPGA
	.playback_dma_req(playback_dma_req),
	.playback_dma_ack(playback_dma_ack),
	.playback_dma_enable(i2s_output_apb_0_playback_dma_enable),
	// FIFO interface to capture shift register
	.capture_fifo_data(i2s_output_apb_0_capture_fifo_data),
	.capture_fifo_write(i2s_output_apb_0_capture_fifo_write),
	.capture_fifo_empty(i2s_output_apb_0_capture_fifo_empty),
	.capture_fifo_full(i2s_output_apb_0_capture_fifo_full),
	.capture_fifo_clk(i2s_output_apb_0_capture_fifo_clk),
	// DMA interface, SOCFPGA
	.capture_dma_req(capture_dma_req),
	.capture_dma_ack(capture_dma_ack),
	.capture_dma_enable(i2s_output_apb_0_capture_dma_enable)
);


/////////////////////////////////////////////

i2s_clkctrl_apb i2s_clkctrl_apb_inst(
	.clk(clk), // Interface clock
	.reset_n(reset_n), // asynchronous, active low
	// APB
	.paddr(clkctrl_paddr), // apb address
	.penable(clkctrl_penable), // apb enable
	.pwrite(clkctrl_pwrite),	// apb write strobe
	.pwdata(clkctrl_pwdata), // apb data in
	.psel(clkctrl_psel), // apb select
	.prdata(clkctrl_prdata), // apb data out
	.pready(clkctrl_pready), // apb ready
	// Clock inputs, synthesized in PLL or external TCXOs
	.clk_48(clk_48), // this clock, divided by mclk_devisor, should be 22.
	.clk_44(clk_44),
	// In slave mode, an external master makes the clocks
	.ext_bclk(i2s_clkctrl_apb_0_ext_bclk),
	.ext_playback_lrclk(i2s_clkctrl_apb_0_ext_playback_lrclk),
	.ext_capture_lrclk(i2s_clkctrl_apb_0_ext_capture_lrclk),
	.master_slave_mode(i2s_clkctrl_apb_0_conduit_master_slave_mode), // 1 = master, 0 (default) = slave
	// Clock derived outputs
	.clk_sel_48_44(i2s_clkctrl_apb_0_conduit_clk_sel_48_44), // 1 = mclk derived from 44, 0 (default) mclk derived from 48
	.mclk(i2s_clkctrl_apb_0_mclk_clk),
	.bclk(i2s_clkctrl_apb_0_conduit_bclk),
	.playback_lrclk(i2s_clkctrl_apb_0_conduit_playback_lrclk),
	.capture_lrclk(i2s_clkctrl_apb_0_ext_capture_lrclk)
);

/////////////////////////////////////////////
	wire i2s_playback_fifo_ack48;
	wire i2s_data_out48;
	i2s_shift_out i2s_shift_out48(
		.reset_n							(reset_n),
		.clk								(clock_bridge_48_out_clk_clk),

		.fifo_right_data					(i2s_output_apb_0_playback_fifo_data[63:32]),
		.fifo_left_data						(i2s_output_apb_0_playback_fifo_data[31:0]),
		.fifo_ready							(~i2s_output_apb_0_playback_fifo_empty),
		.fifo_ack							(i2s_playback_fifo_ack48),

		.enable								(i2s_playback_enable),
		.bclk								(i2s_clkctrl_apb_0_conduit_bclk),
		.lrclk								(i2s_clkctrl_apb_0_conduit_playback_lrclk),
		.data_out							(i2s_data_out48)
	);
	wire i2s_playback_fifo_ack44;
	wire i2s_data_out44;
	i2s_shift_out i2s_shift_out44(
		.reset_n							(reset_n),
		.clk								(clock_bridge_44_out_clk_clk),

		.fifo_right_data					(i2s_output_apb_0_playback_fifo_data[63:32]),
		.fifo_left_data						(i2s_output_apb_0_playback_fifo_data[31:0]),
		.fifo_ready							(~i2s_output_apb_0_playback_fifo_empty),
		.fifo_ack							(i2s_playback_fifo_ack44),

		.enable								(i2s_playback_enable),
		.bclk								(i2s_clkctrl_apb_0_conduit_bclk),
		.lrclk								(i2s_clkctrl_apb_0_conduit_playback_lrclk),
		.data_out							(i2s_data_out44)
	);

	wire i2s_capture_fifo_write48;
	wire i2s_data_in48;
	wire [63:0] i2s_capture_fifo_data48;
	i2s_shift_in i2s_shift_in48(
		.reset_n							(reset_n),
		.clk								(clock_bridge_48_out_clk_clk),

		.fifo_right_data					(i2s_capture_fifo_data48[63:32]),
		.fifo_left_data						(i2s_capture_fifo_data48[31:0]),
		.fifo_ready							(~i2s_output_apb_0_capture_fifo_full),
		.fifo_write							(i2s_capture_fifo_write48),

		.enable								(i2s_capture_enable),
		.bclk								(i2s_clkctrl_apb_0_conduit_bclk),
		.lrclk								(i2s_clkctrl_apb_0_conduit_capture_lrclk),
		.data_in							(i2s_data_in48)
	);
	wire i2s_capture_fifo_write44;
	wire i2s_data_in44;
	wire [63:0] i2s_capture_fifo_data44;
	i2s_shift_in i2s_shift_in44(
		.reset_n							(reset_n),
		.clk								(clock_bridge_44_out_clk_clk),

		.fifo_right_data					(i2s_capture_fifo_data44[63:32]),
		.fifo_left_data						(i2s_capture_fifo_data44[31:0]),
		.fifo_ready							(~i2s_output_apb_0_capture_fifo_full),
		.fifo_write							(i2s_capture_fifo_write44),

		.enable								(i2s_capture_enable),
		.bclk								(i2s_clkctrl_apb_0_conduit_bclk),
		.lrclk								(i2s_clkctrl_apb_0_conduit_capture_lrclk),
		.data_in							(i2s_data_in44)
	);

	// Combinatorics
	assign AUD_XCK = i2s_clkctrl_apb_0_mclk_clk;
	assign i2s_playback_enable = i2s_output_apb_0_playback_dma_enable & ~i2s_output_apb_0_playback_fifo_empty;
	assign i2s_capture_enable = i2s_output_apb_0_capture_dma_enable & ~i2s_output_apb_0_capture_fifo_full;

	// Mux and sync fifo read ack
	reg [2:0] i2s_playback_fifo_ack_synchro;
    wire i2s_playback_fifo_ack;
	assign i2s_playback_fifo_ack = i2s_clkctrl_apb_0_conduit_clk_sel_48_44 ?
		i2s_playback_fifo_ack44 : i2s_playback_fifo_ack48;
	always @(posedge clock_bridge_0_out_clk_clk or negedge reset_n)
		if (~reset_n)
			i2s_playback_fifo_ack_synchro <= 0;
		else
			i2s_playback_fifo_ack_synchro <= {i2s_playback_fifo_ack_synchro[1:0], i2s_playback_fifo_ack};
	assign i2s_output_apb_0_playback_fifo_read = i2s_playback_fifo_ack_synchro[2] & ~i2s_playback_fifo_ack_synchro[1];
	assign i2s_output_apb_0_playback_fifo_clk = clock_bridge_0_out_clk_clk;

	// Mux and sync fifo write
	reg [2:0] i2s_capture_fifo_write_synchro;
    wire i2s_capture_fifo_write;
	assign i2s_capture_fifo_write = i2s_clkctrl_apb_0_conduit_clk_sel_48_44 ?
		i2s_capture_fifo_write44 : i2s_capture_fifo_write48;
	always @(posedge clock_bridge_0_out_clk_clk or negedge reset_n)
		if (~reset_n)
			i2s_capture_fifo_write_synchro <= 0;
		else
			i2s_capture_fifo_write_synchro <= {i2s_capture_fifo_write_synchro[1:0], i2s_capture_fifo_write};
	assign i2s_output_apb_0_capture_fifo_write = i2s_capture_fifo_write_synchro[2] & ~i2s_capture_fifo_write_synchro[1];
	assign i2s_output_apb_0_capture_fifo_clk = clock_bridge_0_out_clk_clk;

	// Mux capture data
	assign i2s_output_apb_0_capture_fifo_data = i2s_clkctrl_apb_0_conduit_clk_sel_48_44 ?
		i2s_capture_fifo_data48 : i2s_capture_fifo_data44;

	// Mux out
	assign AUD_DACDAT = i2s_clkctrl_apb_0_conduit_clk_sel_48_44 ? i2s_data_out44 : i2s_data_out48;

	// Audio input
	assign i2s_data_in44 = AUD_ADCDAT;
	assign i2s_data_in48 = AUD_ADCDAT;
	//assign i2s_data_in44 = i2s_data_out44; // Loopback for testing
	//assign i2s_data_in48 = i2s_data_out48; // Loopback for testing

	// Audio clocks inouts
	assign AUD_BCLK = i2s_clkctrl_apb_0_conduit_master_slave_mode ?
		i2s_clkctrl_apb_0_conduit_bclk : 1'bZ;
	assign AUD_DACLRCK = i2s_clkctrl_apb_0_conduit_master_slave_mode ?
		i2s_clkctrl_apb_0_conduit_playback_lrclk : 1'bZ;
	assign AUD_ADCLRCK = i2s_clkctrl_apb_0_conduit_master_slave_mode ?
		i2s_clkctrl_apb_0_conduit_capture_lrclk : 1'bZ;

	assign i2s_clkctrl_apb_0_ext_bclk = i2s_clkctrl_apb_0_conduit_master_slave_mode ?
		i2s_clkctrl_apb_0_conduit_bclk : AUD_BCLK;
	assign i2s_clkctrl_apb_0_ext_playback_lrclk = i2s_clkctrl_apb_0_conduit_master_slave_mode ?
		i2s_clkctrl_apb_0_conduit_playback_lrclk : AUD_DACLRCK;
	assign i2s_clkctrl_apb_0_ext_capture_lrclk = i2s_clkctrl_apb_0_conduit_master_slave_mode ?
		i2s_clkctrl_apb_0_conduit_capture_lrclk : AUD_DACLRCK;


///////////////////////////


endmodule


