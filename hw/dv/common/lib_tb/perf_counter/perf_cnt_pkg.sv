<% 
//var numChiAiu           = 0;
//var numIoAiu            = 0;
//
//if (obj.BlockId.includes("aiu")) {
//for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
//  if( obj[AgentInfoName][pidx].fnNativeInterface == "CHI-A" || obj[AgentInfoName][pidx].fnNativeInterface == "CHI-B" ||
//      obj[AgentInfoName][pidx].fnNativeInterface == "CHI-C" || obj[AgentInfoName][pidx].fnNativeInterface == "CHI-D" ||
//      obj[AgentInfoName][pidx].fnNativeInterface == "CHI-E"){
//      numChiAiu = numChiAiu + 1;
//    } else {
//      numIoAiu = numIoAiu + 1;
//    }
//}
//}
%>

package <%=obj.BlockId%>_perf_cnt_pkg;
    
  import uvm_pkg::*;
  import <%=obj.BlockId%>_perf_cnt_unit_defines::*;
  <%  if(!obj.CUSTOMER_ENV) { %>
  import ncore_config_pkg::*;
  import addr_trans_mgr_pkg::*;
  <% } %>
  <% if(( obj.testBench == "fsys" ) || ( obj.testBench == "emu" )) { %>
  import concerto_register_map_pkg::*;
  <% } %>
  <% if (obj.testBench == "dmi") { %>
     import <%=obj.BlockId%>_concerto_register_map_pkg::*;
  <% } %>
  <% if (obj.testBench == "dve") { %>
     import <%=obj.BlockId%>_concerto_register_map_pkg::*;
  <% } %>
  <% if (obj.testBench == "dii") { %>
     import <%=obj.BlockId%>_concerto_register_map_pkg::*;
  <% } %>
  <% if (obj.testBench == "dce") { %>
     import <%=obj.BlockId%>_concerto_register_map_pkg::*;
  <% } %>
  <% if (obj.testBench == "chi_aiu") { %>
     import <%=obj.instanceName%>_concerto_register_map_pkg::*;
  <% } %>
  <% if(obj.testBench == "io_aiu") { %>
     import <%=obj.BlockId%>_concerto_register_map_pkg::*;
  <% } %>
 
  // obj.instanceName: <%=obj.instanceName%>
  // obj.stRtlNamePrefix: <%=obj.stRtlNamePrefix%>
  <% if( obj.testBench == "dii") { %>
  `include "<%=obj.DutInfo.strRtlNamePrefix%>_concerto_register_map.sv"
  `include "<%=obj.DutInfo.strRtlNamePrefix%>_perf_cnt_units.sv"
  `include "<%=obj.DutInfo.strRtlNamePrefix%>_perf_counters_scoreboard.svh"
  `include "<%=obj.DutInfo.strRtlNamePrefix%>_perf_cnt_unit_cfg_seq.sv"
  `include "<%=obj.DutInfo.strRtlNamePrefix%>_latency_counters_scoreboard.svh"
  <% } else {%>
  <% if((obj.INHOUSE_APB_VIP) && (obj.DutInfo.strRtlNamePrefix == obj.instanceName)) { %>
  `include "<%=obj.DutInfo.strRtlNamePrefix%>_concerto_register_map.sv"
  `include "<%=obj.DutInfo.strRtlNamePrefix%>_perf_cnt_units.sv"
  `include "<%=obj.DutInfo.strRtlNamePrefix%>_perf_counters_scoreboard.svh"
  <% if((obj.INHOUSE_APB_VIP) && (obj.testBench == "io_aiu")) { 
  } else { %>  
  `include "<%=obj.DutInfo.strRtlNamePrefix%>_perf_cnt_unit_cfg_seq.sv"
  <% } %>
  //Pmon 3.4 latency
  <% if ((obj.Block == 'dii') || (obj.testBench =="io_aiu")  || (obj.Block == 'dmi') || (obj.Block == 'chi_aiu' && obj.AiuInfo[obj.Id].fnNativeInterface.includes("CHI"))) {  %>
  `include "<%=obj.DutInfo.strRtlNamePrefix%>_latency_counters_scoreboard.svh"
  <% } %>
  <% } %>
  <% } %>
  
   <% if(( obj.testBench == "fsys" ) || ( obj.testBench == "emu" )) { %>
  `include "<%=obj.BlockId%>_perf_cnt_units.sv"
  `include "<%=obj.BlockId%>_perf_counters_scoreboard.svh"
  `include "<%=obj.BlockId%>_perf_cnt_unit_cfg_seq.sv"
  <% }%>
endpackage : <%=obj.BlockId%>_perf_cnt_pkg

