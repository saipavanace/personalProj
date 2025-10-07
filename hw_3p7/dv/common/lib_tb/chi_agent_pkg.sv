
////////////////////////////////////////////////////////////////////////////////
//
// CHI Master Agent Package
//
////////////////////////////////////////////////////////////////////////////////

package <%=obj.BlockId%>_chi_agent_pkg;
 <% if (obj.testBench != "emu_t" ) { %>
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    import sv_assert_pkg::*;
    import addr_trans_mgr_pkg::*;
    import common_knob_pkg::*;

    typedef virtual <%=obj.BlockId%>_chi_if.rn_drv_mp  chi_rn_driver_vif;
    typedef virtual <%=obj.BlockId%>_chi_if.rn_mon_mp  chi_rn_monitor_vif;
    typedef virtual <%=obj.BlockId%>_chi_if.rni_drv_mp chi_rni_driver_vif;
    typedef virtual <%=obj.BlockId%>_chi_if.rni_mon_mp chi_rni_monitor_vif;
    typedef virtual <%=obj.BlockId%>_chi_if.sn_drv_mp  chi_sn_driver_vif;
    typedef virtual <%=obj.BlockId%>_chi_if.sn_mon_mp  chi_sn_monitor_vif; <% } %> 

    `include "<%=obj.BlockId%>_chi_widths.svh"
    `include "<%=obj.BlockId%>_chi_types.svh"
 <% if (obj.testBench != "emu_t" ) { %>    
    `include "<%=obj.BlockId%>_chi_agent_cfg.svh"
    `include "<%=obj.BlockId%>_chi_seq_item.svh"
    `include "<%=obj.BlockId%>_chi_misc_txn.svh"
 <% if (obj.testBench =="emu" ) { %>
    `include "<%=obj.BlockId%>_chi_emu_drive_collect.sv"
    `include "<%=obj.BlockId%>_chi_emu_driver.svh" <% } %>
 
 <% if (obj.testBench != "emu" ) { %>
    `include "<%=obj.BlockId%>_chi_driver.svh" <% } %>
  
    `include "<%=obj.BlockId%>_chi_monitor.svh"
    `include "<%=obj.BlockId%>_chi_seqr.svh"
    `include "<%=obj.BlockId%>_chi_agent.svh"
 `ifndef FSYS_COVER_ON
     `include "<%=obj.BlockId%>_chi_coverage.svh" 
 `endif
 <% } %> 

endpackage : <%=obj.BlockId%>_chi_agent_pkg
