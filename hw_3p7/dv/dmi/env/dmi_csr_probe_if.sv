
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------

/**
 * Abstract:
 * Defines an interface that provides access to a internal signal of DUT .This
 */

`ifndef GUARD_DMI_CSR_PROBE_IF_SV
`define GUARD_DMI_CSR_PROBE_IF_SV

interface dmi_csr_probe_if (input clk,input resetn);

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  logic IRQ_C;
  logic IRQ_UC;
  logic [31:0] single_bit_count0;
  logic [31:0] single_bit_count1;

  logic [31:0] double_bit_count0;
  logic [31:0] double_bit_count1;
  logic        en_aw_stall,en_w_stall,en_b_stall,en_r_stall;
  logic        inject_wbuffer0_single_next;
  logic        inject_wbuffer0_double_next;
  logic        inject_wbuffer0_single_double_multi_blk_next;
  logic        inject_wbuffer0_double_multi_blk_next;
  logic        inject_wbuffer0_single_multi_blk_next;
  logic        inject_wbuffer0_addr_next;

  logic        inject_wbuffer1_single_next;
  logic        inject_wbuffer1_double_next;
  logic        inject_wbuffer1_single_double_multi_blk_next;
  logic        inject_wbuffer1_double_multi_blk_next;
  logic        inject_wbuffer1_single_multi_blk_next;
  logic        inject_wbuffer1_addr_next;

  localparam ADDR_WIDTH_WBUF  = $clog2(((2**(<%=obj.wCacheLineOffset%>)*8)/ <%=obj.DmiInfo[obj.Id].wData%>)*( <%=obj.DmiInfo[obj.Id].cmpInfo.nDceRbEntries%>))-1;

  logic [ADDR_WIDTH_WBUF-1:0]  wbuffer0_addr;
  logic [ADDR_WIDTH_WBUF-1:0]  wbuffer1_addr;

<% if (obj.useResiliency) { %>
  logic fault_mission_fault;
  logic fault_latent_fault;
  logic [9:0]  cerr_threshold;
  logic [15:0] cerr_counter;
  logic        cerr_over_thres_fault;
<% } %>
<% if (obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].fnMemType == "SRAM") { %>
  logic inject_mrd_data_single_next;
  logic inject_mrd_data_double_next;
  logic inject_mrd_addr_next;
  logic [<%=obj.BlockId%>_smi_agent_pkg::WSMIADDR-1:0] mrd_error_injected_addr;
  logic mrd_sram_init_done;
<% } %>
<% if (obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].fnMemType == "SRAM") { %>
  logic inject_cmd_data_single_next;
  logic inject_cmd_data_double_next;
  logic inject_cmd_addr_next;
  logic [<%=obj.BlockId%>_smi_agent_pkg::WSMIADDR-1:0] cmd_error_injected_addr;
  logic cmd_sram_init_done;
<% } %>
<% if(obj.useCmc) { %>
  <%for( var i=0;i<obj.DmiInfo[obj.Id].ccpParams.nTagBanks;i++){%>
  logic        inject_tag_single_next<%=i%>;
  logic        inject_tag_double_next<%=i%>;
  logic        inject_tag_single_double_multi_blk_next<%=i%>;
  logic        inject_tag_double_multi_blk_next<%=i%>;
  logic        inject_tag_single_multi_blk_next<%=i%>;
  logic        inject_tag_addr_next<%=i%>; 
  <% } %>
  <%for( var i=0;i<obj.DmiInfo[obj.Id].ccpParams.nDataBanks;i++){%>
  logic        inject_data_single_next<%=i%>;
  logic        inject_data_double_next<%=i%>;
  logic        inject_data_single_double_multi_blk_next<%=i%>;
  logic        inject_data_double_multi_blk_next<%=i%>;
  logic        inject_data_single_multi_blk_next<%=i%>;
  logic        inject_data_addr_next<%=i%>; 
  <% } %>
  <%if(obj.DmiInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
  logic[31:0] plru_single_error_count;
  logic[31:0] plru_double_error_count;
  logic[31:0] plru_addr_error_count;
  <% } %>
<% } %>

  int rtt_size,wtt_size;
  int rtt_size_p[17], wtt_size_p[17];
  bit check_valid;
  bit check_irqc;
  bit check_irquc;
  int irq_uc_count;
  logic TransActv;
  logic AllocActv;
  logic EvictActv;
