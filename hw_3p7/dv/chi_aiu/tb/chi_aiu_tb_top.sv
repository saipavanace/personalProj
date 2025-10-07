`timescale 1 ns/1 ps
<% if(obj.useResiliency) { %>
`include "fault_injector_checker.sv"
`include "placeholder_connectivity_checker.sv"
<% } %>
//
//`define USE_VIP_SNPS
//
//`ifdef USE_VIP_SNPS
//
//`define DESIGNWARE_INCDIR /engr/dev/tools/synopsys/vip_amba_svt_R-2021.03
//`define SVT_VENDOR_LC mti
//`define SVT_AMBA_INCLUDE_CHI_IN_AMBA_SYS_ENV
////`define SVT_AMBA_EXCLUDE_AHB_IN_AMBA_SYS_ENV
////`define SVT_AMBA_EXCLUDE_AXI_IN_AMBA_SYS_ENV
////`define SVT_AMBA_EXCLUDE_APB_IN_AMBA_SYS_ENV
////`define SVT_AMBA_EXCLUDE_AXI_IN_CHI_SYS_ENV
////`define SVT_LOADER_UTIL_ENABLE_DWHOME_INCDIRS
//`define SVT_EXCLUDE_METHODOLOGY_PKG_INCLUDE
////`define SVT_EXCLUDE_METHODOLOGY_PKG
//`define SVT_CHI_INCLUDE_USER_DEFINES
//`define PA_ENABLE
//
//`endif // USE_VIP_SNPS
//
//`include "uvm_pkg.sv"
//
//`ifdef USE_VIP_SNPS
//`include "uvm_macros.svh"
//`include "svt_chi_defines.svi"
//`include  "svt_amba.uvm.pkg"
////`include  "svt_chi.uvm.pkg"
///** Include the AMBA COMMON SVT UVM package */
////`include "svt_amba_common.uvm.pkg"
//`include "svt_chi_if.svi" //top-level CHI interface
//`endif // USE_VIP_SNPS


`include "snps_compile.sv"    


`ifdef USE_VIP_SNPS
<%
//Embedded javascript code to figure number of blocks
   var _child_blkid = [];
   var _child_blk   = [];
   var pidx = 0;
   var chiaiu_idx = 0;
   var initiatorAgents = obj.AiuInfo.length ;
%>

   <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
       <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
       <% _child_blkid[pidx] = 'caiu' + chiaiu_idx; %>
       <% _child_blk[pidx]   = 'chiaiu'; %>
       <% if (obj.testBench == "fsys") { %>
           `include "<%=_child_blkid[pidx]%>_connection_wrapper_to_svt_chi_rn_if.sv"
       <% } else { %>
         <% if (chiaiu_idx == obj.Id && obj.testBench == "chi_aiu") { %>
           `include "<%=_child_blkid[pidx]%>_connection_wrapper_to_svt_chi_rn_if.sv"
         <% } %>
       <% } %>
       <% chiaiu_idx++; %>
     <% } %>
   <% } %>



`endif // USE_VIP_SNPS

module tb_top();

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "event_out_if.sv"

//`ifdef USE_VIP_SNPS
//import svt_uvm_pkg::*;
////import svt_chi_uvm_pkg::*;
//import svt_amba_uvm_pkg::*;
///** Import the AMBA COMMON Package for amba_pv_extension */
////import svt_amba_common_uvm_pkg::*;
//
//`endif // USE_VIP_SNPS


    `include "snps_import.sv"


import <%=obj.BlockId%>_chi_agent_pkg::*;
import sv_assert_pkg::*;
import <%=obj.BlockId%>_env_pkg::*;
import <%=obj.BlockId%>_test_lib_pkg::*;
import <%=obj.BlockId%>_smi_agent_pkg::*;   //to get the *_FUNIT_IDS

//perf counter
<%=obj.BlockId%>_stall_if <%=obj.BlockId%>_sb_stall_if();
<%=obj.BlockId%>_latency_if <%=obj.BlockId%>_sb_latency_if();

//TB local var
bit dut_clk;
bit tb_clk;
bit tb_rst;
wire irq_uc;
wire irq_c;

uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
uvm_event ev_csr_test_time_out_SYSrsp = ev_pool.get("ev_csr_test_time_out_SYSrsp");


<% if(obj.useResiliency) { %>
 logic[1023:0] slv_req_corruption_vector = 1024'b0;
 logic[1023:0] slv_data_corruption_vector = 1024'b0;
 logic[WSMIADDR-1:0] smi_req_addr_modified;

 logic bist_bist_next_ack;
 logic bist_domain_is_on;
 logic fault_mission_fault;
 logic fault_latent_fault;
 logic fault_cerr_over_thres_fault;
<% } %>

`ifdef USE_VIP_SNPS
svt_chi_if chi_if(dut_clk, soft_rstn);
`endif // USE_VIP_SNPS

`ifdef USE_VIP_SNPS

<%
//Embedded javascript code to figure number of blocks
   var pidx = 0;
   var chiaiu_idx = 0;
%>


   <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
       <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
       <% _child_blk[pidx]   = 'chiaiu'; %>
       <% if (obj.testBench == "fsys") { %>
           <%=_child_blkid[pidx]%>_chi_if m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>(dut_clk,soft_rstn);
           <%=_child_blkid[pidx]%>_connection_wrapper_to_svt_chi_rn_if(m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>, chi_if.rn_if[<%=pidx%>]);
       <% } else { %>
         <% if (chiaiu_idx == obj.Id && obj.testBench == "chi_aiu") { %>
           //<%=obj.BlockId%>_chi_if m_chi_vif(dut_clk,soft_rstn);
           <%=_child_blkid[pidx]%>_chi_if m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>(dut_clk,soft_rstn);
           <%=_child_blkid[pidx]%>_connection_wrapper_to_svt_chi_rn_if m_connection_wrapper_to_svt_chi_rn_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>(m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>, chi_if.rn_if[<%=pidx%>]);
           <% if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') { %>
           initial begin
           // CONC-8094
             //force chi_if.rn_if[<%=pidx%>].SYSCOREQ = 0;
             force m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.sysco_req = 0;
             #500ns;
             //release chi_if.rn_if[<%=pidx%>].SYSCOREQ;
             if (!$test$plusargs("CMDrsp_time_out_test")) begin
                 $display($time, "cmd_rsp_timeout_test is not running");
                 release m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.sysco_req;
             end
           end
           <% } %>

         <% } %>
       <% } %>
       <% chiaiu_idx++; %>
     <% } %>
   <% } %>
`else //USE_VIP_SNPS
//CHI Interface
  //<%=obj.BlockId%>_chi_if m_chi_vif(dut_clk,soft_rstn);
  <%=_child_blkid[obj.Id]%>_chi_if m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>(dut_clk,soft_rstn);
`endif //USE_VIP_SNPS
//CHI Interface


//event interface
event_out_if            m_event_out_if_<%=obj.BlockId%>(dut_clk,soft_rstn);

<%if(obj.nPerfCounters) { %> 
always @ (m_event_out_if_<%=obj.BlockId%>.ev_pin_handshakes) begin
  if(m_event_out_if_<%=obj.BlockId%>.ev_pin_handshakes>0) begin
    <%=obj.BlockId%>_sb_stall_if.perf_count_events["Agent_event_counter"].push_back(1);
  end
end
<%} %> 


//SMI Interface
<%console.log("DutInfo : ", + obj.DutInfo.nSmiRx);%>
<% for (var i = 0; i < obj.DutInfo.nSmiRx; i++) { %>
<% var fntype = obj.DutInfo.interfaces.smiRxInt[i].params.wSmiDPdata==0 ? 'ndp' : 'dp';%>
<%=obj.BlockId%>_smi_if m_smi<%=i%>_tx_vif(dut_clk,soft_rstn,
  "<%= 'tx_' +  fntype + '_' + i%>");
<% if(obj.DutInfo.concParams.hdrParams.wSteering == 0) { %>
initial begin $assertoff(0, m_smi<%=i%>_tx_vif.assert_smi_steer_not_x_z); end
<% } %>

<% if(obj.DutInfo.concParams.hdrParams.wPriority == 0) { %>
initial begin $assertoff(0, m_smi<%=i%>_tx_vif.assert_smi_msg_pri_not_x_z); end
<% } %>

<% if(obj.DutInfo.concParams.hdrParams.wTTier == 0) { %>
initial begin $assertoff(0, m_smi<%=i%>_tx_vif.assert_smi_msg_tier_not_x_z); end
<% } %>

<% if(obj.useQos == 0) { %>
initial begin $assertoff(0, m_smi<%=i%>_tx_vif.assert_smi_msg_qos_not_x_z); end
<% } %>

<% if(obj.DutInfo.interfaces.smiRxInt[i].params.wSmiUser == 0) { %>
initial begin $assertoff(0, m_smi<%=i%>_tx_vif.assert_smi_msg_user_not_x_z); end
<% } %>

<% if(obj.DutInfo.interfaces.smiRxInt[0].params.wSmiDPUser == 0) { %>
initial begin $assertoff(0, m_smi<%=i%>_tx_vif.assert_smi_dp_user_not_x_z); end
<% } %>


<% } %>

