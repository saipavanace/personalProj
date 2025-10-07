
`include "ncore_param_info.sv" <%if(1==0){/*Move this to a stand-alone include file like ncore_test_lib*/ }%>

`include "svt_axi_user_defines.svi"
`include "svt_chi_user_defines.svi"
`include "svt_apb_user_defines.svi"

`ifdef EN_RESILIENCY
  `include "svt_apb_if.svi"
  `include "ncore_fault_if.sv"
  `include "ncore_fsys_fault_injector_checker.sv"
`endif

`include "ncore_irq_if.sv"
`include "svt_chi_if.svi"
// `include "chi_if.sv"

// `include "uvm_pkg.sv"

// Include the AMBA SVT UVM package 
`include "svt_amba.uvm.pkg"
`include "import_amba_packages.svi"
//for ACE vip includes
`include "svt_axi_if.svi"

// Include the AXI SVT UVM package 
`include "svt_axi.uvm.pkg"

// Include the AMBA COMMON SVT UVM package 
`include "svt_amba_common.uvm.pkg"
`include "sv_assert_pkg.sv"
`include "addr_trans_mgr_pkg.sv"
`include "ncore_clk_if.sv"
<%if(obj.nCHIs>0){%>
    `include "chi_if.sv"
    `include "connection_wrapper.sv"
<%}%>
`include "ncore_clk_rst_module.sv"
`include "ncore_system_register_map.sv"

