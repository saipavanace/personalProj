////////////////////////////////////////////////////////////////////////////////
//
// DCE Environment Package
//
////////////////////////////////////////////////////////////////////////////////
package <%=obj.BlockId%>_env_pkg;

    import uvm_pkg::*;
   `include "uvm_macros.svh"
   `include "<%=obj.BlockId%>_dce_env_types.svh"

    import <%=obj.BlockId%>_credit_maint_pkg::*;
    import <%=obj.BlockId%>_smi_agent_pkg::*;
    import <%=obj.BlockId%>_dce_probe_pkg::*;
    import addr_trans_mgr_pkg::*;
    import q_chnl_agent_pkg::*;
    <% if(obj.testBench == 'dce') { %>
    import snoop_filter_pkg::*;
    <%}%>
    <% if(obj.INHOUSE_APB_VIP) { %>
    import <%=obj.BlockId%>_apb_agent_pkg::*;
    <%  } %>

     <% if(obj.testBench == 'fsys' || obj.testBench =='emu') { %>
    import concerto_register_map_pkg::ral_sys_ncore;
    <% } else {%>
    import <%=obj.BlockId%>_concerto_register_map_pkg::*;
    <% } %>
    
   `include "<%=obj.BlockId%>_dce_dirm_model.svh"
   `include "<%=obj.BlockId%>_dce_goldenref_model.sv"
   `include "<%=obj.BlockId%>_dce_state_check_item.svh"
   `include "<%=obj.BlockId%>_dce_credits_check.sv"
   `include "<%=obj.BlockId%>_dce_dirm_txn.svh"
   `include "<%=obj.BlockId%>_dce_scb_txn.sv"
   `include "<%=obj.BlockId%>_dce_scoreboard.svh"
   `include "<%=obj.BlockId%>_dce_env_config.svh"
    <% if(obj.testBench == 'dce') { %>
   `include "<%=obj.strRtlNamePrefix%>_concerto_register_map.sv"
    
    //Perf monitor
    //import <%=obj.BlockId%>_perf_cnt_pkg::ral_sys_ncore; //vyshak
    <% } %>

   `include "<%=obj.BlockId%>_dce_env.svh"
    <% if(obj.COVER_ON) { %>
   `ifndef FSYS_COVER_ON
       `include "<%=obj.BlockId%>_dce_coverage.svh"
   `endif
    <% } %>
endpackage: <%=obj.BlockId%>_env_pkg
