
package <%=obj.BlockId%>_dce_probe_pkg;
    import uvm_pkg::*;
    import <%=obj.BlockId%>_smi_agent_pkg::*;
    import addr_trans_mgr_pkg::*;

    `include "uvm_macros.svh"
  	`include "<%=obj.BlockId%>_dce_env_types.svh"
    `include "<%=obj.BlockId%>_dce_probe_seq_item.svh" 
    `include "<%=obj.BlockId%>_dce_probe_monitor.svh"  

endpackage: <%=obj.BlockId%>_dce_probe_pkg
