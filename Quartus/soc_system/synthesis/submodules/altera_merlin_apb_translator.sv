// (C) 2001-2017 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel MegaCore Function License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


// $Id: //acds/rel/16.1/ip/merlin/altera_merlin_apb_translator/altera_merlin_apb_translator.sv#1 $
// $Revision: #1 $
// $Date: 2016/08/07 $
// $Author: swbranch $

// ------------------------------------------------------------------------
// APB Translator
// Turn on/off some signals and set default values if the signal is turned off
// ------------------------------------------------------------------------

`timescale 1 ps / 1 ps
module altera_merlin_apb_translator #(
		parameter ADDR_WIDTH                 = 32,
		parameter DATA_WIDTH                 = 32,
		parameter USE_S0_PADDR31             = 0,
		parameter USE_M0_PADDR31             = 0,
		parameter USE_M0_PSLVERR             = 0,
		parameter AUTO_CLOCK_SINK_CLOCK_RATE = "-1"
	) (
		input  wire        clk,        				// clock_sink.clk
		input  wire        reset,      				// reset_sink.reset
		
		input  wire [ADDR_WIDTH-1:0] 	s0_paddr,   //  apb_slave.paddr
		input  wire        				s0_psel,    //           .psel
		input  wire        				s0_penable, //           .penable
		input  wire        				s0_pwrite,  //           .pwrite
		input  wire [DATA_WIDTH-1:0] 	s0_pwdata,  //           .pwdata
		output reg  [DATA_WIDTH-1:0] 	s0_prdata,  //           .prdata
		output reg        				s0_pslverr, //           .pslverr
		input  wire        				s0_paddr31, //           .paddr31
		output reg        				s0_pready,  //           .pready
		
		output reg  [ADDR_WIDTH-1:0]    m0_paddr,   // apb_master.paddr
		output reg        				m0_psel,    //           .psel
		output reg        				m0_penable, //           .penable
		output reg        				m0_pwrite,  //           .pwrite
		output reg  [DATA_WIDTH-1:0]    m0_pwdata,  //           .pwdata
		input  wire [DATA_WIDTH-1:0]    m0_prdata,  //           .prdata
		input  wire        				m0_pslverr, //           .pslverr
		output reg        				m0_paddr31, //           .paddr31
		input  wire        				m0_pready   //           .pready
	);

// ----------------------------------------
// Assign output to input almost everything
// ----------------------------------------
	assign s0_pready 	= m0_pready;
	assign s0_prdata 	= m0_prdata;
	
	assign m0_penable 	= s0_penable;
	assign m0_psel 		= s0_psel;
	assign m0_pwrite 	= s0_pwrite;
	assign m0_pwdata 	= s0_pwdata;
	assign m0_paddr 	= s0_paddr;

// ----------------------------------------
// Do some checking here
// ----------------------------------------
always_comb
	begin
		if (USE_M0_PSLVERR)
			s0_pslverr = m0_pslverr;
		else
			s0_pslverr = 1'b0;
	
		if (USE_M0_PADDR31 && !USE_S0_PADDR31)
			m0_paddr31 = 1'b0;
		else
			m0_paddr31 = s0_paddr31;
	end
endmodule
