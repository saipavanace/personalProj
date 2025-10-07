<%  if((obj.INHOUSE_APB_VIP)) { %>
 `include "dmi_csr_seq_lib.sv"
<%  } %>
`include "<%=obj.BlockId%>_perf_cnt_unit_macros.svh" // add just macro
`include "dmi_base_test.svh"

<%  if((obj.BLK_SNPS_APB_VIP) || (obj.INHOUSE_APB_VIP)) { %>
<%  } %>
<% if(obj.useResiliency) { %>
  /*
   *demoter class used for the Resiliency feature testing
   *to demote any error occur due to UECC generation
   */
  `include "report_catcher_demoter_base.sv"
<% } %>
`include "dmi_test.svh"
`include "q_channel_dmi_test.svh"
 `include "dmi_test_lib.sv"
import <%=obj.BlockId%>_perf_cnt_unit_defines::*;
`include "perf_cnt_test.sv"
