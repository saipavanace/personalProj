`timescale 1 ns/1 ps

`include "snps_compile.sv"
`include "<%=obj.BlockId%>_connect_source2target_slv_if.sv"

<% if(obj.useResiliency) { %>
`include "fault_injector_checker.sv"
`include "placeholder_connectivity_checker.sv"
<% } %>
<% if(obj.USE_VIP_SNPS) { %>
`define AXI_VIP_IF axi_vip_if.slave_if[0]
<% } %>
`define AXI_INHOUSE_IF m_<%=obj.BlockId%>_axi_slv_if
<% if(obj.useCmc) { %> 
<%    
    var funitId = [];
    var nWays     = obj.DutInfo.ccpParams.nWays;
    var nSets     = obj.DutInfo.ccpParams.nSets;
    var nTagBanks = obj.DutInfo.ccpParams.nTagBanks;
    var nDataBanks = obj.DutInfo.ccpParams.nDataBanks;
    var wfunit    = obj.DmiInfo[obj.Id].interfaces.uSysIdInt.params.wFUnitIdV[0];
   for( var i=0;i<obj.DmiInfo[obj.Id].nAius;i++) {
     funitId[obj.AiuInfo[i].nUnitId] = obj.AiuInfo[i].FUnitId;
   }
 %>
<% } %>

<% var has_secded = 0;
 if (obj.DmiInfo[obj.Id].useCmc) {
   if ((obj.DmiInfo[obj.Id].ccpParams.TagErrInfo === "SECDED") || (obj.DmiInfo[obj.Id].ccpParams.DataErrInfo === "SECDED") || (obj.DmiInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY") || (obj.DmiInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) {
    has_secded = 1;
    console.log("has_secded: "+has_secded);
   }
 }
 var wbuffer_fnerrdetectcorrect = 0;
 if (obj.DmiInfo[obj.Id].fnErrDetectCorrect == "SECDED" || obj.DmiInfo[obj.Id].fnErrDetectCorrect == "PARITYENTRY") {
   wbuffer_fnerrdetectcorrect = 1;
 }
%>

module tb_top;

/////////////////////////////////////////////////////////////
// JS Checks
/////////////////////////////////////////////////////////////
 <%
     var wRegion          = obj.DmiInfo[obj.Id].interfaces.axiInt.params.wRegion    ;
     var wAwUser          = obj.DmiInfo[obj.Id].interfaces.axiInt.params.wAwUser    ;
     var wArUser          = obj.DmiInfo[obj.Id].interfaces.axiInt.params.wArUser    ;
     var wWUser           = obj.DmiInfo[obj.Id].interfaces.axiInt.params.wWUser     ;
     var wBUser           = obj.DmiInfo[obj.Id].interfaces.axiInt.params.wBUser     ;
     var wRUser           = obj.DmiInfo[obj.Id].interfaces.axiInt.params.wRUser     ;
     var wQos             = obj.DmiInfo[obj.Id].interfaces.axiInt.params.wQos       ;
     var wProt            = obj.DmiInfo[obj.Id].interfaces.axiInt.params.wProt      ;
     var wLock            = obj.DmiInfo[obj.Id].interfaces.axiInt.params.wLock      ;
     var wNDPTX = [];
     var wDPUSERTX = [];
for (var i = 0; i < obj.DutInfo.nSmiTx; i++) { 
      wNDPTX[i] = obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiNDP; 
      if(obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.nSmiDPvc){
      wDPUSERTX[i] = obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiDPuser;  
      }
}
   %>


//-----------------------------------------------------------------------------
// Test and Env packages
//-----------------------------------------------------------------------------
import <%=obj.BlockId%>_test_lib_pkg::*;
import <%=obj.BlockId%>_env_pkg::*;
import <%=obj.BlockId%>_smi_agent_pkg::*;
`include "snps_import.sv"
//-----------------------------------------------------------------------------
// Clocks and Reset
//-----------------------------------------------------------------------------
logic dut_clk;
logic tb_clk;
logic fr_clk;
logic tb_rstn;
logic reset_n_1d;
logic ccp_clk;
logic ccp_rstn;
reg dmi_corr_uncorr_flag;
bit [<%=nWays%>-1:0] nru_counter;

int memHntTo;
   bit inject_ttdebug;

   int singleBitPct, doubleBitPct;
   
<% if(obj.useResiliency) { %>
 logic[1023:0] slv_req_corruption_vector = 1024'b0;
 logic[1023:0] slv_data_corruption_vector = 1024'b0;
 //logic[WSMIADDR-1:0] smi_req_addr_modified;
 logic[<%=obj.DmiInfo[obj.Id].wData%>-1:0] smi_req_data_modified;  //TODO checkme: flat view of txn payload data for error injection

 logic bist_bist_next_ack;
 logic bist_domain_is_on;
 logic fault_mission_fault;
 logic fault_latent_fault;
 logic fault_cerr_over_thres_fault;
<% } %>
//----------------------------------------------------------------------------
// Pipelined signals
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Interfaces
//----------------------------------------------------------------------------
<%=obj.BlockId%>_stall_if <%=obj.BlockId%>_sb_stall_if(); // PERF_CNT STALL_IF
initial uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::set(null, "", "<%=obj.BlockId%>_m_top_stall_if",       <%=obj.BlockId%>_sb_stall_if); 

// Latency if
<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_latency_if <%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_sb_latency_if(); // PERF_CNT Latency_IF
initial uvm_config_db#(virtual <%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_latency_if)::set(null, "", "<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_m_top_latency_if",       <%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_sb_latency_if);

<% var NSMIIFTX = obj.DutInfo.nSmiRx;
 for (var i = 0; i < NSMIIFTX; i++) { %>
  <%=obj.BlockId%>_smi_if    m_smi<%=i%>_tx_smi_if(dut_clk, soft_rstn,"m_smi<%=i%>_tx");

<% } %>
 <% var NSMIIFRX = obj.DutInfo.nSmiTx;
 for (var i = 0; i < NSMIIFRX; i++) { %>
  <%=obj.BlockId%>_smi_if    m_smi<%=i%>_rx_smi_if(dut_clk, soft_rstn,"m_smi<%=i%>_rx");

<% } %>

<% if(obj.USE_VIP_SNPS) { %>
svt_axi_if axi_vip_if();
 //Assign the reset pin from the reset interface to the reset pins from the VIP interface.
assign axi_vip_if.slave_if[0].aresetn = soft_rstn;
assign axi_vip_if.common_aclk = dut_clk;
<% } %>
<%=obj.BlockId%>_axi_if m_<%=obj.BlockId%>_axi_slv_if(dut_clk, soft_rstn);
<% if(obj.useCmc) { %>
  <%=obj.BlockId%>_ccp_if  u_ccp_if( .clk(dut_clk),.rst_n(soft_rstn)); 
<% } %>


//Q-channel interface
<%=obj.BlockId%>_q_chnl_if m_q_chnl_if(fr_clk, tb_rstn);

uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
uvm_event inject_err = ev_pool.get("inject_err");
uvm_event ev_always_inject_error = ev_pool.get("ev_always_inject_error");
uvm_event         toggle_clk;
uvm_event         toggle_rstn;

<% if(obj.INHOUSE_APB_VIP) { %>
<%=obj.BlockId%>_apb_if apb_if();

uvm_event         injectSingleErrHtt;
uvm_event         injectDoubleErrHtt;

uvm_event         injectSingleErrwbuffer1;
uvm_event         injectDoubleErrwbuffer1;
uvm_event         inject_multi_block_single_double_Errwbuffer1;
uvm_event         inject_multi_block_double_Errwbuffer1;
uvm_event         inject_multi_block_single_Errwbuffer1;
uvm_event         injectAddrErrBuffer1;

uvm_event         injectSingleErrwbuffer0;
uvm_event         injectDoubleErrwbuffer0;
uvm_event         inject_multi_block_single_double_Errwbuffer0;
uvm_event         inject_multi_block_double_Errwbuffer0;
uvm_event         inject_multi_block_single_Errwbuffer0;
uvm_event         injectAddrErrBuffer0;

<% if(obj.useCmc) { %>
   <%for( var i=0;i<nTagBanks;i++){%>
uvm_event         injectSingleErrTag<%=i%>;
uvm_event         injectDoubleErrTag<%=i%>;
uvm_event         inject_multi_block_single_double_ErrTag<%=i%>;
uvm_event         inject_multi_block_double_ErrTag<%=i%>;
uvm_event         inject_multi_block_single_ErrTag<%=i%>;
uvm_event         injectAddrErrTag<%=i%>;
   <% } %>
   <%for( var i=0;i<nDataBanks;i++){%>
uvm_event         injectSingleErrData<%=i%>;
uvm_event         injectDoubleErrData<%=i%>;
uvm_event         inject_multi_block_single_double_ErrData<%=i%>;
uvm_event         inject_multi_block_double_ErrData<%=i%>;
uvm_event         inject_multi_block_single_ErrData<%=i%>;
uvm_event         injectAddrErrData<%=i%>;
   <% } %>
<% } %>

<%if(obj.DmiInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
uvm_event         setPlruSingleDataErrInj, setPlruDoubleDataErrInj;
uvm_event         setPlruAddrErrInj;
<% } %>
<% if (obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].fnMemType == "SRAM") { %>
uvm_event         injectSingleDataErrMrdSRAM;
uvm_event         injectDoubleDataErrMrdSRAM;
uvm_event         injectSingleAddrErrMrdSRAM;
<% } %>
<% if (obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].fnMemType == "SRAM") { %>
uvm_event         injectSingleDataErrCmdSRAM;
uvm_event         injectDoubleDataErrCmdSRAM;
uvm_event         injectSingleAddrErrCmdSRAM;
<% } %>
uvm_event         checkCELR;
uvm_event         checkUELR;

uvm_event         forceClkgate;
uvm_event         releaseClkgate;;
<% } %>

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

<% if((obj.assertOn) & (obj.DmiInfo[obj.Id].fnEnableQos))  { %>
`ifdef OVL_ASSERT_ON
initial begin
// turn off the OVL assertion for error tests which can corrupt the rbid in the DTW Req
  if($test$plusargs("c_wr_buff_rb_counter_ovl_dis"))begin
      $display("Disable OVL assertion for Coh Wr Buffer RB counter");
      force tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.c_rb_coutner.enable = 1'b0;
      force tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.c_Threshold.enable = 1'b0;
      <% if (obj.DmiInfo[obj.Id].ResilienceInfo.enableUnitDuplication) { %>
        $display("Disable OVL assertion for Coh Wr Buffer RB counter in the duplicate unit");
        force tb_top.dut.dup_unit.dmi_protocol_control.c_write_buffer.c_rb_coutner.enable = 1'b0;
        force tb_top.dut.dup_unit.dmi_protocol_control.c_write_buffer.c_Threshold.enable = 1'b0;
      <% } %>
  end

end
`endif
<% } %>
bit enable=1;
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
    $display("triggered reset event @time: %0t",$time);
    soft_rstn_en = ~soft_rstn_en;
end

assign soft_rstn = soft_rstn_en ? tb_rstn : 0;


  // interface to tap internal csr signal
  dmi_csr_probe_if u_csr_probe_if(.clk(dut_clk),.resetn(soft_rstn));

  <%=obj.BlockId%>_rtl_if  u_<%=obj.BlockId%>_rtl_if(.clk(dut_clk),.rst_n(soft_rstn));
  <%=obj.BlockId%>_tt_if   u_<%=obj.BlockId%>_tt_if(.clk(dut_clk),.rst_n(soft_rstn));

  <%=obj.BlockId%>_read_probe_if   u_<%=obj.BlockId%>_read_probe_if(.clk(dut_clk),.rst_n(soft_rstn));
  <%=obj.BlockId%>_write_probe_if   u_<%=obj.BlockId%>_write_probe_if(.clk(dut_clk),.rst_n(soft_rstn));

<% for (var i = 0; i < NSMIIFTX; i++) { %>
<% if(obj.testBench == 'dmi') { %>
`ifndef VCS
 assign m_smi<%=i%>_tx_smi_if.RDY_NOT_ASSERTED_TIMEOUT = 500000;
`endif // `ifndef VCS
<% } else {%>
 assign m_smi<%=i%>_tx_smi_if.RDY_NOT_ASSERTED_TIMEOUT = 500000;
<% } %>
<% } %>
<% for (var i = 0; i < NSMIIFRX; i++) { %>
<% if(obj.testBench == 'dmi') { %>
`ifndef VCS
 assign m_smi<%=i%>_rx_smi_if.RDY_NOT_ASSERTED_TIMEOUT = 500000;
`endif // `ifndef VCS
<% } else {%>
 assign m_smi<%=i%>_rx_smi_if.RDY_NOT_ASSERTED_TIMEOUT = 500000;
<% } %>
<% } %>



<% if(obj.INHOUSE_APB_VIP) { %>
 assign apb_if.clk = dut_clk;
 assign apb_if.rst_n = soft_rstn;
<% } %>

//-----------------------------------------------------------------------------
// DUT and Reactive BFMs
//-----------------------------------------------------------------------------



<% if(obj.useCmc && obj.DmiInfo[obj.Id].useWayPartitioning) { %>

   typedef bit [<%=wfunit*obj.DmiInfo[obj.Id].nAius - 1%> :0]     aiu_funit_id_t;
   aiu_funit_id_t                         aiu_funit_id;
<% }  %>

   //FIXME: Need similar stuff for Synopsis
 `ifdef INHOUSE_AXI
<%if (wProt==0){%>
                         assign `AXI_INHOUSE_IF.awprot = 0;
                         assign `AXI_INHOUSE_IF.arprot = 0;
<% }  %>
<%if (wQos == 0){%>
                          assign `AXI_INHOUSE_IF.awqos = 0;
                          assign `AXI_INHOUSE_IF.arqos = 0;
<% }  %>

<%if (wLock == 0){%>
                          assign `AXI_INHOUSE_IF.Lock = 0;
                          assign `AXI_INHOUSE_IF.Lock = 0;
<% }  %>

<%if (wRegion==0){%>
                          assign `AXI_INHOUSE_IF.awregion = 0;
                          assign `AXI_INHOUSE_IF.arregion = 0;
<% } %>
<%if (wAwUser==0){%>
                          assign `AXI_INHOUSE_IF.awuser = 0;
<% } %>
<%if (wWUser==0){%>
                          assign `AXI_INHOUSE_IF.wuser = 0;
<% } %>
<%if (wBUser==0){%>
                          assign `AXI_INHOUSE_IF.buser = 0;
<% } %>
<%if (wArUser==0){%>
                          assign `AXI_INHOUSE_IF.aruser = 0;
<% } %>
<%if (wRUser==0){%>
                          assign `AXI_INHOUSE_IF.ruser = 0;
<% } %>
 `endif //  `ifdef INHOUSE_AXI

<%  if(obj.USE_VIP_SNPS) { %>
   <%=obj.BlockId%>_connect_source2target_slv_if connect_<%=obj.BlockId%> (`AXI_INHOUSE_IF, `AXI_VIP_IF);
<% } %>

