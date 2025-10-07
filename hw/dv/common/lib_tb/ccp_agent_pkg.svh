
////////////////////////////////////////////////////////////////////////////////
//
// CCP Agent Package
//
////////////////////////////////////////////////////////////////////////////////

package <%=obj.BlockId%>_ccp_agent_pkg;
   import uvm_pkg::*;
`include "uvm_macros.svh"
//   import <%=obj.BlockId%>_ConcertoPkg::*;
    import ncore_config_pkg::*;
    import addr_trans_mgr_pkg::*;
//`include "<%=obj.BlockId%>_ConcertoParams.svh";

`include "<%=obj.BlockId%>_ccp_widths.svh";
`include "<%=obj.BlockId%>_ccp_types.svh";   
`include "<%=obj.BlockId%>_ccp_cache_model.sv";
`include "<%=obj.BlockId%>_ccp_helper.svh";   
`include "<%=obj.BlockId%>_ccp_txn.svh";   
`include "<%=obj.BlockId%>_ccp_agent_config.svh";   
`include "<%=obj.BlockId%>_ccp_seq_item.svh";   
`include "<%=obj.BlockId%>_ccp_sequencer.svh";   
`include "<%=obj.BlockId%>_ccp_monitor.svh";   
`include "<%=obj.BlockId%>_ccp_driver.svh";   
`include "<%=obj.BlockId%>_ccp_agent.svh";   
`include "<%=obj.BlockId%>_ccp_plru_predictor.sv";   
//`include "<%=obj.BlockId%>_ccp_seq.svh";   
endpackage: <%=obj.BlockId%>_ccp_agent_pkg
/*
package ccp_agent_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `include "ccp_widths.svh"
  `include "ccp_types.svh"
  `include "ccp_txn.svh"
  `include "ccp_agent_config.svh"
  `include "ccp_seq_item.svh"
  `include "ccp_monitor.svh"
  `include "ccp_sequencer.svh"
  `include "ccp_driver.svh"
  `include "ccp_agent.svh"

endpackage : ccp_agent_pkg
*/
