# (C) 2001-2017 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel MegaCore Function License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


############################################################################
# False path the clock crossing write and read pointers
############################################################################
#set fifo_wr_ptrs [get_keepers *cvi*_mixed_widths_fifo:*dcfifo*delayed_wrptr_g[*]]
#set fifo_dgwps   [get_keepers *cvi*_mixed_widths_fifo:*dcfifo*rs_dgwp*]
#foreach_in_collection wr_ptr $fifo_wr_ptrs {
#    foreach_in_collection dgwps $fifo_dgwps {
#        set_false_path -from $wr_ptr -to $dgwps
#    }
#}

#set fifo_rd_ptrs [get_keepers *cvi*_mixed_widths_fifo:*dcfifo*rdptr_g[*]]
#set fifo_dgrp [get_keepers *cvi*_mixed_widths_fifo:*dcfifo*ws_dgrp*]
#foreach_in_collection rd_ptr $fifo_rd_ptrs {
#    foreach_in_collection dgrp $fifo_dgrp {
#        set_false_path -from $rd_ptr -to $dgrp
#    }
#}

set_false_path -to [get_pins -compatibility_mode *cvi_core*rst_vid_clk*clrn]