
package dce_seq_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import sv_assert_pkg::*;
  import addr_trans_mgr_pkg::*;
  import <%=obj.BlockId%>_credit_maint_pkg::*;
  import <%=obj.BlockId%>_smi_agent_pkg::*;
  import dce_unit_args_pkg::*;
  import <%=obj.BlockId%>_env_pkg::*;

  //`include "<%=obj.BlockId%>_dce_scoreboard.svh"
  `include "dce_seq_types.svh"
  `include "dce_container.svh"
  `include "dce_mst_seq.svh"
  `include "dce_mst_seq_lib.svh"
  `include "dce_slv_seq.svh"
  `include "dce_virtual_base_seq.svh"
  `include "dce_virtual_seq.svh"

endpackage: dce_seq_pkg
