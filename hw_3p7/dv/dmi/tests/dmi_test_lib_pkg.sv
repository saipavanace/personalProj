////////////////////////////////////////////////////////////////////////////////
//
// DMI Test Library Package
//
////////////////////////////////////////////////////////////////////////////////
`include "snps_compile.sv"
package <%=obj.BlockId%>_test_lib_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "snps_import.sv"
<%  if(obj.BLK_SNPS_APB_VIP) { %>
  import svt_apb_uvm_pkg::*;
<%  } %>

  import addr_trans_mgr_pkg::*;
<%if(obj.useCmc == 1) { %>
  import <%=obj.BlockId%>_ccp_agent_pkg::*;
  import <%=obj.BlockId%>_ccp_env_pkg::*;
<% } %>
<%  if(obj.INHOUSE_APB_VIP) { %>
  import <%=obj.BlockId%>_apb_agent_pkg::*;
<% } %>
  import q_chnl_agent_pkg::*;
  import <%=obj.BlockId%>_axi_agent_pkg::*;
  import <%=obj.BlockId%>_smi_agent_pkg::*;
  import <%=obj.BlockId%>_env_pkg::*;
  import <%=obj.BlockId%>_rtl_agent_pkg::*;
  import <%=obj.BlockId%>_tt_agent_pkg::*;
  import <%=obj.BlockId%>_read_probe_agent_pkg::*;
  import <%=obj.BlockId%>_write_probe_agent_pkg::*;
  import <%=obj.BlockId%>_inhouse_axi_bfm_pkg::*;

<% if(obj.testBench == "dmi") { %>
  //`include "<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_concerto_register_map.sv"
  import <%=obj.BlockId%>_perf_cnt_pkg::*; // concerto_register_map inside perf_cnt_pkg
<% } %>

<% if(obj.testBench == 'fsys' || obj.testBench =='emu') { %>
    import concerto_register_map_pkg::ral_sys_ncore;
    <% } else if(obj.testBench == "dmi" && obj.Id ==0){%>
    import <%=obj.BlockId%>_concerto_register_map_pkg::*;
 <% } %>
  
  `include "ral_csr_base_seq.svh"

  `include "dmi_csr_ralgen_seq.sv"
  `include "helper_class.svh"
<% if(obj.USE_VIP_SNPS) { %>
  `include "cust_svt_axi_config.sv"
  `include "cust_svt_axi_slave_transaction.sv"
  `include "axi_slave_mem_response_sequence.sv"
<% } %>
  // Test Sequences
  `include "dmi_test_list.svh"
endpackage : <%=obj.BlockId%>_test_lib_pkg