`ifdef ERROR_TEST
<%if(obj.DmiInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
  //Note: This is specific to configuration with 1 PLRU memory instance, to test more than one instance, loop this code per instance
  assign plru_single_error_count = tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.rpMem[0].rtlPrefixString%>.internal_mem_inst.SINGLE_ERROR_COUNT[31:0];
  assign plru_double_error_count = tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.rpMem[0].rtlPrefixString%>.internal_mem_inst.DOUBLE_ERROR_COUNT[31:0];
  assign plru_addr_error_count   = tb_top.dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.rpMem[0].rtlPrefixString%>.internal_mem_inst.ADDR_ERROR_COUNT[31:0];
<% } %>
<% if (typeof obj.DmiInfo[obj.Id].MemoryGeneration.wrDataMem !== 'undefined') { %>
<%   if (obj.DmiInfo[obj.Id].MemoryGeneration.wrDataMem[0].MemType != "SYNOPSYS") { %>
  assign inject_wbuffer0_single_next = tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst0.INJECT_SINGLE_NEXT;
  assign inject_wbuffer0_double_next = tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst0.INJECT_DOUBLE_NEXT;
  assign inject_wbuffer0_single_double_multi_blk_next = tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst0.INJECT_SINGLE_DOUBLE_MULTI_BLK_NEXT;
  assign inject_wbuffer0_double_multi_blk_next = tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst0.INJECT_DOUBLE_MULTI_BLK_NEXT;
  assign inject_wbuffer0_single_multi_blk_next = tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst0.INJECT_SINGLE_MULTI_BLK_NEXT;
  assign inject_wbuffer0_addr_next = tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst0.INJECT_ADDR_NEXT;

  assign inject_wbuffer1_single_next = tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst1.INJECT_SINGLE_NEXT;
  assign inject_wbuffer1_double_next = tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst1.INJECT_DOUBLE_NEXT;
  assign inject_wbuffer1_single_double_multi_blk_next = tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst1.INJECT_SINGLE_DOUBLE_MULTI_BLK_NEXT;
  assign inject_wbuffer1_double_multi_blk_next = tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst1.INJECT_DOUBLE_MULTI_BLK_NEXT;
  assign inject_wbuffer1_single_multi_blk_next = tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst1.INJECT_SINGLE_MULTI_BLK_NEXT;
  assign inject_wbuffer1_addr_next = tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst1.INJECT_ADDR_NEXT;

  assign wbuffer0_addr = tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst0.address[ADDR_WIDTH_WBUF-1:0];
  assign wbuffer1_addr = tb_top.dut.dmi_unit.dmi_protocol_control.c_write_buffer.data_fifo.mem_inst.internal_mem_inst1.address[ADDR_WIDTH_WBUF-1:0];
<% } } %>

<% if (obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].fnMemType == "SRAM") { %>
  assign inject_mrd_data_single_next = dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_SINGLE_NEXT;
  assign inject_mrd_data_double_next = dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_DOUBLE_NEXT;
  assign inject_mrd_addr_next        = dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_ADDR_NEXT;
  assign mrd_error_injected_addr     = dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.MrdSkidBufMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.ADDRESS;
  assign mrd_sram_init_done          = dut.MRDReqSbMem0.external_mem_inst.internal_mem_inst.all_entries_init;
<% } %>
<% if (obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].fnMemType == "SRAM") { %>
  assign inject_cmd_data_single_next = dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_SINGLE_NEXT;
  assign inject_cmd_data_double_next = dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_DOUBLE_NEXT;
  assign inject_cmd_addr_next        = dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.INJECT_ADDR_NEXT;
  assign cmd_error_injected_addr     = dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.CmdSkidBufMem[0].rtlPrefixString%>.external_mem_inst.internal_mem_inst.ADDRESS;
  assign cmd_sram_init_done          = dut.CMDReqSbMem0.external_mem_inst.internal_mem_inst.all_entries_init;
<% } %>
<% if(obj.useCmc) { %>
  <%for( var i=0;i<obj.DmiInfo[obj.Id].ccpParams.nTagBanks;i++){%>
  <%  if (obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].MemType != "SYNOPSYS") { %>
  assign inject_tag_single_next<%=i%> = dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_SINGLE_NEXT;
  assign inject_tag_double_next<%=i%> = dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_DOUBLE_NEXT;
  assign inject_tag_single_double_multi_blk_next<%=i%> = dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_SINGLE_DOUBLE_MULTI_BLK_NEXT;
  assign inject_tag_double_multi_blk_next<%=i%> = dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_DOUBLE_MULTI_BLK_NEXT;
  assign inject_tag_single_multi_blk_next<%=i%> = dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_SINGLE_MULTI_BLK_NEXT;
  assign inject_tag_addr_next<%=i%> = dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_ADDR_NEXT;
  <% } %>
  <% } %>
  <%for( var i=0;i<obj.DmiInfo[obj.Id].ccpParams.nDataBanks;i++){%>
  <%  if (obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].MemType != "SYNOPSYS") { %>
  assign inject_data_single_next<%=i%> = dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_SINGLE_NEXT;
  assign inject_data_double_next<%=i%> = dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_DOUBLE_NEXT;
  assign inject_data_single_double_multi_blk_next<%=i%> = dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_SINGLE_DOUBLE_MULTI_BLK_NEXT;
  assign inject_data_double_multi_blk_next<%=i%> = dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_DOUBLE_MULTI_BLK_NEXT;
  assign inject_data_single_multi_blk_next<%=i%> = dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_SINGLE_MULTI_BLK_NEXT;
  assign inject_data_addr_next<%=i%> = dut.<%=obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[i].rtlPrefixString%>.internal_mem_inst.INJECT_ADDR_NEXT;
  <% } %>
  <% } %>
<% } %>
`endif

