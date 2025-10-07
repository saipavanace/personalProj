//////////////
//Include all sub_sys tests
//////////////
`include "snps_compile.sv"
`include "snps_import.sv"
//`include "cust_svt_amba_system_configuration.sv"
`include "svt_amba_env.sv"
`include "svt_amba_seq_item_lib.sv"
`include "svt_amba_seq_lib.sv"
`include "seq_lib.sv"
//`ifdef USE_VIP_SNPS_AXI_SLAVES
`include "svt_axi_slave_seq_lib.sv"
//`endif // USE_VIP_SNPS_AXI_SLAVES

 import common_knob_pkg::*;
 import concerto_env_pkg::*;
 import q_chnl_agent_pkg::*;
 import svt_amba_env_class_pkg::*;
 import fsys_svt_seq_lib::*;
 import io_subsys_pkg::*;
  import ncore_config_pkg::*;
 import addr_trans_mgr_pkg::*;
 import concerto_register_map_pkg::*;
 import  svt_axi_item_helper_pkg::*;


 //Concerto Tests
`include "concerto_unit_args.svh"
`include "concerto_test_cfg.svh"
`include "concerto_test_helper.svh"
`include "concerto_boot_tasks.svh"
`include "concerto_fsc_tasks.svh"
`include "concerto_secded_parity_err_tasks.svh"
`include "concerto_rw_csr_generic.svh"
`include "concerto_rw_csr_inhouse_tasks.svh"
`include "concerto_rw_csr_snps_tasks.svh"
`include "concerto_sw_credit_mgr.svh"
`include "concerto_legacy_emu_tasks.svh"
`include "concerto_base_test.svh"
`include "concerto_base_trace_test.svh"
`include "concerto_test_lib.svh"
`include "chi_coh_entry_virtual_seq.sv"
`include "chi_linkup_virtual_seq.sv"
`include "chi_coh_bringup_virtual_seq.sv"
`include "chi_traffic_snps_virtual_seq.sv"
`include "fsys_main_traffic_virtual_seq.sv"
`include "fsys_snps_pcie_producer_consumer_vseq.sv"
`include "concerto_fullsys_test.svh"
`include "concerto_fullsys_axi_if_parity_chk_test.svh"
`include "concerto_bootregion_test.svh"
`include "concerto_ioaiu_bootregion_test.svh"
`include "concerto_fullsys_test_ioaiu_csr.svh"
`include "concerto_fullsys_test_chiaiu_csr.svh"
`ifndef USE_VIP_SNPS // New FSYS caused compile issues with fsys_snps. Temp work around to move progress
`include "concerto_fullsys_direct_legacy_test.svh"
`include "concerto_fullsys_direct_wr_rd_legacy_test.svh"
`endif //`ifndef USE_VIP_SNPS 
`include "concerto_fullsys_random_dvm_test.svh"
`include "concerto_fullsys_qchannel_test.svh"
`include "concerto_fullsys_perfmon_legacy_test.svh"
`include "concerto_fullsys_reg_bash_test.svh"
`include "concerto_fullsys_placeholder_test.svh"
`include "concerto_fullsys_sysco_test.svh"
`include "concerto_fullsys_2ndIter_cachelookuponly.svh"
`include "concerto_fullsys_perfmon_test.svh"
`include "concerto_fullsys_performance_test.svh"
`include "concerto_fsc_test.svh"
`include "concerto_secded_parity_err_test.svh"
`include "concerto_dii_backpressure_test.svh"
`include "concerto_fullsys_sw_crdt_mgr_test.svh"
`include "concerto_fullsys_evt_en_dis_test.svh"
`include "concerto_fullsys_smc_mntop_test.svh"
`include "concerto_apb_debug_test.svh"
`include "concerto_fullsys_test_atomicDecErr.svh"
`include "concerto_fullsys_pcie_prod_consu_test.svh"
`ifdef CHI_SUBSYS
    `include "cust_svt_report_catcher.sv"
    `include "chi_subsys_base_test.sv"
    `include "chi_subsys_dvmop_test.sv"
    `include "chi_subsys_mkrdunq_error_test.sv"
    `include "chi_subsys_write_excl_test.sv"
    `include "chi_subsys_excl_noncoh_fix_addr_test.sv"
    `include "chi_subsys_comb_wrcmo_test.sv"
    `include "chi_subsys_unsupported_txn_test.sv"
    `include "chi_subsys_atomic_stress_test.sv"
    `include "chi_subsys_stash_stress_test.sv"
    `include "chi_subsys_ip_error_test.sv"
    `include "chi_subsys_random_test.sv"
    `include "chi_subsys_random_native_interface_delay_test.sv"
    `include "chi_subsys_error_test.sv"
    `include "chi_subsys_snp_test.sv"
    `include "chi_subsys_random_noncoh_test.sv"
    `include "chi_subsys_random_coherency_test.sv"
    `include "chi_subsys_owo_test.sv"
    `include "chi_subsys_cmo_test.sv"
    `include "chi_subsys_mkrdunq_test.sv"
    `include "chi_subsys_wrevctorevct_test.sv"
    `include "chi_subsys_directed_atomic_test.sv"
    `include "chi_subsys_mkrdunq_copyback_hazard_test.sv"
`endif
`include "concerto_legacy_boot_tasks_snps.svh"
`ifdef IO_SUBSYS_SNPS
//    `include "concerto_iosubsys_test_snps.svh"
//    `include "concerto_iosubsys_writenosnoop_readnosnoop_sequential_snps.svh"
//    `include "concerto_iosubsys_random_all_ops_no_dvm_snps.svh"
//    `include "concerto_iosubsys_ace_txn_snps.svh"
//    `include "concerto_iosubsys_axi_random_snps.svh"
    `include "io_subsys_base_test.sv"
    `include "io_subsys_test.sv"
`endif
