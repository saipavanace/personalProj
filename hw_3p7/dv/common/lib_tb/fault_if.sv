//////////////////////////TB_  fault_if ////////////////////////
//DUT interfaces
//////////////////////////////////////////////////////////////////

`ifndef _GUARD_FAULT_IF_SV_
`define _GUARD_FAULT_IF_SV_
interface fault_if;

  logic mission_fault; 
  logic latent_fault;
  logic cerr_over_thres_fault;
<% if(obj.testBench=="fsys") { %>
  logic clk;
<% } %>
  
endinterface: fault_if

interface bist_if;

  logic pin; 
<% if(obj.testBench=="fsys") { %>
  logic bist_next_ack;
  logic bist_next;
  logic clk;
<% } %>
  
endinterface: bist_if
`endif 
