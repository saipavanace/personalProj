////////////////////////////////////////////////////////////////////////////////
//
// SFI Agent Package
//
////////////////////////////////////////////////////////////////////////////////
package <%=obj.BlockId%>_rtl_agent_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
    `include "<%=obj.BlockId%>_dmi_rtl_txn.svh"
    `include "<%=obj.BlockId%>_dmi_rtl_agent_config.svh"
    `include "<%=obj.BlockId%>_dmi_rtl_monitor.svh"
    `include "<%=obj.BlockId%>_dmi_rtl_agent.svh"

endpackage : <%=obj.BlockId%>_rtl_agent_pkg
