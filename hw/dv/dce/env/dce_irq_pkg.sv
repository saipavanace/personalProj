package <%=obj.BlockId%>_irq_pkg;
   import uvm_pkg::*;
`include "uvm_macros.svh"
   import <%=obj.BlockId%>_ConcertoPkg::*;
   import ncore_config_pkg::*;
   import addr_trans_mgr_pkg::*;   

   `include "<%=obj.BlockId%>_dce_irq_seq_item.svh"
   `include "<%=obj.BlockId%>_dce_irq_driver.svh"
   `include "<%=obj.BlockId%>_dce_irq_sequencer.svh"
   `include "<%=obj.BlockId%>_dce_irq_agent.svh"
endpackage //
   
