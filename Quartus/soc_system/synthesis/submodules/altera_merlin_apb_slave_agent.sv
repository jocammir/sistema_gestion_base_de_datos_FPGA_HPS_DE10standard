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


// $Id: //acds/rel/16.1/ip/merlin/altera_merlin_apb_slave_agent/altera_merlin_apb_slave_agent.sv#1 $
// $Revision: #1 $
// $Date: 2016/08/07 $
// $Author: swbranch $

// ------------------------------------------------------------------------
// APB slave agent: 
// The component receives command packet from the network
// converts it into APB transactions and send to APB slave
// it also receives response transaction and convert them to response packet
// and send back to the master
// ------------------------------------------------------------------------

`timescale 1 ps / 1 ps

module altera_merlin_apb_slave_agent 
  #(
    parameter ADDR_WIDTH                  = 32,
	parameter DATA_WIDTH                  = 32,
    
    // ----------------------------------
    // Packet parameters
    // ----------------------------------
    parameter PKT_SYMBOL_W                = 8,
	parameter PKT_ORI_BURST_SIZE_H        = 120,
    parameter PKT_ORI_BURST_SIZE_L        = 118,
    parameter PKT_QOS_H                   = 117,
    parameter PKT_QOS_L                   = 114,
    parameter PKT_THREAD_ID_H             = 113,
    parameter PKT_THREAD_ID_L             = 112,
    parameter PKT_RESPONSE_STATUS_H       = 111, 
    parameter PKT_RESPONSE_STATUS_L       = 110,
    parameter PKT_BEGIN_BURST             = 109,
    parameter PKT_CACHE_H                 = 108,
    parameter PKT_CACHE_L                 = 105,
    parameter PKT_DATA_SIDEBAND_H         = 104,
    parameter PKT_DATA_SIDEBAND_L         = 97,
    parameter PKT_ADDR_SIDEBAND_H         = 96, 
    parameter PKT_ADDR_SIDEBAND_L         = 92,
    parameter PKT_BURST_TYPE_H            = 91,
    parameter PKT_BURST_TYPE_L            = 90,
    parameter PKT_PROTECTION_H            = 89, 
    parameter PKT_PROTECTION_L            = 87,
    parameter PKT_BURST_SIZE_H            = 86,
    parameter PKT_BURST_SIZE_L            = 84,
    parameter PKT_BURSTWRAP_H             = 83,
    parameter PKT_BURSTWRAP_L             = 81,
    parameter PKT_BYTE_CNT_H              = 80,
    parameter PKT_BYTE_CNT_L              = 78,
    parameter PKT_ADDR_H                  = 77,
    parameter PKT_ADDR_L                  = 46,
    parameter PKT_TRANS_EXCLUSIVE         = 45,
    parameter PKT_TRANS_LOCK              = 44,
    parameter PKT_TRANS_COMPRESSED_READ   = 43,
    parameter PKT_TRANS_POSTED            = 42,
    parameter PKT_TRANS_WRITE             = 41,
    parameter PKT_TRANS_READ              = 40,
    parameter PKT_DATA_H                  = 39,
    parameter PKT_DATA_L                  = 8,
    parameter PKT_BYTEEN_H                = 7,
    parameter PKT_BYTEEN_L                = 4,
    parameter PKT_SRC_ID_H                = 3,
    parameter PKT_SRC_ID_L                = 2,
    parameter PKT_DEST_ID_H               = 1,
    parameter PKT_DEST_ID_L               = 0,

	parameter ST_CHANNEL_W                = 8,
	parameter ST_DATA_W                   = 121,
	parameter MERLIN_PACKET_FORMAT        = "",
	parameter AUTO_CLK_CLOCK_RATE         = "-1"
    
	) 
   (
    // ----------------------------------
    // APB master signals
    // ----------------------------------
	output reg [ADDR_WIDTH-1:0] paddr, 
	// output reg [2:0]                pprot, 
	output reg                  psel, 
	output reg                  penable,
	output reg                  pwrite, 
	output reg [DATA_WIDTH-1:0] pwdata, 
	// output reg [(DATA_WIDTH/8)-1:0] pstrb, 
	input                       pready,
	input [DATA_WIDTH-1:0]      prdata,
	input                       pslverr,
    // APB debug interface
	output reg                  paddr31,

    // ----------------------------------
    // Command packet signals
    // ----------------------------------
	input                       cp_valid, 
	output reg                  cp_ready, 
	input [ST_DATA_W-1:0]       cp_data, 
	input [ST_CHANNEL_W-1:0]    cp_channel,
	input                       cp_startofpacket,
	input                       cp_endofpacket,
    // ----------------------------------
    // Response packet signals
    // ----------------------------------
	output reg                  rp_valid, 
    input                       rp_ready, 
	output reg [ST_DATA_W-1:0]  rp_data, 
	output reg                  rp_startofpacket, 
	output reg                  rp_endofpacket,
    // ----------------------------------
    // Clock reset signals
    // ----------------------------------
	input                       clk, 
	input                       reset 
);
    
    // ------------------------------------------------
    // Local Parameters
    // ------------------------------------------------
    localparam DATA_W       = PKT_DATA_H - PKT_DATA_L + 1;
    localparam BE_W         = PKT_BYTEEN_H - PKT_BYTEEN_L + 1;
    localparam MID_W        = PKT_SRC_ID_H - PKT_SRC_ID_L + 1;
    localparam SID_W        = PKT_DEST_ID_H - PKT_DEST_ID_L + 1;
    localparam BYTE_CNT_W   = PKT_BYTE_CNT_H - PKT_BYTE_CNT_L + 1;
    localparam BURSTWRAP_W  = PKT_BURSTWRAP_H - PKT_BURSTWRAP_L + 1;
    localparam BURSTSIZE_W  = PKT_BURST_SIZE_H - PKT_BURST_SIZE_L + 1;
    localparam RESPONSE_W   = PKT_RESPONSE_STATUS_H - PKT_RESPONSE_STATUS_L + 1;
    localparam PROT_W       = PKT_PROTECTION_H - PKT_PROTECTION_L + 1;
    localparam NUMSYMBOLS   = DATA_WIDTH/PKT_SYMBOL_W;
    localparam BURST_SIZE   = log2ceil(NUMSYMBOLS);
    localparam BITS_TO_MASK = BURST_SIZE;
    
    wire [31:0]bytecount_value_int  = NUMSYMBOLS;
    wire [BURSTSIZE_W-1:0] burst_size           = BURST_SIZE[BURSTSIZE_W-1:0];

    // --------------------------             
    // State machine: declaration
    // --------------------------
    enum        
    {
     IDLE,       
     SET_UP,
     ACCESS,
     SEND_RESPONSE
     } state, next_state;

    // ------------------------------------------------
    // Internal Signals
    // ------------------------------------------------
    wire [DATA_WIDTH-1:0]  cmd_data;
    wire [BE_W-1:0]        cmd_byteen;
    wire [ADDR_WIDTH-1:0]  cmd_addr_in;
    wire [ADDR_WIDTH-1:0]  cmd_addr;
    wire [MID_W-1:0]       cmd_mid;
    wire [SID_W-1:0]       cmd_sid;
    wire                   cmd_read;
    wire                   cmd_write;
    wire                   cmd_posted;
    wire [BURSTWRAP_W-1:0] cmd_burstwrap;
    wire [PROT_W-1:0]      cmd_pprot;
	wire [BURSTSIZE_W-1:0] cmd_ori_burstsize;
	
    reg [DATA_WIDTH-1:0]   cmd_data_reg;
    reg [BE_W-1:0]         cmd_byteen_reg;
    reg [ADDR_WIDTH-1:0]   cmd_addr_reg;
    reg [MID_W-1:0]        cmd_mid_reg;
    reg [SID_W-1:0]        cmd_sid_reg;
    reg                    cmd_write_reg;
    reg                    cmd_posted_reg;
    reg [BURSTWRAP_W-1:0]  cmd_burstwrap_reg;
    reg [PROT_W-1:0]       cmd_pprot_reg;
    reg [ST_DATA_W+1:0]    cp_data_reg;
    reg                    pslverr_reg;
    reg [DATA_WIDTH-1:0]   prdata_reg;
    
    reg                    rp_startofpacket_reg;
    reg                    rp_endofpacket_reg;
    reg                    wr_response_mergered_sop;
    

    // ---------------------------------------------------------
    // Assign command fields
    // ---------------------------------------------------------
    assign cmd_data         = cp_data_reg[PKT_DATA_H  :PKT_DATA_L];
    assign cmd_byteen       = cp_data_reg[PKT_BYTEEN_H:PKT_BYTEEN_L];
    assign cmd_addr_in  = cp_data_reg[PKT_ADDR_H  :PKT_ADDR_L];
    // Align address to size, as APB only can see aligned address
    assign cmd_addr         = {cmd_addr_in[ADDR_WIDTH-1:BITS_TO_MASK], {BITS_TO_MASK{1'b0}}};
    assign cmd_posted       = cp_data_reg[PKT_TRANS_POSTED];
    assign cmd_write        = cp_data_reg[PKT_TRANS_WRITE];
    assign cmd_read         = cp_data_reg[PKT_TRANS_READ];
    assign cmd_mid          = cp_data_reg[PKT_SRC_ID_H :PKT_SRC_ID_L];
    assign cmd_sid          = cp_data_reg[PKT_DEST_ID_H:PKT_DEST_ID_L];
    assign cmd_burstwrap    = cp_data_reg[PKT_BURSTWRAP_H:PKT_BURSTWRAP_L];
    assign cmd_pprot        = cp_data_reg[PKT_PROTECTION_H:PKT_PROTECTION_L];
    assign paddr31          = cp_data_reg[PKT_ADDR_SIDEBAND_H:PKT_ADDR_SIDEBAND_L];
    assign cp_ready         = pready && penable;
	assign cmd_ori_burstsize = cp_data_reg[PKT_ORI_BURST_SIZE_H:PKT_ORI_BURST_SIZE_L];
    
    // ------------------------------------
    // Assign command fields to APB signals
    // ------------------------------------
    always_comb
        begin
            paddr   = cmd_addr;
            pwdata  = cmd_data;
            pwrite  = cmd_write; // When read, cmd_write = 0
            // APB 4 support:APB requires that for read transaction, PSTRB must be 0
            // if (cmd_write)
                // pstrb  = cmd_byteen;
            // else
                // pstrb  = '0;
            
            // pprot      = cmd_pprot;
        end
    
    // --------------------------------------------------------------
    // Store some needed signals for recontructing the response packet
    // Those reg will be updated value when penable == 1, and keep
    // unchanged until next penable asserted, Which will hold value
    // thru rp_valid == 1 when sending response packet
    // --------------------------------------------------------------
    always_ff @(posedge clk or posedge reset)
        begin
            if (reset == 1) 
                begin
                    cp_data_reg    <= '0;
                end 
            else if (next_state == SET_UP) 
                begin
                    cp_data_reg              <= cp_data;
                    cp_data_reg[ST_DATA_W]   <= cp_startofpacket;
                    cp_data_reg[ST_DATA_W+1] <= cp_endofpacket;
                end
        end // always_ff @

    // -------------------------------------------------------------
    // Hold information returned from APB slave to fetch in rp_data 
    // because the master might back-pressure so need to hold rp_data
    // until rp_ready asserted. This to make sure all APB responses still
    // avaiable until master takes response
    // -------------------------------------------------------------
    always_ff @(posedge clk or posedge reset)
        begin
            if (reset == 1) begin
                prdata_reg  <= '0;
                pslverr_reg <= '0;
            end
            else if (pready == 1) begin
                prdata_reg  <= prdata;
                pslverr_reg <= pslverr;
            end
        end // always_ff @
    
    // ------------------------------------
    // Slverror merging
    // ------------------------------------
    reg reset_slverr;
    reg prev_slverr_in;
    reg prev_slverr;
    reg slverr_mergerd;
    
    always_comb
        begin
            reset_slverr    = cp_startofpacket && pready;
            prev_slverr_in  = reset_slverr ? pslverr : prev_slverr;
            slverr_mergerd  = prev_slverr_in | pslverr;
            
        end
    always_ff @(posedge clk or posedge reset)
        begin
            if (reset) 
                prev_slverr <= '0;
            else if (pready)
                prev_slverr <= slverr_mergerd;
            
        end
    
    // ------------------------------------
    // Construct response packet
    // ------------------------------------
      always_comb
          begin
              // Send almost everything back 
              rp_data                                               = cp_data_reg[ST_DATA_W-1:0];
              
              // and over write below
              rp_data[PKT_DATA_H   :PKT_DATA_L]                     = prdata_reg;

              rp_data[PKT_TRANS_POSTED]                             = cmd_posted;
              rp_data[PKT_TRANS_WRITE]                              = cmd_write;
              rp_data[PKT_SRC_ID_H :PKT_SRC_ID_L]                   = cmd_sid;
              rp_data[PKT_DEST_ID_H:PKT_DEST_ID_L]                  = cmd_mid;
              rp_data[PKT_BYTEEN_H :PKT_BYTEEN_L]                   = cmd_byteen;
              rp_data[PKT_PROTECTION_H:PKT_PROTECTION_L]            = cmd_pprot;
  
              rp_data[PKT_ADDR_H   :PKT_ADDR_L]                     = cmd_addr;
              rp_data[PKT_BURSTWRAP_H:PKT_BURSTWRAP_L]              = cmd_burstwrap;
              rp_data[PKT_BYTE_CNT_H:PKT_BYTE_CNT_L]                = bytecount_value_int[BYTE_CNT_W-1:0];
              rp_data[PKT_TRANS_READ]                               = ~cmd_write;
              rp_data[PKT_TRANS_COMPRESSED_READ]                    = '0;
  
              // Use pkt_response_status_h for carry pslverr
              rp_data[PKT_RESPONSE_STATUS_H:PKT_RESPONSE_STATUS_L]  = {RESPONSE_W{ 1'b0 }};
              // If this is write burst, then care about response merging
              // if read then just let responses come back together with readata
              if (cmd_write)
                  rp_data[PKT_RESPONSE_STATUS_H]          = slverr_mergerd;
              else
                  rp_data[PKT_RESPONSE_STATUS_H]          = pslverr_reg;
              rp_data[PKT_BURST_SIZE_H:PKT_BURST_SIZE_L]  = burst_size;
			  // return original burst size
			  rp_data[PKT_ORI_BURST_SIZE_H:PKT_ORI_BURST_SIZE_L]  = cmd_ori_burstsize;
          end // always_comb
    
    // -------------------------------------------------
    // Response signals: send sop and eop back to master
    // -------------------------------------------------
    assign rp_startofpacket  = rp_startofpacket_reg | wr_response_mergered_sop;
    assign rp_endofpacket    = rp_endofpacket_reg;
    
    always_ff @(posedge clk or posedge reset)
        begin
            if (reset) begin
                rp_startofpacket_reg <= '0;
                rp_endofpacket_reg   <= '0;
            end else if (cp_valid && cp_ready) begin
                rp_startofpacket_reg <= cp_startofpacket;
                rp_endofpacket_reg   <= cp_endofpacket;
            end
        end
    always_comb
        begin
            // In case write response merging happened, generate sop for response packet
            if (rp_endofpacket && cmd_write)
                wr_response_mergered_sop  = '1;
            else
                wr_response_mergered_sop  = '0;
            
        end

    // --------------------------             
    // State machine: update state
    // --------------------------            
    always_ff @(posedge clk, posedge reset)
        begin
            if (reset)
                state <= IDLE;
            else
                state <= next_state;
        end
               
    // -----------------------------------             
    // State machine: next state condition
    // -----------------------------------
    always_comb 
        begin
            case(state)
                IDLE:
                    if (cp_valid == 1)
                        next_state  = SET_UP;
                    else
                        next_state  = IDLE;
                SET_UP:
                        next_state  = ACCESS;
                ACCESS:
                    if (pready == 0)
                        next_state  = ACCESS;
                    else begin
                        if (cmd_posted == 1) // No request on response (Avalon write transaction)
                            next_state  = IDLE;
                        else // Need to send response back (AXI, APB, Avalon read transactions)
                            begin
                                if (cmd_read)
                                    next_state  = SEND_RESPONSE;
                                else begin 
                                    if (cp_endofpacket)
                                        next_state  = SEND_RESPONSE;
                                    else
                                        next_state  = IDLE;
                                end
                            end
                    end
                SEND_RESPONSE:
                    if (rp_ready == 1)
                        next_state  = IDLE;
                    else
                        next_state  = SEND_RESPONSE;
            endcase // case (state)
        end // always_comb
    
    // -----------------------------------             
    // State machine: state output logic
    // -----------------------------------
    always_comb
        begin
            case(state)
                IDLE: begin
                    psel        = '0;
                    penable     = '0;
                    rp_valid    = '0;
                end
                SET_UP: begin
                    psel        = '1;
                    penable     = '0;
                    rp_valid    = '0;
                end
                ACCESS: begin
                    psel      = '1;
                    penable   = '1;
                    rp_valid  = '0;
                end
                SEND_RESPONSE: begin
                    psel      = '0;
                    penable   = '0;
                    rp_valid  = '1;
                end
                
            endcase
        end // always_comb

    
    // --------------------------------------------------
    // Ceil(log2()) function log2ceil of 4 = 2
    // --------------------------------------------------
    function integer log2ceil;
        input reg [63:0] val;
        reg [63:0]       i;
        
        begin
            i = 1;
            log2ceil = 0;
            while (i < val) begin
                log2ceil = log2ceil + 1;
                i = i << 1;
            end
        end
    endfunction 
    

endmodule
