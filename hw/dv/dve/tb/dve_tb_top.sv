// DVE TB top
 
<% if(obj.useResiliency) { %>
`include "fault_injector_checker.sv"
<% } %>


module tb_top();

import uvm_pkg::*;
`include "uvm_macros.svh"
import <%=obj.BlockId%>_smi_agent_pkg::*;

import <%=obj.BlockId%>_test_lib_pkg::*;

// TB clk and rst
bit dut_clk;
bit tb_clk;
bit tb_rstn;
logic soft_rstn;

wire       dve_apb_slv_pready;
wire[31:0] dve_apb_slv_prdata;
wire       dve_apb_slv_pslverr;

wire dve_irq_uc;
wire dve_irq_c;

<% if(obj.useResiliency) { %>
 logic[1023:0] slv_req_corruption_vector = 1024'b0;
 logic[1023:0] slv_data_corruption_vector = 1024'b0;
 logic[WSMIADDR-1:0] smi_req_addr_modified;
 logic[<%=obj.DveInfo[obj.Id].wData%>-1:0] smi_req_data_modified;  //TODO checkme: flat view of txn payload data for error injection

 logic bist_bist_next_ack;
 logic bist_domain_is_on;
 logic fault_mission_fault;
 logic fault_latent_fault;
 logic fault_cerr_over_thres_fault;
<% } %>

// SMI interfaces from TB perspective
// SMI 0 non data [request]  | TX | CMDreq
// SMI 0 non data [request]  | RX | SNPreq, STRreq
// SMI 1 non data [response] | TX | SNPrsp, STRrsp
// SMI 1 non data [response] | RX | CMDrsp, DTWrsp, CMPrsp
// SMI 2 data     [request]  | TX | DTWreq

//SMI Interface
<% for (var i = 0; i < obj.nSmiRx; i++) { %>
<%=obj.BlockId%>_smi_if m_smi<%=i%>_tx_vif(dut_clk,soft_rstn,"m_smi<%=i%>_tx");
<% } %>

<% for (var i = 0; i < obj.nSmiTx; i++) { %>
<%=obj.BlockId%>_smi_if m_smi<%=i%>_rx_vif(dut_clk,soft_rstn,"m_smi<%=i%>_rx");
<% } %>

<%=obj.BlockId%>_apb_if     m_apb_if(dut_clk, soft_rstn);

//Q-channel interface
<%=obj.BlockId%>_q_chnl_if  m_q_chnl_if(tb_clk, tb_rstn);

<%=obj.BlockId%>_stall_if <%=obj.BlockId%>_sb_stall_if();

<%=obj.BlockId%>_clock_counter_if m_clock_counter_if(tb_clk, tb_rstn);
assign m_clock_counter_if.probe_sig1 = dut.unit.u_protman.csr_DvmSnoopDisable_ff;
   
uvm_event         toggle_clk;
uvm_event         toggle_rstn;

// Setup UVM config db for SMI RX/TX interfaces from TB perspective
initial begin
//SmiTx ports from TB prespective
<% for (var i = 0; i < obj.nSmiRx; i++) { %>
  uvm_config_db #(virtual <%=obj.BlockId%>_smi_if)::set(
    .cntxt(null),
    .inst_name("uvm_test_top"),
    .field_name("m_smi<%=i%>_tx_vif"),
    .value(m_smi<%=i%>_tx_vif)
  );
<% } %>

//SmiRxProts from TB prespective
<% for (var i = 0; i < obj.nSmiTx; i++) { %>
  uvm_config_db #(virtual <%=obj.BlockId%>_smi_if)::set(
    .cntxt(null),
    .inst_name("uvm_test_top"),
    .field_name("m_smi<%=i%>_rx_vif"),
    .value(m_smi<%=i%>_rx_vif)
  );
<% } %>
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
<% if (obj.DveInfo[obj.Id].usePma) { %>
always @(negedge tb_clk) begin
  enable = !(~m_q_chnl_if.QREQn && ~m_q_chnl_if.QACCEPTn);
end
<% } %>

assign dut_clk = enable ? tb_clk : 0;

bit soft_rstn_en=1;
always @(posedge tb_clk) begin
    toggle_rstn.wait_trigger();
    @(negedge tb_clk);
    $display("treggered reset event @time: %0t",$time);
    soft_rstn_en = ~soft_rstn_en;
end

assign soft_rstn = soft_rstn_en ? tb_rstn : 0;

