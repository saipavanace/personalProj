////////////////////////////////////////////////////////////////////////////////
//
// DII Environment Package
//
////////////////////////////////////////////////////////////////////////////////
`include "snps_compile.sv" 

package <%=obj.BlockId%>_env_pkg;

    typedef enum bit [1:0] {
        req = 1,
        ack,
        err
    } event_in_t;

    typedef struct {
     <%=obj.BlockId%>_smi_agent_pkg::smi_unq_identifier_bit_t unq_id;
     <%=obj.BlockId%>_smi_agent_pkg::smi_addr_t               cmd_addr;
     bit                                                      cmd_lock;
    } axi2cmd_t;
    
    
    import uvm_pkg::*;
    import common_knob_pkg::*;
    `include "uvm_macros.svh"
    `include "snps_import.sv" 
    <%if (obj.testBench == "dii") { %>
    `ifdef USE_VIP_SNPS
      `include "dii_amba_env_config.sv"
    `endif // USE_VIP_SNPS
    <%}%>
   import <%=obj.BlockId%>_smi_agent_pkg::*;
   import <%=obj.BlockId%>_axi_agent_pkg::*;
`ifdef VCS
  export <%=obj.BlockId%>_axi_agent_pkg::*;
`endif // `ifdef VCS
   import <%=obj.BlockId%>_apb_agent_pkg::*;

   import q_chnl_agent_pkg::*;

<% if(obj.INHOUSE_AXI) { %>
   import <%=obj.BlockId%>_inhouse_axi_bfm_pkg::*;
<% } %>

<% if(!obj.CUSTOMER_ENV) { %>
  `include "<%=obj.BlockId%>_dii_rtl_agent_config.svh"
  `include "<%=obj.BlockId%>_dii_rtl_monitor.svh"
  `include "<%=obj.BlockId%>_dii_rtl_agent.svh"
  `include "<%=obj.BlockId%>_trace_debug_scoreboard.svh"
<% } %>

    import <%=obj.BlockId%>_resetPkg::*;


   <% if( obj.testBench == "fsys" || obj.testBench == "emu" ) { %>
   import concerto_register_map_pkg::ral_sys_ncore;
   <% } else {%>
   import <%=obj.BlockId%>_concerto_register_map_pkg::*;
   <%} %>
  import ncore_config_pkg::*;
    import addr_trans_mgr_pkg::*;

   `include "<%=obj.BlockId%>_ConcertoAxiHelperFunctions.svh"


  `include "<%=obj.BlockId%>_dii_env_config.svh"

  `include "<%=obj.BlockId%>_ncoreStat.svh"
   
<% if(!obj.CUSTOMER_ENV) { %>
  `include "<%=obj.BlockId%>_exec_mon_predictor.svh"
  `include "<%=obj.BlockId%>_dii_txn.svh"
`ifndef FSYS_COVER_ON
  `include "<%=obj.BlockId%>_dii_coverage.svh"
`endif
  `include "<%=obj.BlockId%>_dii_scoreboard.svh"
<% } %>

  `include "<%=obj.BlockId%>_dii_env.svh"
<% if(obj.testBench == 'dii') { %>
  `include "<%=obj.BlockId%>_smi_seq.svh"
  `include "<%=obj.BlockId%>_dii_seq.svh"
<% } %>



endpackage: <%=obj.BlockId%>_env_pkg

