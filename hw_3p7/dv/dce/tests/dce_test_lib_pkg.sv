////////////////////////////////////////////////////////////////////////////////
//
// DCE Test Library Package
//
////////////////////////////////////////////////////////////////////////////////
package <%=obj.BlockId%>_test_lib_pkg;

  import uvm_pkg::*;
  import common_knob_pkg::*;
  `include "uvm_macros.svh"

  import addr_trans_mgr_pkg::*;
  import <%=obj.BlockId%>_smi_agent_pkg::*;
<%  if(obj.INHOUSE_APB_VIP) { %>
  import <%=obj.BlockId%>_apb_agent_pkg::*;
<% } %>
  import <%=obj.BlockId%>_env_pkg::*;
  import dce_unit_args_pkg::*;
  import dce_seq_pkg::*;
  import q_chnl_agent_pkg::*;
  // Perf monitor:concerto_register_map inside perf_cnt_pkg
  import <%=obj.BlockId%>_perf_cnt_pkg::*;
  import <%=obj.DceInfo[obj.Id].strRtlNamePrefix%>_concerto_register_map_pkg::*; //vyshak
  
<% if(obj.testBench == 'dce') { %>
  `include "<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>_concerto_register_map.sv"
<% } %>

  `include "ral_csr_base_seq.svh"

  `include "dce_test_list.svh"

endpackage : <%=obj.BlockId%>_test_lib_pkg
