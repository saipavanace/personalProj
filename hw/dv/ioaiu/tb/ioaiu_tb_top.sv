`timescale 1 ns/1 ps

`ifdef AIU_MODEL
    `include "req_aiu_dut.sv"
`endif

// To enable RTL desginer assertions always
`define SV_ASSERTIONS_ON

`include "snps_compile.sv"
 `include "snps_import.sv"

`ifdef USE_VIP_SNPS
    `include "<%=obj.BlockId%>_connect_source2target_if.sv"
    import wrapper_pkg_<%=obj.BlockId%>::*;
`endif
<%function sumNDP(o) {
    return Object.keys(o).reduce( (sumvar,key)=>sumvar+parseFloat(o[key]||0),0 );
}
var wCmdRspNdp =  sumNDP(obj.DutInfo.concParams.cmdRspParams);
%>

<%if((obj.useResiliency) || (obj.testBench == "io_aiu")){%>
    `include "fault_injector_checker.sv"
    `include "placeholder_connectivity_checker.sv"
<%}%>

`ifdef USE_VIP_SNPS
  <%if(obj.testBench == "io_aiu" && obj.DutInfo.nNativeInterfacePorts == 1 && obj.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') { %>
      `include "check_en_low_testing.svh"
  <%}%>
`endif


<%if(obj.assertOn){
    var nOttBanks  = obj.DutInfo.cmpInfo.nOttDataBanks;
    if( obj.DutInfo.useCache){
        var nTagBanks  = obj.DutInfo.ccpParams.nTagBanks;
        var nDataBanks = obj.DutInfo.ccpParams.nDataBanks;
    }
}%>

module tb_top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "snps_import.sv"

    //Import AIU env & tests
    import <%=obj.BlockId%>_test_lib_pkg::*;
    import <%=obj.BlockId%>_env_pkg::*;
    import <%=obj.BlockId%>_smi_agent_pkg::*; 

    <%=obj.BlockId%>_stall_if <%=obj.BlockId%>_sb_stall_if[<%=obj.DutInfo.nNativeInterfacePorts%>]();

    wire irq_uc;
    wire irq_c;

    // Urgency
    //1) prm.ott.updIssueFifo:
    //     If prm.ott.init_upd_issue_req_vld is asserted add prm.ott.init_upd_urgency to your queue.
    //     If prm.ott.rsp_upd_issue_req_vld is asserted add prm.ott.rsp_upd_urgency to your queue.
    //2) prm.ott.dtwIssueFifo:
    //     If prm.ott.dtw_issue_req_vld is asserted add prm.ott.dtw_urgency to your queue.
    //     If prm.ott.rd_dtw_issue_req_vld is asserted add prm.ott.rd_dtw_urgency to your queue.
    //3) snp.stt.stt_qos (There's only one snp transaction that can feed into this at a time.)
    //4) prm.ott.ott_sfi_mst_req_urgency -- but only if prm.ott.pkt_sfi_cmd_req_vld is asserted.
    //
    //5) Whatever Parimal drives from the IoCache (currently missing)
    /////////////////////////////////////////////////////////////
    // JS Checks
    /////////////////////////////////////////////////////////////
    <%
    var wNDPTX = [];
    for(var i = 0; i < obj.nSmiTx; i++){ 
        wNDPTX[i] = obj.interfaces.smiTxInt[i].params.wSmiNDP;  
    }

    var wNDPRX = [];
    for(var i = 0; i < obj.nSmiRx; i++){ 
        wNDPRX[i] = obj.interfaces.smiRxInt[i].params.wSmiNDP;  
    }%>

    <%if(obj.wPriorityLevel > 0){%>
        logic[<%=obj.wPriorityLevel%>-1:0] init_upd_urgency;
        logic[<%=obj.wPriorityLevel%>-1:0] rsp_upd_urgency;
        logic[<%=obj.wPriorityLevel%>-1:0] dtw_urgency;
        logic[<%=obj.wPriorityLevel%>-1:0] rd_dtw_urgency;
        logic[<%=obj.wPriorityLevel%>-1:0] snp_urgency;
        logic[<%=obj.wPriorityLevel%>-1:0] sfi_mst_req_urgency;
        logic[<%=obj.wPriorityLevel%>-1:0] stt_qos;
        logic[<%=obj.wPriorityLevel%>-1:0] ioc_qos;
        logic[2**<%=obj.wPriorityLevel%>-1:0][31:0] counter_values; 
        logic[2**<%=obj.wPriorityLevel%>-1:0][31:0] counter_values_d1; 
        logic[<%=obj.wPriorityLevel%>-1:0] expected_press; 
    <%}%>
    string testname;
    int k_prob_iocache_single_bit_tag_error;
    int k_prob_iocache_single_bit_data_error;

    int k_prob_iocache_double_bit_tag_error;
    int k_prob_iocache_double_bit_data_error;
    <%if(obj.DutInfo.useCache){%>
        <%=obj.BlockId + '_ccp_agent_pkg'%>::ccp_ctrlop_addr_logic_t            ctrlop_addr_fwd_p2;
        <%=obj.BlockId + '_ccp_agent_pkg'%>::ccp_ctrlop_security_t              ctrlop_security_fwd_p2;
        <%=obj.BlockId + '_ccp_agent_pkg'%>::ccp_cachefill_doneId_logic_t       cache_fill_done_id_tmp;
        <%=obj.BlockId + '_ccp_agent_pkg'%>::ccp_cachefill_done_logic_t         cache_fill_done_tmp;
        <%=obj.BlockId + '_ccp_agent_pkg'%>::ccp_ctrlfill_addr_t                addr_flop;
        <%=obj.BlockId + '_ccp_agent_pkg'%>::ccp_ctrlfill_wayn_t                wayn_flop;
        <%=obj.BlockId + '_ccp_agent_pkg'%>::ccp_ctrlfill_security_t            security_flop;
        bit [<%=obj.BlockId + '_ccp_agent_pkg'%>::WCCPCACHESTATE-1:0]           state_flop;
        <%=obj.BlockId + '_ccp_agent_pkg'%>::ccp_ctrlfill_vld_logic_t           ctrl_fill_vld_flop;
        <%=obj.BlockId + '_ccp_agent_pkg'%>::ccp_cachefill_rdy_logic_t          cache_fill_rdy_flop;
    <%}%>
    //-----------------------------------------------------------------------------
    // Clocks and Reset
    //-----------------------------------------------------------------------------
    logic dut_clk;
    logic tb_clk;
    logic fr_clk;
    logic tb_rstn;

    //----------------------------------------------------------------------------
    // Interfaces
    //----------------------------------------------------------------------------
    <%if(obj.NO_SMI === undefined){
        var NSMIIFTX = obj.nSmiRx;
        for(var i = 0; i < NSMIIFTX; i++){%>
            <%=obj.BlockId%>_smi_if    port<%=i%>_tx_smi_if(dut_clk, soft_rstn, "port<%=i%>_tx_smi_if");
        <%}
        var NSMIIFRX = obj.nSmiTx;
        for(var i = 0; i < NSMIIFRX; i++){%>
            <%=obj.BlockId%>_smi_if    port<%=i%>_rx_smi_if(dut_clk, soft_rstn, "port<%=i%>_rx_smi_if");
        <%}%>
    <%}%>

    // Latency if
<% if(obj.testBench =="io_aiu"){ %>

<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
	
     <%=obj.BlockId%>_latency_if <%=obj.BlockId%>_sb_latency_if<%=i%>(); // PERF_CNT Latency_IF
      initial uvm_config_db#(virtual <%=obj.BlockId%>_latency_if)::set(null, "", "<%=obj.BlockId%>_m_top_latency_if<%=i%>",<%=obj.BlockId%>_sb_latency_if<%=i%>);  
<% }  %> 
<% }  %> 
    //APB interface
    <%if(obj.INHOUSE_APB_VIP){%>
        <%=obj.BlockId%>_apb_if apb_if(dut_clk, soft_rstn);
    <%}%>

    //Q-channel interface
    <%=obj.BlockId%>_q_chnl_if  m_q_chnl_if(fr_clk, tb_rstn);

    //Connectivity interleaving interface
    <%=obj.BlockId%>_connectivity_if <%=obj.BlockId%>_connectivity_if();

    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event ev_sysco_protocol_timeout = ev_pool.get("ev_sysco_protocol_timeout_<%=obj.DutInfo.FUnitId%>");
    <%for(let i=0; i< obj.DutInfo.nNativeInterfacePorts; i+=1) {%>
    uvm_event ev_always_inject_error_<%=i%> = ev_pool.get("ev_always_inject_error_<%=i%>");
    uvm_event ev_wait_for_inject_error_<%=i%> = ev_pool.get("ev_wait_for_inject_error_<%=i%>");
    uvm_event ev_csr_test_time_out_CMDrsp_STRreq_Evict<%=i%> = ev_pool.get("ev_csr_test_time_out_CMDrsp_STRreq_Evict<%=i%>");
   <% } %>
    uvm_event toggle_clk;
    uvm_event toggle_rstn;
    uvm_event e_tb_clk;
    <%if(obj.INHOUSE_APB_VIP){%>
        <%if(obj.assertOn){%>
            <%for(var i=0;i<(nOttBanks * obj.DutInfo.nNativeInterfacePorts);i++){%>
                uvm_event         injectSingleErrOtt<%=i%>;
                uvm_event         injectDoubleErrOtt<%=i%>;
                uvm_event         inject_multi_block_single_double_ErrOtt<%=i%>;
                uvm_event         inject_multi_block_double_ErrOtt<%=i%>;
                uvm_event         inject_multi_block_single_ErrOtt<%=i%>;
                uvm_event 	  injectAddrErrOtt<%=i%>;
            <%}%>
            <%for(var i=0;i<=(obj.AiuInfo[obj.Id].ccpParams.nRPPorts * obj.DutInfo.nNativeInterfacePorts);i++){%>
                uvm_event         injectSingleErrplru<%=i%>;
                uvm_event         injectDoubleErrplru<%=i%>;
                uvm_event         injectAddrErrplru<%=i%>;
            <%}%>
            <%if(obj.DutInfo.useCache){%>
                <%for(var i=0;i<nTagBanks * obj.DutInfo.nNativeInterfacePorts;i++){%>
                    uvm_event         injectSingleErrTag<%=i%>;
                    uvm_event         injectDoubleErrTag<%=i%>;
                    uvm_event         inject_multi_block_single_double_ErrTag<%=i%>;
                    uvm_event         inject_multi_block_double_ErrTag<%=i%>;
                    uvm_event         inject_multi_block_single_ErrTag<%=i%>;
		    uvm_event         injectAddrErrTag<%=i%>;
                <%}%>
                <%for( var i=0;i<(nDataBanks * obj.DutInfo.nNativeInterfacePorts);i++){%>
                    uvm_event         injectSingleErrData<%=i%>;
                    uvm_event         injectDoubleErrData<%=i%>;
                    uvm_event         inject_multi_block_single_double_ErrData<%=i%>;
                    uvm_event         inject_multi_block_double_ErrData<%=i%>;
                    uvm_event         inject_multi_block_single_ErrData<%=i%>;
		    uvm_event 	      injectAddrErrData<%=i%>;
                <%}%>
            <%}%>
        <%}%>
    <%}%>

    <%if(obj.DutInfo.useCache && obj.V16_OLD_IO_CACHE){%>
        parameter NO_OF_WAYS        = <%=obj.DutInfo.ccpParams.nWays%>; 
        bit [NO_OF_WAYS-1:0] nru_counter;
        logic flop_csr_en_bit;
    <%}%>

    <%if( obj.DutInfo.useCache){%>
        <%=obj.BlockId%>_ccp_if  u_ccp_if[<%=obj.DutInfo.nNativeInterfacePorts%>]( .clk(dut_clk),.rst_n(soft_rstn)); 
        parameter NO_OF_WAYS        = <%=obj.DutInfo.ccpParams.nWays%>; 
        bit [NO_OF_WAYS-1:0] nru_counter;
        logic flop_csr_en_bit;
        logic flop_csr_en_bit_2;
    <%}%>

    <%if(obj.useResiliency){%>
        logic[1023:0] slv_req_corruption_vector = 1024'b0;
        logic[1023:0] slv_data_corruption_vector = 1024'b0;
        logic[1023:0] mst_req_corruption_vector = 1024'b0;
        logic[1023:0] mst_data_corruption_vector = 1024'b0;
        logic bist_bist_next_ack;
        logic bist_domain_is_on;
        logic fault_mission_fault;
        logic fault_latent_fault;
        logic fault_cerr_over_thres_fault;
    <%}%>

    `ifdef USE_VIP_SNPS
        svt_axi_if ace_vip_if();
    `endif

    <%=obj.BlockId+'_axi_if'%>     ace_if[<%=obj.DutInfo.nNativeInterfacePorts%>](dut_clk, soft_rstn);
    <%=obj.BlockId%>_axi_cmdreq_id_if axi_cmdreq_id_if[<%=obj.DutInfo.nNativeInterfacePorts%>](dut_clk, soft_rstn);

    `ifdef AIU_MODEL
        sfi_ace_if aiu_sfi_ace_slave_if(dut_clk, soft_rstn);  
        sfi_axi_if aiu_sfi_axi_master_if(dut_clk, soft_rstn); 
    `endif

    // interface to tap csr internal signal
    <%=obj.BlockId%>_probe_if u_csr_probe_if[<%=obj.DutInfo.nNativeInterfacePorts%>](dut_clk,soft_rstn);
    // Event Interface
    event_out_if     m_event_out_if_<%=obj.DutInfo.strRtlNamePrefix%>(dut_clk,soft_rstn);
    <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %> 
          <%=obj.BlockId%>_event_if #(.IF_MASTER(1)) m_event_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sender_master();
            
    <% } %>
     
    <% if (obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false) { %>
        <%=obj.BlockId%>_event_if #(.IF_MASTER(0)) m_event_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_receiver_slave();
    <% } %>
            

    /*always @ (m_event_out_if_<%=obj.BlockId%>.ev_pin_handshakes) begin
        if(m_event_out_if_<%=obj.BlockId%>.ev_pin_handshakes>0) begin
            <%=obj.BlockId%>_sb_stall_if[0].perf_count_events["Agent_event_counter"].push_back(1);
        end
    end*/
        //event counts 
    <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %> 
    always @ (posedge m_event_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sender_master.req) begin
            <%=obj.BlockId%>_sb_stall_if[0].perf_count_events["Agent_event_counter"].push_back(1);
    end
    <% } %>
     
    <% if (obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false) { %>
    always @ (posedge m_event_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_receiver_slave.req) begin
            <%=obj.BlockId%>_sb_stall_if[0].perf_count_events["Agent_event_counter"].push_back(1);
    end
    <% } %>

    <%if(obj.DutInfo.useCache == 1){%>
        <%for(let i=0; i< obj.DutInfo.nNativeInterfacePorts; i++){%>
            always @(negedge u_ccp_if[<%=i%>].clk) begin   // FIXME : Need to expand to multiple interfaces - SAI MP
                if(u_ccp_if[<%=i%>].cache_nack_ce) begin
                    <%=obj.BlockId%>_sb_stall_if[<%=i%>].perf_count_events["Cache_replay"].push_back(1);
                end
            end
            always @(negedge u_ccp_if[<%=i%>].clk) begin  // FIXME : Need to expand to multiple interfaces - SAI MP
                if(u_ccp_if[<%=i%>].cache_nack_noalloc) begin
                    <%=obj.BlockId%>_sb_stall_if[<%=i%>].perf_count_events["Cache_no_ways_to_allocate"].push_back(1);
                end
            end
        <%}%>
    <%}%>

    <%if((((obj.fnNativeInterface === "ACELITE-E") || 
           (obj.fnNativeInterface === "ACE-LITE")) && 
           (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || 
           (obj.fnNativeInterface === "ACE" || obj.fnNativeInterface === "ACE5") || 
           ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && (obj.DutInfo.useCache))){%>
        always @(posedge tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.u_sys_evt_coh_concerto.u_sys_evt_coh_wrapper.u_sys_coh_sender.protocol_timeout) begin
            ev_sysco_protocol_timeout.trigger();
        end
    <%}%>

    <%for(let i=0; i< obj.DutInfo.nNativeInterfacePorts; i+=1) {%>
    assign u_csr_probe_if[<%=i%>].IRQ_C     = tb_top.dut.<%=obj.interfaces.irqInt.name%>c;
    assign u_csr_probe_if[<%=i%>].IRQ_UC    = tb_top.dut.<%=obj.interfaces.irqInt.name%>uc;
    assign u_csr_probe_if[<%=i%>].UCESR_ErrVld = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.XAIUCESR_ErrVld_out;
    assign u_csr_probe_if[<%=i%>].cmux_dtw_rsp_initiator_id = tb_top.dut.ioaiu_core_wrapper.concerto_mux.dtw_rsp_initiator_id;
    assign u_csr_probe_if[<%=i%>].cmux_dtw_rsp_cm_typ = tb_top.dut.ioaiu_core_wrapper.concerto_mux.dtw_rsp_cm_type;
   assign u_csr_probe_if[<%=i%>].cmux_str_req_initiator_id = tb_top.dut.ioaiu_core_wrapper.concerto_mux.str_req_initiator_id;
    assign u_csr_probe_if[<%=i%>].cmux_str_req_cm_typ = tb_top.dut.ioaiu_core_wrapper.concerto_mux.str_req_cm_type;
    assign u_csr_probe_if[<%=i%>].cmux_snp_req_initiator_id = tb_top.dut.ioaiu_core_wrapper.concerto_mux.snp_req_initiator_id;
    assign u_csr_probe_if[<%=i%>].cmux_snp_req_cm_typ = tb_top.dut.ioaiu_core_wrapper.concerto_mux.snp_req_cm_type;
    <%if((((obj.fnNativeInterface === "ACELITE-E") || 
           (obj.fnNativeInterface === "ACE-LITE")) && 
           (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || 
           (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5")){%>
    assign u_csr_probe_if[<%=i%>].cmux_cmp_rsp_initiator_id = tb_top.dut.ioaiu_core_wrapper.concerto_mux.cmp_rsp_initiator_id;
    assign u_csr_probe_if[<%=i%>].cmux_cmp_rsp_cm_typ = tb_top.dut.ioaiu_core_wrapper.concerto_mux.cmp_rsp_cm_type;
    <%}%>
    assign u_csr_probe_if[<%=i%>].cmux_dtr_req_rx_initiator_id = tb_top.dut.ioaiu_core_wrapper.concerto_mux.dtr_req_rx_initiator_id;
    assign u_csr_probe_if[<%=i%>].cmux_dtr_rsp_rx_initiator_id = tb_top.dut.ioaiu_core_wrapper.concerto_mux.dtr_rsp_rx_initiator_id;
    assign u_csr_probe_if[<%=i%>].cmux_dtr_req_rx_cm_typ = tb_top.dut.ioaiu_core_wrapper.concerto_mux.dtr_req_rx_cm_type;
    assign u_csr_probe_if[<%=i%>].cmux_dtr_rsp_rx_cm_typ = tb_top.dut.ioaiu_core_wrapper.concerto_mux.dtr_rsp_rx_cm_type; 
    assign u_csr_probe_if[<%=i%>].cmux_upd_rsp_initiator_id = tb_top.dut.ioaiu_core_wrapper.concerto_mux.upd_rsp_initiator_id;
    assign u_csr_probe_if[<%=i%>].cmux_upd_rsp_cm_typ = tb_top.dut.ioaiu_core_wrapper.concerto_mux.upd_rsp_cm_type;
    assign u_csr_probe_if[<%=i%>].cmux_cmd_rsp_initiator_id = tb_top.dut.ioaiu_core_wrapper.concerto_mux.cmd_rsp_initiator_id;
    assign u_csr_probe_if[<%=i%>].cmux_cmd_rsp_cm_typ = tb_top.dut.ioaiu_core_wrapper.concerto_mux.cmd_rsp_cm_type;
   
                                 
    //starvation related assigns
    assign u_csr_probe_if[<%=i%>].starv_evt_status  = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.apb_csr.XAIUQOSSR_EventStatus_out;
    assign u_csr_probe_if[<%=i%>].ott_overflow      = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.q_oc_ove;
    assign u_csr_probe_if[<%=i%>].global_counter    = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.q_sv_counter;
    assign u_csr_probe_if[<%=i%>].starv_threshold   = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.apb_csr.XAIUQOSCR_EventThreshold_out;

    //sv_ovt_timeout related  assigns
    assign u_csr_probe_if[<%=i%>].oc_val<%=i%>   	= tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.q_oc_ovt; 
    assign u_csr_probe_if[<%=i%>].oc_ovt<%=i%>  	= tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.q_oc_val;
    assign u_csr_probe_if[<%=i%>].oc_addr<%=i%>  	= tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.q_oc_addr;
    assign u_csr_probe_if[<%=i%>].oc_id<%=i%>  	       = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.q_oc_id;
    assign u_csr_probe_if[<%=i%>].sv_ovt<%=i%>   	= tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.t_sv_ovt;
    assign u_csr_probe_if[<%=i%>].oc_security<%=i%>     = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.q_oc_security;
    
    always @(posedge tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.t_sv_timeout) begin
            ev_csr_test_time_out_CMDrsp_STRreq_Evict<%=i%>.trigger();
        end

    always @(negedge u_csr_probe_if[<%=i%>].starv_evt_status) begin
        <%=obj.BlockId%>_sb_stall_if[<%=i%>].perf_count_events["Number_of_QoS_Starvations"].push_back(1);
    end  

    <%if(obj.useResiliency){%>
        assign u_csr_probe_if[<%=i%>].fault_mission_fault = tb_top.dut.fault_mission_fault;
        assign u_csr_probe_if[<%=i%>].fault_latent_fault  = tb_top.dut.fault_latent_fault;
        assign u_csr_probe_if[<%=i%>].cerr_threshold          = tb_top.dut.dup_checker.cerr_threshold;
        assign u_csr_probe_if[<%=i%>].cerr_counter            = tb_top.dut.dup_checker.cerr_counter;
        assign u_csr_probe_if[<%=i%>].cerr_over_thres_fault   = tb_top.dut.dup_checker.cerr_over_thres_fault;
    <%}%>
   <%}%>
    <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %> 
            assign m_event_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sender_master.clk = dut_clk;
            assign m_event_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sender_master.rst_n = soft_rstn;
    <% } %>
     
    <% if (obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false) { %>
            assign m_event_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_receiver_slave.clk = dut_clk;
            assign m_event_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_receiver_slave.rst_n = soft_rstn;
    <% } %>        

    //Credit Control Status Register Assings
    <%for(let i=0; i< obj.DutInfo.nNativeInterfacePorts; i++){%>
        <%for(let j=0; j< obj.nDCEs; j++){%>
            assign u_csr_probe_if[<%=i%>].XAIUCCR<%=j%>_DCECounterState_<%=i%> = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.apb_csr.XAIUCCR<%=j%>_DCECounterState_out[2:0];
        <%}%>
        <%for(let j=0; j< obj.nDMIs; j++){%>
            assign u_csr_probe_if[<%=i%>].XAIUCCR<%=j%>_DMICounterState_<%=i%> = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.apb_csr.XAIUCCR<%=j%>_DMICounterState_out[2:0];
        <%}%>
        <%for(let j=0; j< obj.nDIIs; j++){%>
            assign u_csr_probe_if[<%=i%>].XAIUCCR<%=j%>_DIICounterState_<%=i%> = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.apb_csr.XAIUCCR<%=j%>_DIICounterState_out[2:0];
        <%}%>
    <%}%>

    //always @ (*) begin
    //
    //<%for(let i=0; i< obj.DutInfo.nNativeInterfacePorts; i++){%>
    //    <%for (var j=0; j< obj.nDCEs; j++){%> 
    //       uvm_config_db#(int)::set(null,"*","check_dce<%=j%>_crd_state_<%=i%>",u_csr_probe_if[<%=i%>].XAIUCCR<%=j%>_DCECounterState_<%=i%>);
    //    <%}%>
    //    
    //    <%for (var j=0; j< obj.nDMIs; j++){%> 
    //       uvm_config_db#(int)::set(null,"*","check_dmi<%=j%>_crd_state_<%=i%>",u_csr_probe_if[<%=i%>].XAIUCCR<%=j%>_DMICounterState_<%=i%>);
    //    <%}%>
    //    
    //    <%for (var j=0; j< obj.nDIIs; j++){%> 
    //       uvm_config_db#(int)::set(null,"*","check_dii<%=j%>_crd_state_<%=i%>",u_csr_probe_if[<%=i%>].XAIUCCR<%=j%>_DIICounterState_<%=i%>);
    //    <%}%>
    //<%}%>
    //    
    //end
    //Hooking Synopsys VIP ACE interface to InHouse BFM
    `ifdef USE_VIP_SNPS
		<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
			<%=obj.BlockId%>_connect_source2target_if#(
				<%if(obj.fnNativeInterface == "ACE-LITE"){%>
					.arm_protocol(IS_ACE_LITE)
				<%}
				if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
					.arm_protocol(IS_ACE)
				<%}
				if(obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5"){%>
					.arm_protocol(IS_AXI)
				<%}
				if (obj.fnNativeInterface == "ACELITE-E"){%>
					.arm_protocol(IS_ACE_LITE_E)
				<%}%>
			)
			u1(
				.source_if(ace_vip_if.master_if[0]),
				.target_if(ace_if[<%=i%>])
			);
			<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"|| obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface == "AXI4" ||  obj.fnNativeInterface == "AXI5"){%>
                               <%if(obj.fnNativeInterface != "AXI5") {%>
				assign ace_if[<%=i%>].awatop=0;
                                 <%}%>
				assign ace_if[<%=i%>].awstashnid=0;
				assign ace_if[<%=i%>].awstashlpid=0;
				assign ace_if[<%=i%>].awloop=0;
				assign ace_if[<%=i%>].awnsaid=0;
				assign ace_if[<%=i%>].awstashniden=0;
				assign ace_if[<%=i%>].awstashlpiden=0;
				assign ace_if[<%=i%>].awtrace=0;
			<%}%>
			assign ace_if[<%=i%>].ruser=0;
        <%}%>
    `endif

    initial begin
        toggle_clk = new("toggle_clk");
        uvm_config_db#(uvm_event)::set(.cntxt( uvm_root::get()),
                                       .inst_name( "" ),
                                       .field_name( "toggle_clk" ),
                                       .value(toggle_clk));

        toggle_rstn = new("toggle_rstn");
        uvm_config_db#(uvm_event)::set(.cntxt( uvm_root::get()),
                                        .inst_name( "" ),
                                        .field_name( "toggle_rstn" ),
                                        .value(toggle_rstn));
    end

    bit enable=1;
    int ott_count =0;
    bit[63:0] ott_valid_prev;

    always @(posedge fr_clk) begin
        toggle_clk.wait_trigger();
        @(negedge fr_clk);
        $display("triggered toggle_clk_event @time: %0t",$time);
        enable = ~enable;
    end

    assign dut_clk = enable ? fr_clk : 0;

    bit soft_rstn_en=1;
    always @(posedge fr_clk) begin
        toggle_rstn.wait_trigger();
        @(negedge fr_clk);
        $display("treggered reset event @time: %0t",$time);
        soft_rstn_en = ~soft_rstn_en;
    end

    assign soft_rstn = soft_rstn_en ? tb_rstn : 0;
    // <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
    //     assign axi_cmdreq_id_if[<%=i%>].w_pt_id = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_id;
    //     assign axi_cmdreq_id_if[<%=i%>].n_mrc0_mid = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.n_mrc0_mid;
    //     assign axi_cmdreq_id_if[<%=i%>].valid = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.n_mrc0_valid & dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_valid;
    //     assign axi_cmdreq_id_if[<%=i%>].cmd_req_valid = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_valid;
    //     assign axi_cmdreq_id_if[<%=i%>].cmd_req_ready = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_ready;     
    //     assign axi_cmdreq_id_if[<%=i%>].cmd_req_msg_type = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_cm_type;
    //     assign axi_cmdreq_id_if[<%=i%>].cmd_req_msg_id = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_message_id;   
    //     assign axi_cmdreq_id_if[<%=i%>].cmd_req_target_id = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_target_id;
    //     assign axi_cmdreq_id_if[<%=i%>].cmd_rsp_valid = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_rsp_valid;
    //     assign axi_cmdreq_id_if[<%=i%>].cmd_rsp_ready = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_rsp_ready;
    //     assign axi_cmdreq_id_if[<%=i%>].cmd_rsp_msg_type = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_rsp_cm_type;
    //     assign axi_cmdreq_id_if[<%=i%>].cmd_rsp_r_msg_id = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_rsp_r_message_id;
    //     assign axi_cmdreq_id_if[<%=i%>].cmd_rsp_src_id = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_rsp_initiator_id;
    //     // assign axi_cmdreq_id_if[<%=i%>].cmd_rsp_ndp = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_rsp_ndp;
    //     assign axi_cmdreq_id_if[<%=i%>].cmd_rsp_msg_id = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_rsp_message_id;
    //     assign axi_cmdreq_id_if[<%=i%>].cmd_rsp_target_id = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_rsp_target_id;
    //     <%if(obj.interfaces.smiRxInt[obj.DutInfo.cmdRspIntf_rx_index].params.wSmiUser >0){%>
    //         // assign axi_cmdreq_id_if[<%=i%>].cmd_rsp_msg_user = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_rsp_msg_user;
    //     <%}%>
    // <%}%>
    
    <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
        assign axi_cmdreq_id_if[<%=i%>].w_pt_id = dut.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.w_pt_id;
        assign axi_cmdreq_id_if[<%=i%>].n_mrc0_mid = dut.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.n_mrc0_mid;
        assign axi_cmdreq_id_if[<%=i%>].valid = dut.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.n_mrc0_valid & dut.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.w_pt_valid;
        assign axi_cmdreq_id_if[<%=i%>].cmd_req_valid = dut.<%=obj.DutInfo.cmdReqIntf%>ndp_msg_valid;
        assign axi_cmdreq_id_if[<%=i%>].cmd_req_ready = dut.<%=obj.DutInfo.cmdReqIntf%>ndp_msg_ready;
        assign axi_cmdreq_id_if[<%=i%>].cmd_req_msg_type = dut.<%=obj.DutInfo.cmdReqIntf%>ndp_msg_type;
        assign axi_cmdreq_id_if[<%=i%>].cmd_req_msg_id = dut.<%=obj.DutInfo.cmdReqIntf%>ndp_msg_id;
        assign axi_cmdreq_id_if[<%=i%>].cmd_req_target_id = dut.<%=obj.DutInfo.cmdReqIntf%>ndp_targ_id;
        assign axi_cmdreq_id_if[<%=i%>].cmd_rsp_valid = dut.<%=obj.DutInfo.cmdRspIntf%>ndp_msg_valid;
        assign axi_cmdreq_id_if[<%=i%>].cmd_rsp_ready = dut.<%=obj.DutInfo.cmdRspIntf%>ndp_msg_ready;
        assign axi_cmdreq_id_if[<%=i%>].cmd_rsp_msg_type = dut.<%=obj.DutInfo.cmdRspIntf%>ndp_msg_type;
        assign axi_cmdreq_id_if[<%=i%>].cmd_rsp_r_msg_id = dut.<%=obj.DutInfo.cmdRspIntf%>ndp_ndp[<%=obj.DutInfo.concParams.cmdRspParams.wMsgId%>-1:0];
        assign axi_cmdreq_id_if[<%=i%>].cmd_rsp_src_id = dut.<%=obj.DutInfo.cmdRspIntf%>ndp_src_id;
        assign axi_cmdreq_id_if[<%=i%>].cmd_rsp_ndp = dut.<%=obj.DutInfo.cmdRspIntf%>ndp_ndp[<%=wCmdRspNdp%>-1:0];
        assign axi_cmdreq_id_if[<%=i%>].cmd_rsp_msg_id = dut.<%=obj.DutInfo.cmdRspIntf%>ndp_msg_id;
        assign axi_cmdreq_id_if[<%=i%>].cmd_rsp_target_id = dut.<%=obj.DutInfo.cmdRspIntf%>ndp_targ_id;
        <%if(obj.interfaces.smiRxInt[obj.DutInfo.cmdRspIntf_rx_index].params.wSmiUser >0){%>
            assign axi_cmdreq_id_if[<%=i%>].cmd_rsp_msg_user = dut.<%=obj.DutInfo.cmdRspIntf%>ndp_msg_user;
        <%}%>
    <%}%>

    `ifdef USE_VIP_SNPS
        //Assign the reset pin from the reset interface to the reset pins from the VIP interface.
       assign ace_vip_if.master_if[0].aresetn = soft_rstn;
        assign ace_vip_if.master_if[0].aclk = dut_clk;
         initial  begin
           ace_vip_if.set_master_common_clock_mode(0,0);
         end
        <%if(obj.NO_SYS_PERF === undefined){%> 
            initial begin
                e_tb_clk = new("e_tb_clk");
                uvm_config_db#(uvm_event)::set(.cntxt(uvm_root::get()),
                    .inst_name( "" ),
                    .field_name( "e_tb_clk" ),
                .value( e_tb_clk));
                forever begin
                    @(posedge dut_clk);
                    e_tb_clk.trigger();
                end
            end
        <%}%>   
    `endif

    <%if(obj.BLK_SNPS_OCP_VIP){%>
        svt_ocp_if  mstr_vif(); 
        assign mstr_vif.Clk = dut_clk;
        assign mstr_vif.EnableClk =  1'b1;
        assign mstr_vif.SDataAccept = 1'b1;
        assign mstr_vif.SDataInfo = 'b0;
        assign mstr_vif.SRespInfo = 'b0;
        assign mstr_vif.SRespLast = 'b0;
        assign mstr_vif.SRespRowLast = 'b0;  
        assign mstr_vif.STagID  = 'b0;
        assign mstr_vif.STagInOrder ='b0;
        assign mstr_vif.SDataThreadBusy = 'b0;
        assign mstr_vif.SThreadBusy = 'b0;
        assign mstr_vif.SThreadID = 'b0;
        assign mstr_vif.SCohState = 'b0;
    <%}%>
    <%if(obj.INHOUSE_APB_VIP){%>
        uvm_event         system_quiesce;
        uvm_event         system_unquiesce;
    <%}%>

    <%if(obj.BLK_SNPS_OCP_VIP){%>
        svt_ocp_master_agent_sv_svt_wrapper mstr_agent_bfm(mstr_vif);
    <%}%>

    // To test single agent isolation mode
    uvm_event e_agent_isolation_mode_flip;
    uvm_event e_agent_isolation_mode_snoops_complete;
    uvm_event e_agent_isolation_mode_complete;

    //-----------------------------------------------------------------------------
    // Dynamic OTT signal driving 
    //-----------------------------------------------------------------------------

    initial begin
        if(!($test$plusargs("csr_throttle_frontend")))begin
            bit [7:0] translimit;
            bit [7:0] transDelta;
            bit       mask;
            bit       throttle_en;
           
            if($urandom_range(0,100) < 5 || $test$plusargs("throttle_test")) begin 
                translimit    = $urandom_range(2,<%= obj.DutInfo.cmpInfo.nOttCtrlEntries %>);
                transDelta    = $urandom_range(0,translimit-1);
                mask          = $urandom_range(0,1);
                throttle_en   = $urandom_range(0,1);

                `uvm_info("tb_top", $sformatf("translimit :%0d transDelta :%0d mask :%0b",translimit,transDelta,mask),UVM_NONE)
  
            end
        end
    end
    <%if(obj.useDynamicOtt == 1){%>
        reg tb_throttle_coh = 'b0;

        initial begin
            int loop;
            int rand_start_time;
            int rand_end_time;
            loop = $urandom_range(0,20);
            rand_start_time = $urandom_range(1000,5000);
            rand_end_time   = $urandom_range(1000,5000);
        
            repeat(loop) begin
                repeat(rand_start_time) begin
                    @(posedge dut_clk);
                end
                tb_throttle_coh = 'b1;
                repeat(rand_end_time) begin
                    @(posedge dut_clk);
                end
                tb_throttle_coh = 'b0;
            end
        end
    <%}%> 

    <%if(obj.assertOn){%>
        <%if((obj.DutInfo.cmpInfo.OttErrorType === "SECDED" || obj.DutInfo.cmpInfo.OttErrorType === "PARITY")) {%>
            <%for( var i=0;i<(nOttBanks * obj.DutInfo.nNativeInterfacePorts);i++){%>
                always@(posedge dut_clk) begin
                    $display("Waiting in  singleErrOtt task");   
                    injectSingleErrOtt<%=i%>.wait_ptrigger();
                    injectSingleErrOtt<%=i%>.reset();
                    $display("Saw wait in  singleErrOtt task"); 

                    <%if(obj.DutInfo.MemoryGeneration.ottMem[0].MemType == "NONE") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.internal_mem_inst.inject_single_error();
                    <%} else if(obj.DutInfo.MemoryGeneration.ottMem[0].MemType == "SYNOPSYS") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_single_error();
                    <%}%>
	            end

                always@(posedge dut_clk) begin
                    $display("Waiting in  DoubleErrOtt task");   
                    injectDoubleErrOtt<%=i%>.wait_ptrigger();
                    injectDoubleErrOtt<%=i%>.reset();
                    $display("Saw wait in  DoubleErrOtt task");   
                    <%if(obj.DutInfo.MemoryGeneration.ottMem[0].MemType == "NONE"){%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.internal_mem_inst.inject_double_error();
                    <%}else if(obj.DutInfo.MemoryGeneration.ottMem[0].MemType == "SYNOPSYS"){%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_double_error();
                    <%}%>
                end

                always@(posedge dut_clk) begin
                    $display("Waiting in multi_block_single_double_ErrOtt task");   
                    inject_multi_block_single_double_ErrOtt<%=i%>.wait_ptrigger();
                    inject_multi_block_single_double_ErrOtt<%=i%>.reset();
                    $display("Saw wait in  multi_block_single_double_ErrOtt task");   
                    <%if(obj.DutInfo.MemoryGeneration.ottMem[0].MemType == "NONE") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.internal_mem_inst.inject_multi_blk_single_double_error();
                    <%}else if(obj.DutInfo.MemoryGeneration.ottMem[0].MemType == "SYNOPSYS") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_multi_blk_single_double_error();
                    <%}%>
                end

                always@(posedge dut_clk) begin
                    $display("Waiting in multi_block_double_ErrOtt task");   
                    inject_multi_block_double_ErrOtt<%=i%>.wait_ptrigger();
                    inject_multi_block_double_ErrOtt<%=i%>.reset();
                    $display("Saw wait in  multi_block_double_ErrOtt task");   
                    <%if(obj.DutInfo.MemoryGeneration.ottMem[0].MemType == "NONE") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.internal_mem_inst.inject_multi_blk_double_error();
                    <%} else if(obj.DutInfo.MemoryGeneration.ottMem[0].MemType == "SYNOPSYS") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_multi_blk_double_error();
                    <%}%>
                end

                always@(posedge dut_clk) begin
                    $display("Waiting in multi_block_single_ErrOtt task");   
                    inject_multi_block_single_ErrOtt<%=i%>.wait_ptrigger();
                    inject_multi_block_single_ErrOtt<%=i%>.reset();
                    $display("Saw wait in  multi_block_single_ErrOtt task");   
                    <%if(obj.DutInfo.MemoryGeneration.ottMem[0].MemType == "NONE") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.internal_mem_inst.inject_multi_blk_single_error();
                    <%}else if(obj.DutInfo.MemoryGeneration.ottMem[0].MemType == "SYNOPSYS") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_multi_blk_single_error();
                    <%}%>
                end
               //#Stimulus.IOAIU.AddrErrorInjection
               always@(posedge dut_clk) begin
                    $display("Waiting in AddrErrOtt task");   
                    injectAddrErrOtt<%=i%>.wait_ptrigger();
                    injectAddrErrOtt<%=i%>.reset();
                    $display("Saw wait in AddrErrOtt task");   
                    <%if(obj.DutInfo.MemoryGeneration.ottMem[0].MemType == "NONE") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.internal_mem_inst.inject_addr_error();
                    <%}else if(obj.DutInfo.MemoryGeneration.ottMem[0].MemType == "SYNOPSYS") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.ottMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_addr_error();
                    <%}%>
                  end  
            <%}%>
        <%}%>
           <%if(obj.AiuInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
            <%for( var i=0;i<=(obj.AiuInfo[obj.Id].ccpParams.nRPPorts * obj.DutInfo.nNativeInterfacePorts);i++){%>
              always@(posedge dut_clk) begin
                    $display("Waiting in  singleErrplru task");   
                    injectSingleErrplru<%=i%>.wait_ptrigger();
                    injectSingleErrplru<%=i%>.reset();
                    $display("Saw wait in  singleErrplru task");   
                    <%if(obj.DutInfo.MemoryGeneration.rpMem[0].MemType == "NONE"){%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.rpMem[i].rtlPrefixString%>.internal_mem_inst.inject_single_error();
                    <%}else if(obj.DutInfo.MemoryGeneration.rpMem[0].MemType == "SYNOPSYS"){%>
                       tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.rpMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_single_error();
                    <%}%>
                end
              always@(posedge dut_clk) begin
                    $display("Waiting in  doubleErrplru task");   
                    injectDoubleErrplru<%=i%>.wait_ptrigger();
                    injectDoubleErrplru<%=i%>.reset();
                    $display("Saw wait in  doubleErrplru task");   
                    <%if(obj.DutInfo.MemoryGeneration.rpMem[0].MemType == "NONE"){%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.rpMem[i].rtlPrefixString%>.internal_mem_inst.inject_double_error();
                    <%}else if(obj.DutInfo.MemoryGeneration.rpMem[0].MemType == "SYNOPSYS"){%>
                       tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.rpMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_double_error();
                    <%}%>
                end
                always@(posedge dut_clk) begin
                    $display("Waiting in  AddrErrplru task");   
                    injectAddrErrplru<%=i%>.wait_ptrigger();
                    injectAddrErrplru<%=i%>.reset();
                    $display("Saw wait in  AddrErrplru task");   
                    <%if(obj.DutInfo.MemoryGeneration.rpMem[0].MemType == "NONE"){%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.rpMem[i].rtlPrefixString%>.internal_mem_inst.inject_addr_error();
                    <%}else if(obj.DutInfo.MemoryGeneration.rpMem[0].MemType == "SYNOPSYS"){%>
                       tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.rpMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_addr_error();
                    <%}%>
                end
 
        <%}%>
        <%}%>
        <%if(obj.DutInfo.useCache){%>
            <%if((obj.DutInfo.ccpParams.TagErrInfo === "SECDED" || obj.DutInfo.ccpParams.TagErrInfo === "PARITYENTRY")){%>
                <%for( var i=0;i<nTagBanks * obj.DutInfo.nNativeInterfacePorts;i++){%>
                    always@(posedge dut_clk) begin
                        $display("Waiting in  singleErrTag task");   
                        injectSingleErrTag<%=i%>.wait_ptrigger();
                        injectSingleErrTag<%=i%>.reset();
                        $display("Saw wait in  singleErrTag task");   
                        <%if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "NONE") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_single_error();
                        <%} else if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "SYNOPSYS") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_single_error();
                        <%}%>
                    end
                    //#Stimulus.IOAIU.DataErrorInjection
                    always@(posedge dut_clk) begin
                        $display("Waiting in  DoubleErrTag task");   
                        injectDoubleErrTag<%=i%>.wait_ptrigger();
                        injectDoubleErrTag<%=i%>.reset();
                        $display("Saw wait in  DoubleErrTag task");   
                        <%if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "NONE") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_double_error();
                        <%} else if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "SYNOPSYS") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_double_error();
                        <%}%>
                    end

                    always@(posedge dut_clk) begin
                        $display("Waiting in multi_block_single_double_ErrTag task");   
                        inject_multi_block_single_double_ErrTag<%=i%>.wait_ptrigger();
                        inject_multi_block_single_double_ErrTag<%=i%>.reset();
                        $display("Saw wait in  multi_block_single_double_ErrTag task");   
                        <%if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "NONE") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_multi_blk_single_double_error();
                        <%} else if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "SYNOPSYS") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_multi_blk_single_double_error();
                        <%}%>
                    end

                    always@(posedge dut_clk) begin
                        $display("Waiting in multi_block_double_ErrTag task");   
                        inject_multi_block_double_ErrTag<%=i%>.wait_ptrigger();
                        inject_multi_block_double_ErrTag<%=i%>.reset();
                        $display("Saw wait in  multi_block_double_ErrTag task");   
                        <%if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "NONE") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_multi_blk_double_error();
                        <%} else if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "SYNOPSYS") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_multi_blk_double_error();
                        <%}%>
                    end

                    always@(posedge dut_clk) begin
                        $display("Waiting in multi_block_single_ErrTag task");   
                        inject_multi_block_single_ErrTag<%=i%>.wait_ptrigger();
                        inject_multi_block_single_ErrTag<%=i%>.reset();
                        $display("Saw wait in  multi_block_single_ErrTag task");   
                        <%if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "NONE") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_multi_blk_single_error();
                        <%} else if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "SYNOPSYS") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_multi_blk_single_error();
                        <%}%>
                    end

                   always@(posedge dut_clk) begin
                    $display("Waiting in AddrErrTag task");   
                    injectAddrErrTag<%=i%>.wait_ptrigger();
                    injectAddrErrTag<%=i%>.reset();
                    $display("Saw wait in AddrErrTag task");   
                    <%if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "NONE") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_addr_error();
                    <%}else if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "SYNOPSYS") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_addr_error();
                    <%}%>
                end  

                <%}%>
            <%}%>

            <%if((obj.DutInfo.ccpParams.DataErrInfo === "SECDED" || obj.DutInfo.ccpParams.DataErrInfo === "PARITYENTRY") && (obj.DutInfo.MemoryGeneration.dataMem.MemType != "SYNOPSYS")) {%>
                <%for( var i=0;i<(nDataBanks * obj.DutInfo.nNativeInterfacePorts);i++){%>
                    always@(posedge dut_clk) begin
                        $display("Waiting in  singleErrData task");   
                        injectSingleErrData<%=i%>.wait_ptrigger();
                        injectSingleErrData<%=i%>.reset();
                        $display("Saw wait in  singleErrData task");   
                        <%if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "NONE") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_single_error();
                        <%} else if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "SYNOPSYS") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_single_error();
                        <%}%>
                    end

                    always@(posedge dut_clk) begin
                        $display("Waiting in  DoubleErrData task");   
                        injectDoubleErrData<%=i%>.wait_ptrigger();
                        injectDoubleErrData<%=i%>.reset();
                        $display("Saw wait in  DoubleErrData task");   
                        <%if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "NONE") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_double_error();
                        <%} else if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "SYNOPSYS") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_double_error();
                        <%}%>
                    end

                    always@(posedge dut_clk) begin
                        $display("Waiting in  multi_block_single_double_ErrData task");   
                        inject_multi_block_single_double_ErrData<%=i%>.wait_ptrigger();
                        inject_multi_block_single_double_ErrData<%=i%>.reset();
                        $display("Saw wait in  multi_block_single_double_ErrData task");   
                        <%if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "NONE") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_multi_blk_single_double_error();
                        <%} else if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "SYNOPSYS") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_multi_blk_single_double_error();
                        <%}%>
                    end

                    always@(posedge dut_clk) begin
                        $display("Waiting in  multi_block_double_ErrData task");   
                        inject_multi_block_double_ErrData<%=i%>.wait_ptrigger();
                        inject_multi_block_double_ErrData<%=i%>.reset();
                        $display("Saw wait in  multi_block_double_ErrData task");   
                        <%if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "NONE") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_multi_blk_double_error();
                        <%} else if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "SYNOPSYS") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_multi_blk_double_error();
                        <%}%>
                    end

                    always@(posedge dut_clk) begin
                        $display("Waiting in  multi_block_single_ErrData task");   
                        inject_multi_block_single_ErrData<%=i%>.wait_ptrigger();
                        inject_multi_block_single_ErrData<%=i%>.reset();
                        $display("Saw wait in  multi_block_single_ErrData task");   
                        <%if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "NONE") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_multi_blk_single_error();
                        <%} else if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "SYNOPSYS") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_multi_blk_single_error();
                        <%}%>
                    end

                     always@(posedge dut_clk) begin
                    	$display("Waiting in AddrErrData task");   
                    	injectAddrErrData<%=i%>.wait_ptrigger();
                   	injectAddrErrData<%=i%>.reset();
                    	$display("Saw wait in AddrErrData task");   
                    	<%if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "NONE") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_addr_error();
                    	<%}else if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "SYNOPSYS") {%>
                        tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_addr_error();
                    <%}%>
                end 
                <%}%>
            <%}%>
        <%}%>
    <%}%>

    //-----------------------------------------------------------------------------
    // DUT and Reactive BFMs 
    //-----------------------------------------------------------------------------

    <%=obj.DutInfo.moduleName%> dut (
    	<%if(obj.DutInfo.nNativeInterfacePorts == 1){%>
			//singleport IOAIU (1 core)	
			.<%=obj.interfaces.axiInt.name%>aw_ready             ( ace_if[0].awready                   ) ,
			.<%=obj.interfaces.axiInt.name%>aw_valid             ( ace_if[0].awvalid                   ) ,
			.<%=obj.interfaces.axiInt.name%>aw_id                ( ace_if[0].awid                      ) ,
			.<%=obj.interfaces.axiInt.name%>aw_addr              ( ace_if[0].awaddr                    ) ,
			.<%=obj.interfaces.axiInt.name%>aw_len               ( ace_if[0].awlen                     ) ,
			.<%=obj.interfaces.axiInt.name%>aw_size              ( ace_if[0].awsize                    ) ,
			.<%=obj.interfaces.axiInt.name%>aw_burst             ( ace_if[0].awburst                   ) ,
			.<%=obj.interfaces.axiInt.name%>aw_lock              ( ace_if[0].awlock                    ) ,
			.<%=obj.interfaces.axiInt.name%>aw_cache             ( ace_if[0].awcache                   ) ,
			.<%=obj.interfaces.axiInt.name%>aw_prot              ( ace_if[0].awprot                    ) ,

                         <%if(obj.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
                
                        .<%=obj.interfaces.axiInt.name%>aw_valid_chk         ( ace_if[0].awvalid_chk               ) ,
                        .<%=obj.interfaces.axiInt.name%>aw_ready_chk         ( ace_if[0].awready_chk               ) ,
                        .<%=obj.interfaces.axiInt.name%>aw_id_chk            ( ace_if[0].awid_chk                  ) ,
                        .<%=obj.interfaces.axiInt.name%>aw_addr_chk          ( ace_if[0].awaddr_chk                ) ,
                        .<%=obj.interfaces.axiInt.name%>aw_len_chk           ( ace_if[0].awlen_chk                 ) ,
                        .<%=obj.interfaces.axiInt.name%>aw_ctl_chk0          ( ace_if[0].awctl_chk0                ) ,
                        .<%=obj.interfaces.axiInt.name%>aw_ctl_chk1          ( ace_if[0].awctl_chk1                ) ,
                       
                        <%}%>
			<%if((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")){%>
				.<%=obj.interfaces.axiInt.name%>aw_snoop             ( ace_if[0].awsnoop                   ) ,
				.<%=obj.interfaces.axiInt.name%>aw_domain            ( ace_if[0].awdomain                  ) ,
				.<%=obj.interfaces.axiInt.name%>aw_bar               ( ace_if[0].awbar                     ) ,
                                <%if(obj.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL' ) {%>
                                .<%=obj.interfaces.axiInt.name%>aw_ctl_chk2          ( ace_if[0].awctl_chk2                ) ,
                                <%}%>
				<%if(obj.DutInfo.cmpInfo.nDvmSnpInFlight){%>
					.<%=obj.interfaces.axiInt.name%>ac_snoop             ( ace_if[0].acsnoop                   ),
					.<%=obj.interfaces.axiInt.name%>ac_addr              ( ace_if[0].acaddr                    ),
					.<%=obj.interfaces.axiInt.name%>ac_prot              ( ace_if[0].acprot                    ),
			    <%if(obj.interfaces.axiInt.params.eAc == 1 && obj.system.DVMVersionSupport > 128){%>
					.<%=obj.interfaces.axiInt.name%>ac_vmidext           ( ace_if[0].acvmidext                 ),
				<%}%>						 
					.<%=obj.interfaces.axiInt.name%>ac_valid             ( ace_if[0].acvalid                   ),
					.<%=obj.interfaces.axiInt.name%>ac_ready             ( ace_if[0].acready                   ),
					.<%=obj.interfaces.axiInt.name%>cr_resp              ( ace_if[0].crresp                    ),
					.<%=obj.interfaces.axiInt.name%>cr_valid             ( ace_if[0].crvalid                   ),
					.<%=obj.interfaces.axiInt.name%>cr_ready             ( ace_if[0].crready                   ),
                                        <%if(obj.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
                 
                                        .<%=obj.interfaces.axiInt.name%>cr_ready_chk         ( ace_if[0].crready_chk               ),
                                        .<%=obj.interfaces.axiInt.name%>cr_valid_chk         ( ace_if[0].crvalid_chk               ),
                                        .<%=obj.interfaces.axiInt.name%>cr_resp_chk          ( ace_if[0].crresp_chk               ),
                                       
                                       <%}%>
				<%}%>						 
			<%}%>
			.<%=obj.interfaces.axiInt.name%>w_ready              ( ace_if[0].wready                    ) ,
			.<%=obj.interfaces.axiInt.name%>w_valid              ( ace_if[0].wvalid                    ) ,
			.<%=obj.interfaces.axiInt.name%>w_data               ( ace_if[0].wdata                     ) ,
			.<%=obj.interfaces.axiInt.name%>w_last               ( ace_if[0].wlast                     ) ,
			.<%=obj.interfaces.axiInt.name%>w_strb               ( ace_if[0].wstrb                     ) ,
                        <%if(obj.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
                 
                        .<%=obj.interfaces.axiInt.name%>w_ready_chk          ( ace_if[0].wready_chk                ) ,
                        .<%=obj.interfaces.axiInt.name%>w_valid_chk          ( ace_if[0].wvalid_chk                ) ,
                        .<%=obj.interfaces.axiInt.name%>w_data_chk           ( ace_if[0].wdata_chk                 ) ,
                        .<%=obj.interfaces.axiInt.name%>w_strb_chk           ( ace_if[0].wstrb_chk                 ) ,
                        .<%=obj.interfaces.axiInt.name%>w_last_chk           ( ace_if[0].wlast_chk                 ) ,
                   
                        <%}%>      

			.<%=obj.interfaces.axiInt.name%>b_ready              ( ace_if[0].bready                    ) ,
			.<%=obj.interfaces.axiInt.name%>b_valid              ( ace_if[0].bvalid                    ) ,
			.<%=obj.interfaces.axiInt.name%>b_id                 ( ace_if[0].bid                       ) ,
			.<%=obj.interfaces.axiInt.name%>b_resp               ( ace_if[0].bresp                     ) ,
                        <%if(obj.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
                  
                        .<%=obj.interfaces.axiInt.name%>b_ready_chk          ( ace_if[0].bready_chk                ) ,
			.<%=obj.interfaces.axiInt.name%>b_valid_chk          ( ace_if[0].bvalid_chk                ) ,
			.<%=obj.interfaces.axiInt.name%>b_id_chk             ( ace_if[0].bid_chk                   ) ,
			.<%=obj.interfaces.axiInt.name%>b_resp_chk           ( ace_if[0].bresp_chk                 ) ,
                      
                        <%}%>

			.<%=obj.interfaces.axiInt.name%>ar_valid             ( ace_if[0].arvalid                   ) ,
			.<%=obj.interfaces.axiInt.name%>ar_ready             ( ace_if[0].arready                   ) ,
			.<%=obj.interfaces.axiInt.name%>ar_id                ( ace_if[0].arid                      ) ,
			.<%=obj.interfaces.axiInt.name%>ar_addr              ( ace_if[0].araddr                    ) ,
			.<%=obj.interfaces.axiInt.name%>ar_len               ( ace_if[0].arlen                     ) ,
			.<%=obj.interfaces.axiInt.name%>ar_size              ( ace_if[0].arsize                    ) ,
			.<%=obj.interfaces.axiInt.name%>ar_burst             ( ace_if[0].arburst                   ) ,
			.<%=obj.interfaces.axiInt.name%>ar_lock              ( ace_if[0].arlock                    ) ,
			.<%=obj.interfaces.axiInt.name%>ar_cache             ( ace_if[0].arcache                   ) ,
			.<%=obj.interfaces.axiInt.name%>ar_prot              ( ace_if[0].arprot                    ) ,
                         <%if(obj.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
                
                        .<%=obj.interfaces.axiInt.name%>ar_valid_chk         ( ace_if[0].arvalid_chk               ) ,
			.<%=obj.interfaces.axiInt.name%>ar_ready_chk         ( ace_if[0].arready_chk               ) ,
			.<%=obj.interfaces.axiInt.name%>ar_id_chk            ( ace_if[0].arid_chk                  ) ,
			.<%=obj.interfaces.axiInt.name%>ar_addr_chk          ( ace_if[0].araddr_chk                ) ,
			.<%=obj.interfaces.axiInt.name%>ar_len_chk           ( ace_if[0].arlen_chk                 ) ,
                        .<%=obj.interfaces.axiInt.name%>ar_ctl_chk0          ( ace_if[0].arctl_chk0                ) ,
                        .<%=obj.interfaces.axiInt.name%>ar_ctl_chk1          ( ace_if[0].arctl_chk1                ) ,
                        <%}%>
			<%if((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")){%>
				.<%=obj.interfaces.axiInt.name%>ar_snoop             ( ace_if[0].arsnoop                   ) ,
				.<%=obj.interfaces.axiInt.name%>ar_domain            ( ace_if[0].ardomain                  ) ,
				.<%=obj.interfaces.axiInt.name%>ar_bar               ( ace_if[0].arbar                     ) ,
                                <%if(obj.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
                                .<%=obj.interfaces.axiInt.name%>ar_ctl_chk2          ( ace_if[0].arctl_chk2                ) ,
                                <%}%>
			<%if(obj.interfaces.axiInt.params.eAc == 1 && obj.system.DVMVersionSupport > 128){%>
				.<%=obj.interfaces.axiInt.name%>ar_vmidext           ( ace_if[0].arvmidext                 ) ,
                                 <%if(obj.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
                                 .<%=obj.interfaces.axiInt.name%>ar_ctl_chk3           ( ace_if[0].arctl_chk3                 ) ,
                                 <%}%>

			<%}%>
			<%}%>

			.<%=obj.interfaces.axiInt.name%>r_ready              ( ace_if[0].rready                    ) ,
			.<%=obj.interfaces.axiInt.name%>r_valid              ( ace_if[0].rvalid                    ) ,
			.<%=obj.interfaces.axiInt.name%>r_resp               ( ace_if[0].rresp                     ) ,
			.<%=obj.interfaces.axiInt.name%>r_data               ( ace_if[0].rdata                     ) ,
			.<%=obj.interfaces.axiInt.name%>r_last               ( ace_if[0].rlast                     ) ,
			.<%=obj.interfaces.axiInt.name%>r_id                 ( ace_if[0].rid                       ) ,
                         <%if(obj.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
                 
                        .<%=obj.interfaces.axiInt.name%>r_ready_chk          ( ace_if[0].rready_chk                ) ,
			.<%=obj.interfaces.axiInt.name%>r_valid_chk          ( ace_if[0].rvalid_chk                ) ,
			.<%=obj.interfaces.axiInt.name%>r_resp_chk           ( ace_if[0].rresp_chk                 ) ,
			.<%=obj.interfaces.axiInt.name%>r_data_chk           ( ace_if[0].rdata_chk                 ) ,
			.<%=obj.interfaces.axiInt.name%>r_last_chk           ( ace_if[0].rlast_chk                 ) ,
	        	.<%=obj.interfaces.axiInt.name%>r_id_chk             ( ace_if[0].rid_chk                   ) ,

                        <%}%>

			<%if(obj.interfaces.axiInt.params.eTrace){%>
				.<%=obj.interfaces.axiInt.name%>ar_trace             ( ace_if[0].artrace                   ) ,
				.<%=obj.interfaces.axiInt.name%>r_trace              ( ace_if[0].rtrace                    ) ,
				.<%=obj.interfaces.axiInt.name%>aw_trace             ( ace_if[0].awtrace                   ) ,
				.<%=obj.interfaces.axiInt.name%>w_trace              ( ace_if[0].wtrace                    ) ,
				.<%=obj.interfaces.axiInt.name%>b_trace              ( ace_if[0].btrace                    ) ,
                                <%if(obj.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
                 
                                .<%=obj.interfaces.axiInt.name%>ar_trace_chk         ( ace_if[0].artrace_chk               ) ,
				.<%=obj.interfaces.axiInt.name%>r_trace_chk          ( ace_if[0].rtrace_chk                ) ,
				.<%=obj.interfaces.axiInt.name%>aw_trace_chk         ( ace_if[0].awtrace_chk               ) ,
			        .<%=obj.interfaces.axiInt.name%>w_trace_chk          ( ace_if[0].wtrace_chk                ) ,
				.<%=obj.interfaces.axiInt.name%>b_trace_chk          ( ace_if[0].btrace_chk                ) ,
		
                                <%}%>
			  <%if(obj.fnNativeInterface === "ACE" || obj.fnNativeInterface === "ACE5" || (obj.fnNativeInterface == "ACELITE-E" && obj.interfaces.axiInt.params.eAc == 1)){%>
				.<%=obj.interfaces.axiInt.name%>ac_trace             ( ace_if[0].actrace                    ) ,
				.<%=obj.interfaces.axiInt.name%>cr_trace             ( ace_if[0].crtrace                    ) ,
			  <%}%>
			<%}%>
			<%if(obj.interfaces.axiInt.params.wQos){%>		 
				.<%=obj.interfaces.axiInt.name%>aw_qos               ( ace_if[0].awqos                     ) ,
				.<%=obj.interfaces.axiInt.name%>ar_qos               ( ace_if[0].arqos                     ) ,
			<%}%>
			<%if(obj.interfaces.axiInt.params.wAwUser){%>
				.<%=obj.interfaces.axiInt.name%>aw_user              ( ace_if[0].awuser                    ) ,
                                <%if(obj.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
                                .<%=obj.interfaces.axiInt.name%>aw_user_chk              ( ace_if[0].awuser_chk            ) , 
                                <%}%>
			<%}%>
			<%if(obj.interfaces.axiInt.params.wArUser){%>
				.<%=obj.interfaces.axiInt.name%>ar_user              ( ace_if[0].aruser                    ) ,
                                <%if(obj.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
                                .<%=obj.interfaces.axiInt.name%>ar_user_chk              ( ace_if[0].aruser_chk            ) , 
                                <%}%>
			<%}%>
			<%if(obj.interfaces.axiInt.params.wWUser){%>
				.<%=obj.interfaces.axiInt.name%>w_user              ( ace_if[0].wuser                    ) ,
                                <%if(obj.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
                                .<%=obj.interfaces.axiInt.name%>w_user_chk              ( ace_if[0].wuser_chk            ) , 
                                <%}%>
			<%}%>
			<%if(obj.interfaces.axiInt.params.wRUser){%>
				.<%=obj.interfaces.axiInt.name%>r_user              ( ace_if[0].ruser                    ) ,
                                <%if(obj.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
                                .<%=obj.interfaces.axiInt.name%>r_user_chk              ( ace_if[0].ruser_chk            ) , 
                                <%}%>
			<%}%>
			<%if(obj.interfaces.axiInt.params.wBUser){%>
				.<%=obj.interfaces.axiInt.name%>b_user              ( ace_if[0].buser                    ) ,
                                <%if(obj.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
				.<%=obj.interfaces.axiInt.name%>b_user_chk              ( ace_if[0].buser_chk                    ) ,
                                <%}%>
			<%}%>
			<%if(((obj.fnNativeInterface == "AXI5") || (obj.fnNativeInterface == "ACELITE-E")) && (obj.interfaces.axiInt.params.atomicTransactions == true)){%>
			        .<%=obj.interfaces.axiInt.name%>aw_atop              ( ace_if[0].awatop                    ) ,
                                 <%if(obj.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
                                .<%=obj.interfaces.axiInt.name%>aw_ctl_chk3          ( ace_if[0].awctl_chk3                ) ,
                                <%}%>
			<%}%>
			<%if(obj.fnNativeInterface === "ACELITE-E"){%>
				.<%=obj.interfaces.axiInt.name%>aw_stashnid          ( ace_if[0].awstashnid                ) ,
				.<%=obj.interfaces.axiInt.name%>aw_stashniden        ( ace_if[0].awstashniden              ) ,
				.<%=obj.interfaces.axiInt.name%>aw_stashlpid         ( ace_if[0].awstashlpid               ) ,
				.<%=obj.interfaces.axiInt.name%>aw_stashlpiden       ( ace_if[0].awstashlpiden             ) ,
                                <%if(obj.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL' ) {%>
                                .<%=obj.interfaces.axiInt.name%>aw_stashnid_chk       ( ace_if[0].awstashnid_chk         ) ,
                                .<%=obj.interfaces.axiInt.name%>aw_stashlpid_chk       ( ace_if[0].awstashlpid_chk         ) ,
                                <%if( obj.interfaces.axiInt.params.eAc == 1) {%>
                                .<%=obj.interfaces.axiInt.name%>cr_valid_chk          ( ace_if[0].crvalid_chk               ) ,
				.<%=obj.interfaces.axiInt.name%>cr_ready_chk          ( ace_if[0].crready_chk               ) ,
                                <%if(obj.DutInfo.cmpInfo.nDvmSnpInFlight){%>
				.<%=obj.interfaces.axiInt.name%>cr_resp_chk           ( ace_if[0].crresp_chk                ) ,
                                <%}%>
                                .<%=obj.interfaces.axiInt.name%>ac_valid_chk              ( ace_if[0].acvalid_chk                   ) ,
				.<%=obj.interfaces.axiInt.name%>ac_ready_chk              ( ace_if[0].acready_chk                   ) ,
				.<%=obj.interfaces.axiInt.name%>ac_addr_chk               ( ace_if[0].acaddr_chk                    ) ,
                                .<%=obj.interfaces.axiInt.name%>ac_trace_chk             ( ace_if[0].actrace_chk                    ) ,
                                .<%=obj.interfaces.axiInt.name%>ac_ctl_chk             ( ace_if[0].acctl_chk                    ) ,
                                <%if(obj.system.DVMVersionSupport > 128) {%>
                                .<%=obj.interfaces.axiInt.name%>ac_vmidext_chk             ( ace_if[0].acvmidext_chk                    ) ,
                                <%}%>

                                .<%=obj.interfaces.axiInt.name%>cr_trace_chk             ( ace_if[0].crtrace_chk                    ) ,
                                //.<%=obj.interfaces.axiInt.name%>cd_valid_chk              ( ace_if[0].cdvalid_chk                   ) ,
				//.<%=obj.interfaces.axiInt.name%>cd_ready_chk              ( ace_if[0].cdready_chk                   ) ,
				//.<%=obj.interfaces.axiInt.name%>cd_data_chk               ( ace_if[0].cddata_chk                    ) ,
                                //.<%=obj.interfaces.axiInt.name%>cd_last_chk               ( ace_if[0].cdlast_chk),
                                <%}%>
                                <%}%>
			<%}%>
			<%if(obj.fnNativeInterface === "ACE" || obj.fnNativeInterface === "ACE5"){%>
				.<%=obj.interfaces.axiInt.name%>ac_valid              ( ace_if[0].acvalid                   ) ,
				.<%=obj.interfaces.axiInt.name%>ac_ready              ( ace_if[0].acready                   ) ,
				.<%=obj.interfaces.axiInt.name%>ac_addr               ( ace_if[0].acaddr                    ) ,
				.<%=obj.interfaces.axiInt.name%>ac_snoop              ( ace_if[0].acsnoop                   ) ,
				.<%=obj.interfaces.axiInt.name%>ac_prot               ( ace_if[0].acprot                    ) ,
            //eAc =<%=obj.interfaces.axiInt.params.eAc%> & DVMVersionSupport=<%=obj.system.DVMVersionSupport%>
			<%if(obj.interfaces.axiInt.params.eAc == 1 && obj.system.DVMVersionSupport > 128){%>
				.<%=obj.interfaces.axiInt.name%>ac_vmidext            ( ace_if[0].acvmidext                 ) ,
			<%}%>

				.<%=obj.interfaces.axiInt.name%>cr_valid              ( ace_if[0].crvalid                   ) ,
				.<%=obj.interfaces.axiInt.name%>cr_ready              ( ace_if[0].crready                   ) ,
				.<%=obj.interfaces.axiInt.name%>cr_resp               ( ace_if[0].crresp                    ) ,
                                <%if(obj.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
                                .<%=obj.interfaces.axiInt.name%>ac_valid_chk              ( ace_if[0].acvalid_chk                   ) ,
				.<%=obj.interfaces.axiInt.name%>ac_ready_chk              ( ace_if[0].acready_chk                   ) ,
				.<%=obj.interfaces.axiInt.name%>ac_addr_chk               ( ace_if[0].acaddr_chk                    ) ,
                                //.<%=obj.interfaces.axiInt.name%>ac_trace_chk             ( ace_if[0].actrace_chk                    ) ,
                                .<%=obj.interfaces.axiInt.name%>ac_ctl_chk             ( ace_if[0].acctl_chk                    ) ,
                                <%if(obj.system.DVMVersionSupport > 128) {%>
                                .<%=obj.interfaces.axiInt.name%>ac_vmidext_chk             ( ace_if[0].acvmidext_chk                    ) ,
                                <%}%>
                  
                                .<%=obj.interfaces.axiInt.name%>cr_valid_chk          ( ace_if[0].crvalid_chk               ) ,
				.<%=obj.interfaces.axiInt.name%>cr_ready_chk          ( ace_if[0].crready_chk               ) ,
				.<%=obj.interfaces.axiInt.name%>cr_resp_chk           ( ace_if[0].crresp_chk                ) ,

			<%if(obj.interfaces.axiInt.params.eTrace){%>
                                .<%=obj.interfaces.axiInt.name%>cr_trace_chk             ( ace_if[0].crtrace_chk                    ) ,
                                .<%=obj.interfaces.axiInt.name%>ac_trace_chk             ( ace_if[0].actrace_chk                    ) ,
                                <%}%>

                                <%}%>
  

				.<%=obj.interfaces.axiInt.name%>cd_valid              ( ace_if[0].cdvalid                   ) ,
				.<%=obj.interfaces.axiInt.name%>cd_ready              ( ace_if[0].cdready                   ) ,
				.<%=obj.interfaces.axiInt.name%>cd_data               ( ace_if[0].cddata                    ) ,
                                <%if(obj.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') {%>
                 
                                .<%=obj.interfaces.axiInt.name%>aw_ctl_chk2          ( ace_if[0].awctl_chk2                ) ,
                                .<%=obj.interfaces.axiInt.name%>ar_ctl_chk2          ( ace_if[0].arctl_chk2                ) ,
                                 .<%=obj.interfaces.axiInt.name%>ar_ctl_chk3           ( ace_if[0].arctl_chk3                 ) ,
                               .<%=obj.interfaces.axiInt.name%>cd_valid_chk              ( ace_if[0].cdvalid_chk                   ) ,
			       .<%=obj.interfaces.axiInt.name%>cd_ready_chk              ( ace_if[0].cdready_chk                   ) ,
			       .<%=obj.interfaces.axiInt.name%>cd_data_chk               ( ace_if[0].cddata_chk                    ) ,
                               .<%=obj.interfaces.axiInt.name%>cd_last_chk               ( ace_if[0].cdlast_chk),
				.<%=obj.interfaces.axiInt.name%>w_ack_chk                 ( ace_if[0].wack_chk                      ) ,
				.<%=obj.interfaces.axiInt.name%>r_ack_chk                 ( ace_if[0].rack_chk                      ) ,

                                <%}%>
				.<%=obj.interfaces.axiInt.name%>cd_last               ( ace_if[0].cdlast                    ) ,

				.<%=obj.interfaces.axiInt.name%>w_ack                 ( ace_if[0].wack                      ) ,
				.<%=obj.interfaces.axiInt.name%>r_ack                 ( ace_if[0].rack                      ) ,

				.<%=obj.interfaces.axiInt.name%>aw_snoop              ( ace_if[0].awsnoop                   ) ,
				.<%=obj.interfaces.axiInt.name%>aw_domain             ( ace_if[0].awdomain                  ) ,
				.<%=obj.interfaces.axiInt.name%>aw_bar                ( ace_if[0].awbar                     ) ,
				.<%=obj.interfaces.axiInt.name%>aw_unique             ( ace_if[0].awunique                  ) ,

				.<%=obj.interfaces.axiInt.name%>ar_snoop              ( ace_if[0].arsnoop                   ) ,
				.<%=obj.interfaces.axiInt.name%>ar_domain             ( ace_if[0].ardomain                  ) ,
				.<%=obj.interfaces.axiInt.name%>ar_bar                ( ace_if[0].arbar                     ) ,
			<%if(obj.interfaces.axiInt.params.eAc == 1 && obj.system.DVMVersionSupport > 128){%>
				.<%=obj.interfaces.axiInt.name%>ar_vmidext            ( ace_if[0].arvmidext                 ) ,
			<%}%>
			<%}%>
    	<%} else {%>

    		//multiport IOAIU (>1 core)	
			<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
					.<%=obj.interfaces.axiInt[i].name%>aw_ready             ( ace_if[<%=i%>].awready           		) ,
					.<%=obj.interfaces.axiInt[i].name%>aw_valid             ( ace_if[<%=i%>].awvalid                   ) ,
					.<%=obj.interfaces.axiInt[i].name%>aw_id                ( ace_if[<%=i%>].awid                      ) ,
					.<%=obj.interfaces.axiInt[i].name%>aw_addr              ( ace_if[<%=i%>].awaddr                    ) ,
					.<%=obj.interfaces.axiInt[i].name%>aw_len               ( ace_if[<%=i%>].awlen                     ) ,
					.<%=obj.interfaces.axiInt[i].name%>aw_size              ( ace_if[<%=i%>].awsize                    ) ,
					.<%=obj.interfaces.axiInt[i].name%>aw_burst             ( ace_if[<%=i%>].awburst                   ) ,
					.<%=obj.interfaces.axiInt[i].name%>aw_lock              ( ace_if[<%=i%>].awlock                    ) ,
					.<%=obj.interfaces.axiInt[i].name%>aw_cache             ( ace_if[<%=i%>].awcache                   ) ,
					.<%=obj.interfaces.axiInt[i].name%>aw_prot              ( ace_if[<%=i%>].awprot                    ) ,
					<%if((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")){%>
						.<%=obj.interfaces.axiInt[i].name%>aw_snoop             ( ace_if[<%=i%>].awsnoop                   ) ,
						.<%=obj.interfaces.axiInt[i].name%>aw_domain            ( ace_if[<%=i%>].awdomain                  ) ,
						.<%=obj.interfaces.axiInt[i].name%>aw_bar               ( ace_if[<%=i%>].awbar                     ) ,
						<%if(obj.DutInfo.cmpInfo.nDvmSnpInFlight){%>
							.<%=obj.interfaces.axiInt[i].name%>ac_snoop             ( ace_if[<%=i%>].acsnoop                   ),
							.<%=obj.interfaces.axiInt[i].name%>ac_addr              ( ace_if[<%=i%>].acaddr                    ),
							.<%=obj.interfaces.axiInt[i].name%>ac_prot              ( ace_if[<%=i%>].acprot                    ),
			            <%if(obj.interfaces.axiInt.params.eAc == 1 && obj.system.DVMVersionSupport > 128){%>
							.<%=obj.interfaces.axiInt[i].name%>ac_vmidext           ( ace_if[<%=i%>].acvmidext                 ),
			            <%}%>
							.<%=obj.interfaces.axiInt[i].name%>ac_valid             ( ace_if[<%=i%>].acvalid                   ),
							.<%=obj.interfaces.axiInt[i].name%>ac_ready             ( ace_if[<%=i%>].acready                   ),
							.<%=obj.interfaces.axiInt[i].name%>cr_resp              ( ace_if[<%=i%>].crresp                    ),
							.<%=obj.interfaces.axiInt[i].name%>cr_valid             ( ace_if[<%=i%>].crvalid                   ),
							.<%=obj.interfaces.axiInt[i].name%>cr_ready             ( ace_if[<%=i%>].crready                   ),
						<%}%>						 
					<%}%>
					.<%=obj.interfaces.axiInt[i].name%>w_ready              ( ace_if[<%=i%>].wready                    ) ,
					.<%=obj.interfaces.axiInt[i].name%>w_valid              ( ace_if[<%=i%>].wvalid                    ) ,
					.<%=obj.interfaces.axiInt[i].name%>w_data               ( ace_if[<%=i%>].wdata                     ) ,
					.<%=obj.interfaces.axiInt[i].name%>w_last               ( ace_if[<%=i%>].wlast                     ) ,
					.<%=obj.interfaces.axiInt[i].name%>w_strb               ( ace_if[<%=i%>].wstrb                     ) ,
					.<%=obj.interfaces.axiInt[i].name%>b_ready              ( ace_if[<%=i%>].bready                    ) ,
					.<%=obj.interfaces.axiInt[i].name%>b_valid              ( ace_if[<%=i%>].bvalid                    ) ,
					.<%=obj.interfaces.axiInt[i].name%>b_id                 ( ace_if[<%=i%>].bid                       ) ,
					.<%=obj.interfaces.axiInt[i].name%>b_resp               ( ace_if[<%=i%>].bresp                     ) ,
					.<%=obj.interfaces.axiInt[i].name%>ar_valid             ( ace_if[<%=i%>].arvalid                   ) ,
					.<%=obj.interfaces.axiInt[i].name%>ar_ready             ( ace_if[<%=i%>].arready                   ) ,
					.<%=obj.interfaces.axiInt[i].name%>ar_id                ( ace_if[<%=i%>].arid                      ) ,
					.<%=obj.interfaces.axiInt[i].name%>ar_addr              ( ace_if[<%=i%>].araddr                    ) ,
					.<%=obj.interfaces.axiInt[i].name%>ar_len               ( ace_if[<%=i%>].arlen                     ) ,
					.<%=obj.interfaces.axiInt[i].name%>ar_size              ( ace_if[<%=i%>].arsize                    ) ,
					.<%=obj.interfaces.axiInt[i].name%>ar_burst             ( ace_if[<%=i%>].arburst                   ) ,
					.<%=obj.interfaces.axiInt[i].name%>ar_lock              ( ace_if[<%=i%>].arlock                    ) ,
					.<%=obj.interfaces.axiInt[i].name%>ar_cache             ( ace_if[<%=i%>].arcache                   ) ,
					.<%=obj.interfaces.axiInt[i].name%>ar_prot              ( ace_if[<%=i%>].arprot                    ) ,
					<%if((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")){%>
						.<%=obj.interfaces.axiInt[i].name%>ar_snoop             ( ace_if[<%=i%>].arsnoop                   ) ,
						.<%=obj.interfaces.axiInt[i].name%>ar_domain            ( ace_if[<%=i%>].ardomain                  ) ,
						.<%=obj.interfaces.axiInt[i].name%>ar_bar               ( ace_if[<%=i%>].arbar                     ) ,
			        <%if(obj.interfaces.axiInt.params.eAc == 1 && obj.system.DVMVersionSupport > 128){%>
						.<%=obj.interfaces.axiInt[i].name%>ar_vmidext           ( ace_if[<%=i%>].arvmidext                 ) ,
					<%}%>
					<%}%>

					.<%=obj.interfaces.axiInt[i].name%>r_ready              ( ace_if[<%=i%>].rready                    ) ,
					.<%=obj.interfaces.axiInt[i].name%>r_valid              ( ace_if[<%=i%>].rvalid                    ) ,
					.<%=obj.interfaces.axiInt[i].name%>r_resp               ( ace_if[<%=i%>].rresp                     ) ,
					.<%=obj.interfaces.axiInt[i].name%>r_data               ( ace_if[<%=i%>].rdata                     ) ,
					.<%=obj.interfaces.axiInt[i].name%>r_last               ( ace_if[<%=i%>].rlast                     ) ,
					.<%=obj.interfaces.axiInt[i].name%>r_id                 ( ace_if[<%=i%>].rid                       ) ,

					<%if(obj.interfaces.axiInt[i].params.eTrace){%>
						.<%=obj.interfaces.axiInt[i].name%>ar_trace             ( ace_if[<%=i%>].artrace                   ) ,
						.<%=obj.interfaces.axiInt[i].name%>r_trace              ( ace_if[<%=i%>].rtrace                    ) ,
						.<%=obj.interfaces.axiInt[i].name%>aw_trace             ( ace_if[<%=i%>].awtrace                   ) ,
						.<%=obj.interfaces.axiInt[i].name%>w_trace              ( ace_if[<%=i%>].wtrace                    ) ,
						.<%=obj.interfaces.axiInt[i].name%>b_trace              ( ace_if[<%=i%>].btrace                    ) ,
					<%}%>
					<%if(obj.interfaces.axiInt[i].params.wQos){%>		 
						.<%=obj.interfaces.axiInt[i].name%>aw_qos               ( ace_if[<%=i%>].awqos                     ) ,
						.<%=obj.interfaces.axiInt[i].name%>ar_qos               ( ace_if[<%=i%>].arqos                     ) ,
					<%}%>
					<%if(obj.interfaces.axiInt[i].params.wAwUser){%>
						.<%=obj.interfaces.axiInt[i].name%>aw_user              ( ace_if[<%=i%>].awuser                    ) ,
					<%}%>
					<%if(obj.interfaces.axiInt[i].params.wArUser){%>
						.<%=obj.interfaces.axiInt[i].name%>ar_user              ( ace_if[<%=i%>].aruser                    ) ,
					<%}%>
					<%if(obj.interfaces.axiInt[i].params.wWUser){%>
						.<%=obj.interfaces.axiInt[i].name%>w_user              ( ace_if[<%=i%>].wuser                    ) ,
					<%}%>
					<%if(obj.interfaces.axiInt[i].params.wRUser){%>
						.<%=obj.interfaces.axiInt[i].name%>r_user              ( ace_if[<%=i%>].ruser                    ) ,
					<%}%>
					<%if(obj.interfaces.axiInt[i].params.wBUser){%>
						.<%=obj.interfaces.axiInt[i].name%>b_user              ( ace_if[<%=i%>].buser                    ) ,
					<%}%>
					<%if(obj.fnNativeInterface === "ACELITE-E"){%>
						.<%=obj.interfaces.axiInt[i].name%>aw_atop              ( ace_if[<%=i%>].awatop                    ) ,
						.<%=obj.interfaces.axiInt[i].name%>aw_stashnid          ( ace_if[<%=i%>].awstashnid                ) ,
						.<%=obj.interfaces.axiInt[i].name%>aw_stashniden        ( ace_if[<%=i%>].awstashniden              ) ,
						.<%=obj.interfaces.axiInt[i].name%>aw_stashlpid         ( ace_if[<%=i%>].awstashlpid               ) ,
						.<%=obj.interfaces.axiInt[i].name%>aw_stashlpiden       ( ace_if[<%=i%>].awstashlpiden             ) ,
					<%}%>
					<%if(obj.fnNativeInterface === "ACE" || obj.fnNativeInterface === "ACE5"){%>
						.<%=obj.interfaces.axiInt[i].name%>ac_valid              ( ace_if[<%=i%>].acvalid                   ) ,
						.<%=obj.interfaces.axiInt[i].name%>ac_ready              ( ace_if[<%=i%>].acready                   ) ,
						.<%=obj.interfaces.axiInt[i].name%>ac_addr               ( ace_if[<%=i%>].acaddr                    ) ,
						.<%=obj.interfaces.axiInt[i].name%>ac_snoop              ( ace_if[<%=i%>].acsnoop                   ) ,
						.<%=obj.interfaces.axiInt[i].name%>ac_prot               ( ace_if[<%=i%>].acprot                    ) ,
						.<%=obj.interfaces.axiInt[i].name%>ac_vmidext            ( ace_if[<%=i%>].acvmidext                 ) ,

						.<%=obj.interfaces.axiInt[i].name%>cr_valid              ( ace_if[<%=i%>].crvalid                   ) ,
						.<%=obj.interfaces.axiInt[i].name%>cr_ready              ( ace_if[<%=i%>].crready                   ) ,
						.<%=obj.interfaces.axiInt[i].name%>cr_resp               ( ace_if[<%=i%>].crresp                    ) ,

						.<%=obj.interfaces.axiInt[i].name%>cd_valid              ( ace_if[<%=i%>].cdvalid                   ) ,
						.<%=obj.interfaces.axiInt[i].name%>cd_ready              ( ace_if[<%=i%>].cdready                   ) ,
						.<%=obj.interfaces.axiInt[i].name%>cd_data               ( ace_if[<%=i%>].cddata                    ) ,
						.<%=obj.interfaces.axiInt[i].name%>cd_last               ( ace_if[<%=i%>].cdlast                    ) ,

						.<%=obj.interfaces.axiInt[i].name%>w_ack                 ( ace_if[<%=i%>].wack                      ) ,
						.<%=obj.interfaces.axiInt[i].name%>r_ack                 ( ace_if[<%=i%>].rack                      ) ,

						.<%=obj.interfaces.axiInt[i].name%>aw_snoop              ( ace_if[<%=i%>].awsnoop                   ) ,
						.<%=obj.interfaces.axiInt[i].name%>aw_domain             ( ace_if[<%=i%>].awdomain                  ) ,
						.<%=obj.interfaces.axiInt[i].name%>aw_bar                ( ace_if[<%=i%>].awbar                     ) ,
						.<%=obj.interfaces.axiInt[i].name%>aw_unique             ( ace_if[<%=i%>].awunique                  ) ,

						.<%=obj.interfaces.axiInt[i].name%>ar_snoop              ( ace_if[<%=i%>].arsnoop                   ) ,
						.<%=obj.interfaces.axiInt[i].name%>ar_domain             ( ace_if[<%=i%>].ardomain                  ) ,
						.<%=obj.interfaces.axiInt[i].name%>ar_bar                ( ace_if[<%=i%>].arbar                     ) ,
						.<%=obj.interfaces.axiInt[i].name%>ar_vmidext            ( ace_if[<%=i%>].arvmidext                 ) ,
					<%}%>
				<%}%>
			<%}%>



        <%for(var i = 0; i < NSMIIFRX; i++){%>
            .<%=obj.interfaces.smiTxInt[i].name %>ndp_msg_valid        (port<%=i%>_rx_smi_if.smi_msg_valid ) ,
            .<%=obj.interfaces.smiTxInt[i].name %>ndp_msg_ready        (port<%=i%>_rx_smi_if.smi_msg_ready  ) ,
            .<%=obj.interfaces.smiTxInt[i].name %>ndp_ndp_len          (port<%=i%>_rx_smi_if.smi_ndp_len   ) ,
            .<%=obj.interfaces.smiTxInt[i].name %>ndp_dp_present       (port<%=i%>_rx_smi_if.smi_dp_present) ,
            .<%=obj.interfaces.smiTxInt[i].name %>ndp_targ_id          (port<%=i%>_rx_smi_if.smi_targ_id   ) ,
            .<%=obj.interfaces.smiTxInt[i].name %>ndp_src_id           (port<%=i%>_rx_smi_if.smi_src_id    ) ,
            .<%=obj.interfaces.smiTxInt[i].name %>ndp_msg_id           (port<%=i%>_rx_smi_if.smi_msg_id    ) ,
            .<%=obj.interfaces.smiTxInt[i].name %>ndp_msg_type         (port<%=i%>_rx_smi_if.smi_msg_type  ) ,
            <%if(obj.interfaces.smiTxInt[i].params.wSmiUser >0){%>
                .<%=obj.interfaces.smiTxInt[i].name %>ndp_msg_user         (port<%=i%>_rx_smi_if.smi_msg_user  ) ,
            <%}%>
            <%if(obj.interfaces.smiTxInt[i].params.wSmiTier >0){%>
                .<%=obj.interfaces.smiTxInt[i].name%>ndp_msg_tier          (port<%=i%>_rx_smi_if.smi_msg_tier  ) ,
            <%}%>
            <%if(obj.interfaces.smiTxInt[i].params.wSmiSteer >0){%>
                .<%=obj.interfaces.smiTxInt[i].name%>ndp_steer             (port<%=i%>_rx_smi_if.smi_steer     ) ,
            <%}%>
            <%if(obj.interfaces.smiTxInt[i].params.wSmiPri >0){%>
                .<%=obj.interfaces.smiTxInt[i].name%>ndp_msg_pri           (port<%=i%>_rx_smi_if.smi_msg_pri   ) ,
            <%}%>
            <%if(obj.interfaces.smiTxInt[i].params.wSmiMsgQos >0){%>
                .<%=obj.interfaces.smiTxInt[i].name%>ndp_msg_qos           (port<%=i%>_rx_smi_if.smi_msg_qos   ) ,
            <%}%>
            .<%=obj.interfaces.smiTxInt[i].name%>ndp_ndp               (port<%=i%>_rx_smi_if.smi_ndp[<%=wNDPTX[i]-1%>:0]) ,
            <%if(obj.interfaces.smiTxInt[i].params.wSmiErr >0){%>
                .<%=obj.interfaces.smiTxInt[i].name%>ndp_msg_err           (port<%=i%>_rx_smi_if.smi_msg_err   ) ,
            <%}%>
            <%if(obj.interfaces.smiTxInt[i].params.nSmiDPvc){%>    
                .<%=obj.interfaces.smiTxInt[i].name%>dp_valid              (port<%=i%>_rx_smi_if.smi_dp_valid  ) ,
                .<%=obj.interfaces.smiTxInt[i].name%>dp_ready              (port<%=i%>_rx_smi_if.smi_dp_ready  ) ,
                .<%=obj.interfaces.smiTxInt[i].name%>dp_last               (port<%=i%>_rx_smi_if.smi_dp_last   ) ,
                .<%=obj.interfaces.smiTxInt[i].name%>dp_data               (port<%=i%>_rx_smi_if.smi_dp_data   ) ,
                <%if(obj.interfaces.smiTxInt[i].params.wSmiDPuser >0){%>
                    .<%=obj.interfaces.smiTxInt[i].name%>dp_user               (port<%=i%>_rx_smi_if.smi_dp_user   ) ,
                <%}%>
            <%}%>
        <%}%>
        <%for(var i = 0; i < NSMIIFTX; i++){%>
            .<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_valid         (port<%=i%>_tx_smi_if.smi_msg_valid ) ,
            .<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_ready         (port<%=i%>_tx_smi_if.smi_msg_ready ) ,
            .<%=obj.interfaces.smiRxInt[i].name%>ndp_ndp_len           (port<%=i%>_tx_smi_if.smi_ndp_len   ) ,
            .<%=obj.interfaces.smiRxInt[i].name%>ndp_dp_present        (port<%=i%>_tx_smi_if.smi_dp_present) ,
            .<%=obj.interfaces.smiRxInt[i].name%>ndp_targ_id           (port<%=i%>_tx_smi_if.smi_targ_id   ) ,
            .<%=obj.interfaces.smiRxInt[i].name%>ndp_src_id            (port<%=i%>_tx_smi_if.smi_src_id    ) ,
            .<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_id            (port<%=i%>_tx_smi_if.smi_msg_id    ) ,
            .<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_type          (port<%=i%>_tx_smi_if.smi_msg_type  ) ,
            <%if(obj.interfaces.smiRxInt[i].params.wSmiUser >0){%>
                .<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_user          (port<%=i%>_tx_smi_if.smi_msg_user  ) ,
            <%}%>
            <%if(obj.interfaces.smiRxInt[i].params.wSmiTier >0){%>
                .<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_tier          (port<%=i%>_tx_smi_if.smi_msg_tier  ) ,
            <%}%>
            <%if(obj.interfaces.smiRxInt[i].params.wSmiSteer >0){%>
                .<%=obj.interfaces.smiRxInt[i].name%>ndp_steer             (port<%=i%>_tx_smi_if.smi_steer     ) ,
            <%}%>
            <%if(obj.interfaces.smiRxInt[i].params.wSmiPri >0){%>
                .<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_pri           (port<%=i%>_tx_smi_if.smi_msg_pri   ) ,
            <%}%>
            <%if(obj.interfaces.smiRxInt[i].params.wSmiMsgQos >0){%>
                .<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_qos           (port<%=i%>_tx_smi_if.smi_msg_qos   ) ,
            <%}%>
            .<%=obj.interfaces.smiRxInt[i].name%>ndp_ndp               (port<%=i%>_tx_smi_if.smi_ndp[<%=wNDPRX[i]-1%>:0]   ) ,
            <%if(obj.interfaces.smiRxInt[i].params.wSmiErr >0){%>
                .<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_err           (port<%=i%>_tx_smi_if.smi_msg_err   ) ,
            <%}%>
            <%if(obj.interfaces.smiRxInt[i].params.nSmiDPvc){%>    
                .<%=obj.interfaces.smiRxInt[i].name%>dp_valid              (port<%=i%>_tx_smi_if.smi_dp_valid  ) ,
                .<%=obj.interfaces.smiRxInt[i].name%>dp_ready              (port<%=i%>_tx_smi_if.smi_dp_ready  ) ,
                .<%=obj.interfaces.smiRxInt[i].name%>dp_last               (port<%=i%>_tx_smi_if.smi_dp_last   ) ,
                .<%=obj.interfaces.smiRxInt[i].name%>dp_data               (port<%=i%>_tx_smi_if.smi_dp_data   ) ,
                <%if(obj.interfaces.smiRxInt[i].params.wSmiDPuser >0){%>
                    .<%=obj.interfaces.smiRxInt[i].name%>dp_user               (port<%=i%>_tx_smi_if.smi_dp_user   ) ,
                <%}%>
            <%}%>
        <%}%>
        <%if(obj.DutInfo.nNativeInterfacePorts === 1) {%>
            .uId_my_f_unit_id ( <%=obj.DutInfo.wFUnitId%>'d<%=obj.DutInfo.FUnitId%>),
            .uId_my_n_unit_id ( <%=obj.DutInfo.wNUnitId%>'d<%=obj.DutInfo.nUnitId%>),
            .uId_my_csr_nrri  ( <%=obj.DutInfo.wNrri%>'d<%=obj.DutInfo.nrri%>),
            .uId_my_csr_rpn   ( <%=obj.DutInfo.wRpn%>'d<%=obj.DutInfo.rpn%> ),
        <%} else {%>
            <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                //.uId<%=i%>_my_f_unit_id ( <%=obj.interfaces.uIdInt[i].params.wFUnitId%>),
                //.uId<%=i%>_my_n_unit_id ( <%=obj.interfaces.uIdInt[i].params.wNUnitId%>),
                //.uId<%=i%>_my_csr_nrri  ( <%=obj.interfaces.uIdInt[i].params.wNrri%>),
                //.uId<%=i%>_my_csr_rpn   ( <%=obj.interfaces.uIdInt[i].params.wRpn%> ),
                .uId<%=i%>_my_f_unit_id ( <%=obj.DutInfo.wFUnitId%>'d<%=obj.DutInfo.FUnitId%>),
                .uId<%=i%>_my_n_unit_id ( <%=obj.DutInfo.wNUnitId%>'d<%=obj.DutInfo.nUnitId%>),
                .uId<%=i%>_my_csr_nrri  ( <%=obj.DutInfo.wNrri%>'d<%=obj.DutInfo.nrri%>),
                .uId<%=i%>_my_csr_rpn   ( <%=obj.DutInfo.wRpn%>'d<%=obj.DutInfo.rpn[i]%> ),
            <%}%>
        <%}%>
        // <%if(obj.DutInfo.nNativeInterfacePorts === 1){%>
        //     .uId0_my_csr_rpn ( <%=obj.DutInfo.rpn%> ),
        // <%}else{%>
        //     <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
        //         .uId<%=i%>_my_csr_rpn ( <%=obj.DutInfo.rpn[i]%> ),
        //     <%}%>
        // <%}%>
        .uSysIdInt_dce_f_unit_id (<%=obj.DutInfo.DceIds%>),
        .uSysIdInt_dmi_f_unit_id (<%=obj.DutInfo.DmiIds%>),
        .uSysIdInt_dii_f_unit_id (<%=obj.DutInfo.DiiIds%>),
        .uSysIdInt_dve_f_unit_id (<%=obj.DutInfo.DveIds%>),
        .uSysIdInt_connected_dce_f_unit_id (<%=obj.BlockId%>_connectivity_if.AiuConnectedDceFunitId),
        .<%=obj.interfaces.uSysConnectedDceIdInt.name%>connectivity (<%=obj.BlockId%>_connectivity_if.AiuDce_connectivity_vec),
        .<%=obj.interfaces.uSysDceIdInt.name%>connectivity (<%=obj.BlockId%>_connectivity_if.AiuDce_connectivity_vec),
        .<%=obj.interfaces.uSysDmiIdInt.name%>connectivity (<%=obj.BlockId%>_connectivity_if.AiuDmi_connectivity_vec), 
        .<%=obj.interfaces.uSysDiiIdInt.name%>connectivity (<%=obj.BlockId%>_connectivity_if.AiuDii_connectivity_vec),
        .<%=obj.interfaces.apbInt.name%>paddr	(apb_if.paddr),	//nnm: connect
        .<%=obj.interfaces.apbInt.name%>psel	(apb_if.psel),		//nnm: connect
        .<%=obj.interfaces.apbInt.name%>penable	(apb_if.penable),		//nnm: connect
        .<%=obj.interfaces.apbInt.name%>pwrite	(apb_if.pwrite),		//nnm: connect
        .<%=obj.interfaces.apbInt.name%>pwdata	(apb_if.pwdata),	//nnm: connect
        .<%=obj.interfaces.apbInt.name%>pready	(apb_if.pready),		//nnm: connect
        .<%=obj.interfaces.apbInt.name%>prdata	(apb_if.prdata),		//nnm: connect
        .<%=obj.interfaces.apbInt.name%>pslverr	(apb_if.pslverr),		//nnm: connect
        <%  if(obj.interfaces.apbInt.params.wProt !== 0) { %>
            .<%=obj.interfaces.apbInt.name%>pprot (apb_if.pprot),
        <% } %>
        <%  if(obj.interfaces.apbInt.params.wStrb !== 0) { %>
            .<%=obj.interfaces.apbInt.name%>pstrb (apb_if.pstrb),
        <% } %>
        //Q-channel interface connection
        <%if(obj.DutInfo.usePma){%>
            .q_ACTIVE      ( m_q_chnl_if.QACTIVE ) ,
            .q_DENY        ( m_q_chnl_if.QDENY   ) ,
            .q_REQn        ( m_q_chnl_if.QREQn   ) ,
            .q_ACCEPTn     ( m_q_chnl_if.QACCEPTn) ,
        <%}%>
        //event interface connection
    <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %> 
            .<%=obj.interfaces.eventRequestInInt.name%>req	(m_event_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sender_master.req),
            .<%=obj.interfaces.eventRequestInInt.name%>ack	(m_event_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sender_master.ack),
    <% } %>
     
    <% if (obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false) { %>
            .<%=obj.interfaces.eventRequestOutInt.name%>req     (m_event_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_receiver_slave.req),
            .<%=obj.interfaces.eventRequestOutInt.name%>ack     (m_event_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_receiver_slave.ack),
    <% } %>        
       /* <%if((obj.fnNativeInterface == "ACE")){%>
            .<%=obj.interfaces.eventRequestOutInt.name%>req     (m_event_out_if_<%=obj.BlockId%>.in),
            .<%=obj.interfaces.eventRequestOutInt.name%>ack     (m_event_out_if_<%=obj.BlockId%>.out),
        <%}%>
        <%if((obj.fnNativeInterface == "ACE") || ((obj.fnNativeInterface == "ACELITE-E") && obj.interfaces.axiInt.params.eAc && !obj.interfaces.eventRequestInInt._SKIP_)){%>
            `ifdef FORCE_SENDER
            .<%=obj.interfaces.eventRequestInInt.name%>ack	(m_event_out_if_<%=obj.BlockId%>.sys_req_event_ack),
            .<%=obj.interfaces.eventRequestInInt.name%>req	(m_event_out_if_<%=obj.BlockId%>.sys_req_event_in),
            `else
            .<%=obj.interfaces.eventRequestInInt.name%>ack     (),
            .<%=obj.interfaces.eventRequestInInt.name%>req     (1'b0),
            `endif //FORCE_SENDER
        <%}%>*/
        <%if(obj.useResiliency){%>
            <%if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){%>
                .<%=obj.interfaces.checkClkInt.name%>clk      (dut_clk),
            <%}%>
            <% if (!obj.interfaces.bistDebugDisableInt._SKIP_) { %>
            .<%=obj.interfaces.bistDebugDisableInt.name%>pin     ('h1),
            <% } %>
            .bist_bist_next(1'b0),
            .bist_bist_next_ack(bist_bist_next_ack),
            .bist_domain_is_on(bist_domain_is_on),
            .fault_mission_fault(fault_mission_fault),
            .fault_latent_fault(fault_latent_fault),
            .fault_cerr_over_thres_fault(fault_cerr_over_thres_fault),
        <%}%>

        .irq_uc         (irq_uc),
        .irq_c          (irq_c ),
        <% if(obj.useResiliency) { %>
            <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication) { %>
                .<%=obj.interfaces.checkClkInt.name%>clk(dut_clk),
                <%if(obj.interfaces.checkClkInt.params.wTestEn){%>
                    .<%=obj.interfaces.checkClkInt.name%>test_en     ('h0),
                <%}%>
            <%}%>
        <%}%>
        <%if(obj.interfaces.clkInt.params.wTestEn){%>
            .<%=obj.interfaces.clkInt.name%>test_en              ( <%=obj.interfaces.clkInt.params.wTestEn%>'h0     ) ,
        <%}%>
         // PERF MON MASTER ENABLE
        .trigger_trigger(<%=obj.BlockId%>_sb_stall_if[0].master_cnt_enable), // FIXME : SAI MPU - Need to tie master_cnt_enables from all stall_if s together - Need to check
        
        .<%=obj.interfaces.clkInt.name%>clk                  ( dut_clk  ) ,
        .<%=obj.interfaces.clkInt.name%>reset_n              ( soft_rstn  )
    );
<%}%>  //Cannot find opening token for this - FIXME

    //DCTODO: Connect tx smi_msg_err to RTL when RTL supports the signal
    <%for(var i = 0; i < NSMIIFRX; i++){%>
       <%if(obj.interfaces.smiTxInt[i].params.nSmiDPvc){%>
       assign port<%=i%>_tx_smi_if.smi_msg_err  = 0;
       assign port<%=i%>_rx_smi_if.smi_msg_err  = 0;
       <%}else{%>
       assign port<%=i%>_rx_smi_if.smi_dp_ready = 0;
       assign port<%=i%>_rx_smi_if.smi_dp_valid = 0;   
       assign port<%=i%>_rx_smi_if.smi_msg_err  = 0;
       assign port<%=i%>_tx_smi_if.smi_dp_ready = 0;
       assign port<%=i%>_tx_smi_if.smi_dp_valid = 0;   
      //assign port<%=i%>_tx_smi_if.smi_msg_err  = 0;
      <%}%>
    <%}%>
    

    //Connectivity if to DUT connection
    assign <%=obj.BlockId%>_connectivity_if.clk       = dut_clk;
    assign <%=obj.BlockId%>_connectivity_if.rst_n     = soft_rstn;
    assign <%=obj.BlockId%>_connectivity_if.ott_busy  = |(tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.q_oc_val);
    assign <%=obj.BlockId%>_connectivity_if.ott_entries  = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.pmon_ott_entries[7:0];
    <% for (var i=0; i<obj.nDCEs; i++) {%>
    assign <%=obj.BlockId%>_connectivity_if.XAIUCCR<%=i%>_DCECounterState = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUCCR<%=i%>_DCECounterState_out[2:0];
    <%}%>
    <% for (var i=0; i<obj.nDMIs; i++) {%>
    assign <%=obj.BlockId%>_connectivity_if.XAIUCCR<%=i%>_DMICounterState = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUCCR<%=i%>_DMICounterState_out[2:0];
    <%}%>
    <% for (var i=0; i<obj.nDIIs; i++) {%>
    assign <%=obj.BlockId%>_connectivity_if.XAIUCCR<%=i%>_DIICounterState = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUCCR<%=i%>_DIICounterState_out[2:0];
    <%}%>
    ////////////////////////////////// ZIED CONNECT STALL_IF TO DUT////////////////////////////

    <%for(let i=0; i< obj.DutInfo.nNativeInterfacePorts; i++){%>
        assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].clk = dut_clk;
        assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].rst_n = soft_rstn;
        assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].trace_capture_busy = dut.ioaiu_core_wrapper.trace_capture_busy;
    <%}%>

    /////////////////////// PERF_CNT CONNECT DUT to LATENCY LATENCY_IF////////////////////////////////////////////////////
<% if(obj.testBench =="io_aiu"){ %>

<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>

    assign <%=obj.BlockId%>_sb_latency_if<%=i%>.clk              =   dut_clk;
    assign <%=obj.BlockId%>_sb_latency_if<%=i%>.rst_n            =   soft_rstn;
<% if (obj.DutInfo.nPerfCounters>0) {%>
    assign <%=obj.BlockId%>_sb_latency_if<%=i%>.div_clk_rtl      =   dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.u_ncr_pmon.latency_counter_table.divevt_clk;
    assign <%=obj.BlockId%>_sb_latency_if<%=i%>.dealloc_if       =   dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.u_ncr_pmon.latency_counter_in_dealloc;
    assign <%=obj.BlockId%>_sb_latency_if<%=i%>.dut_latency_bins =   dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.u_ncr_pmon.latency_bins;
    assign <%=obj.BlockId%>_sb_latency_if<%=i%>.alloc_if         =   dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.u_ncr_pmon.latency_counter_in_alloc;
    assign <%=obj.BlockId%>_sb_latency_if<%=i%>.local_count_enable =   dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.apb_csr.XAIUMCNTCR_LocalCountEnable_out;
<% } else {%>
    assign <%=obj.BlockId%>_sb_latency_if<%=i%>.div_clk_rtl      =   '0;
    assign <%=obj.BlockId%>_sb_latency_if<%=i%>.dealloc_if       =   '0;
    assign <%=obj.BlockId%>_sb_latency_if<%=i%>.dut_latency_bins =   '0;
    assign <%=obj.BlockId%>_sb_latency_if<%=i%>.alloc_if         =   '0;
<% }%>

    /////////////////////////////////// BW events //////////////////////////////////////////////////
    // generate_bandwidth_event  CmdReqWr    
    assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].cmd_req_wr_valid            =  dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_valid
                                                                           & ((dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_cm_type>=8'h10
                                                                              &dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_cm_type<=8'h25)
                                                                            | (dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_cm_type>=8'h29
                                                                              &dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_cm_type<=8'h2a));
    assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].cmd_req_wr_ready            =  dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_ready
                                                                           & ((dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_cm_type>=8'h10
                                                                              &dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_cm_type<=8'h25)
                                                                            | (dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_cm_type>=8'h29
                                                                              &dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_cm_type<=8'h2a));
    assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].cmd_req_wr_funit_id_if      = (dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_target_id >> WSMINCOREPORTID);
    assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].cmd_req_wr_user_bits_if     =  dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_aux;
    
    // generate_bandwidth_event "CmdReqRd"	
    assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].cmd_req_rd_valid            =  dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_valid
                                                                           & ((dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_cm_type<=8'h0b)
                                                                            | (dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_cm_type>=8'h26
                                                                              &dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_cm_type<=8'h28));
    assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].cmd_req_rd_ready            =  dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_ready
                                                                           & ((dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_cm_type<=8'h0b)
                                                                            | (dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_cm_type>=8'h26
                                                                              &dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_cm_type<=8'h28));
    assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].cmd_req_rd_funit_id_if      = (dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_target_id >> WSMINCOREPORTID);
    assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].cmd_req_rd_user_bits_if     =  dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.cmd_req_aux;
      
    // generate_bandwidth_event "SnpRsp"	
    assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].snp_rsp_valid               =  dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.snp_rsp_valid;
    assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].snp_rsp_ready               =  dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.snp_rsp_ready;
    assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].snp_rsp_funit_id_if         = (dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.snp_req_target_id >> WSMINCOREPORTID);
    assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].snp_rsp_user_bits_if        =  1'b0;
 
    <%}%>
    <%}%>

// SMI TX
    <%for(let j=0; j< obj.DutInfo.nNativeInterfacePorts; j++){%>
        <%for(var i = 0; i < NSMIIFRX; i++){%>
            <%if(obj.interfaces.smiTxInt[i].params.nSmiDPvc){%>  
                assign <%=obj.BlockId%>_sb_stall_if[<%=j%>].smi_tx<%=i%>_valid = dut.<%=obj.interfaces.smiTxInt[i].name %>dp_valid;       
                assign <%=obj.BlockId%>_sb_stall_if[<%=j%>].smi_tx<%=i%>_ready = dut.<%=obj.interfaces.smiTxInt[i].name %>dp_ready;    
            <%}else{%>
                assign <%=obj.BlockId%>_sb_stall_if[<%=j%>].smi_tx<%=i%>_valid = dut.<%=obj.interfaces.smiTxInt[i].name %>ndp_msg_valid;       
                assign <%=obj.BlockId%>_sb_stall_if[<%=j%>].smi_tx<%=i%>_ready = dut.<%=obj.interfaces.smiTxInt[i].name %>ndp_msg_ready;
            <%}%> 
        <%}%>
    <%}%>

    // SMI RX
    <%for (var i = 0; i < NSMIIFTX; i++){%>
        <%if(obj.interfaces.smiRxInt[i].params.nSmiDPvc){%>
            <%for(let j=0; j< obj.DutInfo.nNativeInterfacePorts; j++){%>
                assign <%=obj.BlockId%>_sb_stall_if[<%=j%>].smi_rx<%=i%>_valid = dut.<%=obj.interfaces.smiRxInt[i].name%>dp_valid;
                assign <%=obj.BlockId%>_sb_stall_if[<%=j%>].smi_rx<%=i%>_ready = dut.<%=obj.interfaces.smiRxInt[i].name%>dp_ready;
            <%}%>
            assign (supply0, supply1) dut.<%=obj.interfaces.smiRxInt[i].name %>dp_valid = port<%=i%>_tx_smi_if.force_smi_msg_valid;
            assign (supply0, supply1) dut.<%=obj.interfaces.smiRxInt[i].name %>dp_ready = port<%=i%>_tx_smi_if.force_smi_msg_ready;  
        <%}else{%>
            <%for(let j=0; j< obj.DutInfo.nNativeInterfacePorts; j++){%>
                assign <%=obj.BlockId%>_sb_stall_if[<%=j%>].smi_rx<%=i%>_valid = dut.<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_valid;
                assign <%=obj.BlockId%>_sb_stall_if[<%=j%>].smi_rx<%=i%>_ready = dut.<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_ready;
            <%}%>
            assign (supply0, supply1) dut.<%=obj.interfaces.smiRxInt[i].name %>ndp_msg_valid = port<%=i%>_tx_smi_if.force_smi_msg_valid;
            assign (supply0, supply1) dut.<%=obj.interfaces.smiRxInt[i].name %>ndp_msg_ready = port<%=i%>_tx_smi_if.force_smi_msg_ready;      
        <%}%>
    <%}%>
    <%if(obj.fnNativeInterface  == "ACELITE-E" || obj.fnNativeInterface == "ACE-LITE" || obj.fnNativeInterface  == "AXI4" || obj.fnNativeInterface  == "AXI5"){%>
        // AXI/ACE LITE 
        <%if(obj.DutInfo.nNativeInterfacePorts == 1){%>
            assign <%=obj.BlockId%>_sb_stall_if[0].axi_aw_valid = dut.<%=obj.interfaces.axiInt.name%>aw_valid;
            assign <%=obj.BlockId%>_sb_stall_if[0].axi_aw_ready = dut.<%=obj.interfaces.axiInt.name%>aw_ready;
            assign <%=obj.BlockId%>_sb_stall_if[0].axi_w_valid = dut.<%=obj.interfaces.axiInt.name%>w_valid;
            assign <%=obj.BlockId%>_sb_stall_if[0].axi_w_ready = dut.<%=obj.interfaces.axiInt.name%>w_ready;
            assign <%=obj.BlockId%>_sb_stall_if[0].axi_ar_valid = dut.<%=obj.interfaces.axiInt.name%>ar_valid;
            assign <%=obj.BlockId%>_sb_stall_if[0].axi_ar_ready = dut.<%=obj.interfaces.axiInt.name%>ar_ready;
            assign <%=obj.BlockId%>_sb_stall_if[0].axi_r_valid = dut.<%=obj.interfaces.axiInt.name%>r_valid;
            assign <%=obj.BlockId%>_sb_stall_if[0].axi_r_ready = dut.<%=obj.interfaces.axiInt.name%>r_ready;
            assign <%=obj.BlockId%>_sb_stall_if[0].axi_b_valid = dut.<%=obj.interfaces.axiInt.name%>b_valid;
            assign <%=obj.BlockId%>_sb_stall_if[0].axi_b_ready = dut.<%=obj.interfaces.axiInt.name%>b_ready;
        <%}else{%>
            <%for(let i=0; i< obj.DutInfo.nNativeInterfacePorts; i++){%>
                assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].axi_aw_valid = dut.<%=obj.interfaces.axiInt[i].name%>aw_valid;
                assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].axi_aw_ready = dut.<%=obj.interfaces.axiInt[i].name%>aw_ready;
                assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].axi_w_valid  = dut.<%=obj.interfaces.axiInt[i].name%>w_valid;
                assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].axi_w_ready  = dut.<%=obj.interfaces.axiInt[i].name%>w_ready;
                assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].axi_ar_valid = dut.<%=obj.interfaces.axiInt[i].name%>ar_valid;
                assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].axi_ar_ready = dut.<%=obj.interfaces.axiInt[i].name%>ar_ready;
                assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].axi_r_valid  = dut.<%=obj.interfaces.axiInt[i].name%>r_valid;
                assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].axi_r_ready  = dut.<%=obj.interfaces.axiInt[i].name%>r_ready;
                assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].axi_b_valid  = dut.<%=obj.interfaces.axiInt[i].name%>b_valid;
                assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].axi_b_ready  = dut.<%=obj.interfaces.axiInt[i].name%>b_ready;
            <%}%>
        <%}%>
    <%}%>
    // ACE
    <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>
            assign <%=obj.BlockId%>_sb_stall_if[0].ace_aw_valid = dut.<%=obj.interfaces.axiInt.name%>aw_valid;
            assign <%=obj.BlockId%>_sb_stall_if[0].ace_aw_ready = dut.<%=obj.interfaces.axiInt.name%>aw_ready;
            assign <%=obj.BlockId%>_sb_stall_if[0].ace_w_valid  = dut.<%=obj.interfaces.axiInt.name%>w_valid;
            assign <%=obj.BlockId%>_sb_stall_if[0].ace_w_ready  = dut.<%=obj.interfaces.axiInt.name%>w_ready;
            assign <%=obj.BlockId%>_sb_stall_if[0].ace_ar_valid = dut.<%=obj.interfaces.axiInt.name%>ar_valid;
            assign <%=obj.BlockId%>_sb_stall_if[0].ace_ar_ready = dut.<%=obj.interfaces.axiInt.name%>ar_ready;
            assign <%=obj.BlockId%>_sb_stall_if[0].ace_r_valid  = dut.<%=obj.interfaces.axiInt.name%>r_valid;
            assign <%=obj.BlockId%>_sb_stall_if[0].ace_r_ready  = dut.<%=obj.interfaces.axiInt.name%>r_ready;
            assign <%=obj.BlockId%>_sb_stall_if[0].ace_b_valid  = dut.<%=obj.interfaces.axiInt.name%>b_valid;
            assign <%=obj.BlockId%>_sb_stall_if[0].ace_b_ready  = dut.<%=obj.interfaces.axiInt.name%>b_ready;
            assign <%=obj.BlockId%>_sb_stall_if[0].ace_ac_valid = dut.<%=obj.interfaces.axiInt.name%>ac_valid;
            assign <%=obj.BlockId%>_sb_stall_if[0].ace_ac_ready = dut.<%=obj.interfaces.axiInt.name%>ac_ready;
            assign <%=obj.BlockId%>_sb_stall_if[0].ace_cd_valid = dut.<%=obj.interfaces.axiInt.name%>cd_valid;
            assign <%=obj.BlockId%>_sb_stall_if[0].ace_cd_ready = dut.<%=obj.interfaces.axiInt.name%>cd_ready;
            assign <%=obj.BlockId%>_sb_stall_if[0].ace_cr_valid = dut.<%=obj.interfaces.axiInt.name%>cr_valid;
            assign <%=obj.BlockId%>_sb_stall_if[0].ace_cr_ready = dut.<%=obj.interfaces.axiInt.name%>cr_ready;
        /////FORCE CR CHANNEL FOR PERFMON////////////////////
            assign (supply0, supply1) dut.ioaiu_core_wrapper.ioaiu_core0.cr_ready  = ace_if[0].force_crready;  
            assign (supply0, supply1) dut.<%=obj.interfaces.axiInt.name%>cr_valid  = ace_if[0].force_crvalid;
    <%}%>

 //	plusarg "+smi_idle_drive_rnd":"1" does the job of "force_smi_rx" :null  CONC-12911,CONC-13477	
 //   <%for (var i = 0; i < obj.interfaces.smiRxInt.length; i++) { %>
 //       initial 
 //       begin
 //         if ($test$plusargs("force_smi_rx")) begin
 //           force tb_top.dut.<%=obj.interfaces.smiRxInt[i].name%>ndp_ndp_len     = 0;
 //           force tb_top.dut.<%=obj.interfaces.smiRxInt[i].name%>ndp_dp_present  = 0;
 //           force tb_top.dut.<%=obj.interfaces.smiRxInt[i].name%>ndp_targ_id     = 0;    
 //           force tb_top.dut.<%=obj.interfaces.smiRxInt[i].name%>ndp_src_id      = 0;     
 //           force tb_top.dut.<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_id      = 0;     
 //           force tb_top.dut.<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_type    = 0;       
 //           <% if(obj.interfaces.smiRxInt[i].params.wSmiUser >0) {%>      
 //           force tb_top.dut.<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_user    = 0;
 //           <% } %>    
 //           <% if(obj.interfaces.smiRxInt[i].params.wSmiTier >0) {%>
 //           force tb_top.dut.<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_tier    = 0;          
 //           <% } %>
 //           <% if(obj.interfaces.smiRxInt[i].params.wSmiSteer >0) {%>
 //           force tb_top.dut.<%=obj.interfaces.smiRxInt[i].name%>ndp_steer       = 0;      
 //           <% } %>
 //           <% if(obj.interfaces.smiRxInt[i].params.wSmiPri >0) {%>
 //           force tb_top.dut.<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_pri     = 0;      
 //           <% } %>
 //           <% if(obj.interfaces.smiRxInt[i].params.wSmiMsgQos >0) {%>
 //           force tb_top.dut.<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_qos     = 0;  
 //           <% } %>
 //           force tb_top.dut.<%=obj.interfaces.smiRxInt[i].name%>ndp_ndp         = 0; 
 //           <% if(obj.interfaces.smiRxInt[i].params.wSmiErr >0) {%>
 //           force tb_top.dut.<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_err     = 0;      
 //           <% } %>
 //         end
 //       end
 //   	<%}%>
        /////////////////// END PERF_CNT STALL_IF ////////////////////////////////////////////////////
    <%for(let j=0; j< obj.DutInfo.nNativeInterfacePorts; j++){%>
        <%for (var i = 0; i < obj.DutInfo.nPerfCounters; i++){%>
            assign <%=obj.BlockId%>_sb_stall_if[<%=j%>].cnt_reg_capture[<%=i%>].cnt_v     =  dut.ioaiu_core_wrapper.ioaiu_core<%=j%>.apb_csr.XAIUCNTVR<%=i%>_CountVal_out ;  
            assign <%=obj.BlockId%>_sb_stall_if[<%=j%>].cnt_reg_capture[<%=i%>].cnt_v_str =  dut.ioaiu_core_wrapper.ioaiu_core<%=j%>.apb_csr.XAIUCNTSR<%=i%>_CountSatVal_out;   
        <%}%>
    <%}%>
    
	<%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface  == "AXI5") && obj.DutInfo.useCache == 1)){%>
        assign m_event_out_if_<%=obj.BlockId%>.event_receiver_enable    = ~tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUTCR_EventDisable_out;
        assign m_event_out_if_<%=obj.BlockId%>.timeout_threshold 		= tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUTOCR_TimeOutThreshold_out[30:0];
    	assign m_event_out_if_<%=obj.BlockId%>.uedr_timeout_err_det_en 	= tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUUEDR_TimeoutErrDetEn_out;
    	assign m_event_out_if_<%=obj.BlockId%>.uesr_errvld 				= tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.XAIUUESR_ErrVld_out;
    	assign m_event_out_if_<%=obj.BlockId%>.uesr_err_type 			= tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUUESR_ErrType_out[3:0];
    	assign m_event_out_if_<%=obj.BlockId%>.uesr_err_info 			= tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUUESR_ErrInfo_out[15:0];
    	assign m_event_out_if_<%=obj.BlockId%>.ueir_timeout_irq_en 		= tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUUEIR_TimeoutErrIntEn_out;
    	assign m_event_out_if_<%=obj.BlockId%>.IRQ_UC 					= tb_top.dut.irq_uc;
        assign m_event_out_if_<%=obj.BlockId%>.sysco_attach             = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUTCR_SysCoAttach_out;
        assign m_event_out_if_<%=obj.BlockId%>.idle_or_done             = tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.u_sys_evt_coh_concerto.u_sys_evt_coh_wrapper.u_sys_evt_receiver.next_state_is_IDLE_or_DONE;
	<%}%>

         <%for(let i=0; i< obj.DutInfo.nNativeInterfacePorts; i+=1) {%>
         <%if(obj.DutInfo.useCache){%>
         assign u_csr_probe_if[<%=i%>].CCPReady = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.init_done; // CCP ready, indicating that Tag and Data Memory are initialized
         <%}%>
         <%}%>
 

       <%for(let i=0; i< obj.DutInfo.nNativeInterfacePorts; i+=1) {%>

        <%if((obj.testBench =="io_aiu") && (obj.useResiliency)){%>
        assign u_csr_probe_if[<%=i%>].transport_det_en  = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.apb_csr.XAIUUEDR_TransErrDetEn_out;
        assign u_csr_probe_if[<%=i%>].time_out_det_en   = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.apb_csr.XAIUUEDR_TimeoutErrDetEn_out;
        assign u_csr_probe_if[<%=i%>].prot_err_det_en   = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.apb_csr.XAIUUEDR_ProtErrDetEn_out;
        assign u_csr_probe_if[<%=i%>].mem_err_det_en    = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.apb_csr.XAIUUEDR_MemErrDetEn_out;
        <%}%>

        <%if(obj.DutInfo.orderedWriteObservation == true){%>
    	assign u_csr_probe_if[<%=i%>].snp_req_vld = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_snp_req_valid & tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.n_snp_req_ready;
        assign u_csr_probe_if[<%=i%>].snp_req_addr = {tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_snp_req_security, tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_snp_req_addr};
        assign u_csr_probe_if[<%=i%>].snp_req_match = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.snp_req_match[<%=obj.DutInfo.cmpInfo.nOttCtrlEntries%>-1:0];
        assign u_csr_probe_if[<%=i%>].ott_owned_st = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.q_oc_owned[<%=obj.DutInfo.cmpInfo.nOttCtrlEntries%>-1:0];
        assign u_csr_probe_if[<%=i%>].ott_oldest_st = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.q_oc_oldest[<%=obj.DutInfo.cmpInfo.nOttCtrlEntries%>-1:0];
    	<%}%>
    	assign u_csr_probe_if[<%=i%>].ott_entries  = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.q_oc_val[<%=obj.DutInfo.cmpInfo.nOttCtrlEntries%>-1:0];
        assign u_csr_probe_if[<%=i%>].TransActv = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.t_pma_busy;
    	assign u_csr_probe_if[<%=i%>].ott_security = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.q_oc_security[<%=obj.DutInfo.cmpInfo.nOttCtrlEntries%>-1:0];
    	assign u_csr_probe_if[<%=i%>].ott_prot = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.q_oc_pr[<%=obj.DutInfo.cmpInfo.nOttCtrlEntries%>-1:0];
    <%for(var j = 0; j < obj.DutInfo.cmpInfo.nOttCtrlEntries; j++){%>
    	assign u_csr_probe_if[<%=i%>].ott_address[<%=j%>]                               = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.q_oc_addr[<%=j%>];
    	assign u_csr_probe_if[<%=i%>].ott_id[<%=j%>]                                    = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.q_oc_id[<%=j%>];
	assign u_csr_probe_if[<%=i%>].ott_user[<%=j%>]          			= tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.q_oc_user[<%=j%>];
	assign u_csr_probe_if[<%=i%>].ott_write[<%=j%>]          			= tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.q_oc_write[<%=j%>];
	assign u_csr_probe_if[<%=i%>].ott_evict[<%=j%>]          			= tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.t_oc_evict[<%=j%>];
	assign u_csr_probe_if[<%=i%>].ott_qos[<%=j%>]          			= tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.q_oc_qos[<%=j%>];
        assign u_csr_probe_if[<%=i%>].ott_cache[<%=j%>]          			= tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.q_oc_cache[<%=j%>];
    <%}%>
   

    	<%if(obj.assertOn){%>
        	<%if((obj.DutInfo.cmpInfo.OttErrorType === "SECDED" || obj.DutInfo.cmpInfo.OttErrorType === "PARITY")) {%>
    		assign u_csr_probe_if[<%=i%>].oc_id = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.q_oc_id;
    		assign u_csr_probe_if[<%=i%>].oc_addr = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.q_oc_addr;
    		assign u_csr_probe_if[<%=i%>].oc_dptr = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.q_oc_dptr;
    		<%}%>
    	<%}%>

       <%if(obj.assertOn){%>
        <%if(obj.useCache){%>
            <%if(obj.DutInfo.ccpParams.TagErrInfo === "SECDED" || obj.DutInfo.ccpParams.DataErrInfo === "SECDED" || (obj.DutInfo.cmpInfo.OttErrorType === "SECDED") || obj.DutInfo.ccpParams.TagErrInfo === "PARITYENTRY" || obj.DutInfo.ccpParams.DataErrInfo === "PARITYENTRY" || (obj.DutInfo.cmpInfo.OttErrorType === "PARITY")){%>
                assign  u_csr_probe_if[<%=i%>].cesr_errvld = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.XAIUCESR_ErrVld_out;
                assign  u_csr_probe_if[<%=i%>].cesar_errvld_en = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.XAIUCESR_ErrVld_wr;
                assign  u_csr_probe_if[<%=i%>].cesar_errvld = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.XAIUCESR_ErrVld_in;
                assign  u_csr_probe_if[<%=i%>].cesr_err_cnt = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.XAIUCECR_ErrDetEn_out & tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.cerrs_o[0];
                assign  u_csr_probe_if[<%=i%>].uesr_errvld = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.XAIUUESR_ErrVld_out;
                assign  u_csr_probe_if[<%=i%>].uesar_errvld_en = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.XAIUUESR_ErrVld_wr;
                assign  u_csr_probe_if[<%=i%>].uesar_errvld = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.XAIUUESR_ErrVld_in;
                assign  u_csr_probe_if[<%=i%>].uesr_err_cnt = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.XAIUUEDR_MemErrDetEn_out & tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.uerrs_o[0];
                assign  u_csr_probe_if[<%=i%>].uncorr_mem_det_en = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.XAIUUEDR_MemErrDetEn_out;

                always @(posedge dut_clk) begin
                    if( u_csr_probe_if[<%=i%>].uncorr_mem_det_en === 1 &&  u_csr_probe_if[<%=i%>].uesr_errvld === 1)
                         u_csr_probe_if[<%=i%>].uncorr_err_injected = 1;
                end

                property assert_corrErrInjWhileSoftwareWriteHappens_c<%=i%>;                                                
                    @(posedge  u_csr_probe_if[<%=i%>].clk) disable iff (~ u_csr_probe_if[<%=i%>].resetn) ((!u_csr_probe_if[<%=i%>].cesr_errvld &  u_csr_probe_if[<%=i%>].cesar_errvld_en & ! u_csr_probe_if[<%=i%>].cesar_errvld & u_csr_probe_if[<%=i%>].cesr_err_cnt) |=> ! u_csr_probe_if[<%=i%>].cesr_errvld); 
                endproperty

                property assert_uncorrErrInjWhileSoftwareWriteHappens_c<%=i%>;                                                
                    @(posedge  u_csr_probe_if[<%=i%>].clk) disable iff (~ u_csr_probe_if[<%=i%>].resetn) ((!u_csr_probe_if[<%=i%>].uesr_errvld &  u_csr_probe_if[<%=i%>].uesar_errvld_en & ! u_csr_probe_if[<%=i%>].uesar_errvld &  u_csr_probe_if[<%=i%>].uesr_err_cnt) |=> ! u_csr_probe_if[<%=i%>].uesr_errvld); 
                endproperty
                
                assertcorrErrInjWhileSoftwareWriteHappens_c<%=i%> : assert property (assert_corrErrInjWhileSoftwareWriteHappens_c<%=i%>) else 
                                                            `uvm_error("IO-AIU_PROBE_IF",$sformatf(" UCESR_ErrVld bit not cleared  "));

                assertuncorrErrInjWhileSoftwareWriteHappens_c<%=i%> : assert property (assert_uncorrErrInjWhileSoftwareWriteHappens_c<%=i%>) else 
                                                            `uvm_error("IOAIU_PROBE_IF",$sformatf(" CAIUUESR_ErrVld bit not cleared  "));
            <%}%>
        <%}%>
    <%}%>
                
    <%}%>
