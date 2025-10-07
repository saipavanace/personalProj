////////////////////////////////////////////////////////////////////////////////
//
// TT Agent Package
//
////////////////////////////////////////////////////////////////////////////////
package <%=obj.BlockId%>_tt_agent_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import <%=obj.BlockId%>_smi_agent_pkg::*;
    `include "<%=obj.BlockId%>_dmi_tt_txn.svh"
    `include "<%=obj.BlockId%>_dmi_tt_agent_config.svh"
    `include "<%=obj.BlockId%>_dmi_tt_monitor.svh"
    `include "<%=obj.BlockId%>_dmi_tt_agent.svh"

endpackage : <%=obj.BlockId%>_tt_agent_pkg
