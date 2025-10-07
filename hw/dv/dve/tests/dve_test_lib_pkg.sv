package <%=obj.BlockId%>_test_lib_pkg;

  import uvm_pkg::*;
  import common_knob_pkg::*;
  `include "uvm_macros.svh"
  import ncore_config_pkg::*;
  import addr_trans_mgr_pkg::*;
  import <%=obj.BlockId%>_smi_agent_pkg::*;
  import <%=obj.BlockId%>_apb_agent_pkg::*;
  import <%=obj.BlockId%>_env_pkg::*;
//  import dve_unit_args_pkg::*;
  import dve_seq_pkg::*;
  import q_chnl_agent_pkg::*;
  import <%=obj.BlockId%>_concerto_register_map_pkg::*;

  //`include "concerto_register_map.sv"
  
  // Perf monitor:concerto_register_map inside perf_cnt_pkg
  import <%=obj.BlockId%>_perf_cnt_pkg::*;

  `include "ral_csr_base_seq.svh"
  //csr seqs
  `include "dve_ral_csr_seq.sv"
  `include "dve_tacc_test_seq.svh"
  `include "dve_buffer_clear_seq.svh"
  `include "dve_drop_k_seq.svh"
  `include "dve_buffer_error_seq.svh"

  `include "dve_test_list.svh"
endpackage // dve_test_lib_pkg