`ifdef USE_VIP_SNPS
  <%if(obj.testBench == "io_aiu" && obj.DutInfo.nNativeInterfacePorts == 1 && obj.interfaces.axiInt.params.checkType == 'ODD_PARITY_BYTE_ALL') { %>
      check_en_low_testing chk_en_low_test(dut_clk,soft_rstn); 
 <%}%>
`endif
    <%if((obj.useResiliency) || (obj.testBench == "io_aiu")){%>
        placeholder_connectivity_checker placeholder_connec_chk(dut_clk, soft_rstn);
    <%if(obj.useResiliency){%>
        fault_injector_checker fault_inj_check(dut_clk, soft_rstn);
        initial begin
<% if(obj.testBench == 'io_aiu') { %>
`ifndef VCS
            uvm_config_db#(event)::set(.cntxt(null),
                                  .inst_name( "*" ),
                                  .field_name( "kill_test" ),
                                  .value(placeholder_connec_chk.kill_test));

            uvm_config_db#(event)::set(.cntxt(null),
                                  .inst_name( "*" ),
                                  .field_name( "raise_obj_for_resiliency_test" ),
                                  .value(fault_inj_check.raise_obj_for_resiliency_test));

            uvm_config_db#(event)::set(.cntxt(null),
                                  .inst_name( "*" ),
                                  .field_name( "drop_obj_for_resiliency_test" ),
                                  .value(fault_inj_check.drop_obj_for_resiliency_test));
`else // `ifndef VCS
    placeholder_connec_chk.kill_test = new("kill_test");
    fault_inj_check.raise_obj_for_resiliency_test = new("raise_obj_for_resiliency_test");
    fault_inj_check.drop_obj_for_resiliency_test = new("drop_obj_for_resiliency_test");
            uvm_config_db#(uvm_event)::set(.cntxt(null),
                                  .inst_name( "*" ),
                                  .field_name( "kill_test" ),
                                  .value(placeholder_connec_chk.kill_test));

            uvm_config_db#(uvm_event)::set(.cntxt(null),
                                  .inst_name( "*" ),
                                  .field_name( "raise_obj_for_resiliency_test" ),
                                  .value(fault_inj_check.raise_obj_for_resiliency_test));

            uvm_config_db#(uvm_event)::set(.cntxt(null),
                                  .inst_name( "*" ),
                                  .field_name( "drop_obj_for_resiliency_test" ),
                                  .value(fault_inj_check.drop_obj_for_resiliency_test));
