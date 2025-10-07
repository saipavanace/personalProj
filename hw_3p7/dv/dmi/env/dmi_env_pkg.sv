////////////////////////////////////////////////////////////////////////////////
//
// DMI Environment Package
//
////////////////////////////////////////////////////////////////////////////////
`include "snps_compile.sv"
package <%=obj.BlockId%>_env_pkg;

import uvm_pkg::*;
import common_knob_pkg::*;
`include "uvm_macros.svh"
`include "snps_import.sv"
<%
var topObj = {};
var cohAIUs = 0;
var aiuMaxProcs = 0;
var i;

topObj.SYS_nSysAIUs        = obj.nAIUs;
topObj.SYS_wSysAddress     = obj.wSysAddr;
topObj.SYS_nSysCacheline   = Math.pow(2, obj.wCacheLineOffset);
%>
<% for (var key in topObj) { %>
localparam int <%=key%> = <%=topObj[key]%>;
<% } %>
import <%=obj.BlockId%>_smi_agent_pkg::*;
import addr_trans_mgr_pkg::*;
import <%=obj.BlockId%>_rtl_agent_pkg::*;
import <%=obj.BlockId%>_tt_agent_pkg::*;  
import <%=obj.BlockId%>_read_probe_agent_pkg::*;
import <%=obj.BlockId%>_write_probe_agent_pkg::*;

<% if(obj.useCmc == 1) { %>
import <%=obj.BlockId%>_ccp_agent_pkg::*;
import <%=obj.BlockId%>_ccp_env_pkg::*;
<% } %>   
import <%=obj.BlockId%>_axi_agent_pkg::*;
`ifdef VCS
export <%=obj.BlockId%>_axi_agent_pkg::*;
`endif // `ifdef VCS 
import <%=obj.BlockId%>_inhouse_axi_bfm_pkg::*;
`include "<%=obj.BlockId%>_ConcertoAxiHelperFunctions.svh"

import <%=obj.BlockId%>_DmiPkg::*;

<% if(obj.testBench == "dmi") { %>
import <%=obj.BlockId%>_resetPkg::*;
<% } %>
<% if(obj.INHOUSE_APB_VIP) { %>
import <%=obj.BlockId%>_apb_agent_pkg::*;
<% } %>

import q_chnl_agent_pkg::*;
import sv_assert_pkg::*;
<% if(obj.testBench == "dmi" && obj.Id == 0 ) { %>
import <%=obj.BlockId%>_concerto_register_map_pkg::*;
<% } else if(obj.testBench == 'fsys' || obj.testBench =='emu'){%>
import concerto_register_map_pkg::ral_sys_ncore;
<% } %> 
////////////////////////////////////////////////////////////////
`include "<%=obj.BlockId%>_type_defines.svh"    
`include "<%=obj.BlockId%>_dmi_cmd_args.sv"
`include "<%=obj.BlockId%>_addr_status_item.sv"
`include "<%=obj.BlockId%>_dmi_table.sv"
`include "<%=obj.BlockId%>_resource_manager.sv"
`include "<%=obj.BlockId%>_dmi_env_config.svh"

<% if(!obj.CUSTOMER_ENV) { %>
`include "<%=obj.BlockId%>_exec_mon_predictor.svh"
`include "<%=obj.BlockId%>_dmi_states.svh"
`include "<%=obj.BlockId%>_dmi_coverage.svh"
`include "<%=obj.BlockId%>_dmi_scoreboard.sv"
`include "<%=obj.BlockId%>_trace_debug_scoreboard.svh"
<% } %>
`include "<%=obj.BlockId%>_dmi_env.svh"

<% if(obj.testBench == "dmi") { %>
`include "<%=obj.BlockId%>_smi_seq.svh"
// Type based sequence items
`include "<%=obj.BlockId%>_dmi_seq_item.sv"
`include "<%=obj.BlockId%>_data_seq_item.sv"
`include "<%=obj.BlockId%>_cmd_seq_item.sv"
`include "<%=obj.BlockId%>_dtw_seq_item.sv"
`include "<%=obj.BlockId%>_rb_seq_item.sv"
`include "<%=obj.BlockId%>_mrd_seq_item.sv"
// Test Sequences -- v2
`include "<%=obj.BlockId%>_traffic_pattern_seq.sv"
`include "<%=obj.BlockId%>_packet_generator_base_seq.sv"
`include "<%=obj.BlockId%>_packet_generator_seq.sv"
`include "<%=obj.BlockId%>_dmi_base_vseq.sv"
`include "<%=obj.BlockId%>_dmi_vseq.sv"
// Test Sequences -- v1
`include "<%=obj.BlockId%>_dmi_base_seq.svh"
`include "<%=obj.BlockId%>_dmi_seq.svh"
`include "<%=obj.BlockId%>_dmi_rb_seq.svh"
<% } %>
////////////////////////////////////////////////////////////////
endpackage: <%=obj.BlockId%>_env_pkg

