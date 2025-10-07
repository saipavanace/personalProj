//////////////////////////TB_  fltc_out_if ////////////////////////
//DUT interfaces
//////////////////////////////////////////////////////////////////
interface fltc_out_if #(int WIDTH=1024) (input clk, input reset_n);

  logic observed_value; 
  logic reset_n_delay;
  
  clocking cb @(posedge clk);
    inout observed_value;
    inout reset_n_delay;
  endclocking
  
  modport mon_mp (clocking cb);

endinterface: fltc_out_if

