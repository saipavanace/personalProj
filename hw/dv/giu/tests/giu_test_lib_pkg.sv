package <%=obj.instanceName%>_test_lib_pkg;

    `define UVMPKG
    import uvm_pkg::*;
    import common_knob_pkg::*;
    `include "uvm_macros.svh"
    import ncore_config_pkg::*;
    import addr_trans_mgr_pkg::*;
    import <%=obj.instanceName%>_smi_agent_pkg::*;
    import <%=obj.instanceName%>_apb_agent_pkg::*;
    import <%=obj.instanceName%>_giu_env_pkg::*;
    //  import giu_unit_args_pkg::*;
    import <%=obj.instanceName%>_giu_seq_pkg::*;
    import q_chnl_agent_pkg::*;
    import <%=obj.instanceName%>_concerto_register_map_pkg::*;

    //`include "concerto_register_map.sv"
    
    // Perf monitor:concerto_register_map inside perf_cnt_pkg
    //   import <%=obj.instanceName%>_giu_perf_cnt_pkg::*;

    `include "ral_csr_base_seq.svh"
    //csr seqs
    `include "giu_ral_csr_seq.sv"

    `include "giu_test_list.svh"
endpackage // giu_test_lib_pkg