//dmi_0 dut   (
<%=obj.instanceMap[obj.DutInfo.strRtlNamePrefix]%> dut   (
<%  if(obj.INHOUSE_APB_VIP) { %>
    .<%=obj.DmiInfo[obj.Id].interfaces.apbInt.name%>paddr                (apb_if.paddr),
    .<%=obj.DmiInfo[obj.Id].interfaces.apbInt.name%>pwrite               (apb_if.pwrite),
    .<%=obj.DmiInfo[obj.Id].interfaces.apbInt.name%>psel                 (apb_if.psel),
    .<%=obj.DmiInfo[obj.Id].interfaces.apbInt.name%>penable              (apb_if.penable),
    .<%=obj.DmiInfo[obj.Id].interfaces.apbInt.name%>prdata               (apb_if.prdata),
    .<%=obj.DmiInfo[obj.Id].interfaces.apbInt.name%>pwdata               (apb_if.pwdata),
    .<%=obj.DmiInfo[obj.Id].interfaces.apbInt.name%>pready               (apb_if.pready),
    .<%=obj.DmiInfo[obj.Id].interfaces.apbInt.name%>pslverr              (apb_if.pslverr),
<%  if(obj.DmiInfo[obj.Id].interfaces.apbInt.params.wProt !== 0) { %>
    .<%=obj.DmiInfo[obj.Id].interfaces.apbInt.name%>pprot                (apb_if.pprot),
<% } %>
<%  if(obj.DmiInfo[obj.Id].interfaces.apbInt.params.wStrb !== 0) { %>
    .<%=obj.DmiInfo[obj.Id].interfaces.apbInt.name%>pstrb                (apb_if.pstrb),
<% } %>
    .<%=obj.DmiInfo[obj.Id].interfaces.irqInt.name%>c                        (apb_if.IRQ_c),
    .<%=obj.DmiInfo[obj.Id].interfaces.irqInt.name%>uc                       (apb_if.IRQ_uc),
<% } %>



<%if (wProt >0){%>
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>aw_prot         ( `AXI_INHOUSE_IF.awprot              ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>ar_prot         ( `AXI_INHOUSE_IF.arprot              ) ,
<% } %>
<%if (wQos >0){%>
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>aw_qos          ( `AXI_INHOUSE_IF.awqos               ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>ar_qos          ( `AXI_INHOUSE_IF.arqos               ) ,
<% } %>
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>aw_ready        ( `AXI_INHOUSE_IF.awready             ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>aw_valid        ( `AXI_INHOUSE_IF.awvalid             ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>aw_id           ( `AXI_INHOUSE_IF.awid                ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>aw_addr         ( `AXI_INHOUSE_IF.awaddr              ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>aw_burst        ( `AXI_INHOUSE_IF.awburst             ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>aw_len          ( `AXI_INHOUSE_IF.awlen               ) ,
<%if (wLock >0){%>
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>aw_lock         ( `AXI_INHOUSE_IF.awlock              ) ,
<% } %>
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>aw_size         ( `AXI_INHOUSE_IF.awsize              ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>w_ready         ( `AXI_INHOUSE_IF.wready              ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>w_valid         ( `AXI_INHOUSE_IF.wvalid              ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>w_data          ( `AXI_INHOUSE_IF.wdata               ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>w_last          ( `AXI_INHOUSE_IF.wlast               ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>w_strb          ( `AXI_INHOUSE_IF.wstrb               ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>b_ready         ( `AXI_INHOUSE_IF.bready              ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>b_valid         ( `AXI_INHOUSE_IF.bvalid              ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>b_id            ( `AXI_INHOUSE_IF.bid                 ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>b_resp          ( `AXI_INHOUSE_IF.bresp               ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>ar_ready        ( `AXI_INHOUSE_IF.arready             ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>ar_valid        ( `AXI_INHOUSE_IF.arvalid             ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>ar_addr         ( `AXI_INHOUSE_IF.araddr              ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>ar_burst        ( `AXI_INHOUSE_IF.arburst             ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>ar_id           ( `AXI_INHOUSE_IF.arid                ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>ar_len          ( `AXI_INHOUSE_IF.arlen               ) ,
<%if (wLock >0){%>
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>ar_lock         ( `AXI_INHOUSE_IF.arlock              ) ,
<% } %>
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>ar_size         ( `AXI_INHOUSE_IF.arsize              ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>r_id            ( `AXI_INHOUSE_IF.rid                 ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>r_resp          ( `AXI_INHOUSE_IF.rresp[1:0]          ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>r_ready         ( `AXI_INHOUSE_IF.rready              ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>r_valid         ( `AXI_INHOUSE_IF.rvalid              ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>r_data          ( `AXI_INHOUSE_IF.rdata               ) ,
     .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>r_last          ( `AXI_INHOUSE_IF.rlast               ) ,
    .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>aw_cache        ( `AXI_INHOUSE_IF.awcache             ) ,
    .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>ar_cache        ( `AXI_INHOUSE_IF.arcache             ) ,
<%if (wRegion>0){%>
    .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>aw_region       ( `AXI_INHOUSE_IF.awregion            ) ,
    .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>ar_region       ( `AXI_INHOUSE_IF.arregion            ) ,
<% } %>
<%if (wAwUser >0){%>
    .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>aw_user         ( `AXI_INHOUSE_IF.awuser              ) ,
<% } %>
<%if (wWUser >0){%>
    .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>w_user         ( `AXI_INHOUSE_IF.wuser              ) ,
<% } %>
<%if (wBUser>0){%>
    .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>b_user         ( `AXI_INHOUSE_IF.buser              ) ,
<% } %>
<%if (wArUser>0){%>
    .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>ar_user         ( `AXI_INHOUSE_IF.aruser              ) ,
<% } %>
<%if (wRUser>0){%>
    .<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>r_user         ( `AXI_INHOUSE_IF.ruser              ) ,
<% } %>
<%for (var i = 0; i < NSMIIFRX; i++) { %>
.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_valid         (m_smi<%=i%>_rx_smi_if.smi_msg_valid ) ,
.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name %>ndp_msg_valid        (m_smi<%=i%>_rx_smi_if.smi_msg_valid ) ,
.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name %>ndp_msg_ready        (m_smi<%=i%>_rx_smi_if.smi_msg_ready  ) ,
.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name %>ndp_ndp_len          (m_smi<%=i%>_rx_smi_if.smi_ndp_len   ) ,
.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name %>ndp_dp_present       (m_smi<%=i%>_rx_smi_if.smi_dp_present) ,
.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name %>ndp_targ_id          (m_smi<%=i%>_rx_smi_if.smi_targ_id   ) ,
.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name %>ndp_src_id           (m_smi<%=i%>_rx_smi_if.smi_src_id    ) ,
.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name %>ndp_msg_id           (m_smi<%=i%>_rx_smi_if.smi_msg_id    ) ,
.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name %>ndp_msg_type         (m_smi<%=i%>_rx_smi_if.smi_msg_type  ) ,
<% if(obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiUser >0) {%>
.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name %>ndp_msg_user         (m_smi<%=i%>_rx_smi_if.smi_msg_user  ) ,
<% } %>
<% if(obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiTier >0) {%>
.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_tier          (m_smi<%=i%>_rx_smi_if.smi_msg_tier  ) ,
<% } %>
<% if(obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiSteer >0) {%>
.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_steer             (m_smi<%=i%>_rx_smi_if.smi_steer     ) ,
<% } %>
<% if(obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiPri >0) {%>
.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_pri           (m_smi<%=i%>_rx_smi_if.smi_msg_pri   ) ,
<% } %>
<% if(obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiMsgQos >0) {%>
.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_qos           (m_smi<%=i%>_rx_smi_if.smi_msg_qos   ) ,
<% } %>
.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_ndp               (m_smi<%=i%>_rx_smi_if.smi_ndp[<%=wNDPTX[i]-1%>:0]) ,
<% if(obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiErr >0) {%>
.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_err           (m_smi<%=i%>_rx_smi_if.smi_msg_err   ) ,
<% } %>

    <%  if (obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.nSmiDPvc) { %>    
.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name%>dp_valid              (m_smi<%=i%>_rx_smi_if.smi_dp_valid  ) ,
.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name%>dp_ready              (m_smi<%=i%>_rx_smi_if.smi_dp_ready  ) ,
.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name%>dp_last               (m_smi<%=i%>_rx_smi_if.smi_dp_last   ) ,
.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name%>dp_data               (m_smi<%=i%>_rx_smi_if.smi_dp_data   ) ,
<% if(obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiDPuser >0) {%>
.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name%>dp_user               (m_smi<%=i%>_rx_smi_if.smi_dp_user[<%=wDPUSERTX[i]-1%>:0]) ,
<% } %>

    <% } %>
<% } %>
<%for (var i = 0; i < NSMIIFTX; i++) { %>
.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_valid         (m_smi<%=i%>_tx_smi_if.smi_msg_valid ) ,
.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_ready         (m_smi<%=i%>_tx_smi_if.smi_msg_ready ) ,
.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_ndp_len           (m_smi<%=i%>_tx_smi_if.smi_ndp_len   ) ,
.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_dp_present        (m_smi<%=i%>_tx_smi_if.smi_dp_present) ,
.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_targ_id           (m_smi<%=i%>_tx_smi_if.smi_targ_id   ) ,
.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_src_id            (m_smi<%=i%>_tx_smi_if.smi_src_id    ) ,
.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_id            (m_smi<%=i%>_tx_smi_if.smi_msg_id    ) ,
.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_type          (m_smi<%=i%>_tx_smi_if.smi_msg_type  ) ,
<% if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiUser >0) {%>
.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_user          (m_smi<%=i%>_tx_smi_if.smi_msg_user  ) ,
<% } %>
<% if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiTier >0) {%>
.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_tier          (m_smi<%=i%>_tx_smi_if.smi_msg_tier  ) ,
<% } %>
<% if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiSteer >0) {%>
.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_steer             (m_smi<%=i%>_tx_smi_if.smi_steer     ) ,
<% } %>
<% if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiPri >0) {%>
.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_pri           (m_smi<%=i%>_tx_smi_if.smi_msg_pri   ) ,
<% } %>
<% if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiMsgQos >0) {%>
.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_qos           (m_smi<%=i%>_tx_smi_if.smi_msg_qos   ) ,
<% } %>
.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_ndp               (m_smi<%=i%>_tx_smi_if.smi_ndp       ) ,
<% if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiErr >0) {%>
.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_err           (m_smi<%=i%>_tx_smi_if.smi_msg_err   ) ,
<% } %>
    <%  if (obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].params.nSmiDPvc) { %>    
.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>dp_valid              (m_smi<%=i%>_tx_smi_if.smi_dp_valid  ) ,
.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>dp_ready              (m_smi<%=i%>_tx_smi_if.smi_dp_ready  ) ,
.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>dp_last               (m_smi<%=i%>_tx_smi_if.smi_dp_last   ) ,
.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>dp_data               (m_smi<%=i%>_tx_smi_if.smi_dp_data   ) ,
<% if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiDPuser >0) {%>
.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>dp_user               (m_smi<%=i%>_tx_smi_if.smi_dp_user   ) ,
<% } %>
    <% } %>
<% } %>

    .<%=obj.DmiInfo[obj.Id].interfaces.uIdInt.name%>my_f_unit_id          (<%=obj.DmiInfo[obj.Id].FUnitId%>    ) ,  //has to uncomment once this m_smi is visable in DUT TBD
    .<%=obj.DmiInfo[obj.Id].interfaces.uIdInt.name%>my_n_unit_id          (<%=obj.DmiInfo[obj.Id].nUnitId%>    ) ,
<% if(obj.wRpn!=0) { %>
    .<%=obj.DmiInfo[obj.Id].interfaces.uIdInt.name%>my_csr_rpn            (<%=obj.DmiInfo[obj.Id].rpn%>        ) ,
<% } %>
<% if(obj.wNrri!=0) { %>
    .<%=obj.DmiInfo[obj.Id].interfaces.uIdInt.name%>my_csr_nrri           (<%=obj.DmiInfo[obj.Id].nrri%>       ) ,
<% } %>
    .<%=obj.DmiInfo[obj.Id].interfaces.uSysDveIdInt.name%>f_unit_id       (DVE_FUNIT_IDS                       ) ,
    .<%=obj.DmiInfo[obj.Id].interfaces.clkInt.name%>clk(dut_clk),

<% if(obj.useResiliency) { %>
    //TODO resiliency if ******************************************
<% if(obj.DmiInfo[obj.Id].ResilienceInfo.enableUnitDuplication) { %>
    .<%=obj.DmiInfo[obj.Id].interfaces.checkClkInt.name%>clk(dut_clk),
//    .<%=obj.DmiInfo[obj.Id].interfaces.checkClkInt.name%>reset_n(soft_rstn),
    .<%=obj.DmiInfo[obj.Id].interfaces.checkClkInt.name%>test_en     ('h0),
<% } %>
<% if (!obj.DmiInfo[obj.Id].interfaces.bistDebugDisableInt._SKIP_) { %>
    .<%=obj.DmiInfo[obj.Id].interfaces.bistDebugDisableInt.name%>pin     ('h1),
<% } %>
    // .clk_check(fr_clk),
     .bist_bist_next(1'b0),
     .bist_bist_next_ack(bist_bist_next_ack),
     .bist_domain_is_on(bist_domain_is_on),
     .fault_mission_fault(fault_mission_fault),
     .fault_latent_fault(fault_latent_fault),
     .fault_cerr_over_thres_fault(fault_cerr_over_thres_fault),
<% } %>


<% if(obj.useCmc && obj.DmiInfo[obj.Id].useWayPartitioning) { %>
    .<%=obj.DmiInfo[obj.Id].interfaces.uSysIdInt.name%>f_unit_id          ( aiu_funit_id),
<% } %>
//Q-channel interface connection
<% if(obj.DmiInfo[obj.Id].usePma) { %>
    .<%=obj.DmiInfo[obj.Id].interfaces.qInt.name%>ACTIVE                ( m_q_chnl_if.QACTIVE ) ,
    .<%=obj.DmiInfo[obj.Id].interfaces.qInt.name%>DENY                  ( m_q_chnl_if.QDENY   ) ,
    .<%=obj.DmiInfo[obj.Id].interfaces.qInt.name%>REQn                  ( m_q_chnl_if.QREQn   ) ,
    .<%=obj.DmiInfo[obj.Id].interfaces.qInt.name%>ACCEPTn               ( m_q_chnl_if.QACCEPTn) ,
<% } %>
     // PERF MON MASTER ENABLE
     .trigger_trigger(<%=obj.BlockId%>_sb_stall_if.master_cnt_enable),

    .<%=obj.DmiInfo[obj.Id].interfaces.clkInt.name%>test_en                  ('h0),
    .<%=obj.DmiInfo[obj.Id].interfaces.clkInt.name%>reset_n(soft_rstn)
      );

/////////////////////// PERF_CNT CONNECT DUT to LATENCY LATENCY_IF////////////////////////////////////////////////////

assign <%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_sb_latency_if.clk              =   dut_clk;
assign <%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_sb_latency_if.rst_n            =   soft_rstn;
<% if( (obj.nPerfCounters > 0) && (obj.nLatencyCounters > 0) ) { %>
assign <%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_sb_latency_if.alloc_if           =   dut.dmi_unit.u_ncr_pmon.latency_counter_in_alloc;
assign <%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_sb_latency_if.dealloc_if         =   dut.dmi_unit.u_ncr_pmon.latency_counter_in_dealloc;
assign <%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_sb_latency_if.dut_latency_bins   =   dut.dmi_unit.u_ncr_pmon.latency_bins;
assign <%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_sb_latency_if.div_clk_rtl        =   dut.dmi_unit.u_ncr_pmon.latency_counter_table.divevt_clk;
assign <%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_sb_latency_if.local_count_enable =   dut.dmi_unit.csr.u_dmi_apb_csr.DMIMCNTCR_LocalCountEnable_out;
  
<% } %>
/////////////////////// PERF_CNT CONNECT STALL_IF TO DUT////////////////////////////////////////////////////

assign <%=obj.BlockId%>_sb_stall_if.clk = dut_clk;
assign <%=obj.BlockId%>_sb_stall_if.rst_n = soft_rstn;
assign <%=obj.BlockId%>_sb_stall_if.trace_capture_busy = dut.dmi_unit.trace_capture_busy;

// SMI TX
<%for (var i = 0; i < NSMIIFRX; i++) { %>
<%  if (obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.nSmiDPvc) { %>  
assign <%=obj.BlockId%>_sb_stall_if.smi_tx<%=i%>_valid = dut.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name%>dp_valid;       
assign <%=obj.BlockId%>_sb_stall_if.smi_tx<%=i%>_ready = dut.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name%>dp_ready;      
<% } else { %>
assign <%=obj.BlockId%>_sb_stall_if.smi_tx<%=i%>_valid = dut.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_valid ;       
assign <%=obj.BlockId%>_sb_stall_if.smi_tx<%=i%>_ready = dut.<%=obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_ready  ;      
<% } %>
<% } %>
// SMI RX
<%for (var i = 0; i < NSMIIFTX; i++) { %>
<%  if (obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].params.nSmiDPvc) { %>  
assign <%=obj.BlockId%>_sb_stall_if.smi_rx<%=i%>_valid = dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>dp_valid;
assign <%=obj.BlockId%>_sb_stall_if.smi_rx<%=i%>_ready = dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>dp_ready;
assign (supply0, supply1) dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>dp_valid = m_smi<%=i%>_tx_smi_if.force_smi_msg_valid;  
assign (supply0, supply1) dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>dp_ready = m_smi<%=i%>_tx_smi_if.force_smi_msg_ready;
<% } else { %>
assign <%=obj.BlockId%>_sb_stall_if.smi_rx<%=i%>_valid = dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_valid;
assign <%=obj.BlockId%>_sb_stall_if.smi_rx<%=i%>_ready = dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_ready;
assign (supply0, supply1) dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_valid = m_smi<%=i%>_tx_smi_if.force_smi_msg_valid;
assign (supply0, supply1)  dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_ready = m_smi<%=i%>_tx_smi_if.force_smi_msg_ready; 
<%}%>
<%}%>
// AXI 
assign <%=obj.BlockId%>_sb_stall_if.axi_aw_valid = dut.<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>aw_valid;
assign <%=obj.BlockId%>_sb_stall_if.axi_aw_ready = dut.<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>aw_ready;

assign <%=obj.BlockId%>_sb_stall_if.axi_w_valid = dut.<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>w_valid;
assign <%=obj.BlockId%>_sb_stall_if.axi_w_ready = dut.<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>w_ready;

assign <%=obj.BlockId%>_sb_stall_if.axi_ar_valid = dut.<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>ar_valid;
assign <%=obj.BlockId%>_sb_stall_if.axi_ar_ready = dut.<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>ar_ready;

assign <%=obj.BlockId%>_sb_stall_if.axi_r_valid = dut.<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>r_valid;
assign <%=obj.BlockId%>_sb_stall_if.axi_r_ready = dut.<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>r_ready;

assign <%=obj.BlockId%>_sb_stall_if.axi_b_valid = dut.<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>b_valid;
assign <%=obj.BlockId%>_sb_stall_if.axi_b_ready = dut.<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>b_ready;
//CONC-12693 : tie-off signals of RX2 interface other than valid and ready to avoid propagating X to RTL.
initial 
begin
  if ($test$plusargs("force_smi_2_rx")) begin
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[2].name%>ndp_ndp_len     = 0;
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[2].name%>ndp_dp_present  = 0;
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[2].name%>ndp_targ_id     = 0;    
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[2].name%>ndp_src_id      = 0;     
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[2].name%>ndp_msg_id      = 0;     
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[2].name%>ndp_msg_type    = 0;       
    <% if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[2].params.wSmiUser >0) {%>      
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[2].name%>ndp_msg_user    = 0;
    <% } %>    
    <% if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[2].params.wSmiTier >0) {%>
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[2].name%>ndp_msg_tier    = 0;          
    <% } %>
    <% if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[2].params.wSmiSteer >0) {%>
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[2].name%>ndp_steer       = 0;      
    <% } %>
    <% if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[2].params.wSmiPri >0) {%>
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[2].name%>ndp_msg_pri     = 0;      
    <% } %>
    <% if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[2].params.wSmiMsgQos >0) {%>
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[2].name%>ndp_msg_qos     = 0;  
    <% } %>
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[2].name%>ndp_ndp         = 0; 
    <% if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[2].params.wSmiErr >0) {%>
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[2].name%>ndp_msg_err     = 0;      
    <% } %>
    $assertoff(0,m_smi2_tx_smi_if);
  end
  if ($test$plusargs("force_smi_1_rx")) begin
    $assertoff(0,m_smi1_tx_smi_if);
  end
  if ($test$plusargs("force_smi_0_rx")) begin
    $assertoff(0,m_smi0_tx_smi_if);
  end