<% for (var i = 0; i < obj.nSmiRx; i++) { %>
 <%  if (obj.DveInfo[obj.Id].interfaces.smiRxInt[i].params.nSmiDPvc) { %> 
assign (supply0, supply1) dut.<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>dp_valid = m_smi<%=i%>_tx_vif.force_smi_msg_valid;
assign (supply0, supply1) dut.<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>dp_ready = m_smi<%=i%>_tx_vif.force_smi_msg_ready;
<% } else { %>
assign (supply0, supply1) dut.<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_valid = m_smi<%=i%>_tx_vif.force_smi_msg_valid;
assign (supply0, supply1) dut.<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_ready = m_smi<%=i%>_tx_vif.force_smi_msg_ready;
<% } %> 
<% } %> 

// DUT instantiation
<%=obj.DutInfo.moduleName%> dut(
//dve_0 dut(
  .<%=obj.DveInfo[obj.Id].interfaces.clkInt.name%>clk(dut_clk),
  .<%=obj.DveInfo[obj.Id].interfaces.clkInt.name%>reset_n(soft_rstn),
  .<%=obj.DveInfo[obj.Id].interfaces.clkInt.name%>test_en(1'b0),

  .<%=obj.DveInfo[obj.Id].interfaces.uIdInt.name%>my_n_unit_id(<%=obj.DveInfo[obj.Id].wNUnitId%>'h0),
  .<%=obj.DveInfo[obj.Id].interfaces.uIdInt.name%>my_f_unit_id(DVE_FUNIT_IDS),

  .<%=obj.DveInfo[obj.Id].interfaces.uSysIdInt.name%>f_unit_id(DVM_AIU_FUNIT_IDS),
  .<%=obj.DveInfo[obj.Id].interfaces.uSysNodeIdInt.name%>n_unit_id(DVM_AIU_NUNIT_IDS),

  .<%=obj.DveInfo[obj.Id].interfaces.uIdInt.name%>my_csr_rpn(8'h0),  //RPN width is always 8 bits as per Ncore3SysArch spec
  .<%=obj.DveInfo[obj.Id].interfaces.uIdInt.name%>my_csr_nrri(4'h0), //NRRI width is always 4 bits as per Ncore3SysArch spec

  //APB control if *****************************************
  .<%=obj.DveInfo[obj.Id].interfaces.apbInt.name%>paddr  			(m_apb_if.paddr),
  .<%=obj.DveInfo[obj.Id].interfaces.apbInt.name%>pwrite 			(m_apb_if.pwrite),
  .<%=obj.DveInfo[obj.Id].interfaces.apbInt.name%>psel   		        (m_apb_if.psel),
  .<%=obj.DveInfo[obj.Id].interfaces.apbInt.name%>penable		        (m_apb_if.penable),
  .<%=obj.DveInfo[obj.Id].interfaces.apbInt.name%>prdata 			(m_apb_if.prdata),
  .<%=obj.DveInfo[obj.Id].interfaces.apbInt.name%>pwdata 			(m_apb_if.pwdata),
  .<%=obj.DveInfo[obj.Id].interfaces.apbInt.name%>pready 			(m_apb_if.pready),
  .<%=obj.DveInfo[obj.Id].interfaces.apbInt.name%>pslverr		        (m_apb_if.pslverr),
<%  if(obj.DveInfo[obj.Id].interfaces.apbInt.params.wProt !== 0) { %>
  .<%=obj.DveInfo[obj.Id].interfaces.apbInt.name%>pprot                         (m_apb_if.pprot),
<% } %>
<%  if(obj.DveInfo[obj.Id].interfaces.apbInt.params.wStrb !== 0) { %>
  .<%=obj.DveInfo[obj.Id].interfaces.apbInt.name%>pstrb                         (m_apb_if.pstrb),
<% } %>

   //SMI TX ports
<% for (var i = 0; i < obj.nSmiTx; i++) { %>
    .<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_valid       (m_smi<%=i%>_rx_vif.smi_msg_valid),
    .<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_ready       (m_smi<%=i%>_rx_vif.smi_msg_ready),
    .<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_ndp_len	     (m_smi<%=i%>_rx_vif.smi_ndp_len),
    .<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_dp_present      (m_smi<%=i%>_rx_vif.smi_dp_present),
    .<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_targ_id	     (m_smi<%=i%>_rx_vif.smi_targ_id),
    .<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_src_id          (m_smi<%=i%>_rx_vif.smi_src_id),
    .<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_id          (m_smi<%=i%>_rx_vif.smi_msg_id),
    .<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_type	     (m_smi<%=i%>_rx_vif.smi_msg_type),
<% if(obj.DveInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiUser >0) {%>
    .<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_user	     (m_smi<%=i%>_rx_vif.smi_msg_user[<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiUser-1%>:0]), 
<% } %>
<% if(obj.DveInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiTier >0) {%>
    .<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_tier	     (m_smi<%=i%>_rx_vif.smi_msg_tier[<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiTier-1%>:0]),  
<% } %>
<% if(obj.DveInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiSteer >0) {%>
    .<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_steer	         (m_smi<%=i%>_rx_vif.smi_steer[<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiSteer-1%>:0]),  
<% } %>
<% if(obj.DveInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiPri >0) {%>
    .<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_pri	     (m_smi<%=i%>_rx_vif.smi_msg_pri[<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiPri-1%>:0]),  
<% } %>
<% if(obj.DveInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiMsgQos >0) {%>
    .<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_qos	     (m_smi<%=i%>_rx_vif.smi_msg_qos[<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiMsgQos-1%>:0]), 
<% } %>
    .<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_ndp         (m_smi<%=i%>_rx_vif.smi_ndp[<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiNDP-1%>:0]	),
<% if(obj.DveInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiErr >0) {%>
    .<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_err	     (m_smi<%=i%>_rx_vif.smi_msg_err[<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiErr-1%>:0]),
<% } %>
<%  if (obj.DveInfo[obj.Id].interfaces.smiTxInt[i].params.nSmiDPvc) { %>    
        .<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>dp_valid       (m_smi<%=i%>_rx_vif.smi_dp_valid),
        .<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>dp_ready       (m_smi<%=i%>_rx_vif.smi_dp_ready),
        .<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>dp_last        (m_smi<%=i%>_rx_vif.smi_dp_last),
        .<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>dp_data        (m_smi<%=i%>_rx_vif.smi_dp_data[<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiDPdata-1%>:0]),
<% if(obj.DveInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiDPuser >0) {%>
        .<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>dp_user	    (m_smi<%=i%>_rx_vif.smi_dp_user[<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiDPuser-1%>:0]),
<% } %>
<% } %> 
<% } %>

    //SMI RX ports
<% for (var i = 0; i < obj.nSmiRx; i++) { %>
    .<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_valid	    (m_smi<%=i%>_tx_vif.smi_msg_valid),
    .<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_ready	    (m_smi<%=i%>_tx_vif.smi_msg_ready),
    .<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_ndp_len	    (m_smi<%=i%>_tx_vif.smi_ndp_len),
    .<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_dp_present     (m_smi<%=i%>_tx_vif.smi_dp_present),
    .<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_targ_id	    (m_smi<%=i%>_tx_vif.smi_targ_id),
    .<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_src_id         (m_smi<%=i%>_tx_vif.smi_src_id),
    .<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_id         (m_smi<%=i%>_tx_vif.smi_msg_id),
    .<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_type	    (m_smi<%=i%>_tx_vif.smi_msg_type),
<% if(obj.DveInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiUser >0) {%>
    .<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_user	    (m_smi<%=i%>_tx_vif.smi_msg_user[<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiUser-1%>:0]), 
<% } %>
<% if(obj.DveInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiTier >0) {%>
    .<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_tier	    (m_smi<%=i%>_tx_vif.smi_msg_tier[<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiTier-1%>:0]),  
<% } %>
<% if(obj.DveInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiSteer >0) {%>
    .<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_steer	        (m_smi<%=i%>_tx_vif.smi_steer[<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiSteer-1%>:0]),  
<% } %>
<% if(obj.DveInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiPri >0) {%>
    .<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_pri	    (m_smi<%=i%>_tx_vif.smi_msg_pri[<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiPri-1%>:0]),  
<% } %>
<% if(obj.DveInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiMsgQos >0) {%>
    .<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_qos	    (m_smi<%=i%>_tx_vif.smi_msg_qos[<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiMsgQos-1%>:0]), 
<% } %>
    .<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_ndp	        (m_smi<%=i%>_tx_vif.smi_ndp[<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiNDP-1%>:0]	), 
<% if(obj.DveInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiErr >0) {%>
    .<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_err	    (m_smi<%=i%>_tx_vif.smi_msg_err[<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiErr-1%>:0]),
<% } %>

    <%  if (obj.DveInfo[obj.Id].interfaces.smiRxInt[i].params.nSmiDPvc) { %>    
    .<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>dp_valid                 (m_smi<%=i%>_tx_vif.smi_dp_valid),
    .<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>dp_ready                 (m_smi<%=i%>_tx_vif.smi_dp_ready),
    .<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>dp_last                  (m_smi<%=i%>_tx_vif.smi_dp_last),
    .<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>dp_data                  (m_smi<%=i%>_tx_vif.smi_dp_data[<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiDPdata-1%>:0]),
<% if(obj.DveInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiDPuser >0) {%>
    .<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>dp_user	              (m_smi<%=i%>_tx_vif.smi_dp_user[<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiDPuser-1%>:0]),
<% } %>
<% } %> 
<% } %>

 
    
<% if(obj.useResiliency) { %>
    //TODO resiliency if ******************************************
<% if(obj.DveInfo[obj.Id].ResilienceInfo.enableUnitDuplication) { %>
    .<%=obj.interfaces.checkClkInt.name%>clk      (dut_clk),
    .<%=obj.interfaces.checkClkInt.name%>test_en  (1'b0),
//    .<%=obj.interfaces.checkClkInt.name%>reset_n (soft_rstn),
<% } %>
    // .clk_check(fr_clk),
     .bist_bist_next(1'b0),
     .bist_bist_next_ack(bist_bist_next_ack),
     .bist_domain_is_on(bist_domain_is_on),
     .fault_mission_fault(fault_mission_fault),
     .fault_latent_fault(fault_latent_fault),
     .fault_cerr_over_thres_fault(fault_cerr_over_thres_fault),
<% } %>

//Q-channel interface connection
<% if (obj.DveInfo[obj.Id].usePma) { %>
  .<%=obj.DveInfo[obj.Id].interfaces.qInt.name%>ACTIVE                ( m_q_chnl_if.QACTIVE ) ,
  .<%=obj.DveInfo[obj.Id].interfaces.qInt.name%>DENY                  ( m_q_chnl_if.QDENY   ) ,
  .<%=obj.DveInfo[obj.Id].interfaces.qInt.name%>REQn                  ( m_q_chnl_if.QREQn   ) ,
  .<%=obj.DveInfo[obj.Id].interfaces.qInt.name%>ACCEPTn               ( m_q_chnl_if.QACCEPTn) ,
<% } %>
  //.fault_late_clk               (dut_clk),     //TODO : need to delay?     
  .<%=obj.DveInfo[obj.Id].interfaces.irqInt.name%>uc(dve_irq_uc)

  //.smi_rx2_dp_valid(m_smi2_tx_vif.smi_dp_valid),
  //.smi_rx2_dp_ready(m_smi2_tx_vif.smi_dp_ready),
  //.smi_rx2_dp_last(m_smi2_tx_vif.smi_dp_last),
  //.smi_rx2_dp_data(m_smi2_tx_vif.smi_dp_data),
  //.smi_rx2_dp_user(m_smi2_tx_vif.smi_dp_user)
); // dve dut

<% for (var i = 0; i < obj.nSmiTx; i++) { %>
<% if(obj.DveInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiErr == 0) {%>
//assign m_smi<%=i%>_rx_vif.smi_msg_err = 1'b0;
initial begin $assertoff(0, m_smi<%=i%>_rx_vif.assert_smi_msg_err_not_x_z); end
<% } %>
<% } %>
////perf counter :stall_if to dut connection 
assign <%=obj.BlockId%>_sb_stall_if.clk = dut_clk;
assign <%=obj.BlockId%>_sb_stall_if.rst_n = soft_rstn;
assign <%=obj.BlockId%>_sb_stall_if.master_cnt_enable = dut.trigger_trigger;
// SMI TX
<%for (var i = 0; i < obj.nSmiTx; i++) { %>
<%  if (obj.DveInfo[obj.Id].interfaces.smiTxInt[i].params.nSmiDPvc) { %>  
assign <%=obj.BlockId%>_sb_stall_if.smi_tx<%=i%>_valid = dut.<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>dp_valid;       
assign <%=obj.BlockId%>_sb_stall_if.smi_tx<%=i%>_ready = dut.<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>dp_ready;     
<% } else { %>
assign <%=obj.BlockId%>_sb_stall_if.smi_tx<%=i%>_valid = dut.<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_valid;       
assign <%=obj.BlockId%>_sb_stall_if.smi_tx<%=i%>_ready = dut.<%=obj.DveInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_ready;     
<% } %> 
<% } %>
// SMI RX
<%for (var i = 0; i < obj.nSmiRx; i++) { %>
  <%  if (obj.DveInfo[obj.Id].interfaces.smiRxInt[i].params.nSmiDPvc) { %>  
assign <%=obj.BlockId%>_sb_stall_if.smi_rx<%=i%>_valid = dut.<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>dp_valid;
assign <%=obj.BlockId%>_sb_stall_if.smi_rx<%=i%>_ready = dut.<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>dp_ready;
<% } else { %>
assign <%=obj.BlockId%>_sb_stall_if.smi_rx<%=i%>_valid = dut.<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_valid;
assign <%=obj.BlockId%>_sb_stall_if.smi_rx<%=i%>_ready = dut.<%=obj.DveInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_ready;
<% } %> 
<% } %>
<%for (var i = 0; i < nPerfCounters; i++) { %>
assign <%=obj.BlockId%>_sb_stall_if.cnt_reg_capture[<%=i%>].cnt_v =  dut.unit.u_csr.u_apb_csr.DVECNTVR<%=i%>_CountVal_out ;  
assign <%=obj.BlockId%>_sb_stall_if.cnt_reg_capture[<%=i%>].cnt_v_str =  dut.unit.u_csr.u_apb_csr.DVECNTSR<%=i%>_CountSatVal_out;
<% } %>

//CONC-12835 : tie-off signals of RX0 interface other than valid and ready to avoid propagating X to RTL. Same fix in DMI in CONC-12693
initial 
begin
  if ($test$plusargs("force_smi_0_rx")) begin
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[0].name%>ndp_ndp_len     = 0;
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[0].name%>ndp_dp_present  = 0;
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[0].name%>ndp_targ_id     = 0;    
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[0].name%>ndp_src_id      = 0;     
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[0].name%>ndp_msg_id      = 0;     
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[0].name%>ndp_msg_type    = 0;       
    <% if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[0].params.wSmiUser >0) {%>      
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[0].name%>ndp_msg_user    = 0;
    <% } %>    
    <% if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[0].params.wSmiTier >0) {%>
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[0].name%>ndp_msg_tier    = 0;          
    <% } %>
    <% if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[0].params.wSmiSteer >0) {%>
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[0].name%>ndp_steer       = 0;      
    <% } %>
    <% if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[0].params.wSmiPri >0) {%>
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[0].name%>ndp_msg_pri     = 0;      
    <% } %>
    <% if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[0].params.wSmiMsgQos >0) {%>
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[0].name%>ndp_msg_qos     = 0;  
    <% } %>
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[0].name%>ndp_ndp         = 0; 
    <% if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[0].params.wSmiErr >0) {%>
    force tb_top.dut.<%=obj.DmiInfo[obj.Id].interfaces.smiRxInt[0].name%>ndp_msg_err     = 0;      
    <% } %>
    $assertoff(0,m_smi0_tx_vif);
  end
  if ($test$plusargs("force_smi_1_rx")) begin
    $assertoff(0,m_smi1_tx_vif);
  end
  if ($test$plusargs("force_smi_2_rx")) begin
    $assertoff(0,m_smi2_tx_vif);
  end
