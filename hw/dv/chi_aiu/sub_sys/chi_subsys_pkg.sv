`include "snps_compile.sv"

package chi_subsys_pkg;
    `ifdef USE_VIP_SNPS_CHI
        import svt_uvm_pkg::*;
        import svt_amba_uvm_pkg::*;
    `endif

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    //`ifdef CHI_SUBSYS
    `ifdef CHI_UNITS_CNT_NON_ZERO
        import sv_assert_pkg::*;
        import concerto_register_map_pkg::*;
        import ncore_config_pkg::*;
        import addr_trans_mgr_pkg::*;
        import chi_aiu_unit_args_pkg::*;
        import chiaiu0_chi_bfm_types_pkg::*;
        import chiaiu0_chi_bfm_txn_pkg::*;
        import chiaiu0_chi_traffic_seq_lib_pkg::*;
        import chiaiu0_svt_chi_node_params_pkg::*;
        `ifdef VCS
            export chiaiu0_chi_bfm_types_pkg::*;
            export chiaiu0_chi_bfm_txn_pkg::*;
            export chiaiu0_chi_traffic_seq_lib_pkg::*;
        `endif // `ifdef VCS
        `include "snps_import.sv"
        `include "chi_subsys_mstr_seq_cfg.sv"
        `include "chiaiu0_chi_aiu_vseq_helper.svh"
        `include "chi_subsys_seq_lib.sv"
        `include "chi_subsys_vseq_lib.sv"
    `endif
    //`endif
endpackage: chi_subsys_pkg
