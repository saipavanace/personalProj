////////////////////////////
//AIU Tests Package
//File: aiu_tests_pkg.sv
////////////////////////////
`include "snps_compile.sv"
`include "svt_axi_item_helper_pkg.sv"
`include "svt_amba_env.sv"
  

package <%=obj.BlockId%>_test_lib_pkg;

    import uvm_pkg::*;
    import common_knob_pkg::*;
    `ifdef USE_VIP_SNPS
    import svt_uvm_pkg::*;
     import svt_amba_uvm_pkg::*;
     import svt_amba_env_class_pkg::*;
     `endif
    `include "uvm_macros.svh"

<%  if(obj.BLK_SNPS_OCP_VIP) { %>
  import svt_ocp_uvm_pkg::*;
<%  } %>
    

    //Concerto, In-House AXI Agent, SFI Agent Packages
//    import <%=obj.BlockId%>_ConcertoPkg::*;
    import <%=obj.BlockId%>_axi_agent_pkg::*;
    import <%=obj.BlockId%>_smi_agent_pkg::*;
    import q_chnl_agent_pkg::*;
<%if(obj.DutInfo.useCache) {%>
    import <%=obj.BlockId%>_ccp_agent_pkg::*;
    import <%=obj.BlockId%>_ccp_env_pkg::*;
<% } %>
<%if((obj.INHOUSE_APB_VIP) && (obj.testBench == "io_aiu") && 
        ((obj.instanceName) ? (obj.BlockId == obj.instanceName) :
        (obj.ioaiuId==0))) { %>
        import <%=obj.BlockId%>_concerto_register_map_pkg::*;   
<% } else if(obj.testBench == 'fsys' || obj.testBench =='emu'){%>
        import concerto_register_map_pkg::ral_sys_ncore;
<% } %> 
<%  if(obj.INHOUSE_APB_VIP) { %>
    import <%=obj.BlockId%>_apb_agent_pkg::*;
<% } %>
<%  if(!obj.CUSTOMER_ENV) { %>
    import ncore_config_pkg::*;
    import addr_trans_mgr_pkg::*;
<% } %>
    import <%=obj.BlockId%>_inhouse_axi_bfm_pkg::*;
    //Import Synopsys VIP Packages
    `include "snps_import.sv"
`ifdef USE_VIP_SNPS
 <%if (obj.testBench == "io_aiu") { %>
     import sv_assert_pkg::*;
        //import concerto_register_map_pkg::*;
        `include "mstr_seq_cfg.sv"
        import svt_axi_item_helper_pkg::*;
        `include "snps_import.sv"
        //`include "svt_amba_seq_item_lib.sv"
        `include "io_mstr_seq_cfg.sv"
        `include "io_subsys_seq_item_lib.sv"
        `include "io_subsys_seq_lib.sv"

    //`include "cust_svt_amba_system_configuration.sv"
<%}%>
`endif

    import ioaiu_unit_args_pkg::*;

    //AIU env pkg
    import <%=obj.BlockId%>_env_pkg::*;

    //AIU Seq pkg
    import <%=obj.BlockId%>_ioaiu_seq_lib_pkg::*;
	import <%=obj.BlockId%>_ioaiu_seq_pkg::*;
    //Perf counter pkg
    import <%=obj.BlockId%>_perf_cnt_pkg::*;
    import <%=obj.BlockId%>_perf_cnt_unit_defines::*;
    //Connectivity pkg
    import <%=obj.BlockId%>_connectivity_pkg::*;
    import <%=obj.BlockId%>_connectivity_defines::*;
    

<% if(!obj.PSEUDO_SYS_TB) { %> 
<%if(obj.NO_SYS_BFM === undefined) { %>
    `include "<%=obj.BlockId%>_system_bfm_seq.sv"
<% } %>
<% } %>
<% if(obj.testBench == "io_aiu") { %>
//    `include "concerto_register_map.sv"
<% } %>
<% if((obj.INHOUSE_APB_VIP) && (obj.testBench == "io_aiu") && 
((obj.instanceName) ? (obj.instanceName == obj.DutInfo.strRtlNamePrefix) : 1)) { %>
    `include "ral_csr_base_seq.svh"
<% } %>
    `include "helper_cls.svh"
    `include "ioaiu_test_list.svh"

endpackage: <%=obj.BlockId%>_test_lib_pkg
