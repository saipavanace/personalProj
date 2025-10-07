package <%=obj.BlockId%>_env_pkg;
  `ifdef QUESTA
    timeunit 1ps;
    timeprecision 1ps;
  `endif // QUESTA

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import <%=obj.BlockId%>_smi_agent_pkg::*;
  import <%=obj.BlockId%>_apb_agent_pkg::*;
  import q_chnl_agent_pkg::*;
  import <%=obj.BlockId%>_clock_counter_pkg::*;

<% if(obj.testBench == "dve") { %>
  `include "<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>_concerto_register_map.sv"
  //import <%=obj.BlockId%>_perf_cnt_pkg::*; //ral_sys_ncore;
  import <%=obj.BlockId%>_concerto_register_map_pkg::*;
<% } else if(obj.testBench == "cust_tb") { %>
  import ncore_system_ral_pkg::ral_sys_ncore;
<% } else if(obj.testBench == "fsys") { %>
  //`include "concerto_register_map.sv"
<% } %>
  `include "<%=obj.BlockId%>_dve_sb_txn.svh"
`ifndef FSYS_COVER_ON
  `include "<%=obj.BlockId%>_dve_coverage.svh"
`endif
  `include "<%=obj.BlockId%>_dve_sb.svh"
  `include "<%=obj.BlockId%>_dve_dtwdbg_reader.svh"
  `include "<%=obj.BlockId%>_dve_env_config.svh"
  `include "<%=obj.BlockId%>_dve_env.svh"
endpackage // dve_env_pkg
