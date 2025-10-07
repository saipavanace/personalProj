
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------

/**
 * Abstract:
 * Defines an interface that will drive dce/dmi/dii_connectivity interface signals of DUT .
 */

`ifndef  GUARD_GLOBAL_CONNECTIVITY_IF_SV
`define  GUARD_GLOBAL_CONNECTIVITY_IF_SV
 import uvm_pkg::*;
`endif
`ifndef  <%=obj.BlockId%>_GUARD_GLOBAL_CONNECTIVITY_IF_SV
`define  <%=obj.BlockId%>_GUARD_GLOBAL_CONNECTIVITY_IF_SV


interface <%=obj.BlockId%>_connectivity_if ();
 import <%=obj.BlockId%>_connectivity_defines::*;

  bit test_connectivity_test;
  
  logic clk;
  logic rst_n;
  logic force_rst_n;

  logic ott_busy;

  logic [7:0] ott_entries;

  <% for (var i=0; i<obj.nDCEs; i++) {%>
  bit [2:0] XAIUCCR<%=i%>_DCECounterState;
  <%}%>
  <% for (var i=0; i<obj.nDMIs; i++) {%>
  bit [2:0] XAIUCCR<%=i%>_DMICounterState;
  <%}%>
  <% for (var i=0; i<obj.nDIIs; i++) {%>
  bit [2:0] XAIUCCR<%=i%>_DIICounterState;
  <%}%>

  AiuDce_connectivity_vec_type AiuDce_connectivity_vec;
  AiuDmi_connectivity_vec_type AiuDmi_connectivity_vec;
  AiuDii_connectivity_vec_type AiuDii_connectivity_vec;
  AiuConnectedDceFunitId_type  AiuConnectedDceFunitId;

  uint64_type main_seq_iter;
  uint64_type csr_seq_iter;
<% if (obj.testBench != "fsys") { %>
  initial begin
    wait (clk);
    if($test$plusargs("test_connectivity_test") || test_connectivity_test) begin

      if (! $value$plusargs("hexAiuDceDefault=0x%0h", AiuDce_connectivity_vec)) 
        AiuDce_connectivity_vec = AiuDce_connectivity_vec_default; 
      if (! $value$plusargs("hexAiuDmiDefault=0x%0h", AiuDmi_connectivity_vec))
        AiuDmi_connectivity_vec = AiuDmi_connectivity_vec_default;
      if (! $value$plusargs("hexAiuDiiDefault=0x%0h", AiuDii_connectivity_vec))
        AiuDii_connectivity_vec = AiuDii_connectivity_vec_default;
  
    end else begin
      AiuDce_connectivity_vec = 'h<%=obj.AiuInfo[obj.Id].hexAiuDceVec%>; //'
      AiuDmi_connectivity_vec = 'h<%=obj.AiuInfo[obj.Id].hexAiuDmiVec%>; //'
      AiuDii_connectivity_vec = 'h<%=obj.AiuInfo[obj.Id].hexAiuDiiVec%>; //'
      //JSON vector value is bit reversed
      AiuDce_connectivity_vec = {<<{AiuDce_connectivity_vec}}; 
      AiuDmi_connectivity_vec = {<<{AiuDmi_connectivity_vec}}; 
      AiuDii_connectivity_vec = {<<{AiuDii_connectivity_vec}}; 
    end 

    AiuConnectedDceFunitId = AiuConnectedDceFunitId_default;
  end
<%}%>
endinterface

`endif // GUARD_GLOBAL_CONNECTIVITY_IF_SV
