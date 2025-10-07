//
//File: addr_trans_mgr_pkg.sv
//

package ncore_config_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import sv_assert_pkg::*;
`ifndef DPIGETENV
`define DPIGETENV
    import "DPI-C" function string getenv(input string env_name);
`endif
    `include "ncore_config_info.svh"

endpackage: ncore_config_pkg