end

// interface to tap internal csr signal
dve_csr_probe_if u_csr_probe_if(.clk(dut_clk),.resetn(soft_rstn));

       assign u_csr_probe_if.IRQ_C     = tb_top.dut.<%=obj.DveInfo[obj.Id].interfaces.irqInt.name%>c;
       //assign u_csr_probe_if.IRQ_C     = 0;
       assign u_csr_probe_if.IRQ_UC    = tb_top.dut.<%=obj.DveInfo[obj.Id].interfaces.irqInt.name%>uc;
<% if(obj.useResiliency) { %>
       assign u_csr_probe_if.fault_mission_fault = tb_top.dut.fault_mission_fault;
       assign u_csr_probe_if.fault_latent_fault  = tb_top.dut.fault_latent_fault;
       assign u_csr_probe_if.cerr_threshold          = tb_top.dut.u_fault_checker.cerr_threshold;
       assign u_csr_probe_if.cerr_counter            = tb_top.dut.u_fault_checker.cerr_counter;
       assign u_csr_probe_if.cerr_over_thres_fault   = tb_top.dut.u_fault_checker.cerr_over_thres_fault;
<% } %>

initial begin

    uvm_config_db#(virtual dve_csr_probe_if)::set(.cntxt( uvm_root::get() ),
                                        .inst_name( "" ),
                                        .field_name( "u_csr_probe_if" ),
                                        .value( u_csr_probe_if ));

    uvm_config_db#(virtual <%=obj.BlockId%>_apb_if )::set(.cntxt( uvm_root::get()),
                                        .inst_name( "" ),
                                        .field_name( "m_apb_if" ),
                                        .value(m_apb_if ));
    uvm_config_db#(virtual <%=obj.BlockId%>_q_chnl_if )::set(.cntxt( uvm_root::get()),
                                        .inst_name( "" ),
                                        .field_name( "m_q_chnl_if" ),
                                        .value(m_q_chnl_if ));
   uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::set(null, "", "<%=obj.BlockId%>_m_top_stall_if",       <%=obj.BlockId%>_sb_stall_if); 
    uvm_config_db#(virtual <%=obj.BlockId%>_clock_counter_if )::set(.cntxt( uvm_root::get()),
                                        .inst_name( "" ),
                                        .field_name( "m_clock_counter_if" ),
                                        .value(m_clock_counter_if ));

