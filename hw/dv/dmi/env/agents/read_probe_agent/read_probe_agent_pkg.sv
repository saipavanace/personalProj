////////////////////////////////////////////////////////////////////////////////
//
// SFI Agent Package
//
////////////////////////////////////////////////////////////////////////////////
package <%=obj.BlockId%>_read_probe_agent_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

    `include "<%=obj.BlockId%>_read_probe_txn.svh"
    `include "<%=obj.BlockId%>_read_probe_agent_config.svh"
    `include "<%=obj.BlockId%>_read_probe_monitor.svh"
    `include "<%=obj.BlockId%>_read_probe_agent.svh"

endpackage : <%=obj.BlockId%>_read_probe_agent_pkg