end
/////////////////////////////////////       DMI BW events       //////////////////////////////////////////
//dtr_req event
assign <%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_sb_stall_if.dtr_req_valid = dut.dmi_unit.dtr_req_valid;
assign <%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_sb_stall_if.dtr_req_ready = dut.dmi_unit.dtr_req_ready;
assign <%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_sb_stall_if.dtr_req_funit_id_if = (dut.dmi_unit.dtr_req_target_id >> WSMINCOREPORTID);
<%if (wArUser > 0){%>
assign <%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_sb_stall_if.dtr_req_user_bits_if = dut.dmi_unit.pmon_dtr_associated_user;  //dut.dmi_unit.dtr_req_aux;
<% } %>
//dtw_req event
assign <%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_sb_stall_if.dtw_req_valid = dut.dmi_unit.dtw_req_valid;
assign <%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_sb_stall_if.dtw_req_ready = dut.dmi_unit.dtw_req_ready;
assign <%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_sb_stall_if.dtw_req_funit_id_if = (dut.dmi_unit.dtw_req_initiator_id >> WSMINCOREPORTID);
<%if (wAwUser > 0){%>
assign <%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_sb_stall_if.dtw_req_user_bits_if = dut.dmi_unit.pmon_dtw_associated_user;  //dut.dmi_unit.dtw_req_aux;
<% } %>

/////////////////////////////////////    End Of DMI BW events   //////////////////////////////////////////


<%for (var i = 0; i < obj.nPerfCounters; i++) { %>
assign <%=obj.BlockId%>_sb_stall_if.cnt_reg_capture[<%=i%>].cnt_v =  dut.dmi_unit.csr.DMICNTVR<%=i%>_CountVal_out ;  
assign <%=obj.BlockId%>_sb_stall_if.cnt_reg_capture[<%=i%>].cnt_v_str =  dut.dmi_unit.csr.DMICNTSR<%=i%>_CountSatVal_out;      
<% } %>
<% if(obj.useCmc) { %>
assign <%=obj.BlockId%>_sb_stall_if.<%=obj.listEventArr.filter(e => e.name == "Cache_read_stall").map(e=>e.itf_name)%>_ready = u_ccp_if.cache_rdrsp_rdy; 
assign <%=obj.BlockId%>_sb_stall_if.<%=obj.listEventArr.filter(e => e.name == "Cache_read_stall").map(e=>e.itf_name)%>_valid = u_ccp_if.cache_rdrsp_vld; 
assign <%=obj.BlockId%>_sb_stall_if.<%=obj.listEventArr.filter(e => e.name == "Cache_write_stall").map(e=>e.itf_name)%>_ready = u_ccp_if.cache_wr_rdy; 
assign <%=obj.BlockId%>_sb_stall_if.<%=obj.listEventArr.filter(e => e.name == "Cache_write_stall").map(e=>e.itf_name)%>_valid = u_ccp_if.ctrl_wr_vld;
assign <%=obj.BlockId%>_sb_stall_if.<%=obj.listEventArr.filter(e => e.name == "Cache_fill_stall").map(e=>e.itf_name)%>_ready = u_ccp_if.cache_filldata_rdy; 
assign <%=obj.BlockId%>_sb_stall_if.<%=obj.listEventArr.filter(e => e.name == "Cache_fill_stall").map(e=>e.itf_name)%>_valid = u_ccp_if.ctrl_filldata_vld;
<% } %>


<% if(!obj.USE_VIP_SNPS) { %> //FIXME hook this up differently for VIP IF VIK
/////FORCE READ DATA CHANNEL ET B RESPENSE CHANNEL FOR PERFMON////////////////////
assign (supply0, supply1) dut.<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>b_ready  = `AXI_INHOUSE_IF.force_bready;
assign (supply0, supply1) dut.<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>b_valid  = `AXI_INHOUSE_IF.force_bvalid;
assign (supply0, supply1) dut.<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>r_ready  = `AXI_INHOUSE_IF.force_rready;  
assign (supply0, supply1) dut.<%=obj.DmiInfo[obj.Id].interfaces.axiInt.name%>r_valid  = `AXI_INHOUSE_IF.force_rvalid;
/////////////////// END PERF_CNT STALL_IF ////////////////////////////////////////////////////
<% } %>

   // ARM AXI Assertions
