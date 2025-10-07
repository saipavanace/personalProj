// The entire notice above must be reproduced on all authorized copies.
//----------------------------------------------------------------------------------------------------------------
// File     : snoop_filter_if.sv
// Author   : yramasamy
// Notes    : interface file to monitor the snoop filter
//----------------------------------------------------------------------------------------------------------------

`ifndef __SNOOP_FILTER_IF_SV__
`define __SNOOP_FILTER_IF_SV__

interface snoop_filter_if
   #(parameter  NSETS           =   64  ,
     parameter  NWAYS           =    4  ,
     parameter  BYTES_PER_LINE  =    8  ) ();
    
    // snoop filter signals
    logic                        clk;
    logic                        rst_n;
    logic                        mnt_ops;
    logic                        cen;
    logic                        wen;
    logic [             63 : 0]  data;
    logic [$clog2(NSETS)-1 : 0]  set_index;

    // clocking block
    clocking posedge_monitor_cb @(posedge clk);
        default input #1step output #1ns;
        input   mnt_ops;
        input   cen;
        input   wen;
        input   data;
        input   set_index;
    endclocking: posedge_monitor_cb

    clocking negedge_monitor_cb @(negedge clk);
        default input #1step output #1ns;
        input   mnt_ops;
        input   cen;
        input   wen;
        input   data;
        input   set_index;
    endclocking: negedge_monitor_cb
endinterface: snoop_filter_if

`endif
