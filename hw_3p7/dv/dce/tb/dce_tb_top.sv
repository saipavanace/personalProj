//`timescale 1ps/1ps

<% var ASILB = 0; // (obj.useResiliency & obj.enableUnitDuplication) ? 0 : 1; %>
<% var hier_path_dce_csr          = (!ASILB) ? 'dce_func_unit.u_csr' : 'u_csr'; %>
<% var hier_path_dce_cmux         = (!ASILB) ? 'dce_func_unit.dce_conc_mux' : 'dce_conc_mux'; %>
<% var hier_path_dce_sbcmdreqfifo = (!ASILB) ? 'dce_func_unit.skid_buf_cmd_req_fifo' : 'skid_buf_cmd_req_fifo'; %>
<% var hier_path_dce_sb           = (!ASILB) ? 'dce_func_unit.dce_skid_buffer' : 'dce_skid_buffer'; %>

<% if(obj.useResiliency) { %>
`include "fault_injector_checker.sv"
<% } %>

<% 

var attvec_width = 0;

obj.DceInfo.forEach(function(bundle) {
    if (bundle.nAttCtrlEntries > attvec_width) {
        attvec_width = bundle.nAttCtrlEntries;
    }
});
%> 

localparam [<%=obj.DceInfo[obj.Id].nCachingAgents%>-1:0][<%=obj.DceInfo[obj.Id].wNUnitId%>-1:0] CACHING_NUNIT_IDS = '{
    <% var index       = 0;
       var sf_cnt      = 0;
       var plru_en     = 0;
       var nunit_index = [];
       var nunit_idx   = 0 ;
       obj.SnoopFilterInfo.forEach(function(bundle,indx, array) {
        index++; 
        sf_cnt++;
        if(bundle.RepPolicy == "PLRU") {
            plru_en = 1;
        }
    });
    for(var x = 0; x < index; x++){
        obj.SnoopFilterInfo[x].SnoopFilterNUnitIdAssignment.forEach(function(bundle,indx, array) { 
             nunit_idx++;
        });
        nunit_index[x] = nunit_idx;
        nunit_idx = 0;
    }
    for(var i = index; i >= 0;i--){
         for(var j = 0; j < nunit_index[i];j++){ %>
            <%=obj.SnoopFilterInfo[i].SnoopFilterNUnitIdAssignment[j]%><% if(i == 0 && j == (nunit_index[i]-1)){ } else {%> ,<%};
        }
    }%>
        
};

localparam [<%=obj.DceInfo[obj.Id].nDceConnectedDmis%>-1:0][<%=obj.Widths.Concerto.Ndp.Body.wRBId%>-1:0] DMI_RBOffset = '{
    <% for(var rb_index = 0; rb_index < obj.DceInfo[obj.Id].hexDceDmiRbOffset.length; rb_index++){%>
        <%=obj.DceInfo[obj.Id].hexDceDmiRbOffset[rb_index]%><% if(rb_index == (obj.DceInfo[obj.Id].hexDceDmiRbOffset.length-1)){ } else {%> ,<%};
    }%>
};

localparam [<%=obj.DceInfo[obj.Id].nDceConnectedDmis%>-1:0][<%=obj.DceInfo[obj.Id].wFUnitId%>-1:0] CONNECTED_DMI_FUNIT_ID = '{
    <% for(var dmi_index = 0; dmi_index < obj.DceInfo[obj.Id].nDceConnectedDmis; dmi_index++){%>
        <%=obj.DceInfo[obj.Id].hexDceConnectedDmiFunitId[dmi_index]%><% if(dmi_index == (obj.DceInfo[obj.Id].nDceConnectedDmis-1)){ } else {%> ,<%};
    }%>
};

module tb_top();

import uvm_pkg::*;
import addr_trans_mgr_pkg::*;
import <%=obj.BlockId%>_smi_agent_pkg::*;

`include "uvm_macros.svh"

import <%=obj.BlockId%>_test_lib_pkg::*;

//-----------------------------------------------------------------------------
// Clocks and Reset
//-----------------------------------------------------------------------------
bit dut_clk;
bit tb_clk;
bit tb_rstn;
bit soft_rstn;

//Event Interface signals

bit event_in_req_dly;
bit event_in_ack_dly;
bit event_err_valid_dly;

logic [<%=obj.DceInfo[obj.Id].nDmis%>-1:0] DceDmiConVec = 'h<%=obj.DceInfo[obj.Id].hexDceDmiVec%>;

initial begin
    DceDmiConVec = {<<{DceDmiConVec}};
end


//Resiliency
<% if(obj.useResiliency) { %>
  <%
  var ASILB = 0; // (obj.useResiliency & obj.DceInfo[obj.Id].ResilienceInfo.enableUnitDuplication) ? 0 : 1;
  var hier_path_dce_csr = '';
  var hier_path_dce_cmux = '';
  var hier_path_dce_sbcmdreqfifo = '';
  var hier_path_dce_sb = '';
  if (!ASILB) {
    hier_path_dce_csr = 'dce_func_unit.u_csr';
    hier_path_dce_cmux = 'dce_func_unit.dce_conc_mux';
    hier_path_dce_sbcmdreqfifo = 'dce_func_unit.skid_buf_cmd_req_fifo';
    hier_path_dce_sb = 'dce_func_unit.dce_skid_buffer';
  } else {
    hier_path_dce_csr = 'u_csr';
    hier_path_dce_cmux = 'dce_conc_mux';
    hier_path_dce_sbcmdreqfifo = 'skid_buf_cmd_req_fifo';
    hier_path_dce_sb = 'dce_skid_buffer';
  }
  %>
 logic[1023:0] slv_req_corruption_vector = 1024'b0;
 logic[1023:0] slv_data_corruption_vector = 1024'b0;
 logic[WSMIADDR-1:0] smi_req_addr_modified;
 logic[<%=obj.DceInfo[obj.Id].wData%>-1:0] smi_req_data_modified;  //TODO checkme: flat view of txn payload data for error injection

 logic bist_bist_next_ack;
 logic bist_domain_is_on;
 logic fault_mission_fault;
 logic fault_latent_fault;
 logic fault_cerr_over_thres_fault;
<% } %>

<% for(var x = 0; x < sf_cnt; x++){ %>
    // insitantiaing a snoop filter if[<%=x%>]
    // ----------------------------------------------------------------------------------------
    snoop_filter_if #(.NSETS(<%=obj.SnoopFilterInfo[x].nSets%>), .NWAYS(<%=obj.SnoopFilterInfo[x].nWays%>), .BYTES_PER_LINE(8)) u_sf_if_<%=x%>[<%=obj.SnoopFilterInfo[x].nWays%>] ();
    <% for(var y = 0; y < obj.SnoopFilterInfo[x].nWays; y++){ %>
    assign u_sf_if_<%=x%>[<%=y%>].clk        = tb_top.dut.<%=obj.SnoopFilterInfo[x].TagMem[y].rtlPrefixString%>.clk;
    assign u_sf_if_<%=x%>[<%=y%>].rst_n      = 1;
    assign u_sf_if_<%=x%>[<%=y%>].mnt_ops    = tb_top.dut.<%=hier_path_dce_csr%>.csr_DceMntOpActive;
    assign u_sf_if_<%=x%>[<%=y%>].cen        = tb_top.dut.<%=obj.SnoopFilterInfo[x].TagMem[y].rtlPrefixString%>.int_chip_en;
    assign u_sf_if_<%=x%>[<%=y%>].wen        = tb_top.dut.<%=obj.SnoopFilterInfo[x].TagMem[y].rtlPrefixString%>.int_write_en;
    assign u_sf_if_<%=x%>[<%=y%>].data       = tb_top.dut.<%=obj.SnoopFilterInfo[x].TagMem[y].rtlPrefixString%>.int_data_out;
    assign u_sf_if_<%=x%>[<%=y%>].set_index  = tb_top.dut.<%=obj.SnoopFilterInfo[x].TagMem[y].rtlPrefixString%>.int_address;
    <% } %>

    <%if(plru_en == 1) {%>
    snoop_filter_if #(.NSETS(<%=obj.SnoopFilterInfo[x].nSets%>), .NWAYS(1), .BYTES_PER_LINE(8)) u_plru_mem_wr_if_<%=x%>();
    assign u_plru_mem_wr_if_<%=x%>.clk        = tb_top.dut.<%=obj.SnoopFilterInfo[x].RpMem[0].rtlPrefixString%>.clk;
    assign u_plru_mem_wr_if_<%=x%>.rst_n      = 1;
    assign u_plru_mem_wr_if_<%=x%>.mnt_ops    = tb_top.dut.<%=hier_path_dce_csr%>.csr_DceMntOpActive;
    assign u_plru_mem_wr_if_<%=x%>.cen        = tb_top.dut.<%=obj.SnoopFilterInfo[x].RpMem[0].rtlPrefixString%>.int_chip_en_write;
    assign u_plru_mem_wr_if_<%=x%>.wen        = 1;
    assign u_plru_mem_wr_if_<%=x%>.data       = tb_top.dut.<%=obj.SnoopFilterInfo[x].RpMem[0].rtlPrefixString%>.int_data_in;
    assign u_plru_mem_wr_if_<%=x%>.set_index  = tb_top.dut.<%=obj.SnoopFilterInfo[x].RpMem[0].rtlPrefixString%>.int_address_write;
    <%}%>

    initial begin
    <% for(var y = 0; y < obj.SnoopFilterInfo[x].nWays; y++){ %>
        uvm_config_db #(virtual snoop_filter_if #(<%=obj.SnoopFilterInfo[x].nSets%>, <%=obj.SnoopFilterInfo[x].nWays%>, 8))::set(null, "", "sf_monitor[<%=x%>].way<%=y%>", u_sf_if_<%=x%>[<%=y%>]);
    <% } %>
    <%if(plru_en == 1) {%>
        uvm_config_db #(virtual snoop_filter_if #(<%=obj.SnoopFilterInfo[x].nSets%>, 1, 8))::set(null, "", "plru_mem_wr_monitor[<%=x%>].way0", u_plru_mem_wr_if_<%=x%>);
    <%}%>
    end

<% } %>

<% if(obj.INHOUSE_APB_VIP && obj.assertOn) {%>
  <% obj.SnoopFilterInfo.forEach(function sfways(item,index){ %>
    <%  if (item.TagMem[0].MemType == "NONE" || item.TagMem[0].MemType == "SYNOPSYS") { %>
    <% for(var i=0;i<item.nWays;i++){ %>
       uvm_event         injectSingleErrTag<%=index%>_<%=i%>;
       uvm_event         injectDoubleErrTag<%=index%>_<%=i%>;
       uvm_event         inject_multi_block_single_double_ErrTag<%=index%>_<%=i%>;
       uvm_event         inject_multi_block_double_ErrTag<%=index%>_<%=i%>;
       uvm_event         inject_multi_block_single_ErrTag<%=index%>_<%=i%>;
       uvm_event         injectAddrErrTag<%=index%>_<%=i%>;
    <% } %>
    <% } %>
  <% }); %>
<% } %>


//SMI Interface
<% for (var i = 0; i < obj.nSmiRx; i++) { %>
<%=obj.BlockId%>_smi_if m_smi<%=i%>_tx_vif(dut_clk, soft_rstn, "<%= 'tx_NDP_' + i%>");
<% } %>

<% for (var i = 0; i < obj.nSmiTx; i++) { %>
<%=obj.BlockId%>_smi_if m_smi<%=i%>_rx_vif(dut_clk, soft_rstn, "<%= 'rx_NDP_' + i%>");
<% } %>

//Probe Interface
<%=obj.BlockId%>_probe_if probe_vif(dut_clk, soft_rstn);

//Q-channel interface
<%=obj.BlockId%>_q_chnl_if  m_q_chnl_if(tb_clk, tb_rstn);
//perf monitor staal if
<%=obj.BlockId%>_stall_if <%=obj.BlockId%>_sb_stall_if();
uvm_event         toggle_clk;
uvm_event         toggle_rst;

<%  if(obj.INHOUSE_APB_VIP && obj.testBench=="dce") { %>
<%=obj.BlockId%>_apb_if apb_if(.clk(dut_clk), .rst_n(soft_rstn));
<% } %>

assign probe_vif.IRQ_C     = tb_top.dut.<%=obj.DceInfo[obj.Id].interfaces.irqInt.name%>c;
assign probe_vif.IRQ_UC    = tb_top.dut.<%=obj.DceInfo[obj.Id].interfaces.irqInt.name%>uc;
assign probe_vif.timeout_threshold       = tb_top.dut.<%=hier_path_dce_csr%>.DCEUTOCR_TimeOutThreshold_out;
assign probe_vif.uedr_timeout_err_det_en = tb_top.dut.<%=hier_path_dce_csr%>.DCEUUEDR_TimeoutErrDetEn_out;
assign probe_vif.uesr_errvld             = tb_top.dut.<%=hier_path_dce_csr%>.DCEUUESR_ErrVld_out;
assign probe_vif.uesr_err_type           = tb_top.dut.<%=hier_path_dce_csr%>.DCEUUESR_ErrType_out;
assign probe_vif.uesr_err_info           = tb_top.dut.<%=hier_path_dce_csr%>.DCEUUESR_ErrInfo_out;
assign probe_vif.ueir_timeout_irq_en     = tb_top.dut.<%=hier_path_dce_csr%>.DCEUUEIR_TimeoutErrIntEn_out;

// Update for CONC-12575
// The bit width seems to grown? So depositing a higher value for
// quick convergence during simulation
logic deposit_tout_cnt_value;
initial begin
    deposit_tout_cnt_value = 0;
    if($test$plusargs("en_dce_ev_protocol_timeout")) begin // enable protocol_timeout scenarios
        forever begin
            @(posedge probe_vif.event_in_req);
            deposit_tout_cnt_value = 1'b1;
            $deposit(tb_top.dut.dce_func_unit.u_sys_evt_coh_concerto.u_sys_evt_coh_wrapper.u_sys_evt_sender.protocol_timeout_counter, 20'hf_fc00);
            #5ns;
            deposit_tout_cnt_value = 1'b0;
        end
    end
end

<% if(obj.useResiliency) { %>
   assign probe_vif.fault_mission_fault = tb_top.dut.fault_mission_fault;
   assign probe_vif.fault_latent_fault  = tb_top.dut.fault_latent_fault;
   assign probe_vif.cerr_threshold          = tb_top.dut.u_dce_fault_checker.cerr_threshold;
   assign probe_vif.cerr_counter            = tb_top.dut.u_dce_fault_checker.cerr_counter;
   assign probe_vif.cerr_over_thres_fault   = tb_top.dut.u_dce_fault_checker.cerr_over_thres_fault;
<% } %>

initial begin
<% if(obj.INHOUSE_APB_VIP && obj.assertOn) {%>
   if ($test$plusargs("always_inject_error")) begin
     ev_always_inject_error.wait_ptrigger();
     fork
<% obj.SnoopFilterInfo.forEach(function sfways(item,index){ %>
<%  if (item.TagMem[0].MemType == "NONE") { %>
  <% for(var i=0;i<item.nWays;i++){ %>
       //tb_top.dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.inject_errors(100,0,1);
       tb_top.dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.internal_mem_inst.inject_errors(100,0,1);
  <% } %>
  <% } %>
<%  if (item.TagMem[0].MemType == "SYNOPSYS") { %>
  <% for(var i=0;i<item.nWays;i++){ %>
       //tb_top.dut.f<%=index%>m<%=i%>_memory.external_mem_inst.internal_mem_inst.inject_errors(100,0,1);
       //tb_top.dut.EOS<%=index%>_TagMem_way_<%=i%>.external_mem_inst.internal_mem_inst.inject_errors(100,0,1);
       tb_top.dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_errors(100,0,1);
  <% } %>
  <% } %>
  <% }); %>
     join
     $display("Always injecting correctable errors");
   end
<% } %>
end

<% if(obj.INHOUSE_APB_VIP && obj.assertOn) {%>
<% obj.SnoopFilterInfo.forEach(function sfways(item,index){ %>
<%  if (item.TagMem[0].MemType == "NONE") { %>
  <% for(var i=0;i<item.nWays;i++){ %>

initial
     begin
         int k_addr_inject_pct;

         if(($value$plusargs("k_addr_inject_pct=%d",k_addr_inject_pct))) begin
             tb_top.dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.internal_mem_inst.init_addr_error(k_addr_inject_pct);
         end
     end

always@(posedge dut_clk) begin
  $display("%0t Waiting in  singleErrTag task for filter: <%=index%> & ways: <%=i%>", $time);
  injectSingleErrTag<%=index%>_<%=i%>.wait_ptrigger();
  injectSingleErrTag<%=index%>_<%=i%>.reset();
  $display("%0t Saw wait in  singleErrTag task for filter: <%=index%> & ways: <%=i%>", $time);
  //tb_top.dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.inject_single_error();
  //tb_top.dut.EOS<%=index%>_TagMem_way_<%=i%>.internal_mem_inst.inject_single_error();
  tb_top.dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.internal_mem_inst.inject_single_error();
end

always@(posedge dut_clk) begin
  $display("%0t Waiting in  DoubleErrTag task for filter: <%=index%> & ways: <%=i%>", $time);   
  injectDoubleErrTag<%=index%>_<%=i%>.wait_ptrigger();
  injectDoubleErrTag<%=index%>_<%=i%>.reset();
  $display("%0t Saw wait in  DoubleErrTag task for filter: <%=index%> & ways: <%=i%>", $time);   
  //tb_top.dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.inject_double_error();
  //tb_top.dut.EOS<%=index%>_TagMem_way_<%=i%>.internal_mem_inst.inject_double_error();
  tb_top.dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.internal_mem_inst.inject_double_error();
end

always@(posedge dut_clk) begin
  $display("Waiting in multi_block_single_double_ErrTag task for filter: <%=index%> & ways: <%=i%>");   
  inject_multi_block_single_double_ErrTag<%=index%>_<%=i%>.wait_ptrigger();
  inject_multi_block_single_double_ErrTag<%=index%>_<%=i%>.reset();
  $display("Saw wait in  multi_block_single_double_ErrTag task for filter: <%=index%> & ways: <%=i%>");   
  //tb_top.dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.inject_multi_blk_single_double_error();
  //tb_top.dut.EOS<%=index%>_TagMem_way_<%=i%>.internal_mem_inst.inject_multi_blk_single_double_error();
  tb_top.dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.internal_mem_inst.inject_multi_blk_single_double_error();
end

always@(posedge dut_clk) begin
  $display("Waiting in multi_block_double_ErrTag task for filter: <%=index%> & ways: <%=i%>");   
  inject_multi_block_double_ErrTag<%=index%>_<%=i%>.wait_ptrigger();
  inject_multi_block_double_ErrTag<%=index%>_<%=i%>.reset();
  $display("Saw wait in  multi_block_double_ErrTag task for filter: <%=index%> & ways: <%=i%>");   
  //tb_top.dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.inject_multi_blk_double_error();
  //tb_top.dut.EOS<%=index%>_TagMem_way_<%=i%>.internal_mem_inst.inject_multi_blk_double_error();
  tb_top.dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.internal_mem_inst.inject_multi_blk_double_error();
end

always@(posedge dut_clk) begin
  $display("Waiting in multi_block_single_ErrTag task for filter: <%=index%> & ways: <%=i%>");   
  inject_multi_block_single_ErrTag<%=index%>_<%=i%>.wait_ptrigger();
  inject_multi_block_single_ErrTag<%=index%>_<%=i%>.reset();
  $display("Saw wait in  multi_block_single_ErrTag task for filter: <%=index%> & ways: <%=i%>");   
  //tb_top.dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.inject_multi_blk_single_error();
  //tb_top.dut.EOS<%=index%>_TagMem_way_<%=i%>.internal_mem_inst.inject_multi_blk_single_error();
  tb_top.dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.internal_mem_inst.inject_multi_blk_single_error();
end

always@(posedge dut_clk) begin
  $display("Waiting in AddrErrTag task for filter: <%=index%> & ways: <%=i%>");   
  injectAddrErrTag<%=index%>_<%=i%>.wait_ptrigger();
  injectAddrErrTag<%=index%>_<%=i%>.reset();
  $display("Saw wait in AddrErrTag task for filter: <%=index%> & ways: <%=i%>");   
  //tb_top.dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.inject_addr_error();
  //tb_top.dut.EOS<%=index%>_TagMem_way_<%=i%>.internal_mem_inst.inject_addr_error();
  tb_top.dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.internal_mem_inst.inject_addr_error();
end

    <% } %>
    <% } %>

<%  if (item.TagMem[0].MemType == "SYNOPSYS") { %>
  <% for(var i=0;i<item.nWays;i++){ %>
     initial
     begin
         int k_addr_inject_pct;

         if(($value$plusargs("k_addr_inject_pct=%d",k_addr_inject_pct))) begin
             tb_top.dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.init_addr_error(k_addr_inject_pct);
         end
     end

always@(posedge dut_clk) begin
  $display("%0t Waiting in  singleErrTag task for filter: <%=index%> & ways: <%=i%>", $time);
  injectSingleErrTag<%=index%>_<%=i%>.wait_ptrigger();
  injectSingleErrTag<%=index%>_<%=i%>.reset();
  $display("%0t Saw wait in  singleErrTag task for filter: <%=index%> & ways: <%=i%>", $time);
  //tb_top.dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.inject_single_error();
  //tb_top.dut.EOS<%=index%>_TagMem_way_<%=i%>.external_mem_inst.internal_mem_inst.inject_single_error();
  tb_top.dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_single_error();
end

always@(posedge dut_clk) begin
  $display("%0t Waiting in  DoubleErrTag task for filter: <%=index%> & ways: <%=i%>", $time);
  injectDoubleErrTag<%=index%>_<%=i%>.wait_ptrigger();
  injectDoubleErrTag<%=index%>_<%=i%>.reset();
  $display("%0t Saw wait in  DoubleErrTag task for filter: <%=index%> & ways: <%=i%>", $time);
  //tb_top.dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.inject_double_error();
  //tb_top.dut.EOS<%=index%>_TagMem_way_<%=i%>.external_mem_inst.internal_mem_inst.inject_double_error();
  tb_top.dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_double_error();
end

always@(posedge dut_clk) begin
  $display("Waiting in multi_block_single_double_ErrTag task for filter: <%=index%> & ways: <%=i%>");   
  inject_multi_block_single_double_ErrTag<%=index%>_<%=i%>.wait_ptrigger();
  inject_multi_block_single_double_ErrTag<%=index%>_<%=i%>.reset();
  $display("Saw wait in  multi_block_single_double_ErrTag task for filter: <%=index%> & ways: <%=i%>");   
  //tb_top.dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.inject_multi_blk_single_double_error();
  //tb_top.dut.EOS<%=index%>_TagMem_way_<%=i%>.external_mem_inst.internal_mem_inst.inject_multi_blk_single_double_error();
  tb_top.dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_multi_blk_single_double_error();
end

always@(posedge dut_clk) begin
  $display("Waiting in multi_block_double_ErrTag task for filter: <%=index%> & ways: <%=i%>");   
  inject_multi_block_double_ErrTag<%=index%>_<%=i%>.wait_ptrigger();
  inject_multi_block_double_ErrTag<%=index%>_<%=i%>.reset();
  $display("Saw wait in  multi_block_double_ErrTag task for filter: <%=index%> & ways: <%=i%>");   
  //tb_top.dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.inject_multi_blk_double_error();
  //tb_top.dut.EOS<%=index%>_TagMem_way_<%=i%>.external_mem_inst.internal_mem_inst.inject_multi_blk_double_error();
  tb_top.dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_multi_blk_double_error();
end

always@(posedge dut_clk) begin
  $display("Waiting in multi_block_single_ErrTag task for filter: <%=index%> & ways: <%=i%>");   
  inject_multi_block_single_ErrTag<%=index%>_<%=i%>.wait_ptrigger();
  inject_multi_block_single_ErrTag<%=index%>_<%=i%>.reset();
  $display("Saw wait in  multi_block_single_ErrTag task for filter: <%=index%> & ways: <%=i%>");   
  //tb_top.dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.inject_multi_blk_single_error();
  //tb_top.dut.EOS<%=index%>_TagMem_way_<%=i%>.external_mem_inst.internal_mem_inst.inject_multi_blk_single_error();
  tb_top.dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_multi_blk_single_error();
end
always@(posedge dut_clk) begin
  $display("Waiting in AddrErrTag task for filter: <%=index%> & ways: <%=i%>");   
  injectAddrErrTag<%=index%>_<%=i%>.wait_ptrigger();
  injectAddrErrTag<%=index%>_<%=i%>.reset();
  $display("Saw wait in AddrErrTag task for filter: <%=index%> & ways: <%=i%>");   
  //tb_top.dut.f<%=index%>m<%=i%>_memory.internal_mem_inst.inject_addr_error();
  //tb_top.dut.EOS<%=index%>_TagMem_way_<%=i%>.internal_mem_inst.inject_addr_error();
  tb_top.dut.<%=obj.SnoopFilterInfo[index].TagMem[i].rtlPrefixString%>.external_mem_inst.internal_mem_inst.inject_addr_error();
end

    <% } %>
    <% } %>

  <% }); %>
<% } %>

uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
uvm_event ev_fliter_memory_warmed_up = ev_pool.get("ev_fliter_memory_warmed_up");
uvm_event ev_ready_for_mem_trigger   = ev_pool.get("ev_ready_for_mem_trigger");
uvm_event ev_always_inject_error = ev_pool.get("ev_always_inject_error");

bit wait_for_mem_trigger;
initial begin
    wait_for_mem_trigger = 1'b0;
    ev_ready_for_mem_trigger.wait_ptrigger();
    wait_for_mem_trigger = 1'b1;
end

initial begin
  //wait until memory initialization is complete
  wait(tb_top.dut.dce_func_unit.dce_dm.t_init_valid === 1);
  wait(tb_top.dut.dce_func_unit.dce_dm.t_init_valid === 0);
  if(wait_for_mem_trigger == 1'b0) begin
    ev_ready_for_mem_trigger.wait_ptrigger();
  end
  ev_fliter_memory_warmed_up.trigger();
end

initial begin

//SmiTx ports from TB prespective
<% for (var i = 0; i < obj.nSmiRx; i++) { %>
  uvm_config_db #(virtual <%=obj.BlockId%>_smi_if)::set(
    .cntxt(null),
    .inst_name("*"),
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

//probe interface
uvm_config_db#(virtual <%=obj.BlockId%>_probe_if)::set(
    .cntxt( null ), 
    .inst_name( "*" ),
    .field_name( "probe_vif" ),
    .value( probe_vif ));

//Q-Channel interface
uvm_config_db#(virtual <%=obj.BlockId%>_q_chnl_if )::set(
    .cntxt( uvm_root::get()),
    .inst_name( "" ),
    .field_name( "m_q_chnl_if" ),
    .value(m_q_chnl_if ));
//Perf monitor stall_if 
uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::set(null, "", "<%=obj.BlockId%>_m_top_stall_if",       <%=obj.BlockId%>_sb_stall_if); 

<% if(obj.INHOUSE_APB_VIP) { %>
    uvm_config_db#(virtual <%=obj.BlockId%>_apb_if )::set(.cntxt( uvm_root::get()),
                                        .inst_name( "" ),
                                        .field_name( "apb_if" ),
                                        .value(apb_if ));

    uvm_config_db#(virtual <%=obj.BlockId%>_apb_if )::set(.cntxt( null ),
                                        .inst_name( "uvm_test_top.m_env.m_apb_agent.m_apb_driver" ),
                                        .field_name( "m_vif" ),
                                        .value(apb_if ));
<%}%>
<% if(obj.INHOUSE_APB_VIP && obj.assertOn) {%>
<% obj.SnoopFilterInfo.forEach(function sfways(item,index){ %>
    <%  if (item.TagMem[0].MemType == "NONE" || item.TagMem[0].MemType == "SYNOPSYS") { %>
  <% for(var i=0;i<item.nWays;i++){ %>
    injectSingleErrTag<%=index%>_<%=i%> = new("injectSingleErrTag<%=index%>_<%=i%>");
    injectDoubleErrTag<%=index%>_<%=i%> = new("injectDoubleErrTag<%=index%>_<%=i%>");
    inject_multi_block_single_double_ErrTag<%=index%>_<%=i%> = new("inject_multi_block_single_double_ErrTag<%=index%>_<%=i%>");
    inject_multi_block_double_ErrTag<%=index%>_<%=i%> = new("inject_multi_block_double_ErrTag<%=index%>_<%=i%>");
    inject_multi_block_single_ErrTag<%=index%>_<%=i%> = new("inject_multi_block_single_ErrTag<%=index%>_<%=i%>");
    injectAddrErrTag<%=index%>_<%=i%> = new("injectAddrErrTag<%=index%>_<%=i%>");
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "injectSingleErrTag<%=index%>_<%=i%>" ),
                                        .value( injectSingleErrTag<%=index%>_<%=i%>));
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "injectDoubleErrTag<%=index%>_<%=i%>" ),
                                        .value( injectDoubleErrTag<%=index%>_<%=i%>));
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "inject_multi_block_single_double_ErrTag<%=index%>_<%=i%>" ),
                                        .value( inject_multi_block_single_double_ErrTag<%=index%>_<%=i%>));
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "inject_multi_block_double_ErrTag<%=index%>_<%=i%>" ),
                                        .value( inject_multi_block_double_ErrTag<%=index%>_<%=i%>));
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                        .inst_name( "*" ),
                                        .field_name( "inject_multi_block_single_ErrTag<%=index%>_<%=i%>" ),
                                        .value( inject_multi_block_single_ErrTag<%=index%>_<%=i%>));
    uvm_config_db#(uvm_event)::set(.cntxt(null),
                                          .inst_name( "*"),
                                          .field_name("injectAddrErrTag<%=index%>_<%=i%>"),
                                          .value(injectAddrErrTag<%=index%>_<%=i%>));

    <% } %>
    <% } %>
  <% }); %>
