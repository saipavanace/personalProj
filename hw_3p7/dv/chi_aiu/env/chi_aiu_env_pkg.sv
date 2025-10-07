////////////////////////////
//CHI-AIU Environment Package
//File: chi_aiu_env_pkg.sv
////////////////////////////

package <%=obj.BlockId%>_env_pkg;
`ifdef QUESTA
  timeunit 1ps;
  timeprecision 1ps;
`endif

  import uvm_pkg::*;
  //import common_knob_pkg::*;
  `include "uvm_macros.svh"
<% if(obj.testBench=="emu") { %>
import mgc_vtl_chi_pkg::*;
`include "/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/chi_v2/sysvlog/vtl_chi_types.svh"
<% } %> 

<%  if(!obj.CUSTOMER_ENV) { %>
  import addr_trans_mgr_pkg::*;
  import <%=obj.BlockId%>_chi_agent_pkg::*;
`ifdef VCS
  export <%=obj.BlockId%>_chi_agent_pkg::*;
`endif // `ifdef VCS
  import <%=obj.BlockId%>_smi_agent_pkg::*;
<% } %>
<% if(obj.INHOUSE_APB_VIP && obj.testBench=="chi_aiu") { %>
   import <%=obj.BlockId%>_apb_agent_pkg::*;
<% } %>
   import q_chnl_agent_pkg::*;
   <% if (obj.testBench=="fsys") { %>
  //sys_event agent pkg
  <% if((obj.interfaces.eventRequestOutInt._SKIP_ == false) || (obj.interfaces.eventRequestInInt._SKIP_ == false )) { %>
  import <%=obj.BlockId%>_event_agent_pkg::*;
  <%}%>
  <% } %>
        //Perf counter pkg
    import <%=obj.BlockId%>_perf_cnt_pkg::*;
    import <%=obj.BlockId%>_perf_cnt_unit_defines::*;
    //Connectivity pkg
    import <%=obj.BlockId%>_connectivity_pkg::*;
    import <%=obj.BlockId%>_connectivity_defines::*;
    
  `include "<%=obj.BlockId%>_chi_aiu_env_config.svh"

<% if(!obj.CUSTOMER_ENV) { %>
  `include "<%=obj.BlockId%>_chi_aiu_types.svh"
  `include "<%=obj.BlockId%>_chi_aiu_scb_txn.svh"
`ifndef FSYS_COVER_ON
  `include "<%=obj.BlockId%>_chi_aiu_coverage.svh"
`elsif CHI_SUBSYS_COVER_ON
  `include "<%=obj.BlockId%>_chi_aiu_coverage.svh"
`endif
  `include "<%=obj.BlockId%>_trace_trigger_utils.svh"
  `include "<%=obj.BlockId%>_chi_aiu_scoreboard.svh"
  `include "<%=obj.BlockId%>_trace_debug_scoreboard.svh"
<% } %>
<% if(obj.testBench == "chi_aiu" && obj.INHOUSE_APB_VIP ) { %>
    import <%=obj.instanceName%>_concerto_register_map_pkg::*;
    <% } else if(obj.testBench == 'fsys' || obj.testBench =='emu'){%>
    import concerto_register_map_pkg::ral_sys_ncore;
 <% } %> 

    <%if (obj.testBench=="fsys"){%>
        import newperf_test_tools_pkg::*;
        `include "newperf_test_chi_scoreboard.sv"
        `include "txn_info.sv"
        `include "chi_txn_memory.sv"
        `include "chi_predictor.sv"
        `include "chi_comparator.sv"
        `include "chi_scoreboard.sv"
    <%}%>
  `include "<%=obj.BlockId%>_chiaiu_env.sv"
endpackage: <%=obj.BlockId%>_env_pkg

