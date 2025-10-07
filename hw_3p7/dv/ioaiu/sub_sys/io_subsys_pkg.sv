`include "snps_compile.sv"
`include "svt_axi_item_helper_pkg.sv"

package io_subsys_pkg;
    `ifdef USE_VIP_SNPS
        import svt_uvm_pkg::*;
        import svt_amba_uvm_pkg::*;
    `endif

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    `include "mstr_seq_cfg.sv"
    `ifdef IO_UNITS_CNT_NON_ZERO
        import sv_assert_pkg::*;
        import concerto_register_map_pkg::*;
        import addr_trans_mgr_pkg::*;
        import svt_axi_item_helper_pkg::*;
        import concerto_env_pkg::*;
        `include "snps_import.sv"
        `include "io_mstr_seq_cfg.sv"
        `include "io_subsys_seq_item_lib.sv"
        `include "io_subsys_seq_lib.sv"
        `include "io_subsys_vseq_lib.sv"
    `endif
endpackage: io_subsys_pkg