<%}%>
end

//Q-Channel
initial begin
   toggle_clk = new("toggle_clk");
   uvm_config_db#(uvm_event)::set(.cntxt( uvm_root::get()),
                                  .inst_name( "" ),
                                  .field_name( "toggle_clk" ),
                                  .value(toggle_clk));
   toggle_rst = new("toggle_rst");
   uvm_config_db#(uvm_event)::set(.cntxt( uvm_root::get()),
                                  .inst_name( "" ),
                                  .field_name( "toggle_rst" ),
                                  .value(toggle_rst));
end

//initial begin
//
//    <% var j = 0; %>
//    <% //obj.AddrMap.forEach(function(addr_range,i) { %>
//
//    <% //if (addr_range.HUT == 0) { %>
//            force tb_top.dut.<%=hier_path_dce_csr%>.DCEUGPRBLR<%=j%>_AddrLow_out = <%//="32'h" + ((addr_range.BaseAddr & 0xfffffffffff)>>>12).toString(16)%>;
//            force tb_top.dut.<%=hier_path_dce_csr%>.DCEUGPRBHR<%=j%>_AddrHigh_out = <%//="32'h" + ((addr_range.BaseAddr >>> 44) & 0xff).toString(16)%>;
//            force tb_top.dut.<%=hier_path_dce_csr%>.GPRAR<%=j%>_Size = <%//=addr_range.Size%>;
//            force tb_top.dut.<%=hier_path_dce_csr%>.GPRAR<%=j%>_DIGId = 'b0;
//            force tb_top.dut.<%=hier_path_dce_csr%>.GPRAR<%=j%>_Valid = 'b1;
//            force tb_top.dut.<%=hier_path_dce_csr%>.GPRAR<%=j%>_HUI = <%//=addr_range.HUI%>;
//            force tb_top.dut.<%=hier_path_dce_csr%>.GPRAR<%=j%>_HUT = <%//=addr_range.HUT%>;
//    <% //j = j + 1 ; %>
//    <%// } %> // if
//
//    <%// }) %> // forEach
//
//        force tb_top.dut.<%=hier_path_dce_csr%>.DCEUAMIGR_Valid_out = 'b1;
//        force tb_top.dut.<%=hier_path_dce_csr%>.DCEUAMIGR_AMIGS_out = 'b0;
//end
//