end

initial begin
  int ts;
  // in some cases, use a non-standard reset value for the timestamp
  // #Stimulus.DVE.v3.2.TSRollover
  if($value$plusargs("dve_initial_timestamp=%0d", ts)) begin
    force tb_top.dut.unit.u_protman.u_dve_trace_accumulator.frc_dffre.q = ts;
    `uvm_info("dve_tb_top unit", $psprintf("Forced frc=0x%0h", ts), UVM_NONE)
    @ (posedge tb_top.dut.unit.u_protman.u_dve_trace_accumulator.frc_dffre.reset_n);
    release tb_top.dut.unit.u_protman.u_dve_trace_accumulator.frc_dffre.q;
  end
end

<% if(obj.DveInfo[0].useResiliency == 1) {
    if(obj.DveInfo[0].ResilienceInfo.enableUnitDuplication == 1) { %>
initial begin
  int ts1;
  // in some cases, use a non-standard reset value for the timestamp
  // #Stimulus.DVE.v3.2.TSRollover
  if($value$plusargs("dve_initial_timestamp=%0d", ts1)) begin
    force tb_top.dut.dup_unit.u_protman.u_dve_trace_accumulator.frc_dffre.q = ts1;
    `uvm_info("dve_tb_top dup_unit", $psprintf("Forced frc=0x%0h", ts1), UVM_NONE)
    @ (posedge tb_top.dut.dup_unit.u_protman.u_dve_trace_accumulator.frc_dffre.reset_n);
    release tb_top.dut.dup_unit.u_protman.u_dve_trace_accumulator.frc_dffre.q;
  end
