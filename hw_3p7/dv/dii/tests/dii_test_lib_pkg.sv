////////////////////////////////////////////////////////////////////////////////
//
// DII Test Library Package
//
////////////////////////////////////////////////////////////////////////////////
`include "snps_compile.sv"
//
package <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_test_lib_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    import addr_trans_mgr_pkg::*;
    import common_knob_pkg::*;
    import <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_concerto_register_map_pkg::*;

    import <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_smi_agent_pkg::*;
    import <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_axi_agent_pkg::*;
    import <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_apb_agent_pkg::*;
    import <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_perf_cnt_pkg::*; // concerto_register_map inside perf_cnt_pkg
    import <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_perf_cnt_unit_defines::*;

    import q_chnl_agent_pkg::*;

    import <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_inhouse_axi_bfm_pkg::*;

    import <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_env_pkg::*;

    import <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_dii_args_pkg::*;

    //csr seqs
    `include "ral_csr_base_seq.svh"
    `include "dii_ral_csr_seq.sv"

    <% if(obj.useResiliency) { %>
    /*
     *demoter class used for the Resiliency feature testing
     *to demote any error occur due to UECC generation
     */
      `include "report_catcher_demoter_base.sv"
    <% } %>

    `ifdef USE_VIP_SNPS
    <%if (obj.testBench == "dii") { %>
    `include "snps_import.sv"
    `include "svt_axi_slave_seq_lib.sv"

    <%}%>
    `endif

   
    //tests 
    `include "dii_base_test.svh"
    `include "dii_test.svh"
    `include "dii_qchannel_test.svh"
    `include "dii_targt_id_err_test.svh"
    `include "perf_cnt_test.sv"


endpackage : <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_test_lib_pkg
