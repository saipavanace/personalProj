`ifndef SVT_CHI_ITEM_HELPER_PKG_SV
`define SVT_CHI_ITEM_HELPER_PKG_SV

package svt_chi_item_helper_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"

import sv_assert_pkg::*;

class svt_chi_item_helper;
static bit dis_addr_range_constraint;
static bit disable_boot_addr_region=0;
static bit exp_compack=0;

static function dis_ncore_sys_mem_addr_range_cnstr();
  dis_addr_range_constraint = 1;
endfunction:dis_ncore_sys_mem_addr_range_cnstr

static function en_ncore_sys_mem_addr_range_cnstr();
  dis_addr_range_constraint = 0;
endfunction:en_ncore_sys_mem_addr_range_cnstr

static function disable_boot_addr();
    disable_boot_addr_region=1;
endfunction: disable_boot_addr

static function force_exp_compack();
    exp_compack = 1;
endfunction: force_exp_compack

endclass

endpackage: svt_chi_item_helper_pkg 

`endif // SVT_CHI_ITEM_HELPER_PKG_SV
