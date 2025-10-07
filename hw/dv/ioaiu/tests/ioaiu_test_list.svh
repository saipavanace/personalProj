////////////////////////////
//Description: Inlucde all AIU tests in this file
//File: aiu_test_lib.svh
////////////////////////////
<% if((obj.INHOUSE_APB_VIP) && (obj.testBench == "io_aiu")) { 
  for (var i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
 `include "core<%=i%>_ioaiu_csr_seq_lib.sv"
 `include "core<%=i%>_perf_cnt_unit_cfg_seq_ioaiu.sv"
<% }  
} %>
<% if(obj.useResiliency) { %>
  /*
   *demoter class used for the Resiliency feature testing
   *to demote any error occur due to UECC generation
   */
  `include "report_catcher_demoter_base.sv"
<% } %>
`include "base_test.sv"
`include "bring_up_test.sv"
`include "credit_sw_mgr_test.sv"
 `include "ioaiu_csr_bit_bash_test.sv"
 `include "ioaiu_csr_all_reg_rd_reset_val_test.sv"
 `include "fn_csr_access_test.sv"
 `include "directed_test.sv"
 `include "ioaiu_AXI_register_access_test.sv"
 `include "resiliency_unitduplication_test.sv"
 `include "ioaiu_noncoh_exclusive_test.sv"
 `include "unit_test.sv"
 `include "sysco_test.sv"
 `include "ioaiu_qchannel_test.sv"
 `include "perf_cnt_test.sv"
 `include "connectivity_test.sv"
