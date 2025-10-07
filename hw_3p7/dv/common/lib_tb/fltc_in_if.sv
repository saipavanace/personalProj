//////////////////////////TB_  fltc_in_if ////////////////////////
//DUT interfaces
//////////////////////////////////////////////////////////////////
interface fltc_in_if #(int WIDTH=1024) (input clk, input reset_n);

  logic[WIDTH-1:0] func;
  logic[WIDTH-1:0] check;
  logic[WIDTH-1:0] latent_error_func;
  logic[WIDTH-1:0] latent_error_check;
  logic cerr_func;
  logic cerr_check;
  logic latent_fault_tree; 
  logic reset_n_delay;
  
  
  clocking cb @(posedge clk);
    inout func;
    inout check;
    inout latent_error_func;
    inout latent_error_check;
    inout cerr_func;
    inout cerr_check;
    inout latent_fault_tree;
    inout reset_n_delay;
  endclocking
  
  modport mon_mp (clocking cb);

endinterface: fltc_in_if