import ncore_param_info::*;
import addr_trans_mgr_pkg::*;
import svt_uvm_pkg::*;
import svt_amba_uvm_pkg::*;

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "ncore_vip_configuration.sv"
`include "ncore_test_lib.sv"

<%let isMixedConfig = 0;%>
<%let foundChiB = 0;%>
<%let foundChiE = 0;%>

<%for(var idx = 0; idx < obj.AiuInfo.length; idx++) {%>
    <%if(obj.AiuInfo[idx].fnNativeInterface == 'CHI-B'){ 
      if(foundChiE == 1) {
        isMixedConfig = 1;
        break;
      }else {
        foundChiB = 1;
      }
     }else{
      if(foundChiB == 1){
        isMixedConfig = 1;
        break;
      }else{
        foundChiE = 1;
      }
    }%>
<%}%>

module ncore_system_tb_top;

  timeunit 1ns;
  timeprecision 1ps;

  logic sys_clk; 
  logic dut_clk;
  logic sys_rstn; 
  logic soft_rstn;

  <%for(pidx = 0; pidx < obj.AiuInfo.length; pidx++) {%>
    <%if(obj.AiuInfo[pidx].fnNativeInterface.includes('CHI')){%>
      parameter int WREQFLIT<%=pidx%> = <%=obj.AiuInfo[pidx].interfaces.chiInt.params.wReqflit%>;
      parameter int WDATFLIT<%=pidx%> = <%=obj.AiuInfo[pidx].interfaces.chiInt.params.wDatflit%>;
      parameter int WRSPFLIT<%=pidx%> = <%=obj.AiuInfo[pidx].interfaces.chiInt.params.wRspflit%>;
      parameter int WSNPFLIT<%=pidx%> = <%=obj.AiuInfo[pidx].interfaces.chiInt.params.wSnpflit%>;
      <%}%>
  <%}%>

  ncore_params obj;
  <%let l_chi_idx=0;%>
    // Declare Interface parity signals
  <%for(pidx = 0; pidx < obj.AiuInfo.length; pidx++) {%>
    <%if(obj.AiuInfo[pidx].fnNativeInterface.includes('CHI')){%>
      <%if(obj.AiuInfo[pidx].interfaces.chiInt.params.checkType != "NONE"){%>
          logic [((WREQFLIT<%=pidx%>/8)+(WREQFLIT<%=pidx%>%8 != 0))-1 : 0]    chi<%=l_chi_idx%>_rx_req_flit_chk;
          logic [((WRSPFLIT<%=pidx%>/8)+(WRSPFLIT<%=pidx%>%8 != 0))-1 : 0]    chi<%=l_chi_idx%>_rx_rsp_flit_chk;
          logic [((WDATFLIT<%=pidx%>/8)+(WDATFLIT<%=pidx%>%8 != 0))-1 : 0]    chi<%=l_chi_idx%>_rx_dat_flit_chk;
      <%}%>
      <%l_chi_idx++;%>
      <%}%>
  <%}%>

  <%for(var clock=0; clock < obj.Clocks.length; clock++){%>
      ncore_clk_if m_clk_if_<%=obj.Clocks[clock].name%>();
      logic <%=obj.Clocks[clock].name%>clk; 
      logic <%=obj.Clocks[clock].name%>clk_sync; 
      logic <%=obj.Clocks[clock].name%>reset_n;
      assign <%=obj.Clocks[clock].name%>clk  = m_clk_if_<%=obj.Clocks[clock].name%>.clk;
      assign <%=obj.Clocks[clock].name%>reset_n = m_clk_if_<%=obj.Clocks[clock].name%>.reset_n;
      assign <%=obj.Clocks[clock].name%>test_en = m_clk_if_<%=obj.Clocks[clock].name%>.test_en;
  <%}%>
  logic chi_clk_rn_clk[(`SVT_CHI_MAX_NUM_RNS-1):0];
  logic chi_clk_sn_clk[(`SVT_CHI_MAX_NUM_SNS-1):0];
  logic chi_clk_rn_resetn[(`SVT_CHI_MAX_NUM_RNS-1):0];
  logic chi_clk_sn_resetn[(`SVT_CHI_MAX_NUM_SNS-1):0];

  //Interfaces instantiation
  <%if(obj.useResiliency == 1){%>
      svt_apb_if  m_fsc_apb_if();
      fault_if  m_fsc_master_fault();
      uvm_event mission_fault_detected;
      parameter integer apb_dbg_id = 1;
  <%}else{%>
       parameter integer apb_dbg_id = 0;
  <%}%>
  <%for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
      ncore_irq_if m_irq_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_if();
  <%}%>
  <%for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
      ncore_irq_if m_irq_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>_if();
  <%}%>
  <%for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
      ncore_irq_if m_irq_<%=obj.DceInfo[pidx].strRtlNamePrefix%>_if();
  <%}%>
  <%for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
      ncore_irq_if m_irq_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>_if();
  <%}%>
  <%for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
      ncore_irq_if m_irq_<%=obj.DveInfo[pidx].strRtlNamePrefix%>_if();
  <%}%>
  svt_chi_if  m_svt_chi_if(
    .rn_clk(chi_clk_rn_clk),
    .sn_clk(chi_clk_sn_clk),
    .rn_resetn(chi_clk_rn_resetn),
    .sn_resetn(chi_clk_sn_resetn)
  );

    
  svt_axi_if  m_axi_if();
  <%l_chi_idx=0;%>
  <%for(let pidx = 0; pidx < obj.AiuInfo.length; pidx++) {%>
    <%if(obj.AiuInfo[pidx].fnNativeInterface.includes('CHI')){%>
      chi_if #(WREQFLIT<%=pidx%>,  WRSPFLIT<%=pidx%>, WDATFLIT<%=pidx%>, WSNPFLIT<%=pidx%>) m_chi_if<%=l_chi_idx%>();
      connection_wrapper #(FLIT_INFO[<%=l_chi_idx%>], "<%=obj.AiuInfo[pidx].fnNativeInterface%>", <%=isMixedConfig%>) m_connect_wrapper<%=pidx%>(m_chi_if<%=l_chi_idx%>, m_svt_chi_if.rn_if[<%=l_chi_idx%>]);
      <%l_chi_idx++;%>
    <%}%>
    
  <%}%>
  <%if(obj.useResiliency == 1){%>
      assign m_fsc_apb_if.pclk = <%=obj.AiuInfo[pidx].nativeClk%>clk;
      assign m_fsc_apb_if.presetn = <%=obj.AiuInfo[pidx].nativeClk%>reset_n;
  <%}%>
  
  <%if(obj.DebugApbInfo.length > 0){%>
      svt_apb_if  m_apb_debug_if();
  <%}%>
  <% let ioidx=0;
  l_chi_idx=0;
  for(let idx=0; idx<obj.nAIUs; idx++){%>
    <%if(obj.AiuInfo[idx].fnNativeInterface.includes("CHI")){%>
        assign chi_clk_rn_clk[<%=l_chi_idx%>] = <%=obj.AiuInfo[idx].nativeClk%>clk;
        assign chi_clk_sn_clk[<%=l_chi_idx%>] = <%=obj.AiuInfo[idx].nativeClk%>clk;
        assign chi_clk_rn_resetn[<%=l_chi_idx%>]  =  <%=obj.AiuInfo[idx].nativeClk%>reset_n;
        assign chi_clk_sn_resetn[<%=l_chi_idx%>]  =  <%=obj.AiuInfo[idx].nativeClk%>reset_n;
        <%l_chi_idx++;%>
    <%}else{%>
         <%for(let sub_io=0; sub_io<obj.AiuInfo[idx].nNativeInterfacePorts; sub_io++){%>
                assign m_axi_if.master_if[<%=ioidx%>].aclk = <%=obj.AiuInfo[idx].nativeClk%>clk;
                assign m_axi_if.master_if[<%=ioidx%>].aresetn =  <%=obj.AiuInfo[idx].nativeClk%>reset_n;
             <%ioidx++;%>
         <%}%>
    <%}%>
    initial  begin
        m_axi_if.set_master_common_clock_mode(0,<%=idx%>);
    end
  <%}%>
  
  <%if(obj.DebugApbInfo.length > 0){%>
      assign m_apb_debug_if.pclk = <%=obj.DebugApbInfo[0].unitClk[0]%>clk;
      assign m_apb_debug_if.presetn = <%=obj.DebugApbInfo[0].unitClk[0]%>reset_n;
  <%}%>
  assign m_axi_if.common_aclk = <%=obj.DmiInfo[0].unitClk[0]%>clk;
  <%let axiid=0;%>
  <%for(let pidx = 0; pidx < obj.nDMIs; pidx++){%>
      assign m_axi_if.slave_if[<%=axiid%>].aclk = <%=obj.DmiInfo[pidx].unitClk[0]%>clk;
      assign m_axi_if.slave_if[<%=axiid%>].aresetn = <%=obj.DmiInfo[pidx].unitClk[0]%>reset_n;
        initial  begin
            m_axi_if.set_slave_common_clock_mode(0,<%=axiid%>);
        end
      <%axiid++;%>
  <%}%>
    
  <% let axiidx=0;
  for(let pidx = 0; pidx < obj.nDIIs; pidx++){%>
    <% if (obj.DiiInfo[pidx].configuration == 0){%>  					       
         assign m_axi_if.slave_if[<%=axiid%>].aclk = <%=obj.DiiInfo[pidx].unitClk[0]%>clk;
         assign m_axi_if.slave_if[<%=axiid%>].aresetn = <%=obj.DiiInfo[pidx].unitClk[0]%>reset_n;  
         initial  begin
            m_axi_if.set_slave_common_clock_mode(0,<%=axiid%>);
         end
        <%axiid++;%>
    <%}%>
  <%}%>

  function automatic logic[63:0] calculateParity(logic [511:0] sig);
    longint checkValue = 0;
    for(int i=0; i<64; i+=1) begin
      checkValue[i] = ~^sig[(i*8) +: 8];
    end
    return checkValue;
  endfunction

  // DUT Instantiation
  <% if (obj.useRtlPrefix == 1) { %>
    <%=obj.strProjectName%>_gen_wrapper u_chip (
<% } else { %>
  gen_wrapper u_chip (
<% } %>

  <%if(obj.useResiliency == 1){%>
      .fsc_<%=obj.FscInfo.interfaces.apbInterface.name%>psel       (m_fsc_apb_if.psel),
      .fsc_<%=obj.FscInfo.interfaces.apbInterface.name%>penable    (m_fsc_apb_if.penable),
      .fsc_<%=obj.FscInfo.interfaces.apbInterface.name%>pwrite     (m_fsc_apb_if.pwrite),
      <% if(obj.FscInfo.interfaces.apbInterface.params.wProt>0){%>
           .fsc_<%=obj.FscInfo.interfaces.apbInterface.name%>pprot      (m_fsc_apb_if.pprot),
      <%}%>
      <%if(obj.FscInfo.interfaces.apbInterface.params.wStrb>0){%>
           .fsc_<%=obj.FscInfo.interfaces.apbInterface.name%>pstrb      (m_fsc_apb_if.pstrb),
      <%}%>
      .fsc_<%=obj.FscInfo.interfaces.apbInterface.name%>paddr      (m_fsc_apb_if.paddr),
      .fsc_<%=obj.FscInfo.interfaces.apbInterface.name%>pwdata     (m_fsc_apb_if.pwdata),
      .fsc_<%=obj.FscInfo.interfaces.apbInterface.name%>pready     (m_fsc_apb_if.slave_if[0].pready),
      .fsc_<%=obj.FscInfo.interfaces.apbInterface.name%>prdata     (m_fsc_apb_if.slave_if[0].prdata),
      .fsc_<%=obj.FscInfo.interfaces.apbInterface.name%>pslverr    (m_fsc_apb_if.slave_if[0].pslverr),
      .fsc_<%=obj.FscInfo.interfaces.masterFaultInterface.name%>mission_fault  (m_fsc_master_fault.mission_fault),
      .fsc_<%=obj.FscInfo.interfaces.masterFaultInterface.name%>latent_fault  (m_fsc_master_fault.latent_fault),
      .fsc_<%=obj.FscInfo.interfaces.masterFaultInterface.name%>cerr_over_thres_fault  (m_fsc_master_fault.cerr_over_thres_fault),
      .ncore_en_debug_bist_pin(1'b1),
  <%}%>
  <%if(obj.DebugApbInfo.length > 0){%>
      .ncore_debug_atu_config_paddr(m_apb_debug_if.paddr),
      .ncore_debug_atu_config_psel(m_apb_debug_if.psel),
      .ncore_debug_atu_config_penable(m_apb_debug_if.penable),
      .ncore_debug_atu_config_pwrite(m_apb_debug_if.pwrite),
      .ncore_debug_atu_config_pwdata(m_apb_debug_if.pwdata),
      .ncore_debug_atu_config_pready(m_apb_debug_if.slave_if[0].pready),
      .ncore_debug_atu_config_prdata(m_apb_debug_if.slave_if[0].prdata),
      .ncore_debug_atu_config_pslverr(m_apb_debug_if.slave_if[0].pslverr),
      <%if(obj.DebugApbInfo[0].interfaces.apbInterface.params.wStrb>0){%>
          .ncore_debug_atu_config_pstrb      (m_apb_debug_if.slave_if[0].pstrb),
      <%}%>
      <%if(obj.DebugApbInfo[0].interfaces.apbInterface.params.wProt>0){%>
          .ncore_debug_atu_config_pprot      ('d0),
      <%}%>
  <%}%>
  <%for(var idx = 0; idx < obj.nAIUs; idx++){ %>
      <%if(obj.AiuInfo[idx].interfaces.eventRequestInInt._SKIP_ == false) {%>        
          .<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=obj.AiuInfo[idx].interfaces.eventRequestInInt.name%>req              (1'b0),
          .<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=obj.AiuInfo[idx].interfaces.eventRequestInInt.name%>ack              (),
      <%}%>
      <%if(obj.AiuInfo[idx].interfaces.eventRequestOutInt._SKIP_ == false) {%>        
          .<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=obj.AiuInfo[idx].interfaces.eventRequestOutInt.name%>req              (),
          .<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=obj.AiuInfo[idx].interfaces.eventRequestOutInt.name%>ack              (1'b0),
      <%}%>
      <%if(!(obj.AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
          <%if(obj.AiuInfo[idx].interfaces.userPlaceInt._SKIP_ == false || (typeof obj.AiuInfo[idx].interfaces.memoryInt !== 'undefined')){%>
              <%for(var memIdx = 0; memIdx < obj.AiuInfo[idx].interfaces.memoryInt.length; memIdx++){%>
                  <%for(var inIdx = 0; inIdx < obj.AiuInfo[idx].interfaces.memoryInt[memIdx].synonyms.in.length; inIdx++){%>
                    <%if(obj.AiuInfo[idx].interfaces.memoryInt[memIdx]._SKIP_ === false){%>
                      .<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=obj.AiuInfo[idx].interfaces.memoryInt[memIdx].name%><%=obj.AiuInfo[idx].interfaces.memoryInt[memIdx].synonyms.in[inIdx].name%>                ('b0),
                      <%}%>
                  <%}%>
              <%}%>
          <%}%>
      <%}%>
  <%}%>

  <%for(var idx = 0; idx < obj.nAIUs; idx++){%>
      <%if(!obj.AiuInfo[idx].fnNativeInterface.includes('CHI')){%>
          .<%=obj.AiuInfo[idx].strRtlNamePrefix%>_irq_c                (m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_c),
      <%}%>
      .<%=obj.AiuInfo[idx].strRtlNamePrefix%>_irq_uc               (m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if.IRQ_uc),
  <%}%>
  <%for(var idx = 0; idx < obj.nDMIs; idx++){ %>
      .<%=obj.DmiInfo[idx].strRtlNamePrefix%>_irq_c                (m_irq_<%=obj.DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_c),
      .<%=obj.DmiInfo[idx].strRtlNamePrefix%>_irq_uc               (m_irq_<%=obj.DmiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc),
      <%if(obj.DmiInfo[idx].interfaces.userPlaceInt._SKIP_ == false || (typeof obj.DmiInfo[idx].interfaces.memoryInt !== 'undefined')){%>
          <%for(var memIdx = 0; memIdx < obj.DmiInfo[idx].interfaces.memoryInt.length; memIdx++){ %>
              <%for(var inIdx = 0; inIdx < obj.DmiInfo[idx].interfaces.memoryInt[memIdx].synonyms.in.length; inIdx++){%>
                    <%if(obj.DmiInfo[idx].interfaces.memoryInt[memIdx]._SKIP_ === false){%>
                  .<%=obj.DmiInfo[idx].strRtlNamePrefix%>_<%=obj.DmiInfo[idx].interfaces.memoryInt[memIdx].name%><%=obj.DmiInfo[idx].interfaces.memoryInt[memIdx].synonyms.in[inIdx].name%>                ('b0),
                  <%}%>
              <%}%>
          <%}%>
      <%}%>
  <%}%>
  <%for(var idx = 0; idx < obj.nDIIs; idx++){%>
      .<%=obj.DiiInfo[idx].strRtlNamePrefix%>_irq_c                (m_irq_<%=obj.DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_c),
      .<%=obj.DiiInfo[idx].strRtlNamePrefix%>_irq_uc               (m_irq_<%=obj.DiiInfo[idx].strRtlNamePrefix%>_if.IRQ_uc),
      <%if(obj.DiiInfo[idx].interfaces.userPlaceInt._SKIP_ == false || (typeof obj.DiiInfo[idx].interfaces.memoryInt !== 'undefined')){%>
          <%for(var inIdx = 0; inIdx < obj.DiiInfo[idx].interfaces.userPlaceInt.synonyms.in.length; inIdx++){ %>
              .<%=obj.DiiInfo[idx].strRtlNamePrefix%>_<%=obj.DiiInfo[idx].interfaces.userPlaceInt.name%><%=obj.DiiInfo[idx].interfaces.userPlaceInt.synonyms.in[inIdx].name%>                ('b0),
          <%}%>
      <%}%>
  <%}%>
  <%for(var idx = 0; idx < obj.nDCEs; idx++){ %>
      .<%=obj.DceInfo[idx].strRtlNamePrefix%>_irq_c                (m_irq_<%=obj.DceInfo[idx].strRtlNamePrefix%>_if.IRQ_c),
      .<%=obj.DceInfo[idx].strRtlNamePrefix%>_irq_uc               (m_irq_<%=obj.DceInfo[idx].strRtlNamePrefix%>_if.IRQ_uc),
      <%if(obj.DceInfo[idx].interfaces._SKIP_ == false || (typeof obj.DceInfo[idx].interfaces.memoryInt !== 'undefined')){%>
          <%for(var memIdx = 0; memIdx < obj.DceInfo[idx].interfaces.memoryInt.length; memIdx++){%>
              <%for(var inIdx = 0; inIdx < obj.DceInfo[idx].interfaces.memoryInt[memIdx].synonyms.in.length; inIdx++){%>
                  .<%=obj.DceInfo[idx].strRtlNamePrefix%>_<%=obj.DceInfo[idx].interfaces.memoryInt[memIdx].name%><%=obj.DceInfo[idx].interfaces.memoryInt[memIdx].synonyms.in[inIdx].name%>                ('b0),
              <%}%>
          <%}%>
      <%}%>
  <%}%>
  <% for(var idx = 0; idx < obj.nDVEs; idx++){ %>
      .<%=obj.DveInfo[idx].strRtlNamePrefix%>_irq_uc               (m_irq_<%=obj.DveInfo[idx].strRtlNamePrefix%>_if.IRQ_uc),
      <%if(obj.DveInfo[idx].interfaces._SKIP_ == false || (typeof obj.DveInfo[idx].interfaces.memoryInt !== 'undefined')){%>
          <%for(var memIdx = 0; memIdx < obj.DveInfo[idx].interfaces.memoryInt.length; memIdx++){ %>
              <%for(var inIdx = 0; inIdx < obj.DveInfo[idx].interfaces.memoryInt[memIdx].synonyms.in.length; inIdx++){ %>
                  .<%=obj.DveInfo[idx].strRtlNamePrefix%>_<%=obj.DveInfo[idx].interfaces.memoryInt[memIdx].name%><%=obj.DveInfo[idx].interfaces.memoryInt[memIdx].synonyms.in[inIdx].name%>                ('b0),
              <%}%>
          <%}%>
      <%}%>
  <%}%>
  <% axiidx = 0; chiidx=0; obj.AiuInfo.forEach(function(bundle, idx) { %>
       <%if (bundle.fnNativeInterface.includes('CHI')) { %>
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_sactive              (m_chi_if<%=chiidx%>.tx_sactive),
           <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_sactive_chk     (!m_chi_if<%=chiidx%>.tx_sactive),
           <%}%>
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_sactive              (m_chi_if<%=chiidx%>.rx_sactive),
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_link_active_req      (m_chi_if<%=chiidx%>.tx_link_active_req),
           <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_link_active_req_chk  (!m_chi_if<%=chiidx%>.tx_link_active_req),
           <%}%>
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_link_active_ack      (m_chi_if<%=chiidx%>.tx_link_active_ack),
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_link_active_req      (m_chi_if<%=chiidx%>.rx_link_active_req),
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_link_active_ack      (m_chi_if<%=chiidx%>.rx_link_active_ack),
           <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_link_active_ack_chk  (!m_chi_if<%=chiidx%>.rx_link_active_ack),
           <%}%>
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_req_flit_pend        (m_chi_if<%=chiidx%>.tx_req_flit_pend),
           <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_req_flit_pend_chk  (!m_chi_if<%=chiidx%>.tx_req_flit_pend),
           <%}%>
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_req_flitv            (m_chi_if<%=chiidx%>.tx_req_flitv),
           <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_req_flitv_chk  (!m_chi_if<%=chiidx%>.tx_req_flitv),
           <%}%>
            .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_req_flit             (m_chi_if<%=chiidx%>.tx_req_flit),
            <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_req_flit_chk  (calculateParity(m_chi_if<%=chiidx%>.tx_req_flit)),
            <%}%>
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_req_lcrdv            (m_chi_if<%=chiidx%>.tx_req_lcrdv),
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_rsp_flit_pend        (m_chi_if<%=chiidx%>.tx_rsp_flit_pend),
           <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_rsp_flit_pend_chk  (!m_chi_if<%=chiidx%>.tx_rsp_flit_pend),
           <%}%>
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_rsp_flitv            (m_chi_if<%=chiidx%>.tx_rsp_flitv),
           <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_rsp_flitv_chk  (!m_chi_if<%=chiidx%>.tx_rsp_flitv),
           <%}%>
            .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_rsp_flit             (m_chi_if<%=chiidx%>.tx_rsp_flit),
            <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_rsp_flit_chk  (calculateParity(m_chi_if<%=chiidx%>.tx_rsp_flit)),
            <%}%>
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_rsp_lcrdv            (m_chi_if<%=chiidx%>.tx_rsp_lcrdv),
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_dat_flit_pend        (m_chi_if<%=chiidx%>.tx_dat_flit_pend),
           <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_dat_flit_pend_chk  (!m_chi_if<%=chiidx%>.tx_dat_flit_pend),
           <%}%>
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_dat_flitv            (m_chi_if<%=chiidx%>.tx_dat_flitv),
           <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_dat_flitv_chk  (!m_chi_if<%=chiidx%>.tx_dat_flitv),
           <%}%>
            .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_dat_flit             (m_chi_if<%=chiidx%>.tx_dat_flit),
            <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_dat_flit_chk  (calculateParity(m_chi_if<%=chiidx%>.tx_dat_flit)),
            <%}%>
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>rx_dat_lcrdv            (m_chi_if<%=chiidx%>.tx_dat_lcrdv),
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_snp_flit_pend        (m_chi_if<%=chiidx%>.rx_snp_flit_pend),
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_snp_flitv            (m_chi_if<%=chiidx%>.rx_snp_flitv),
            .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_snp_flit             (m_chi_if<%=chiidx%>.rx_snp_flit),
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_snp_lcrdv            (m_chi_if<%=chiidx%>.rx_snp_lcrdv),
           <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_snp_lcrdv_chk  (!m_chi_if<%=chiidx%>.rx_snp_lcrdv),
           <%}%>
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_rsp_flit_pend        (m_chi_if<%=chiidx%>.rx_rsp_flit_pend),
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_rsp_flitv            (m_chi_if<%=chiidx%>.rx_rsp_flitv),
            .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_rsp_flit             (m_chi_if<%=chiidx%>.rx_rsp_flit),
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_rsp_lcrdv            (m_chi_if<%=chiidx%>.rx_rsp_lcrdv),
           <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_rsp_lcrdv_chk  (!m_chi_if<%=chiidx%>.rx_rsp_lcrdv),
           <%}%>
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_dat_flit_pend        (m_chi_if<%=chiidx%>.rx_dat_flit_pend),
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_dat_flitv            (m_chi_if<%=chiidx%>.rx_dat_flitv),
            .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_dat_flit             (m_chi_if<%=chiidx%>.rx_dat_flit),
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_dat_lcrdv            (m_chi_if<%=chiidx%>.rx_dat_lcrdv),
           <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>tx_dat_lcrdv_chk  (!m_chi_if<%=chiidx%>.rx_dat_lcrdv),
           <%}%>
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>sysco_req               (m_chi_if<%=chiidx%>.sysco_req),
           .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>sysco_ack               (m_chi_if<%=chiidx%>.sysco_ack),
           <%if(bundle.interfaces.chiInt.params.checkType != "NONE"){%>
               .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.chiInt.name%>sysco_req_chk      (!m_chi_if<%=chiidx%>.sysco_req),
           <%}%>
           <%chiidx++%>
        <%}else{%>
            <%for (var mpu_io = 0; mpu_io < bundle.nNativeInterfacePorts; mpu_io++){%>
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_ready                ( m_axi_if.master_if[<%=axiidx%>].awready                   ) ,
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_valid                ( m_axi_if.master_if[<%=axiidx%>].awvalid                   ) ,
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_id                   ( m_axi_if.master_if[<%=axiidx%>].awid                      ) ,
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_addr                 ( m_axi_if.master_if[<%=axiidx%>].awaddr                    ) ,
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_len                  ( m_axi_if.master_if[<%=axiidx%>].awlen                     ) ,
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_size                 ( m_axi_if.master_if[<%=axiidx%>].awsize                    ) ,
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_burst                ( m_axi_if.master_if[<%=axiidx%>].awburst                   ) ,
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_lock                 ( m_axi_if.master_if[<%=axiidx%>].awlock                    ) ,
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_cache                ( m_axi_if.master_if[<%=axiidx%>].awcache                   ) ,
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_prot                 ( m_axi_if.master_if[<%=axiidx%>].awprot                    ) ,
                <%if (bundle.interfaces.axiInt[mpu_io].params.eAtomic>0) { %>                                                                          
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_atop               ( m_axi_if.master_if[<%=axiidx%>].awatop                  ) ,
                <%}%>                                                                                                                         
                <%if (bundle.interfaces.axiInt[mpu_io].params.wRegion>0) { %>                                                                          
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_region               ( m_axi_if.master_if[<%=axiidx%>].awregion                  ) ,
                <%}%>                                                                                                                         
                <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_trace                  ( m_axi_if.master_if[<%=axiidx%>].awtrace                     ) ,
                <%}%>                                                                                                                                
                <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_ready_chk            ( m_axi_if.master_if[<%=axiidx%>].awreadychk               ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_valid_chk            ( m_axi_if.master_if[<%=axiidx%>].awvalidchk               ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_id_chk               ( m_axi_if.master_if[<%=axiidx%>].awidchk                  ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_addr_chk             ( m_axi_if.master_if[<%=axiidx%>].awaddrchk                ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_len_chk              ( m_axi_if.master_if[<%=axiidx%>].awlenchk                 ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_ctl_chk0             ( m_axi_if.master_if[<%=axiidx%>].awctlchk0                ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_ctl_chk1             ( m_axi_if.master_if[<%=axiidx%>].awctlchk1                ) ,
                <%if (!(bundle.fnNativeInterface === "AXI5")){%>
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_ctl_chk2             ( m_axi_if.master_if[<%=axiidx%>].awctlchk2                ) ,
                    <%}%>
                <%if ((bundle.fnNativeInterface === "AXI5" ||  bundle.fnNativeInterface === "ACELITE-E") && (bundle.interfaces.axiInt[mpu_io].params.atomicTransactions == true ))  { %>                               
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_ctl_chk3             ( m_axi_if.master_if[<%=axiidx%>].awctlchk3                ) ,
                <%}%>
                <%if (!((bundle.fnNativeInterface === "ACE5") || (bundle.fnNativeInterface === "AXI5"))){%>
                <%if (bundle.interfaces.axiInt[mpu_io].params.eStash>0) { %>                                                                                    
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_stashnid_chk         ( m_axi_if.master_if[<%=axiidx%>].awstashnidchk            ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_stashlpid_chk        ( m_axi_if.master_if[<%=axiidx%>].awstashlpidchk           ) ,
                <%}%>                                                                                                                         
                <%}%>                                                                                                                         
                <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
				    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_trace_chk            ( m_axi_if.master_if[<%=axiidx%>].awtracechk               ) ,
                <%}%>                                                                                                                         
                <%}%>                                                                                                                         

                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_ready                 ( m_axi_if.master_if[<%=axiidx%>].wready                    ) ,
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_valid                 ( m_axi_if.master_if[<%=axiidx%>].wvalid                    ) ,
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_data                  ( m_axi_if.master_if[<%=axiidx%>].wdata[<%=bundle.interfaces.axiInt[mpu_io].params.wData - 1%> : 0]                     ) ,
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_last                  ( m_axi_if.master_if[<%=axiidx%>].wlast                     ) ,
                .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_strb                  ( m_axi_if.master_if[<%=axiidx%>].wstrb[<%=bundle.interfaces.axiInt[mpu_io].params.wData/8 - 1%> : 0]                     ) ,
                <%if (bundle.interfaces.axiInt[mpu_io].params.wWUser > 0){%>
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_user                  ( m_axi_if.master_if[<%=axiidx%>].wuser                     ) ,
                <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_user_chk              ( m_axi_if.master_if[<%=axiidx%>].wuserchk                  ) ,
                <%}%>
                <%}%>
                <%if(bundle.interfaces.axiInt[mpu_io].params.eTrace>0){%>
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_trace                  ( m_axi_if.master_if[<%=axiidx%>].wtrace                       ) ,
                <%}%>
                <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_ready_chk             ( m_axi_if.master_if[<%=axiidx%>].wreadychk                ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_valid_chk             ( m_axi_if.master_if[<%=axiidx%>].wvalidchk                ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_data_chk              ( m_axi_if.master_if[<%=axiidx%>].wdatachk                 ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_strb_chk              ( m_axi_if.master_if[<%=axiidx%>].wstrbchk                 ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_last_chk              ( m_axi_if.master_if[<%=axiidx%>].wlastchk                 ) ,
                <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
			        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_trace_chk             ( m_axi_if.master_if[<%=axiidx%>].wtracechk                ) ,
                <%}%>                                                                                                                         
                <%}%>

                 .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_ready                 ( m_axi_if.master_if[<%=axiidx%>].bready                    ) ,
                 .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_valid                 ( m_axi_if.master_if[<%=axiidx%>].bvalid                    ) ,
                 .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_id                    ( m_axi_if.master_if[<%=axiidx%>].bid                       ) ,
                 .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_resp                  ( m_axi_if.master_if[<%=axiidx%>].bresp                     ) ,
                 <%if (bundle.interfaces.axiInt[mpu_io].params.wBUser > 0){%>
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_user              ( m_axi_if.master_if[<%=axiidx%>].buser                     ) ,
                 <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_user_chk          ( m_axi_if.master_if[<%=axiidx%>].buserchk                  ) ,
                 <%}%>                                                                                                                         
                 <%}%>                                                                                                                         
                 <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0){%>
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_trace                  ( m_axi_if.master_if[<%=axiidx%>].btrace                       ) ,
                 <%}%>
                <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_ready_chk             ( m_axi_if.master_if[<%=axiidx%>].breadychk                ) ,
			        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_valid_chk             ( m_axi_if.master_if[<%=axiidx%>].bvalidchk                ) ,
		    	    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_id_chk                ( m_axi_if.master_if[<%=axiidx%>].bidchk                   ) ,
			        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_resp_chk              ( m_axi_if.master_if[<%=axiidx%>].brespchk                 ) ,
                <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
				    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>b_trace_chk             ( m_axi_if.master_if[<%=axiidx%>].btracechk                ) ,
                <%}%>                                                                                                                         
                <%}%>

                 .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_valid                ( m_axi_if.master_if[<%=axiidx%>].arvalid                   ) ,
                 .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_ready                ( m_axi_if.master_if[<%=axiidx%>].arready                   ) ,
                 .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_id                   ( m_axi_if.master_if[<%=axiidx%>].arid                      ) ,
                 .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_addr                 ( m_axi_if.master_if[<%=axiidx%>].araddr                    ) ,
                 .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_len                  ( m_axi_if.master_if[<%=axiidx%>].arlen                     ) ,
                 .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_size                 ( m_axi_if.master_if[<%=axiidx%>].arsize                    ) ,
                 .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_burst                ( m_axi_if.master_if[<%=axiidx%>].arburst                   ) ,
                 .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_lock                 ( m_axi_if.master_if[<%=axiidx%>].arlock                    ) ,
                 .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_cache                ( m_axi_if.master_if[<%=axiidx%>].arcache                   ) ,
                 .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_prot                 ( m_axi_if.master_if[<%=axiidx%>].arprot                    ) ,
                 <%if (bundle.interfaces.axiInt[mpu_io].params.wRegion>0) { %>                                                                          
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_region               ( m_axi_if.master_if[<%=axiidx%>].arregion                    ) ,
                 <%}%>
                 <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0){%>
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_trace                  ( m_axi_if.master_if[<%=axiidx%>].artrace                       ) ,
                 <%}%>
                <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_valid_chk            ( m_axi_if.master_if[<%=axiidx%>].arvalidchk               ) ,
			        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_ready_chk            ( m_axi_if.master_if[<%=axiidx%>].arreadychk               ) ,
			        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_id_chk               ( m_axi_if.master_if[<%=axiidx%>].aridchk                  ) ,
			        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_addr_chk             ( m_axi_if.master_if[<%=axiidx%>].araddrchk                ) ,
			        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_len_chk              ( m_axi_if.master_if[<%=axiidx%>].arlenchk                 ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_ctl_chk0             ( m_axi_if.master_if[<%=axiidx%>].arctlchk0                ) ,
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_ctl_chk1             ( m_axi_if.master_if[<%=axiidx%>].arctlchk1                ) ,
                <%if (!(bundle.fnNativeInterface === "AXI5")){%>
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_ctl_chk2             ( m_axi_if.master_if[<%=axiidx%>].arctlchk2                ) ,
			        <%if(bundle.interfaces.axiInt[mpu_io].params.eAc == 1 && obj.DVMVersionSupport > 128){%>
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_ctl_chk3             ( m_axi_if.master_if[<%=axiidx%>].arctlchk3                ) ,
                    <%}%>
                <%}%>
                <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_trace_chk            ( m_axi_if.master_if[<%=axiidx%>].artracechk               ) ,
                <%}%>                                                                                                                         
                <%}%>

                 .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_ready                 ( m_axi_if.master_if[<%=axiidx%>].rready                    ) ,
                 .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_valid                 ( m_axi_if.master_if[<%=axiidx%>].rvalid                    ) ,
                 .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_resp                  ( m_axi_if.master_if[<%=axiidx%>].rresp                     ) ,
                 .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_data                  ( m_axi_if.master_if[<%=axiidx%>].rdata[<%=bundle.interfaces.axiInt[mpu_io].params.wData - 1%> : 0]                     ) ,
                 .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_last                  ( m_axi_if.master_if[<%=axiidx%>].rlast                     ) ,
                 .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_id                    ( m_axi_if.master_if[<%=axiidx%>].rid                       ) ,
                 <%if (bundle.interfaces.axiInt[mpu_io].params.wRUser > 0){%>
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_user              ( m_axi_if.master_if[<%=axiidx%>].ruser                     ) ,
                 <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_user_chk          ( m_axi_if.master_if[<%=axiidx%>].ruserchk                  ) ,
                 <%}%>
                 <%}%>
                 <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0){%>
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_trace                  ( m_axi_if.master_if[<%=axiidx%>].rtrace                       ) ,
                 <%}%>
                <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_ready_chk             ( m_axi_if.master_if[<%=axiidx%>].rreadychk                ) ,
			        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_valid_chk             ( m_axi_if.master_if[<%=axiidx%>].rvalidchk                ) ,
			        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_resp_chk              ( m_axi_if.master_if[<%=axiidx%>].rrespchk                 ) ,
		    	    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_data_chk              ( m_axi_if.master_if[<%=axiidx%>].rdatachk                 ) ,
			        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_last_chk              ( m_axi_if.master_if[<%=axiidx%>].rlastchk                 ) ,
	        	    .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_id_chk                ( m_axi_if.master_if[<%=axiidx%>].ridchk                   ) ,
                <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0) { %>                                                                                    
				.<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_trace_chk             ( m_axi_if.master_if[<%=axiidx%>].rtracechk                ) ,
                <%}%>                                                                                                                         
                <%}%>

                 <%if (bundle.interfaces.axiInt[mpu_io].params.wQos>0){%>
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_qos                  ( m_axi_if.master_if[<%=axiidx%>].awqos                     ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_qos                  ( m_axi_if.master_if[<%=axiidx%>].arqos                     ) ,
                 <%}%>
                 <%if (bundle.interfaces.axiInt[mpu_io].params.wAwUser > 0){%>
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_user                 ( m_axi_if.master_if[<%=axiidx%>].awuser                    ) ,
                 <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_user_chk             ( m_axi_if.master_if[<%=axiidx%>].awuserchk                 ) ,
                 <%}%>
                 <%}%>
                 <%if (bundle.interfaces.axiInt[mpu_io].params.wArUser > 0){%>
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_user                 ( m_axi_if.master_if[<%=axiidx%>].aruser                    ) ,
                 <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_user_chk             ( m_axi_if.master_if[<%=axiidx%>].aruserchk                 ) ,
                 <%}%>
                 <%}%>
                 <%if (bundle.fnNativeInterface === "ACE-LITE" || bundle.fnNativeInterface === "ACELITE-E"){%>
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_snoop                ( m_axi_if.master_if[<%=axiidx%>].awsnoop                   ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_domain               ( m_axi_if.master_if[<%=axiidx%>].awdomain                  ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_bar                  ( m_axi_if.master_if[<%=axiidx%>].awbar                     ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_snoop                ( m_axi_if.master_if[<%=axiidx%>].arsnoop                   ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_domain               ( m_axi_if.master_if[<%=axiidx%>].ardomain                  ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_bar                  ( m_axi_if.master_if[<%=axiidx%>].arbar                     ) ,
                     <%if (bundle.interfaces.axiInt[mpu_io].params.eAtomic > 0) { %>
                         .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_atop                 ( m_axi_if.master_if[<%=axiidx%>].awatop                    ) ,
                     <%}%>                                                                                                                         
                     <%if (bundle.interfaces.axiInt[mpu_io].params.eStash > 0) { %>
                         .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_stashnid             ( m_axi_if.master_if[<%=axiidx%>].awstashnid                ) ,
                         .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_stashniden           ( m_axi_if.master_if[<%=axiidx%>].awstashnid_en              ) ,
                         .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_stashlpid            ( m_axi_if.master_if[<%=axiidx%>].awstashlpid               ) ,
                         .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_stashlpiden          ( m_axi_if.master_if[<%=axiidx%>].awstashlpid_en             ) ,
                     <%}%>                                                                                                                         
                     <%if (bundle.interfaces.axiInt[mpu_io].params.eAc > 0){%>
                         .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_snoop                ( m_axi_if.master_if[<%=axiidx%>].acsnoop                   ) ,
                         .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_addr                 ( m_axi_if.master_if[<%=axiidx%>].acaddr                    ) ,
                         .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_prot                 ( m_axi_if.master_if[<%=axiidx%>].acprot                    ) ,
                         .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_valid                ( m_axi_if.master_if[<%=axiidx%>].acvalid                   ) ,
                         .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_ready                ( m_axi_if.master_if[<%=axiidx%>].acready                   ) ,
                         .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_ready                ( m_axi_if.master_if[<%=axiidx%>].crready                   ) ,
                         .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_valid                ( m_axi_if.master_if[<%=axiidx%>].crvalid                   ) ,
                         .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_resp                 ( m_axi_if.master_if[<%=axiidx%>].crresp                    ) ,
                         <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0){%>
                             .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_trace                  ( m_axi_if.master_if[<%=axiidx%>].actrace                       ) ,
                             .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_trace                  ( m_axi_if.master_if[<%=axiidx%>].crtrace                       ) ,
                         <%}%>                                                                                                                                  
                    <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_valid_chk            ( m_axi_if.master_if[<%=axiidx%>].acvalidchk               ) ,
				        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_ready_chk            ( m_axi_if.master_if[<%=axiidx%>].acreadychk               ) ,
				        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_addr_chk             ( m_axi_if.master_if[<%=axiidx%>].acaddrchk                ) ,
                        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_ctl_chk              ( m_axi_if.master_if[<%=axiidx%>].acctlchk                ) ,
                        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_valid_chk            ( m_axi_if.master_if[<%=axiidx%>].crvalidchk               ) ,
        				.<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_ready_chk            ( m_axi_if.master_if[<%=axiidx%>].crreadychk               ) ,
        				.<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_resp_chk             ( m_axi_if.master_if[<%=axiidx%>].crrespchk                ) ,
                         <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0){%>
                             .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_trace_chk                  ( m_axi_if.master_if[<%=axiidx%>].actracechk                       ) ,
                             .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_trace_chk                  ( m_axi_if.master_if[<%=axiidx%>].crtracechk                       ) ,
                         <%}%>                                                                                                                                  
                     <%}%>
                     <%}%>                                                                                                                                    
                 <%}%>
                 <%if (bundle.fnNativeInterface === "ACE" || bundle.fnNativeInterface === "ACE5" ){%>                                                                                  
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_snoop                ( m_axi_if.master_if[<%=axiidx%>].awsnoop                   ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_domain               ( m_axi_if.master_if[<%=axiidx%>].awdomain                  ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_bar                  ( m_axi_if.master_if[<%=axiidx%>].awbar                     ) ,
                     <%if (bundle.interfaces.axiInt[mpu_io].params.eUnique> 0){%>
                         .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_unique               ( m_axi_if.master_if[<%=axiidx%>].awunique                  ) ,
                     <%}%>
                     <%if (bundle.fnNativeInterface === "ACE5" && bundle.interfaces.axiInt[mpu_io].params.eAtomic> 0){%>
                        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>aw_atop                ( m_axi_if.master_if[<%=axiidx%>].awatop                   ) ,
                     <%}%>
                                                                                                                                     
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_snoop                ( m_axi_if.master_if[<%=axiidx%>].arsnoop                   ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_domain               ( m_axi_if.master_if[<%=axiidx%>].ardomain                  ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ar_bar                  ( m_axi_if.master_if[<%=axiidx%>].arbar                     ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_ack                   ( m_axi_if.master_if[<%=axiidx%>].wack                      ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_ack                   ( m_axi_if.master_if[<%=axiidx%>].rack                      ) ,
                     <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>w_ack_chk               ( m_axi_if.master_if[<%=axiidx%>].wackchk                   ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>r_ack_chk               ( m_axi_if.master_if[<%=axiidx%>].rackchk                   ) ,
                     <%}%>
                                                                                                                                     
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_valid                ( m_axi_if.master_if[<%=axiidx%>].acvalid                   ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_ready                ( m_axi_if.master_if[<%=axiidx%>].acready                   ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_addr                 ( m_axi_if.master_if[<%=axiidx%>].acaddr                    ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_snoop                ( m_axi_if.master_if[<%=axiidx%>].acsnoop                   ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_prot                 ( m_axi_if.master_if[<%=axiidx%>].acprot                    ) ,
                    <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_valid_chk            ( m_axi_if.master_if[<%=axiidx%>].acvalidchk               ) ,
				        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_ready_chk            ( m_axi_if.master_if[<%=axiidx%>].acreadychk               ) ,
				        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_addr_chk             ( m_axi_if.master_if[<%=axiidx%>].acaddrchk                ) ,
                        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_ctl_chk              ( m_axi_if.master_if[<%=axiidx%>].acctlchk                ) ,
                     <%}%>
                                                                                                                                             
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_valid                ( m_axi_if.master_if[<%=axiidx%>].crvalid                   ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_ready                ( m_axi_if.master_if[<%=axiidx%>].crready                   ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_resp                 ( m_axi_if.master_if[<%=axiidx%>].crresp                    ) ,
                    <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_valid_chk            ( m_axi_if.master_if[<%=axiidx%>].crvalidchk               ) ,
				        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_ready_chk            ( m_axi_if.master_if[<%=axiidx%>].crreadychk               ) ,
				        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_resp_chk             ( m_axi_if.master_if[<%=axiidx%>].crrespchk                ) ,
                    <%}%>

                     <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0){%>
                         .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_trace                  ( m_axi_if.master_if[<%=axiidx%>].actrace                       ) ,
                         .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_trace                  ( m_axi_if.master_if[<%=axiidx%>].crtrace                       ) ,
                          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_trace                  ( m_axi_if.master_if[<%=axiidx%>].cdtrace                       ) ,
                     <%}%>
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_valid                ( m_axi_if.master_if[<%=axiidx%>].cdvalid                   ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_ready                ( m_axi_if.master_if[<%=axiidx%>].cdready                   ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_data                 ( m_axi_if.master_if[<%=axiidx%>].cddata                    ) ,
                     .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_last                 ( m_axi_if.master_if[<%=axiidx%>].cdlast                    ) ,
                    <%if (bundle.interfaces.axiInt[mpu_io].params.checkType == 'ODD_PARITY_BYTE_ALL') { %>                                                                          
                        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_valid_chk            ( m_axi_if.master_if[<%=axiidx%>].cdvalidchk               ) ,
				        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_ready_chk            ( m_axi_if.master_if[<%=axiidx%>].cdreadychk               ) ,
                        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_data_chk             ( m_axi_if.master_if[<%=axiidx%>].cddatachk                ) ,
                        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_last_chk             ( m_axi_if.master_if[<%=axiidx%>].cdlastchk                ) ,
                     <%if (bundle.interfaces.axiInt[mpu_io].params.eTrace>0){%>
				        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>ac_trace_chk             ( m_axi_if.master_if[<%=axiidx%>].actracechk              ) ,
				        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cr_trace_chk             ( m_axi_if.master_if[<%=axiidx%>].crtracechk              ) ,
				        .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt[mpu_io].name%>cd_trace_chk             ( m_axi_if.master_if[<%=axiidx%>].cdtracechk              ) ,
                    <%}%>
                      <%}%>                                                                                                                                  
                    <%}%>
                    <%axiidx++%>
                <%}%>
            <%}%>                                                                                                                            
        <%});%>

  <%axiidx =0; obj.DmiInfo.forEach(function(bundle, idx) { %>
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_ready                ( m_axi_if.slave_if[<%=idx%>].awready             ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_valid                ( m_axi_if.slave_if[<%=idx%>].awvalid             ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_id                   ( m_axi_if.slave_if[<%=idx%>].awid                ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_addr                 ( m_axi_if.slave_if[<%=idx%>].awaddr              ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_burst                ( m_axi_if.slave_if[<%=idx%>].awburst             ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_len                  ( m_axi_if.slave_if[<%=idx%>].awlen               ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_lock                 ( m_axi_if.slave_if[<%=idx%>].awlock              ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_prot                 ( m_axi_if.slave_if[<%=idx%>].awprot              ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_size                 ( m_axi_if.slave_if[<%=idx%>].awsize              ) ,
      <%if (bundle.interfaces.axiInt.params.wQos>0) { %>                                                                                    
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_qos                  ( m_axi_if.slave_if[<%=idx%>].awqos               ) ,
      <%}%>
      <%if (bundle.interfaces.axiInt.params.wRegion>0){%>
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_region               ( m_axi_if.slave_if[<%=idx%>].awregion            ) ,
      <%}%>
      <%if (bundle.interfaces.axiInt.params.wAwUser > 0) { %>
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_user                 ( m_axi_if.slave_if[<%=idx%>].awuser              ) ,
      <%}%>
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_cache                ( m_axi_if.slave_if[<%=idx%>].awcache             ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_ready                 ( m_axi_if.slave_if[<%=idx%>].wready              ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_valid                 ( m_axi_if.slave_if[<%=idx%>].wvalid              ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_data                  ( m_axi_if.slave_if[<%=idx%>].wdata[<%=bundle.interfaces.axiInt.params.wData -1%> : 0]               ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_last                  ( m_axi_if.slave_if[<%=idx%>].wlast               ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_strb                  ( m_axi_if.slave_if[<%=idx%>].wstrb[<%=bundle.interfaces.axiInt.params.wData/8 -1%> : 0]               ) ,
      <%if (bundle.interfaces.axiInt.params.wWUser > 0){%>
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_user                  ( m_axi_if.slave_if[<%=idx%>].wuser               ) ,
      <%}%>
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_ready                 ( m_axi_if.slave_if[<%=idx%>].bready              ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_valid                 ( m_axi_if.slave_if[<%=idx%>].bvalid              ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_id                    ( m_axi_if.slave_if[<%=idx%>].bid                 ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_resp                  ( m_axi_if.slave_if[<%=idx%>].bresp               ) ,
      <%if(bundle.interfaces.axiInt.params.wBUser > 0){%>
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_user                  ( m_axi_if.slave_if[<%=idx%>].buser               ) ,
      <%}%>
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_ready                ( m_axi_if.slave_if[<%=idx%>].arready             ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_valid                ( m_axi_if.slave_if[<%=idx%>].arvalid             ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_addr                 ( m_axi_if.slave_if[<%=idx%>].araddr              ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_burst                ( m_axi_if.slave_if[<%=idx%>].arburst             ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_id                   ( m_axi_if.slave_if[<%=idx%>].arid                ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_len                  ( m_axi_if.slave_if[<%=idx%>].arlen               ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_lock                 ( m_axi_if.slave_if[<%=idx%>].arlock              ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_prot                 ( m_axi_if.slave_if[<%=idx%>].arprot              ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_size                 ( m_axi_if.slave_if[<%=idx%>].arsize              ) ,
      <%if (bundle.interfaces.axiInt.params.wQos>0) { %>                                                                                    
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_qos                  ( m_axi_if.slave_if[<%=idx%>].arqos               ) ,
      <%}%>
      <%if(bundle.interfaces.axiInt.params.wRegion>0){%>
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_region               ( m_axi_if.slave_if[<%=idx%>].arregion            ) ,
      <%}%>                                                                                                                                
      <%if(bundle.interfaces.axiInt.params.wArUser > 0){%>
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_user                 ( m_axi_if.slave_if[<%=idx%>].aruser              ) ,
      <%}%>
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_cache                ( m_axi_if.slave_if[<%=idx%>].arcache             ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_id                    ( m_axi_if.slave_if[<%=idx%>].rid                 ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_resp                  ( m_axi_if.slave_if[<%=idx%>].rresp[1:0]          ) ,
      <%if (bundle.interfaces.axiInt.params.wRUser > 0){%>
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_user                  ( m_axi_if.slave_if[<%=idx%>].ruser               ) ,
      <%}%>
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_ready                 ( m_axi_if.slave_if[<%=idx%>].rready              ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_valid                 ( m_axi_if.slave_if[<%=idx%>].rvalid              ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_data                  ( m_axi_if.slave_if[<%=idx%>].rdata[<%=bundle.interfaces.axiInt.params.wData - 1%> : 0]                ) ,
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_last                  ( m_axi_if.slave_if[<%=idx%>].rlast               ) ,
      <% axiidx++
  });%>

  <% obj.DiiInfo.forEach(function(bundle, idx) { %>
      <%if(bundle.configuration == 0){%>
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_ready                 ( m_axi_if.slave_if[<%=axiidx+idx%>].awready             ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_valid                 ( m_axi_if.slave_if[<%=axiidx+idx%>].awvalid             ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_id                    ( m_axi_if.slave_if[<%=axiidx+idx%>].awid                ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_addr                  ( m_axi_if.slave_if[<%=axiidx+idx%>].awaddr              ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_burst                 ( m_axi_if.slave_if[<%=axiidx+idx%>].awburst             ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_len                   ( m_axi_if.slave_if[<%=axiidx+idx%>].awlen               ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_lock                  ( m_axi_if.slave_if[<%=axiidx+idx%>].awlock              ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_prot                  ( m_axi_if.slave_if[<%=axiidx+idx%>].awprot              ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_size                  ( m_axi_if.slave_if[<%=axiidx+idx%>].awsize              ) ,
          <%if (bundle.interfaces.axiInt.params.wQos>0){%>
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_qos                   ( m_axi_if.slave_if[<%=axiidx+idx%>].awqos               ) ,
          <%}%>
          <%if (bundle.interfaces.axiInt.params.wRegion>0){%>
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_region                ( m_axi_if.slave_if[<%=axiidx+idx%>].awregion            ) ,
          <%}%>
          <%if(bundle.interfaces.axiInt.params.wAwUser > 0){%>
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_user                  ( m_axi_if.slave_if[<%=axiidx+idx%>].awuser              ) ,
          <%}%>
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>aw_cache                 ( m_axi_if.slave_if[<%=axiidx+idx%>].awcache             ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_ready                  ( m_axi_if.slave_if[<%=axiidx+idx%>].wready              ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_valid                  ( m_axi_if.slave_if[<%=axiidx+idx%>].wvalid              ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_data                   ( m_axi_if.slave_if[<%=axiidx+idx%>].wdata[<%=bundle.interfaces.axiInt.params.wData - 1%> : 0]               ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_last                   ( m_axi_if.slave_if[<%=axiidx+idx%>].wlast               ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_strb                   ( m_axi_if.slave_if[<%=axiidx+idx%>].wstrb[<%=bundle.interfaces.axiInt.params.wData/8 - 1%> : 0]               ) ,
          <%if(bundle.interfaces.axiInt.params.wWUser > 0){%>
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>w_user                   ( m_axi_if.slave_if[<%=axiidx+idx%>].wuser               ) ,
          <%}%>
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_ready                  ( m_axi_if.slave_if[<%=axiidx+idx%>].bready              ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_valid                  ( m_axi_if.slave_if[<%=axiidx+idx%>].bvalid              ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_id                     ( m_axi_if.slave_if[<%=axiidx+idx%>].bid                 ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_resp                   ( m_axi_if.slave_if[<%=axiidx+idx%>].bresp               ) ,
          <%if (bundle.interfaces.axiInt.params.wBUser > 0) { %>
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>b_user                   ( m_axi_if.slave_if[<%=axiidx+idx%>].buser               ) ,
          <%}%>
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_ready                 ( m_axi_if.slave_if[<%=axiidx+idx%>].arready             ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_valid                 ( m_axi_if.slave_if[<%=axiidx+idx%>].arvalid             ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_addr                  ( m_axi_if.slave_if[<%=axiidx+idx%>].araddr              ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_burst                 ( m_axi_if.slave_if[<%=axiidx+idx%>].arburst             ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_id                    ( m_axi_if.slave_if[<%=axiidx+idx%>].arid                ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_len                   ( m_axi_if.slave_if[<%=axiidx+idx%>].arlen               ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_lock                  ( m_axi_if.slave_if[<%=axiidx+idx%>].arlock              ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_prot                  ( m_axi_if.slave_if[<%=axiidx+idx%>].arprot              ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_size                  ( m_axi_if.slave_if[<%=axiidx+idx%>].arsize              ) ,
          <%if (bundle.interfaces.axiInt.params.wQos>0) { %>                                                                                     
              .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_qos                   ( m_axi_if.slave_if[<%=axiidx+idx%>].arqos               ) ,
          <%}%>                                                                                                                                 
          <%if(bundle.interfaces.axiInt.params.wRegion>0) { %>
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_region                ( m_axi_if.slave_if[<%=axiidx+idx%>].arregion            ) ,
          <%}%>
          <%if (bundle.interfaces.axiInt.params.wArUser > 0) { %>
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_user                  ( m_axi_if.slave_if[<%=axiidx+idx%>].aruser              ) ,
          <%}%>
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>ar_cache                 ( m_axi_if.slave_if[<%=axiidx+idx%>].arcache             ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_id                     ( m_axi_if.slave_if[<%=axiidx+idx%>].rid                 ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_resp                   ( m_axi_if.slave_if[<%=axiidx+idx%>].rresp[1:0]          ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_ready                  ( m_axi_if.slave_if[<%=axiidx+idx%>].rready              ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_valid                  ( m_axi_if.slave_if[<%=axiidx+idx%>].rvalid              ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_data                   ( m_axi_if.slave_if[<%=axiidx+idx%>].rdata[<%=bundle.interfaces.axiInt.params.wData - 1%> : 0]               ) ,
          .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_last                   ( m_axi_if.slave_if[<%=axiidx+idx%>].rlast               ) ,
          <%if (bundle.interfaces.axiInt.params.wRUser > 0) { %>                                                                                 
              .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.axiInt.name%>r_user               ( m_axi_if.slave_if[<%=axiidx+idx%>].ruser               ) ,
          <%}%>
      <%}%>
  <%});%>
  <% obj.PmaInfo.forEach(function(bundle, idx) { %>
      // Needs to add PMA interface/agent if support required 
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.masterInt.name%>REQn                  ( 1 ),
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.masterInt.name%>ACTIVE                (   ),
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.masterInt.name%>ACCEPTn               (   ),
      .<%=bundle.strRtlNamePrefix%>_<%=bundle.interfaces.masterInt.name%>DENY                  (   ),
  <%});%>
  <%for(var clock=0; clock < obj.Clocks.length; clock++) { %>
      <%if (clock == 0) { %>
          .<%=obj.Clocks[clock].interfaces[Object.keys(obj.Clocks[clock].interfaces)[0]].module%>clk      (<%=obj.Clocks[clock].name%>clk                          )
      <%}else{%>
          ,.<%=obj.Clocks[clock].interfaces[Object.keys(obj.Clocks[clock].interfaces)[0]].module%>clk      (<%=obj.Clocks[clock].name%>clk                          )
      <%}%>
      ,.<%=obj.Clocks[clock].interfaces[Object.keys(obj.Clocks[clock].interfaces)[0]].module%>test_en  (<%=obj.Clocks[clock].name%>test_en                      )
      <% if ( obj.Clocks[clock].name.indexOf('check') < 0 ) { %>
          ,.<%=obj.Clocks[clock].interfaces[Object.keys(obj.Clocks[clock].interfaces)[0]].module%>reset_n  (<%=obj.Clocks[clock].name%>reset_n                      )
      <%}%>
  <%}%>
    );
    //assertion to check DECERR/SLVERR
    always @(posedge ncore_system_tb_top.sys_clk) begin
        <%let ioidx_a=0;%>
            <%for(let idx = 0; idx < obj.nAIUs; idx++) { %>
                <%if(!(obj.AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
                    <%for (let mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
                        assert ((m_axi_if.master_if[<%=ioidx_a%>].bresp) != 2'b11)
                        else begin
                            $warning("DECERR detected(BRESP)! Warning issued.");
                        end
                        assert ((m_axi_if.master_if[<%=ioidx_a%>].bresp) != 2'b10)
                        else begin
                            $warning("SLVERR detected(BRESP)! Warning issued.");
                        end
                        assert ((m_axi_if.master_if[<%=ioidx_a%>].rresp) != 2'b11)
                        else begin
                            $warning("DECERR detected(RRESP)! Warning issued.");
                        end
                        assert ((m_axi_if.master_if[<%=ioidx_a%>].rresp) != 2'b10)
                        else begin
                            $warning("SLVERR detected(RRESP)! Warning issued.");
                        end
                    <%ioidx_a++;%>
                <%}%>
            <%}%>
        <%}%>
    end

    //assertion to check NON_DATA_ERROR
    /*always @(posedge ncore_system_tb_top.sys_clk) begin
        <%let chiidx_a=0;%>
            <%for(let idx = 0; idx < obj.nAIUs; idx++) { %>
                <%if((obj.AiuInfo[idx].fnNativeInterface.includes('CHI'))){%>
                        assert (ncore_system_tb_top.u_chip.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.unit.chi_aiu_chi_slave_if.rxdat_chan_handler.RXDATFLIT_pre_RespErr[1:0] != 2'b11)
                        else begin
                        $fatal("NON_DATA_ERROR(DATA_FLIT) detected! Failing the test.");
                        end
                        assert (ncore_system_tb_top.u_chip.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.unit.chi_aiu_chi_slave_if.rxrsp_chan_handler.RXRSPFLIT_RespErr[1:0] != 2'b11)
                        else begin
                        $fatal("NON_DATA_ERROR(RSP_FLIT) detected! Failing the test.");
                        end
                <%chiidx_a++;%>
            <%}%>
        <%}%>
    end*/


  initial begin
    $timeformat(-9,0,"ns",0);
    obj = new;
    obj.update_params();
    <%if(obj.useResiliency == 1){%>
        uvm_config_db #(virtual svt_apb_if)::set(uvm_root::get(),"uvm_test_top.m_env.m_amba_env.apb_system[0]","vif",m_fsc_apb_if);
        mission_fault_detected = new("mission_fault_detected");
        uvm_config_db#(uvm_event)::set(.cntxt( uvm_root::get()),
                                  .inst_name( "" ),
                                  .field_name( "mission_fault_detected" ),
                                  .value(mission_fault_detected));
    
    <%}%>
    uvm_config_db #(virtual svt_chi_if)::set(uvm_root::get(),"uvm_test_top.m_env.m_amba_env.chi_system[0]","vif",m_svt_chi_if);
        
    uvm_config_db #(virtual svt_axi_if)::set(uvm_root::get(),"uvm_test_top.m_env.m_amba_env.axi_system[0]","vif",m_axi_if);
    <%if(obj.DebugApbInfo.length > 0 && (obj.useResiliency == 1)){%>
        uvm_config_db #(virtual svt_apb_if)::set(uvm_root::get(),"uvm_test_top.m_env.m_amba_env.apb_system[1]","vif",m_apb_debug_if);
    <%}else if(obj.DebugApbInfo.length > 0){%>
        uvm_config_db #(virtual svt_apb_if)::set(uvm_root::get(),"uvm_test_top.m_env.m_amba_env.apb_system[0]","vif",m_apb_debug_if);
    <%}%>
    
    
    <%for(var idx = 0; idx < obj.nAIUs; idx++){ %>
        uvm_config_db#(virtual ncore_irq_if)::set(.cntxt( null ),
                                            .inst_name( "" ),
                                            .field_name( "m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if" ),
                                            .value(m_irq_<%=obj.AiuInfo[idx].strRtlNamePrefix%>_if));
    <% } %>
    <%for(var idx = 0; idx < obj.nDMIs; idx++){ %>
        uvm_config_db#(virtual ncore_irq_if)::set(.cntxt( null ),
                                            .inst_name( "" ),
                                            .field_name( "m_irq_<%=obj.DmiInfo[idx].strRtlNamePrefix%>_if" ),
                                            .value(m_irq_<%=obj.DmiInfo[idx].strRtlNamePrefix%>_if));
    <% } %>
    <%for(var idx = 0; idx < obj.nDIIs; idx++){ %>
        uvm_config_db#(virtual ncore_irq_if)::set(.cntxt( null ),
                                            .inst_name( "" ),
                                            .field_name( "m_irq_<%=obj.DiiInfo[idx].strRtlNamePrefix%>_if" ),
                                            .value(m_irq_<%=obj.DiiInfo[idx].strRtlNamePrefix%>_if));
    <% } %>
    <%for(var idx = 0; idx < obj.nDVEs; idx++){ %>
        uvm_config_db#(virtual ncore_irq_if)::set(.cntxt( null ),
                                            .inst_name( "" ),
                                            .field_name( "m_irq_<%=obj.DveInfo[idx].strRtlNamePrefix%>_if" ),
                                            .value(m_irq_<%=obj.DveInfo[idx].strRtlNamePrefix%>_if));
    <% } %>
    <%for(var idx = 0; idx < obj.nDCEs; idx++){ %>
        uvm_config_db#(virtual ncore_irq_if)::set(.cntxt( null ),
                                            .inst_name( "" ),
                                            .field_name( "m_irq_<%=obj.DceInfo[idx].strRtlNamePrefix%>_if" ),
                                            .value(m_irq_<%=obj.DceInfo[idx].strRtlNamePrefix%>_if));
    <% } %>
    `ifdef DUMP_ON
        if($test$plusargs("en_dump")) begin
            <%if(obj.CDN){%>
                <%if(obj.enInternalCode){%>
                    $vcdpluson;
                <%}else{%>
                    $shm_open ( "waves.shm" ) ;
                    $shm_probe ( "ACMS" ) ;
                <%}%>
            <%}else{%>
                $fsdbDumpvars("+all");
                $vcdpluson;
            <%}%>
        end
    `endif
    run_test("ncore_base_test");
    $finish;
  end

  assign dut_clk = sys_clk;
  assign soft_rstn = sys_rstn;

  <% if(obj.useResiliency == 1){ %>
       always @(posedge m_fsc_master_fault.mission_fault) begin
         $display("it_is_here_tb_top_01");
         if(m_fsc_master_fault.mission_fault === 1'b1) begin
           mission_fault_detected.trigger();
           $display("triggered mission_fault_detected @time: %0t",$time);
         end
       end
  <% } %>

  /*<%l_chi_idx=0;%>
  <%for(pidx = 0; pidx < obj.AiuInfo.length; pidx++) {%>
    <%if(obj.AiuInfo[pidx].fnNativeInterface.includes('CHI')){%>
      <%if(obj.AiuInfo[pidx].interfaces.chiInt.params.checkType != "NONE"){%>
          // Interface Parity signals
          always_comb begin
            foreach(chi<%=l_chi_idx%>_rx_req_flit_chk[idx]) begin
              chi<%=l_chi_idx%>_rx_req_flit_chk[idx] = (($countones(m_chi_if<%=l_chi_idx%>.tx_req_flit[(idx*8) +: 8])) % 2 == 0);
            end
            foreach(chi<%=l_chi_idx%>_rx_rsp_flit_chk[idx]) begin
              chi<%=l_chi_idx%>_rx_rsp_flit_chk[idx] = (($countones(m_chi_if<%=l_chi_idx%>.tx_rsp_flit[(idx*8) +: 8])) % 2 == 0);
            end
            foreach(chi<%=l_chi_idx%>_rx_dat_flit_chk[idx]) begin
              chi<%=l_chi_idx%>_rx_dat_flit_chk[idx] = (($countones(m_chi_if<%=l_chi_idx%>.tx_dat_flit[(idx*8) +: 8])) % 2 == 0);
            end
          end
      <%}%>
      <%l_chi_idx++%>
      <%}%>
  <%}%>*/
  <% if(obj.useResiliency) { %>
       fsys_fault_injector_checker fault_injector_checker(
          <% for(var clock=0; clock < obj.Clocks.length; clock++) { %>
               <% if (obj.Clocks[clock].name.includes("_check") == false){ %>
                    <%=obj.Clocks[clock].name%>clk,  
               <% } %>
          <% } %>
       soft_rstn);
  <% } %>

  //-----------------------------------------------------------------------------
  // Generate clocks and reset
  //-----------------------------------------------------------------------------
<%for(var clock=0; clock < obj.Clocks.length; clock++) { %>
      ncore_clk_rst_module <%=obj.Clocks[clock].name%>_gen(.clk_fr(m_clk_if_<%=obj.Clocks[clock].name%>.clk), .clk_tb(<%=obj.Clocks[clock].name%>clk_sync), .rst(m_clk_if_<%=obj.Clocks[clock].name%>.reset_n));
      defparam <%=obj.Clocks[clock].name%>_gen.CLK_PERIOD = <%=obj.Clocks[clock].params.period%>;
  <%}%>
  
  // Use first customer defined clock as sys_clk. Customer needs to confirm to this
  assign sys_clk = m_clk_if_<%=obj.Clocks[0].name%>.clk;
  assign sys_rstn = m_clk_if_<%=obj.Clocks[0].name%>.reset_n;

endmodule: ncore_system_tb_top

<%
//Embedded javascript code to figure number of blocks
  var _child_blkid = [];
  var _child_blk   = [];
  var pidx = 0;
  var ridx = 0;
  var chiaiu_idx = 0;
  var axiaiu_idx = 0;
  var aceaiu_idx = 0;
  var aceliteeaiu_idx = 0;
  var ioaiu_idx = 0;
  var has_chib  = 0;
  var has_chia  = 0;
  var has_chie  = 0;
  var initiatorAgents = obj.AiuInfo.length ;
  var nGPRA = 0;
  var nDII = 0;
  var nDMI = 0;
  var nAXI = 0;
  var nACE = 0;
  var nACELITE = 0;
  var nCHI = 0;
  var nINIT = 0;
  var nAIU = 0;
  var cnt_multi = 200*(obj.AiuInfo.length+obj.DceInfo.length+obj.DmiInfo.length+obj.DveInfo.length+obj.DiiInfo.length); 


  for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
      _child_blkid[pidx] = 'chiaiu' + chiaiu_idx;
      _child_blk[pidx]   = 'chiaiu';
      chiaiu_idx++;
      if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B') {
        has_chib  = 1;
      }
      if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') {
        has_chie  = 1;
      }
    } else {
      _child_blkid[pidx] = 'ioaiu' + ioaiu_idx;
      _child_blk[pidx]   = 'ioaiu';
      ioaiu_idx += obj.AiuInfo[pidx].nNativeInterfacePorts;
    }
    if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE')|| (obj.AiuInfo[pidx].fnNativeInterface == 'ACE5') ){
      aceaiu_idx += obj.AiuInfo[pidx].nNativeInterfacePorts;
      has_ace  = 1 ;
    } 
  
  } 


  for(pidx = 0; pidx < obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
      _child_blkid[pidx] = 'chiaiu' + chiaiu_idx;
      _child_blk[pidx]   = 'chiaiu';
      chiaiu_idx++;
    } else {
      _child_blkid[pidx] = 'ioaiu' + ioaiu_idx;
      _child_blk[pidx]   = 'ioaiu';
      ioaiu_idx+= obj.AiuInfo[pidx].nNativeInterfacePorts;
    }
    if((obj.AiuInfo[pidx].fnNativeInterface == 'AXI4')|| (obj.AiuInfo[pidx].fnNativeInterface == 'AXI5') ) {
      axiaiu_idx+= obj.AiuInfo[pidx].nNativeInterfacePorts;
    } else if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E')){
        aceliteeaiu_idx+= obj.AiuInfo[pidx].nNativeInterfacePorts;
    } else if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE')|| (obj.AiuInfo[pidx].fnNativeInterface == 'ACE5') ){
        aceaiu_idx+= obj.AiuInfo[pidx].nNativeInterfacePorts;
    }
  }
  nINIT = chiaiu_idx + ioaiu_idx;

  for(pidx = 0; pidx < obj.nDCEs; pidx++) {
    ridx = pidx + obj.nAIUs;
    _child_blkid[ridx] = 'dce' + pidx;
    _child_blk[ridx]   = 'dce';
  }
  for(pidx =  0; pidx < obj.nDMIs; pidx++) {
    ridx = pidx + obj.nAIUs + obj.nDCEs;
    _child_blkid[ridx] = 'dmi' + pidx;
    _child_blk[ridx]   = 'dmi';
  }
  for(pidx = 0; pidx < obj.nDIIs; pidx++) {
    ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
    _child_blkid[ridx] = 'dii' + pidx;
    _child_blk[ridx]   = 'dii';
  }
  for(pidx = 0; pidx < obj.nDVEs; pidx++) {
    ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs;
    _child_blkid[ridx] = 'dve' + pidx;
    _child_blk[ridx]   = 'dve';
  }
  nGPRA = obj.AiuInfo[0].nGPRA;
  nDII = obj.nDIIs;
  nDMI = obj.nDMIs;
  nACE = 0;
  nAIU = obj.nAIUs;
%>


int interval_delay_cycle=0;
function int reverse_value(int dii_no,int array_in);
  int reverse,j;

  j = dii_no-1;
  for(int i=0;i<dii_no;i++)begin
    reverse[j]=array_in[i];
    j--;
  end 
  return reverse;
endfunction


function int get_slv_id(bit[<%=obj.wSysAddr-1%>:0] addr,int port_sel[$]);
  int id,slv_id;

  if(port_sel.size()==1)begin
    case(addr[port_sel[0]])
    'd0:begin
          id = slv_id;
        end
    'd1:begin
          id = slv_id+1;
        end
    endcase
  end 
  <% if(obj.AiuInfo[0].InterleaveInfo.dmi4WIFV.length > 0) {%>
       <%var a=obj.AiuInfo[0].InterleaveInfo.dmi4WIFV[0].PrimaryBits[0];
       var b=obj.AiuInfo[0].InterleaveInfo.dmi4WIFV[0].PrimaryBits[1];%>
       if(port_sel.size()==2)begin
         case({addr[<%=b%>],addr[<%=a%>]})
         'd0:begin
               id = slv_id;
             end
         'd1:begin
               id = slv_id+1;
             end
         'd2:begin
               id = slv_id+2;
             end
         'd3:begin
               id = slv_id+3;
             end
         endcase
       end 
  <% } %>
  <% if(obj.AiuInfo[0].InterleaveInfo.dmi16WIFV.length > 0) {%>
       <%var a=obj.AiuInfo[0].InterleaveInfo.dmi16WIFV[0].PrimaryBits[0];
       var b=obj.AiuInfo[0].InterleaveInfo.dmi16WIFV[0].PrimaryBits[1];
       var c=obj.AiuInfo[0].InterleaveInfo.dmi16WIFV[0].PrimaryBits[2];
       var d=obj.AiuInfo[0].InterleaveInfo.dmi16WIFV[0].PrimaryBits[3];%>
	   
       if(port_sel.size()==4)begin
         id = {addr[<%=d%>],addr[<%=c%>],addr[<%=b%>],addr[<%=a%>]};
       end 
  
  <% } %>
  return id;
endfunction


function bit[<%=nINIT%>-1:0] port_sel_logic(bit[<%=obj.wSysAddr-1%>:0] addr,bit [10:0] port_sel[],int index,int no_intf);
  bit[<%=nINIT%>-1:0] enable;
  int a,b;

  <% var aidx=0;var bidx=0;var cidx=0;for(pidx = 0; pidx <  obj.nAIUs; pidx++) { if(obj.AiuInfo[pidx].nNativeInterfacePorts >1) {%> 
       <% if(obj.AiuInfo[pidx].nNativeInterfacePorts == 4) {%>
            <% var a= obj.AiuInfo[pidx].aNcaiuIntvFunc.aPrimaryBits[0];
            var b= obj.AiuInfo[pidx].aNcaiuIntvFunc.aPrimaryBits[1];%>
            <%  bidx=1;%>
       <% } %>
       <% if(obj.AiuInfo[pidx].nNativeInterfacePorts == 2) {%>
            <% var a= obj.AiuInfo[pidx].aNcaiuIntvFunc.aPrimaryBits[0];%>
            <%  aidx=1;%>
       <% } %>
       <% if(obj.AiuInfo[pidx].nNativeInterfacePorts == 8) {%>
            <% var a= obj.AiuInfo[pidx].aNcaiuIntvFunc.aPrimaryBits[0];
            var b= obj.AiuInfo[pidx].aNcaiuIntvFunc.aPrimaryBits[1];
            var c= obj.AiuInfo[pidx].aNcaiuIntvFunc.aPrimaryBits[2];%>
            <%  cidx=1;%>
       <% } %>
       <%pidx = pidx+obj.AiuInfo[pidx].nNativeInterfacePorts;%>
  <% } %>
  <% } %>
  <% if(bidx ==1) {%>
       enable='d0;
       if(no_intf==4)begin
         case(addr[<%=b%>:<%=a%>])
         'd0:begin
               enable[index] = 1;
             end
         'd1:begin
               enable[index+1] = 1;
             end
         'd2:begin
               enable[index+2] = 1;
             end
         'd3:begin
               enable[index+3] = 1;
             end
         endcase
       end
  <% } %>
  <% if(cidx ==1) {%>
       enable='d0;
       if(no_intf==8)begin
         case(addr[<%=c%>:<%=a%>])
         'd0:begin
               enable[index] = 1;
             end
         'd1:begin
               enable[index+1] = 1;
             end
         'd2:begin
               enable[index+2] = 1;
             end
         'd3:begin
               enable[index+3] = 1;
             end
         'd4:begin
               enable[index+4] = 1;
             end
         'd5:begin
               enable[index+5] = 1;
             end
         'd6:begin
               enable[index+6] = 1;
             end
         'd7:begin
               enable[index+7] = 1;
             end
         endcase
       end
  <% } %>

  <% if(aidx ==1) {%>
       enable='d0;
       if(no_intf==2)begin
         case(addr[<%=a%>])
         'd0:begin
               enable[index] = 1;
             end
         'd1:begin
               enable[index+1] = 1;
             end
         endcase
       
       end
  
  <% } %>
  return enable;
endfunction

//-----------------------------------------------------------
/** Test specific method to read performance metrics from agents */
//-----------------------------------------------------------
function void retrieve_perf_metrics(string msg_id_str, svt_chi_rn_agent my_agent, int unsigned perf_rec_interval, int unsigned master_id,int rd,int wr);
  svt_chi_transaction out_xacts[$];
  real  outvalue;

  // Retrieve rn%0d metrics
  `uvm_info(msg_id_str, "perf_tracking:: rn performance metrics ::", UVM_NONE)

  `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d Latency Unit: %0s  Throughput unit:%0s ", master_id, my_agent.perf_status.get_unit_for_latency_metrics(), my_agent.perf_status.get_unit_for_throughput_metrics()), UVM_NONE)

  if(wr==1)begin
     outvalue = my_agent.perf_status.get_perf_metric(svt_chi_node_perf_status::MAX_WRITE_LATENCY, out_xacts, 1, perf_rec_interval);
     `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d max wr latency %0f", master_id, outvalue), UVM_NONE)
     if (out_xacts.size())
       `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d max wr latency xact %0s", master_id,`SVT_CHI_PRINT_PREFIX(out_xacts[0])), UVM_LOW)

     outvalue = my_agent.perf_status.get_perf_metric(svt_chi_node_perf_status::MIN_WRITE_LATENCY, out_xacts, 1, perf_rec_interval);
     `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d min wr latency %0f", master_id, outvalue), UVM_NONE)
     if (out_xacts.size())
       `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d min wr latency xact %0s", master_id, `SVT_CHI_PRINT_PREFIX(out_xacts[0])), UVM_LOW)

     outvalue = my_agent.perf_status.get_perf_metric(svt_chi_node_perf_status::AVG_WRITE_LATENCY, out_xacts, , perf_rec_interval);
     `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d avg wr latency %0f", master_id, outvalue), UVM_NONE)

     outvalue = my_agent.perf_status.get_perf_metric(svt_chi_node_perf_status::WRITE_THROUGHPUT, out_xacts, ,perf_rec_interval);
     `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d wr throughput %0f", master_id, outvalue), UVM_NONE)
  end

  if(rd==1)begin
     outvalue = my_agent.perf_status.get_perf_metric(svt_chi_node_perf_status::MAX_READ_LATENCY, out_xacts, 1, perf_rec_interval);
     `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d max rd latency %0f", master_id, outvalue), UVM_NONE)
     if (out_xacts.size())
       `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d max rd latency xact %0s", master_id,`SVT_CHI_PRINT_PREFIX(out_xacts[0])), UVM_LOW)

     outvalue = my_agent.perf_status.get_perf_metric(svt_chi_node_perf_status::MIN_READ_LATENCY, out_xacts, 1, perf_rec_interval);
     `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d min rd latency %0f", master_id, outvalue), UVM_NONE)
     if (out_xacts.size())
       `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d min rd latency xact %0s", master_id, `SVT_CHI_PRINT_PREFIX(out_xacts[0])), UVM_LOW)

     outvalue = my_agent.perf_status.get_perf_metric(svt_chi_node_perf_status::AVG_READ_LATENCY, out_xacts, , perf_rec_interval);
     `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d avg rd latency %0f", master_id, outvalue), UVM_NONE)

     outvalue = my_agent.perf_status.get_perf_metric(svt_chi_node_perf_status::READ_THROUGHPUT, out_xacts, ,perf_rec_interval);
     `uvm_info(msg_id_str, $sformatf("perf_tracking:: rn %0d rd throughput %0f", master_id, outvalue), UVM_NONE)
  end

endfunction // retrieve_perf_metrics
