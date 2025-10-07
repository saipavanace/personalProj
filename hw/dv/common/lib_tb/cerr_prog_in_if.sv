//////////////////////////TB_  cerr_prog_in_if ////////////////////////
//DUT interfaces
//////////////////////////////////////////////////////////////////
interface cerr_prog_in_if(input bist_clk, input reset_n);

  logic cerr_threshold_vld; 
  logic cerr_threshold_ack;
  logic[7:0] cerr_threshold;
  
  clocking cb @(posedge bist_clk);
    inout cerr_threshold_vld;
    inout cerr_threshold_ack;
    inout cerr_threshold;
  endclocking
  
  modport mon_mp (clocking cb);

endinterface: cerr_prog_in_if