logic cmd_skid_buffer_empty;
logic mrd_skid_buffer_empty;
logic mrd_resp_valid;
logic nc_cmd_resp_valid;
logic str_rsp_pending;
logic dtr_rsp_pending;
logic nc_write_active;
logic c_write_active;
logic rtt_trans_active;
logic wtt_trans_active;


assign cmd_skid_buffer_empty = tb_top.dut.dmi_unit.dmi_protocol_control.cmd_skid_buffer_empty;
assign mrd_skid_buffer_empty = tb_top.dut.dmi_unit.dmi_protocol_control.mrd_skid_buffer_empty;
assign mrd_resp_valid = tb_top.dut.dmi_unit.dmi_protocol_control.mrd_resp_valid;
assign nc_cmd_resp_valid = tb_top.dut.dmi_unit.dmi_protocol_control.nc_cmd_resp_valid;
assign str_rsp_pending = tb_top.dut.dmi_unit.dmi_protocol_control.str_rsp_pending;
assign dtr_rsp_pending = tb_top.dut.dmi_unit.dmi_protocol_control.dtr_rsp_pending;
assign nc_write_active = tb_top.dut.dmi_unit.dmi_protocol_control.nc_write_active;
assign c_write_active = tb_top.dut.dmi_unit.dmi_protocol_control.c_write_active;
assign rtt_trans_active = tb_top.dut.dmi_unit.dmi_transaction_control.rtt.trans_active;
assign wtt_trans_active = tb_top.dut.dmi_unit.dmi_transaction_control.wtt.trans_active;

logic DMIUCESR_ErrVld;
logic DMIUCESR_ErrCountOverflow;
logic[7:0] DMIUCESR_ErrCount;
logic[4:0] DMIUCESR_ErrType;
logic[15:0] DMIUCESR_ErrInfo;

