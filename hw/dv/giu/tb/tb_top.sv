//--------------------------------------------------------------------------------------
// Copyright(C) 2014-2025 Arteris, Inc. and its applicable subsidiaries.
// All rights reserved.
//
// Disclaimer: This release is not provided nor intended for any chip implementations, 
//             tapeouts, or other features of production releases. 
//
// These files and associated documentation is proprietary and confidential to
// Arteris, Inc. and its applicable subsidiaries. The files and documentation
// may only be used pursuant to the terms and conditions of a signed written
// license agreement with Arteris, Inc. or one of its subsidiaries.
// All other use, reproduction, modification, or distribution of the information
// contained in the files or the associated documentation is strictly prohibited.
// This product and its technology is protected by patents and other forms of 
// intellectual property protection.
//
// License: Arteris Confidential
<%// Project: GIU
// Product: Ncore 3.8
// Author: esherk
// %> 
//--------------------------------------------------------------------------------------
 
<% if(obj.system.ResilienceEnable) { %>
`include "fault_injector_checker.sv"
<% } %>

`define TT_DEBUG // EDS temp to turn off smi assertions

module tb_top();

    `ifndef UVMPKG
    import uvm_pkg::*;
    `endif
    `include "uvm_macros.svh"
    import <%=obj.BlockId%>_smi_agent_pkg::*;

    import <%=obj.BlockId%>_test_lib_pkg::*;

    // local js values to set values
    localparam nCAius = <%=obj.DutInfo.system.nCAius%>; // TODO: temporary, port will be removed
    localparam wSysVec = <%=obj.interfaces.uIdInt[0].params.wFUnitId%>; // TODO: temporary, port will be removed
    localparam nDces = <%=obj.DutInfo.system.nDces%>;
    localparam wDceVec = <%=obj.interfaces.uSysDceIdInt.params.wFUnitIdV.reduce((sum, value) => sum + value, 0)%>;
    localparam nDiis = <%=obj.DutInfo.system.nDiis%>;
    localparam wDiiVec = <%=obj.interfaces.uSysDiiIdInt.params.wFUnitIdV.reduce((sum, value) => sum + value, 0)%>;
    localparam nDmis = <%=obj.DutInfo.system.nDmis%>;
    localparam wDmiVec = <%=obj.interfaces.uSysDmiIdInt.params.wFUnitIdV.reduce((sum, value) => sum + value, 0)%>;
    localparam nDves = <%=obj.DutInfo.system.nDves%>;
    localparam wDveVec = <%=obj.interfaces.uSysDveIdInt.params.wFUnitIdV.reduce((sum, value) => sum + value, 0)%>;

    // TB clk and rst
    bit dut_clk;
    bit tb_clk;
    bit tb_rstn;
    logic soft_rstn;

    // currently unused ports
    logic giu_irq_c;
    logic giu_irq_uc;
    // connectivity definitions with inital values, override later if appropriate
    logic [nCAius-1:0] sys_connectivity = {nCAius{1'b0}}; // TODO: temporary, port will be removed
    logic [wSysVec-1:0] sys_f_unit_id = {wSysVec{1'b0}}; // TODO: temporary, port will be removed
    logic [nDces-1:0] sys_dce_connectivity = (nDces > 0) ? {nDces{1'b1}} : {nDces{1'b0}};
    logic [wDceVec-1:0] sys_dce_f_unit_id = {wDceVec{1'b0}};
    logic [nDiis-1:0] sys_dii_connectivity = (nDiis > 0) ? {nDiis{1'b1}} : {nDiis{1'b0}};
    logic [wDiiVec-1:0] sys_dii_f_unit_id = {wDiiVec{1'b0}};
    logic [nDmis-1:0] sys_dmi_connectivity = (nDmis > 0) ? {nDmis{1'b1}} : {nDmis{1'b0}};
    logic [wDmiVec-1:0] sys_dmi_f_unit_id = {wDmiVec{1'b0}};
    logic [nDves-1:0] sys_dve_connectivity = (nDves > 0) ? {nDves{1'b1}} : {nDves{1'b0}};
    logic [wDveVec-1:0] sys_dve_f_unit_id = {wDveVec{1'b0}};
    logic [<%=obj.interfaces.uChipletIdInt.params.wChipletId-1%>:0] my_chiplet_id = <%=obj.interfaces.uChipletIdInt.params.wChipletId%>'d0;
    logic [<%=obj.interfaces.uChipletIdInt.params.wAssemblyId-1%>:0] my_assembly_id = <%=obj.interfaces.uChipletIdInt.params.wAssemblyId%>'d0;
    // wrap CXS
    logic <%if(obj.interfaces.cxsTxInt.params.wValid>1){%>[<%=obj.interfaces.cxsTxInt.params.wValid-1%>:0]<%}%> cxs_wrap_valid;
    logic <%if(obj.interfaces.cxsTxInt.params.wData>1){%>[<%=obj.interfaces.cxsTxInt.params.wData-1%>:0]<%}%> cxs_wrap_data;
    logic <%if(obj.interfaces.cxsTxInt.params.wCntl>1){%>[<%=obj.interfaces.cxsTxInt.params.wCntl-1%>:0]<%}%> cxs_wrap_cntl;
    logic <%if(obj.interfaces.cxsTxInt.params.wLast>1){%>[<%=obj.interfaces.cxsTxInt.params.wLast-1%>:0]<%}%> cxs_wrap_last;
    logic <%if(obj.interfaces.cxsTxInt.params.wPrcltype>1){%>[<%=obj.interfaces.cxsTxInt.params.wPrcltype-1%>:0]<%}%> cxs_wrap_prcltype;
    logic <%if(obj.interfaces.cxsTxInt.params.wCrdrtn>1){%>[<%=obj.interfaces.cxsTxInt.params.wCrdrtn-1%>:0]<%}%> cxs_wrap_crdrtn;
    logic <%if(obj.interfaces.cxsTxInt.params.wCrdGnt>1){%>[<%=obj.interfaces.cxsTxInt.params.wCrdGnt-1%>:0]<%}%> cxs_wrap_crdgnt;
    logic <%if(obj.interfaces.cxsTxInt.params.wActivereq>1){%>[<%=obj.interfaces.cxsTxInt.params.wActivereq-1%>:0]<%}%> cxs_wrap_activereq;
    logic <%if(obj.interfaces.cxsTxInt.params.wActiveack>1){%>[<%=obj.interfaces.cxsTxInt.params.wActiveack-1%>:0]<%}%> cxs_wrap_activeack;
    logic <%if(obj.interfaces.cxsTxInt.params.wDeacthint>1){%>[<%=obj.interfaces.cxsTxInt.params.wDeacthint-1%>:0]<%}%> cxs_wrap_deacthint;

    <% if(obj.system.ResilienceEnable) { %>
    logic[1023:0] slv_req_corruption_vector = 1024'b0;
    logic[1023:0] slv_data_corruption_vector = 1024'b0;
    logic[WSMIADDR-1:0] smi_req_addr_modified;
    logic[<%=obj.DutInfo.wData%>-1:0] smi_req_data_modified;  //TODO checkme: flat view of txn payload data for error injection

    logic bist_bist_next_ack;
    logic bist_domain_is_on;
    logic fault_mission_fault;
    logic fault_latent_fault;
    logic fault_cerr_over_thres_fault;
    <% } %>

    // SMI interfaces from TB perspective
    // SMI 0 non data [request]  | TX | CmdReq, StrReq, UpdReq, SysReq
    // SMI 0 non data [request]  | RX | CmdReq, StrReq, UpdReq, SysReq
    // SMI 1 non data [response] | TX | StrRsp,CmdRsp, UpdRsp, SysRsp
    // SMI 1 non data [response] | RX | StrRsp,CmdRsp, UpdRsp, SysRsp
    // SMI 2 non data [response] | TX | DtwRsp, DtrRsp
    // SMI 2 non data [response] | RX | DtwRsp, DtrRsp
    // SMI 3 data [request]      | TX | DtwReq, DtrReq
    // SMI 3 data [request]      | RX | DtwReq, DtrReq

    //SMI Interface
    <% for (var i = 0; i < obj.nSmiRx; i++) { %>
    <%=obj.BlockId%>_smi_if m_smi<%=i%>_tx_vif(dut_clk,soft_rstn,"m_smi<%=i%>_tx");
    <% } %>

    <% for (var i = 0; i < obj.interfaces.smiTxInt.length; i++) { %>
    <%=obj.BlockId%>_smi_if m_smi<%=i%>_rx_vif(dut_clk,soft_rstn,"m_smi<%=i%>_rx");
    <% } %>

    <%=obj.BlockId%>_apb_if     m_apb_if(dut_clk, soft_rstn);

    //Q-channel interface
    <%=obj.BlockId%>_q_chnl_if  m_q_chnl_if(tb_clk, tb_rstn);

    // <%=obj.BlockId%>_stall_if <%=obj.BlockId%>_sb_stall_if();

    <%=obj.BlockId%>_clock_counter_if m_clock_counter_if(tb_clk, tb_rstn);
    // assign m_clock_counter_if.probe_sig1 = dut.unit.u_protman.csr_DvmSnoopDisable_ff;
    
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

    //SmiRx Ports from TB prespective
    <% for (var i = 0; i < obj.nSmiTx; i++) { %>
    uvm_config_db #(virtual <%=obj.BlockId%>_smi_if)::set(
        .cntxt(null),
        .inst_name("uvm_test_top"),
        .field_name("m_smi<%=i%>_rx_vif"),
        .value(m_smi<%=i%>_rx_vif)
    );
    <% } %>
    end

    // assign actual connectivity
    initial begin 
        <%var conlen = obj.interfaces.uSysDceIdInt.params.wFUnitIdV.length;%>
        <%for (var i=0; i<conlen; i++) { var wThis = obj.interfaces.uSysDceIdInt.params.wFUnitIdV[i];%>
        sys_dce_f_unit_id = sys_dce_f_unit_id | (<%=wThis%>'d<%=obj.DutInfo.system.DCEFUnitIdV[i]%>)<<(<%=wThis%>*<%=i%>);<%;%>
        <%}%>
        <%var conlen = obj.interfaces.uSysDiiIdInt.params.wFUnitIdV.length;%>
        <%for (var i=0; i<conlen; i++) { var wThis = obj.interfaces.uSysDiiIdInt.params.wFUnitIdV[i]; %>
        sys_dii_f_unit_id = sys_dii_f_unit_id | (<%=wThis%>'d<%=obj.DutInfo.system.DIIFUnitIdV[i]%>)<<(<%=wThis%>*<%=i%>);<%;%>
        <%}%>
        <%var conlen = obj.interfaces.uSysDceIdInt.params.wFUnitIdV.length;%>
        <%for (var i=0; i<conlen; i++) { var wThis = obj.interfaces.uSysDmiIdInt.params.wFUnitIdV[i]%>
        sys_dmi_f_unit_id = sys_dmi_f_unit_id | (<%=wThis%>'d<%=obj.DutInfo.system.DMIFUnitIdV[i]%>)<<(<%=wThis%>*<%=i%>);<%;%>
        <%}%>
        <%var conlen = obj.interfaces.uSysDveIdInt.params.wFUnitIdV.length;%>
        <%for (var i=0; i<conlen; i++) { var wThis = obj.interfaces.uSysDveIdInt.params.wFUnitIdV[i];%>
        sys_dve_f_unit_id = sys_dve_f_unit_id | (<%=wThis%>'d<%=obj.DutInfo.system.DVEFUnitIdV[i]%>)<<(<%=wThis%>*<%=i%>);<%;%>
        <%}%>
        // randomize these at start of sim
        my_chiplet_id = $urandom_range(0, <%=obj.interfaces.uChipletIdInt.params.wChipletId+1%>);
        my_assembly_id = $urandom_range(0, 1);
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
    <% if (obj.DutInfo.usePma) { %>
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
    <%  if (obj.interfaces.smiRxInt[i].params.nSmiDPvc) { %> 
    assign (supply0, supply1) dut.<%=obj.interfaces.smiRxInt[i].name%>dp_valid = m_smi<%=i%>_tx_vif.force_smi_msg_valid;
    assign (supply0, supply1) dut.<%=obj.interfaces.smiRxInt[i].name%>dp_ready = m_smi<%=i%>_tx_vif.force_smi_msg_ready;
    <% } else { %>
    assign (supply0, supply1) dut.<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_valid = m_smi<%=i%>_tx_vif.force_smi_msg_valid;
    assign (supply0, supply1) dut.<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_ready = m_smi<%=i%>_tx_vif.force_smi_msg_ready;
    <% } %> 
    <% } %> 

    // DUT instantiation
    // chiplet1_giu_a dut (
    <%=obj.instanceMap[obj.DutInfo.strRtlNamePrefix]%> dut(   
        // clocks, resets, interrupts
        // FIXME: clock moved to bottom so we can ensure no comma at end
        // .<%=obj.interfaces.clkInt.name%>clk     (dut_clk),
        .<%=obj.interfaces.clkInt.name%>reset_n (soft_rstn),
        .<%=obj.interfaces.clkInt.name%>test_en (1'b0),
        .<%=obj.interfaces.irqInt.name%>c       (giu_irq_c),
        .<%=obj.interfaces.irqInt.name%>uc      (giu_irq_uc),
        // APB 
        .<%=obj.interfaces.apbInt.name%>paddr   (m_apb_if.paddr),
        .<%=obj.interfaces.apbInt.name%>psel    (m_apb_if.psel),
        .<%=obj.interfaces.apbInt.name%>penable (m_apb_if.penable),
        .<%=obj.interfaces.apbInt.name%>pwrite  (m_apb_if.pwrite),
    <%if(obj.interfaces.apbInt.params.wProt !== 0){%> .<%=obj.interfaces.apbInt.name%>pprot  (m_apb_if.pprot),<% } %>
        .<%=obj.interfaces.apbInt.name%>pwdata  (m_apb_if.pwdata),
    <%if(obj.interfaces.apbInt.params.wStrb !== 0){%> .<%=obj.interfaces.apbInt.name%>pstrb  (m_apb_if.pstrb),<% } %>
        .<%=obj.interfaces.apbInt.name%>pready  (m_apb_if.pready),
        .<%=obj.interfaces.apbInt.name%>prdata  (m_apb_if.prdata),
        .<%=obj.interfaces.apbInt.name%>pslverr (m_apb_if.pslverr),
        // end APB
        // start unit connectivity
        .uSysIdInt_dce_f_unit_id    (sys_dce_f_unit_id),
        .uSysIdInt_dce_connectivity (sys_dce_connectivity),
        .uSysIdInt_dve_f_unit_id    (sys_dve_f_unit_id),
        .uSysIdInt_dve_connectivity (sys_dve_connectivity),
        .uSysIdInt_dmi_f_unit_id    (sys_dmi_f_unit_id),
        .uSysIdInt_dmi_connectivity (sys_dmi_connectivity),
        .uSysIdInt_dii_f_unit_id    (sys_dii_f_unit_id),
        .uSysIdInt_dii_connectivity (sys_dii_connectivity),
        .uSysId_f_unit_id           (sys_f_unit_id),    // TODO: temporary, port will be removed
        .uSysId_connectivity        (sys_connectivity), // TODO: temporary, port will be removed
        // static input ports, randomize at beginning of sim
        .uchipletId_my_chiplet_id   (my_chiplet_id),
        .uchipletId_my_assembly_id  (my_assembly_id),
        // end unit connectivity
        // start CXS, wrap connections for now FIXME: change to VIP
        .cxs_giu_tx_valid           (cxs_wrap_valid),
        .cxs_giu_tx_data            (cxs_wrap_data),
        .cxs_giu_tx_cntl            (cxs_wrap_cntl),
        .cxs_giu_tx_last            (cxs_wrap_last),
        .cxs_giu_tx_prcltype        (cxs_wrap_prcltype),
        .cxs_giu_tx_crdrtn          (cxs_wrap_crdrtn),
        .cxs_giu_tx_crdgnt          (cxs_wrap_crdgnt),
        .cxs_giu_tx_activereq       (cxs_wrap_activereq),
        .cxs_giu_tx_activeack       (cxs_wrap_activeack),
        .cxs_giu_tx_deacthint       (cxs_wrap_deacthint),
        .cxs_giu_rx_valid           (cxs_wrap_valid),
        .cxs_giu_rx_data            (cxs_wrap_data),  
        .cxs_giu_rx_cntl            (cxs_wrap_cntl),
        .cxs_giu_rx_last            (cxs_wrap_last),
        .cxs_giu_rx_prcltype        (cxs_wrap_prcltype),
        .cxs_giu_rx_crdrtn          (cxs_wrap_crdrtn),
        .cxs_giu_rx_crdgnt          (cxs_wrap_crdgnt),
        .cxs_giu_rx_activereq       (cxs_wrap_activereq),
        .cxs_giu_rx_activeack       (cxs_wrap_activeack),
        .cxs_giu_rx_deacthint       (cxs_wrap_deacthint),
        // end CXS
        // unit ids
        .<%=obj.interfaces.uIdInt[0].name%>my_f_unit_id(<%=obj.interfaces.uIdInt[0].params.wFUnitId%>'d<%=obj.DutInfo.FUnitId%>),
        .<%=obj.interfaces.uIdInt[0].name%>my_n_unit_id(<%=obj.interfaces.uIdInt[0].params.wNUnitId%>'d<%=obj.DutInfo.nUnitId%>),
        .<%=obj.interfaces.uIdInt[0].name%>my_csr_rpn(<%=obj.interfaces.uIdInt[0].params.wRpn%>'d<%=obj.DutInfo.rpn%>),
        .<%=obj.interfaces.uIdInt[0].name%>my_csr_nrri(<%=obj.interfaces.uIdInt[0].params.wNrri%>'d<%=obj.DutInfo.nrri%>),

        //SMI TX ports
    <% for (var i = 0; i < obj.nSmiTx; i++) { %>
        .<%=obj.interfaces.smiTxInt[i].name%>ndp_targ_id	    (m_smi<%=i%>_rx_vif.smi_targ_id),
        .<%=obj.interfaces.smiTxInt[i].name%>ndp_src_id         (m_smi<%=i%>_rx_vif.smi_src_id),
        .<%=obj.interfaces.smiTxInt[i].name%>ndp_ndp_len	    (m_smi<%=i%>_rx_vif.smi_ndp_len),
        .<%=obj.interfaces.smiTxInt[i].name%>ndp_ndp            (m_smi<%=i%>_rx_vif.smi_ndp[<%=obj.interfaces.smiTxInt[i].params.wSmiNDP-1%>:0]	),
        .<%=obj.interfaces.smiTxInt[i].name%>ndp_msg_valid      (m_smi<%=i%>_rx_vif.smi_msg_valid),
        .<%=obj.interfaces.smiTxInt[i].name%>ndp_msg_type	    (m_smi<%=i%>_rx_vif.smi_msg_type),
        .<%=obj.interfaces.smiTxInt[i].name%>ndp_msg_ready      (m_smi<%=i%>_rx_vif.smi_msg_ready),
    <% if(obj.interfaces.smiTxInt[i].params.wSmiPri >0) {%>
        .<%=obj.interfaces.smiTxInt[i].name%>ndp_msg_pri	    (m_smi<%=i%>_rx_vif.smi_msg_pri[<%=obj.interfaces.smiTxInt[i].params.wSmiPri-1%>:0]),  
    <% } %>
        .<%=obj.interfaces.smiTxInt[i].name%>ndp_msg_id         (m_smi<%=i%>_rx_vif.smi_msg_id),
        .<%=obj.interfaces.smiTxInt[i].name%>ndp_dp_present     (m_smi<%=i%>_rx_vif.smi_dp_present),
    <% if(obj.interfaces.smiTxInt[i].params.wSmiUser >0) {%>
        .<%=obj.interfaces.smiTxInt[i].name%>ndp_msg_user	    (m_smi<%=i%>_rx_vif.smi_msg_user[<%=obj.interfaces.smiTxInt[i].params.wSmiUser-1%>:0]), 
    <% } %>
    <% if(obj.interfaces.smiTxInt[i].params.wSmiTier >0) {%>
        .<%=obj.interfaces.smiTxInt[i].name%>ndp_msg_tier	    (m_smi<%=i%>_rx_vif.smi_msg_tier[<%=obj.interfaces.smiTxInt[i].params.wSmiTier-1%>:0]),  
    <% } %>
    <% if(obj.interfaces.smiTxInt[i].params.wSmiSteer >0) {%>
        .<%=obj.interfaces.smiTxInt[i].name%>ndp_steer	        (m_smi<%=i%>_rx_vif.smi_steer[<%=obj.interfaces.smiTxInt[i].params.wSmiSteer-1%>:0]),  
    <% } %>
    <% if(obj.interfaces.smiTxInt[i].params.wSmiMsgQos >0) {%>
        .<%=obj.interfaces.smiTxInt[i].name%>ndp_msg_qos	    (m_smi<%=i%>_rx_vif.smi_msg_qos[<%=obj.interfaces.smiTxInt[i].params.wSmiMsgQos-1%>:0]), 
    <% } %>
    <% if(obj.interfaces.smiTxInt[i].params.wSmiErr >0) {%>
        .<%=obj.interfaces.smiTxInt[i].name%>ndp_msg_err	    (m_smi<%=i%>_rx_vif.smi_msg_err[<%=obj.interfaces.smiTxInt[i].params.wSmiErr-1%>:0]),
    <% } %>
    <%  if (obj.interfaces.smiTxInt[i].params.nSmiDPvc) { %>    
            .<%=obj.interfaces.smiTxInt[i].name%>dp_valid       (m_smi<%=i%>_rx_vif.smi_dp_valid),
    <% if(obj.interfaces.smiTxInt[i].params.wSmiDPuser >0) {%>
            .<%=obj.interfaces.smiTxInt[i].name%>dp_user	    (m_smi<%=i%>_rx_vif.smi_dp_user[<%=obj.interfaces.smiTxInt[i].params.wSmiDPuser-1%>:0]),
    <% } %>
            .<%=obj.interfaces.smiTxInt[i].name%>dp_ready       (m_smi<%=i%>_rx_vif.smi_dp_ready),
            .<%=obj.interfaces.smiTxInt[i].name%>dp_last        (m_smi<%=i%>_rx_vif.smi_dp_last),
            .<%=obj.interfaces.smiTxInt[i].name%>dp_data        (m_smi<%=i%>_rx_vif.smi_dp_data[<%=obj.interfaces.smiTxInt[i].params.wSmiDPdata-1%>:0]),
    <% } %> 
    <% } %>

        //SMI RX ports
    <% for (var i = 0; i < obj.interfaces.smiTxInt.length; i++) { %>
        .<%=obj.interfaces.smiRxInt[i].name%>ndp_targ_id	    (m_smi<%=i%>_tx_vif.smi_targ_id),
        .<%=obj.interfaces.smiRxInt[i].name%>ndp_src_id         (m_smi<%=i%>_tx_vif.smi_src_id),
        .<%=obj.interfaces.smiRxInt[i].name%>ndp_ndp_len	    (m_smi<%=i%>_tx_vif.smi_ndp_len),
        .<%=obj.interfaces.smiRxInt[i].name%>ndp_ndp	        (m_smi<%=i%>_tx_vif.smi_ndp[<%=obj.interfaces.smiRxInt[i].params.wSmiNDP-1%>:0]	), 
        .<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_valid	    (m_smi<%=i%>_tx_vif.smi_msg_valid),
        .<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_type	    (m_smi<%=i%>_tx_vif.smi_msg_type),
        .<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_ready	    (m_smi<%=i%>_tx_vif.smi_msg_ready),
    <% if(obj.interfaces.smiRxInt[i].params.wSmiPri >0) {%>
        .<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_pri	    (m_smi<%=i%>_tx_vif.smi_msg_pri[<%=obj.interfaces.smiRxInt[i].params.wSmiPri-1%>:0]),  
    <% } %>
        .<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_id         (m_smi<%=i%>_tx_vif.smi_msg_id),
        .<%=obj.interfaces.smiRxInt[i].name%>ndp_dp_present     (m_smi<%=i%>_tx_vif.smi_dp_present),
    <% if(obj.interfaces.smiRxInt[i].params.wSmiUser >0) {%>
        .<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_user	    (m_smi<%=i%>_tx_vif.smi_msg_user[<%=obj.interfaces.smiRxInt[i].params.wSmiUser-1%>:0]), 
    <% } %>
    <% if(obj.interfaces.smiRxInt[i].params.wSmiTier >0) {%>
        .<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_tier	    (m_smi<%=i%>_tx_vif.smi_msg_tier[<%=obj.interfaces.smiRxInt[i].params.wSmiTier-1%>:0]),  
    <% } %>
    <% if(obj.interfaces.smiRxInt[i].params.wSmiSteer >0) {%>
        .<%=obj.interfaces.smiRxInt[i].name%>ndp_steer	        (m_smi<%=i%>_tx_vif.smi_steer[<%=obj.interfaces.smiRxInt[i].params.wSmiSteer-1%>:0]),  
    <% } %>
    <% if(obj.interfaces.smiRxInt[i].params.wSmiMsgQos >0) {%>
        .<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_qos	    (m_smi<%=i%>_tx_vif.smi_msg_qos[<%=obj.interfaces.smiRxInt[i].params.wSmiMsgQos-1%>:0]), 
    <% } %>
    <% if(obj.interfaces.smiRxInt[i].params.wSmiErr >0) {%>
        .<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_err	    (m_smi<%=i%>_tx_vif.smi_msg_err[<%=obj.interfaces.smiRxInt[i].params.wSmiErr-1%>:0]),
    <% } %>

    <%  if (obj.interfaces.smiRxInt[i].params.nSmiDPvc) { %>    
        .<%=obj.interfaces.smiRxInt[i].name%>dp_valid           (m_smi<%=i%>_tx_vif.smi_dp_valid),
    <% if(obj.interfaces.smiRxInt[i].params.wSmiDPuser >0) {%>
        .<%=obj.interfaces.smiRxInt[i].name%>dp_user	        (m_smi<%=i%>_tx_vif.smi_dp_user[<%=obj.interfaces.smiRxInt[i].params.wSmiDPuser-1%>:0]),
    <% } %>
        .<%=obj.interfaces.smiRxInt[i].name%>dp_ready           (m_smi<%=i%>_tx_vif.smi_dp_ready),
        .<%=obj.interfaces.smiRxInt[i].name%>dp_last            (m_smi<%=i%>_tx_vif.smi_dp_last),
        .<%=obj.interfaces.smiRxInt[i].name%>dp_data            (m_smi<%=i%>_tx_vif.smi_dp_data[<%=obj.interfaces.smiRxInt[i].params.wSmiDPdata-1%>:0]),
    <% } %> 
    <% } %>

    
        
    <% if(obj.system.ResilienceEnable) { %>
        //TODO resiliency if ******************************************
    <% if(obj.UnitDuplicationEnable) { %>
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
    <% if (obj.DutInfo.usePma) { %>
    .<%=obj.interfaces.qInt.name%>ACTIVE                ( m_q_chnl_if.QACTIVE ) ,
    .<%=obj.interfaces.qInt.name%>DENY                  ( m_q_chnl_if.QDENY   ) ,
    .<%=obj.interfaces.qInt.name%>REQn                  ( m_q_chnl_if.QREQn   ) ,
    .<%=obj.interfaces.qInt.name%>ACCEPTn               ( m_q_chnl_if.QACCEPTn) ,
    <% } %>

        // even though clock is at top of design module, moved here to
        // FIXME: avoid compiler error due to comma on last port map if only SMI
        .<%=obj.interfaces.clkInt.name%>clk     (dut_clk)
        ); // giu dut

    <% for (var i = 0; i < obj.nSmiTx; i++) { %>
    <% if(obj.interfaces.smiTxInt[i].params.wSmiErr == 0) {%>
    //assign m_smi<%=i%>_rx_vif.smi_msg_err = 1'b0;
    initial begin $assertoff(0, m_smi<%=i%>_rx_vif.assert_smi_msg_err_not_x_z); end
    <% } %>
    <% } %>
    ////perf counter :stall_if to dut connection 
    // assign <%=obj.BlockId%>_sb_stall_if.clk = dut_clk;
    // assign <%=obj.BlockId%>_sb_stall_if.rst_n = soft_rstn;
    // assign <%=obj.BlockId%>_sb_stall_if.master_cnt_enable = dut.trigger_trigger;
    // SMI TX
    // <%for (var i = 0; i < obj.nSmiTx; i++) { %>
    // <%  if (obj.interfaces.smiTxInt[i].params.nSmiDPvc) { %>  
    // assign <%=obj.BlockId%>_sb_stall_if.smi_tx<%=i%>_valid = dut.<%=obj.interfaces.smiTxInt[i].name%>dp_valid;       
    // assign <%=obj.BlockId%>_sb_stall_if.smi_tx<%=i%>_ready = dut.<%=obj.interfaces.smiTxInt[i].name%>dp_ready;     
    // <% } else { %>
    // assign <%=obj.BlockId%>_sb_stall_if.smi_tx<%=i%>_valid = dut.<%=obj.interfaces.smiTxInt[i].name%>ndp_msg_valid;       
    // assign <%=obj.BlockId%>_sb_stall_if.smi_tx<%=i%>_ready = dut.<%=obj.interfaces.smiTxInt[i].name%>ndp_msg_ready;     
    // <% } %> 
    // <% } %>
    // SMI RX
    // <%for (var i = 0; i < obj.nSmiRx; i++) { %>
    //   <%  if (obj.interfaces.smiRxInt[i].params.nSmiDPvc) { %>  
    // assign <%=obj.BlockId%>_sb_stall_if.smi_rx<%=i%>_valid = dut.<%=obj.interfaces.smiRxInt[i].name%>dp_valid;
    // assign <%=obj.BlockId%>_sb_stall_if.smi_rx<%=i%>_ready = dut.<%=obj.interfaces.smiRxInt[i].name%>dp_ready;
    // <% } else { %>
    // assign <%=obj.BlockId%>_sb_stall_if.smi_rx<%=i%>_valid = dut.<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_valid;
    // assign <%=obj.BlockId%>_sb_stall_if.smi_rx<%=i%>_ready = dut.<%=obj.interfaces.smiRxInt[i].name%>ndp_msg_ready;
    // <% } %> 
    // <% } %>

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
    giu_csr_probe_if u_csr_probe_if(.clk(dut_clk),.resetn(soft_rstn));

        assign u_csr_probe_if.IRQ_C     = tb_top.dut.<%=obj.interfaces.irqInt.name%>c;
        //assign u_csr_probe_if.IRQ_C     = 0;
        assign u_csr_probe_if.IRQ_UC    = tb_top.dut.<%=obj.interfaces.irqInt.name%>uc;
    <% if(obj.system.ResilienceEnable) { %>
        assign u_csr_probe_if.fault_mission_fault = tb_top.dut.fault_mission_fault;
        assign u_csr_probe_if.fault_latent_fault  = tb_top.dut.fault_latent_fault;
        assign u_csr_probe_if.cerr_threshold          = tb_top.dut.u_fault_checker.cerr_threshold;
        assign u_csr_probe_if.cerr_counter            = tb_top.dut.u_fault_checker.cerr_counter;
        assign u_csr_probe_if.cerr_over_thres_fault   = tb_top.dut.u_fault_checker.cerr_over_thres_fault;
    <% } %>

    initial begin

        uvm_config_db#(virtual giu_csr_probe_if)::set(.cntxt( uvm_root::get() ),
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
    //    uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::set(null, "", "<%=obj.BlockId%>_m_top_stall_if",       <%=obj.BlockId%>_sb_stall_if); 
        uvm_config_db#(virtual <%=obj.BlockId%>_clock_counter_if )::set(.cntxt( uvm_root::get()),
                                            .inst_name( "" ),
                                            .field_name( "m_clock_counter_if" ),
                                            .value(m_clock_counter_if ));

    end

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

    <% if(obj.system.ResilienceEnable) { %>
    fault_injector_checker fault_inj_check(dut_clk, soft_rstn);
    initial begin
    <% if(obj.testBench == 'giu') { %>
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
    uvm_event inject_single = ev_pool.get("giu_trace_mem_inject_single_error");
    uvm_event inject_double = ev_pool.get("giu_trace_mem_inject_double_error");
    uvm_event inject_addr = ev_pool.get("giu_trace_mem_inject_addr_error");
    uvm_event saw_single = ev_pool.get("giu_trace_mem_rtl_saw_single_error");
    uvm_event saw_double = ev_pool.get("giu_trace_mem_rtl_saw_double_error");
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
    join_none
    end: trace_mem_error

    task inject_tacc_single_error(int mem = 0);
    <% // External trace memories don't have error injection functions?
    // or is it internal?
    //console.log(obj.GiuInfo[0].MemoryGeneration.traceMem);
    if(obj.GiuInfo[0].assertOn == 1) {
        for(var i = 0; i < obj.GiuInfo[0].MemoryGeneration.traceMem.length; i++) {
            var name = obj.GiuInfo[0].MemoryGeneration.traceMem[i].rtlPrefixString;
            var type = obj.GiuInfo[0].MemoryGeneration.traceMem[i].MemType; %>
    if(mem == <%=i%>) begin
    <% if(type == "NONE") { %>
        tb_top.dut.<%=name%>.internal_mem_inst.inject_single_error();
        `uvm_info("tb_top", "Injected single error on memory <%=name%>(<%=type%>)", UVM_NONE)
    <% } else if (type == "SYNOPSYS") { %>
        tb_top.dut.<%=name%>.external_mem_inst.internal_mem_inst.inject_single_error();
        `uvm_info("tb_top", "Injected single error on memory <%=name%>(<%=type%>)", UVM_NONE)
    <% } else { %>
    // <%=i%> not building error injection for memory <%=name%> with type <%=type%>
        `uvm_warning("tb_top", "Attempted to inject error on <%=name%>, which does not support error injection")
    <% } %>
    end
    <% } } %>
    endtask:inject_tacc_single_error

    task inject_tacc_double_error(int mem = 0);
    <% // External trace memories don't have error injection functions?
    // or is it internal?
    //console.log(obj.GiuInfo[0].MemoryGeneration.traceMem);
    if(obj.GiuInfo[0].assertOn == 1) {
        for(var i = 0; i < obj.GiuInfo[0].MemoryGeneration.traceMem.length; i++) {
            var name = obj.GiuInfo[0].MemoryGeneration.traceMem[i].rtlPrefixString;
            var type = obj.GiuInfo[0].MemoryGeneration.traceMem[i].MemType; %>
    if(mem == <%=i%>) begin
    <% if(type == "NONE") { %>
        tb_top.dut.<%=name%>.internal_mem_inst.inject_double_error();
        `uvm_info("tb_top", "Injected double error on memory <%=name%>(<%=type%>)", UVM_NONE)
    <% } else if (type == "SYNOPSYS") { %>
        tb_top.dut.<%=name%>.external_mem_inst.internal_mem_inst.inject_double_error();
        `uvm_info("tb_top", "Injected double error on memory <%=name%>(<%=type%>)", UVM_NONE)
    <% } else { %>
    // <%=i%> not building error injection for memory <%=name%> with type <%=type%>
        `uvm_warning("tb_top", "Attempted to inject error on <%=name%>, which does not support error injection")
    <% } %>
    end
    <% } } %>
    endtask:inject_tacc_double_error

    task inject_tacc_addr_error(int mem = 0);
    <% // External trace memories don't have error injection functions?
    // or is it internal?
    //console.log(obj.GiuInfo[0].MemoryGeneration.traceMem);
    if(obj.GiuInfo[0].assertOn == 1) {
        for(var i = 0; i < obj.GiuInfo[0].MemoryGeneration.traceMem.length; i++) {
            var name = obj.GiuInfo[0].MemoryGeneration.traceMem[i].rtlPrefixString;
            var type = obj.GiuInfo[0].MemoryGeneration.traceMem[i].MemType; %>
    if(mem == <%=i%>) begin
    <% if(type == "NONE") { %>
        tb_top.dut.<%=name%>.internal_mem_inst.inject_addr_error();
        `uvm_info("tb_top", "Injected addr error on memory <%=name%>(<%=type%>)", UVM_NONE)
    <% } else if (type == "SYNOPSYS") { %>
        tb_top.dut.<%=name%>.external_mem_inst.internal_mem_inst.inject_addr_error();
        `uvm_info("tb_top", "Injected addr error on memory <%=name%>(<%=type%>)", UVM_NONE)
    <% } else { %>
    // <%=i%> not building error injection for memory <%=name%> with type <%=type%>
        `uvm_warning("tb_top", "Attempted to inject error on <%=name%>, which does not support error injection")
    <% } %>
    end
    <% } } %>
    endtask:inject_tacc_addr_error

    initial begin: drop_capture_count
    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event rtl_captured = ev_pool.get("giu_trace_captured");
    uvm_event rtl_dropped = ev_pool.get("giu_trace_dropped");
    fork
        // watch RTL for capture events
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
    <% if (obj.DutInfo.usePma) { %>
    assert_clk_idle_when_pma_asserted : assert property (
        @(posedge tb_clk) disable iff (!soft_rstn)
        (!m_q_chnl_if.QREQn && !m_q_chnl_if.QACCEPTn ) |-> !dut_clk
        ) else assert_error("ERROR", "Dut clock is not stable low when RTL entered into PMA");
    <% } %>

endmodule
