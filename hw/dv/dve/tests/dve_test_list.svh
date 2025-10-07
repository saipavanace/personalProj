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
`include "dve_base_test.svh"
`include "dve_bringup_test.svh"
`include "dve_ral_test.svh"
`include "dve_targt_id_err_test.svh"
`include "dve_snpcap_ral_test.svh"
`include "dve_err_log_en_test.svh"
`include "dve_qchannel_test.svh"
`include "dve_buffer_clear_test.svh"
`include "dve_drop_k_test.svh"
`include "dve_buffer_error_test.svh"
//Perf monitor
import <%=obj.BlockId%>_perf_cnt_unit_defines::*;
`include "perf_cnt_test.sv"