assign DMIUCESR_ErrVld = tb_top.dut.dmi_unit.csr.DMIUCESR_ErrVld_out;
assign DMIUCESR_ErrCountOverflow = tb_top.dut.dmi_unit.csr.DMIUCESR_ErrCountOverflow_out;
assign DMIUCESR_ErrCount = tb_top.dut.dmi_unit.csr.DMIUCESR_ErrCount_out;
assign DMIUCESR_ErrType = tb_top.dut.dmi_unit.csr.DMIUCESR_ErrType_out;
assign DMIUCESR_ErrInfo = tb_top.dut.dmi_unit.csr.DMIUCESR_ErrInfo_out;

logic DMIUUEDR_MemErrDetEn; //just used to check mission fault for uncorr memory error injection
logic DMIUUESR_ErrVld;
logic uncorr_err_injected;
logic dmi_corr_uncorr_flag;
logic[4:0] DMIUUESR_ErrType;
logic[15:0] DMIUUESR_ErrInfo;

<% if(obj.useCmc) { %>
<% if ((obj.DmiInfo[obj.Id].ccpParams.TagErrInfo === "SECDED") || (obj.DmiInfo[obj.Id].ccpParams.DataErrInfo === "SECDED") || (obj.DmiInfo[obj.Id].ccpParams.TagErrInfo === "PARITYENTRY") || (obj.DmiInfo[obj.Id].ccpParams.DataErrInfo === "PARITYENTRY")) { %>
assign DMIUUEDR_MemErrDetEn = tb_top.dut.dmi_unit.csr.DMIUUEDR_MemErrDetEn_out;
<% } %>
<% } else if ((obj.DmiInfo[obj.Id].fnErrDetectCorrect == "SECDED") || (obj.DmiInfo[obj.Id].fnErrDetectCorrect == "PARITYENTRY")) { %>
assign DMIUUEDR_MemErrDetEn = tb_top.dut.dmi_unit.csr.DMIUUEDR_MemErrDetEn_out;
<% } %>
assign DMIUUESR_ErrVld = tb_top.dut.dmi_unit.csr.DMIUUESR_ErrVld_out;
assign DMIUUESR_ErrType = tb_top.dut.dmi_unit.csr.DMIUUESR_ErrType_out;
assign DMIUUESR_ErrInfo = tb_top.dut.dmi_unit.csr.DMIUUESR_ErrInfo_out;

//last two ports are data networks
logic <%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>ndp_vld;
logic <%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>ndp_rdy;
logic <%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>dp_vld;
logic <%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>dp_rdy;
logic <%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>dp_lst;

logic <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>ndp_vld;
logic <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>ndp_rdy;
logic <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>dp_vld;
logic <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>dp_rdy;
logic <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>dp_lst;

assign <%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>ndp_vld = tb_top.dut.<%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>ndp_msg_valid;
assign <%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>ndp_rdy = tb_top.dut.<%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>ndp_msg_ready;
assign <%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>dp_vld  = tb_top.dut.<%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>dp_valid;
assign <%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>dp_rdy  = tb_top.dut.<%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>dp_ready;
assign <%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>dp_lst  = tb_top.dut.<%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>dp_last;

assign <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>ndp_vld = tb_top.dut.<%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>ndp_msg_valid;
assign <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>ndp_rdy = tb_top.dut.<%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>ndp_msg_ready;
assign <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>dp_vld  = tb_top.dut.<%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>dp_valid;
assign <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>dp_rdy  = tb_top.dut.<%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>dp_ready;
assign <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>dp_lst  = tb_top.dut.<%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>dp_last;

bit ndp_dp_match;
bit <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>first_pass = 0;
int <%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>ndp_count = 0;
int <%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>dp_count = 0;
int <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>ndp_count = 0;
int <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>dp_count = 0;

always @(negedge clk) begin
    if(<%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>ndp_vld && <%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>ndp_rdy) begin
        <%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>ndp_count++;
    end
    if(<%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>ndp_vld && <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>ndp_rdy) begin
        <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>ndp_count++;
    end
end