end
<% } } %>

// Reset
initial begin
  tb_rstn <= 0;
  #1ns;
  tb_rstn <= 0;
  repeat(20) @(posedge tb_clk); #1ns;
  tb_rstn <= 1;
end

// Clock
initial begin
  tb_clk = 0;
  forever #5ns tb_clk = ~tb_clk;
end

// Call run_test
initial begin
  $timeformat(-9, 0, "ns", 0);

  `ifdef DUMP_ON
    if($test$plusargs("en_dump"))
      $vcdpluson;
  `endif // DUMP_ON

  run_test();
  $finish;
end

<% if(obj.useResiliency) { %>
 fault_injector_checker fault_inj_check(dut_clk, soft_rstn);
 initial begin
<% if(obj.testBench == 'dve') { %>
`ifndef VCS
    uvm_config_db#(event)::set(.cntxt(null),
                               .inst_name( "*" ),
                               .field_name( "kill_test" ),
                               .value(fault_inj_check.kill_test));

    uvm_config_db#(event)::set(.cntxt(null),
                               .inst_name( "*" ),
                               .field_name( "raise_obj_for_resiliency_test" ),
                               .value(fault_inj_check.raise_obj_for_resiliency_test));

    uvm_config_db#(event)::set(.cntxt(null),
                               .inst_name( "*" ),
                               .field_name( "drop_obj_for_resiliency_test" ),
                               .value(fault_inj_check.drop_obj_for_resiliency_test));
`else // `ifndef VCS
    fault_inj_check.kill_test = new("kill_test");
    fault_inj_check.raise_obj_for_resiliency_test = new("raise_obj_for_resiliency_test");
    fault_inj_check.drop_obj_for_resiliency_test = new("drop_obj_for_resiliency_test");

    uvm_config_db#(uvm_event)::set(.cntxt(null),
                               .inst_name( "*" ),
                               .field_name( "kill_test" ),
                               .value(fault_inj_check.kill_test));

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
                               .value(fault_inj_check.kill_test));

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

