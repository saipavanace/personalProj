////////////////////////////////////////////////////////////////////////////////
//
// APB Agent Package
//
////////////////////////////////////////////////////////////////////////////////
package <%=obj.BlockId%>_apb_agent_pkg;

import uvm_pkg::*;
//import addr_trans_mgr_pkg::*;
`include "uvm_macros.svh"


`include "<%=obj.BlockId%>_apb_widths.svh"
`include "<%=obj.BlockId%>_apb_types.svh"
`include "<%=obj.BlockId%>_apb_txn.svh"
`include "<%=obj.BlockId%>_apb_driver.svh"
`include "<%=obj.BlockId%>_apb_monitor.svh"
`include "<%=obj.BlockId%>_apb_sequencer.svh"
`include "<%=obj.BlockId%>_apb_reg_adapter.sv"
`include "<%=obj.BlockId%>_apb_agent_config.svh"
`include "<%=obj.BlockId%>_apb_agent.svh"

endpackage : <%=obj.BlockId%>_apb_agent_pkg