always @(negedge clk) begin
   if(<%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>dp_vld && <%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>dp_rdy) begin
        if(!<%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>first_pass) begin 
            <%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>dp_count++;
            <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>first_pass = 1;
        end
        if(<%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>dp_lst) <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>first_pass = 0;
   end
   if(<%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>dp_vld && <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>dp_rdy) begin
        if(!<%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>first_pass) begin 
            <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>dp_count++;
            <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>first_pass = 1;
        end
        if(<%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>dp_lst) <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>first_pass = 0;
   end
   #1;
   if((<%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>ndp_count != <%=obj.DmiInfo[obj.Id].smiPortParams.tx[obj.DmiInfo[obj.Id].smiPortParams.tx.length-1].name%>dp_count) || (<%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>ndp_count != <%=obj.DmiInfo[obj.Id].smiPortParams.rx[obj.DmiInfo[obj.Id].smiPortParams.rx.length-1].name%>dp_count)) ndp_dp_match = 0;             //scoreboard doesnt recieve ndp or dp packet until both first data beat and header is recieved. ndp_dp_match represents if there is a data beat waiting for header or header waiting for first data beat.
   else ndp_dp_match = 1;                                                                                                       
end

always @(posedge clk) begin
  if (DMIUUEDR_MemErrDetEn === 1 && DMIUUESR_ErrVld === 1) begin
    uncorr_err_injected = 1;
  end
end
assign dmi_corr_uncorr_flag = tb_top.dmi_corr_uncorr_flag;
<% if (obj.testBench != "fsys") { %>
always @(posedge clk) begin
  if (tb_top.dut.dmi_unit.irq_c ==1 ) begin
    check_irqc =1;
  end
end

always @(posedge clk) begin
  if (tb_top.dut.dmi_unit.irq_uc ==1) begin
    check_irquc =1;
  end
end
always @(posedge tb_top.dut.dmi_unit.irq_uc) begin
  irq_uc_count++;
end
<% } %>

