////////////////////////////////////////////////////////////////////////////////
//
// SMI Agent Package
<% if (1 == 0) { %>
// Author: Chirag Gandhi
<% } %>
//
////////////////////////////////////////////////////////////////////////////////
package <%=obj.BlockId%>_smi_agent_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
`ifndef VELOCE_HDL_COMPILE
  import common_knob_pkg::*;
  import ncore_config_pkg::*;
  import addr_trans_mgr_pkg::*;
`endif

  `include "<%=obj.BlockId%>_smi_widths.svh"
  `include "<%=obj.BlockId%>_smi_types.svh"
  `include "<%=obj.BlockId%>_smi_seq_item.svh"
`ifndef VELOCE_HDL_COMPILE
  `include "<%=obj.BlockId%>_smi_seq.svh"
  `include "<%=obj.BlockId%>_smi_agent_config.svh"
  `include "<%=obj.BlockId%>_smi_driver.svh"
<%  if(obj.BlockId.match('chiaiu')) { %>
    `ifdef CHI_SUBSYS
  `include "<%=obj.BlockId%>_smi_force_driver.svh"
    `endif
<% } %>
  `include "<%=obj.BlockId%>_smi_monitor.svh"
  `include "<%=obj.BlockId%>_smi_sequencer.svh"
  `include "<%=obj.BlockId%>_smi_virtual_sequencer.svh"
  `include "<%=obj.BlockId%>_smi_force_virtual_sequencer.svh"
  `include "<%=obj.BlockId%>_smi_force_seq.sv"
  `include "<%=obj.BlockId%>_toggle_cg_wrapper.svh"
  `include "<%=obj.BlockId%>_smi_coverage.svh"
  `include "<%=obj.BlockId%>_smi_agent.svh"
`endif

endpackage : <%=obj.BlockId%>_smi_agent_pkg