bit enable=1;
always @(posedge tb_clk) begin
    toggle_clk.wait_trigger();
    @(negedge tb_clk);
    $display("triggered toggle_clk_event @time: %0t",$time);
    enable = ~enable;
end

assign dut_clk = enable ? tb_clk : 0;

bit soft_rst_en=1;
always @(posedge tb_clk) begin
    toggle_rst.wait_trigger();
    @(negedge tb_clk);
    $display("treggered reset event @time: %0t",$time);
    soft_rst_en = ~soft_rst_en;
end

assign soft_rstn = soft_rst_en ? tb_rstn : 0;

<%=obj.instanceMap[obj.DutInfo.strRtlNamePrefix]%> dut(
   //SMI TX ports
<% for (var i = 0; i < obj.nSmiTx; i++) { %>
    .<%=obj.DceInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_valid    (m_smi<%=i%>_rx_vif.smi_msg_valid),
    .<%=obj.DceInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_ready    (m_smi<%=i%>_rx_vif.smi_msg_ready),
    .<%=obj.DceInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_ndp_len      (m_smi<%=i%>_rx_vif.smi_ndp_len),
    .<%=obj.DceInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_dp_present   (m_smi<%=i%>_rx_vif.smi_dp_present),
    .<%=obj.DceInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_targ_id      (m_smi<%=i%>_rx_vif.smi_targ_id),
    .<%=obj.DceInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_src_id       (m_smi<%=i%>_rx_vif.smi_src_id),
    .<%=obj.DceInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_id       (m_smi<%=i%>_rx_vif.smi_msg_id),
    .<%=obj.DceInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_type     (m_smi<%=i%>_rx_vif.smi_msg_type),

  <% if(obj.DceInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiUser >0) {%>
    .<%=obj.DceInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_user     (m_smi<%=i%>_rx_vif.smi_msg_user), 
  <% } %>
  <% if(obj.DceInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiTier >0) {%>
    .<%=obj.DceInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_tier     (m_smi<%=i%>_rx_vif.smi_msg_tier),  
  <% } %>
  <% if(obj.DceInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiSteer >0) {%>
    .<%=obj.DceInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_steer        (m_smi<%=i%>_rx_vif.smi_steer),  
  <% } %>
  <% if(obj.DceInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiPri >0) {%>
    .<%=obj.DceInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_pri      (m_smi<%=i%>_rx_vif.smi_msg_pri),  
  <% } %>
  <% if(obj.DceInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiMsgQos >0) {%>
    .<%=obj.DceInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_qos      (m_smi<%=i%>_rx_vif.smi_msg_qos), 
  <% } %>

    .<%=obj.DceInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_ndp          (m_smi<%=i%>_rx_vif.smi_ndp[<%=obj.DceInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiNDP-1%>:0]),
  <% if(obj.DceInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiErr >0) {%>
    .<%=obj.DceInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_err      (m_smi<%=i%>_rx_vif.smi_msg_err), 
  <% } %>
<% } %>

    //SMI RX ports
<% for (var i = 0; i < obj.nSmiRx; i++) { %>
    .<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_valid    (m_smi<%=i%>_tx_vif.smi_msg_valid),
    .<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_ready    (m_smi<%=i%>_tx_vif.smi_msg_ready),
    .<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_ndp_len      (m_smi<%=i%>_tx_vif.smi_ndp_len),
    .<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_dp_present   (m_smi<%=i%>_tx_vif.smi_dp_present),
    .<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_targ_id      (m_smi<%=i%>_tx_vif.smi_targ_id),
    .<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_src_id       (m_smi<%=i%>_tx_vif.smi_src_id),
    .<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_id       (m_smi<%=i%>_tx_vif.smi_msg_id),
    .<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_type     (m_smi<%=i%>_tx_vif.smi_msg_type),

  <% if(obj.DceInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiUser >0) {%>
    .<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_user     (m_smi<%=i%>_tx_vif.smi_msg_user), 
  <% } %>
  <% if(obj.DceInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiTier >0) {%>
    .<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_tier     (m_smi<%=i%>_tx_vif.smi_msg_tier),  
  <% } %>
  <% if(obj.DceInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiSteer >0) {%>
    .<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_steer        (m_smi<%=i%>_tx_vif.smi_steer),  
  <% } %>
  <% if(obj.DceInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiPri >0) {%>
    .<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_pri      (m_smi<%=i%>_tx_vif.smi_msg_pri),  
  <% } %>
  <% if(obj.DceInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiMsgQos >0) {%>
    .<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_qos      (m_smi<%=i%>_tx_vif.smi_msg_qos), 
  <% } %>

    .<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_ndp          (m_smi<%=i%>_tx_vif.smi_ndp[<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiNDP-1%>:0]),
    <% if(obj.DceInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiErr >0) {%>
    .<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_err      (m_smi<%=i%>_tx_vif.smi_msg_err),
    <%}
 } %>

    .<%=obj.DceInfo[obj.Id].interfaces.uIdInt.name%>my_f_unit_id    (addrMgrConst::get_dce_funitid(0)),
    .<%=obj.DceInfo[obj.Id].interfaces.uIdInt.name%>my_n_unit_id    (<%=obj.DceInfo[obj.Id].nUnitId%>),
    .<%=obj.DceInfo[obj.Id].interfaces.uIdInt.name%>my_csr_rpn      (<%=obj.DceInfo[obj.Id].rpn%>),
    .<%=obj.DceInfo[obj.Id].interfaces.uIdInt.name%>my_csr_nrri     (<%=obj.DceInfo[obj.Id].nrri%>),
    .<%=obj.DceInfo[obj.Id].interfaces.uSysDveIdInt.name%>f_unit_id  (addrMgrConst::get_dve_funitid(0)), 
    .<%=obj.DceInfo[obj.Id].interfaces.uSysDveIdInt.name%>connectivity (1), // From Ncore3.6, we are supposed to use DVE for sys event communication 
    .<%=obj.DceInfo[obj.Id].interfaces.uSysCaIdInt.name%>f_unit_id  (CACHING_AIU_FUNIT_IDS), 
    .<%=obj.DceInfo[obj.Id].interfaces.uSysCaIdInt.name%>connectivity  ({<%=obj.DceInfo[obj.Id].nCachingAgents%>{1'b1}}), 
    .<%=obj.DceInfo[obj.Id].interfaces.uSysCaNodeIdInt.name%>n_unit_id  (CACHING_NUNIT_IDS),
    .<%=obj.DceInfo[obj.Id].interfaces.uSysDmiIdInt.name%>f_unit_id (DMI_FUNIT_IDS),
    .<%=obj.DceInfo[obj.Id].interfaces.uSysDmiIdInt.name%>connectivity ($test$plusargs("disconnect_all_dmis") ? 0 : DceDmiConVec),
    .<%=obj.DceInfo[obj.Id].interfaces.uSysConnectedDmiIdInt.name%>f_unit_id (CONNECTED_DMI_FUNIT_ID),
    .<%=obj.DceInfo[obj.Id].interfaces.uSysConnectedDmiIdInt.name%>connectivity (DceDmiConVec),
    .<%=obj.DceInfo[obj.Id].interfaces.uSysConnectedCaIdInt.name%>f_unit_id (CACHING_AIU_FUNIT_IDS),
    .<%=obj.DceInfo[obj.Id].interfaces.uSysConnectedCaIdInt.name%>connectivity ({<%=obj.DceInfo[obj.Id].nCachingAgents%>{1'b1}}),
    .<%=obj.DceInfo[obj.Id].interfaces.uSysConnectedDmiRbOffsetInt.name%>f_unit_id (DMI_RBOffset), //This field is RBOffset but not Funit ID
    .<%=obj.DceInfo[obj.Id].interfaces.uSysConnectedDmiRbOffsetInt.name%>connectivity (DceDmiConVec),
    .<%=obj.DceInfo[obj.Id].interfaces.irqInt.name%>c               (),
    .<%=obj.DceInfo[obj.Id].interfaces.irqInt.name%>uc              (),
<%  if(obj.DceInfo[obj.Id].usePma) { %>
//Q-channel interface connection
    .<%=obj.DceInfo[obj.Id].interfaces.qInt.name%>ACTIVE             ( m_q_chnl_if.QACTIVE ),
    .<%=obj.DceInfo[obj.Id].interfaces.qInt.name%>DENY               ( m_q_chnl_if.QDENY   ),
    .<%=obj.DceInfo[obj.Id].interfaces.qInt.name%>REQn               ( m_q_chnl_if.QREQn   ),
    .<%=obj.DceInfo[obj.Id].interfaces.qInt.name%>ACCEPTn            ( m_q_chnl_if.QACCEPTn),
<% } %>
<%  if(obj.INHOUSE_APB_VIP && obj.testBench=="dce") { %>
// APB interface tie offs
    .<%=obj.DceInfo[obj.Id].interfaces.apbInt.name%>paddr        (apb_if.paddr[<%=obj.DceInfo[obj.Id].interfaces.apbInt.params.wAddr-1%>:0]),
    .<%=obj.DceInfo[obj.Id].interfaces.apbInt.name%>psel         (apb_if.psel),
    .<%=obj.DceInfo[obj.Id].interfaces.apbInt.name%>penable      (apb_if.penable),
    .<%=obj.DceInfo[obj.Id].interfaces.apbInt.name%>pwrite       (apb_if.pwrite),
    .<%=obj.DceInfo[obj.Id].interfaces.apbInt.name%>pwdata       (apb_if.pwdata[<%=obj.DceInfo[obj.Id].interfaces.apbInt.params.wData-1%>:0]),
    .<%=obj.DceInfo[obj.Id].interfaces.apbInt.name%>pready       (apb_if.pready),
    .<%=obj.DceInfo[obj.Id].interfaces.apbInt.name%>prdata       (apb_if.prdata),
    .<%=obj.DceInfo[obj.Id].interfaces.apbInt.name%>pslverr      (apb_if.pslverr[<%=obj.DceInfo[obj.Id].interfaces.apbInt.params.wPSlverr-1%>:0]),
<%  if(obj.DceInfo[obj.Id].interfaces.apbInt.params.wProt !== 0) { %>
    .<%=obj.DceInfo[obj.Id].interfaces.apbInt.name%>pprot        (apb_if.pprot),
<% } %>
<%  if(obj.DceInfo[obj.Id].interfaces.apbInt.params.wStrb !== 0) { %>
    .<%=obj.DceInfo[obj.Id].interfaces.apbInt.name%>pstrb        (apb_if.pstrb),
<% } %>
<% } %>
      
<% if(obj.useResiliency) { %>
    //TODO resiliency if ******************************************
<% if(obj.DceInfo[obj.Id].ResilienceInfo.enableUnitDuplication) { %>
    .<%=obj.DceInfo[obj.Id].interfaces.checkClkInt.name%>clk         (dut_clk),
//    .<%=obj.DceInfo[obj.Id].interfaces.checkClkInt.name%>reset_n     (soft_rstn),    
    .<%=obj.DceInfo[obj.Id].interfaces.checkClkInt.name%>test_en     ('h0),
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

    .<%=obj.DceInfo[obj.Id].interfaces.clkInt.name%>clk         (dut_clk),
    .<%=obj.DceInfo[obj.Id].interfaces.clkInt.name%>reset_n     (soft_rstn),
    .<%=obj.DceInfo[obj.Id].interfaces.clkInt.name%>test_en     ('h0)
    //.fault_late_clk                                              (dut_clk)

);

//TODO FIXME Remove when smi_msg_err is implemented. 
<% for (var i = 0; i < obj.nSmiRx; i++) { %>
     assign m_smi<%=i%>_tx_vif.smi_dp_ready = 'h0;
     assign m_smi<%=i%>_tx_vif.smi_dp_valid = 'h0;
     assign m_smi<%=i%>_tx_vif.smi_msg_err  = 'h0;
<% } %>

<% for (var i = 0; i < obj.nSmiTx; i++) { %>
     assign m_smi<%=i%>_rx_vif.smi_dp_ready = 'h0;
     assign m_smi<%=i%>_rx_vif.smi_dp_valid = 'h0;
     assign m_smi<%=i%>_rx_vif.smi_msg_err  = 'h0;
<% } %>

//cmd req interface (dce_dm_0.v)
assign probe_vif.cmd_req_vld           = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_req_valid_i; 
assign probe_vif.cmd_req_rdy           = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_req_ready_o; 
assign probe_vif.cmd_req_addr          = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_req_addr_i; 
assign probe_vif.cmd_req_ns            = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_req_ns_i; 
assign probe_vif.cmd_req_type          = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_req_type_i;
assign probe_vif.cmd_req_iid           = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_req_iid_i;
assign probe_vif.cmd_req_sid           = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_req_sid_i;
assign probe_vif.cmd_req_att_vec       = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_req_att_vec_i;
assign probe_vif.cmd_req_wakeup        = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_req_wakeup_i;
assign probe_vif.cmd_req_msg_id        = tb_top.dut.<%=hier_path_dce_sbcmdreqfifo%>.pop_message_id;
assign probe_vif.cmd_req1_busy_vec     = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_req1_busy_vec_i;
assign probe_vif.cmd_req1_filter_num   = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_req1_filter_num_o;
assign probe_vif.cmd_req1_alloc        = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_req1_alloc_i;
assign probe_vif.cmd_req1_cancel       = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_req1_cancel_i;

//upd req interface (dce_dm_0.v)
assign probe_vif.upd_req_vld           = tb_top.dut.dce_func_unit.dce_dm.dm_upd_req_valid_i;
assign probe_vif.upd_req_rdy           = tb_top.dut.dce_func_unit.dce_dm.dm_upd_req_ready_o;
assign probe_vif.upd_req_addr          = tb_top.dut.dce_func_unit.dce_dm.dm_upd_req_addr_i;
assign probe_vif.upd_req_ns            = tb_top.dut.dce_func_unit.dce_dm.dm_upd_req_ns_i;
assign probe_vif.upd_req_iid           = tb_top.dut.dce_func_unit.dce_dm.dm_upd_req_iid_i;
assign probe_vif.upd_req_status        = tb_top.dut.dce_func_unit.dce_dm.dm_upd_status_o;
assign probe_vif.upd_req_status_vld    = tb_top.dut.dce_func_unit.dce_dm.dm_upd_status_valid_o;

//dir rsp interface
assign probe_vif.cmd_rsp_rdy         = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_rsp_ready_i;
assign probe_vif.cmd_rsp_vld         = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_rsp_valid_o;
assign probe_vif.cmd_rsp_att_vec     = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_rsp_att_vec_o;
assign probe_vif.cmd_rsp_way_vec     = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_rsp_way_vec_o;
assign probe_vif.cmd_rsp_owner_val   = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_rsp_owner_val_o;
assign probe_vif.cmd_rsp_owner_num   = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_rsp_owner_num_o;
assign probe_vif.cmd_rsp_sharer_vec  = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_rsp_sharer_vec_o;
assign probe_vif.cmd_rsp_vbhit_sfvec = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_rsp_vb_hits_o; //this is wr_required for each snoop-filter.
assign probe_vif.cmd_rsp_wr_required = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_rsp_wr_required_o;
assign probe_vif.cmd_rsp_error       = tb_top.dut.dce_func_unit.dce_dm.dm_cmd_rsp_error_o;
  
//recall interface
assign probe_vif.recall_vld        = tb_top.dut.dce_func_unit.dce_dm.dm_recall_valid_o;
assign probe_vif.recall_rdy        = tb_top.dut.dce_func_unit.dce_dm.dm_recall_ready_i;
assign probe_vif.recall_addr       = tb_top.dut.dce_func_unit.dce_dm.dm_recall_addr_o;
assign probe_vif.recall_ns         = tb_top.dut.dce_func_unit.dce_dm.dm_recall_ns_o;
assign probe_vif.recall_sharer_vec = tb_top.dut.dce_func_unit.dce_dm.dm_recall_sharer_vec_o;
assign probe_vif.recall_owner_val  = tb_top.dut.dce_func_unit.dce_dm.dm_recall_owner_val_o;
assign probe_vif.recall_owner_num  = tb_top.dut.dce_func_unit.dce_dm.dm_recall_owner_num_o;
assign probe_vif.recall_att_vec     = tb_top.dut.dce_func_unit.dce_tm.att_recall_alloc;
  
//write interface
assign probe_vif.write_rdy         = tb_top.dut.dce_func_unit.dce_dm.dm_write_ready_o;
assign probe_vif.write_vld         = tb_top.dut.dce_func_unit.dce_dm.dm_write_valid_i;
assign probe_vif.write_addr        = tb_top.dut.dce_func_unit.dce_dm.dm_write_addr_i;
assign probe_vif.write_ns          = tb_top.dut.dce_func_unit.dce_dm.dm_write_ns_i;
assign probe_vif.write_way_vec     = tb_top.dut.dce_func_unit.dce_dm.dm_write_way_vec_i;
assign probe_vif.write_owner_val   = tb_top.dut.dce_func_unit.dce_dm.dm_write_owner_val_i;
assign probe_vif.write_owner_num   = tb_top.dut.dce_func_unit.dce_dm.dm_write_owner_num_i;
assign probe_vif.write_sharer_vec  = tb_top.dut.dce_func_unit.dce_dm.dm_write_sharer_vec_i;
assign probe_vif.write_change_vec  = tb_top.dut.dce_func_unit.dce_dm.dm_write_change_vec_i;

//retry interface
assign probe_vif.retry_rdy         = tb_top.dut.dce_func_unit.dce_dm.dm_rtr_ready_i;
assign probe_vif.retry_vld         = tb_top.dut.dce_func_unit.dce_dm.dm_rtr_valid_o;
assign probe_vif.retry_att_vec     = tb_top.dut.dce_func_unit.dce_dm.dm_rtr_att_vec_o;
assign probe_vif.retry_filter_vec  = tb_top.dut.dce_func_unit.dce_dm.dm_rtr_filter_vec_o;
assign probe_vif.retry_way_mask    = tb_top.dut.dce_func_unit.dce_dm.dm_rtr_way_mask_o;

assign probe_vif.dm_mem_init       = tb_top.dut.dce_func_unit.dce_dm.t_init_valid;
assign probe_vif.dm_flush          = tb_top.dut.dce_func_unit.dce_dm.q_flush;

<% for (var i = 0; i < attvec_width; i++) { %>
   assign probe_vif.attvld_vec[<%=i%>] = tb_top.dut.dce_func_unit.dce_tm.ATT_ENTRIES[<%=i%>].att_entry.att_entry_addr_comp_valid;
<% } %>

//these RTL signals need to be probed for QOS testing
assign probe_vif.sb_cmdrsp_vld    = tb_top.dut.<%=hier_path_dce_sb%>.f0_cmd_rsp_valid;
assign probe_vif.sb_cmdrsp_rdy    = tb_top.dut.<%=hier_path_dce_sb%>.f0_cmd_rsp_ready;
assign probe_vif.sb_cmdrsp_tgtid  = tb_top.dut.<%=hier_path_dce_sb%>.f0_cmd_rsp_target_id;
assign probe_vif.sb_cmdrsp_rmsgid = tb_top.dut.<%=hier_path_dce_sb%>.f0_cmd_rsp_r_message_id;

//These RTL signals are grabbed to updated snoop enable register in TB
assign probe_vif.sb_sysrsp_vld    = tb_top.dut.<%=hier_path_dce_cmux%>.sys_rsp_tx_valid;
assign probe_vif.sb_sysrsp_rdy    = tb_top.dut.<%=hier_path_dce_cmux%>.sys_rsp_tx_ready;
assign probe_vif.sb_sysrsp_tgtid  = tb_top.dut.<%=hier_path_dce_cmux%>.sys_rsp_tx_target_id;

always @(posedge dut_clk) begin

  event_in_req_dly = tb_top.dut.dce_func_unit.event_in_req;
  event_in_ack_dly = tb_top.dut.dce_func_unit.event_in_ack;
  event_err_valid_dly  = tb_top.dut.dce_func_unit.csr_sys_evt_sender_err_vld;

end

assign probe_vif.event_in_req       = tb_top.dut.dce_func_unit.event_in_req;
assign probe_vif.event_in_ack       = tb_top.dut.dce_func_unit.event_in_ack;
assign probe_vif.event_err_valid    = tb_top.dut.dce_func_unit.csr_sys_evt_sender_err_vld;

assign probe_vif.store_pass         = tb_top.dut.dce_func_unit.dce_tm.dm_rsp_exmon_store_pass;
assign probe_vif.prot_timeout_val   = tb_top.dut.dce_func_unit.u_sys_evt_coh_concerto.csr_protocol_timeout_value;
assign probe_vif.prot_timeout_err   = tb_top.dut.dce_func_unit.u_sys_evt_coh_concerto.u_sys_evt_coh_wrapper.u_sys_evt_sender.protocol_timeout;

//signals needed to grab output of conc_mux for QOS testing -CONC-7215
//due to cmdreq backpressure, SMI_Time != CMux_Time
assign probe_vif.cmux_cmdreq_vld  = tb_top.dut.<%=hier_path_dce_cmux%>.cmd_req_valid;
assign probe_vif.cmux_cmdreq_rdy  = tb_top.dut.<%=hier_path_dce_cmux%>.cmd_req_ready;
assign probe_vif.cmux_cmdreq_addr = tb_top.dut.<%=hier_path_dce_cmux%>.cmd_req_addr;
assign probe_vif.cmux_cmdreq_ns   = tb_top.dut.<%=hier_path_dce_cmux%>.cmd_req_ns;
assign probe_vif.cmux_cmdreq_iid  = tb_top.dut.<%=hier_path_dce_cmux%>.cmd_req_initiator_id;
assign probe_vif.cmux_cmdreq_cm_type = tb_top.dut.<%=hier_path_dce_cmux%>.cmd_req_cm_type;
assign probe_vif.cmux_cmdreq_msg_id  = tb_top.dut.<%=hier_path_dce_cmux%>.cmd_req_message_id;

assign probe_vif.arb_cmdreq_vld  = tb_top.dut.<%=hier_path_dce_sb%>.cmd_skid_buffer.req_in_valid;
assign probe_vif.arb_cmdreq_rdy  = tb_top.dut.<%=hier_path_dce_sb%>.cmd_skid_buffer.req_in_ready;
assign probe_vif.arb_cmdreq_addr = tb_top.dut.<%=hier_path_dce_sb%>.cmd_skid_buffer.req_in_addr;
assign probe_vif.arb_cmdreq_ns   = tb_top.dut.<%=hier_path_dce_sb%>.cmd_skid_buffer.req_in_ns;
assign probe_vif.arb_cmdreq_iid  = tb_top.dut.<%=hier_path_dce_sb%>.cmd_skid_buffer.req_in_initiator_id;
assign probe_vif.arb_cmdreq_cm_type = tb_top.dut.<%=hier_path_dce_sb%>.cmd_skid_buffer.req_in_cm_type;
assign probe_vif.arb_cmdreq_msg_id  = tb_top.dut.<%=hier_path_dce_sb%>.cmd_skid_buffer.req_in_message_id;
///perf counter :stall_if to dut connection 
assign <%=obj.BlockId%>_sb_stall_if.clk = tb_clk;
assign <%=obj.BlockId%>_sb_stall_if.rst_n = tb_rstn;
// SMI TX
<%for (var i = 0; i < obj.nSmiTx; i++) { %>
<%  if (obj.DceInfo[obj.Id].interfaces.smiTxInt[i].params.nSmiDPvc) { %>   
assign <%=obj.BlockId%>_sb_stall_if.smi_tx<%=i%>_valid = dut.<%=obj.DceInfo[obj.Id].interfaces.smiTxInt[i].name%>dp_valid;       
assign <%=obj.BlockId%>_sb_stall_if.smi_tx<%=i%>_ready = dut.<%=obj.DceInfo[obj.Id].interfaces.smiTxInt[i].name%>dp_ready;     
<% } else { %>
assign <%=obj.BlockId%>_sb_stall_if.smi_tx<%=i%>_valid = dut.<%=obj.DceInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_valid;       
assign <%=obj.BlockId%>_sb_stall_if.smi_tx<%=i%>_ready = dut.<%=obj.DceInfo[obj.Id].interfaces.smiTxInt[i].name%>ndp_msg_ready;     
<% } %> 
<% } %>
// SMI RX
<%for (var i = 0; i < obj.nSmiRx; i++) { %>
  <%  if (obj.DceInfo[obj.Id].interfaces.smiRxInt[i].params.nSmiDPvc) { %>  
assign <%=obj.BlockId%>_sb_stall_if.smi_rx<%=i%>_valid = dut.<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>dp_valid;
assign <%=obj.BlockId%>_sb_stall_if.smi_rx<%=i%>_ready = dut.<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>dp_ready;
assign (supply0, supply1) dut.<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].named%>p_valid = m_smi<%=i%>_tx_vif.force_smi_msg_valid;
assign (supply0, supply1) dut.<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>dp_ready = m_smi<%=i%>_tx_vif.force_smi_msg_ready;
<% } else { %>
assign <%=obj.BlockId%>_sb_stall_if.smi_rx<%=i%>_valid = dut.<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_valid;
assign <%=obj.BlockId%>_sb_stall_if.smi_rx<%=i%>_ready = dut.<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_ready;
assign (supply0, supply1) dut.<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_valid = m_smi<%=i%>_tx_vif.force_smi_msg_valid;
assign (supply0, supply1) dut.<%=obj.DceInfo[obj.Id].interfaces.smiRxInt[i].name%>ndp_msg_ready = m_smi<%=i%>_tx_vif.force_smi_msg_ready;
<% } %> 
<% } %>
<%for (var i = 0; i < obj.nPerfCounters; i++) { %>
assign <%=obj.BlockId%>_sb_stall_if.cnt_reg_capture[<%=i%>].cnt_v =  dut.<%=hier_path_dce_csr%>.DCECNTVR<%=i%>_CountVal_out ;  
assign <%=obj.BlockId%>_sb_stall_if.cnt_reg_capture[<%=i%>].cnt_v_str =  dut.<%=hier_path_dce_csr%>.DCECNTSR<%=i%>_CountSatVal_out;   
<% } %>
<% if(obj.testBench == 'dce') { %>
`ifndef VCS
if (addrMgrConst::get_highest_qos() != 0) begin
    assign probe_vif.sb_starv_mode    = tb_top.dut.<%=hier_path_dce_sb%>.cmd_skid_buffer.starv_mode;
end
`else // `ifndef VCS
<%if(obj.AiuInfo[0].QosInfo && (obj.AiuInfo[0].QosInfo.qosMap.length > 0)){%>
     assign probe_vif.sb_starv_mode   = (addrMgrConst::get_highest_qos() != 0) ? tb_top.dut.<%=hier_path_dce_sb%>.cmd_skid_buffer.starv_mode : probe_vif.sb_starv_mode ;
<% } %>
`endif // `ifndef VCS ... `else ... 
<% } else {%>
if (addrMgrConst::get_highest_qos() != 0) begin
    assign probe_vif.sb_starv_mode    = tb_top.dut.<%=hier_path_dce_sb%>.cmd_skid_buffer.starv_mode;
end
<% } %>
//assign probe_vif.sb_starv_mode    = tb_top.dut.<%=hier_path_dce_sb%>.cmd_skid_buffer.starv_mode
//Test call
initial begin
  $timeformat(-9, 3," ns",8);
  `ifdef DUMP_ON if ($test$plusargs("en_dump")) begin 
<%  if(obj.SYS_CDNS_ACE_VIP) { %> 
       $shm_open("waves.shm");
       $shm_probe("AS");
<%  } else { %>
       $vcdpluson;
<%  } %>
     end
  `endif
`ifdef VCS
  `ifdef FSDB_DUMP_ON if ($test$plusargs("en_dump")) begin
     $fsdbDumpfile("dce.fsdb");
     $fsdbDumpvars;
   end
  `endif
`endif
  run_test();
  $finish;
end

<% if(obj.useResiliency) { %>
 fault_injector_checker fault_inj_check(dut_clk, soft_rstn);
 initial begin
<% if(obj.testBench == 'dce') { %>
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

//-----------------------------------------------------------------------------
// Generate clocks and reset
//-----------------------------------------------------------------------------
clk_rst_gen cr_gen(.clk_fr(fr_clk), .clk_tb(tb_clk), .rst(tb_rstn));


//HS: Commented out below code since we are now using the clk_rst_gen module.
//Delete later
////rst logic
//initial begin
//  tb_rst <= 0;
//  #1ns;
//  tb_rst <= 0;
//  repeat (2)
//    @(posedge tb_clk);
//
//  #1ns;
//  tb_rst <= 0;
//  repeat (10)
//    @(posedge tb_clk);
//  #1ns;
//  tb_rst <= 1;
//end
//
////Clock logic
//initial begin
//  tb_clk <= 0;
//  forever
//    #5ns tb_clk <= ~tb_clk;
//end


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
<%  if(obj.DceInfo[obj.Id].usePma) { %>
assert_clk_idle_when_pma_asserted : assert property (
    @(posedge tb_clk) disable iff (!soft_rstn)
    (!m_q_chnl_if.QREQn && !m_q_chnl_if.QACCEPTn ) |-> !dut_clk
    ) else assert_error("ERROR", "Dut clock is not stable low when RTL entered into PMA");
<% } %>

endmodule: tb_top

