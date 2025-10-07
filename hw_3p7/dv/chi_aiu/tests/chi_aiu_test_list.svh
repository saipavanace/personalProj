<%  if(obj.INHOUSE_APB_VIP && obj.testBench=="chi_aiu") { %>
`include "chi_aiu_csr_seq_lib.svh"
<% } %>
`include "chi_aiu_base_test.svh"
`include "chi_aiu_bringup_test.svh"
`include "chi_credit_mgr_test.svh"
`include "chi_aiu_perf_test.svh"
`include "chi_aiu_qchannel_test.svh"
`include "chi_aiu_resiliency_test.svh"
//`ifndef USE_VIP_SNPS
`include "chi_aiu_link_ctrl_test.svh"
//`endif // `ifndef USE_VIP_SNPS

//`include "chi_aiu_dataless_txn_test.svh"
//`include "chi_aiu_write_test.svh"
`include "perf_cnt_test.sv"
`include "connectivity_test.sv"

