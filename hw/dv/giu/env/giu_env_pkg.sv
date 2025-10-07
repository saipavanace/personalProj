package <%=obj.instanceName%>_giu_env_pkg;
    `ifdef QUESTA
    timeunit 1ps;
    timeprecision 1ps;
    `endif // QUESTA

    `define UVMPKG
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import <%=obj.instanceName%>_smi_agent_pkg::*;
    import <%=obj.instanceName%>_apb_agent_pkg::*;
    import q_chnl_agent_pkg::*;
    import <%=obj.instanceName%>_clock_counter_pkg::*;

    <% if(obj.testBench == "giu") { %>
    //import <%=obj.BlockId%>_perf_cnt_pkg::*; //ral_sys_ncore;
    import <%=obj.instanceName%>_concerto_register_map_pkg::*;
    <% } else if(obj.testBench == "cust_tb") { %>
    import ncore_system_ral_pkg::ral_sys_ncore;
    <% } else if(obj.testBench == "fsys") { %>
    //`include "concerto_register_map.sv"
    <% } %>
    `include "<%=obj.instanceName%>_giu_sb_txn.svh"
    `ifndef FSYS_COVER_ON
    `include "<%=obj.instanceName%>_giu_coverage.svh"
    `endif
    `include "<%=obj.instanceName%>_giu_sb.svh"
    `include "<%=obj.instanceName%>_giu_env_config.svh"
    `include "<%=obj.instanceName%>_giu_env.svh"
endpackage // giu_env_pkg
