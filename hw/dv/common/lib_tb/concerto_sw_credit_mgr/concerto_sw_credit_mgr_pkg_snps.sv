//
//File: concerto_sw_credit_mgr_pkg.sv
//
`ifdef USE_VIP_SNPS // Now using this file for synopsys vip sim
`include "snps_compile.sv"    
`include "svt_amba_env.sv"
`include "seq_lib.sv"
package concerto_sw_credit_mgr_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import sv_assert_pkg::*;

    `include "snps_import.sv"
    //`include "cust_svt_amba_system_configuration.sv"
    //`include "svt_amba_env.sv"
    `include "svt_amba_seq_item_lib.sv"
    `include "svt_amba_seq_lib.sv"
    import svt_amba_env_class_pkg::*;
    import fsys_svt_seq_lib::*;
    `include "concerto_sw_credit_mgr_snps.svh"

endpackage: concerto_sw_credit_mgr_pkg
`endif // `ifdef USE_VIP_SNPS
