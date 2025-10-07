`include "uvm_macros.svh"
`include "ncore_clk_rst_module.sv"
//`include "ncore_user_defines.svh"
`include "sv_assert_pkg.sv"
`include "ncore_config_pkg.sv"
`include "addr_trans_mgr_pkg.sv"
`include "ncore_clk_if.sv"
`include "cdnAxiUvmDefines.sv"

package ncore_tb_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import CdnSvVip::*;
  import DenaliSvMem::*;
<% if(obj.useResiliency == 1 || obj.DebugApbInfo.length > 0){ %>
  import DenaliSvCdn_apb::*;
  import cdnApbUvm::*;   
<% } %>
  import DenaliSvCdn_axi::*;
  import cdnAxiUvm::*;
  import DenaliSvChi::*;
  import cdnChiUvm::*;

  // Import the addr Mgr
  import ncore_config_pkg::*;
  import addr_trans_mgr_pkg::*;
 
  `include "ncore_chi_transaction.sv"
  `include "ncore_chi_agent.sv"
  `include "ncore_ace_agent.sv"
  `include "ncore_ace_config.sv"
  `include "ncore_ace_seq_lib.sv"
  `include "ncore_system_register_map.sv"
  `include "ncore_vip_configuration.sv"
<% if(obj.useResiliency == 1){ %>
  `include "ncore_fsc_system_register_map.sv"
<% } %>
  `include "ncore_env.sv"
  `include "axi_base_seq.sv"
  `include "chi_base_seq.sv"
  `include "ncore_axi_base_seq.sv"
  `include "ncore_chi_base_seq.sv"
  `include "ncore_apb_debug_seq.sv"
  `include "ncore_base_vseq.sv"
  `include "ncore_reg_wr_rd_vseq.sv"
  `include "ncore_fsc_ralgen_err_intr_vseq.sv"
  `include "ncore_ace_directed_vseq.sv"
  `include "ncore_chi_directed_vseq.sv"
  `include "ncore_cache_access_vseq.sv"
  `include "ncore_connectivity_vseq.sv"
  `include "ncore_snoop_vseq.sv"
  `include "ncore_apb_debug_vseq.sv"
  `include "ncore_bandwidth_vseq.sv"
  `include "ncore_bandwidth_multi_vseq.sv"
  `include "ncore_base_test.sv"
  `include "ncore_sys_test.sv"
  `include "ncore_ace_directed_test.sv"
  `include "ncore_chi_directed_test.sv"
  `include "ncore_snoop_test.sv"
  `include "ncore_cache_access_test.sv"
  `include "ncore_connectivity_test.sv"
  `include "ncore_bandwidth_test.sv"
  `include "ncore_bandwidth_test_multi.sv"
  `include "ncore_ral_bit_bash_test.sv"
  `include "ncore_apb_debug_test.sv"
  `include "ncore_ral_reset_value_test.sv"
  `include "ncore_reg_wr_rd_test.sv"
  `include "ncore_fsc_ral_bit_bash_test.sv"
  `include "ncore_fsc_ral_reset_value_test.sv"
  `include "ncore_fsc_ralgen_err_intr_test.sv"
  `include "ncore_fsc_Uncorr_Error_test.sv"
endpackage
