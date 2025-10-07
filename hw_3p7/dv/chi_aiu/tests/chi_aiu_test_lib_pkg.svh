////////////////////////////
//CHI-AIU Tests Package
//File: chi_aiu_test_lib_pkg.sv
////////////////////////////


`include "snps_compile.sv"    

`ifdef USE_VIP_SNPS
`include "svt_amba_env.sv"
`endif // USE_VIP_SNPS
package <%=obj.BlockId%>_test_lib_pkg;

    import uvm_pkg::*;
    import common_knob_pkg::*;
    `include "uvm_macros.svh"

    //Concerto, In-House AXI Agent, SFI Agent Packages

<%  if(!obj.CUSTOMER_ENV) { %>
  import addr_trans_mgr_pkg::*;
  import <%=obj.BlockId%>_chi_agent_pkg::*;
  import <%=obj.BlockId%>_smi_agent_pkg::*;
<% } %>

        `include "snps_import.sv"

    `ifdef USE_VIP_SNPS
        import svt_amba_env_class_pkg::*;
        //`include "cust_svt_amba_system_configuration.sv"
        //`include "svt_amba_env.sv"
        `include "svt_amba_seq_item_lib.sv"
        `include "svt_amba_seq_lib.sv"
        `include "cust_svt_report_catcher.sv"
    `endif // USE_VIP_SNPS

<%  if(obj.INHOUSE_APB_VIP && obj.testBench=="chi_aiu") { %>
  import <%=obj.BlockId%>_apb_agent_pkg::*;
<% } %>

    import q_chnl_agent_pkg::*;
    import chi_aiu_unit_args_pkg::*;
    import <%=obj.BlockId%>_chi_aiu_vseq_pkg::*;
    //AIU env pkg
    import <%=obj.BlockId%>_env_pkg::*;
    //Perf counter pkg
    import <%=obj.BlockId%>_perf_cnt_pkg::*;
    import <%=obj.BlockId%>_perf_cnt_unit_defines::*;
    //Connectivity pkg
    import <%=obj.BlockId%>_connectivity_pkg::*;
    import <%=obj.BlockId%>_connectivity_defines::*;

    //AIU Seq pkg
    //import aiu_seq_lib_pkg::*;
    `include "<%=obj.BlockId%>_system_bfm_seq.sv"

    //`include "helper_cls.svh"

<% if(obj.testBench == 'fsys' || obj.testBench =='emu') { %>
    import concerto_register_map_pkg::*;
    <% } else if(obj.testBench == "chi_aiu" && obj.INHOUSE_APB_VIP){%>
    import <%=obj.instanceName%>_concerto_register_map_pkg::*;
 <% } %>
    `include "ral_csr_base_seq.svh"
    `include "chi_aiu_test_list.svh"

endpackage: <%=obj.BlockId%>_test_lib_pkg
