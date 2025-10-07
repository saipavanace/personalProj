////////////////////////////////////////////////////////////////////////////////
//
// AXI Agent Package
//
////////////////////////////////////////////////////////////////////////////////
package <%=obj.BlockId%>_axi_agent_pkg;
`ifndef VELOCE_HDL_COMPILE
   <% if (obj.testBench != "emu_t" ) { %>

  import uvm_pkg::*;
  import ncore_config_pkg::*;
  import addr_trans_mgr_pkg::*; //use in axi_txn 
  `include "uvm_macros.svh"

       `include "global_tb_phys.sv"  <% } %> 
`endif
       `include "<%=obj.BlockId%>_axi_widths.svh"
       `include "<%=obj.BlockId%>_axi_types.svh"
`ifndef VELOCE_HDL_COMPILE
   <% if (obj.testBench != "emu_t" ) { %>

      `include "<%=obj.BlockId%>_axi_txn.svh"
      `include "<%=obj.BlockId%>_axi_agent_config.svh"
      `include "<%=obj.BlockId%>_axi_seq_item.svh"
      `include "<%=obj.BlockId%>_axi_driver.svh"
      `include "<%=obj.BlockId%>_axi_monitor.svh"
      `include "<%=obj.BlockId%>_axi_sequencer.svh"
      `include "<%=obj.BlockId%>_axi_virtual_sequencer.svh"
      `include "<%=obj.BlockId%>_axi_agent.svh" <% } %> 
`endif
endpackage : <%=obj.BlockId%>_axi_agent_pkg