<% for (var i = 0; i < obj.DutInfo.nSmiTx; i++) { %>
<% var fntype = obj.DutInfo.interfaces.smiTxInt[i].params.wSmiDPdata==0 ? 'ndp' : 'dp';%>
<%=obj.BlockId%>_smi_if m_smi<%=i%>_rx_vif(dut_clk,soft_rstn,
  "<%= 'rx_' + fntype + '_' + i%>");
<% if(obj.DutInfo.interfaces.smiTxInt[i].params.wSmiErr==0) { %>
initial begin $assertoff(0, m_smi<%=i%>_rx_vif.assert_smi_msg_err_not_x_z); end
<% } %>
<% if(obj.DutInfo.concParams.hdrParams.wSteering == 0) { %>
initial begin $assertoff(0, m_smi<%=i%>_rx_vif.assert_smi_steer_not_x_z); end
<% } %>

<% if(obj.DutInfo.concParams.hdrParams.wPriority == 0) { %>
initial begin $assertoff(0, m_smi<%=i%>_rx_vif.assert_smi_msg_pri_not_x_z); end
<% } %>

<% if(obj.DutInfo.concParams.hdrParams.wTTier == 0) { %>
initial begin $assertoff(0, m_smi<%=i%>_rx_vif.assert_smi_msg_tier_not_x_z); end
<% } %>

<% if(obj.useQos == 0) { %>
initial begin $assertoff(0, m_smi<%=i%>_rx_vif.assert_smi_msg_qos_not_x_z); end
<% } %>

<% if(obj.DutInfo.interfaces.smiTxInt[i].params.wSmiUser == 0) { %>
initial begin $assertoff(0, m_smi<%=i%>_rx_vif.assert_smi_msg_user_not_x_z); end
<% } %>

<% if(obj.DutInfo.interfaces.smiTxInt[0].params.wSmiDPUser == 0) { %>
initial begin $assertoff(0, m_smi<%=i%>_rx_vif.assert_smi_dp_user_not_x_z); end
<% } %>


<% } %>



<%  if(obj.INHOUSE_APB_VIP && obj.testBench=="chi_aiu") { %>
<%=obj.BlockId%>_apb_if apb_if();
<%}%>
<% if(obj.INHOUSE_APB_VIP && obj.testBench=="chi_aiu") { %>
 assign apb_if.clk = dut_clk;
 assign apb_if.rst_n = soft_rstn;
<% } %>

//Connectivity interleaving interface
<%=obj.BlockId%>_connectivity_if <%=obj.BlockId%>_connectivity_if();

//Q-channel interface
<%=obj.BlockId%>_q_chnl_if  m_q_chnl_if(tb_clk, tb_rst);

// interface to tap csr intrrupt signal
chi_aiu_csr_probe_if u_csr_probe_if(dut_clk,soft_rstn);

// interface to tap internal chi aiu dut signals
chi_aiu_dut_probe_if u_dut_probe_if(dut_clk,soft_rstn);

<%if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
    // interface to split the transaction into individual fields for debug purposes
    <%=obj.BlockId%>_chi_debug_if <%=obj.BlockId%>_u_chi_debug_if(dut_clk,soft_rstn);
<%}%>

uvm_event  toggle_clk;
uvm_event  toggle_rstn;

//Setup uvm_config_db
initial begin
  //uvm_config_db #(chi_rn_driver_vif)::set(.cntxt(null),
  //  .inst_name("uvm_test_top"),
  //  .field_name("chi_rn_driver_vif"),
  //  .value(m_chi_vif.rn_drv_mp)
  //);

  //uvm_config_db #(chi_rn_monitor_vif)::set(.cntxt(null),
  //  .inst_name("uvm_test_top"),
  //  .field_name("chi_rn_monitor_vif"),
  //  .value(m_chi_vif.rn_mon_mp)
  //);
<%  if(obj.INHOUSE_APB_VIP && obj.testBench=="chi_aiu") { %>
    uvm_config_db#(virtual <%=obj.BlockId%>_apb_if )::set(.cntxt( uvm_root::get()),
                                        .inst_name( "" ),
                                        .field_name( "apb_if" ),
                                        .value(apb_if ));

    uvm_config_db#(virtual <%=obj.BlockId%>_apb_if )::set(.cntxt( null ),
                                        .inst_name( "uvm_test_top.env.m_apb_agent.m_apb_driver" ),
                                        .field_name( "m_vif" ),
                                        .value(apb_if ));
<%}%>
  uvm_config_db#(virtual chi_aiu_csr_probe_if)::set(.cntxt( uvm_root::get() ),
                                        .inst_name( "*" ),
                                        .field_name( "u_csr_probe_if" ),
                                        .value( u_csr_probe_if ));

  uvm_config_db#(virtual chi_aiu_dut_probe_if)::set(.cntxt( uvm_root::get() ),
                                        .inst_name( "*" ),
                                        .field_name( "u_dut_probe_if" ),
                                        .value( u_dut_probe_if ));


  uvm_config_db#(virtual event_out_if )::set(.cntxt( uvm_root::get() ),
                                        .inst_name( "" ),
                                        .field_name( "u_event_out_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>"),
                                        .value( m_event_out_if_<%=obj.BlockId%>));

  //uvm_config_db #(virtual <%=obj.BlockId%>_chi_if)::set(
  //  .cntxt(null),
  //  .inst_name("uvm_test_top"),
  //  .field_name("chi_rn_vif"),
  //  .value(m_chi_vif)
  //);
    <% var chi_idx=0;
       var io_idx=0;
    %>
    <% for(var pidx = 0; pidx < initiatorAgents; pidx++) { %>
    <%  if(chi_idx == obj.Id && _child_blk[pidx] == "chiaiu") { %>
        uvm_config_db #(virtual <%=_child_blkid[pidx]%>_chi_if)::set(uvm_root::get(),"","chi_rn_vif",m_chi_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>);
    <% } %>
	<% chi_idx++; %>
    <% } %>

`ifdef USE_VIP_SNPS
  uvm_config_db#(svt_chi_vif)::set(uvm_root::get(),"uvm_test_top.env.amba_system_env.chi_system[0]", "vif", chi_if);
`endif // USE_VIP_SNPS

//SmiTx ports from TB prespective
<% for (var i = 0; i < obj.DutInfo.nSmiRx; i++) { %>
  uvm_config_db #(virtual <%=obj.BlockId%>_smi_if)::set(
    .cntxt(null),
    .inst_name("*"),
    .field_name("m_smi<%=i%>_tx_vif"),
    .value(m_smi<%=i%>_tx_vif)
  );
<% } %>

//SmiRxProts from TB prespective
<% for (var i = 0; i < obj.DutInfo.nSmiTx; i++) { %>
  uvm_config_db #(virtual <%=obj.BlockId%>_smi_if)::set(
    .cntxt(null),
    .inst_name("*"),
    .field_name("m_smi<%=i%>_rx_vif"),
    .value(m_smi<%=i%>_rx_vif)
  );
<% } %>

uvm_config_db#(virtual <%=obj.BlockId%>_q_chnl_if )::set(.cntxt( uvm_root::get()),
                                    .inst_name( "" ),
                                    .field_name( "m_q_chnl_if" ),
                                    .value(m_q_chnl_if ));
end

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
always @(posedge tb_clk) begin
    toggle_clk.wait_trigger();
    @(negedge tb_clk);
    $display("triggered toggle_clk_event @time: %0t",$time);
    enable = ~enable;
end

assign dut_clk = enable ? tb_clk : 0;

bit soft_rstn_en=1;
always @(posedge tb_clk) begin
    toggle_rstn.wait_trigger();
    @(negedge tb_clk);
    $display("treggered reset event @time: %0t",$time);
    soft_rstn_en = ~soft_rstn_en;
end

assign soft_rstn = soft_rstn_en ? tb_rst : 0;