initial begin: trace_mem_error
  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event inject_single = ev_pool.get("dve_trace_mem_inject_single_error");
  uvm_event inject_double = ev_pool.get("dve_trace_mem_inject_double_error");
  uvm_event inject_addr = ev_pool.get("dve_trace_mem_inject_addr_error");
  uvm_event saw_single = ev_pool.get("dve_trace_mem_rtl_saw_single_error");
  uvm_event saw_double = ev_pool.get("dve_trace_mem_rtl_saw_double_error");
  fork
    forever begin
      inject_single.wait_trigger();
      inject_tacc_single_error($urandom() % 2);
      inject_single.reset();
    end
    forever begin
      inject_double.wait_trigger();
      inject_tacc_double_error($urandom() % 2);
      inject_double.reset();
    end
    forever begin
      inject_addr.wait_trigger();
      inject_tacc_addr_error($urandom() % 2);
      inject_addr.reset();
    end
    // watch RTL for single data errors
    forever begin
      @(posedge tb_top.dut.unit.u_protman.u_dve_trace_accumulator.dve_trace_data_ecc_sb_error, posedge tb_top.dut.unit.u_protman.u_dve_trace_accumulator.dve_trace_hdr_ecc_sb_error);
      saw_single.trigger();
    end
    // watch RTL for double data errors
    forever begin
      @(posedge tb_top.dut.unit.u_protman.u_dve_trace_accumulator.dve_trace_data_ecc_db_error, posedge tb_top.dut.unit.u_protman.u_dve_trace_accumulator.dve_trace_hdr_ecc_db_error);
      saw_double.trigger();
    end
  join_none
