
////////////////////////////////////////////////////////////////////////////////
//
// CCP Agent Package
//
////////////////////////////////////////////////////////////////////////////////

package <%=obj.BlockId%>_ccp_agent_pkg;
   import uvm_pkg::*;
`include "uvm_macros.svh";
//   import addr_trans_mgr_pkg::*;
`include "<%=obj.BlockId%>_ccp_widths.svh";
`include "<%=obj.BlockId%>_ccp_types.svh";   
`include "<%=obj.BlockId%>_ccp_cache_model.sv";
`include "<%=obj.BlockId%>_ccp_helper.svh";   
`include "<%=obj.BlockId%>_ccp_txn.svh";   
`include "<%=obj.BlockId%>_ccp_agent_config.svh";   
`include "<%=obj.BlockId%>_ccp_seq_item.svh";
`include "<%=obj.BlockId%>_ccp_sequencer.svh";   
`include "<%=obj.BlockId%>_ccp_seq.svh";
`include "<%=obj.BlockId%>_ccp_monitor.svh";   
`include "<%=obj.BlockId%>_ccp_driver.svh";   
`include "<%=obj.BlockId%>_ccp_agent.svh";   

endpackage: <%=obj.BlockId%>_ccp_agent_pkg

