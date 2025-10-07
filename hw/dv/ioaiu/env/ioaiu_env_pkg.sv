////////////////////////////
//AIU Environment Package
//File: aiu_env_pkg.sv
////////////////////////////
`include "snps_compile.sv"    

package <%=obj.BlockId%>_env_pkg;
    `ifdef QUESTA
        timeunit 1ps;
        timeprecision 1ps;
    `endif
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "<%=obj.BlockId%>_check_macros.svh"
    //`include "<%=obj.BlockId%>_ConcertoParams.svh"
    //Concerto, In-House AXI Agent, SFI Agent Packages

    <%if((obj.INHOUSE_APB_VIP) && (obj.testBench == "io_aiu") && 
        ((obj.instanceName) ? (obj.BlockId == obj.instanceName) :
        (obj.DutInfo.ioaiuId==0))) { %>
        import <%=obj.BlockId%>_concerto_register_map_pkg::*;   
    <% } else if(obj.testBench == 'fsys' || obj.testBench =='emu'){%>
        import concerto_register_map_pkg::ral_sys_ncore;
    <% } %> 

    <% if((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")) { %>
        import <%=obj.BlockId%>_axi_agent_pkg::*;
        `ifdef VCS
        export <%=obj.BlockId%>_axi_agent_pkg::*;
        `endif // `ifdef VCS
    <%}else{%>
        import <%=obj.BlockId%>_axi_agent_pkg::*;
        `ifdef VCS
        export <%=obj.BlockId%>_axi_agent_pkg::*;
        `endif // `ifdef VCS
    <%}%>
    import <%=obj.BlockId%>_smi_agent_pkg::*;
    <% if (obj.testBench=="fsys") { %>
    <% if((obj.interfaces.eventRequestOutInt._SKIP_ == false) || (obj.interfaces.eventRequestInInt._SKIP_ == false )) { %>
    import <%=obj.BlockId%>_event_agent_pkg::*;
    <%}%>
    <%}%>
    import q_chnl_agent_pkg::*;
    //Perf counter pkg
    import <%=obj.BlockId%>_perf_cnt_pkg::*;
    import <%=obj.BlockId%>_perf_cnt_unit_defines::*;
     //Connectivity pkg
    import <%=obj.BlockId%>_connectivity_pkg::*;
    import <%=obj.BlockId%>_connectivity_defines::*;
    
    <%if(!obj.CUSTOMER_ENV){%>
        import ncore_config_pkg::*;
        import addr_trans_mgr_pkg::*;
        //import <%=obj.BlockId%>_inhouse_ace_bfm_pkg::*;
        import <%=obj.BlockId%>_inhouse_axi_bfm_pkg::*;
    <%}%>
    `include "<%=obj.BlockId%>_ConcertoAxiHelperFunctions.svh"
    <%if((obj.DutInfo.useCache == 1)){%>
        import <%=obj.BlockId%>_ccp_agent_pkg::*;
        import <%=obj.BlockId%>_ccp_env_pkg::*;
`ifdef VCS        
        export <%=obj.BlockId%>_ccp_agent_pkg::*;
        export <%=obj.BlockId%>_ccp_env_pkg::*;
`endif        
    <%}%>   
    <%if(obj.INHOUSE_APB_VIP){%>
        import <%=obj.BlockId%>_apb_agent_pkg::*;
    <%}%>
    <%if(!obj.PSEUDO_SYS_TB) { %>
        //import resetPkg::*;
        //import ocp_agent_pkg::*;
    <%}%>
    <% if(obj.BLK_SNPS_OCP_VIP) { %>
        //import svt_uvm_pkg::*;
        //import svt_ocp_uvm_pkg::*;
        //`include "cust_svt_ocp_system_configuration.sv"
    <%}%>
    `include "snps_import.sv"
    `include "<%=obj.BlockId%>_ioaiu_env_config.svh"
    `include "<%=obj.BlockId%>_ioaiu_env_types.svh"
    <%if(!obj.CUSTOMER_ENV) { %>
        //  `include "<%=obj.BlockId%>_axi_cov_define.svi"     
        //  `include "<%=obj.BlockId%>_axi_cover_point.svi"  
        //  `include "<%=obj.BlockId%>_sfi_cover_point.svi" 
        // `include "ioaiu_probe_txn.svh"
        // `include "ioaiu_probe_monitor.svh"
        // `include "ioaiu_probe_agent.svh"
        <%if(obj.COVER_ON){%>
            //`include "<%=obj.BlockId%>_cbi_cov_collector.svh"
        <%}%>  
        //  `include "<%=obj.BlockId%>_aiu_sfi_pkts.svh"			   
        //  `include "<%=obj.BlockId%>_aiu_rtl_monitor.sv"
        //  `include "<%=obj.BlockId%>_ncbu_rtl_monitor.sv"
        `include "<%=obj.BlockId%>_trace_trigger_utils.svh"
        `include "<%=obj.BlockId%>_ioaiu_probe_txn.svh"
        `include "<%=obj.BlockId%>_ioaiu_probe_monitor.svh"
        `include "<%=obj.BlockId%>_ioaiu_probe_agent.svh"

        <%if(obj.NO_SCB === undefined){%>
            `include "<%=obj.BlockId%>_auvm_scoreboard.svh"
            `include "<%=obj.BlockId%>_ioaiu_scb_txn.svh"
            <%if(obj.COVER_ON){%>
            `ifndef FSYS_COVER_ON
                `include "<%=obj.BlockId%>_ioaiu_cover_points.svh"
                `include "<%=obj.BlockId%>_ioaiu_coverage.svh"
            `endif
                //  `include "<%=obj.BlockId%>_axi_scoreboard_cov_cb.svh"
                //  `include "<%=obj.BlockId%>_sfi_scoreboard_cov_cb.svh"
            <% } else if(obj.IO_SUBSYS_SNPS) { %>     
                `include "<%=obj.BlockId%>_ioaiu_cover_points.svh"
                `include "<%=obj.BlockId%>_ioaiu_coverage.svh"
            <%}%>
            `include "<%=obj.BlockId%>_ioaiu_scoreboard.svh"
            <%if(obj.DutInfo.useCache){%>
                `include "<%=obj.BlockId%>_ioaiu_ccp_scoreboard.svh"
            <%}%>
            `include "<%=obj.BlockId%>_trace_debug_scoreboard.svh"
            <%if(obj.testBench=="fsys" || obj.testBench=="emu") { %>
                // newperf test scoreboard
                import newperf_test_tools_pkg::*;
                `include "newperf_test_ace_scoreboard.sv"
                // newperf test scoreboard
            <%}%>
        <%}%>
    <%}%>

//`ifdef USE_VIP_SNPS
<% if (obj.testBench == "fsys") { %>
    //Sequences
    `include "<%=obj.BlockId%>_snp_cust_seq.sv"
    `include "<%=obj.BlockId%>_cust_seq.sv"
<% } %>
//`endif

    //    `include "<%=obj.BlockId%>_cbi_rtl_monitor.sv"
    <% if((!obj.CUSTOMER_ENV)) { %>
        //    `include "<%=obj.BlockId%>_aiu_register.sv"
        //    `include "<%=obj.BlockId%>_concerto_register_map_aiu.sv"
        //    `include "<%=obj.BlockId%>_ncbu_register.sv"
        //    `include "<%=obj.BlockId%>_concerto_register_map.sv"
    <%}%>
    `include "<%=obj.BlockId%>_ioaiu_env.svh"
    `include "<%=obj.BlockId%>_ioaiu_smi_demux.svh"
    `include "<%=obj.BlockId%>_ioaiu_multiport_env.svh"
endpackage: <%=obj.BlockId%>_env_pkg

/* 
 <%=JSON.stringify(obj,null,' ')%>
 */