end: trace_mem_error

task inject_tacc_single_error(int mem = 0);
<% // External trace memories don't have error injection functions?
   // or is it internal?
  //console.log(obj.DveInfo[0].MemoryGeneration.traceMem);
  if(obj.DveInfo[0].assertOn == 1) {
     for(var i = 0; i < obj.DveInfo[0].MemoryGeneration.traceMem.length; i++) {
        var name = obj.DveInfo[0].MemoryGeneration.traceMem[i].rtlPrefixString;
        var type = obj.DveInfo[0].MemoryGeneration.traceMem[i].MemType; %>
  if(mem == <%=i%>) begin
<% if(type == "NONE") { %>
    tb_top.dut.<%=name%>.internal_mem_inst.inject_single_error();
    `uvm_info("dve_tb_top", "Injected single error on memory <%=name%>(<%=type%>)", UVM_NONE)
<% } else if (type == "SYNOPSYS") { %>
    tb_top.dut.<%=name%>.external_mem_inst.internal_mem_inst.inject_single_error();
    `uvm_info("dve_tb_top", "Injected single error on memory <%=name%>(<%=type%>)", UVM_NONE)
<% } else { %>
  // <%=i%> not building error injection for memory <%=name%> with type <%=type%>
    `uvm_warning("dve_tb_top", "Attempted to inject error on <%=name%>, which does not support error injection")
<% } %>
  end
<% } } %>
endtask:inject_tacc_single_error

task inject_tacc_double_error(int mem = 0);
<% // External trace memories don't have error injection functions?
   // or is it internal?
  //console.log(obj.DveInfo[0].MemoryGeneration.traceMem);
  if(obj.DveInfo[0].assertOn == 1) {
     for(var i = 0; i < obj.DveInfo[0].MemoryGeneration.traceMem.length; i++) {
        var name = obj.DveInfo[0].MemoryGeneration.traceMem[i].rtlPrefixString;
        var type = obj.DveInfo[0].MemoryGeneration.traceMem[i].MemType; %>
  if(mem == <%=i%>) begin
<% if(type == "NONE") { %>
    tb_top.dut.<%=name%>.internal_mem_inst.inject_double_error();
    `uvm_info("dve_tb_top", "Injected double error on memory <%=name%>(<%=type%>)", UVM_NONE)
<% } else if (type == "SYNOPSYS") { %>
    tb_top.dut.<%=name%>.external_mem_inst.internal_mem_inst.inject_double_error();
    `uvm_info("dve_tb_top", "Injected double error on memory <%=name%>(<%=type%>)", UVM_NONE)
<% } else { %>
  // <%=i%> not building error injection for memory <%=name%> with type <%=type%>
    `uvm_warning("dve_tb_top", "Attempted to inject error on <%=name%>, which does not support error injection")
<% } %>
  end
<% } } %>
endtask:inject_tacc_double_error

