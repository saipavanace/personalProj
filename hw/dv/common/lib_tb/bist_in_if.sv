//////////////////////////TB_  bist_if ////////////////////////
//DUT interfaces
//////////////////////////////////////////////////////////////////
interface bist_in_if(input bist_clk, input reset_n);

  logic bist_next; 
  logic bist_next_ack;
  
  clocking cb @(posedge bist_clk);
    inout bist_next;
    inout bist_next_ack;
  endclocking
  
  modport mon_mp (clocking cb);

endinterface: bist_in_if


