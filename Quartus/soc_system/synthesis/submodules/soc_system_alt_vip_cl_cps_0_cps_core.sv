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


// The Terp wrapper for the cps algorithmic core

module soc_system_alt_vip_cl_cps_0_cps_core

    (  clock,
       reset,

       // Avalon-ST message data sinks(s)
       av_st_din_0_ready,
       av_st_din_0_valid,
       av_st_din_0_data,
       av_st_din_0_startofpacket,
       av_st_din_0_endofpacket,

       av_st_din_1_ready,
       av_st_din_1_valid,
       av_st_din_1_data,
       av_st_din_1_startofpacket,
       av_st_din_1_endofpacket,

       // Avalon-ST message data source(s)
       av_st_dout_0_ready,
       av_st_dout_0_valid,
       av_st_dout_0_data,
       av_st_dout_0_startofpacket,
       av_st_dout_0_endofpacket,

       av_st_dout_1_ready,
       av_st_dout_1_valid,
       av_st_dout_1_data,
       av_st_dout_1_startofpacket,
       av_st_dout_1_endofpacket
   );

   import alt_vip_common_pkg::*;
    
   //input and output data width
   parameter  BITS_PER_SYMBOL                       =  8;

   parameter  NUMBER_OF_INPUTS                      =  1;
   parameter  NUMBER_OF_OUTPUTS                     =  1;

   parameter  INPUT_0_NUMBER_OF_COLOR_PLANES        =  3;
   parameter  INPUT_0_COLOR_PLANES_ARE_IN_PARALLEL  =  1;
   parameter  INPUT_0_PIXELS_IN_PARALLEL            =  1;
   parameter  INPUT_0_TWO_PIXELS_PATTERN            =  0;

   parameter  INPUT_1_NUMBER_OF_COLOR_PLANES        =  3;
   parameter  INPUT_1_COLOR_PLANES_ARE_IN_PARALLEL  =  1;
   parameter  INPUT_1_PIXELS_IN_PARALLEL            =  1;
   parameter  INPUT_1_TWO_PIXELS_PATTERN            =  0;

   parameter  OUTPUT_0_NUMBER_OF_COLOR_PLANES       =  3;
   parameter  OUTPUT_0_COLOR_PLANES_ARE_IN_PARALLEL =  1;
   parameter  OUTPUT_0_PIXELS_IN_PARALLEL           =  1;
   parameter  OUTPUT_0_TWO_PIXELS_PATTERN           =  0;

   parameter  OUTPUT_1_NUMBER_OF_COLOR_PLANES       =  3;
   parameter  OUTPUT_1_COLOR_PLANES_ARE_IN_PARALLEL =  1;
   parameter  OUTPUT_1_PIXELS_IN_PARALLEL           =  1;
   parameter  OUTPUT_1_TWO_PIXELS_PATTERN           =  0;

   // Select whether outputs are pipelined (ignored if FIFOs turned on as ready is always registered)
   parameter  PIPELINE_READY                        =  0;
 
   // Parameters to configure the avalon-st message interfaces
   parameter  SRC_WIDTH                             =  8;
   parameter  DST_WIDTH                             =  8;
   parameter  CONTEXT_WIDTH                         =  8;
   parameter  TASK_WIDTH                            =  8;
   
   // Derived parameter, must match individual ??_PIXELS_IN_PARALLEL and ??_TWO_PIXELS_PATTERN
   parameter  NUMBER_ROUTING_ENGINES                = 1;
   
   

   // Input/output port sizes
   localparam INPUT_0_PIX_WIDTH           =  BITS_PER_SYMBOL * ((INPUT_0_COLOR_PLANES_ARE_IN_PARALLEL == 1) ? INPUT_0_NUMBER_OF_COLOR_PLANES : 1);
   localparam INPUT_1_PIX_WIDTH           =  BITS_PER_SYMBOL * ((INPUT_1_COLOR_PLANES_ARE_IN_PARALLEL == 1) ? INPUT_1_NUMBER_OF_COLOR_PLANES : 1);
   localparam OUTPUT_0_PIX_WIDTH          =  BITS_PER_SYMBOL * ((OUTPUT_0_COLOR_PLANES_ARE_IN_PARALLEL == 1) ? OUTPUT_0_NUMBER_OF_COLOR_PLANES : 1);
   localparam OUTPUT_1_PIX_WIDTH          =  BITS_PER_SYMBOL * ((OUTPUT_1_COLOR_PLANES_ARE_IN_PARALLEL == 1) ? OUTPUT_1_NUMBER_OF_COLOR_PLANES : 1);

   localparam INPUT_0_EMPTY_WIDTH         =  (INPUT_0_PIXELS_IN_PARALLEL > 1)  ?  alt_clogb2_pure(INPUT_0_PIXELS_IN_PARALLEL) : 0;
   localparam INPUT_1_EMPTY_WIDTH         =  (INPUT_1_PIXELS_IN_PARALLEL > 1)  ?  alt_clogb2_pure(INPUT_1_PIXELS_IN_PARALLEL) : 0;
   localparam OUTPUT_0_EMPTY_WIDTH        =  (OUTPUT_0_PIXELS_IN_PARALLEL > 1) ? alt_clogb2_pure(OUTPUT_0_PIXELS_IN_PARALLEL) : 0;
   localparam OUTPUT_1_EMPTY_WIDTH        =  (OUTPUT_1_PIXELS_IN_PARALLEL > 1) ? alt_clogb2_pure(OUTPUT_1_PIXELS_IN_PARALLEL) : 0;

   localparam CTRL_WIDTH                  =  SRC_WIDTH + DST_WIDTH + CONTEXT_WIDTH + TASK_WIDTH;
   localparam INPUT_0_TOTAL_WIDTH         =  (INPUT_0_PIX_WIDTH * INPUT_0_PIXELS_IN_PARALLEL)   + CTRL_WIDTH + 2*INPUT_0_EMPTY_WIDTH; 
   localparam INPUT_1_TOTAL_WIDTH         =  (INPUT_1_PIX_WIDTH * INPUT_1_PIXELS_IN_PARALLEL)   + CTRL_WIDTH + 2*INPUT_1_EMPTY_WIDTH; 
   localparam OUTPUT_0_TOTAL_WIDTH        =  (OUTPUT_0_PIX_WIDTH * OUTPUT_0_PIXELS_IN_PARALLEL) + CTRL_WIDTH + 2*OUTPUT_0_EMPTY_WIDTH; 
   localparam OUTPUT_1_TOTAL_WIDTH        =  (OUTPUT_1_PIX_WIDTH * OUTPUT_1_PIXELS_IN_PARALLEL) + CTRL_WIDTH + 2*OUTPUT_1_EMPTY_WIDTH;

   // Templated patterns
   localparam            OUTPUT_0_PATTERN_SIZE                           = 3;
   localparam  integer   OUTPUT_0_PATTERN [OUTPUT_0_PATTERN_SIZE]        = '{ 0,1,2 };
   localparam            OUTPUT_1_PATTERN_SIZE                           = 1;
   localparam  integer   OUTPUT_1_PATTERN [OUTPUT_1_PATTERN_SIZE]        = '{0};

   input   wire                                                      clock;
   input   wire                                                      reset;

   //din_0 interface
   output  wire                                                      av_st_din_0_ready;
   input   wire                                                      av_st_din_0_valid;
   input   wire   [INPUT_0_TOTAL_WIDTH - 1 : 0]                      av_st_din_0_data;
   input   wire                                                      av_st_din_0_startofpacket;
   input   wire                                                      av_st_din_0_endofpacket;
   //din_1 interface
   output  wire                                                      av_st_din_1_ready;
   input   wire                                                      av_st_din_1_valid;
   input   wire   [INPUT_1_TOTAL_WIDTH - 1 : 0]                      av_st_din_1_data;
   input   wire                                                      av_st_din_1_startofpacket;
   input   wire                                                      av_st_din_1_endofpacket;

   //dout_0 interface
   input   wire                                                      av_st_dout_0_ready;
   output  wire                                                      av_st_dout_0_valid;
   output  wire   [OUTPUT_0_TOTAL_WIDTH - 1 : 0]                     av_st_dout_0_data;
   output  wire                                                      av_st_dout_0_startofpacket;
   output  wire                                                      av_st_dout_0_endofpacket;
   //dout_1 interface
   input   wire                                                      av_st_dout_1_ready;
   output  wire                                                      av_st_dout_1_valid;
   output  wire   [OUTPUT_1_TOTAL_WIDTH - 1 : 0]                     av_st_dout_1_data;
   output  wire                                                      av_st_dout_1_startofpacket;
   output  wire                                                      av_st_dout_1_endofpacket;


   alt_vip_cps_alg_core # (
      .BITS_PER_SYMBOL                         (BITS_PER_SYMBOL),
      .NUMBER_OF_INPUTS                        (NUMBER_OF_INPUTS),
      .NUMBER_OF_OUTPUTS                       (NUMBER_OF_OUTPUTS),
      .INPUT_0_NUMBER_OF_COLOR_PLANES          (INPUT_0_NUMBER_OF_COLOR_PLANES),
      .INPUT_0_COLOR_PLANES_ARE_IN_PARALLEL    (INPUT_0_COLOR_PLANES_ARE_IN_PARALLEL),
      .INPUT_0_PIXELS_IN_PARALLEL              (INPUT_0_PIXELS_IN_PARALLEL),
      .INPUT_0_TWO_PIXELS_PATTERN              (INPUT_0_TWO_PIXELS_PATTERN),
      .INPUT_1_NUMBER_OF_COLOR_PLANES          (INPUT_1_NUMBER_OF_COLOR_PLANES),
      .INPUT_1_COLOR_PLANES_ARE_IN_PARALLEL    (INPUT_1_COLOR_PLANES_ARE_IN_PARALLEL),
      .INPUT_1_PIXELS_IN_PARALLEL              (INPUT_1_PIXELS_IN_PARALLEL),
      .INPUT_1_TWO_PIXELS_PATTERN              (INPUT_1_TWO_PIXELS_PATTERN),
      .OUTPUT_0_NUMBER_OF_COLOR_PLANES         (OUTPUT_0_NUMBER_OF_COLOR_PLANES),
      .OUTPUT_0_COLOR_PLANES_ARE_IN_PARALLEL   (OUTPUT_0_COLOR_PLANES_ARE_IN_PARALLEL),
      .OUTPUT_0_PIXELS_IN_PARALLEL             (OUTPUT_0_PIXELS_IN_PARALLEL),
      .OUTPUT_0_TWO_PIXELS_PATTERN             (OUTPUT_0_TWO_PIXELS_PATTERN),
      .OUTPUT_1_NUMBER_OF_COLOR_PLANES         (OUTPUT_1_NUMBER_OF_COLOR_PLANES),
      .OUTPUT_1_COLOR_PLANES_ARE_IN_PARALLEL   (OUTPUT_1_COLOR_PLANES_ARE_IN_PARALLEL),
      .OUTPUT_1_PIXELS_IN_PARALLEL             (OUTPUT_1_PIXELS_IN_PARALLEL),
      .OUTPUT_1_TWO_PIXELS_PATTERN             (OUTPUT_1_TWO_PIXELS_PATTERN),
      .OUTPUT_0_PATTERN_SIZE                   (OUTPUT_0_PATTERN_SIZE),
      .OUTPUT_0_PATTERN                        (OUTPUT_0_PATTERN),
      .OUTPUT_1_PATTERN_SIZE                   (OUTPUT_1_PATTERN_SIZE),
      .OUTPUT_1_PATTERN                        (OUTPUT_1_PATTERN),
      .PIPELINE_READY                          (PIPELINE_READY),
      .SRC_WIDTH                               (SRC_WIDTH),
      .DST_WIDTH                               (DST_WIDTH),
      .CONTEXT_WIDTH                           (CONTEXT_WIDTH),
      .TASK_WIDTH                              (TASK_WIDTH),
      .NUMBER_ROUTING_ENGINES                  (NUMBER_ROUTING_ENGINES)
   ) alg_core (
      .clock                       (clock),
      .reset                       (reset),
      .av_st_din_0_ready           (av_st_din_0_ready),
      .av_st_din_0_valid           (av_st_din_0_valid),
      .av_st_din_0_data            (av_st_din_0_data),
      .av_st_din_0_startofpacket   (av_st_din_0_startofpacket),
      .av_st_din_0_endofpacket     (av_st_din_0_endofpacket),
      .av_st_din_1_ready           (av_st_din_1_ready),
      .av_st_din_1_valid           (av_st_din_1_valid),
      .av_st_din_1_data            (av_st_din_1_data),
      .av_st_din_1_startofpacket   (av_st_din_1_startofpacket),
      .av_st_din_1_endofpacket     (av_st_din_1_endofpacket),
      .av_st_dout_0_ready          (av_st_dout_0_ready),
      .av_st_dout_0_valid          (av_st_dout_0_valid),
      .av_st_dout_0_data           (av_st_dout_0_data),
      .av_st_dout_0_startofpacket  (av_st_dout_0_startofpacket),
      .av_st_dout_0_endofpacket    (av_st_dout_0_endofpacket),
      .av_st_dout_1_ready          (av_st_dout_1_ready),
      .av_st_dout_1_valid          (av_st_dout_1_valid),
      .av_st_dout_1_data           (av_st_dout_1_data),
      .av_st_dout_1_startofpacket  (av_st_dout_1_startofpacket),
      .av_st_dout_1_endofpacket    (av_st_dout_1_endofpacket)
   );

endmodule
                    
            


