//
//File: addr_trans_mgr_pkg.sv
//

package addr_trans_mgr_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import sv_assert_pkg::*;
import "DPI-C" function string getenv(input string env_name);

`include "ncore_config_info.svh"
`include "memregions_per_ig.svh"
`include "memregions_info.svh"
`include "select_bits.svh"
`include "param_gen_value.svh"
`include "cacheline_dist.svh"
`include "gen_new_cacheline.svh"
`include "ncore_memory_map.svh"
`include "addr_trans_mgr.svh"

endpackage: addr_trans_mgr_pkg