`ifdef ASSERT_ON
<%=obj.DmiInfo[obj.Id].strRtlNamePrefix%>_Axi4PC_ace m_axi4_arm_sva    (
   // Global Signals
   .ACLK                     ( dut_clk                           ) ,
   .ARESETn                  ( soft_rstn                          ) ,

   // Write Address Channel
   .AWID                     ( `AXI_INHOUSE_IF.awid                ) ,
   .AWADDR                   ( `AXI_INHOUSE_IF.awaddr              ) ,
   .AWLEN                    ( `AXI_INHOUSE_IF.awlen               ) ,
   .AWSIZE                   ( `AXI_INHOUSE_IF.awsize              ) ,
   .AWBURST                  ( `AXI_INHOUSE_IF.awburst             ) ,
   .AWLOCK                   ( `AXI_INHOUSE_IF.awlock              ) ,
   .AWCACHE                  ( `AXI_INHOUSE_IF.awcache             ) ,
   .AWPROT                   ( `AXI_INHOUSE_IF.awprot              ) ,
   .AWUSER                   ( `AXI_INHOUSE_IF.awuser              ) ,
   .AWQOS                    ( `AXI_INHOUSE_IF.awqos               ) ,
   .AWREGION                 ( `AXI_INHOUSE_IF.awregion            ) ,
   .AWVALID                  ( `AXI_INHOUSE_IF.awvalid             ) ,
   .AWREADY                  ( `AXI_INHOUSE_IF.awready             ) ,

   // Write Channel
   .WDATA                    ( `AXI_INHOUSE_IF.wdata               ) ,
   .WSTRB                    ( `AXI_INHOUSE_IF.wstrb               ) ,
   .WUSER                    ( `AXI_INHOUSE_IF.wuser               ) ,
   .WLAST                    ( `AXI_INHOUSE_IF.wlast               ) ,
   .WVALID                   ( `AXI_INHOUSE_IF.wvalid              ) ,
   .WREADY                   ( `AXI_INHOUSE_IF.wready              ) ,

   // Write Response Channel
   .BID                      ( `AXI_INHOUSE_IF.bid                 ) ,
   .BRESP                    ( `AXI_INHOUSE_IF.bresp               ) ,
   .BUSER                    ( `AXI_INHOUSE_IF.buser               ) ,
   .BVALID                   ( `AXI_INHOUSE_IF.bvalid              ) ,
   .BREADY                   ( `AXI_INHOUSE_IF.bready              ) ,

   // Read Address Channel
   .ARID                     ( `AXI_INHOUSE_IF.arid                ) ,
   .ARADDR                   ( `AXI_INHOUSE_IF.araddr              ) ,
   .ARREGION                 ( `AXI_INHOUSE_IF.arregion            ) ,
   .ARLEN                    ( `AXI_INHOUSE_IF.arlen               ) ,
   .ARSIZE                   ( `AXI_INHOUSE_IF.arsize              ) ,
   .ARBURST                  ( `AXI_INHOUSE_IF.arburst             ) ,
   .ARLOCK                   ( `AXI_INHOUSE_IF.arlock              ) ,
   .ARCACHE                  ( `AXI_INHOUSE_IF.arcache             ) ,
   .ARPROT                   ( `AXI_INHOUSE_IF.arprot              ) ,
   .ARUSER                   ( `AXI_INHOUSE_IF.aruser              ) ,
   .ARQOS                    ( `AXI_INHOUSE_IF.arqos               ) ,
   .ARVALID                  ( `AXI_INHOUSE_IF.arvalid             ) ,
   .ARREADY                  ( `AXI_INHOUSE_IF.arready             ) ,

   //  Read Channel
   .RID                      ( `AXI_INHOUSE_IF.rid                 ) ,
   .RLAST                    ( `AXI_INHOUSE_IF.rlast               ) ,
   .RDATA                    ( `AXI_INHOUSE_IF.rdata               ) ,
   .RRESP                    ( `AXI_INHOUSE_IF.rresp               ) ,
   .RUSER                    ( `AXI_INHOUSE_IF.ruser               ) ,
   .RVALID                   ( `AXI_INHOUSE_IF.rvalid              ) ,
   .RREADY                   ( `AXI_INHOUSE_IF.rready              ) ,

   // Low Power Interface
   .CACTIVE                  ( 'b1                              ) ,
   .CSYSREQ                  ( 'b1                              ) ,
   .CSYSACK                  ( 'b1                              )
) ;

initial begin
    if ($test$plusargs("AXI_assertions_off")) begin
        $assertoff(0,m_axi4_arm_sva);
    end
end

`endif



<% for (var i = 0; i < NSMIIFRX; i++) { %>
  <%  if (!obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.nSmiDPvc) { %>    
     assign m_smi<%=i%>_rx_smi_if.smi_dp_ready = 0;
     assign m_smi<%=i%>_rx_smi_if.smi_dp_valid = 0;
  <% } %>
<% } %>

<% for (var i = 0; i < NSMIIFTX; i++) { %>
  <%  if (!obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.nSmiDPvc) { %>    
     assign m_smi<%=i%>_tx_smi_if.smi_dp_ready = 0;
     assign m_smi<%=i%>_tx_smi_if.smi_dp_valid = 0;
  <% } %>
<% } %>
// will connect smi_msg_err when it will be implemented in RTL

<% for (var i = 0; i < NSMIIFRX; i++) { %>
 <% if(!obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiErr) {%>
       assign m_smi<%=i%>_rx_smi_if.smi_msg_err = 0;
 <% } %>
<% if(!obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiMsgQos) {%>
       assign m_smi<%=i%>_rx_smi_if.smi_msg_qos = 0;
 <% } %>
<% if(!obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiUser) {%>
       assign m_smi<%=i%>_rx_smi_if.smi_msg_user = 0;
 <% } %>
<% if(!obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiTier) {%>
       assign m_smi<%=i%>_rx_smi_if.smi_msg_tier = 0;
 <% } %>
<% if(!obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiPri >0) {%>
       assign m_smi<%=i%>_rx_smi_if.smi_msg_pri = 0;
 <% } %>
<% if(!obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiSteer) {%>
       assign m_smi<%=i%>_rx_smi_if.smi_steer = 0;
 <% } %>
<% } %>

initial 
  begin 
  <% var rdQDepth = 8; %>

<% for (var i = 0; i < NSMIIFRX; i++) { %>
<% if(obj.testBench == 'dmi') { %>
   `ifndef VCS
      m_smi<%=i%>_rx_smi_if.smi_ndp = 0;
   `endif // `ifndef VCS ... `else ... 
<% } else {%>
      m_smi<%=i%>_rx_smi_if.smi_ndp = 0;
<% } %>
    <%  if (obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.nSmiDPvc) { %>    
<% if(obj.testBench == 'dmi') { %>
   `ifndef VCS
      m_smi<%=i%>_rx_smi_if.smi_dp_user = 0;
   `endif // `ifndef VCS ... `else ... 
<% } else {%>
      m_smi<%=i%>_rx_smi_if.smi_dp_user = 0;
    <% } %>
    <% } %>
<% } %>
  end

      assign  u_dmi0_rtl_if.cmd_rsp_push_valid   =  tb_top.dut.dmi_unit.dmi_protocol_control.cmd_skid_buffer_pop_valid; 
      assign  u_dmi0_rtl_if.cmd_rsp_push_ready   =  tb_top.dut.dmi_unit.dmi_protocol_control.cmd_skid_buffer_pop_ready; 
      assign  u_dmi0_rtl_if.cmd_rsp_push_rmsg_id =  tb_top.dut.dmi_unit.dmi_protocol_control.cmd_skid_buffer_pop_message_id[<%=obj.Widths.Concerto.Ndp.Header.wMsgId-1%>:0];
      assign  u_dmi0_rtl_if.cmd_rsp_push_targ_id =  tb_top.dut.dmi_unit.dmi_protocol_control.cmd_skid_buffer_pop_initiator_id[<%=obj.DmiInfo[obj.Id].wFUnitId+obj.DmiInfo[obj.Id].wFPortId-1%>:<%=obj.DmiInfo[obj.Id].wFPortId%>];
      
      assign  u_dmi0_rtl_if.mrd_pop_valid        =  tb_top.dut.dmi_unit.dmi_protocol_control.mrd_skid_buffer_pop_valid; 
      assign  u_dmi0_rtl_if.mrd_pop_ready        =  tb_top.dut.dmi_unit.dmi_protocol_control.mrd_skid_buffer_pop_ready; 
      assign  u_dmi0_rtl_if.mrd_pop_msg_id       =  tb_top.dut.dmi_unit.dmi_protocol_control.mrd_skid_buffer_pop_message_id[<%=obj.Widths.Concerto.Ndp.Header.wMsgId-1%>:0];
      assign  u_dmi0_rtl_if.mrd_pop_initiator_id =  tb_top.dut.dmi_unit.dmi_protocol_control.mrd_skid_buffer_pop_initiator_id[<%=obj.DmiInfo[obj.Id].wFUnitId+obj.DmiInfo[obj.Id].wFPortId-1%>:<%=obj.DmiInfo[obj.Id].wFPortId%>];
      assign  u_dmi0_rtl_if.mrd_pop_addr         =  tb_top.dut.dmi_unit.dmi_protocol_control.mrd_skid_buffer_pop_addr; 
      assign  u_dmi0_rtl_if.mrd_pop_ns           =  tb_top.dut.dmi_unit.dmi_protocol_control.mrd_skid_buffer_pop_ns; 

  <%if (obj.DmiInfo[0].fnEnableQos) { %>
      assign  u_dmi0_rtl_if.cmd_starv_mode       =  tb_top.dut.dmi_unit.dmi_protocol_control.cmd_starv_mode; 
      assign  u_dmi0_rtl_if.mrd_starv_mode       =  tb_top.dut.dmi_unit.dmi_protocol_control.mrd_starv_mode; 
  <% } %>

    //signals to detect addr collision 
    assign  u_dmi0_rtl_if.cmd_skid_buffer_pop_valid   = tb_top.dut.dmi_unit.dmi_protocol_control.cmd_pop_valid;
    assign  u_dmi0_rtl_if.cmd_skid_buffer_pop_ready   = tb_top.dut.dmi_unit.dmi_protocol_control.cmd_pop_ready;                
    assign  u_dmi0_rtl_if.cmd_skid_buffer_pop_addr    = tb_top.dut.dmi_unit.dmi_protocol_control.cmd_pop_addr;
    assign  u_dmi0_rtl_if.cmd_skid_buffer_pop_ns      = tb_top.dut.dmi_unit.dmi_protocol_control.cmd_pop_ns;
                                                                                                              

    assign  u_dmi0_rtl_if.req_entry_valid      = tb_top.dut.dmi_unit.dmi_protocol_control.dmi_nc_read_buffer.req_entry_valid;
    assign  u_dmi0_rtl_if.req_entry_addr       = {<% for(var i=(rdQDepth-1); i>=0; i--) {

                     if(i == 0) {%> tb_top.dut.dmi_unit.dmi_protocol_control.dmi_nc_read_buffer.req_entry_addr<%=i%>
                                                        <% } else { %> tb_top.dut.dmi_unit.dmi_protocol_control.dmi_nc_read_buffer.req_entry_addr<%=i%>,<%}}%>};

    assign u_dmi0_rtl_if.req_entry_ns           = {<% for(var i=(rdQDepth-1); i>=0; i--) {
                                                     if(i == 0) {%> tb_top.dut.dmi_unit.dmi_protocol_control.dmi_nc_read_buffer.req_entry_ns<%=i%>
                                                        <% } else { %> tb_top.dut.dmi_unit.dmi_protocol_control.dmi_nc_read_buffer.req_entry_ns<%=i%>,<%}}%>};


    assign u_dmi0_rtl_if.rb_id_valid                  = tb_top.dut.dmi_unit.dmi_protocol_control.nc_write_buffer.rb_id_valid;
    assign u_dmi0_rtl_if.rb_id_addr                   = {<% for(var i=(obj.DmiInfo[obj.Id].cmpInfo.nDmiRbEntries-1); i>=0; i--) {
                                                        if(i == 0) {%> tb_top.dut.dmi_unit.dmi_protocol_control.nc_write_buffer.rb_id_addr_<%=i%>
                                                        <% } else { %> tb_top.dut.dmi_unit.dmi_protocol_control.nc_write_buffer.rb_id_addr_<%=i%>,<%}}%>};
    assign u_dmi0_rtl_if.rb_id_ns                     = {<% for(var i=(obj.DmiInfo[obj.Id].cmpInfo.nDmiRbEntries-1); i>=0; i--) {
                                                        if(i == 0) {%> tb_top.dut.dmi_unit.dmi_protocol_control.nc_write_buffer.rb_id_ns_<%=i%>
                                                        <% } else { %> tb_top.dut.dmi_unit.dmi_protocol_control.nc_write_buffer.rb_id_ns_<%=i%>,<%}}%>};
    //
    
    assign u_dmi0_tt_if.read_alloc_valid        = tb_top.dut.dmi_unit.dmi_transaction_control.rtt.alloc_valid; 
    assign u_dmi0_tt_if.read_alloc_ready        = tb_top.dut.dmi_unit.dmi_transaction_control.rtt.alloc_ready; 
    assign u_dmi0_tt_if.read_alloc_addr         = tb_top.dut.dmi_unit.dmi_transaction_control.rtt.alloc_addr;
    assign u_dmi0_tt_if.read_alloc_ns           = tb_top.dut.dmi_unit.dmi_transaction_control.rtt.alloc_ns;
    assign u_dmi0_tt_if.read_alloc_msg_id       = tb_top.dut.dmi_unit.dmi_transaction_control.rtt.alloc_aiu_trans_id[<%=obj.Widths.Concerto.Ndp.Header.wMsgId-1%>:0];
    assign u_dmi0_tt_if.read_alloc_aiu_unit_id = tb_top.dut.dmi_unit.dmi_transaction_control.rtt.alloc_aiu_id[<%=obj.DmiInfo[obj.Id].wFUnitId+obj.DmiInfo[obj.Id].wFPortId-1%>:<%=obj.DmiInfo[obj.Id].wFPortId%>];
    assign u_dmi0_tt_if.read_alloc_msg_type     = tb_top.dut.dmi_unit.dmi_transaction_control.rtt.alloc_cm_type;
    assign u_dmi0_tt_if.read_tt_dealloc_vld     = tb_top.dut.dmi_unit.dmi_transaction_control.rtt.dealloc_valid;


    assign u_dmi0_tt_if.write_alloc_valid       = tb_top.dut.dmi_unit.dmi_transaction_control.wtt.write_alloc_valid;
    assign u_dmi0_tt_if.write_alloc_ready       = tb_top.dut.dmi_unit.dmi_transaction_control.wtt.write_alloc_ready;
    assign u_dmi0_tt_if.write_alloc_addr        = tb_top.dut.dmi_unit.dmi_transaction_control.wtt.write_alloc_addr;
    assign u_dmi0_tt_if.write_alloc_ns          = tb_top.dut.dmi_unit.dmi_transaction_control.wtt.write_alloc_ns;
    assign u_dmi0_tt_if.write_alloc_msg_id      = tb_top.dut.dmi_unit.dmi_transaction_control.wtt.write_alloc_aiu_trans_id[<%=obj.Widths.Concerto.Ndp.Header.wMsgId-1%>:0];
    assign u_dmi0_tt_if.write_alloc_aiu_unit_id= tb_top.dut.dmi_unit.dmi_transaction_control.wtt.write_alloc_aiu_id[<%=obj.DmiInfo[obj.Id].wFUnitId+obj.DmiInfo[obj.Id].wFPortId-1%>:<%=obj.DmiInfo[obj.Id].wFPortId%>];
    assign u_dmi0_tt_if.write_alloc_msg_type    = tb_top.dut.dmi_unit.dmi_transaction_control.wtt.write_alloc_cm_type;
    assign u_dmi0_tt_if.write_tt_dealloc_vld    = tb_top.dut.dmi_unit.dmi_transaction_control.wtt.dealloc_valid;

    <%if(obj.useCmc) {%>
    assign u_dmi0_tt_if.ctrlop_vld_p0    = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_valid_p0;
    assign u_dmi0_tt_if.cacheop_rdy_p0   = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_op_ready_p0;
    assign u_dmi0_tt_if.isReplay         = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.cache_pipe.replay_queue.ccp_p1_is_replay;
    assign u_dmi0_tt_if.isRecycle        = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.cache_pipe.recycle_valid;
    assign u_dmi0_tt_if.isMntOp          = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.cache_pipe.ccp_p1_mnt;
    assign u_dmi0_tt_if.cam_addr         = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.cache_pipe.ccp_p1_addr;
    assign u_dmi0_tt_if.cam_ns           = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.cache_pipe.ccp_p1_ns;
    <% } else {%>
    assign u_dmi0_tt_if.write_pipe_pop_valid = tb_top.dut.dmi_unit.dmi_resource_control.dmi_no_cache_wrap.write_pipe_pop_valid;
    assign u_dmi0_tt_if.write_pipe_pop_ready = tb_top.dut.dmi_unit.dmi_resource_control.dmi_no_cache_wrap.write_pipe_pop_ready;
    assign u_dmi0_tt_if.write_req_addr       = tb_top.dut.dmi_unit.dmi_resource_control.dmi_no_cache_wrap.write_req_addr;
    assign u_dmi0_tt_if.write_req_ns         = tb_top.dut.dmi_unit.dmi_resource_control.dmi_no_cache_wrap.write_req_ns;

    assign u_dmi0_tt_if.read_pipe_pop_valid  = tb_top.dut.dmi_unit.dmi_resource_control.dmi_no_cache_wrap.read_pipe_pop_valid;
    assign u_dmi0_tt_if.read_pipe_pop_ready  = tb_top.dut.dmi_unit.dmi_resource_control.dmi_no_cache_wrap.read_pipe_pop_ready;
    assign u_dmi0_tt_if.read_req_addr        = tb_top.dut.dmi_unit.dmi_resource_control.dmi_no_cache_wrap.read_req_addr;
    assign u_dmi0_tt_if.read_req_ns          = tb_top.dut.dmi_unit.dmi_resource_control.dmi_no_cache_wrap.read_req_ns;
    <% } %>

   assign u_dmi0_tt_if.tt_valid      = tb_top.dut.dmi_unit.dmi_transaction_control.rtt.tt_valid;
   assign u_dmi0_tt_if.tt_addr       = {<% for(var i=(obj.DmiInfo[obj.Id].cmpInfo.nRttCtrlEntries-1); i>=0; i--) {
                                        if(i == 0) {%> tb_top.dut.dmi_unit.dmi_transaction_control.rtt.tt_addr<%=i%>
                                        <% } else { %> tb_top.dut.dmi_unit.dmi_transaction_control.rtt.tt_addr<%=i%>,<%}}%>};
   assign u_dmi0_tt_if.tt_ns        = {<% for(var i=(obj.DmiInfo[obj.Id].cmpInfo.nRttCtrlEntries-1); i>=0; i--) {
                                        if(i == 0) {%> tb_top.dut.dmi_unit.dmi_transaction_control.rtt.tt_ns<%=i%>
                                      <% } else { %> tb_top.dut.dmi_unit.dmi_transaction_control.rtt.tt_ns<%=i%>,<%}}%>};
    
    assign u_dmi0_tt_if.wtt_valid      = tb_top.dut.dmi_unit.dmi_transaction_control.wtt.wtt_valid;
    assign u_dmi0_tt_if.wtt_addr       = {<% for(var i=(obj.DmiInfo[obj.Id].cmpInfo.nWttCtrlEntries-1); i>=0; i--) {
                                        if(i == 0) {%> tb_top.dut.dmi_unit.dmi_transaction_control.wtt.wtt_addr<%=i%>
                                        <% } else { %> tb_top.dut.dmi_unit.dmi_transaction_control.wtt.wtt_addr<%=i%>,<%}}%>};
    assign u_dmi0_tt_if.wtt_ns         = {<% for(var i=(obj.DmiInfo[obj.Id].cmpInfo.nWttCtrlEntries-1); i>=0; i--) {
                                        if(i == 0) {%> tb_top.dut.dmi_unit.dmi_transaction_control.wtt.wtt_ns<%=i%>
                                        <% } else { %> tb_top.dut.dmi_unit.dmi_transaction_control.wtt.wtt_ns<%=i%>,<%}}%>};

<% if(obj.INHOUSE_APB_VIP) { %>
       // TODO: confirm with Steve
       assign u_csr_probe_if.TransActv = tb_top.dut.dmi_unit.csr.u_dmi_apb_csr.DMIUTAR_TransActv_out;
 <% if(obj.useCmc) { %>
       assign u_csr_probe_if.AllocActv = tb_top.dut.dmi_unit.csr.u_dmi_apb_csr.DMIUSMCTAR_AllocActive_out;
       assign u_csr_probe_if.EvictActv = tb_top.dut.dmi_unit.csr.u_dmi_apb_csr.DMIUSMCTAR_EvictActive_out;
 <% } %>
<% } %>
       assign u_csr_probe_if.IRQ_C     = tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.irqInt.name%>c;
       assign u_csr_probe_if.IRQ_UC    = tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.irqInt.name%>uc;

<% if (obj.useResiliency) { %>
       assign u_csr_probe_if.fault_mission_fault = tb_top.dut.fault_mission_fault;
       assign u_csr_probe_if.fault_latent_fault  = tb_top.dut.fault_latent_fault;
       assign u_csr_probe_if.cerr_threshold          = tb_top.dut.u_dmi_fault_checker.cerr_threshold;
       assign u_csr_probe_if.cerr_counter            = tb_top.dut.u_dmi_fault_checker.cerr_counter;
       assign u_csr_probe_if.cerr_over_thres_fault   = tb_top.dut.u_dmi_fault_checker.cerr_over_thres_fault;
<% } %>
;

<% if(obj.useCmc) { %>
        //CTRL channel
        assign ccp_clk                       = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.clk;
        assign ccp_rstn                      = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.reset_n;
        assign u_ccp_if.ctrlop_vld           = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_valid_p0;
        assign u_ccp_if.ctrlop_addr          = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_address_p0;
<% if(obj.wSecurityAttribute) { %>
        assign u_ccp_if.ctrlop_security      = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_security_p0        ;
<% } else { %>
        assign u_ccp_if.ctrlop_security      = 0  ;
<% } %>
        assign u_ccp_if.ctrlop_allocate      = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_allocate_p2        ;
        assign u_ccp_if.ctrlop_rd_data       = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_read_data_p2       ;
        assign u_ccp_if.ctrlop_wr_data       = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_write_data_p2      ;
        assign u_ccp_if.ctrlop_port_sel      = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_port_sel_p2        ;
        assign u_ccp_if.ctrlop_bypass        = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_bypass_p2          ;
        assign u_ccp_if.ctrlop_rp_update     = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_rp_update_p2       ;
        assign u_ccp_if.ctrlop_tagstateup    = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_tag_state_update_p2;
        assign u_ccp_if.ctrlop_state         = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_state_p2           ;
        assign u_ccp_if.ctrlop_burstln       = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_burst_len_p2       ;
        assign u_ccp_if.ctrlop_burstwrap     = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_burst_wrap_p2      ;
        assign u_ccp_if.ctrlop_setway_debug  = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_setway_debug_p2    ;
        assign u_ccp_if.ctrlop_waybusy_vec   = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_ways_busy_vec_p2   ;
        assign u_ccp_if.ctrlop_waystale_vec  = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_op_ways_stale_vec_p2   ;


        assign u_ccp_if.cacheop_rdy          = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_op_ready_p0          ;
        assign u_ccp_if.cache_vld            = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_valid_p2             ;
        assign u_ccp_if.cache_currentstate   = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_current_state_p2     ;
        assign u_ccp_if.cache_set_index      = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_set_index_p2         ;
     <% if(nWays>1) { %>
        assign u_ccp_if.cache_alloc_wayn     = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_alloc_way_vec_p2 ;
        assign u_ccp_if.cache_hit_wayn       = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_hit_way_vec_p2 ;
     <% } %>
        assign u_ccp_if.cachectrl_evict_vld  = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_evict_valid_p2       ;
        assign u_ccp_if.cache_evict_addr     = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_evict_address_p2     ;
<% if(obj.wSecurityAttribute) { %>
        assign u_ccp_if.cache_evict_security = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_evict_security_p2    ;
<% } else { %>
        assign u_ccp_if.cache_evict_security = 0  ;
<% } %>
        assign u_ccp_if.cache_evict_state    = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_evict_state_p2       ;
        assign u_ccp_if.cache_nack_uce       = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_nack_uce_p2          ;
        assign u_ccp_if.cache_nack           = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_nack_p2              ;
        assign u_ccp_if.cache_nack_ce        = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_nack_ce_p2           ;
        assign u_ccp_if.cache_nack_noalloc   = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_nack_no_allocate_p2  ;
        assign u_ccp_if.cache_no_ways_2_alloc= tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.pmon_ccp_ctrl_op_allocate_nack_no_allocate  ; 

//Fill CTRL Channel
        assign u_ccp_if.ctrl_fill_vld        = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_valid            ;
        assign u_ccp_if.ctrl_fill_addr       = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_address          ;
     <% if(nWays>1) { %>
        assign u_ccp_if.ctrl_fill_wayn       = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_way_num          ;
     <% } %>
        assign u_ccp_if.ctrl_fill_state      = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_state            ;
<% if(obj.wSecurityAttribute) { %>
        assign u_ccp_if.ctrl_fill_security   = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_security         ;
<% } else { %>
        assign u_ccp_if.ctrl_fill_security   = 0 ;
<% } %>
//Fill Data Channel
        assign u_ccp_if.ctrl_filldata_vld    = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_data_valid       ;
        <% if (obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad && obj.DmiInfo[obj.Id].useAtomic) { %>
        assign u_ccp_if.ctrl_filldata_scratchpad = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_scratchpad   ;
        <% } else { %>
        assign u_ccp_if.ctrl_filldata_scratchpad = 0;
        <% } %>
        assign u_ccp_if.ctrl_fill_data       = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_data             ;
        assign u_ccp_if.ctrl_filldata_id     = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_data_id          ;
        assign u_ccp_if.ctrl_filldata_addr   = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_data_address     ;
     <% if(nWays>1) { %>
        assign u_ccp_if.ctrl_filldata_wayn   = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_data_way_num     ;
     <% } %>
        assign u_ccp_if.ctrl_filldata_beatn  = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_data_beat_num    ;
        assign u_ccp_if.ctrl_filldata_byten  = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_data_byteen      ;
        assign u_ccp_if.ctrl_filldata_last   = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_data_last        ;
        assign u_ccp_if.cache_filldata_rdy   = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_fill_data_ready      ;
        assign u_ccp_if.cache_fill_rdy       = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_fill_ready           ;
        assign u_ccp_if.cache_fill_done      = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_fill_done            ;
        assign u_ccp_if.cache_fill_done_id   = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_fill_done_id         ;
        //CONC-15425::CONC-15710 - Fill Interface udpdate: Adding Fill data full signal to the Fill Data Interafce
        assign u_ccp_if.ctrl_filldata_full   = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_fill_data_full        ;

//WR Data Channel
        assign u_ccp_if.ctrl_wr_vld          = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_wr_valid              ;
        assign u_ccp_if.ctrl_wr_data         = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_wr_data               ;
        assign u_ccp_if.ctrl_wr_byte_en      = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_wr_byte_en            ;
        assign u_ccp_if.ctrl_wr_beat_num     = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_wr_beat_num           ;
        assign u_ccp_if.ctrl_wr_last         = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.ctrl_wr_last               ;
        assign u_ccp_if.cache_wr_rdy         = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_wr_ready             ;

//Evict Channel
        assign u_ccp_if.cache_evict_rdy      = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_evict_ready          ;
        assign u_ccp_if.cache_evict_vld      = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_evict_valid          ;
        assign u_ccp_if.cache_evict_data     = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_evict_data           ;
        assign u_ccp_if.cache_evict_byten    = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_evict_byteen         ;
        assign u_ccp_if.cache_evict_last     = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_evict_last           ;
        assign u_ccp_if.cache_evict_cancel   = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_evict_cancel         ;

//Read response Channel
        assign u_ccp_if.cache_rdrsp_rdy      = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_rdrsp_ready          ;
        assign u_ccp_if.cache_rdrsp_vld      = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_rdrsp_valid          ;
        assign u_ccp_if.cache_rdrsp_data     = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_rdrsp_data           ;
        assign u_ccp_if.cache_rdrsp_byten    = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_rdrsp_byteen         ;
        assign u_ccp_if.cache_rdrsp_last     = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_rdrsp_last           ;
        assign u_ccp_if.cache_rdrsp_cancel   = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.cache_rdrsp_cancel         ;
//Mnt Channel
        assign u_ccp_if.maint_req_opcode     = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.maint_req_opcode           ;
        assign u_ccp_if.maint_wrdata         = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.maint_req_data             ;
     <% if(nWays>1) { %>
        assign u_ccp_if.maint_req_way        = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.maint_req_way              ;
     <% } %>
        assign u_ccp_if.maint_req_entry      = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.maint_req_entry            ;
        assign u_ccp_if.maint_req_word       = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.maint_req_word             ;
        assign u_ccp_if.maint_req_array_sel  = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.maint_req_array_sel        ;

//        assign u_ccp_if.maint_active         = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.maint_active               ;
        assign u_ccp_if.maint_active         = tb_top.dut.dmi_unit.csr.DMIUSMCMAR_MntOpActv_in[0]                                               ;   //Replaced maint_active probe as per JIRA CONC-5896
        assign u_ccp_if.maint_read_data      = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.maint_read_data            ;
        assign u_ccp_if.maint_read_data_en   = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.maint_read_data_en         ;
        assign u_ccp_if.isReplay             = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.cache_pipe.replay_queue.ccp_p1_is_replay    ;
        assign u_ccp_if.toReplay             = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.cache_pipe.replay_queue.ccp_p1_to_replay    ;
        assign u_ccp_if.isRecycle            = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.cache_pipe.recycle_valid;
        assign u_ccp_if.msgType_p2           = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.ccp_p2_cm_type   ;
        assign u_ccp_if.msgType_p0           = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.cache_pipe.ccp_p0_cm_type   ;
        assign u_ccp_if.msgType_p1           = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.cache_pipe.ccp_p1_cm_type   ;
        assign u_ccp_if.isCoh_p0             = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.cache_pipe.ccp_p0_write_nc_sel;
        assign u_ccp_if.isMntOp              = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.cache_pipe.ccp_p2_mnt;
        assign u_ccp_if.isRply_vld_p0        = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.cache_pipe.replay_valid;
        assign u_ccp_if.flush_fail_p2        = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_mnt_op_ctrl_unit.flush_fail_p2;

// ScratchPad signals
<% if (obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
        assign u_ccp_if.sp_rdrsp_vld         = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_rdrsp_valid        ;
        assign u_ccp_if.sp_rdrsp_data        = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_rdrsp_data         ;
        assign u_ccp_if.sp_rdrsp_byten       = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_rdrsp_byteen       ;
        assign u_ccp_if.sp_rdrsp_last        = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_rdrsp_last         ;
        assign u_ccp_if.sp_rdrsp_rdy         = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_rdrsp_ready        ;
        assign u_ccp_if.sp_rdrsp_cancel      = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_rdrsp_cancel       ;
        
        assign u_ccp_if.sp_wr_vld            = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_wr_valid           ;
        assign u_ccp_if.sp_wr_data           = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_wr_data            ;
        assign u_ccp_if.sp_wr_byte_en        = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_wr_byte_en         ;
        assign u_ccp_if.sp_wr_beat_num       = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_wr_beat_num        ;
        assign u_ccp_if.sp_wr_last           = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_wr_last            ;
        assign u_ccp_if.sp_wr_rdy            = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_wr_ready           ;
        
        assign u_ccp_if.sp_op_rdy            = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_op_ready           ;
        assign u_ccp_if.sp_op_vld            = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_op_valid           ;
        assign u_ccp_if.sp_op_wr_data        = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_op_write_data      ;
        assign u_ccp_if.sp_op_rd_data        = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_op_read_data       ;
        assign u_ccp_if.sp_op_index_addr     = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_op_index_addr      ;
        assign u_ccp_if.sp_op_way_num        = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_op_way_num         ;
        assign u_ccp_if.sp_op_beat_num       = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_op_beat_num        ;
        assign u_ccp_if.sp_op_burst_len      = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_op_burst_len       ;
        assign u_ccp_if.sp_op_burst_type     = tb_top.dut.dmi_unit.dmi_resource_control.dmi_cache_wrap.dmi_ccp.u_ccp.scratch_op_burst_wrap      ;
<% } %>

<% if(obj.useCmc && obj.DmiInfo[obj.Id].useWayPartitioning) { %>
  <% for (var i = 0; i < obj.DmiInfo[obj.Id].nAius; i++) { %>
   assign aiu_funit_id[<%=(i+1)*wfunit-1%>:<%=i*wfunit%>] = <%=funitId[i]%>;
  <% } %>
<% } %>
<% } %>

  assign u_<%=obj.BlockId%>_read_probe_if.nc_read_valid        = tb_top.dut.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink0_valid;
  assign u_<%=obj.BlockId%>_read_probe_if.nc_read_ready        = tb_top.dut.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink0_ready;
  assign u_<%=obj.BlockId%>_read_probe_if.nc_read_addr         = tb_top.dut.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink0_addr;
  assign u_<%=obj.BlockId%>_read_probe_if.nc_read_cm_type      = tb_top.dut.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink0_cm_type;
  assign u_<%=obj.BlockId%>_read_probe_if.nc_read_aiu_trans_id = tb_top.dut.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink0_aiu_trans_id;
  assign u_<%=obj.BlockId%>_read_probe_if.nc_read_aiu_id       = tb_top.dut.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink0_aiu_id;
  assign u_<%=obj.BlockId%>_read_probe_if.nc_read_ns           = tb_top.dut.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink0_ns;


  assign u_<%=obj.BlockId%>_read_probe_if.coh_read_valid       = tb_top.dut.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink1_valid;
  assign u_<%=obj.BlockId%>_read_probe_if.coh_read_ready       = tb_top.dut.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink1_ready;
  assign u_<%=obj.BlockId%>_read_probe_if.coh_read_addr        = tb_top.dut.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink1_addr;
  assign u_<%=obj.BlockId%>_read_probe_if.coh_read_cm_type     = tb_top.dut.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink1_cm_type;
  assign u_<%=obj.BlockId%>_read_probe_if.coh_read_aiu_trans_id= tb_top.dut.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink1_aiu_trans_id;
  assign u_<%=obj.BlockId%>_read_probe_if.coh_read_aiu_id      = tb_top.dut.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink1_aiu_id;
  assign u_<%=obj.BlockId%>_read_probe_if.coh_read_ns          = tb_top.dut.dmi_unit.dmi_protocol_control.read_prot_muxarb_sink1_ns;

  assign u_<%=obj.BlockId%>_write_probe_if.nc_write_valid        = tb_top.dut.dmi_unit.dmi_protocol_control.nc_write_prot_valid;
  assign u_<%=obj.BlockId%>_write_probe_if.nc_write_ready        = tb_top.dut.dmi_unit.dmi_protocol_control.nc_write_prot_ready;
  assign u_<%=obj.BlockId%>_write_probe_if.nc_write_addr         = tb_top.dut.dmi_unit.dmi_protocol_control.nc_write_prot_addr;
  assign u_<%=obj.BlockId%>_write_probe_if.nc_write_cm_type      = tb_top.dut.dmi_unit.dmi_protocol_control.nc_write_prot_cm_type;
  assign u_<%=obj.BlockId%>_write_probe_if.nc_write_aiu_trans_id = tb_top.dut.dmi_unit.dmi_protocol_control.nc_write_prot_aiu_trans_id;
  assign u_<%=obj.BlockId%>_write_probe_if.nc_write_aiu_id       = tb_top.dut.dmi_unit.dmi_protocol_control.nc_write_prot_aiu_id;
  assign u_<%=obj.BlockId%>_write_probe_if.nc_write_ns           = tb_top.dut.dmi_unit.dmi_protocol_control.nc_write_prot_ns;


  assign u_<%=obj.BlockId%>_write_probe_if.coh_write_valid       = tb_top.dut.dmi_unit.dmi_protocol_control.write_prot_muxarb_sink0_valid;
  assign u_<%=obj.BlockId%>_write_probe_if.coh_write_ready       = tb_top.dut.dmi_unit.dmi_protocol_control.write_prot_muxarb_sink0_ready;
  assign u_<%=obj.BlockId%>_write_probe_if.coh_write_addr        = tb_top.dut.dmi_unit.dmi_protocol_control.write_prot_muxarb_sink0_addr;
  assign u_<%=obj.BlockId%>_write_probe_if.coh_write_cm_type     = tb_top.dut.dmi_unit.dmi_protocol_control.write_prot_muxarb_sink0_cm_type;
  assign u_<%=obj.BlockId%>_write_probe_if.coh_write_aiu_trans_id= tb_top.dut.dmi_unit.dmi_protocol_control.write_prot_muxarb_sink0_aiu_trans_id;
  assign u_<%=obj.BlockId%>_write_probe_if.coh_write_aiu_id      = tb_top.dut.dmi_unit.dmi_protocol_control.write_prot_muxarb_sink0_aiu_id;
  assign u_<%=obj.BlockId%>_write_probe_if.coh_write_ns          = tb_top.dut.dmi_unit.dmi_protocol_control.write_prot_muxarb_sink0_ns;
  assign u_<%=obj.BlockId%>_write_probe_if.dtw_aiu_src_id        = tb_top.dut.dmi_unit.dmi_protocol_control.write_data_initiator_id;

//-----------------------------------------------------------------------------
// Generate clocks and reset
//-----------------------------------------------------------------------------
clk_rst_gen cr_gen(.clk_fr(fr_clk), .clk_tb(tb_clk), .rst(tb_rstn));
//
//////////////////////////////////////////////////////////////////////////
//
// Always error Injection. Error testing  
//
//////////////////////////////////////////////////////////////////////////
initial begin
`ifdef ERROR_TEST
   if ($test$plusargs("always_inject_error")) begin
     ev_always_inject_error.wait_ptrigger();
     fork
<% if(obj.useCmc) { %>
   <% if (obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[0].MemType != "SYNOPSYS") { %>
   <%for( var i=0;i<nTagBanks;i++){%>
       tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_errors(100,0,1);
   <% } %>
   <% } %>
   <% if (obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[0].MemType != "SYNOPSYS") { %>
   <%for( var i=0;i<nDataBanks;i++){%>
       tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_errors(100,0,1);
   <% } %>
   <% } %>
<% } %>
<% if (typeof obj.DmiInfo[obj.Id].MemoryGeneration.wrDataMem !== 'undefined') { %>
<%   if (obj.DmiInfo[obj.Id].MemoryGeneration.wrDataMem[0].MemType != "SYNOPSYS") { %>
       tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst0.inject_errors(100,0,1);
       tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst1.inject_errors(100,0,1);
<% } } %>
     join
     $display("Always injecting correctable errors");
   end
`endif
end


//////////////////////////////////////////////////////////////////////////
//
// Error Injection one-by-one. Error testing  
//
//////////////////////////////////////////////////////////////////////////
`ifdef ERROR_TEST
   // error injection when memory exists and are not SYNOPSYS
   <% if (typeof obj.DmiInfo[obj.Id].MemoryGeneration.wrDataMem != 'undefined' &&
          obj.DmiInfo[obj.Id].MemoryGeneration.wrDataMem[0].MemType != "SYNOPSYS") { %>

       initial 
       begin
            int k_addr_inject_pct_wbuff;

            if(($value$plusargs("k_addr_inject_pct_wbuff=%d",k_addr_inject_pct_wbuff))) begin
               inject_err.wait_ptrigger();
               tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst0.init_addr_error(k_addr_inject_pct_wbuff);
            end
 
            if(($value$plusargs("k_addr_inject_pct_wbuff=%d",k_addr_inject_pct_wbuff))) begin
               inject_err.wait_ptrigger();
               tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst1.init_addr_error(k_addr_inject_pct_wbuff);
            end

       end
    
   always@(posedge dut_clk) begin
     $display("Waiting in  singleErrwbuffer0 task");   
     injectSingleErrwbuffer0.wait_ptrigger();
     injectSingleErrwbuffer0.reset();
     $display("Saw: wait in  singleErrbuffer0 task");   
     tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst0.inject_single_error();
<% if(obj.enableUnitDuplication) { %>
     tb_top.dut.dup_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst0.inject_single_error();
     $display("Saw: error was injected on the dup_unit as well");
<% } %>
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in  DoubleErrbuffer0 task");   
     injectDoubleErrwbuffer0.wait_ptrigger();
     injectDoubleErrwbuffer0.reset();
     $display("Saw: wait in  DoubleErrbuffer0 task");   
     tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst0.inject_double_error();
<% if(obj.enableUnitDuplication) { %>
     tb_top.dut.dup_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst0.inject_double_error();
     $display("Saw: error was injected on the dup_unit as well");
<% } %>
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in multi_block_single_double_Errbuffer0 task");   
     inject_multi_block_single_double_Errwbuffer0.wait_ptrigger();
     inject_multi_block_single_double_Errwbuffer0.reset();
     $display("Saw: wait in  multi_block_single_double_Errbuffer0 task");   
     tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst0.inject_multi_blk_single_double_error();
<% if(obj.enableUnitDuplication) { %>
     tb_top.dut.dup_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst0.inject_multi_blk_single_double_error();
     $display("Saw: error was injected on the dup_unit as well");
<% } %>
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in multi_block_double_Errbuffer0 task");   
     inject_multi_block_double_Errwbuffer0.wait_ptrigger();
     inject_multi_block_double_Errwbuffer0.reset();
     $display("Saw: wait in  multi_block_double_Errbuffer0 task");   
     tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst0.inject_multi_blk_double_error();
<% if(obj.enableUnitDuplication) { %>
     tb_top.dut.dup_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst0.inject_multi_blk_double_error();
     $display("Saw: error was injected on the dup_unit as well");
<% } %>
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in multi_block_single_Errbuffer0 task");   
     inject_multi_block_single_Errwbuffer0.wait_ptrigger();
     inject_multi_block_single_Errwbuffer0.reset();
     $display("Saw: wait in  multi_block_single_Errbuffer0 task");   
     tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst0.inject_multi_blk_single_error();
<% if(obj.enableUnitDuplication) { %>
     tb_top.dut.dup_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst0.inject_multi_blk_single_error();
     $display("Saw: error was injected on the dup_unit as well");
<% } %>
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in AddrErrBuffer0 task for Buffer0");   
     injectAddrErrBuffer0.wait_ptrigger();
     injectAddrErrBuffer0.reset();
     $display("Saw: wait in AddrErrBuffer0 task for Buffer0");   
     tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst0.inject_addr_error();
<% if(obj.enableUnitDuplication) { %>
     tb_top.dut.dup_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst0.inject_addr_error();
     $display("Saw: error was injected on the dup_unit as well");
<% } %>
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in  singleErrwbuffer1 task");   
     injectSingleErrwbuffer1.wait_ptrigger();
     injectSingleErrwbuffer1.reset();
     $display("Saw: wait in  singleErrbuffer1 task");   
     tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst1.inject_single_error();
<% if(obj.enableUnitDuplication) { %>
     tb_top.dut.dup_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst1.inject_single_error();
     $display("Saw: error was injected on the dup_unit as well");
<% } %>
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in  DoubleErrbuffer1 task");   
     injectDoubleErrwbuffer1.wait_ptrigger();
     injectDoubleErrwbuffer1.reset();
     $display("Saw: wait in  DoubleErrbuffer1 task");   
     tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst1.inject_double_error();
<% if(obj.enableUnitDuplication) { %>
     tb_top.dut.dup_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst1.inject_double_error();
     $display("Saw: error was injected on the dup_unit as well");
<% } %>
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in multi_block_single_double_Errbuffer1 task");   
     inject_multi_block_single_double_Errwbuffer1.wait_ptrigger();
     inject_multi_block_single_double_Errwbuffer1.reset();
     $display("Saw: wait in  multi_block_single_double_Errbuffer1 task");   
     tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst1.inject_multi_blk_single_double_error();
<% if(obj.enableUnitDuplication) { %>
     tb_top.dut.dup_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst1.inject_multi_blk_single_double_error();
     $display("Saw: error was injected on the dup_unit as well");
<% } %>
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in multi_block_double_Errbuffer1 task");   
     inject_multi_block_double_Errwbuffer1.wait_ptrigger();
     inject_multi_block_double_Errwbuffer1.reset();
     $display("Saw: wait in  multi_block_double_Errbuffer1 task");   
     tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst1.inject_multi_blk_double_error();
<% if(obj.enableUnitDuplication) { %>
     tb_top.dut.dup_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst1.inject_multi_blk_double_error();
     $display("Saw: error was injected on the dup_unit as well");
<% } %>
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in multi_block_single_Errbuffer1 task");   
     inject_multi_block_single_Errwbuffer1.wait_ptrigger();
     inject_multi_block_single_Errwbuffer1.reset();
     $display("Saw: wait in  multi_block_single_Errbuffer1 task");   
     tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst1.inject_multi_blk_single_error();
<% if(obj.enableUnitDuplication) { %>
     tb_top.dut.dup_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst1.inject_multi_blk_single_error();
     $display("Saw: error was injected on the dup_unit as well");
<% } %>
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in AddrErrBuffer1 task for Buffer1");   
     injectAddrErrBuffer1.wait_ptrigger();
     injectAddrErrBuffer1.reset();
     $display("Saw: wait in AddrErrBuffer1 task for Buffer1");   
     tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst1.inject_addr_error();
<% if(obj.enableUnitDuplication) { %>
     tb_top.dut.dup_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst1.inject_addr_error();
     $display("Saw: error was injected on the dup_unit as well");
<% } %>
     dmi_corr_uncorr_flag = 1;
   end

<% } %>
<% if(obj.useCmc) { %>

<% if (obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[0].MemType != "SYNOPSYS") { %>
   <%for( var i=0;i<nTagBanks;i++){%>

   <% if(has_secded || wbuffer_fnerrdetectcorrect) { %>
   initial begin
     int k_addr_inject_pct_tag;
     if(($value$plusargs("k_addr_inject_pct_tag=%d",k_addr_inject_pct_tag))) begin
        tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.init_addr_error(k_addr_inject_pct_tag);
     end
   end
   <% } %>

   always@(posedge dut_clk) begin
     $display("Waiting in  singleErrTag task");   
     injectSingleErrTag<%=i%>.wait_ptrigger();
     injectSingleErrTag<%=i%>.reset();
     $display("Saw wait in  singleErrTag task");   
     tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_single_error();
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in  DoubleErrTag task");   
     injectDoubleErrTag<%=i%>.wait_ptrigger();
     injectDoubleErrTag<%=i%>.reset();
     $display("Saw wait in  DoubleErrTag task");   
     tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_double_error();
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in multi_block_single_double_ErrTag task");   
     inject_multi_block_single_double_ErrTag<%=i%>.wait_ptrigger();
     inject_multi_block_single_double_ErrTag<%=i%>.reset();
     $display("Saw wait in  multi_block_single_double_ErrTag task");   
     tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_multi_blk_single_double_error();
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in multi_block_double_ErrTag task");   
     inject_multi_block_double_ErrTag<%=i%>.wait_ptrigger();
     inject_multi_block_double_ErrTag<%=i%>.reset();
     $display("Saw wait in  multi_block_double_ErrTag task");   
     tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_multi_blk_double_error();
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in multi_block_single_ErrTag task");   
     inject_multi_block_single_ErrTag<%=i%>.wait_ptrigger();
     inject_multi_block_single_ErrTag<%=i%>.reset();
     $display("Saw wait in  multi_block_single_ErrTag task");   
     tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_multi_blk_single_error();
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in AddrErrTag task for tagMem");   
     injectAddrErrTag<%=i%>.wait_ptrigger();
     injectAddrErrTag<%=i%>.reset();
     $display("Saw wait in AddrErrTag task for tagMem");   
     tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_addr_error();
     dmi_corr_uncorr_flag = 1;
   end
  
   <% } %>
   <% } %>


   <% if (obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[0].MemType != "SYNOPSYS") { %>
   <%for( var i=0;i<nDataBanks;i++){%>

   initial 
       begin
            int k_addr_inject_pct_data;
            if(($value$plusargs("k_addr_inject_pct_data=%d",k_addr_inject_pct_data))) begin
               tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.init_addr_error(k_addr_inject_pct_data);
            end
       end

   always@(posedge dut_clk) begin
     $display("Waiting in  singleErrData task");   
     injectSingleErrData<%=i%>.wait_ptrigger();
     injectSingleErrData<%=i%>.reset();
     $display("Saw wait in  singleErrData task");   
     tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_single_error();
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in  DoubleErrData task");   
     injectDoubleErrData<%=i%>.wait_ptrigger();
     injectDoubleErrData<%=i%>.reset();
     $display("Saw wait in  DoubleErrData task");   
     tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_double_error();
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in  multi_block_single_double_ErrData task");   
     inject_multi_block_single_double_ErrData<%=i%>.wait_ptrigger();
     inject_multi_block_single_double_ErrData<%=i%>.reset();
     $display("Saw wait in  multi_block_single_double_ErrData task");   
     tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_multi_blk_single_double_error();
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in  multi_block_double_ErrData task");   
     inject_multi_block_double_ErrData<%=i%>.wait_ptrigger();
     inject_multi_block_double_ErrData<%=i%>.reset();
     $display("Saw wait in  multi_block_double_ErrData task");   
     tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_multi_blk_double_error();
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in  multi_block_single_ErrData task");   
     inject_multi_block_single_ErrData<%=i%>.wait_ptrigger();
     inject_multi_block_single_ErrData<%=i%>.reset();
     $display("Saw wait in  multi_block_single_ErrData task");   
     tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_multi_blk_single_error();
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in AddrErrData task for dataMem");   
     injectAddrErrData<%=i%>.wait_ptrigger();
     injectAddrErrData<%=i%>.reset();
     $display("Saw wait in AddrErrData task for dataMem");   
     tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_addr_error();
     dmi_corr_uncorr_flag = 1;
   end
   <% } %>
<% } %>
<% } %>

<% if(obj.useCmc) { %>

<% if (obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[0].MemType != "SYNOPSYS") { %>
   always@(posedge dut_clk) begin
     forceClkgate.wait_ptrigger();
    <%for( var i=0;i<nDataBanks;i++){%>
      force  tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.EN_CLOCK_GATING = 1'b1;
    <%}%>
    <%for( var i=0;i<nTagBanks;i++){%>
      force  tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.EN_CLOCK_GATING = 1'b1;
    <%}%>
    dmi_corr_uncorr_flag = 1;
   end
   always@(posedge dut_clk) begin
     releaseClkgate.wait_ptrigger();
    <%for( var i=0;i<nDataBanks;i++){%>
      release  tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.EN_CLOCK_GATING;
    <%}%>
    <%for( var i=0;i<nTagBanks;i++){%>
      release  tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.EN_CLOCK_GATING;
    <%}%>
    dmi_corr_uncorr_flag = 1;
   end
<% } %>
<% } %>
<%if(obj.DmiInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
  always@(posedge dut_clk) begin
    setPlruAddrErrInj.wait_ptrigger();
    $display("Setting PLRU Address error injection to a non-zero value");
    tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.rpMem[0].rtlPrefixString%>.internal_mem_inst.init_addr_error(50);
  end
  always@(posedge dut_clk) begin
    setPlruSingleDataErrInj.wait_ptrigger();
    $display("Setting PLRU Single Data error injection to a non-zero value");
    tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.rpMem[0].rtlPrefixString%>.internal_mem_inst.inject_errors(50,0,0);
  end
  always@(posedge dut_clk) begin
    setPlruDoubleDataErrInj.wait_ptrigger();
    $display("Setting PLRU Double Data error injection to a non-zero value");
    tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.rpMem[0].rtlPrefixString%>.internal_mem_inst.inject_errors(0,50,0);
  end
<% } %>
<% if (obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].fnMemType == "SRAM") { %>
   always@(posedge dut_clk) begin
     $display("Waiting in injectSingleDataErrMrdSRAM");
     injectSingleDataErrMrdSRAM.wait_ptrigger();
     injectSingleDataErrMrdSRAM.reset();
     $display("Received trigger injectSingleDataErrMrdSRAM");
     tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_single_error();
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in injectDoubleDataErrMrdSRAM");
     injectDoubleDataErrMrdSRAM.wait_ptrigger();
     injectDoubleDataErrMrdSRAM.reset();
     $display("Received trigger injectDoubleDataErrMrdSRAM");
     tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_double_error();
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in injectSingleAddrErrMrdSRAM");
     injectSingleAddrErrMrdSRAM.wait_ptrigger();
     injectSingleAddrErrMrdSRAM.reset();
     $display("Received trigger injectSingleAddrErrMrdSRAM");
     tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_addr_error();
     dmi_corr_uncorr_flag = 1;
   end
<% } %>
<% if (obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].fnMemType == "SRAM") { %>
   always@(posedge dut_clk) begin
     $display("Waiting in injectSingleDataErrCmdSRAM");
     injectSingleDataErrCmdSRAM.wait_ptrigger();
     injectSingleDataErrCmdSRAM.reset();
     $display("Received trigger injectSingleDataErrCmdSRAM");
     tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_single_error();
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in injectDoubleDataErrCmdSRAM");
     injectDoubleDataErrCmdSRAM.wait_ptrigger();
     injectDoubleDataErrCmdSRAM.reset();
     $display("Received trigger injectDoubleDataErrCmdSRAM");
     tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_double_error();
     dmi_corr_uncorr_flag = 1;
   end

   always@(posedge dut_clk) begin
     $display("Waiting in injectSingleAddrErrCmdSRAM");
     injectSingleAddrErrCmdSRAM.wait_ptrigger();
     injectSingleAddrErrCmdSRAM.reset();
     $display("Received trigger injectSingleAddrErrCmdSRAM");
     tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_addr_error();
     dmi_corr_uncorr_flag = 1;
   end
   //tb_top.dut.MRDReqSbMem0.external_mem_inst.internal_mem_inst.inject_single_error
<% } %>
//-----------------------------------------------------------------------------
// PIPELINE
//-----------------------------------------------------------------------------

/*
  assert property (@(posedge tb_top.dut.clk) disable iff (tb_top.dut.reset_n == 0) (($past(tb_top.dut.axi_mst_bvalid === 1) && $past(tb_top.dut.axi_mst_bready === 0) && (tb_top.dut.axi_mst_bvalid === 0) && (tb_top.dut.axi_mst_bready === 0)) === 0)) else begin
   `uvm_info("AXI Memory Error", $sformatf("past_bvalid:%0b past_bready:%0b bvalid:%0b bready:%0b",$past(tb_top.dut.axi_mst_bvalid), $past(tb_top.dut.axi_mst_bready), tb_top.dut.axi_mst_bvalid, tb_top.dut.axi_mst_bready, $fell(tb_top.dut.axi_mst_bvalid)),UVM_NONE)
   `uvm_error($sformatf("AXI Memory Error"), $sformatf("BVALID fell when BREADY was low")); 
   end
//////////////////////////////////////////////////////////////////////////////
//
// Directed test checks
//
//////////////////////////////////////////////////////////////////////////////
   initial begin
      if (($test$plusargs("no_error"))) begin
         forever begin
            @(posedge tb_top.dut.clk);
            if (tb_top.dut.reset_n == 1) begin
               if ((tb_top.dut.dmi.csr_array.i_CMIUUELR0_ErrEntry)||
                   (tb_top.dut.dmi.csr_array.i_CMIUUELR0_ErrWay)  ||
                   (tb_top.dut.dmi.csr_array.i_CMIUUELR0_ErrWord) ||
                   (tb_top.dut.dmi.csr_array.i_CMIUUELR1_ErrAddr) ||
                   (tb_top.dut.dmi.csr_array.i_CMIUCELR0_ErrEntry)||
                   (tb_top.dut.dmi.csr_array.i_CMIUCELR0_ErrWay)  ||
                   (tb_top.dut.dmi.csr_array.i_CMIUCELR0_ErrWord) ||
                   (tb_top.dut.dmi.csr_array.i_CMIUCELR1_ErrAddr)) begin
                  `uvm_error($sformatf("ERROR LOGGING ASSERTION"), $sformatf("ELRs cannot change value in this test vector:%0b%0b%0b%0b%0b%0b%0b%0b {i_CMIUUELR0_ErrEntry,i_CMIUUELR0_ErrWay,i_CMIUUELR0_ErrWord,i_CMIUUELR1_ErrAddr,i_CMIUCELR0_ErrEntry,i_CMIUCELR0_ErrWay,i_CMIUCELR0_ErrWord,i_CMIUCELR1_ErrAddr}",
                                                                             tb_top.dut.dmi.csr_array.i_CMIUUELR0_ErrEntry,
                                                                             tb_top.dut.dmi.csr_array.i_CMIUUELR0_ErrWay,
                                                                             tb_top.dut.dmi.csr_array.i_CMIUUELR0_ErrWord,
                                                                             tb_top.dut.dmi.csr_array.i_CMIUUELR1_ErrAddr,
                                                                             tb_top.dut.dmi.csr_array.i_CMIUCELR0_ErrEntry,
                                                                             tb_top.dut.dmi.csr_array.i_CMIUCELR0_ErrWay,
                                                                             tb_top.dut.dmi.csr_array.i_CMIUCELR0_ErrWord,
                                                                             tb_top.dut.dmi.csr_array.i_CMIUCELR1_ErrAddr)); 
               end
            end
         end
      end
   end
*/
`endif
//-----------------------------------------------------------------------------
// Run Test
// Note: The test name is specified using the +UVM_TESTNAME
//-----------------------------------------------------------------------------
initial begin
    dmi_corr_uncorr_flag = 0;

  

   <% if(obj.useCmc && obj.DmiInfo[obj.Id].useWayPartitioning) { %>
    uvm_config_db#(aiu_funit_id_t)::set(.cntxt( uvm_root::get() ),
                                        .inst_name( "" ),
                                        .field_name( "aiu_funit_id" ),
                                        .value( aiu_funit_id ));

 <%}%>
    uvm_config_db#(virtual <%=obj.BlockId%>_rtl_if)::set(.cntxt( uvm_root::get() ),
                                        .inst_name( "" ),
                                        .field_name( "u_<%=obj.BlockId%>_rtl_if"),
                                        .value( u_<%=obj.BlockId%>_rtl_if ));

    uvm_config_db#(virtual <%=obj.BlockId%>_tt_if)::set(.cntxt( uvm_root::get() ),
                                        .inst_name( "" ),
                                        .field_name( "u_<%=obj.BlockId%>_tt_if"),
                                        .value( u_<%=obj.BlockId%>_tt_if ));

    uvm_config_db#(virtual dmi_csr_probe_if)::set(.cntxt( uvm_root::get() ),
                                        .inst_name( "" ),
                                        .field_name( "u_csr_probe_if" ),
                                        .value( u_csr_probe_if ));

    uvm_config_db#(virtual <%=obj.BlockId%>_read_probe_if)::set(.cntxt( uvm_root::get() ),
                                        .inst_name( "" ),
                                        .field_name( "u_<%=obj.BlockId%>_read_probe_if"),
                                        .value( u_<%=obj.BlockId%>_read_probe_if ));

    uvm_config_db#(virtual <%=obj.BlockId%>_write_probe_if)::set(.cntxt( uvm_root::get() ),
                                        .inst_name( "" ),
                                        .field_name( "u_<%=obj.BlockId%>_write_probe_if"),
                                        .value( u_<%=obj.BlockId%>_write_probe_if ));
 <% 
 for (var i = 0; i < NSMIIFTX; i++) { %>
    uvm_config_db#(virtual <%=obj.BlockId%>_smi_if)::set(.cntxt( null ),
                                        .inst_name( "uvm_test_top" ),
                                        .field_name( "m_smi<%=i%>_tx_smi_if" ),
                                        .value(m_smi<%=i%>_tx_smi_if));
<% } %>
 <% 
 for (var i = 0; i < NSMIIFRX; i++) { %>
    uvm_config_db#(virtual <%=obj.BlockId%>_smi_if)::set(.cntxt( null ),
                                        .inst_name( "uvm_test_top" ),
                                        .field_name( "m_smi<%=i%>_rx_smi_if" ),
                                        .value(m_smi<%=i%>_rx_smi_if));
<% } %>
<% if(obj.useCmc) { %>
    uvm_config_db#(virtual <%=obj.BlockId%>_ccp_if)::set(uvm_root::get(), "", "ccp<%=obj.Id%>_vif", u_ccp_if);
<% } %>



<%  if(obj.INHOUSE_APB_VIP) { %>

    injectSingleErrwbuffer0 = new("injectSingleErrTagwbuffer0");
    injectDoubleErrwbuffer0 = new("injectDoubleErrTagwbuffer0");
    inject_multi_block_single_double_Errwbuffer0 = new("inject_multi_block_single_double_Errwbuffer0");
    inject_multi_block_double_Errwbuffer0 = new("inject_multi_block_double_Errwbuffer0");
    inject_multi_block_single_Errwbuffer0 = new("inject_multi_block_single_Errwbuffer0");
    injectAddrErrBuffer0 = new("injectAddrErrBuffer0");

    injectSingleErrwbuffer1 = new("injectSingleErrTagwbuffer1");
    injectDoubleErrwbuffer1 = new("injectDoubleErrTagwbuffer1");
    inject_multi_block_single_double_Errwbuffer1 = new("inject_multi_block_single_double_Errwbuffer1");
    inject_multi_block_double_Errwbuffer1 = new("inject_multi_block_double_Errwbuffer1");
    inject_multi_block_single_Errwbuffer1 = new("inject_multi_block_single_Errwbuffer1");
    injectAddrErrBuffer1 = new("injectAddrErrBuffer1");

<% if(obj.useCmc) { %>
   <%for( var i=0;i<nTagBanks;i++){%>
    injectSingleErrTag<%=i%> = new("injectSingleErrTag<%=i%>");
    injectDoubleErrTag<%=i%> = new("injectDoubleErrTag<%=i%>");
    inject_multi_block_single_double_ErrTag<%=i%> = new("inject_multi_block_single_double_ErrTag<%=i%>");
    inject_multi_block_double_ErrTag<%=i%> = new("inject_multi_block_double_ErrTag<%=i%>");
    inject_multi_block_single_ErrTag<%=i%> = new("inject_multi_block_single_ErrTag<%=i%>");
    injectAddrErrTag<%=i%> = new("injectAddrErrTag<%=i%>");

   <% } %>
   <%for( var i=0;i<nDataBanks;i++){%>
    injectSingleErrData<%=i%> = new("injectSingleErrData<%=i%>");
    injectDoubleErrData<%=i%> = new("injectDoubleErrData<%=i%>");
    inject_multi_block_single_double_ErrData<%=i%> = new("inject_multi_block_single_double_ErrData<%=i%>");
    inject_multi_block_double_ErrData<%=i%> = new("inject_multi_block_double_ErrData<%=i%>");
    inject_multi_block_single_ErrData<%=i%> = new("inject_multi_block_single_ErrData<%=i%>");
    injectAddrErrData<%=i%> = new("injectAddrErrData<%=i%>");
   <% } %>
<% } %>
<%if(obj.DmiInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
    setPlruAddrErrInj = new("setPlruAddrErrInj");
    setPlruSingleDataErrInj = new("setPlruSingleDataErrInj");
    setPlruDoubleDataErrInj = new("setPlruDoubleDataErrInj");
<% } %>
<% if (obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].fnMemType == "SRAM") { %>
    injectSingleDataErrMrdSRAM = new("injectSingleDataErrMrdSRAM");
    injectDoubleDataErrMrdSRAM = new("injectDoubleDataErrMrdSRAM");
    injectSingleAddrErrMrdSRAM = new("injectSingleAddrErrMrdSRAM");
<% } %>
<% if (obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].fnMemType == "SRAM") { %>
    injectSingleDataErrCmdSRAM = new("injectSingleDataErrCmdSRAM");
    injectDoubleDataErrCmdSRAM = new("injectDoubleDataErrCmdSRAM");
    injectSingleAddrErrCmdSRAM = new("injectSingleAddrErrCmdSRAM");
<% } %>


    checkCELR = new("checkCELR");
    checkUELR = new("checkUELR");

    forceClkgate   = new("forceClkgate");
    releaseClkgate = new("releaseClkgate");

    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "injectSingleErrwbuffer0" ),
                                        .value( injectSingleErrwbuffer0));
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "injectDoubleErrwbuffer0" ),
                                        .value( injectDoubleErrwbuffer0));
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "inject_multi_block_single_double_Errwbuffer0" ),
                                        .value( inject_multi_block_single_double_Errwbuffer0));
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "inject_multi_block_double_Errwbuffer0" ),
                                        .value( inject_multi_block_double_Errwbuffer0));
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "inject_multi_block_single_Errwbuffer0" ),
                                        .value( inject_multi_block_single_Errwbuffer0));

    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "injectSingleErrwbuffer1" ),
                                        .value( injectSingleErrwbuffer1));
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "injectDoubleErrwbuffer1" ),
                                        .value( injectDoubleErrwbuffer1));
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "inject_multi_block_single_double_Errwbuffer1" ),
                                        .value( inject_multi_block_single_double_Errwbuffer1));
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "inject_multi_block_double_Errwbuffer1" ),
                                        .value( inject_multi_block_double_Errwbuffer1));
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "inject_multi_block_single_Errwbuffer1" ),
                                        .value( inject_multi_block_single_Errwbuffer1));
  uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "injectAddrErrBuffer0" ),
                                        .value( injectAddrErrBuffer0));
  uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "injectAddrErrBuffer1" ),
                                        .value( injectAddrErrBuffer1));

<% if(obj.useCmc) { %>
   <%for( var i=0;i<nTagBanks;i++){%>
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
                                        .value(injectAddrErrTag<%=i%>));

   <% } %>
   <%for( var i=0;i<nDataBanks;i++){%>
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
                                        .value(injectAddrErrData<%=i%>));

   <% } %>
<% } %>
<%if(obj.DmiInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "setPlruAddrErrInj" ),
                                        .value(setPlruAddrErrInj));
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "setPlruSingleDataErrInj" ),
                                        .value(setPlruSingleDataErrInj));

    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "setPlruDoubleDataErrInj" ),
                                        .value(setPlruDoubleDataErrInj));
<% } %>
<% if (obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].fnMemType == "SRAM") { %>
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "injectSingleDataErrMrdSRAM" ),
                                        .value(injectSingleDataErrMrdSRAM));
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "injectDoubleDataErrMrdSRAM" ),
                                        .value(injectDoubleDataErrMrdSRAM));
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "injectSingleAddrErrMrdSRAM" ),
                                        .value(injectSingleAddrErrMrdSRAM));
<% } %>
<% if (obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].fnMemType == "SRAM") { %>
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "injectSingleDataErrCmdSRAM" ),
                                        .value(injectSingleDataErrCmdSRAM));
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "injectDoubleDataErrCmdSRAM" ),
                                        .value(injectDoubleDataErrCmdSRAM));
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "injectSingleAddrErrCmdSRAM" ),
                                        .value(injectSingleAddrErrCmdSRAM));
<% } %>
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "uvm_test_top.m_env" ),
                                        .field_name( "checkCELR" ),
                                        .value( checkCELR));
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "uvm_test_top.m_env" ),
                                        .field_name( "checkUELR" ),
                                        .value( checkUELR));

    uvm_config_db#(uvm_event)::set(.cntxt( uvm_root::get()),
                                        .inst_name( "" ),
                                        .field_name( "forceClkgate" ),
                                        .value(forceClkgate));

    uvm_config_db#(uvm_event)::set(.cntxt( uvm_root::get()),
                                        .inst_name( "" ),
                                        .field_name( "releaseClkgate" ),
                                        .value(releaseClkgate));

    uvm_config_db#(virtual <%=obj.BlockId%>_apb_if )::set(.cntxt( uvm_root::get()),
                                        .inst_name( "" ),
                                        .field_name( "apb_if" ),
                                        .value(apb_if ));

    uvm_config_db#(virtual <%=obj.BlockId%>_apb_if )::set(.cntxt( null ),
                                        .inst_name( "uvm_test_top.m_env.m_apb_agent.m_apb_driver" ),
                                        .field_name( "m_vif" ),
                                        .value(apb_if ));
<%  } %>

    uvm_config_db#(virtual <%=obj.BlockId%>_q_chnl_if )::set(.cntxt( uvm_root::get()),
                                        .inst_name( "" ),
                                        .field_name( "m_q_chnl_if" ),
                                        .value(m_q_chnl_if ));

<% if(obj.USE_VIP_SNPS) { %>
    uvm_config_db#(svt_axi_uvm_pkg::svt_axi_vif)::set(.cntxt(uvm_root::get()),
                                        .inst_name("uvm_test_top.m_env.m_axi_system_env"),
                                        .field_name("vif"), 
                                        .value(axi_vip_if));
    m_<%=obj.BlockId%>_axi_slv_if.IS_ACTIVE = 0;
<% } else { %>                                    
    m_<%=obj.BlockId%>_axi_slv_if.IS_ACTIVE = 1;
<% } %>
    uvm_config_db#(virtual <%=obj.BlockId%>_axi_if)::set(.cntxt( uvm_root::get() ),
                                        .inst_name( "" ),
                                        .field_name( "m_<%=obj.BlockId%>_axi_slv_if" ),
                                        .value( m_<%=obj.BlockId%>_axi_slv_if ));
//`ifdef VCS_SIM
`ifdef DUMP_ON
  if ($test$plusargs("en_dump")) begin
   $vcdpluson;
  end
`endif


/////////////////////////////////////////////////////////////////////
//
// Error Testing Percentage based
//
/////////////////////////////////////////////////////////////////////
   // CSR Tests only knob


   run_test("dmi_test");
   //repeat(1000) @(posedge tb_clk);
   $finish;

end

<% if(obj.useResiliency) { %>
 fault_injector_checker fault_inj_check(dut_clk, soft_rstn);
 placeholder_connectivity_checker placeholder_connec_chk(dut_clk, soft_rstn);
 initial begin
<% if(obj.testBench == 'dmi') { %>
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
 end

 ////TODO FIXME inject error in which IF?
 //assign smi_req_addr_modified = smi_if.smi_addr ^ slv_req_corruption_vector;
 //assign smi_req_data_modified = smi_if.smi_dp_data ^ slv_data_corruption_vector;
<% } %>



<% if(!obj.CUSTOMER_ENV) { %>
//Task calls end of simulation tasks and pending transaction methods
task assert_error(input string verbose, input string msg);
    uvm_component  m_comp[$];
    dmi_scoreboard m_scb;

    uvm_top.find_all("uvm_test_top.m_env.m_sb", m_comp, uvm_top); 
    if(m_comp.size() == 0) begin
        `uvm_fatal("tb_top", "none of the components are found with specified name");
    end
    if(m_comp.size() > 1) begin
        foreach(m_comp[i]) 
            `uvm_info("tb_top", $psprintf("component: %s", m_comp[i].get_full_name()), UVM_LOW);
        `uvm_fatal("tb_top", "multiple components with same name are found, components are specified above");
    end

    //TODO FIXME
    //Must call pending transactions method

    if(verbose == "FATAL") begin 
        `uvm_fatal("assert_error", msg); 
    end else begin 
        `uvm_error("assert_error", msg); 
    end
endtask: assert_error
<% } %>


/////////////////////////////////////////////////////////////////////////////////
// This block was meant to work around an issue that was reported by CONC-10113
// Please refer to the Ticket if more details are required...
// On a side note, the implementation below is mainly for DUP_UNIT. This code
// might have to get updated if we ever encounter such behavior on the DMI_UNIT.
/////////////////////////////////////////////////////////////////////////////////
<% if(obj.assertOn & obj.useResiliency & obj.enableUnitDuplication) { %>

`ifdef OVL_ASSERT_ON
initial begin : dmi_unit_duplicate
   int numDupTrFound=0;
   int noTransGenOnDupUnit;
 
   if ($value$plusargs("noTransGenOnDupUnit=%d",noTransGenOnDupUnit)) begin
      forever begin : main_loop
        @(posedge tb_top.dut.dmi_unit.clk);

        //DUP_UNIT:::
        if ((tb_top.dut.dup_unit.axi_mst_aw_valid) &
            (tb_top.dut.dup_unit.axi_mst_aw_ready)) begin
              ++numDupTrFound;       // transaction has been detected.
              `uvm_info("tb_top", $psprintf("HxP:: A valid trans was detected in DUP_UNIT.."), UVM_LOW);
        end

        //Force b_valid to 0, if not trans had been seen in the DUP_UNIT.
        if (numDupTrFound==0) begin
            force tb_top.dut.dup_unit.axi_mst_b_valid=1'b0;
        end
        else begin 
             if (tb_top.dut.dup_unit.axi_mst_b_valid) begin
                 --numDupTrFound;
                 `uvm_info("tb_top", $psprintf("HxP:: A valid Resp was detected in DUP_UNIT -- %0d left to be processed..",numDupTrFound), UVM_LOW);
             end
             else begin
                 //We are expecting b_valid to be asserted as numDupTrFound diff than 0..
                 release tb_top.dut.dup_unit.axi_mst_b_valid;
             end
        end
      end : main_loop
   end
end : dmi_unit_duplicate

`endif
<% } %>


//////////////////////////////////////////////////////////////////////////////
// This block is only going to be used by the trace_debug_scoreboard.svh.
// The current RTL has added three unsynthesized registers. The following
// are checked in this new block::
//  1- Compare these RTL registers values against the DV expected values
//  2- TimeStamp wrap condition.. it is checked, if and only if the following
//     parm is used... " +frcModified "
//////////////////////////////////////////////////////////////////////////////
<% if (obj.assertOn) { %>
`ifdef OVL_ASSERT_ON
initial begin : trace_regs_count
<% var numAccum = 3; %>        // Number of Accumulators in TCAP
   reg tcapRegCheck        = 0;
   reg updateTStamp        = 0;
   int tsClock_limit       = 0;
   logic [31:0] TimeoutVal = 32'h400;

<% for (var i=0; i<numAccum; i++) { %>
   logic [31:0] TimeoutSave<%=i%>;
<% } %>

   forever begin

      assign  u_dmi0_rtl_if.tsClock        = tb_top.dut.trace_capture.capture_frc;
      assign  u_dmi0_rtl_if.captured_count = tb_top.dut.trace_capture.cover_captured_count; 
      assign  u_dmi0_rtl_if.dtwdbg_count   = tb_top.dut.trace_capture.cover_dtwdbg_count; 
      assign  u_dmi0_rtl_if.dropped_count  = tb_top.dut.trace_capture.cover_dropped_count; 
      
      //There are 3 Accumulators implemented by TCAP.
<% for (var i=0; i<numAccum; i++) { %>
      assign  u_dmi0_rtl_if.acc<%=i%>_cnt_dffre    = tb_top.dut.trace_capture.force_accum_<%=i%>_counter_dffre.q;
      assign  u_dmi0_rtl_if.acc<%=i%>_cnt_expired  = tb_top.dut.trace_capture.force_accum_<%=i%>_counter_expired;
      assign  u_dmi0_rtl_if.acc<%=i%>_cnt_dffre_en = tb_top.dut.trace_capture.force_accum_<%=i%>_counter_dffre.en;
<% } %>

      @(posedge tb_top.dut.trace_capture.clk);
      if (tb_top.dut.trace_capture.reset_n) begin  

          // Let's read the registers final value, as the part becomes idle
          if (tb_top.dut.dmi_unit.dmi_idle_q && tcapRegCheck==1) begin
                trace_debug_scb::checkRtlRegCount = 1;
                trace_debug_scb::captured_count = u_dmi0_rtl_if.captured_count;
                trace_debug_scb::dropped_count  = u_dmi0_rtl_if.dropped_count;
                trace_debug_scb::dtwdbg_count   = u_dmi0_rtl_if.dtwdbg_count;

                tcapRegCheck = 0;
          end
          else if (tb_top.dut.trace_capture.trace_capture_busy) begin
                tcapRegCheck = 1;
          end

          // Check the FRC <==> TimeStamp reg
          if (($value$plusargs("frcModified=%d",frcModified))         && 
              (tb_top.dut.trace_capture.capture_frc < tsClock_limit)  &&
              (trace_debug_scb::frcAlterAndWrap==1))   begin 

              trace_debug_scb::frcAlterAndWrap = 2;    // Altered and Wrapped 
          end

          // Registering the FRC (free runing counter clock)
          trace_debug_scb::tsClock = u_dmi0_rtl_if.tsClock;

          // Time to release the force below.
          if ((updateTStamp != 0) && (trace_debug_scb::frcAlterAndWrap!=2)) begin     
              force tb_top.dut.trace_capture.capture_frc_upd = 1'b0;
              release tb_top.dut.trace_capture.capture_frc;
          end else begin
              release tb_top.dut.trace_capture.capture_frc_upd;
          end

          // You need to use this parm to check for the TimeStamp WRAP condition
          if (($value$plusargs("frcModified=%d",frcModified)) && 
              (updateTStamp == 0) &&  
              (u_dmi0_rtl_if.tsClock > $urandom_range(200000,400000))  &&
              (!tb_top.dut.trace_capture.dtw_resp_valid)) begin
    
               force tb_top.dut.trace_capture.capture_frc = 32'hFFFF_F000;
               trace_debug_scb::frCounter = 32'hFFFF_F000;    // FRC Altered, not wrapped yet
               trace_debug_scb::frcAlterAndWrap = 1;          // FRC Altered, not wrapped yet

               // Number of clock before checking if Wrap actually occured.
               tsClock_limit = $urandom_range(10,200);
               ++updateTStamp;
          end
      end

      // CHECK ADDED FOR THE 3 ACCUMULATOR COUNTERS....
  <% for (var i=0; i<numAccum; i++) { %>
      // Accumulator counter should not exceed 2**10.
      if ((u_dmi0_rtl_if.acc<%=i%>_cnt_dffre > TimeoutVal) && (u_dmi0_rtl_if.acc<%=i%>_cnt_expired)) begin
          `uvm_error($sformatf("One of the TCAP Accumulators has exceeded the timeout 2**10 --"), $sformatf("signal to look for :: force_accum_<%=i%>_counter_dffre.q."))
      end 

      // Check to make sure the accumulator counter updates correctly.
      if ((u_dmi0_rtl_if.acc<%=i%>_cnt_dffre != 0)    &&
          (u_dmi0_rtl_if.acc<%=i%>_cnt_dffre_en != 0) &&
          (u_dmi0_rtl_if.acc<%=i%>_cnt_dffre != TimeoutSave<%=i%>+1)) begin
             `uvm_error($sformatf("One of the TCAP Accumulators counter has incremented incorrectly --"), $sformatf("signal to look for :: force_accum_<%=i%>_counter_dffre.q."))
      end else begin
          if (u_dmi0_rtl_if.acc<%=i%>_cnt_dffre_en) TimeoutSave<%=i%> = u_dmi0_rtl_if.acc<%=i%>_cnt_dffre; 
      end 
   <% } %>

   end
end : trace_regs_count
`endif
<% } %>

`ifdef ERROR_TEST
initial
begin

<% if(obj.useCmc) { %>
    string Datafnerrdetectcorrect = "<%=obj.DmiInfo[obj.Id].ccpParams.DataErrInfo%>";
    string Tagfnerrdetectcorrect = "<%=obj.DmiInfo[obj.Id].ccpParams.TagErrInfo%>";
<%}%>
 

    int k_prob_ccp_single_bit_tag_error;
    int	k_prob_ccp_single_bit_data_error;
    int k_prob_ccp_double_bit_tag_error;
    int k_prob_ccp_double_bit_data_error;

    if(!($value$plusargs("k_prob_ccp_single_bit_tag_error=%d",k_prob_ccp_single_bit_tag_error))) begin
        k_prob_ccp_single_bit_tag_error = 10;
    end

    if(!($value$plusargs("k_prob_ccp_single_bit_data_error=%d",k_prob_ccp_single_bit_data_error))) begin
        k_prob_ccp_single_bit_data_error = 5;
    end

    if(!($value$plusargs("k_prob_ccp_double_bit_tag_error=%d",k_prob_ccp_double_bit_tag_error))) begin
        k_prob_ccp_double_bit_tag_error = 20;
    end

    if(!($value$plusargs("k_prob_ccp_double_bit_data_error=%d",k_prob_ccp_double_bit_data_error))) begin
        k_prob_ccp_double_bit_data_error = 25;
    end
    <% if(obj.useCmc) { %>
       if($test$plusargs("ccp_if_disable"))begin
    <% if (obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[0].MemType != "SYNOPSYS") { %>
        <%for( var i=0;i<nDataBanks;i++){%>
          force  tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.EN_CLOCK_GATING = 1'b1;
        <%}%>
    <% } %>
    <% if (obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[0].MemType != "SYNOPSYS") { %>
        <%for( var i=0;i<nTagBanks;i++){%>
          force  tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.EN_CLOCK_GATING = 1'b1;
        <%}%>
    <%}%>
       end
    <%}%>



<% if(obj.useCmc) { %>
    <% if (obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[0].MemType != "SYNOPSYS") { %>
    if ($test$plusargs("ccp_single_bit_tag_error_test") &&  
        ((Tagfnerrdetectcorrect == "SECDED") || 
        (Tagfnerrdetectcorrect == "SECDED64BITS") || 
        (Tagfnerrdetectcorrect == "SECDED128BITS") 
        )) begin
          dmi_corr_uncorr_flag = 1;
        <%for( var i=0;i<nTagBanks;i++){%>
            tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_errors(k_prob_ccp_single_bit_tag_error,0,0);
        <%}%>
    end else if (($test$plusargs("ccp_double_bit_tag_error_test")) && 
        ((Tagfnerrdetectcorrect == "PARITYENTRY") || 
        (Tagfnerrdetectcorrect == "PARITY8BITS") || 
        (Tagfnerrdetectcorrect == "PARITY16BITS"))) begin
          dmi_corr_uncorr_flag = 1;
        <%for( var i=0;i<nTagBanks;i++){%>
            tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_errors(k_prob_ccp_single_bit_tag_error,0,0);
        <%}%>
    end

    if (($test$plusargs("ccp_double_bit_tag_error_test")) &&  
        ((Tagfnerrdetectcorrect == "SECDED") || 
        (Tagfnerrdetectcorrect == "SECDED64BITS") || 
        (Tagfnerrdetectcorrect == "SECDED128BITS") 
        )) begin
          dmi_corr_uncorr_flag = 1;
        <%for( var i=0;i<nTagBanks;i++){%>
            tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_errors(0,k_prob_ccp_double_bit_tag_error,0);
        <%}%>
    end
    <% } %>
    <% if (obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[0].MemType != "SYNOPSYS") { %>
    if ($test$plusargs("ccp_single_bit_data_error_test") &&  
        ((Datafnerrdetectcorrect == "SECDED") || 
        (Datafnerrdetectcorrect == "SECDED64BITS") || 
        (Datafnerrdetectcorrect == "SECDED128BITS") 
        )) begin
          dmi_corr_uncorr_flag = 1;
        <%for( var i=0;i<nDataBanks;i++){%>
            tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_errors(k_prob_ccp_single_bit_data_error,0,1);
        <%}%>
    end else if (($test$plusargs("ccp_double_bit_data_error_test")) && 
        ((Datafnerrdetectcorrect == "PARITYENTRY") || 
        (Datafnerrdetectcorrect == "PARITY8BITS") || 
        (Datafnerrdetectcorrect == "PARITY16BITS"))) begin
          dmi_corr_uncorr_flag = 1;
        <%for( var i=0;i<nDataBanks;i++){%>
            tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_errors(0,k_prob_ccp_double_bit_data_error,0);
        <%}%>
    end

    if (($test$plusargs("ccp_double_bit_data_error_test")) &&  
        ((Datafnerrdetectcorrect == "SECDED") || 
        (Datafnerrdetectcorrect == "SECDED64BITS") || 
        (Datafnerrdetectcorrect == "SECDED128BITS") 
        )) begin
          dmi_corr_uncorr_flag = 1;
        <%for( var i=0;i<nDataBanks;i++){%>
            tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_errors(0,k_prob_ccp_double_bit_data_error,0);
        <%}%>
    end

    if ((($urandom_range(0,100) < 50 && 
          ((Datafnerrdetectcorrect == "SECDED") ||
          (Datafnerrdetectcorrect == "SECDED64BITS") || 
          (Datafnerrdetectcorrect == "SECDED128BITS"))) &&  
            $test$plusargs("Data_rand_single_bit_error_test"))
          ) begin
          dmi_corr_uncorr_flag = 1;
        <%for( var i=0;i<nDataBanks;i++){%>
            tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.inject_errors(k_prob_ccp_single_bit_data_error,0,0);
        <%}%>
     end
    if ((($urandom_range(0,100) < 50 && 
          ((Tagfnerrdetectcorrect == "SECDED") ||
          (Tagfnerrdetectcorrect == "SECDED64BITS") || 
          (Tagfnerrdetectcorrect == "SECDED128BITS"))) &&  
            $test$plusargs("tag_rand_single_bit_error_test"))
          ) begin
          dmi_corr_uncorr_flag = 1;

        <%for( var i=0;i<nTagBanks;i++){%>
            tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.inject_errors(k_prob_ccp_single_bit_tag_error,0,0);
        <%}%>
    end
<% } %>
<% } %>
 end 
 `endif 
//Free Running Counter to mimic Eviction Counter
// in IO Cache.

<% if(obj.useCmc) { %>

assign u_ccp_if.nru_counter = nru_counter;

always @ (posedge ccp_clk or negedge ccp_rstn)
begin
    if(~ccp_rstn) begin
        nru_counter <= '0;
    end else begin
        if(nru_counter<(<%=nWays%>-1)) 
            nru_counter <= nru_counter+1'b1;
        else 
            nru_counter <= '0;
    end
end
<% } %>
//===================================================================
//
//          OSKI SVA
//===================================================================
<%if(obj.OSKI_CCP_SVA && obj.useCmc){%>
<% if (obj.strProjectName) { %>
  bind   <%=obj.strProjectName%>__<%=obj.DutInfo.strRtlNamePrefix%>0___dmi__dmi_ccp_ctrl_intf__dmi_ccp fv_ccp_top fv_ccp_top(.*,
<% } else { %>
  bind   top__<%=obj.DutInfo.strRtlNamePrefix%>0___dmi__dmi_ccp_ctrl_intf__dmi_ccp fv_ccp_top fv_ccp_top(.*,
<% } %>


    <% 
    if (obj.strProjectName) { 
        var dutPrefix = obj.strProjectName + "__" + obj.DutInfo.strRtlNamePrefix  + "0___dmi__dmi_ccp_ctrl_intf__dmi_ccp" ; 
    }else{ 
        var dutPrefix = "top__" + obj.DutInfo.strRtlNamePrefix + "0___dmi__dmi_ccp_ctrl_intf__dmi_ccp";
    } 

    %>


.ctrl_fill_valid    ( dmi_tb_top.ctrl_fill_vld_flop       ) ,
.cache_fill_ready   ( dmi_tb_top.cache_fill_rdy_flop        ) ,
.ctrl_fill_address  ( dmi_tb_top.addr_flop                  ) ,
<% if( nWays>1 ) { %>
.ctrl_fill_way_num  ( dmi_tb_top.wayn_flop                  ) ,
<% }else{ %>
.ctrl_fill_way_num  ( 0                          ) ,
<%}%>
.ctrl_fill_state    ( dmi_tb_top.state_flop                 ) ,
<% if( obj.wSecurityAttribute > 0 ) { %>
.ctrl_fill_security ( dmi_tb_top.security_flop              ) ,
<% }else{ %>
.ctrl_fill_security ( 0                          ) ,
<%}%>

.wr_only_bypass_valid        ( <%=dutPrefix%>.ccp.tagpipe__wr_only_bypass_valid     ) ,
.wr_only_bypass              ( <%=dutPrefix%>.ccp.tagpipe__wr_only_bypass           ) ,
.wr_only_bypass_port         ( <%=dutPrefix%>.ccp.tagpipe__wr_only_bypass_port      ) ,
.write_control_fifo_ready    ( <%=dutPrefix%>.ccp.tagpipe__write_control_fifo_ready ) ,
.datapipe_ctrl_op_valid      ( <%=dutPrefix%>.ccp.tagpipe__datapipe_ctrl_op_valid   ) ,
.datapipe_ctrl_op_data       ( <%=dutPrefix%>.ccp.tagpipe__datapipe_ctrl_op_data    ) ,
.datapipe_ctrl_op_ready      ( <%=dutPrefix%>.ccp.tagpipe__datapipe_ctrl_op_ready   ) ,
.rdrsp_port_valid0           ( <%=dutPrefix%>.ccp.tagpipe__rdrsp_port_valid0        ) ,
.rdrsp_port_control0         ( <%=dutPrefix%>.ccp.tagpipe__rdrsp_port_control0      ) ,
.rdrsp_port_ready0           ( <%=dutPrefix%>.ccp.tagpipe__rdrsp_port_ready0        ) ,
.rdrsp_port_valid1           ( <%=dutPrefix%>.ccp.tagpipe__rdrsp_port_valid1        ) ,
.rdrsp_port_control1         ( <%=dutPrefix%>.ccp.tagpipe__rdrsp_port_control1      ) ,
.rdrsp_port_ready1           ( <%=dutPrefix%>.ccp.tagpipe__rdrsp_port_ready1        ) ,
.evict_port_valid0           ( <%=dutPrefix%>.ccp.tagpipe__evict_port_valid0        ) ,
.evict_port_control0         ( <%=dutPrefix%>.ccp.tagpipe__evict_port_control0      ) ,
.evict_port_ready0           ( <%=dutPrefix%>.ccp.tagpipe__evict_port_ready0        ) ,
.evict_port_valid1           ( <%=dutPrefix%>.ccp.tagpipe__evict_port_valid1        ) ,
.evict_port_control1         ( <%=dutPrefix%>.ccp.tagpipe__evict_port_control1      ) ,
.evict_port_ready1           ( <%=dutPrefix%>.ccp.tagpipe__evict_port_ready1        ) ,
.rtl_ctrl_op_address_p2      ( <%=dutPrefix%>.ccp.tagpipe__ctrl_op_address_p2       ) ,
.tagpipe_maint_read_data_en  ( <%=dutPrefix%>.ccp.tagpipe__maint_read_data_en       ) ,
.tagpipe_maint_read_data     ( <%=dutPrefix%>.ccp.tagpipe__maint_read_data          ) ,
.datapipe_maint_read_data_en ( <%=dutPrefix%>.ccp.datapipe__maint_read_data_en      ) ,
.datapipe_maint_read_data    ( <%=dutPrefix%>.ccp.datapipe__maint_read_data         )
`ifndef CCP_FV_NUM_WAY_IS_1
   ,.random_counter(<%=dutPrefix%>.ccp.tagpipe.replacement_policy.random_counter),
`endif

.tag_mem_chip_en       ( {
<%for( var i=0;i<nTagBanks;i++){%>
<% if((i+1) == nTagBanks){%>
<%=dutPrefix%>.mem.tag_mem<%=i%>_chip_en
<%}else{%>
<%=dutPrefix%>.mem.tag_mem<%=i%>_chip_en,
<%}}%>
}) ,

.tag_mem_write_en      ( {
<%for( var i=0;i<nTagBanks;i++){%>
<% if((i+1) == nTagBanks){%>
<%=dutPrefix%>.mem.tag_mem<%=i%>_write_en
<%}else{%>
<%=dutPrefix%>.mem.tag_mem<%=i%>_write_en,
<%}}%>
}) ,

.tag_mem_write_en_mask ( {
<%for( var i=0;i<nTagBanks;i++){%>
<% if((i+1) == nTagBanks){%>
<%=dutPrefix%>.mem.tag_mem<%=i%>_write_en_mask
<%}else{%>
<%=dutPrefix%>.mem.tag_mem<%=i%>_write_en_mask,
<%}}%>
} ) ,
.tag_mem_address       ( {
<%for( var i=0;i<nTagBanks;i++){%>
<% if((i+1) == nTagBanks){%>
<%=dutPrefix%>.mem.tag_mem<%=i%>_address
<%}else{%>
<%=dutPrefix%>.mem.tag_mem<%=i%>_address,
<%}}%>
}) ,

.tag_mem_data_in       ( {
<%for( var i=0;i<nTagBanks;i++){%>
<% if((i+1) == nTagBanks){%>
<%=dutPrefix%>.mem.tag_mem<%=i%>_data_in
<%}else{%>
<%=dutPrefix%>.mem.tag_mem<%=i%>_data_in,
<%}}%>
}) ,

.tag_mem_data_out      ( {
<%for( var i=0;i<nTagBanks;i++){%>
<% if((i+1) == nTagBanks){%>
<%=dutPrefix%>.mem.tag_mem<%=i%>_data_out
<%}else{%>
<%=dutPrefix%>.mem.tag_mem<%=i%>_data_out,
<%}}%>
})

);


<%}%>

//Checking clock idle when qREQn and qACCEPTn are low (entered into pma)
<% if(obj.DmiInfo[obj.Id].usePma) { %>
assert_clk_idle_when_pma_asserted : assert property (
    @(posedge fr_clk) disable iff (!soft_rstn)
    (!m_q_chnl_if.QREQn && !m_q_chnl_if.QACCEPTn ) |-> !dut_clk
    ) else assert_error("ERROR", "Dut clock is not stable low when RTL entered into PMA");
<% } %>

endmodule

/*
<%=JSON.stringify(obj,null,' ')%>
*/
