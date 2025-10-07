//
//DEC Test List
//
//
// DCE New set of testlists
//
<%  if(obj.INHOUSE_APB_VIP) { %>
 `include "dce_csr_seq_lib.sv"
<%  } %>
<% if(obj.useResiliency) { %>
  /*
   *demoter class used for the Resiliency feature testing
   *to demote any error occur due to UECC generation
   */
  `include "report_catcher_demoter_base.sv"
<% } %>
//Perf monitor
`include "<%=obj.BlockId%>_perf_cnt_unit_macros.svh" // add perfmon macro
//
`include "dce_unit_test_helper.svh"
`include "dce_base_test.svh"
`include "dce_bringup_test.svh"
`include "dce_csr_bitbash_reg_test.sv"
`include "dce_csr_reg_reset_test.sv"
`include "dce_qchannel_test.svh"
//Perf monitor
import <%=obj.BlockId%>_perf_cnt_unit_defines::*;
`include "perf_cnt_test.sv"
