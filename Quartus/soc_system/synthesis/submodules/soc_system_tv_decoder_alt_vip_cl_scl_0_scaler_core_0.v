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


module soc_system_tv_decoder_alt_vip_cl_scl_0_scaler_core_0
(        
    input   wire   av_st_din_valid,
    input   wire   av_st_din_startofpacket,
    input   wire   av_st_din_endofpacket,
    input   wire   [80 - 1 : 0] av_st_din_data,
    input   wire   av_st_line_cmd_valid,
    input   wire   av_st_line_cmd_startofpacket,
    input   wire   av_st_line_cmd_endofpacket,
    input   wire   [64 - 1 : 0] av_st_line_cmd_data,
    input   wire   av_st_dout_ready,
    output  wire   av_st_din_ready,
    output  wire   av_st_line_cmd_ready,
    output  wire   av_st_dout_valid,
    output  wire   av_st_dout_startofpacket,
    output  wire   av_st_dout_endofpacket,
    output  wire   [56 - 1 : 0] av_st_dout_data,
    input   wire   clock,
    input   wire   reset
);

    wire   av_st_coeff_valid;
    wire   av_st_coeff_startofpacket;
    wire   av_st_coeff_endofpacket;
    wire   [1 - 1 : 0] av_st_coeff_data;
    wire   av_st_coeff_ready;
    wire   av_st_coeff_cmd_valid;
    wire   av_st_coeff_cmd_startofpacket;
    wire   av_st_coeff_cmd_endofpacket;
    wire   [64 - 1 : 0] av_st_coeff_cmd_data;
    wire   av_st_coeff_cmd_ready;

alt_vip_scaler_alg_core # (
   .NUMBER_OF_COLOR_PLANES               (3),
   .COLOR_PLANES_ARE_IN_PARALLEL         (1),
   .BITS_PER_SYMBOL                      (8),
   .IS_422                               (0),
   .MAX_IN_WIDTH                         (720),
   .MAX_OUT_WIDTH                        (1024),
   .ALGORITHM_NAME                       ("BILINEAR"),
   .PARTIAL_LINE_SCALING                 (0),
   .LEFT_MIRROR                          (1),
   .RIGHT_MIRROR                         (1),
   .H_TAPS                               (2),
   .V_TAPS                               (2),
   .H_PHASES                             (16),
   .V_PHASES                             (16),
   .V_SIGNED                             (0),
   .V_INTEGER_BITS                       (0),
   .V_FRACTION_BITS                      (7),
   .H_SIGNED                             (0),
   .H_INTEGER_BITS                       (0),
   .H_FRACTION_BITS                      (7),
   .H_KERNEL_BITS                        (8),
   .LOAD_AT_RUNTIME                      (0),
   .RUNTIME_CONTROL                      (1),
   .ARE_IDENTICAL                        (1),
   .V_BANKS                              (1),
   .V_SYMMETRIC                          (0),
   .H_BANKS                              (1),
   .H_SYMMETRIC                          (0),
   .SRC_WIDTH                            (8),
   .DST_WIDTH                            (8),
   .CONTEXT_WIDTH                        (8),
   .TASK_WIDTH                           (8),
   .DOUT_SRC_ADDRESS                     (0),
   .COEFF_FILE                           ("soc_system_tv_decoder_alt_vip_cl_scl_0_scaler_core_0_coeff.mif"),
   .EXTRA_PIPELINE_REG                   (1),
   .CYCLONE_STYLE                        (0),
   .V_SERIES_STYLE                       (1),
   .SHIFTED_MIRROR                       (0)
) scaler_core_inst (
   .clock                         (clock),
   .reset                         (reset),
   .av_st_din_ready               (av_st_din_ready),
   .av_st_din_valid               (av_st_din_valid),
   .av_st_din_startofpacket       (av_st_din_startofpacket),
   .av_st_din_endofpacket         (av_st_din_endofpacket),
   .av_st_din_data                (av_st_din_data),
   .av_st_coeff_ready             (av_st_coeff_ready),
   .av_st_coeff_valid             (av_st_coeff_valid),
   .av_st_coeff_startofpacket     (av_st_coeff_startofpacket),
   .av_st_coeff_endofpacket       (av_st_coeff_endofpacket),
   .av_st_coeff_data              (av_st_coeff_data),
   .av_st_line_cmd_ready          (av_st_line_cmd_ready),
   .av_st_line_cmd_valid          (av_st_line_cmd_valid),
   .av_st_line_cmd_startofpacket  (av_st_line_cmd_startofpacket),
   .av_st_line_cmd_endofpacket    (av_st_line_cmd_endofpacket),
   .av_st_line_cmd_data           (av_st_line_cmd_data),
   .av_st_coeff_cmd_ready         (av_st_coeff_cmd_ready),
   .av_st_coeff_cmd_valid         (av_st_coeff_cmd_valid),
   .av_st_coeff_cmd_startofpacket (av_st_coeff_cmd_startofpacket),
   .av_st_coeff_cmd_endofpacket   (av_st_coeff_cmd_endofpacket),
   .av_st_coeff_cmd_data          (av_st_coeff_cmd_data),
   .av_st_dout_ready              (av_st_dout_ready),
   .av_st_dout_valid              (av_st_dout_valid),
   .av_st_dout_startofpacket      (av_st_dout_startofpacket),
   .av_st_dout_endofpacket        (av_st_dout_endofpacket),
   .av_st_dout_data               (av_st_dout_data)
);

endmodule