<%=obj.moduleName%> dut(   
//aiu_top_0 dut(
//`ifdef USE_VIP_SNPS
//    .<%=obj.DutInfo.interfaces.chiInt.name%>sysco_req            (chi_if.rn_if[0].SYSCOREQ),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>sysco_ack            (chi_if.rn_if[0].SYSCOACK),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_link_active_req   (chi_if.rn_if[0].TXLINKACTIVEREQ),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_link_active_ack   (chi_if.rn_if[0].TXLINKACTIVEACK),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_link_active_req   (chi_if.rn_if[0].RXLINKACTIVEREQ),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_link_active_ack   (chi_if.rn_if[0].RXLINKACTIVEACK),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_req_flit_pend     (chi_if.rn_if[0].TXREQFLITPEND),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_req_flitv         (chi_if.rn_if[0].TXREQFLITV),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_req_flit          (chi_if.rn_if[0].TXREQFLIT),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_req_lcrdv         (chi_if.rn_if[0].TXREQLCRDV),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_rsp_flit_pend     (chi_if.rn_if[0].TXRSPFLITPEND),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_rsp_flitv         (chi_if.rn_if[0].TXRSPFLITV),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_rsp_flit          (chi_if.rn_if[0].TXRSPFLIT),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_rsp_lcrdv         (chi_if.rn_if[0].TXRSPLCRDV),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_dat_flit_pend     (chi_if.rn_if[0].TXDATFLITPEND),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_dat_flitv         (chi_if.rn_if[0].TXDATFLITV),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_dat_flit          (chi_if.rn_if[0].TXDATFLIT),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_dat_lcrdv         (chi_if.rn_if[0].TXDATLCRDV),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_snp_flit_pend     (chi_if.rn_if[0].RXSNPFLITPEND),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_snp_flitv         (chi_if.rn_if[0].RXSNPFLITV),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_snp_flit          (chi_if.rn_if[0].RXSNPFLIT),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_snp_lcrdv         (chi_if.rn_if[0].RXSNPLCRDV),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_rsp_flit_pend     (chi_if.rn_if[0].RXSNPFLITPEND),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_rsp_flitv         (chi_if.rn_if[0].RXSNPFLITV),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_rsp_flit          (chi_if.rn_if[0].RXSNPFLIT),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_rsp_lcrdv         (chi_if.rn_if[0].RXSNPLCRDV),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_dat_flit_pend     (chi_if.rn_if[0].RXDATFLITPEND),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_dat_flitv         (chi_if.rn_if[0].RXDATFLITV),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_dat_flit          (chi_if.rn_if[0].RXDATLCRDV),
//    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_dat_lcrdv         (chi_if.rn_if[0].RXDATLCRDV),
//`else  // USE_VIP_SNPS
    .<%=obj.DutInfo.interfaces.chiInt.name%>sysco_req            (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.sysco_req),
    .<%=obj.DutInfo.interfaces.chiInt.name%>sysco_ack            (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.sysco_ack),
    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_sactive           (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_sactive),
    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_sactive           (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_sactive),
    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_link_active_req   (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_link_active_req),
    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_link_active_ack   (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_link_active_ack),
    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_link_active_req   (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_link_active_req),
    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_link_active_ack   (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_link_active_ack),
    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_req_flit_pend     (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_req_flit_pend),
    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_req_flitv         (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_req_flitv),
    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_req_flit          (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_req_flit),
    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_req_lcrdv         (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_req_lcrdv),
    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_rsp_flit_pend     (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_rsp_flit_pend),
    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_rsp_flitv         (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_rsp_flitv),
    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_rsp_flit          (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_rsp_flit),
    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_rsp_lcrdv         (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_rsp_lcrdv),
    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_dat_flit_pend     (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_dat_flit_pend),
    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_dat_flitv         (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_dat_flitv),
    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_dat_flit          (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_dat_flit),
    .<%=obj.DutInfo.interfaces.chiInt.name%>rx_dat_lcrdv         (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_dat_lcrdv),
    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_snp_flit_pend     (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_snp_flit_pend),
    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_snp_flitv         (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_snp_flitv),
    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_snp_flit          (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_snp_flit),
    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_snp_lcrdv         (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_snp_lcrdv),
    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_rsp_flit_pend     (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_rsp_flit_pend),
    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_rsp_flitv         (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_rsp_flitv),
    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_rsp_flit          (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_rsp_flit),
    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_rsp_lcrdv         (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_rsp_lcrdv),
    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_dat_flit_pend     (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_dat_flit_pend),
    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_dat_flitv         (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_dat_flitv),
    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_dat_flit          (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_dat_flit),
    .<%=obj.DutInfo.interfaces.chiInt.name%>tx_dat_lcrdv         (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_dat_lcrdv),
    <%if (obj.DutInfo.interfaces.chiInt.params.checkType !== "NONE") {%>
        .<%=obj.DutInfo.interfaces.chiInt.name%>tx_sactive_chk            (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_sactive_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>rx_sactive_chk            (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_sactive_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>sysco_req_chk             (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.sysco_req_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>sysco_ack_chk             (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.sysco_ack_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>tx_link_active_req_chk    (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_link_active_req_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>tx_link_active_ack_chk    (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_link_active_ack_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>rx_link_active_req_chk    (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_link_active_req_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>rx_link_active_ack_chk    (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_link_active_ack_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>rx_req_flit_pend_chk      (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_req_flit_pend_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>rx_req_flitv_chk          (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_req_flitv_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>rx_req_flit_chk           (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_req_flit_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>rx_req_lcrdv_chk          (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_req_lcrdv_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>rx_rsp_flit_pend_chk      (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_rsp_flit_pend_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>rx_rsp_flitv_chk          (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_rsp_flitv_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>rx_rsp_flit_chk           (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_rsp_flit_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>rx_rsp_lcrdv_chk          (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_rsp_lcrdv_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>rx_dat_flit_pend_chk      (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_dat_flit_pend_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>rx_dat_flitv_chk          (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_dat_flitv_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>rx_dat_flit_chk           (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_dat_flit_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>rx_dat_lcrdv_chk          (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_dat_lcrdv_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>tx_rsp_flit_pend_chk      (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_rsp_flit_pend_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>tx_rsp_flitv_chk          (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_rsp_flitv_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>tx_rsp_flit_chk           (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_rsp_flit_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>tx_rsp_lcrdv_chk          (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_rsp_lcrdv_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>tx_dat_flit_pend_chk      (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_dat_flit_pend_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>tx_dat_flitv_chk          (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_dat_flitv_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>tx_dat_flit_chk           (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_dat_flit_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>tx_dat_lcrdv_chk          (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_dat_lcrdv_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>tx_snp_flit_pend_chk      (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_snp_flit_pend_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>tx_snp_flitv_chk          (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_snp_flitv_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>tx_snp_flit_chk           (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_snp_flit_chk),
        .<%=obj.DutInfo.interfaces.chiInt.name%>tx_snp_lcrdv_chk          (m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_snp_lcrdv_chk),
    <% } %>

//`endif // USE_VIP_SNPS

<%for (var i = 0; i < obj.DutInfo.nSmiTx; i++) { %>
.<%=obj.DutInfo.interfaces.smiTxInt[i].name%>ndp_msg_valid         (m_smi<%=i%>_rx_vif.smi_msg_valid ) ,
.<%=obj.DutInfo.interfaces.smiTxInt[i].name %>ndp_msg_ready        (m_smi<%=i%>_rx_vif.smi_msg_ready  ) ,
.<%=obj.DutInfo.interfaces.smiTxInt[i].name %>ndp_ndp_len          (m_smi<%=i%>_rx_vif.smi_ndp_len   ) ,
.<%=obj.DutInfo.interfaces.smiTxInt[i].name %>ndp_dp_present       (m_smi<%=i%>_rx_vif.smi_dp_present) ,
.<%=obj.DutInfo.interfaces.smiTxInt[i].name %>ndp_targ_id          (m_smi<%=i%>_rx_vif.smi_targ_id   ) ,
.<%=obj.DutInfo.interfaces.smiTxInt[i].name %>ndp_src_id           (m_smi<%=i%>_rx_vif.smi_src_id    ) ,
.<%=obj.DutInfo.interfaces.smiTxInt[i].name %>ndp_msg_id           (m_smi<%=i%>_rx_vif.smi_msg_id    ) ,
.<%=obj.DutInfo.interfaces.smiTxInt[i].name %>ndp_msg_type         (m_smi<%=i%>_rx_vif.smi_msg_type  ) ,
<% if(obj.DutInfo.interfaces.smiTxInt[i].params.wSmiUser >0) {%>
.<%=obj.DutInfo.interfaces.smiTxInt[i].name %>ndp_msg_user         (m_smi<%=i%>_rx_vif.smi_msg_user  ) ,
<% } %>
<% if(obj.DutInfo.interfaces.smiTxInt[i].params.wSmiTier >0) {%>
.<%=obj.DutInfo.interfaces.smiTxInt[i].name%>ndp_msg_tier          (m_smi<%=i%>_rx_vif.smi_msg_tier  ) ,
<% } %>
<% if(obj.DutInfo.interfaces.smiTxInt[i].params.wSmiSteer >0) {%>
.<%=obj.DutInfo.interfaces.smiTxInt[i].name%>ndp_steer             (m_smi<%=i%>_rx_vif.smi_steer     ) ,
<% } %>
<% if(obj.DutInfo.interfaces.smiTxInt[i].params.wSmiPri >0) {%>
.<%=obj.DutInfo.interfaces.smiTxInt[i].name%>ndp_msg_pri           (m_smi<%=i%>_rx_vif.smi_msg_pri   ) ,
<% } %>
<% if(obj.DutInfo.interfaces.smiTxInt[i].params.wSmiMsgQos >0) {%>
.<%=obj.DutInfo.interfaces.smiTxInt[i].name%>ndp_msg_qos           (m_smi<%=i%>_rx_vif.smi_msg_qos   ) ,
<% } %>
.<%=obj.DutInfo.interfaces.smiTxInt[i].name%>ndp_ndp               (m_smi<%=i%>_rx_vif.smi_ndp[<%=obj.DutInfo.interfaces.smiTxInt[i].params.wSmiNDP-1%>:0]) ,
<% if(obj.DutInfo.interfaces.smiTxInt[i].params.wSmiErr >0) {%>
.<%=obj.DutInfo.interfaces.smiTxInt[i].name%>ndp_msg_err           (m_smi<%=i%>_rx_vif.smi_msg_err   ) ,
<% } %>

    <%  if (obj.DutInfo.interfaces.smiTxInt[i].params.nSmiDPvc) { %>    
.<%=obj.DutInfo.interfaces.smiTxInt[i].name%>dp_valid              (m_smi<%=i%>_rx_vif.smi_dp_valid  ) ,
.<%=obj.DutInfo.interfaces.smiTxInt[i].name%>dp_ready              (m_smi<%=i%>_rx_vif.smi_dp_ready  ) ,
.<%=obj.DutInfo.interfaces.smiTxInt[i].name%>dp_last               (m_smi<%=i%>_rx_vif.smi_dp_last   ) ,
.<%=obj.DutInfo.interfaces.smiTxInt[i].name%>dp_data               (m_smi<%=i%>_rx_vif.smi_dp_data   ) ,
<% if(obj.DutInfo.interfaces.smiTxInt[i].params.wSmiDPuser >0) {%>
.<%=obj.DutInfo.interfaces.smiTxInt[i].name%>dp_user               (m_smi<%=i%>_rx_vif.smi_dp_user[<%=obj.DutInfo.interfaces.smiTxInt[i].params.wSmiDPuser-1%>:0]   ) ,
<% } %>

    <% } %>
<% } %>
<%for (var i = 0; i < obj.DutInfo.nSmiRx; i++) { %>
.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>ndp_msg_valid         (m_smi<%=i%>_tx_vif.smi_msg_valid ) ,
.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>ndp_msg_ready         (m_smi<%=i%>_tx_vif.smi_msg_ready ) ,
.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>ndp_ndp_len           (m_smi<%=i%>_tx_vif.smi_ndp_len   ) ,
.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>ndp_dp_present        (m_smi<%=i%>_tx_vif.smi_dp_present) ,
.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>ndp_targ_id           (m_smi<%=i%>_tx_vif.smi_targ_id   ) ,
.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>ndp_src_id            (m_smi<%=i%>_tx_vif.smi_src_id    ) ,
.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>ndp_msg_id            (m_smi<%=i%>_tx_vif.smi_msg_id    ) ,
.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>ndp_msg_type          (m_smi<%=i%>_tx_vif.smi_msg_type  ) ,
<% if(obj.DutInfo.interfaces.smiRxInt[i].params.wSmiUser >0) {%>
.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>ndp_msg_user          (m_smi<%=i%>_tx_vif.smi_msg_user  ) ,
<% } %>
<% if(obj.DutInfo.interfaces.smiRxInt[i].params.wSmiTier >0) {%>
.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>ndp_msg_tier          (m_smi<%=i%>_tx_vif.smi_msg_tier  ) ,
<% } %>
<% if(obj.DutInfo.interfaces.smiRxInt[i].params.wSmiSteer >0) {%>
.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>ndp_steer             (m_smi<%=i%>_tx_vif.smi_steer     ) ,
<% } %>
<% if(obj.DutInfo.interfaces.smiRxInt[i].params.wSmiPri >0) {%>
.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>ndp_msg_pri           (m_smi<%=i%>_tx_vif.smi_msg_pri   ) ,
<% } %>
<% if(obj.DutInfo.interfaces.smiRxInt[i].params.wSmiMsgQos >0) {%>
.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>ndp_msg_qos           (m_smi<%=i%>_tx_vif.smi_msg_qos   ) ,
<% } %>
.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>ndp_ndp               (m_smi<%=i%>_tx_vif.smi_ndp[<%=obj.DutInfo.interfaces.smiRxInt[i].params.wSmiNDP-1%>:0]       ) ,
<% if(obj.DutInfo.interfaces.smiRxInt[i].params.wSmiErr >0) {%>
.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>ndp_msg_err           (m_smi<%=i%>_tx_vif.smi_msg_err   ) ,
<% } %>
    <%  if (obj.DutInfo.interfaces.smiRxInt[i].params.nSmiDPvc) { %>    
.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>dp_valid              (m_smi<%=i%>_tx_vif.smi_dp_valid  ) ,
.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>dp_ready              (m_smi<%=i%>_tx_vif.smi_dp_ready  ) ,
.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>dp_last               (m_smi<%=i%>_tx_vif.smi_dp_last   ) ,
.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>dp_data               (m_smi<%=i%>_tx_vif.smi_dp_data   ) ,
<% if(obj.DutInfo.interfaces.smiRxInt[i].params.wSmiDPuser >0) {%>
.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>dp_user               (m_smi<%=i%>_tx_vif.smi_dp_user[<%=obj.DutInfo.interfaces.smiRxInt[i].params.wSmiDPuser-1%>:0]   ) ,
<% } %>
    <% } %>
<% } %>
    .<%=obj.DutInfo.interfaces.clkInt.name%>clk                      (dut_clk),
    .<%=obj.DutInfo.interfaces.clkInt.name%>reset_n                  (soft_rstn),
    .<%=obj.DutInfo.interfaces.clkInt.name%>test_en                  ('h0),
    .<%=obj.DutInfo.interfaces.uIdInt.name%>my_f_unit_id         (<%=obj.DutInfo.FUnitId%>),
    .<%=obj.DutInfo.interfaces.uIdInt.name%>my_n_unit_id         (<%=obj.DutInfo.nUnitId%>),
    .<%=obj.DutInfo.interfaces.uIdInt.name%>my_csr_rpn           (<%=obj.DutInfo.rpn%>) ,
    .<%=obj.DutInfo.interfaces.uIdInt.name%>my_csr_nrri          (<%=obj.DutInfo.nrri%>) ,
    .<%=obj.DutInfo.interfaces.uSysDceIdInt.name%>f_unit_id        (DCE_FUNIT_IDS),
    .<%=obj.DutInfo.interfaces.uSysDveIdInt.name%>f_unit_id        (DVE_FUNIT_IDS),
    .<%=obj.DutInfo.interfaces.uSysDmiIdInt.name%>f_unit_id        (DMI_FUNIT_IDS),
    .<%=obj.DutInfo.interfaces.uSysDiiIdInt.name%>f_unit_id        (DII_FUNIT_IDS),
    .<%=obj.DutInfo.interfaces.uSysCAiuIdInt.name%>f_unit_id        (CACHING_AIU_FUNIT_IDS),
    .<%=obj.DutInfo.interfaces.uSysDceIdInt.name%>connectivity      (<%=obj.BlockId%>_connectivity_if.AiuDce_connectivity_vec),  //#Stimulus.CHIAIU.v3.4.Connectivity.UnconnectedDce
    .<%=obj.DutInfo.interfaces.uSysDmiIdInt.name%>connectivity      (<%=obj.BlockId%>_connectivity_if.AiuDmi_connectivity_vec),  //#Stimulus.CHIAIU.v3.4.Connectivity.UnconnectedDmi
    .<%=obj.DutInfo.interfaces.uSysDiiIdInt.name%>connectivity      (<%=obj.BlockId%>_connectivity_if.AiuDii_connectivity_vec),  //#Stimulus.CHIAIU.v3.4.Connectivity.UnconnectedDii

    .<%=obj.DutInfo.interfaces.uSysConnectedDceIdInt.name%>f_unit_id    (<%=obj.BlockId%>_connectivity_if.AiuConnectedDceFunitId),
    .<%=obj.DutInfo.interfaces.uSysConnectedDceIdInt.name%>connectivity (<%=obj.BlockId%>_connectivity_if.AiuDce_connectivity_vec),


<%  if(obj.INHOUSE_APB_VIP && obj.testBench=="chi_aiu") { %>
    .<%=obj.DutInfo.interfaces.apbInt.name%>paddr	(apb_if.paddr[<%=obj.DutInfo.interfaces.apbInt.params.wAddr-1%>:0]),	
    .<%=obj.DutInfo.interfaces.apbInt.name%>psel	(apb_if.psel),	
    .<%=obj.DutInfo.interfaces.apbInt.name%>penable	(apb_if.penable),
    .<%=obj.DutInfo.interfaces.apbInt.name%>pwrite	(apb_if.pwrite),
    .<%=obj.DutInfo.interfaces.apbInt.name%>pwdata	(apb_if.pwdata),
    .<%=obj.DutInfo.interfaces.apbInt.name%>pready	(apb_if.pready),
    .<%=obj.DutInfo.interfaces.apbInt.name%>prdata	(apb_if.prdata),
    .<%=obj.DutInfo.interfaces.apbInt.name%>pslverr	(apb_if.pslverr),
<%  if(obj.DutInfo.interfaces.apbInt.params.wProt !== 0) { %>
    .<%=obj.DutInfo.interfaces.apbInt.name%>pprot       (apb_if.pprot),
<% } %>
<%  if(obj.DutInfo.interfaces.apbInt.params.wStrb !== 0) { %>
    .<%=obj.DutInfo.interfaces.apbInt.name%>pstrb       (apb_if.pstrb),
<% } %>
<% } %>

//Q-channel interface connection
<%  if(obj.DutInfo.usePma) { %>

    .q_ACTIVE       (m_q_chnl_if.QACTIVE ) ,
    .q_DENY         (m_q_chnl_if.QDENY   ) ,
    .q_REQn         (m_q_chnl_if.QREQn   ) ,
    .q_ACCEPTn      (m_q_chnl_if.QACCEPTn) ,

<% } %>

//event interface connection
    .<%=obj.DutInfo.interfaces.eventRequestOutInt.name%>req	(m_event_out_if_<%=obj.BlockId%>.in),
    .<%=obj.DutInfo.interfaces.eventRequestOutInt.name%>ack	(m_event_out_if_<%=obj.BlockId%>.out),
    `ifdef FORCE_SENDER
    .<%=obj.DutInfo.interfaces.eventRequestInInt.name%>ack	(m_event_out_if_<%=obj.BlockId%>.sys_req_event_ack),
    .<%=obj.DutInfo.interfaces.eventRequestInInt.name%>req	(m_event_out_if_<%=obj.BlockId%>.sys_req_event_in),
    `else
    .<%=obj.DutInfo.interfaces.eventRequestInInt.name%>ack	(),
    .<%=obj.DutInfo.interfaces.eventRequestInInt.name%>req	(1'b0),
    `endif //FORCE_SENDER
  


<% if(obj.useResiliency) { %>
    //TODO resiliency if ******************************************
<% if(obj.AiuInfo[obj.Id].ResilienceInfo.enableUnitDuplication) { %> 
    .<%=obj.DutInfo.interfaces.checkClkInt.name%>clk      (dut_clk),
//    .<%=obj.DutInfo.interfaces.checkClkInt.name%>reset_n  (soft_rstn),
    .<%=obj.DutInfo.interfaces.checkClkInt.name%>test_en  ('h0),
<% } %>
<% if (!obj.DutInfo.interfaces.bistDebugDisableInt._SKIP_) { %>
    .<%=obj.DutInfo.interfaces.bistDebugDisableInt.name%>pin     ('h1),
<% } %>
     .bist_bist_next(1'b0),
     .bist_bist_next_ack(bist_bist_next_ack),
     .bist_domain_is_on(bist_domain_is_on),
     .fault_mission_fault(fault_mission_fault),
     .fault_latent_fault(fault_latent_fault),
     .fault_cerr_over_thres_fault(fault_cerr_over_thres_fault),
<% } %>
  // PERF MON MASTER ENABLE
  .trigger_trigger(<%=obj.BlockId%>_sb_stall_if.master_cnt_enable),

    .<%=obj.DutInfo.interfaces.irqInt.name%>uc		(irq_uc),
    .<%=obj.DutInfo.interfaces.irqInt.name%>c        	(irq_c)

//    .aiu_caiu_f_unit_id       (CACHING_AIU_FUNIT_IDS)

//    .MyId                     (<%=obj.DutInfo.FUnitId%>),
//    .MyNId                    ('h0)
);

//TODO FIXME

//<% for (var i = 0; i < obj.DutInfo.nSmiRx; i++) { %>
//  assign m_smi<%=i%>_tx_vif.smi_msg_err = 'h0;
//<% } %>

//<% for (var i = 0; i < obj.DutInfo.nSmiTx; i++) { %>
//  assign m_smi<%=i%>_rx_vif.smi_msg_err = 'h0;
//<% } %>
//

assign u_csr_probe_if.IRQ_C = irq_c;
assign u_csr_probe_if.IRQ_UC = irq_uc;
<% if(obj.useResiliency) { %>
       assign u_csr_probe_if.fault_mission_fault = tb_top.dut.fault_mission_fault;
       assign u_csr_probe_if.fault_latent_fault  = tb_top.dut.fault_latent_fault;
       assign u_csr_probe_if.cerr_threshold          = tb_top.dut.u_chi_aiu_fault_checker.cerr_threshold;
       assign u_csr_probe_if.cerr_counter            = tb_top.dut.u_chi_aiu_fault_checker.cerr_counter;
       assign u_csr_probe_if.cerr_over_thres_fault   = tb_top.dut.u_chi_aiu_fault_checker.cerr_over_thres_fault;
<% } %>

//Connectivity if to DUT connection
assign <%=obj.BlockId%>_connectivity_if.clk       = dut_clk;
assign <%=obj.BlockId%>_connectivity_if.rst_n     = soft_rstn;
assign <%=obj.BlockId%>_connectivity_if.ott_busy  = tb_top.dut.unit.ott_busy;

////perf counter :stall_if to dut connection 
assign <%=obj.BlockId%>_sb_stall_if.clk = dut_clk;
assign <%=obj.BlockId%>_sb_stall_if.rst_n = soft_rstn;
<%if(obj.nPerfCounters) { %> 
assign <%=obj.BlockId%>_sb_stall_if.trace_capture_busy = tb_top.dut.unit.trace_capture_busy;
assign <%=obj.BlockId%>_sb_stall_if.ott_busy = tb_top.dut.unit.ott_busy;
<%}%> 

//CHI Event Registers
assign m_event_out_if_<%=obj.BlockId%>.event_receiver_enable    = ~tb_top.dut.unit.chi_aiu_csr.CAIUTCR_EventDisable_out;
assign m_event_out_if_<%=obj.BlockId%>.timeout_threshold 		    = tb_top.dut.unit.chi_aiu_csr.CAIUTOCR_TimeOutThreshold_out[30:0];
assign m_event_out_if_<%=obj.BlockId%>.uedr_timeout_err_det_en 	= tb_top.dut.unit.chi_aiu_csr.CAIUUEDR_TimeoutErrDetEn_out;
assign m_event_out_if_<%=obj.BlockId%>.uesr_errvld 				      = tb_top.dut.unit.chi_aiu_csr.CAIUUESR_ErrVld_out;
assign m_event_out_if_<%=obj.BlockId%>.uesr_err_type 			      = tb_top.dut.unit.chi_aiu_csr.CAIUUESR_ErrType_out[3:0];
assign m_event_out_if_<%=obj.BlockId%>.uesr_err_info 			      = tb_top.dut.unit.chi_aiu_csr.CAIUUESR_ErrInfo_out[15:0];
assign m_event_out_if_<%=obj.BlockId%>.ueir_timeout_irq_en 		  = tb_top.dut.unit.chi_aiu_csr.CAIUUEIR_TimeOutErrIntEn_out;
assign m_event_out_if_<%=obj.BlockId%>.sysco_attach 		        = tb_top.dut.unit.chi_aiu_csr.CAIUTAR_SysCoAttached_out;
assign m_event_out_if_<%=obj.BlockId%>.sysco_connecting         = !tb_top.dut.unit.co_state_disabled; // this signal is equivalent to sysco_connecting for the events purposes
assign m_event_out_if_<%=obj.BlockId%>.IRQ_UC 					        = tb_top.dut.irq_uc;
assign m_event_out_if_<%=obj.BlockId%>.idle_or_done             = tb_top.dut.unit.u_sys_evt_coh_concerto.u_sys_evt_coh_wrapper.u_sys_evt_receiver.next_state_is_IDLE_or_DONE;
// assign m_event_out_if_<%=obj.BlockId%>.receiver_busy            = tb_top.dut.unit.u_sys_evt_coh_concerto.u_sys_evt_coh_wrapper.u_sys_evt_receiver.evt_receiver_busy;
assign m_event_out_if_<%=obj.BlockId%>.sys_receiver_busy            = tb_top.dut.unit.u_sys_evt_coh_concerto.u_sys_evt_coh_wrapper.u_sys_evt_receiver.evt_receiver_busy;
always @(posedge tb_top.dut.unit.u_sys_evt_coh_concerto.u_sys_evt_coh_wrapper.u_sys_coh_sender.protocol_timeout) begin
  if ($test$plusargs("SYSrsp_time_out_test")) begin
    ev_csr_test_time_out_SYSrsp.trigger(null);
  end
end

<%if(obj.nPerfCounters) { %> 
// SMI TX
<%for (var i = 0; i < obj.DutInfo.nSmiTx; i++) { %>
<%  if (obj.DutInfo.interfaces.smiTxInt[i].params.nSmiDPvc) { %>  
assign <%=obj.BlockId%>_sb_stall_if.smi_tx<%=i%>_valid = dut.<%=obj.DutInfo.interfaces.smiTxInt[i].name%>dp_valid;       
assign <%=obj.BlockId%>_sb_stall_if.smi_tx<%=i%>_ready = dut.<%=obj.DutInfo.interfaces.smiTxInt[i].name%>dp_ready;     
<% } else { %>
assign <%=obj.BlockId%>_sb_stall_if.smi_tx<%=i%>_valid = dut.<%=obj.DutInfo.interfaces.smiTxInt[i].name%>ndp_msg_valid;       
assign <%=obj.BlockId%>_sb_stall_if.smi_tx<%=i%>_ready = dut.<%=obj.DutInfo.interfaces.smiTxInt[i].name%>ndp_msg_ready;     
<% } %> 
<% } %>
// SMI RX
<%for (var i = 0; i < obj.DutInfo.nSmiRx; i++) { %>
  <%  if (obj.DutInfo.interfaces.smiRxInt[i].params.nSmiDPvc) { %>  
assign <%=obj.BlockId%>_sb_stall_if.smi_rx<%=i%>_valid = dut.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>dp_valid;
assign <%=obj.BlockId%>_sb_stall_if.smi_rx<%=i%>_ready = dut.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>dp_ready;
assign (supply0, supply1) dut.<%=obj.DutInfo.interfaces.smiRxInt[i].name %>dp_valid = m_smi<%=i%>_tx_vif.force_smi_msg_valid;
assign (supply0, supply1) dut.<%=obj.DutInfo.interfaces.smiRxInt[i].name %>dp_ready = m_smi<%=i%>_tx_vif.force_smi_msg_ready;  

<% } else { %>
assign <%=obj.BlockId%>_sb_stall_if.smi_rx<%=i%>_valid = dut.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>ndp_msg_valid;
assign <%=obj.BlockId%>_sb_stall_if.smi_rx<%=i%>_ready = dut.<%=obj.DutInfo.interfaces.smiRxInt[i].name%>ndp_msg_ready;
assign (supply0, supply1) dut.<%=obj.DutInfo.interfaces.smiRxInt[i].name %>ndp_msg_valid = m_smi<%=i%>_tx_vif.force_smi_msg_valid;
assign (supply0, supply1) dut.<%=obj.DutInfo.interfaces.smiRxInt[i].name %>ndp_msg_ready = m_smi<%=i%>_tx_vif.force_smi_msg_ready;      
<% } %> 
<% } %>

<%for (var i = 0; i < obj.nPerfCounters; i++) { %>
assign <%=obj.BlockId%>_sb_stall_if.cnt_reg_capture[<%=i%>].cnt_v =  dut.unit.chi_aiu_csr.CAIUCNTVR<%=i%>_CountVal_out ;  
assign <%=obj.BlockId%>_sb_stall_if.cnt_reg_capture[<%=i%>].cnt_v_str =  dut.unit.chi_aiu_csr.CAIUCNTSR<%=i%>_CountSatVal_out;      
<% } %>

/////////////////////////////////// CHI BW events //////////////////////////////////////////////////
  //cmd_req_wr event
assign <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sb_stall_if.cmd_req_wr_valid = 
dut.<%=obj.DutInfo.interfaces.smiTxInt[0].name%>ndp_msg_valid &&
(dut.<%=obj.DutInfo.interfaces.smiTxInt[0].name%>ndp_msg_type inside 
{CMD_WR_EVICT,CMD_WR_CLN_PTL,CMD_WR_CLN_FULL,CMD_WR_UNQ_PTL,CMD_WR_UNQ_FULL,CMD_WR_BK_PTL,CMD_WR_BK_FULL,CMD_WR_NC_PTL,CMD_WR_NC_FULL,CMD_WR_STSH_PTL,CMD_WR_STSH_FULL});

assign <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sb_stall_if.cmd_req_wr_ready = dut.<%=obj.DutInfo.interfaces.smiTxInt[0].name%>ndp_msg_ready; 
assign <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sb_stall_if.cmd_req_wr_funit_id_if = (dut.<%=obj.DutInfo.interfaces.smiTxInt[0].name%>ndp_targ_id >> WSMINCOREPORTID); 
<% if(obj.DutInfo.interfaces.smiTxInt[0].params.wSmiUser >0) {%> 
assign <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sb_stall_if.cmd_req_wr_user_bits_if = dut.<%=obj.DutInfo.interfaces.smiTxInt[0].name%>ndp_ndp[CMD_REQ_NDP_AUX_MSB:CMD_REQ_NDP_AUX_LSB];
<% } %>

//cmd_req_rd event
assign <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sb_stall_if.cmd_req_rd_valid = 
dut.<%=obj.DutInfo.interfaces.smiTxInt[0].name%>ndp_msg_valid &&
(dut.<%=obj.DutInfo.interfaces.smiTxInt[0].name%>ndp_msg_type inside
{CMD_RD_CLN,CMD_RD_NOT_SHD,CMD_RD_VLD,CMD_RD_UNQ,CMD_RD_NITC,CMD_RD_NC,CMD_RD_NITC_CLN_INV,CMD_RD_NITC_MK_INV});

assign <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sb_stall_if.cmd_req_rd_ready = dut.<%=obj.DutInfo.interfaces.smiTxInt[0].name%>ndp_msg_ready; 
assign <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sb_stall_if.cmd_req_rd_funit_id_if = (dut.<%=obj.DutInfo.interfaces.smiTxInt[0].name%>ndp_targ_id >> WSMINCOREPORTID);
<% if(obj.DutInfo.interfaces.smiTxInt[0].params.wSmiUser >0) {%>
assign <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sb_stall_if.cmd_req_rd_user_bits_if = dut.<%=obj.DutInfo.interfaces.smiTxInt[0].name%>ndp_ndp[CMD_REQ_NDP_AUX_MSB:CMD_REQ_NDP_AUX_LSB];
<% } %>

//snp_rsp event
assign <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sb_stall_if.snp_rsp_valid =
dut.<%=obj.DutInfo.interfaces.smiTxInt[1].name%>ndp_msg_valid && (dut.<%=obj.DutInfo.interfaces.smiTxInt[1].name%>ndp_msg_type == SNP_RSP);

assign <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sb_stall_if.snp_rsp_ready = dut.<%=obj.DutInfo.interfaces.smiTxInt[1].name%>ndp_msg_ready;
assign <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sb_stall_if.snp_rsp_funit_id_if = (dut.<%=obj.DutInfo.interfaces.smiTxInt[1].name%>ndp_targ_id >> WSMINCOREPORTID) ;
<% if(obj.DutInfo.interfaces.smiTxInt[1].params.wSmiUser >0) {%>
assign <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sb_stall_if.snp_rsp_user_bits_if = 0; // dut.<%=obj.DutInfo.interfaces.smiTxInt[1].name%>ndp_ndp[CMD_REQ_NDP_AUX_MSB:CMD_REQ_NDP_AUX_LSB];
<% } %>

/////////////////////////////////// CHI Latency spies //////////////////////////////////////////////////
assign <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sb_latency_if.clk                  =   dut_clk;
assign <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sb_latency_if.rst_n                =   soft_rstn;
assign <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sb_latency_if.alloc_if             =   dut.unit.u_ncr_pmon.latency_counter_in_alloc;
assign <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sb_latency_if.dealloc_if           =   dut.unit.u_ncr_pmon.latency_counter_in_dealloc;
assign <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sb_latency_if.dut_latency_bins     =   dut.unit.u_ncr_pmon.latency_bins;
assign <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sb_latency_if.div_clk_rtl          =   dut.unit.u_ncr_pmon.latency_counter_table.divevt_clk;
assign <%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>_sb_latency_if.local_count_enable   =   dut.unit.chi_aiu_csr.CAIUMCNTCR_LocalCountEnable_out;
<%}%> 

<%if(obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E'){%>
    // Assign signals to debug interface
    assign <%=obj.BlockId%>_u_chi_debug_if.rx_req_flit          = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_req_flit;
    assign <%=obj.BlockId%>_u_chi_debug_if.rx_req_flitv         = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_req_flitv;
    assign <%=obj.BlockId%>_u_chi_debug_if.rx_req_lcrdv         = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_req_lcrdv;
    assign <%=obj.BlockId%>_u_chi_debug_if.rx_rsp_flit_pend     = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_rsp_flit_pend;
    assign <%=obj.BlockId%>_u_chi_debug_if.rx_rsp_flitv         = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_rsp_flitv;
    assign <%=obj.BlockId%>_u_chi_debug_if.rx_rsp_flit          = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_rsp_flit;
    assign <%=obj.BlockId%>_u_chi_debug_if.rx_rsp_lcrdv         = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_rsp_lcrdv;
    assign <%=obj.BlockId%>_u_chi_debug_if.rx_dat_flit_pend     = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_dat_flit_pend;
    assign <%=obj.BlockId%>_u_chi_debug_if.rx_dat_flitv         = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_dat_flitv;
    assign <%=obj.BlockId%>_u_chi_debug_if.rx_dat_flit          = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_dat_flit;
    assign <%=obj.BlockId%>_u_chi_debug_if.rx_dat_lcrdv         = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_dat_lcrdv;
    assign <%=obj.BlockId%>_u_chi_debug_if.tx_snp_flit_pend     = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_snp_flit_pend;
    assign <%=obj.BlockId%>_u_chi_debug_if.tx_snp_flitv         = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_snp_flitv;
    assign <%=obj.BlockId%>_u_chi_debug_if.tx_snp_flit          = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_snp_flit;
    assign <%=obj.BlockId%>_u_chi_debug_if.tx_snp_lcrdv         = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_snp_lcrdv;
    assign <%=obj.BlockId%>_u_chi_debug_if.tx_rsp_flit_pend     = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_rsp_flit_pend;
    assign <%=obj.BlockId%>_u_chi_debug_if.tx_rsp_flitv         = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_rsp_flitv;
    assign <%=obj.BlockId%>_u_chi_debug_if.tx_rsp_flit          = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_rsp_flit;
    assign <%=obj.BlockId%>_u_chi_debug_if.tx_rsp_lcrdv         = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_rsp_lcrdv;
    assign <%=obj.BlockId%>_u_chi_debug_if.tx_dat_flit_pend     = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_dat_flit_pend;
    assign <%=obj.BlockId%>_u_chi_debug_if.tx_dat_flitv         = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_dat_flitv;
    assign <%=obj.BlockId%>_u_chi_debug_if.tx_dat_flit          = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_dat_flit;
    assign <%=obj.BlockId%>_u_chi_debug_if.tx_dat_lcrdv         = m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_dat_lcrdv;
<%}%>

//SPEC:ACE STALL dose not plly for CHI AIU 
////end stall if connections 
//Test call
initial begin
    $timeformat(-9,0,"ns",0);
    `ifdef DUMP_ON
        if($test$plusargs("en_dump")) begin
            <%  if(obj.SYS_CDNS_ACE_VIP) { %>
                $shm_open("waves.shm");
                $shm_probe("AS");
            <%  } else { %>
                $vcdpluson;
            <%  } %>
        end
    `endif
    run_test();
    $finish;
end

<% if(obj.useResiliency) { %>
 placeholder_connectivity_checker placeholder_connec_chk(dut_clk, soft_rstn);
 fault_injector_checker fault_inj_check(dut_clk, soft_rstn);
 initial begin
<% if(obj.testBench == 'chi_aiu') { %>
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
`endif // `ifndef VCS
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
 end

 ////TODO FIXME inject error in which IF?
 //assign smi_req_addr_modified = smi_if.smi_addr ^ slv_req_corruption_vector;
 //assign smi_req_data_modified = smi_if.smi_dp_data ^ slv_data_corruption_vector;
<% } %>
initial begin
  //perf counter
  uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::set(       null, "", "<%=obj.BlockId%>_0_m_top_stall_if",  <%=obj.BlockId%>_sb_stall_if); 
  uvm_config_db#(virtual <%=obj.BlockId%>_latency_if)::set(     null, "", "<%=obj.BlockId%>_m_top_latency_if",  <%=obj.BlockId%>_sb_latency_if); 
  uvm_config_db#(virtual <%=obj.BlockId%>_connectivity_if)::set(null, "", "<%=obj.BlockId%>_connectivity_if",   <%=obj.BlockId%>_connectivity_if); 
end


initial begin
    if ($test$plusargs("force_overflow_count")) begin
        force {tb_top.dut.unit.chi_aiu_csr.chi_aiu_csr_gen.u_CAIUQOSSR.reg_out_dffre.q[17:2]} = 16'd65535;
        @(posedge tb_top.dut.unit.chi_aiu_csr.chi_aiu_csr_gen.u_CAIUQOSSR.reg_out_dffre.reset_n);
        release {tb_top.dut.unit.chi_aiu_csr.chi_aiu_csr_gen.u_CAIUQOSSR.reg_out_dffre.q[17:2]};
    end
end

<% if(obj.AiuInfo[obj.Id].ResilienceInfo.enableUnitDuplication) { %>
initial begin
    if ($test$plusargs("force_overflow_count")) begin
        force {tb_top.dut.dup_unit.chi_aiu_csr.chi_aiu_csr_gen.u_CAIUQOSSR.reg_out_dffre.q[17:2]} = 16'd65535;
        @(posedge tb_top.dut.dup_unit.chi_aiu_csr.chi_aiu_csr_gen.u_CAIUQOSSR.reg_out_dffre.reset_n);
        release {tb_top.dut.dup_unit.chi_aiu_csr.chi_aiu_csr_gen.u_CAIUQOSSR.reg_out_dffre.q[17:2]};
    end
end
<% } %>

always @ (<%=obj.BlockId%>_connectivity_if.force_rst_n) begin
  if(<%=obj.BlockId%>_connectivity_if.force_rst_n) begin
    tb_rst = 0;
    repeat (10)
      @(posedge dut_clk);
    #1ns;
    tb_rst = 1;
    <%=obj.BlockId%>_connectivity_if.force_rst_n = 0;
  end
end

//rst logic
initial begin
  tb_rst <= 0;
  #1ns;
  tb_rst <= 0;
  repeat (2)
    @(posedge dut_clk);

  #1ns;
  tb_rst <= 0;
  repeat (10)
    @(posedge dut_clk);
  #1ns;
  tb_rst <= 1;
end

//Clock logic
initial begin
  tb_clk <= 0;
  forever
    #(<%=obj.Clocks[0].params.period%>ps/2) tb_clk = ~tb_clk;
end


<% if(!obj.CUSTOMER_ENV) { %>
//Task calls end of simulation and pending transaction methods
task assert_error(input string verbose, input string msg);
  uvm_component  m_comp[$];
  chi_aiu_scb    m_scb;

  //uvm_top.find_all("uvm_test_top.env.m_scb", m_comp, uvm_top); 
  //if(m_comp.size() == 0) 
  //    `uvm_fatal("tb_top", "none of the components are found with specified name");
  //if(m_comp.size() > 1) begin
  //    foreach(m_comp[i]) 
  //        `uvm_info("tb_top", $psprintf("component: %s", m_comp[i].get_full_name()), UVM_LOW);
  //    `uvm_fatal("tb_top", "multiple components with same name are found, components are specified above");
  //end

  //if($cast(m_scb, m_comp[0])) begin
  //    //anippuleti TODO
  //    //m_scb.check_queues();
  //end else 
  //    `uvm_fatal("tb_top", "unable to cast, maybe the hierarchical reference to tb specific scoreboard is changed");

  if(verbose == "FATAL") begin 
      `uvm_fatal("assert_error", msg); 
  end else begin 
      `uvm_error("assert_error", msg); 
  end
endtask: assert_error
<% } %>

`ifdef CHI_ARM_ASSERT_ON
Chi5PC_if #(.MAX_OS_REQ(32),
  .MAX_OS_SNP(16),
  .MAX_OS_EXCL(8),
  .numChi5nodes(6),
  .nodeIdQ('{0,1,2,4,8,16}),
  .NODE_ID(2)
//  .NODE_TYPE(Chi5PC_pkg::RNF),
//  .devQ('{Chi5PC_pkg::HNF, // 0
//          Chi5PC_pkg::SNF, // 1
//          Chi5PC_pkg::SNI, // 2
//          Chi5PC_pkg::SNF, // 4
//          Chi5PC_pkg::SNI, // 8
//          Chi5PC_pkg::HNI}), // 16
//  .DAT_FLIT_WIDTH(Chi5PC_pkg::CHI5PC_DAT_128B)
) CHI5PCInt(
  .SRESETn(soft_rstn),
  .TXREQFLITV(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_req_flitv),
  .TXREQFLIT(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_req_flit),
  .TXREQLCRDV(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_req_lcrdv),
  .RXREQFLITV(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_req_flitv),
  .RXREQFLIT(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_req_flit),
  .RXREQLCRDV(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_req_lcrdv),
  .TXDATFLITV(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_dat_flitv),
  .TXDATFLIT(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_dat_flit),
  .TXDATLCRDV(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_dat_lcrdv),
  .RXDATFLITV(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_dat_flitv),
  .RXDATFLIT(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_dat_flit),
  .RXDATLCRDV(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_dat_lcrdv),
  //.TXSNPFLITV(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.),
  //.TXSNPFLIT(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.),
  //.TXSNPLCRDV(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.),
  .RXSNPFLITV(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_snp_flitv),
  .RXSNPFLIT(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_snp_flit),
  .RXSNPLCRDV(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_snp_lcrdv),
  .TXRSPFLITV(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_rsp_flitv),
  .TXRSPFLIT(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_rsp_flit),
  .TXRSPLCRDV(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_rsp_lcrdv),
  .RXRSPFLITV(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_rsp_flitv),
  .RXRSPFLIT(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_rsp_flit),
  .RXRSPLCRDV(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_rsp_lcrdv),
  .TXLINKACTIVEREQ(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_link_active_req),
  .TXLINKACTIVEACK(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_link_active_ack),
  .RXLINKACTIVEREQ(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_link_active_req),
  .RXLINKACTIVEACK(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_link_active_ack),
  .TXREQFLITPEND(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_req_flit_pend),
  .RXREQFLITPEND(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_req_flit_pend),
  .TXRSPFLITPEND(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_rsp_flit_pend),
  .RXRSPFLITPEND(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_rsp_flit_pend),
  .TXDATFLITPEND(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_dat_flit_pend),
  .RXDATFLITPEND(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_dat_flit_pend),
  //.TXSNPFLITPEND(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.),
  .RXSNPFLITPEND(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_snp_flit_pend),
  .TXSACTIVE(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.tx_sactive),
  .RXSACTIVE(m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_sactive) //FIXME: Missing signal in AIU RTL m_chi_if_<%=obj.AiuInfo[obj.Id].strRtlNamePrefix%>.rx_sactive) //CHI protocol section 13.7.3
);
//  logic [31:0] BroadcastVector;
//----------------------------------------
//  logic [`CHI5PC_REQ_FLIT_RANGE] TXREQFLIT;
//  logic [`CHI5PC_REQ_FLIT_RANGE] RXREQFLIT;
//  logic [DAT_FLIT_WIDTH-1:0] TXDATFLIT;
//  logic [DAT_FLIT_WIDTH-1:0] RXDATFLIT;
//  logic [`CHI5PC_SNP_FLIT_RANGE] TXSNPFLIT;
//  logic [`CHI5PC_SNP_FLIT_RANGE] RXSNPFLIT;
//  logic [`CHI5PC_RSP_FLIT_RANGE] TXRSPFLIT;
//  logic [`CHI5PC_RSP_FLIT_RANGE] RXRSPFLIT;
//  logic [31:0] BroadcastVector;
//----------------------------------------

Chi5PC #(
  .ErrorOn_SW(1),
  .RecommendOn(1),
  .RecommendOn_Haz(1),
  .MAX_OS_REQ(32),
  .MAX_OS_EXCL(8),
  .MAX_OS_SNP(16),
  .NODE_ID(2),
  .CRDGRANT_BEFORE_RETRY(1),
  .MAXLLCREDITS(16),
  .DAT_FLIT_WIDTH(128)
) u_Chi5PC(
  .Chi5_in (CHI5PCInt),
  .SCLK (dut_clk)
);
`endif // ASSERT_ON


//Checking clock idle when qREQn and qACCEPTn are low (entered into pma)
<%if(obj.DutInfo.usePma) { %>
assert_clk_idle_when_pma_asserted : assert property (
    @(posedge tb_clk) disable iff (!soft_rstn)
    (!m_q_chnl_if.QREQn && !m_q_chnl_if.QACCEPTn ) |-> !dut_clk
    ) else assert_error("ERROR", "Dut clock is not stable low when RTL entered into PMA");
<% } %>

// System coherency state
wire tb_sysco_req;
wire tb_sysco_ack;
chi_sysco_state_t tb_sysco_state;

assign tb_sysco_req = tb_top.dut.<%=obj.DutInfo.interfaces.chiInt.name%>sysco_req;
assign tb_sysco_ack = tb_top.dut.<%=obj.DutInfo.interfaces.chiInt.name%>sysco_ack;

always @(tb_sysco_req or tb_sysco_ack) begin  //async
  if(soft_rstn) begin
    case (tb_sysco_state)
      DISABLED : begin
        case ({tb_sysco_ack, tb_sysco_req})
          0 : tb_sysco_state = DISABLED;
          1 : tb_sysco_state = CONNECT;
          2 : `ASSERT(0, "DISABLED->DISCONNECT Sysco state is illegal");
          3 : `ASSERT(0, "DISABLED->ENABLED Sysco state is illegal");
          default: `ASSERT(0, $psprintf("Illegal value %0h, %0h", tb_sysco_ack, tb_sysco_req));
        endcase
      end

      CONNECT : begin
        case ({tb_sysco_ack, tb_sysco_req})
          0 : `ASSERT(0, "CONNECT->DISABLED Sysco state is illegal");
          1 : tb_sysco_state = CONNECT;
          2 : `ASSERT(0, "CONNECT->DISCONNECT Sysco state is illegal");
          3 : tb_sysco_state = ENABLED;
          default: `ASSERT(0, $psprintf("Illegal value %0h, %0h", tb_sysco_ack, tb_sysco_req));
        endcase
      end

      ENABLED : begin
        case ({tb_sysco_ack, tb_sysco_req})
          0 : `ASSERT(0, "ENABLED->DISABLED Sysco state is illegal");
          1 : `ASSERT(0, "ENABLED->CONNECT Sysco state is illegal"); 
          2 : tb_sysco_state = DISCONNECT;
          3 : tb_sysco_state = ENABLED;
          default: `ASSERT(0, $psprintf("Illegal value %0h, %0h", tb_sysco_ack, tb_sysco_req));
        endcase
      end

      DISCONNECT : begin
        case ({tb_sysco_ack, tb_sysco_req})
          0 : tb_sysco_state = DISABLED; 
          1 : `ASSERT(0, "DISCONNECT->CONNECT Sysco state is illegal");
          2 : tb_sysco_state = DISCONNECT;
          3 : `ASSERT(0, "DISCONNECT->ENABLED Sysco state is illegal");
          default: `ASSERT(0, $psprintf("Illegal value %0h, %0h", tb_sysco_ack, tb_sysco_req));
        endcase
      end

      default : begin
        tb_sysco_state = DISABLED;
      end
    endcase
  end
end // always

endmodule: tb_top