task inject_tacc_addr_error(int mem = 0);
<% // External trace memories don't have error injection functions?
   // or is it internal?
  //console.log(obj.DveInfo[0].MemoryGeneration.traceMem);
  if(obj.DveInfo[0].assertOn == 1) {
     for(var i = 0; i < obj.DveInfo[0].MemoryGeneration.traceMem.length; i++) {
        var name = obj.DveInfo[0].MemoryGeneration.traceMem[i].rtlPrefixString;
        var type = obj.DveInfo[0].MemoryGeneration.traceMem[i].MemType; %>
  if(mem == <%=i%>) begin
<% if(type == "NONE") { %>
    tb_top.dut.<%=name%>.internal_mem_inst.inject_addr_error();
    `uvm_info("dve_tb_top", "Injected addr error on memory <%=name%>(<%=type%>)", UVM_NONE)
<% } else if (type == "SYNOPSYS") { %>
    tb_top.dut.<%=name%>.external_mem_inst.internal_mem_inst.inject_addr_error();
    `uvm_info("dve_tb_top", "Injected addr error on memory <%=name%>(<%=type%>)", UVM_NONE)
<% } else { %>
  // <%=i%> not building error injection for memory <%=name%> with type <%=type%>
    `uvm_warning("dve_tb_top", "Attempted to inject error on <%=name%>, which does not support error injection")
<% } %>
  end
<% } } %>
endtask:inject_tacc_addr_error

initial begin: drop_capture_count
  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event rtl_captured = ev_pool.get("dve_trace_captured");
  uvm_event rtl_dropped = ev_pool.get("dve_trace_dropped");
  fork
    // watch RTL for capture events
    forever begin
      @(posedge tb_top.dut.unit.u_protman.u_dve_trace_accumulator.dve_trace_packets_accepted)
      rtl_captured.trigger();
    end
    // watch RTL for drop events
    forever begin
      @(posedge tb_top.dut.unit.u_protman.u_dve_trace_accumulator.dve_trace_packets_dropped)
      rtl_dropped.trigger();
    end
  join_none
end: drop_capture_count

initial begin: set_initial_timestamp
end: set_initial_timestamp

//Calls UVM end of simulation/pending transactions methods 
task assert_error(input string verbose, input string msg);
  uvm_component  m_comp[$];
  //dce0_scoreboard m_scb;

  //uvm_top.find_all("uvm_test_top.m_env.m_dirm_scb", m_comp, uvm_top); 
  //if (m_comp.size() == 0) 
  //  `uvm_fatal("tb_top", "None of the components are found with specified name");
  //if (m_comp.size() > 1) begin
  //  foreach(m_comp[i]) 
  //    `uvm_info("tb_top", $psprintf("component: %s", m_comp[i].get_full_name()), UVM_LOW);
  //  `uvm_fatal("tb_top", "Multiple components with same name are found, Components are specified above");
  //end

  //if($cast(m_scb, m_comp[0])) begin
  //  if (m_scb.m_csm.transactionPending()) 
  //    m_scb.m_csm.printPendingTransactions(); 
  //end else 
  //  `uvm_fatal("tb_top", "Unable to cast, maybe the
  //      hierarchical reference to Tb specific scoreboard is changed");

  if(verbose == "FATAL") begin
    `uvm_fatal("ASSERT_ERROR", msg); 
  end else begin
    `uvm_error("ASSERT_ERROR", msg); 
  end
endtask: assert_error

//Checking clock idle when qREQn and qACCEPTn are low (entered into pma)
<% if (obj.DveInfo[obj.Id].usePma) { %>
assert_clk_idle_when_pma_asserted : assert property (
    @(posedge tb_clk) disable iff (!soft_rstn)
    (!m_q_chnl_if.QREQn && !m_q_chnl_if.QACCEPTn ) |-> !dut_clk
    ) else assert_error("ERROR", "Dut clock is not stable low when RTL entered into PMA");
<% } %>

endmodule
