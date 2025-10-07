
package <%=obj.BlockId%>_chi_bfm_txn_pkg;

import uvm_pkg::*;
`include "uvm_macros.svh"
import <%=obj.BlockId%>_chi_bfm_types_pkg::*;
  import ncore_config_pkg::*;
import addr_trans_mgr_pkg::*;
import sv_assert_pkg::*;

`include "<%=obj.BlockId%>_chi_bfm_txn.svh"

endpackage: <%=obj.BlockId%>_chi_bfm_txn_pkg