<%if(obj.DmiInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
function void eos_plru_error_check(int error_check_type=0);
  `uvm_info("DMI CSR PROBE IF:",$sformatf("PLRU Type[%0d] errors reported :: Address:%0d Single-Bit:%0d Double-Bit:%0d", error_check_type,plru_addr_error_count,plru_single_error_count,plru_double_error_count),UVM_LOW)
  if(error_check_type == 1) begin
    if(plru_addr_error_count == 0) begin
      `uvm_error("DMI CSR PROBE IF:","PLRU address error count should be non-zero to effectively test error injection on SRAM")
    end
  end
  else if (error_check_type == 2) begin
    if(plru_single_error_count == 0) begin
      `uvm_error("DMI CSR PROBE IF:","PLRU single error count should be non-zero to effectively test error injection on SRAM")
    end
  end
  else if (error_check_type == 3) begin
    if(plru_double_error_count == 0) begin
      `uvm_error("DMI CSR PROBE IF:","PLRU double error count should be non-zero to effectively test error injection on SRAM")
    end
  end
  else begin
    `uvm_warning("DMI CSR PROBE IF:",$sformatf("PLRU error type received %0d [NULL=0,ADDR=1,SINGLE=2,DOUBLE=3", error_check_type))
  end
endfunction
<% } %>

function void eos_timeout_non_zero_check();
  if (DMIUUESR_ErrVld == 0) begin  //un-correctable error valid 
    `uvm_error("DMI CSR PROBE IF:"," DMIUUESR_ErrVld should be 1 at the end of test");
  end
  if (DMIUUESR_ErrType != 4'h9) begin  //un-correctable error type for timeout 0x9
    `uvm_error("DMI CSR PROBE IF:"," DMIUUESR_ErrType should be 9 at the end of test");
  end
endfunction

function void eos_check();
  if (DMIUCESR_ErrVld !== 0) begin  //correctable error valid
    `uvm_error("DMI CSR PROBE IF:"," DMIUCESR_ErrVld should be 0 at the end of test");
  end
  if (DMIUCESR_ErrCountOverflow !== 0) begin  //correctable error count overflow
    `uvm_error("DMI CSR PROBE IF:"," DMIUCESR_ErrCountOverflow should be 0 at the end of test");
  end
  if (DMIUCESR_ErrCount !== 0) begin  //correctable error count 
    `uvm_error("DMI CSR PROBE IF:"," DMIUCESR_ErrCount should be 0 at the end of test");
  end
  if (DMIUCESR_ErrType !== 0) begin  //correctable error type 
    `uvm_error("DMI CSR PROBE IF:"," DMIUCESR_ErrType should be 0 at the end of test");
  end
  if (DMIUCESR_ErrInfo !== 0) begin  //correctable error info 
    `uvm_error("DMI CSR PROBE IF:"," DMIUCESR_ErrInfo should be 0 at the end of test");
  end
  if (DMIUUESR_ErrVld !== 0) begin  //un-correctable error valid 
    `uvm_error("DMI CSR PROBE IF:"," DMIUUESR_ErrVld should be 0 at the end of test");
  end
  if (DMIUUESR_ErrType !== 0) begin  //un-correctable error type 
    `uvm_error("DMI CSR PROBE IF:"," DMIUUESR_ErrType should be 0 at the end of test");
  end
  if (DMIUUESR_ErrInfo !== 0) begin  //un-correctable error info 
    `uvm_error("DMI CSR PROBE IF:"," DMIUUESR_ErrInfo should be 0 at the end of test");
  end
  if (cmd_skid_buffer_empty !== 1) begin  //CMDReq credits all returned
    `uvm_error("DMI CSR PROBE IF:"," cmd_skid_buffer_empty should be 1 at the end of test");
  end
  if (mrd_skid_buffer_empty !== 1) begin  //MRDReq credits all returned
    `uvm_error("DMI CSR PROBE IF:"," mrd_skid_buffer_empty should be 1 at the end of test");
  end
  if (mrd_resp_valid !== 0) begin  //MRDRsp not pending
    `uvm_error("DMI CSR PROBE IF:"," mrd_resp_valid should be 0 at the end of test");
  end
  if (nc_cmd_resp_valid !== 0) begin  //CMDRsp not pending
    `uvm_error("DMI CSR PROBE IF:"," nc_cmd_resp_valid should be 0 at the end of test");
  end
  if (str_rsp_pending !== 0) begin  //STRRsp not pending
    `uvm_error("DMI CSR PROBE IF:"," str_rsp_pending should be 0 at the end of test");
  end
  if (dtr_rsp_pending !== 0) begin  //DTRRsp not pending
    `uvm_error("DMI CSR PROBE IF:"," dtr_rsp_pending should be 0 at the end of test");
  end
  if (nc_write_active !== 0) begin  //NC RBID not active
    `uvm_error("DMI CSR PROBE IF:"," nc_write_active should be 0 at the end of test");
  end
  if (c_write_active !== 0) begin  //C RBID not active
    `uvm_error("DMI CSR PROBE IF:"," c_write_active should be 0 at the end of test");
  end
  if (rtt_trans_active !== 0) begin  //RTT not active
    `uvm_error("DMI CSR PROBE IF:"," rtt_trans_active should be 0 at the end of test");
  end
  if (wtt_trans_active !== 0) begin  //WTT not active
    `uvm_error("DMI CSR PROBE IF:"," wtt_trans_active should be 0 at the end of test");
  end
endfunction: eos_check

 always @(negedge clk) begin
   #3
   rtt_size_p[0]  <= rtt_size;                                     
   rtt_size_p[1]  <= rtt_size_p[0];
   rtt_size_p[2]  <= rtt_size_p[1];
   rtt_size_p[3]  <= rtt_size_p[2];
   rtt_size_p[4]  <= rtt_size_p[3];
   rtt_size_p[5]  <= rtt_size_p[4];
   rtt_size_p[6]  <= rtt_size_p[5];
   rtt_size_p[7]  <= rtt_size_p[6];
   rtt_size_p[8]  <= rtt_size_p[7];
   rtt_size_p[9]  <= rtt_size_p[8];
   rtt_size_p[10] <= rtt_size_p[9];
   rtt_size_p[11] <= rtt_size_p[10];
   rtt_size_p[12] <= rtt_size_p[11];
   rtt_size_p[13] <= rtt_size_p[12];
   rtt_size_p[14] <= rtt_size_p[13];
   rtt_size_p[15] <= rtt_size_p[14];
   rtt_size_p[16] <= rtt_size_p[15];
   wtt_size_p[0]  <= wtt_size;
   wtt_size_p[1]  <= wtt_size_p[0];
   wtt_size_p[2]  <= wtt_size_p[1];
   wtt_size_p[3]  <= wtt_size_p[2];
   wtt_size_p[4]  <= wtt_size_p[3];
   wtt_size_p[5]  <= wtt_size_p[4];
   wtt_size_p[6]  <= wtt_size_p[5];
   wtt_size_p[7]  <= wtt_size_p[6];
   wtt_size_p[8]  <= wtt_size_p[7];
   wtt_size_p[9]  <= wtt_size_p[8];
   wtt_size_p[10] <= wtt_size_p[9];
   wtt_size_p[11] <= wtt_size_p[10];
   wtt_size_p[12] <= wtt_size_p[11];
   wtt_size_p[13] <= wtt_size_p[12];
   wtt_size_p[14] <= wtt_size_p[13];
   wtt_size_p[15] <= wtt_size_p[14];
   wtt_size_p[16] <= wtt_size_p[15];
   #1;
   <%if (obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 2){ %>
   if(!(rtt_size_p[0] == rtt_size_p[1] && rtt_size_p[1] == rtt_size_p[2] && rtt_size_p[2] == rtt_size_p[3] && rtt_size_p[3] == rtt_size_p[4] && rtt_size_p[4] == rtt_size_p[5] && 
        rtt_size_p[5] == rtt_size_p[6] && rtt_size_p[6] == rtt_size_p[7] && rtt_size_p[7] == rtt_size_p[8] && rtt_size_p[8] == rtt_size_p[9] && rtt_size_p[9] == rtt_size_p[10] && 
        rtt_size_p[10] == rtt_size_p[11] && rtt_size_p[11] == rtt_size_p[12] && rtt_size_p[12] == rtt_size_p[13] && rtt_size_p[13] == rtt_size_p[14] && rtt_size_p[14] == rtt_size_p[15] && rtt_size_p[15] == rtt_size_p[16]) || 
      !(wtt_size_p[0] == wtt_size_p[1] && wtt_size_p[1] == wtt_size_p[2] && wtt_size_p[2] == wtt_size_p[3] && wtt_size_p[3] == wtt_size_p[4] && wtt_size_p[4] == wtt_size_p[5] &&
        wtt_size_p[5] == wtt_size_p[6] && wtt_size_p[6] == wtt_size_p[7] && wtt_size_p[7] == wtt_size_p[8] && wtt_size_p[8] == wtt_size_p[9] && wtt_size_p[9] == wtt_size_p[10] &&
        wtt_size_p[10] == wtt_size_p[11] && wtt_size_p[11] == wtt_size_p[12] && wtt_size_p[12] == wtt_size_p[13] && wtt_size_p[13] == wtt_size_p[14] && wtt_size_p[14] == wtt_size_p[15] && wtt_size_p[15] == wtt_size_p[16]) || 
      !ndp_dp_match) //RTT/WTT held longer for SLOW SRAM configuration, CCP takes longer to settle CONC-17372
   begin
     check_valid = 0;
   end
   else begin
     check_valid = 1;
   end
   <%} else {%>
   if(!(rtt_size_p[0] == rtt_size_p[1] && rtt_size_p[1] == rtt_size_p[2] && rtt_size_p[2] == rtt_size_p[3] && rtt_size_p[3] == rtt_size_p[4] && rtt_size_p[4] == rtt_size_p[5]) || 
       !(wtt_size_p[0] == wtt_size_p[1] && wtt_size_p[1] == wtt_size_p[2] && wtt_size_p[2] == wtt_size_p[3] && wtt_size_p[3] == wtt_size_p[4] && wtt_size_p[4] == wtt_size_p[5]) ||
       !ndp_dp_match)// once rtt/wtt size changes check valid goes high after 5 cycles. DMI takes 5 cycles to dellocate wtt entry after receiving bresp CONC-7362
   begin
     check_valid = 0;
   end
   else begin
     check_valid = 1;
   end
   <%} %>
 end
endinterface

`endif // GUARD_DMI_CSR_PROBE_IF_SV