`endif // `ifndef VCS ... `else ... 
<% } else {%>
            uvm_config_db#(event)::set(.cntxt(null),
                                  .inst_name( "*" ),
                                  .field_name( "kill_test" ),
                                  .value(placeholder_connec_chk.kill_test));

            uvm_config_db#(event)::set(.cntxt(null),
                                  .inst_name( "*" ),
                                  .field_name( "raise_obj_for_resiliency_test" ),
                                  .value(fault_inj_check.raise_obj_for_resiliency_test));

            uvm_config_db#(event)::set(.cntxt(null),
                                  .inst_name( "*" ),
                                  .field_name( "drop_obj_for_resiliency_test" ),
                                  .value(fault_inj_check.drop_obj_for_resiliency_test));
<% } %>
            if($test$plusargs("test_unit_duplication")) begin
                `uvm_info("test_unit_duplication","Disabling the assertion from {tb_top.ace_if} for resiliency_unitduplication testing",UVM_DEBUG)
                $assertoff(0, ace_if[0]);
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                `ifdef ASSERT_ON2
                    $assertoff(0, ace_if[0].m_ace_arm_sva);
                `endif
<%}else if (obj.fnNativeInterface == "ACE-LITE" ) { %>
                `ifdef ASSERT_ON2
                    $assertoff(0, ace_if[0].m_acelite_arm_sva);
                `endif
<%}%>
            end
          end
    <%}%>
    <%}%>

      initial begin
       string k_csr_seq = "";
      if (! $value$plusargs("k_csr_seq=%s", k_csr_seq)) begin
           k_csr_seq = "";
      end
      if($test$plusargs("wt_illegal_op_addr") || $test$plusargs("dvm_snp_rsp_error_test")  || k_csr_seq ==="ioaiu_csr_uuecr_sw_write_seq" || $test$plusargs("fault_inject_nocheck_demote")) begin
                `uvm_info("ioaiu_csr_no_address_hit_seq","Disabling the assertion from {tb_top.ace_if} for ioaiu_csr_no_address_hit_seq testing",UVM_DEBUG)
                $assertoff(0, ace_if[0]);
               <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                `ifdef ASSERT_ON2
                    $assertoff(0, ace_if[0].m_ace_arm_sva);
                `endif
<%}else if (obj.fnNativeInterface == "ACE-LITE" ) { %>
                `ifdef ASSERT_ON2
                    $assertoff(0, ace_if[0].m_acelite_arm_sva);
                `endif
<%}%>

            end
      end

	initial begin
      if($test$plusargs("wrong_cmdrsp_target_id") || $test$plusargs( "wrong_dtrreq_target_id") || $test$plusargs( "wrong_dtwrsp_target_id" ) || $test$plusargs( "wrong_strreq_target_id") || $test$plusargs("wrong_sysrsp_target_id") || $test$plusargs("wrong_dtrrsp_target_id") || $test$plusargs("wrong_updrsp_target_id") ||  $test$plusargs("wrong_snpreq_target_id") || $test$plusargs("wrong_sysreq_target_id") || $test$plusargs("inject_smi_uncorr_error")|| $test$plusargs("expect_mission_fault")) begin
          `uvm_info("wrong_target_id","Disabling the assertion from {tb_top.ace_if} for wrong_target_id testing",UVM_NONE)
          $assertoff(0, ace_if[0]);
<% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
	  `ifdef ASSERT_ON2
    	  $assertoff(0, ace_if[0].m_ace_arm_sva);
      `endif
<%}%>
      end
      end

    //-----------------------------------------------------------------------------
    // Generate clocks and reset
    //-----------------------------------------------------------------------------
    clk_rst_gen cr_gen(.clk_fr(fr_clk), .clk_tb(tb_clk), .rst(tb_rstn)); 

    <%if(obj.DutInfo.useCache){%>
        //Free Running Counter to mimic Eviction Counter in IO Cache.
        always @ (posedge dut_clk or negedge soft_rstn) begin
            if(~soft_rstn) begin
                nru_counter <= '0;
            end else begin
                if(nru_counter<(NO_OF_WAYS-1)) 
                    nru_counter <= nru_counter+1'b1;
                else 
                nru_counter <= '0;
            end
        end

        //CTRL channel
		<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            // Capture cache stall event to perf counter scorebord
            //FILL Data
            assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].cache_fill_valid          = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_data_valid             ;
            assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].cache_fill_ready          = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_fill_data_ready            ;

            //WR Data Channel
            assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].cache_write_valid         = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_wr_valid                    ;
            assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].cache_write_ready         = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_wr_ready                   ;

            //Read response Channel
            assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].cache_read_ready          = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_rdrsp_ready                ;
            assign <%=obj.BlockId%>_sb_stall_if[<%=i%>].cache_read_valid          = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_rdrsp_valid                ;


            assign u_ccp_if[<%=i%>].core_id = <%=i%>;
            assign u_ccp_if[<%=i%>].nru_counter          = nru_counter;
            assign u_ccp_if[<%=i%>].ctrlop_vld           = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_valid_p0                 ;
            assign u_ccp_if[<%=i%>].ctrlop_addr          = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_address_p0               ;
            <%if(obj.wSecurityAttribute > 0){%>
                assign u_ccp_if[<%=i%>].ctrlop_security      = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_security_p0              ;
            <%}else{%>
                assign u_ccp_if[<%=i%>].ctrlop_security      = 0              ;
            <%}%>

            assign u_ccp_if[<%=i%>].ctrlop_allocate      = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_allocate_p2              ;
            assign u_ccp_if[<%=i%>].ctrlop_rd_data       = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_read_data_p2             ;
            assign u_ccp_if[<%=i%>].ctrlop_wr_data       = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_write_data_p2            ;
            assign u_ccp_if[<%=i%>].ctrlop_port_sel      = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_port_sel_p2              ;
            assign u_ccp_if[<%=i%>].ctrlop_bypass        = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_bypass_p2                ;
            assign u_ccp_if[<%=i%>].ctrlop_rp_update     = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_rp_update_p2             ;
            assign u_ccp_if[<%=i%>].ctrlop_tagstateup    = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_tag_state_update_p2      ;
            assign u_ccp_if[<%=i%>].ctrlop_state         = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_state_p2                 ;
            assign u_ccp_if[<%=i%>].ctrlop_burstln       = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_burst_len_p2             ;
            assign u_ccp_if[<%=i%>].ctrlop_burstwrap     = 0                                            ;
            assign u_ccp_if[<%=i%>].ctrlop_setway_debug  = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_setway_debug_p2          ;
            assign u_ccp_if[<%=i%>].ctrlop_waybusy_vec   = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_ways_busy_vec_p2         ;
            assign u_ccp_if[<%=i%>].ctrlop_waystale_vec  = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_op_ways_stale_vec_p2        ;
            assign u_ccp_if[<%=i%>].ctrlop_cancel        = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.t_c2_cancel;
            assign u_ccp_if[<%=i%>].t_pt_err             = tb_top.dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.t_pt_err;;
            assign u_ccp_if[<%=i%>].ctrlop_lookup_p2     = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.t_c2_lookup;
            assign u_ccp_if[<%=i%>].ctrlop_pt_id_p2      = (u_ccp_if[<%=i%>].isWrite_Wakeup || u_ccp_if[<%=i%>].isRead_Wakeup || u_ccp_if[<%=i%>].isWrite || u_ccp_if[<%=i%>].isRead) ? dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_id : 
                        {dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.t_st_iid[dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_kid],dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.t_st_mid[dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_kid]}; 
            assign u_ccp_if[<%=i%>].cacheop_rdy          = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_op_ready_p0                ;
            assign u_ccp_if[<%=i%>].cache_vld            = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_valid_p2                   ;
            assign u_ccp_if[<%=i%>].out_req_valid_p2     = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_valid_p2                   ;
            assign u_ccp_if[<%=i%>].cache_currentstate   = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_current_state_p2           ;
            assign u_ccp_if[<%=i%>].cache_set_index      = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_set_index_p2              ;
			
			<%if ((obj.DutInfo.ccpParams.RepPolicy != "RANDOM") && (obj.DutInfo.ccpParams.nWays>1)) {%>
            	assign u_ccp_if[<%=i%>].cache_current_nru_vec = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_current_nru_vec_p2           ;
            <%}%>

            assign u_ccp_if[<%=i%>].cache_alloc_wayn     = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_alloc_way_vec_p2                 ;
            assign u_ccp_if[<%=i%>].cache_hit_wayn       = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_hit_way_vec_p2            ;

            assign u_ccp_if[<%=i%>].cachectrl_evict_vld  = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_evict_valid_p2             ;
            assign u_ccp_if[<%=i%>].cache_evict_addr     = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_evict_address_p2           ;

            <%if(obj.wSecurityAttribute > 0){%>
                assign u_ccp_if[<%=i%>].cache_evict_security = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_evict_security_p2          ;
            <%}else{%>
                assign u_ccp_if[<%=i%>].cache_evict_security = 0          ;
            <%}%>
            assign u_ccp_if[<%=i%>].cache_evict_state    = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_evict_state_p2             ;
            assign u_ccp_if[<%=i%>].cache_nack_uce       = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_nack_uce_p2                ;
            assign u_ccp_if[<%=i%>].cache_nack           = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_nack_p2                    ;
            assign u_ccp_if[<%=i%>].cache_nack_ce        = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_nack_ce_p2                 ;
            assign u_ccp_if[<%=i%>].cache_nack_noalloc   = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_nack_no_allocate_p2        ;
        <%}%>
        //Fill CTRL Channel
        always @(posedge dut_clk or negedge soft_rstn) begin
            if (~soft_rstn) begin
                addr_flop           <= '0;
                wayn_flop           <= '0;
                <%if(obj.wSecurityAttribute > 0){%>
                    security_flop   <= '0;
                <%}%>
                state_flop          <= <%=obj.BlockId + '_ccp_agent_pkg'%>::IX;
                ctrl_fill_vld_flop  <= '0;
                cache_fill_rdy_flop <= '0;
            end else begin
                addr_flop           <= dut.ioaiu_core_wrapper.ioaiu_core0.ccp_top.ctrl_fill_address;
                <%if(obj.DutInfo.ccpParams.nWays>1){%>
                    wayn_flop       <= dut.ioaiu_core_wrapper.ioaiu_core0.ccp_top.ctrl_fill_way_num;
                <%}%>
                <%if(obj.wSecurityAttribute > 0){%>
                    security_flop   <= dut.ioaiu_core_wrapper.ioaiu_core0.ccp_top.ctrl_fill_security;
                <%}%>
                state_flop          <= dut.ioaiu_core_wrapper.ioaiu_core0.ccp_top.ctrl_fill_state;
                ctrl_fill_vld_flop  <= dut.ioaiu_core_wrapper.ioaiu_core0.ccp_top.ctrl_fill_valid;
                cache_fill_rdy_flop <= dut.ioaiu_core_wrapper.ioaiu_core0.ccp_top.cache_fill_ready;
            end
        end
		<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            assign u_ccp_if[<%=i%>].ctrl_fill_vld        = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_valid;
            assign u_ccp_if[<%=i%>].cache_fill_rdy       = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_fill_ready;
            assign u_ccp_if[<%=i%>].ctrl_fill_addr       = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_address;

            <%if(obj.DutInfo.ccpParams.nWays>1){%>
                assign u_ccp_if[<%=i%>].ctrl_fill_wayn       = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_way_num;
            <%}else{%>
                assign u_ccp_if[<%=i%>].ctrl_fill_wayn    = 0;
            <%}%>

            assign u_ccp_if[<%=i%>].ctrl_fill_state      = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_state;
            <%if(obj.wSecurityAttribute > 0){%>
                assign u_ccp_if[<%=i%>].ctrl_fill_security   = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_security;
            <%}else{%>
                assign u_ccp_if[<%=i%>].ctrl_fill_security   = 0               ;
            <%}%>
            //Fill Data Channel
            assign u_ccp_if[<%=i%>].ctrl_filldata_vld    = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_data_valid             ;
            assign u_ccp_if[<%=i%>].ctrl_filldata_scratchpad = 0             ;
            assign u_ccp_if[<%=i%>].ctrl_fill_data       = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_data                   ;
            assign u_ccp_if[<%=i%>].ctrl_filldata_id     = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_data_id                ;
            assign u_ccp_if[<%=i%>].ctrl_filldata_last   = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_data_last              ;

            assign u_ccp_if[<%=i%>].ctrl_filldata_byten  = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_data_byteen            ;
            assign u_ccp_if[<%=i%>].ctrl_filldata_addr   = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_data_address           ;

            <%if(obj.DutInfo.ccpParams.nWays>1){%>
                assign u_ccp_if[<%=i%>].ctrl_filldata_wayn   = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_data_way_num           ;
            <%}else{%>
                assign u_ccp_if[<%=i%>].ctrl_filldata_wayn   = 0;
            <%}%>
            assign u_ccp_if[<%=i%>].ctrl_filldata_beatn  = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_data_beat_num          ;
            assign u_ccp_if[<%=i%>].cache_filldata_rdy   = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_fill_data_ready            ;
            assign u_ccp_if[<%=i%>].cache_fill_done      = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_fill_done;
            assign u_ccp_if[<%=i%>].cache_fill_done_id   = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_fill_done_id;
            //CONC-15425::CONC-15710 - Fill Interface udpdate: Adding Fill data full signal to the Fill Data Interafce
            assign u_ccp_if[<%=i%>].ctrl_filldata_full   = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_fill_data_full    	    ;

            //WR Data Channel
            assign u_ccp_if[<%=i%>].ctrl_wr_vld          = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_wr_valid                    ;
            assign u_ccp_if[<%=i%>].ctrl_wr_data         = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_wr_data                     ;
            assign u_ccp_if[<%=i%>].ctrl_wr_byte_en      = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_wr_byte_en                  ;
            assign u_ccp_if[<%=i%>].ctrl_wr_beat_num     = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_wr_beat_num                 ;
            assign u_ccp_if[<%=i%>].ctrl_wr_last         = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.ctrl_wr_last                     ;
            assign u_ccp_if[<%=i%>].cache_wr_rdy         = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_wr_ready                   ;

            //Evict Channel
            assign u_ccp_if[<%=i%>].cache_evict_rdy      = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_evict_ready                ;
            assign u_ccp_if[<%=i%>].cache_evict_vld      = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_evict_valid                ;
            assign u_ccp_if[<%=i%>].cache_evict_data     = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_evict_data                 ;
            assign u_ccp_if[<%=i%>].cache_evict_byten    = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_evict_byteen               ;
            assign u_ccp_if[<%=i%>].cache_evict_last     = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_evict_last                 ;
            assign u_ccp_if[<%=i%>].cache_evict_cancel   = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_evict_cancel               ;

            //Read response Channel
            assign u_ccp_if[<%=i%>].cache_rdrsp_rdy      = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_rdrsp_ready                ;
            assign u_ccp_if[<%=i%>].cache_rdrsp_vld      = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_rdrsp_valid                ;
            assign u_ccp_if[<%=i%>].cache_rdrsp_data     = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_rdrsp_data                 ;
            assign u_ccp_if[<%=i%>].cache_rdrsp_byten    = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_rdrsp_byteen               ;
            assign u_ccp_if[<%=i%>].cache_rdrsp_last     = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_rdrsp_last                 ;
            assign u_ccp_if[<%=i%>].cache_rdrsp_cancel   = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.cache_rdrsp_cancel               ;

            //Mnt Channel
            assign u_ccp_if[<%=i%>].maint_req_opcode     = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.maint_req_opcode                 ;
            assign u_ccp_if[<%=i%>].maint_req_data       = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.maint_req_data                   ;
            assign u_ccp_if[<%=i%>].maint_req_way        = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.maint_req_way                    ;
            assign u_ccp_if[<%=i%>].maint_req_entry      = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.maint_req_entry                  ;
            assign u_ccp_if[<%=i%>].maint_req_word       = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.maint_req_word                   ;
            assign u_ccp_if[<%=i%>].maint_req_array_sel  = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.maint_req_array_sel              ;

            assign u_ccp_if[<%=i%>].maint_active         = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.maint_active                     ;
            assign u_ccp_if[<%=i%>].maint_read_data      = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.maint_read_data                  ;
            assign u_ccp_if[<%=i%>].maint_read_data_en   = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.maint_read_data_en               ;

            //Serialization Signal
            assign u_ccp_if[<%=i%>].isRead      = ((dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid &&
                        ~dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_snp &&
                        ~dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_wake) &&
                        ~dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_write);
                        
            assign u_ccp_if[<%=i%>].isWrite     = ((dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid &&
                                            ~dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_wake
                                            ) &&
                                        dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_write);

            assign u_ccp_if[<%=i%>].isSnoop     = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid &
//                                        ~dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_write &
//                                        dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.t_pt_partial;
                                        dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_snp;
            assign u_ccp_if[<%=i%>].isMntOp     = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_cmr[1]; 


            assign u_ccp_if[<%=i%>].isRead_Wakeup      = (dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid &&
                                                dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_wake &&
                                                ~dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_write);

            assign u_ccp_if[<%=i%>].isWrite_Wakeup     = ((dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid &&
                                                dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_wake) &&
                                                dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_write);

            assign u_ccp_if[<%=i%>].read_hit            = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid &
                                                ~dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_write &
                                                ~dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_snp &
                                            dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_c2_chit ;
            assign u_ccp_if[<%=i%>].read_miss_allocate  = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid &
                                                ~dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_write &
                                                ~dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_snp &
                                                ~dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_c2_chit &
                                            dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.cp2_alloc_o ;

            assign u_ccp_if[<%=i%>].write_hit           = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid &
                                                dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_write &
                                            dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_c2_chit ;
            assign u_ccp_if[<%=i%>].write_miss_allocate = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid &
                                                dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_write &
                                                (~| dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.cp2_hits_i) &
                                            dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.cp2_alloc_o;
            assign u_ccp_if[<%=i%>].snoop_hit           = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid &
                                                dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_snp &
                                            dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_c2_chit;
            assign u_ccp_if[<%=i%>].write_hit_upgrade   = dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_p2_valid &
                                                dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_pt_write &
                                                (| dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.cp2_hits_i) &
                                            (~& dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ioaiu_control.w_c2_state);
        <%}%>
        int unsigned current_index;
        int unsigned prev_index;
        logic  stale_vec_detected;

        always @ (posedge dut_clk or negedge soft_rstn) begin
            if(~soft_rstn) begin 
                stale_vec_detected <= '0;
            end else begin
                if(dut.ioaiu_core_wrapper.ioaiu_core0.ccp_top.cache_valid_p2 && dut.ioaiu_core_wrapper.ioaiu_core0.ccp_top.cache_nack_uce_p2) begin
                    stale_vec_detected <= 1'b1; 
                end else begin
                    stale_vec_detected <= 1'b0;
                end
            end
        end
		<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            assign u_ccp_if[<%=i%>].stale_vec_flag         = stale_vec_detected & (|dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.u_ccp.u_tagpipe.way_alloc_residue);
            <%for( var j=0;j<nTagBanks;j++){%>
           assign u_csr_probe_if[<%=i%>].bypass_bank<%=j%>      =|dut.ioaiu_core_wrapper.ioaiu_core<%=i%>.ccp_top.u_ccp.u_tagpipe.bypass_bank<%=j%>;
        <%}%>
        <%}%>
    <%}%>

    int totalData[<%=obj.DutInfo.nNativeInterfacePorts%>];
    bit cacheLineStarted[<%=obj.DutInfo.nNativeInterfacePorts%>];
    <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++ ){%>
        always @(posedge dut_clk) begin
            if(ace_if[<%=i%>].rvalid && ace_if[<%=i%>].rready) begin
                totalData[<%=i%>] = totalData[<%=i%>] + <%=obj.DutInfo.wData%>;
                if(totalData[<%=i%>] == 512) begin
                    totalData[<%=i%>] = 0;
                    cacheLineStarted[<%=i%>] = 0;
                end else begin
                    cacheLineStarted[<%=i%>] = 1;
                end
            end
        end
    <%}%>

    reg aiu_corr_uncorr_flag;
    int k_prob_single_bit_tag_error = 100;
    int k_prob_double_bit_tag_error = 100;
    int k_prob_single_bit_data_error = 100;
    int k_prob_double_bit_data_error = 100;

    initial begin

       <%for(let i=0; i< obj.DutInfo.nNativeInterfacePorts; i++){%>
        uvm_config_db#(virtual <%=obj.BlockId%>_probe_if)::set(.cntxt( uvm_root::get() ),
                                            .inst_name( "" ),
                                            .field_name( "u_csr_probe_if<%=i%>" ),
                                            .value( u_csr_probe_if[<%=i%>] ));
	<%}%>
    <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %> 
	    uvm_config_db#(virtual <%=obj.BlockId%>_event_if #(.IF_MASTER(1)))::set(uvm_root::get(), "", "m_<%=obj.BlockId%>_event_if_sender_master",m_event_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sender_master);    
    <% } %> 
    <% if (obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false) { %>
	       uvm_config_db#(virtual <%=obj.BlockId%>_event_if #(.IF_MASTER(0)))::set(uvm_root::get(), "", "m_<%=obj.BlockId%>_event_if_receiver_slave",m_event_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_receiver_slave);      
    <% } %>

        // Put Event Interface in the config db. This is used in the ioaiu_scoreboard
        // Event Out interface can be optional for ACE - CONC-8149
        <%if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5" || ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface  == "AXI5") && obj.DutInfo.useCache == 1))){%>
            uvm_config_db#(virtual event_out_if)::set(.cntxt( uvm_root::get() ),
                                                .inst_name( "" ),
                                                .field_name( "u_event_out_if_<%=obj.DutInfo.strRtlNamePrefix%>" ),
                                                .value( m_event_out_if_<%=obj.DutInfo.strRtlNamePrefix%> ));
        <%}%>
    
    	<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
        	ace_if[<%=i%>].IS_IF_A_SLAVE = 0;
               <% if(obj.testBench == 'io_aiu') { %>
              `ifndef VCS
        //	ace_if[<%=i%>].rresp[3:2]    = '0;
              `else // `ifndef VCS
              //ace_if[<%=i%>].rresp[3:2]    = '0;
              `endif // `ifndef VCS ... `else ... 
              <% } else {%>
        	ace_if[<%=i%>].rresp[3:2]    = '0;
              <% } %>
        <%}%>						 
        `ifdef USE_VIP_SNPS
            uvm_config_db#(virtual svt_axi_if)::set(null, 
            "uvm_test_top.axi_system_env.amba_system_env.axi_system[0]", "vif", ace_vip_if);
        `else
    		<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            	ace_if[<%=i%>].IS_ACTIVE       = 1;
        	<%}%>						 
        `endif // !`ifdef USE_VIP_SNPS

        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            uvm_config_db#(virtual <%=obj.BlockId%>_axi_cmdreq_id_if)::set(uvm_root::get(), "*", "<%=obj.BlockId%>_axi_cmdreq_id_vif_<%=i%>", axi_cmdreq_id_if[<%=i%>]);
        <%}%>
        <%if(obj.NO_SMI === undefined){
            var NSMIIFTX = obj.nSmiRx;
            for(var i = 0; i < NSMIIFTX; i++){%>
                uvm_config_db#(virtual <%=obj.BlockId%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                            .inst_name( "*" ),
                                            .field_name( "m_smi<%=i%>_tx_port_if" ),
                                            .value(port<%=i%>_tx_smi_if));
            <%}%>
            <%var NSMIIFRX = obj.nSmiTx;
            for(var i = 0; i < NSMIIFRX; i++){%>
                uvm_config_db#(virtual <%=obj.BlockId%>_smi_if)::set(.cntxt( uvm_root::get() ),
                                            .inst_name( "" ),
                                            .field_name( "m_smi<%=i%>_rx_port_if" ),
                                            .value(port<%=i%>_rx_smi_if));
            <%}%>
        <%}%>

        uvm_config_db#(virtual <%=obj.BlockId%>_q_chnl_if )::set(.cntxt( uvm_root::get()),
                                            .inst_name( "" ),
                                            .field_name( "m_q_chnl_if" ),
                                            .value(m_q_chnl_if ));


    	<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            uvm_config_db#(virtual <%=obj.BlockId+'_axi_if'%>)::set(uvm_root::get(), "*", "axi_master_vif_<%=i%>", ace_if[<%=i%>]);
        <%}%>
          uvm_config_db#(virtual <%=obj.BlockId+'_axi_if'%>)::set(uvm_root::get(), "*", "axi_master_vif_0", ace_if[0]);


        <%if( obj.DutInfo.useCache && obj.V16_OLD_IO_CACHE){%>
            uvm_config_db#(virtual <%=obj.BlockId%>_cbi_rtl_if)::set(uvm_root::get(), "", "cbi<%=obj.Id%>_vif", m_cbi_rtl_if);
        <%}%>

        <%if(obj.DutInfo.useCache){%>
			<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                uvm_config_db#(virtual <%=obj.BlockId%>_ccp_if)::set(uvm_root::get(), "", "ccp<%=obj.Id%>_vif_<%=i%>", u_ccp_if[<%=i%>]);
            <%}%>
        <%}%>

        <%if(obj.BLK_SNPS_OCP_VIP){%>

            uvm_config_db#(virtual svt_ocp_if )::set(.cntxt( null ),
                                            .inst_name( "" ),
                                            .field_name( "mstr_vif" ),
                                            .value(mstr_vif ));
        <%}%>
        <%if(obj.INHOUSE_APB_VIP){%>
            uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "uvm_test_top.env" ),
                                            .field_name( "system_quiesce" ),
                                            .value( system_quiesce));
            uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "uvm_test_top.env" ),
                                            .field_name( "system_unquiesce" ),
                                            .value( system_unquiesce));

            uvm_config_db#(virtual <%=obj.BlockId%>_apb_if )::set(.cntxt( uvm_root::get()),
                                            .inst_name( "" ),
                                            .field_name( "apb_if" ),
                                            .value(apb_if ));

            uvm_config_db#(virtual <%=obj.BlockId%>_apb_if )::set(.cntxt( null ),
                                            .inst_name( "uvm_test_top.m_env.m_apb_agent.m_apb_driver" ),
                                            .field_name( "m_vif" ),
                                            .value(apb_if ));
        <%}%>
		<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::set(null, "", "<%=obj.BlockId%>_0_m_top_stall_if_<%=i%>", <%=obj.BlockId%>_sb_stall_if[<%=i%>]); 
        <%}%>
        uvm_config_db#(virtual <%=obj.BlockId%>_connectivity_if)::set(null,"","<%=obj.BlockId%>_connectivity_if",<%=obj.BlockId%>_connectivity_if);
        <%if(obj.DutInfo.useCache && obj.assertOn) {
            if(obj.DutInfo.ccpParams.TagErrInfo === "SECDED" && obj.DutInfo.MemoryGeneration.tagMem.MemType != "SYNOPSYS") {%>
                // IOAIU Need to fix for multiport - SAI
                if ($test$plusargs("single_bit_tag_error_test")) begin
                    <%for( var i=0;i<obj.DutInfo.ccpParams.nTagBanks * obj.DutInfo.nNativeInterfacePorts;i++){%>
                        <%if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "NONE") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_errors(k_prob_single_bit_tag_error,0,0);
                        <%} else if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "SYNOPSYS") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_errors(k_prob_single_bit_tag_error,0,0);
                        <%}%>
                    <%}%>
                    `uvm_info("TAG_ERROR_TEST","single_bit_tag_error_test",UVM_MEDIUM)
                end
                if($test$plusargs("double_bit_tag_error_test")) begin
                    <%for( var i=0;i<obj.DutInfo.ccpParams.nTagBanks * obj.DutInfo.nNativeInterfacePorts;i++){%>
                        <%if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "NONE") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_errors(0,k_prob_double_bit_tag_error,0);
                        <%} else if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "SYNOPSYS") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_errors(0,k_prob_double_bit_tag_error,0);
                        <%}%>
                    <%}%>
                    `uvm_info("TAG_ERROR_TEST","double_bit_tag_error_test",UVM_MEDIUM)
                end    
                if($test$plusargs("multi_blk_single_double_tag_error")) begin
                    <%for( var i=0;i<obj.DutInfo.ccpParams.nTagBanks * obj.DutInfo.nNativeInterfacePorts;i++){%>
                        <%if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "NONE") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_errors(k_prob_single_bit_tag_error,k_prob_double_bit_tag_error,1);
                        <%} else if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "SYNOPSYS") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_errors(k_prob_single_bit_tag_error,k_prob_double_bit_tag_error,1);
                        <%}%>
                    <%}%>
                    `uvm_info("TAG_ERROR_TEST","multi_blk_single_double_tag_error",UVM_MEDIUM)
                end
                if ($test$plusargs("multi_blk_double_tag_error")) begin
                    <%for( var i=0;i<obj.DutInfo.ccpParams.nTagBanks * obj.DutInfo.nNativeInterfacePorts;i++){%>
                        <%if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "NONE") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_errors(0,k_prob_double_bit_tag_error,1);
                        <%} else if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "SYNOPSYS") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_errors(0,k_prob_double_bit_tag_error,1);
                        <%}%>
                    <%}%>

                    `uvm_info("TAG_ERROR_TEST","multi_blk_double_tag_error",UVM_MEDIUM)
                end

                if ($test$plusargs("multi_blk_single_tag_error")) begin
                    <%for( var i=0;i<obj.DutInfo.ccpParams.nTagBanks * obj.DutInfo.nNativeInterfacePorts;i++){%>
                        <%if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "NONE") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_errors(k_prob_single_bit_tag_error,0,1);
                        <%} else if(obj.DutInfo.MemoryGeneration.tagMem[0].MemType == "SYNOPSYS") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_errors(k_prob_single_bit_tag_error,0,1);
                        <%}%>
                    <%}%>
                    `uvm_info("TAG_ERROR_TEST","multi_blk_single_tag_error",UVM_MEDIUM)
                end
           
            <%}else{%>
                //`uvm_warning($sformatf("%m"), "CCP tag error injection Ignored")
            <%}%> 
            <%if(obj.DutInfo.ccpParams.DataErrInfo.substring(0,6) === "SECDED" && obj.DutInfo.MemoryGeneration.dataMem.MemType != "SYNOPSYS"){%>
                if($test$plusargs("single_bit_data_error_test")) begin
                    //FIXME : Need to fix for multiport IOAIU - sai
                    <%for( var i=0;i<obj.DutInfo.ccpParams.nDataBanks;i++){%>
                        <%if(obj.DutInfo.MemoryGeneration.dataMem[0].MemType == "NONE") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_errors(k_prob_single_bit_data_error,0,0);
                        <%} else if(obj.DutInfo.MemoryGeneration.dataMem[0].MemType == "SYNOPSYS") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_errors(k_prob_single_bit_data_error,0,0);
                        <%}%>
                    <%}%>
                    `uvm_info("DATA_ERROR_TEST","single_bit_data_error_test",UVM_MEDIUM)
                end
                if($test$plusargs("double_bit_data_error_test")) begin
                    //FIXME : Need to fix for multiport IOAIU - sai
                    <%for( var i=0;i<obj.DutInfo.ccpParams.nDataBanks;i++){%>
                        <%if(obj.DutInfo.MemoryGeneration.dataMem[0].MemType == "NONE") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_errors(0,k_prob_double_bit_data_error,0);
                        <%} else if(obj.DutInfo.MemoryGeneration.dataMem[0].MemType == "SYNOPSYS") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_errors(0,k_prob_double_bit_data_error,0);
                        <%}%>
                    <%}%>
                    `uvm_info("DATA_ERROR_TEST","double_bit_data_error_test",UVM_MEDIUM)
                end    
                if($test$plusargs("multi_blk_single_double_data_error")) begin
                    <%for( var i=0;i<obj.DutInfo.ccpParams.nDataBanks;i++){%>
                        <%if(obj.DutInfo.MemoryGeneration.dataMem[0].MemType == "NONE") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_errors(k_prob_single_bit_data_error,k_prob_double_bit_data_error,1);
                        <%} else if(obj.DutInfo.MemoryGeneration.dataMem[0].MemType == "SYNOPSYS") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_errors(k_prob_single_bit_data_error,k_prob_double_bit_data_error,1);
                        <%}%>
                    <%}%>
                    `uvm_info("DATA_ERROR_TEST","multi_blk_single_double_data_error",UVM_MEDIUM)
                    
                end

                if($test$plusargs("multi_blk_double_data_error")) begin
                    <%for( var i=0;i<obj.DutInfo.ccpParams.nDataBanks;i++){%>
                        <%if(obj.DutInfo.MemoryGeneration.dataMem[0].MemType == "NONE") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_errors(0,k_prob_double_bit_data_error,1);
                        <%} else if(obj.DutInfo.MemoryGeneration.dataMem[0].MemType == "SYNOPSYS") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_errors(0,k_prob_double_bit_data_error,1);
                        <%}%>
                    <%}%>
                    `uvm_info("DATA_ERROR_TEST","multi_blk_double_data_error",UVM_MEDIUM)
                    
                end

                if($test$plusargs("multi_blk_single_data_error")) begin
                    <%for( var i=0;i<obj.DutInfo.ccpParams.nDataBanks;i++){%>
                        <%if(obj.DutInfo.MemoryGeneration.dataMem[0].MemType == "NONE") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_errors(k_prob_single_bit_data_error,0,1);
                        <%} else if(obj.DutInfo.MemoryGeneration.dataMem[0].MemType == "SYNOPSYS") {%>
                            tb_top.dut.<%=obj.AiuInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_errors(k_prob_single_bit_data_error,0,1);
                        <%}%>
                    <%}%>

                    `uvm_info("DATA_ERROR_TEST","multi_blk_single_data_error",UVM_MEDIUM)
                    
                end
            <%}else{%>
                //`uvm_warning($sformatf("%m"), "CCP data error injection Ignored")
            <%}%> 
        <%}else{%>
            //`uvm_warning($sformatf("%m"), "useCmc = 0.")
        <%}%>

        <%if(obj.INHOUSE_APB_VIP){%>
            <%if(obj.assertOn){%>
                <%for(var i=0;i< (nOttBanks * obj.DutInfo.nNativeInterfacePorts);i++){%>
                    injectSingleErrOtt<%=i%> = new("injectSingleErrOtt<%=i%>");
                    injectDoubleErrOtt<%=i%> = new("injectDoubleErrOtt<%=i%>");
                    inject_multi_block_single_double_ErrOtt<%=i%> = new("inject_multi_block_single_double_ErrOtt<%=i%>");
                    inject_multi_block_double_ErrOtt<%=i%> = new("inject_multi_block_double_ErrOtt<%=i%>");
                    inject_multi_block_single_ErrOtt<%=i%> = new("inject_multi_block_single_ErrOtt<%=i%>");
		    injectAddrErrOtt<%=i%>  = new ("injectAddrErrOtt<%=i%>");
                <%}%>
                <%if(obj.DutInfo.useCache){%>
                    <%for(var i=0;i<nTagBanks * obj.DutInfo.nNativeInterfacePorts;i++){%>
                        injectSingleErrTag<%=i%> = new("injectSingleErrTag<%=i%>");
                        injectDoubleErrTag<%=i%> = new("injectDoubleErrTag<%=i%>");
                        inject_multi_block_single_double_ErrTag<%=i%> = new("inject_multi_block_single_double_ErrTag<%=i%>");
                        inject_multi_block_double_ErrTag<%=i%> = new("inject_multi_block_double_ErrTag<%=i%>");
                        inject_multi_block_single_ErrTag<%=i%> = new("inject_multi_block_single_ErrTag<%=i%>");
                        injectAddrErrTag<%=i%>  = new ("injectAddrErrTag<%=i%>");
                    <%}%>
                    <%for(var i=0;i<=obj.AiuInfo[obj.Id].ccpParams.nRPPorts * obj.DutInfo.nNativeInterfacePorts;i++){%>
                    injectSingleErrplru<%=i%> = new("injectSingleErrplru<%=i%>");
                    injectDoubleErrplru<%=i%> = new("injectDoubleErrplru<%=i%>");
                    injectAddrErrplru<%=i%> = new("injectAddrErrplru<%=i%>");
                    <%}%>
                    <%for(var i=0;i<(nDataBanks * obj.DutInfo.nNativeInterfacePorts);i++){%>
                        injectSingleErrData<%=i%> = new("injectSingleErrData<%=i%>");
                        injectDoubleErrData<%=i%> = new("injectDoubleErrData<%=i%>");
                        inject_multi_block_single_double_ErrData<%=i%> = new("inject_multi_block_single_double_ErrData<%=i%>");
                        inject_multi_block_double_ErrData<%=i%> = new("inject_multi_block_double_ErrData<%=i%>");
                        inject_multi_block_single_ErrData<%=i%> = new("inject_multi_block_single_ErrData<%=i%>");
                        injectAddrErrData<%=i%>  = new ("injectAddrErrData<%=i%>");

                    <%}%>
                <%}%>
            <%}%>
            <%if(obj.assertOn){%>
                <%for(var i=0;i< (nOttBanks * obj.DutInfo.nNativeInterfacePorts);i++){%>
                    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "*" ),
                                            .field_name( "injectSingleErrOtt<%=i%>" ),
                                            .value( injectSingleErrOtt<%=i%>));
                    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "*" ),
                                            .field_name( "injectDoubleErrOtt<%=i%>" ),
                                            .value( injectDoubleErrOtt<%=i%>));
                    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "*" ),
                                            .field_name( "inject_multi_block_single_double_ErrOtt<%=i%>" ),
                                            .value( inject_multi_block_single_double_ErrOtt<%=i%>));
                    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "*" ),
                                            .field_name( "inject_multi_block_double_ErrOtt<%=i%>" ),
                                            .value( inject_multi_block_double_ErrOtt<%=i%>));
                    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "*" ),
                                            .field_name( "inject_multi_block_single_ErrOtt<%=i%>" ),
                                            .value( inject_multi_block_single_ErrOtt<%=i%>));

                    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "*" ),
                                            .field_name( "injectAddrErrOtt<%=i%>" ),
                                            .value( injectAddrErrOtt<%=i%>));

                <%}%>
                <%for(var i=0;i<=obj.AiuInfo[obj.Id].ccpParams.nRPPorts * obj.DutInfo.nNativeInterfacePorts;i++){%>
                uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "*" ),
                                            .field_name( "injectSingleErrplru<%=i%>" ),
                                            .value( injectSingleErrplru<%=i%>));
                uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "*" ),
                                            .field_name( "injectDoubleErrplru<%=i%>" ),
                                            .value( injectDoubleErrplru<%=i%>));
                uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "*" ),
                                            .field_name( "injectAddrErrplru<%=i%>" ),
                                            .value( injectAddrErrplru<%=i%>));


                <%}%>
                   
                <%if(obj.DutInfo.useCache){%>
                    <%for(var i=0;i<nTagBanks * obj.DutInfo.nNativeInterfacePorts;i++){%>
                        uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "*" ),
                                            .field_name( "injectSingleErrTag<%=i%>" ),
                                            .value( injectSingleErrTag<%=i%>));
                        uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "*" ),
                                            .field_name( "injectDoubleErrTag<%=i%>" ),
                                            .value( injectDoubleErrTag<%=i%>));
                        uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "*" ),
                                            .field_name( "inject_multi_block_single_double_ErrTag<%=i%>" ),
                                            .value( inject_multi_block_single_double_ErrTag<%=i%>));
                        uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "*" ),
                                            .field_name( "inject_multi_block_double_ErrTag<%=i%>" ),
                                            .value( inject_multi_block_double_ErrTag<%=i%>));
                        uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "*" ),
                                            .field_name( "inject_multi_block_single_ErrTag<%=i%>" ),
                                            .value( inject_multi_block_single_ErrTag<%=i%>));
                       uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "*" ),
                                            .field_name( "injectAddrErrTag<%=i%>" ),
                                            .value( injectAddrErrTag<%=i%>));
                    <%}%>
                    <%for(var i=0;i<(nDataBanks * obj.DutInfo.nNativeInterfacePorts);i++){%>
                        uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "*" ),
                                            .field_name( "injectSingleErrData<%=i%>" ),
                                            .value( injectSingleErrData<%=i%>));
                        uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "*" ),
                                            .field_name( "injectDoubleErrData<%=i%>" ),
                                            .value( injectDoubleErrData<%=i%>));
                        uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "*" ),
                                            .field_name( "inject_multi_block_single_double_ErrData<%=i%>" ),
                                            .value( inject_multi_block_single_double_ErrData<%=i%>));
                        uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "*" ),
                                            .field_name( "inject_multi_block_double_ErrData<%=i%>" ),
                                            .value( inject_multi_block_double_ErrData<%=i%>));
                        uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "*" ),
                                            .field_name( "inject_multi_block_single_ErrData<%=i%>" ),
                                            .value( inject_multi_block_single_ErrData<%=i%>));
                      uvm_config_db#(uvm_event)::set(.cntxt(null),
                                            .inst_name( "*" ),
                                            .field_name( "injectAddrErrData<%=i%>" ),
                                            .value( injectAddrErrData<%=i%>));

                    <%}%>
                <%}%>
            <%}%>
        <%}%>

        `ifdef DUMP_ON
            if($test$plusargs("en_dump")) begin
                $vcdpluson;
                $vcdplusmemon;
            end
        `endif
        run_test("bring_up_test");
        $finish;
    end

    <%if(!obj.CUSTOMER_ENV){%>
        //Task calls end of simulation and pending transaction methods
        task assert_error(input string verbose, input string msg);
            uvm_component  m_comp[$];
            
            if(verbose == "FATAL") begin 
                `uvm_fatal("assert_error", msg); 
            end else begin 
                `uvm_error("assert_error", msg); 
            end
        endtask: assert_error
        // ARM AXI Assertions
        <%if(obj.ARM_SVA_ON){%>
            `ifdef ASSERT_ON
                <%if(((obj.fnNativeInterface == "ACE-LITE") || (obj.fnNativeInterface == "ACELITE-E")) && obj.ARM_SVA_ON){%>
                    //FIXME: need to hook up ACE-Lite sva 
                    //defparam m_axi4_arm_sva.PROTOCOL = 2'b10;
                <%}%>
                <%if(obj.fnNativeInterface == "AXI4"){%>
                	<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                    <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_Axi4PC_ace m_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_C<%=i%>_axi4_arm_sva(
                    // Global Signals
                    .ACLK                     ( dut_clk         ) ,
                    .ARESETn                  ( soft_rstn       ) ,
                    // Write Address Channel
                    .AWID                     ( ace_if[<%=i%>].awid     ) ,
                    .AWADDR                   ( ace_if[<%=i%>].awaddr   ) ,
                    .AWLEN                    ( ace_if[<%=i%>].awlen    ) ,
                    .AWSIZE                   ( ace_if[<%=i%>].awsize   ) ,
                    .AWBURST                  ( ace_if[<%=i%>].awburst  ) ,
                    .AWLOCK                   ( ace_if[<%=i%>].awlock   ) ,
                    .AWCACHE                  ( ace_if[<%=i%>].awcache  ) ,
                    .AWPROT                   ( ace_if[<%=i%>].awprot   ) ,
    	<%if(obj.DutInfo.nNativeInterfacePorts == 1){%>
                    .AWUSER                   ( <%if(obj.interfaces.axiInt.params.wAwUser > 0) {%>ace_if[<%=i%>].awuser<%} else {%> '0 <%}%> ) ,
                    .AWQOS                    ( <%if(obj.interfaces.axiInt.params.wQos > 0) {%>ace_if[<%=i%>].awqos<%} else {%> '0 <%}%> ) ,
                    .AWREGION                 ( <%if(obj.interfaces.axiInt.params.wRegion > 0) {%>ace_if[<%=i%>].awregion<%} else {%> '0 <%}%> ) ,
                    <%} else if(obj.DutInfo.nNativeInterfacePorts > 1) {%>
                    .AWUSER                   ( <%if(obj.interfaces.axiInt[i].params.wAwUser > 0) {%>ace_if[<%=i%>].awuser<%} else {%> '0 <%}%> ) ,
                    .AWQOS                    ( <%if(obj.interfaces.axiInt[i].params.wQos > 0) {%>ace_if[<%=i%>].awqos<%} else {%> '0 <%}%> ) ,
                    .AWREGION                 ( <%if(obj.interfaces.axiInt[i].params.wRegion > 0) {%>ace_if[<%=i%>].awregion<%} else {%> '0 <%}%> ) ,
                <%}%>
                    .AWVALID                  ( ace_if[<%=i%>].awvalid  ) ,
                    .AWREADY                  ( ace_if[<%=i%>].awready  ) ,

                    // Write Channel
                    .WDATA                    ( ace_if[<%=i%>].wdata    ) ,
                    .WSTRB                    ( ace_if[<%=i%>].wstrb    ) ,
    	<%if(obj.DutInfo.nNativeInterfacePorts == 1){%>
                    .WUSER                    ( <%if(obj.interfaces.axiInt.params.wWUser > 0) {%>ace_if[<%=i%>].wuser<%} else {%> '0 <%}%> ) ,
                    <%} else if(obj.DutInfo.nNativeInterfacePorts > 1) {%>
                    .WUSER                    ( <%if(obj.interfaces.axiInt[i].params.wWUser > 0) {%>ace_if[<%=i%>].wuser<%} else {%> '0 <%}%> ) ,
                <%}%>
                    .WLAST                    ( ace_if[<%=i%>].wlast    ) ,
                    .WVALID                   ( ace_if[<%=i%>].wvalid   ) ,
                    .WREADY                   ( ace_if[<%=i%>].wready   ) ,

                    // Write Response Channel
                    .BID                      ( ace_if[<%=i%>].bid      ) ,
                    .BRESP                    ( ace_if[<%=i%>].bresp    ) ,
    	<%if(obj.DutInfo.nNativeInterfacePorts == 1){%>
                    .BUSER                    ( <%if(obj.interfaces.axiInt.params.wBUser > 0) {%>ace_if.buser<%} else {%> '0 <%}%> ) ,
                    <%} else if(obj.DutInfo.nNativeInterfacePorts > 1) {%>
                    .BUSER                    ( <%if(obj.interfaces.axiInt[i].params.wBUser > 0) {%>ace_if.buser<%} else {%> '0 <%}%> ) ,
                <%}%>
                    .BVALID                   ( ace_if[<%=i%>].bvalid   ) ,
                    .BREADY                   ( ace_if[<%=i%>].bready   ) ,

                    // Read Address Channel
                    .ARID                     ( ace_if[<%=i%>].arid     ) ,
                    .ARADDR                   ( ace_if[<%=i%>].araddr   ) ,
                    .ARLEN                    ( ace_if[<%=i%>].arlen    ) ,
                    .ARSIZE                   ( ace_if[<%=i%>].arsize   ) ,
                    .ARBURST                  ( ace_if[<%=i%>].arburst  ) ,
                    .ARLOCK                   ( ace_if[<%=i%>].arlock   ) ,
                    .ARCACHE                  ( ace_if[<%=i%>].arcache  ) ,
                    .ARPROT                   ( ace_if[<%=i%>].arprot   ) ,
    	<%if(obj.DutInfo.nNativeInterfacePorts == 1){%>
                    .ARUSER                   ( <%if(obj.interfaces.axiInt.params.wArUser > 0) {%>ace_if[<%=i%>].aruser<%} else {%> '0 <%}%> ) ,
                    .ARQOS                    ( <%if(obj.interfaces.axiInt.params.wQos > 0) {%>ace_if[<%=i%>].arqos<%} else {%> '0 <%}%> ) ,
                    .ARREGION                 ( <%if(obj.interfaces.axiInt.params.wRegion > 0) {%>ace_if[<%=i%>].arregion<%} else {%> '0 <%}%> ) ,
                    <%} else if(obj.DutInfo.nNativeInterfacePorts > 1) {%>
                    .ARUSER                   ( <%if(obj.interfaces.axiInt[i].params.wArUser > 0) {%>ace_if[<%=i%>].aruser<%} else {%> '0 <%}%> ) ,
                    .ARQOS                    ( <%if(obj.interfaces.axiInt[i].params.wQos > 0) {%>ace_if[<%=i%>].arqos<%} else {%> '0 <%}%> ) ,
                    .ARREGION                 ( <%if(obj.interfaces.axiInt[i].params.wRegion > 0) {%>ace_if[<%=i%>].arregion<%} else {%> '0 <%}%> ) ,
                <%}%>
                    .ARVALID                  ( ace_if[<%=i%>].arvalid  ) ,
                    .ARREADY                  ( ace_if[<%=i%>].arready  ) ,

                    //  Read Channel
                    .RID                      ( ace_if[<%=i%>].rid      ) ,
                    .RLAST                    ( ace_if[<%=i%>].rlast    ) ,
                    .RDATA                    ( ace_if[<%=i%>].rdata    ) ,
                    .RRESP                    ( ace_if[<%=i%>].rresp    ) ,
    	<%if(obj.DutInfo.nNativeInterfacePorts == 1){%>
                    .RUSER                    ( <%if(obj.interfaces.axiInt.params.wRUser > 0) {%>ace_if[<%=i%>].ruser<%} else {%> '0            <%}%> ) ,
                    <%} else if(obj.DutInfo.nNativeInterfacePorts > 1) {%>
                    .RUSER                    ( <%if(obj.interfaces.axiInt[i].params.wRUser > 0) {%>ace_if[<%=i%>].ruser<%} else {%> '0            <%}%> ) ,
                <%}%>
                    .RVALID                   ( ace_if[<%=i%>].rvalid   ) ,
                    .RREADY                   ( ace_if[<%=i%>].rready   ) ,

                    // Low Power Interface
                    .CACTIVE                  ( 'b1             ) ,
                    .CSYSREQ                  ( 'b1             ) ,
                    .CSYSACK                  ( 'b1             )) ;
                <%}%>

                <%if(obj.fnNativeInterface === "ACE" || obj.fnNativeInterface === "ACE5"){%>
                    <%=obj.BlockId + '_'%>AcePC m_ace_arm_sva    (
                    // Global Signals
                    .ACLK                     ( dut_clk         ) ,
                    .ARESETn                  ( soft_rstn       ) ,

                    // Write Address Channel
                    .AWID                     ( ace_if[<%=i%>].awid     ) ,
                    .AWADDR                   ( ace_if[<%=i%>].awaddr   ) ,
                    .AWLEN                    ( ace_if[<%=i%>].awlen    ) ,
                    .AWSIZE                   ( ace_if[<%=i%>].awsize   ) ,
                    .AWBURST                  ( ace_if[<%=i%>].awburst  ) ,
                    .AWLOCK                   ( ace_if[<%=i%>].awlock   ) ,
                    .AWCACHE                  ( ace_if[<%=i%>].awcache  ) ,
                    .AWSNOOP                  ( ace_if[<%=i%>].awsnoop  ) ,
                    .AWPROT                   ( ace_if[<%=i%>].awprot   ) ,
                    .AWUSER                   ( <%if(obj.interfaces.axiInt.params.wAwUser > 0) {%>ace_if[<%=i%>].awuser<%} else {%> '0            <%}%> ) ,
                    .AWQOS                    ( <%if(obj.interfaces.axiInt.params.wQos > 0) {%>ace_if[<%=i%>].awqos<%} else {%> '0            <%}%> ) ,
                    .AWBAR                    ( ace_if[<%=i%>].awbar    ) ,
                    .AWDOMAIN                 ( ace_if[<%=i%>].awdomain ) ,
                    .AWREGION                 ( <%if(obj.interfaces.axiInt.params.wRegion > 0) {%>ace_if[<%=i%>].awregion<%} else {%> '0            <%}%> ) ,
                    .AWVALID                  ( ace_if[<%=i%>].awvalid  ) ,
                    .AWREADY                  ( ace_if[<%=i%>].awready  ) ,

                    // Write Channel
                    .WDATA                    ( ace_if[<%=i%>].wdata    ) ,
                    .WSTRB                    ( ace_if[<%=i%>].wstrb    ) ,
                    .WUSER                    ( <%if(obj.interfaces.axiInt.params.wWUser > 0) {%>ace_if[<%=i%>].wuser<%} else {%> '0            <%}%> ) ,
                    .WLAST                    ( ace_if[<%=i%>].wlast    ) ,
                    .WVALID                   ( ace_if[<%=i%>].wvalid   ) ,
                    .WREADY                   ( ace_if[<%=i%>].wready   ) ,

                    // Write Response Channel
                    .BID                      ( ace_if[<%=i%>].bid      ) ,
                    .BRESP                    ( ace_if[<%=i%>].bresp    ) ,
                    .BUSER                    ( <%if(obj.interfaces.axiInt.params.wBUser > 0) {%>ace_if[<%=i%>].buser<%} else {%> '0            <%}%> ) ,
                    .BVALID                   ( ace_if[<%=i%>].bvalid   ) ,
                    .BREADY                   ( ace_if[<%=i%>].bready   ) ,

                    .WACK                     ( ace_if[<%=i%>].wack     ) ,

                    // Read Address Channel
                    .ARID                     ( ace_if[<%=i%>].arid     ) ,
                    .ARADDR                   ( ace_if[<%=i%>].araddr   ) ,
                    .ARLEN                    ( ace_if[<%=i%>].arlen    ) ,
                    .ARSIZE                   ( ace_if[<%=i%>].arsize   ) ,
                    .ARBURST                  ( ace_if[<%=i%>].arburst  ) ,
                    .ARLOCK                   ( ace_if[<%=i%>].arlock   ) ,
                    .ARCACHE                  ( ace_if[<%=i%>].arcache  ) ,
                    .ARSNOOP                  ( ace_if[<%=i%>].arsnoop  ) ,
                    .ARPROT                   ( ace_if[<%=i%>].arprot   ) ,
                    .ARUSER                   ( <%if(obj.interfaces.axiInt.params.wArUser > 0) {%>ace_if[<%=i%>].aruser<%} else {%> '0            <%}%> ) ,
                    .ARQOS                    ( <%if(obj.interfaces.axiInt.params.wQos > 0) {%>ace_if[<%=i%>].arqos<%} else {%> '0            <%}%> ) ,
                    .ARBAR                    ( ace_if[<%=i%>].arbar    ) ,
                    .ARDOMAIN                 ( ace_if[<%=i%>].ardomain ) ,
                    .ARREGION                 ( <%if(obj.interfaces.axiInt.params.wRegion > 0) {%>ace_if[<%=i%>].arregion<%} else {%> '0            <%}%> ) ,
                    .ARVALID                  ( ace_if[<%=i%>].arvalid  ) ,
                    .ARREADY                  ( ace_if[<%=i%>].arready  ) ,

                    //  Read Channel
                    .RID                      ( ace_if[<%=i%>].rid      ) ,
                    .RLAST                    ( ace_if[<%=i%>].rlast    ) ,
                    .RDATA                    ( ace_if[<%=i%>].rdata    ) ,
                    .RRESP                    ( ace_if[<%=i%>].rresp    ) ,
                    .RUSER                    ( <%if(obj.interfaces.axiInt.params.wRUser > 0) {%>ace_if[<%=i%>].ruser<%} else {%> '0            <%}%> ) ,
                    .RVALID                   ( ace_if[<%=i%>].rvalid   ) ,
                    .RREADY                   ( ace_if[<%=i%>].rready   ) ,
                    
                    .RACK                     ( ace_if[<%=i%>].rack     ) ,

                    // Snoop Address Channel
                    .ACADDR                   ( ace_if[<%=i%>].acaddr   ) ,
                    .ACPROT                   ( ace_if[<%=i%>].acprot   ) ,
                    .ACSNOOP                  ( ace_if[<%=i%>].acsnoop  ) ,
                    .ACVALID                  ( ace_if[<%=i%>].acvalid  ) ,
                    .ACREADY                  ( ace_if[<%=i%>].acready  ) ,

                    // Snoop Response Channel
                    .CRRESP                   ( ace_if[<%=i%>].crresp   ) ,
                    .CRVALID                  ( ace_if[<%=i%>].crvalid  ) ,
                    .CRREADY                  ( ace_if[<%=i%>].crready  ) ,

                    // Snoop Data Channel
                    .CDVALID                  ( ace_if[<%=i%>].cdvalid  ) ,
                    .CDREADY                  ( ace_if[<%=i%>].cdready  ) ,
                    .CDLAST                   ( ace_if[<%=i%>].cdlast   ) ,
                    .CDDATA                   ( ace_if[<%=i%>].cddata   ) ,
                    // Low Power Interface
                    .CACTIVE                  ( 'b1             ) ,
                    .CSYSREQ                  ( 'b1             ) ,
                    .CSYSACK                  ( 'b1             ));
                <%}%>
                <%}%>
            `endif
        <%}%>

        //Checking clock idle when qREQn and qACCEPTn are low (entered into pma)
        <%if(obj.DutInfo.usePma){%>
            assert_clk_idle_when_pma_asserted : assert property (
            @(posedge fr_clk) disable iff (!soft_rstn)
                (!m_q_chnl_if.QREQn && !m_q_chnl_if.QACCEPTn ) |-> !dut_clk
            )else assert_error("ERROR", "Dut clock is not stable low when RTL entered into PMA");
        <%}%>
	initial begin
          if(($test$plusargs("dtw_dbg_rsp_err_inj")) || ($test$plusargs("dtr_req_err_inj")) || ($test$plusargs("snp_req_err_inj")) || ($test$plusargs("dtw_rsp_err_inj")) ||  ($test$plusargs("str_req_err_inj")) || ($test$plusargs("dtr_rsp_err_inj")) || ($test$plusargs("ccmd_rsp_err_inj")) || ($test$plusargs("nccmd_rsp_err_inj")) || ($test$plusargs("cmp_rsp_err_inj")) || ($test$plusargs("sys_req_err_inj_uc")) || ($test$plusargs("sys_req_err_inj_c")) || ($test$plusargs("upd_rsp_err_inj")) || ($test$plusargs("dtw_dbg_rsp_err_inj_uc")) || ($test$plusargs("dtw_dbg_rsp_err_inj_c")) || ($test$plusargs("sys_rsp_err_inj_uc")) || ($test$plusargs("sys_rsp_err_inj_c")) || $test$plusargs("wrong_cmdrsp_target_id") || $test$plusargs( "wrong_dtrreq_target_id") || $test$plusargs( "wrong_dtwrsp_target_id" ) || $test$plusargs( "wrong_strreq_target_id") || $test$plusargs("wrong_sysrsp_target_id") || $test$plusargs("wrong_dtrrsp_target_id") || $test$plusargs("wrong_updrsp_target_id") ||  $test$plusargs("wrong_snpreq_target_id") || $test$plusargs("wrong_sysreq_target_id") || $test$plusargs("expect_mission_fault"))begin 
            <%if(obj.fnNativeInterface == "AXI4"){%>
              <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
          `uvm_info("resilency","Disabling the assertion from {tb_top.axi_if} for resilency testing",UVM_NONE)
                $assertoff(0, m_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_C<%=i%>_axi4_arm_sva);
              <%}%>
            <%}%>
          end
        end


endmodule
