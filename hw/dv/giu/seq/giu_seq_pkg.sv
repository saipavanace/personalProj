package <%=obj.instanceName%>_giu_seq_pkg;

    `define UVMPKG
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import sv_assert_pkg::*;
    import ncore_config_pkg::*;
    import addr_trans_mgr_pkg::*;
    import <%=obj.instanceName%>_smi_agent_pkg::*;
    //  import giu_unit_args_pkg::*;

    `include "<%=obj.instanceName%>_giu_coverage_seq.svh"
    `include "<%=obj.instanceName%>_giu_cntr.svh"
    `include "<%=obj.instanceName%>_giu_seq.svh"
    //   `include "<%=obj.instanceName%>_giu_targt_id_err_seq.svh"
endpackage: <%=obj.instanceName%>_giu_seq_pkg
