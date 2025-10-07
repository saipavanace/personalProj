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

`ifndef UVMPKG
import uvm_pkg::*;
`endif
`include "uvm_macros.svh"

class giu_sb_txn extends uvm_object;
  `uvm_object_utils(giu_sb_txn)

  smi_seq_item cmd_req_pkt;
  smi_seq_item cmd_rsp_pkt;
  smi_seq_item str_req_pkt;
  smi_seq_item dtw_req_pkt;
  smi_seq_item dtw_rsp_pkt;
  smi_seq_item snp_req1_pkt;
  smi_seq_item snp_req2_pkt;
  smi_seq_item snp_rsp_pkt;
  smi_seq_item cmp_rsp_pkt;
  smi_seq_item str_rsp_pkt;
  smi_seq_item sys_req_pkt;
  smi_seq_item sys_rsp_pkt;

  // Expected packets
  smi_seq_item expd_cmd_req_pkt;
  smi_seq_item expd_cmd_rsp_pkt;
  smi_seq_item expd_str_req_pkt;
  smi_seq_item expd_dtw_req_pkt;
  smi_seq_item expd_dtw_rsp_pkt;
  smi_seq_item expd_snp_req1_pkt;
  smi_seq_item expd_snp_req2_pkt;
  smi_seq_item expd_snp_rsp_pkt;
  smi_seq_item expd_cmp_rsp_pkt;
  smi_seq_item expd_str_rsp_pkt;
  smi_seq_item expd_sys_req_pkt;
  smi_seq_item expd_sys_rsp_pkt;

  // Queues
  smi_seq_item snp_req1_pkt_q[$]; // 2 SNPreq for 1 AIU
  smi_seq_item snp_req2_pkt_q[$]; // 2 SNPreq for 1 AIU

  smi_seq_item save_snp_req1_pkt_q[$]; // 2 SNPreq for 1 AIU
  smi_seq_item save_snp_req2_pkt_q[$]; // 2 SNPreq for 1 AIU
  smi_seq_item save_snp_rsp_pkt_q[$]; //  SNPrsp queue

  // Counts
  int txn_id = 1;
  int num_expd_snp_req1;
  int num_expd_snp_req2;
  int num_expd_snp_rsp;
  int num_rcvd_snp_req1;
  int num_rcvd_snp_req2;
  int num_rcvd_snp_rsp;

  // Flags
  bit expd_cmd_req = 0;
  bit expd_cmd_rsp = 0;
  bit expd_str_req = 0;
  bit expd_dtw_req = 0;
  bit expd_dtw_rsp = 0;
  bit expd_snp_req1 = 0;
  bit expd_snp_req2 = 0;
  bit expd_snp_rsp = 0;
  bit expd_cmp_rsp = 0;
  bit expd_str_rsp = 0;
  bit expd_sys_rsp = 0;
  bit expd_sysEvent_rsp_in = 0;
  bit expd_sysEvent_rsp_out = 0;
  bit rcvd_cmd_req = 0;
  bit rcvd_cmd_rsp = 0;
  bit rcvd_str_req = 0;
  bit rcvd_dtw_req = 0;
  bit rcvd_dtw_rsp = 0;
  bit rcvd_snp_req1 = 0;
  bit rcvd_snp_req2 = 0;
  bit rcvd_snp_rsp = 0;
  bit rcvd_cmp_rsp = 0;
  bit rcvd_str_rsp = 0;
  bit rcvd_sys_rsp = 0;
  bit rcvd_snoop_update = 0;
  bit is_cmd_sync = 0;
  bit dtw_dbad_err = 0; 
  bit snp_rsp_cmstatus_err = 0;
  int snp_rsp_cmstatus_err_payload = 0;
  bit transport_error = 0;
   
  int num_sys_req_cycle_delay = 6;
    //cov = new();
  int drop_bad_dvm_msg;
  smi_msg_id_t expd_snpreq_msg_id;
  
  typedef struct{
    int funit_id;
    int smi_msg_id;
    bit giu_sent;
    bit rsp_rcvd;
    }sys_evnt_rcvrs_s;
  sys_evnt_rcvrs_s sys_evnt_rcvrs_q[$];

  // Constructor
  function new(string name = "giu_sb_txn");
    super.new(name);
  endfunction // new

  // Save packets
  extern function void save_cmd_req_pkt(const ref smi_seq_item rcvd_pkt);
  extern function void save_cmd_rsp_pkt(const ref smi_seq_item rcvd_pkt);
  extern function void save_str_req_pkt(const ref smi_seq_item rcvd_pkt);
  extern function void save_dtw_req_pkt(const ref smi_seq_item rcvd_pkt);
  extern function void save_dtw_rsp_pkt(const ref smi_seq_item rcvd_pkt);
  extern function void save_snp_req1_pkt(const ref smi_seq_item rcvd_pkt);
  extern function void save_snp_req2_pkt(const ref smi_seq_item rcvd_pkt);
  extern function void save_snp_rsp_pkt(const ref smi_seq_item rcvd_pkt);
  extern function void save_cmp_rsp_pkt(const ref smi_seq_item rcvd_pkt);
  extern function void save_str_rsp_pkt(const ref smi_seq_item rcvd_pkt);
  extern function void save_sys_req_pkt(const ref smi_seq_item rcvd_pkt);
  extern function void save_sys_rsp_pkt(const ref smi_seq_item rcvd_pkt);
endclass // giu_sb_txn

function void giu_sb_txn::save_cmd_req_pkt(const ref smi_seq_item rcvd_pkt);
  cmd_req_pkt = new();
  cmd_req_pkt.copy(rcvd_pkt);
  <% if (obj.system.ResilienceEnable) { %>
  if (cmd_req_pkt.hdr_corr_error | cmd_req_pkt.hdr_parity_error) begin
    cmd_req_pkt.correct_smi_hdr_error();
    cmd_req_pkt.unpack_smi_seq_item();
  end

  if (cmd_req_pkt.ndp_corr_error | cmd_req_pkt.ndp_parity_error) begin
    cmd_req_pkt.correct_smi_ndp_error();
    cmd_req_pkt.unpack_smi_seq_item();
  end

  if (cmd_req_pkt.smi_dp_present) begin
    if (cmd_req_pkt.dp_corr_error | cmd_req_pkt.dp_parity_error) begin
      cmd_req_pkt.correct_smi_dp_error();
      cmd_req_pkt.unpack_smi_seq_item();
    end
  end
  <% } %>
endfunction // save_cmd_req_pkt

function void giu_sb_txn::save_cmd_rsp_pkt(const ref smi_seq_item rcvd_pkt);
  smi_cmstatus_err_t m_cmstatus_err;
  smi_cmstatus_err_payload_t m_cmstatus_err_payload;

  cmd_rsp_pkt = new();
  cmd_rsp_pkt.copy(rcvd_pkt);

  if((rcvd_dtw_req == 1) && (dtw_req_pkt.smi_cmstatus_err == 1)) begin
     m_cmstatus_err = dtw_req_pkt.smi_cmstatus_err;
     m_cmstatus_err_payload = dtw_req_pkt.smi_cmstatus_err_payload;
  end
  else begin
     m_cmstatus_err = cmd_req_pkt.smi_cmstatus_err;
     m_cmstatus_err_payload = cmd_req_pkt.smi_cmstatus_err_payload;
  end

  expd_cmd_rsp_pkt = new();
  expd_cmd_rsp_pkt.construct_nccmdrsp(
    .smi_steer('h0),
    .smi_targ_ncore_unit_id(cmd_req_pkt.smi_src_ncore_unit_id),
    .smi_src_ncore_unit_id(cmd_req_pkt.smi_targ_ncore_unit_id),
    .smi_msg_tier('h0),
    .smi_msg_qos('h0), 
    .smi_msg_pri(cmd_req_pkt.smi_msg_pri),
    .smi_msg_type(NC_CMD_RSP),
    .smi_msg_id(cmd_req_pkt.smi_msg_id),
    .smi_msg_err(1'b0),
    .smi_cmstatus({m_cmstatus_err, m_cmstatus_err_payload}),
    .smi_tm(cmd_req_pkt.smi_tm),
    .smi_rmsg_id(cmd_req_pkt.smi_msg_id)
   );
endfunction // save_cmd_rsp_pkt

function void giu_sb_txn::save_str_req_pkt(const ref smi_seq_item rcvd_pkt);
  str_req_pkt = new();
  str_req_pkt.copy(rcvd_pkt);

    // FIXME: Need to generate expected StrRsp here
  expd_str_req_pkt = new();
  expd_str_req_pkt.construct_strmsg(
    .smi_targ_ncore_unit_id(cmd_req_pkt.smi_src_ncore_unit_id),
    .smi_src_ncore_unit_id(cmd_req_pkt.smi_targ_ncore_unit_id),
    .smi_msg_type(STR_STATE),
    .smi_msg_id(rcvd_pkt.smi_msg_id),
    .smi_msg_tier('h0),
    .smi_steer('h0),
    .smi_msg_pri(cmd_req_pkt.smi_msg_pri), //QoS from CM Body
    .smi_msg_qos('h0),
    .smi_msg_err(1'b0),
    .smi_cmstatus('h0),
    .smi_cmstatus_so('h0),
    .smi_cmstatus_ss('h0),
    .smi_cmstatus_sd('h0),
    .smi_cmstatus_st('h0),
    .smi_cmstatus_state('h0),
    .smi_cmstatus_snarf('h0),
    .smi_cmstatus_exok('h0),
    .smi_tm(cmd_req_pkt.smi_tm),
    .smi_rbid(cmd_req_pkt.smi_rbid),
    .smi_rmsg_id(cmd_req_pkt.smi_msg_id),
    .smi_mpf1('h0),
    .smi_mpf2('h0),
    .smi_intfsize('h0)
  );
endfunction // save_str_req_pkt

function void giu_sb_txn::save_dtw_req_pkt(const ref smi_seq_item rcvd_pkt);
   smi_seq_item saved_snp_req1_pkt;
   smi_seq_item saved_snp_req2_pkt;
   
  dtw_req_pkt = new();
  dtw_req_pkt.copy(rcvd_pkt);
  <% if (obj.system.ResilienceEnable) { %>
  if (dtw_req_pkt.hdr_corr_error | dtw_req_pkt.hdr_parity_error) begin
    dtw_req_pkt.correct_smi_hdr_error();
    dtw_req_pkt.unpack_smi_seq_item();
  end

  if (dtw_req_pkt.ndp_corr_error | dtw_req_pkt.ndp_parity_error) begin
    dtw_req_pkt.correct_smi_ndp_error();
    dtw_req_pkt.unpack_smi_seq_item();
  end

  if (dtw_req_pkt.smi_dp_present) begin
    if (dtw_req_pkt.dp_corr_error | dtw_req_pkt.dp_parity_error) begin
      dtw_req_pkt.correct_smi_dp_error();
      dtw_req_pkt.unpack_smi_seq_item();
    end
  end
  <% } %>
  //`uvm_info(">> save_dtw_req_pkt <<", $psprintf("Saving DTWReq: %0s", dtw_req_pkt.convert2string()), UVM_LOW)
  if(rcvd_snp_req1) begin
     saved_snp_req1_pkt = save_snp_req1_pkt_q.pop_front();
     save_snp_req1_pkt(saved_snp_req1_pkt);
     saved_snp_req1_pkt = save_snp_req1_pkt_q.pop_front();
  end
  if(rcvd_snp_req2) begin
     saved_snp_req2_pkt = save_snp_req2_pkt_q.pop_front(); 
     save_snp_req2_pkt(saved_snp_req2_pkt);
     saved_snp_req2_pkt = save_snp_req2_pkt_q.pop_front();
  end
endfunction // save_dtw_req_pkt

function void giu_sb_txn::save_dtw_rsp_pkt(const ref smi_seq_item rcvd_pkt);
bit dbad_err = 0;
  dtw_rsp_pkt = new();
  dtw_rsp_pkt.copy(rcvd_pkt);
    
//  foreach(dtw_req_pkt.smi_dp_dbad[idx]) begin
//      if (dtw_req_pkt.smi_dp_dbad[idx] !== 0) begin
//          dbad_err = 1;
//      end
//  end

  expd_dtw_rsp_pkt = new();
  expd_dtw_rsp_pkt.construct_dtwrsp(
    .smi_steer('h0),
    .smi_targ_ncore_unit_id(dtw_req_pkt.smi_src_ncore_unit_id),
    .smi_src_ncore_unit_id(dtw_req_pkt.smi_targ_ncore_unit_id),
    .smi_msg_tier('h0),
    .smi_msg_qos('h0),
    //CONC-14145 change priority bits mapping from dtw_req to cmd_req in dtw_rsp
    .smi_msg_pri(cmd_req_pkt.smi_msg_pri),
    //.smi_msg_pri(dtw_req_pkt.smi_msg_pri),
    .smi_msg_type(DTW_RSP),
    .smi_msg_id(dtw_req_pkt.smi_msg_id),
    .smi_msg_err(1'b0),
    .smi_cmstatus('h0),  // per section 5.1.8 of GIU 3.0.1 micro-arch spec, dtw_rsp_cm_status is always 0
    .smi_tm(dtw_req_pkt.smi_tm),
    .smi_rl('h0),
    .smi_rmsg_id(dtw_req_pkt.smi_msg_id)
  );
//  dbad status is now moved to CMPrsp packet
//  if (dbad_err) begin
//      expd_dtw_rsp_pkt.smi_cmstatus_err = 1'b1;
//      expd_dtw_rsp_pkt.smi_cmstatus_err_payload = 'h3;
//  end
endfunction // save_dtw_rsp_pkt

function void giu_sb_txn::save_snp_req1_pkt(const ref smi_seq_item rcvd_pkt);
  smi_addr_t  						my_smi_addr;
  smi_mpf1_stash_valid_t           my_mpf1_StashValid = 'h0;
  smi_mpf1_stash_nid_t             my_mpf1_StashNid = 'h0;
  smi_mpf1_dtr_tgt_id_t            my_mpf1_DtrTgtId = 'h0;
  smi_mpf1_vmid_ext_t              my_mpf1_vmId_ext = 'h0;
  smi_mpf2_stash_valid_t           my_mpf2_StashValid = 'h0;
  smi_mpf2_stash_lpid_t            my_mpf2_StashLPId = 'h0;
  smi_mpf2_dtr_msg_id_t            my_mpf2_DtrMsgId = 'h0;
  smi_mpf2_dvmop_id_t              my_mpf2_dvmOpId = 'h0; 
  smi_mpf3_intervention_unit_id_t  my_mpf3_InterventionUnitId = 'h0;
  smi_mpf3_dvmop_portion_t         my_mpf3_dvmOpPortion = 'h0; 
  smi_mpf3_range_t                 my_mpf3_range = 'h0; 

  snp_req1_pkt = new();
  snp_req1_pkt.copy(rcvd_pkt);

  if(rcvd_dtw_req == 1) begin
//  expd_snp_req1_pkt.smi_addr = 'h0;
//  expd_snp_req1_pkt.smi_addr[3] = 1'b0;
//  expd_snp_req1_pkt.smi_addr[40:4] = cmd_req_pkt.smi_addr[40:4];
//  expd_snp_req1_pkt.smi_addr[43:41] = dtw_req_pkt.smi_dp_data[0][46:44];
//  expd_snp_req1_pkt.smi_addr[44] = dtw_req_pkt.smi_dp_data[0][48];
//  expd_snp_req1_pkt.smi_addr[45] = dtw_req_pkt.smi_dp_data[0][50];
//  expd_snp_req1_pkt.smi_mpf1_dtr_tgt_id = dtw_req_pkt.smi_dp_data[0][63:56];
  my_smi_addr        = 'h0;
  my_smi_addr[3]     = 1'b0;
  my_smi_addr[40:4]  = cmd_req_pkt.smi_addr[40:4];
  <% if (obj.GiuInfo[0].wAddr > 40) { %>
  my_smi_addr[43:41] = dtw_req_pkt.smi_dp_data[0][46:44];
  <% if (obj.GiuInfo[0].wAddr > 44) { %>
  my_smi_addr[44]    = dtw_req_pkt.smi_dp_data[0][48];
  my_smi_addr[45]    = dtw_req_pkt.smi_dp_data[0][50];
  <%}%>
  <%}%>
  my_mpf3_dvmOpPortion[0] = 1'b0;
  my_mpf3_range = cmd_req_pkt.smi_addr[41];
 // my_mpf1_DtrTgtId[7:0] =  dtw_req_pkt.smi_dp_data[63:56];
  //my_mpf3_dvmOpPortion[1] = cmd_req_pkt.smi_addr[41];
  my_mpf1_vmId_ext[7:0] = dtw_req_pkt.smi_dp_data[0][63:56];
 `uvm_info($sformatf("%m"), $sformatf("SNPREQ: Addr=%p", my_smi_addr), UVM_LOW)
  expd_snp_req1_pkt = new();
  expd_snp_req1_pkt.construct_snpmsg(
//    .smi_targ_ncore_unit_id(cmd_req_pkt.smi_src_ncore_unit_id),
//    .smi_src_ncore_unit_id(cmd_req_pkt.smi_targ_ncore_unit_id),
    .smi_targ_ncore_unit_id(rcvd_pkt.smi_targ_ncore_unit_id),
    .smi_src_ncore_unit_id(rcvd_pkt.smi_src_ncore_unit_id),
    .smi_msg_type(SNP_DVM_MSG),
    .smi_msg_id(rcvd_pkt.smi_msg_id),
    .smi_msg_tier('h0),
    .smi_steer('h0),
    .smi_msg_pri(cmd_req_pkt.smi_msg_pri),
    .smi_msg_qos('h0),
    .smi_msg_err(1'b0),
    .smi_cmstatus(cmd_req_pkt.smi_cmstatus),
//    .smi_addr(cmd_req_pkt.smi_addr),
    .smi_addr(my_smi_addr),
    .smi_vz(cmd_req_pkt.smi_vz),
    .smi_ac(cmd_req_pkt.smi_ac),
    .smi_ca(cmd_req_pkt.smi_ca),
    .smi_ns(cmd_req_pkt.smi_ns),
    .smi_pr(cmd_req_pkt.smi_pr),
    .smi_rl(cmd_req_pkt.smi_rl),
    .smi_tm(cmd_req_pkt.smi_tm),
    .smi_up(cmd_req_pkt.smi_up),
	.smi_mpf1_stash_valid(cmd_req_pkt.smi_mpf1_stash_valid),
	.smi_mpf1_stash_nid(cmd_req_pkt.smi_mpf1_stash_nid),
    .smi_mpf1_dtr_tgt_id(cmd_req_pkt.smi_mpf1_dtr_tgt_id),
    .smi_mpf1_vmid_ext(my_mpf1_vmId_ext),
	.smi_mpf2_dtr_msg_id(cmd_req_pkt.smi_mpf2_dtr_msg_id),
    .smi_mpf2_stash_valid(cmd_req_pkt.smi_mpf2_stash_valid),
    .smi_mpf2_stash_lpid(cmd_req_pkt.smi_mpf2_stash_lpid),
	.smi_mpf2_dvmop_id(rcvd_pkt.smi_mpf2_dvmop_id),
    .smi_mpf3_intervention_unit_id(rcvd_pkt.smi_mpf3_intervention_unit_id),
	.smi_mpf3_dvmop_portion(my_mpf3_dvmOpPortion),
	.smi_mpf3_range(my_mpf3_range),
	.smi_mpf3_num('h0),
//    .smi_mpf1_stash_valid(cmd_req_pkt.smi_mpf1_stash_valid),
//    .smi_mpf1_stash_nid(cmd_req_pkt.smi_mpf1_stash_nid),
//    .smi_mpf1_dtr_tgt_id(cmd_req_pkt.smi_mpf1_dtr_tgt_id),
//    .smi_mpf1_dtr_tgt_id(dtw_req_pkt.smi_dp_data[0][63:56]),
//    .smi_mpf1_vmid_ext(dtw_req_pkt.smi_mpf1_vmid_ext),
//    .smi_mpf1_vmid_ext(dtw_req_pkt.smi_dp_data[0][63:56]),
//    .smi_mpf2_dtr_msg_id(cmd_req_pkt.smi_mpf2_dtr_msg_id),
//    .smi_mpf2_stash_valid(cmd_req_pkt.smi_mpf2_stash_valid),
//    .smi_mpf2_stash_lpid(cmd_req_pkt.smi_mpf2_stash_lpid),
//    .smi_mpf2_dvmop_id(cmd_req_pkt.smi_mpf2_dvmop_id),
//    .smi_mpf2_dvmop_id(rcvd_pkt.smi_mpf2_dvmop_id),
//    .smi_mpf3_intervention_unit_id(rcvd_pkt.smi_mpf3_intervention_unit_id),
//    .smi_mpf3_dvmop_portion(cmd_req_pkt.smi_mpf3_dvmop_portion),
//    .smi_mpf3_dvmop_portion('h0),
    .smi_intfsize('h0), //Should be 0 since GIU's data bus will always be 64bits wide, as per test plan review discussion.
    .smi_dest_id('h0), //dont care in case of GIU.
    .smi_qos(cmd_req_pkt.smi_qos),
    .smi_tof(cmd_req_pkt.smi_tof),
    .smi_rbid(cmd_req_pkt.smi_rbid),
    .smi_ndp_aux(cmd_req_pkt.smi_ndp_aux)
  );
     snp_req1_pkt_q.push_back(snp_req1_pkt);
  end
  else begin
     save_snp_req1_pkt_q.push_back(snp_req1_pkt);
     //`uvm_info(">> save_snp_req1_pkt <<", $psprintf("Saving SNPReq1: %0s", expd_snp_req1_pkt.convert2string()), UVM_LOW)
  end // else: !if(rcvd_dtw_req == 1)

endfunction // save_snp_req1_pkt

function void giu_sb_txn::save_snp_req2_pkt(const ref smi_seq_item rcvd_pkt);
  smi_addr_t   					   my_smi_addr;
  smi_mpf1_stash_valid_t           my_mpf1_StashValid = 'h0;
  smi_mpf1_stash_nid_t             my_mpf1_StashNid = 'h0;
  smi_mpf1_dtr_tgt_id_t            my_mpf1_DtrTgtId = 'h0;
  smi_mpf1_vmid_ext_t              my_mpf1_vmId_ext = 'h0;
  smi_mpf2_stash_valid_t           my_mpf2_StashValid = 'h0;
  smi_mpf2_stash_lpid_t            my_mpf2_StashLPId = 'h0;
  smi_mpf2_dtr_msg_id_t            my_mpf2_DtrMsgId = 'h0;
  smi_mpf2_dvmop_id_t              my_mpf2_dvmOpId = 'h0; 
  smi_mpf3_intervention_unit_id_t  my_mpf3_InterventionUnitId = 'h0;
  smi_mpf3_dvmop_portion_t         my_mpf3_dvmOpPortion = 'h0; 
  smi_mpf3_num_t                   my_mpf3_num = 'h0; 

  snp_req2_pkt = new();
  snp_req2_pkt.copy(rcvd_pkt);

  if(rcvd_dtw_req == 1) begin
	my_smi_addr = 'h0;
    //Following mapping is from 3.6 Supplemental Architecture Spec Rev#0.7
    //The RHS mapping is derived from Table 17 DVM Data Mapping
    //The LHS mapping is derived from Table 19 DVM 2nd Snoop Mapping
	my_smi_addr[3]     = 1'b1;                                   // 1 indicates 2nd Snoop
	my_smi_addr[5:4]   = dtw_req_pkt.smi_dp_data[0][5:4];        // VA[7:6]/PA[7:6]
	my_smi_addr[7:6]   = dtw_req_pkt.smi_dp_data[0][7:6];        // VA[9:8]/PA[9:8]
	my_smi_addr[9:8]   = dtw_req_pkt.smi_dp_data[0][9:8];        // VA[11:10]/PA[11:10]
	my_smi_addr[37:10] = dtw_req_pkt.smi_dp_data[0][37:10];      // VA[39:12]/PA[39:12]
	my_smi_addr[38]    = dtw_req_pkt.smi_dp_data[0][38];         // VA[40]/PA[40]
	my_smi_addr[39]    = dtw_req_pkt.smi_dp_data[0][39];         // VA[41]/PA[41]
    <% if (obj.GiuInfo[0].wAddr > 40) { %>
	my_smi_addr[42:40] = dtw_req_pkt.smi_dp_data[0][42:40];      // VA[44:42]/PA[44:42]
	my_smi_addr[43]    = dtw_req_pkt.smi_dp_data[0][43];         // VA[45]/PA[45]
    <% if (obj.GiuInfo[0].wAddr > 44) { %>
    if (cmd_req_pkt.smi_addr[13:11] === 3'b010) begin            // if DVMOpType=PICI
	  my_smi_addr[44]  = dtw_req_pkt.smi_dp_data[0][44];         // PA[46]
    end else begin 
	  my_smi_addr[44]  = dtw_req_pkt.smi_dp_data[0][47];         // VA[49]
    end
    if (cmd_req_pkt.smi_addr[13:11] === 3'b010) begin
	  my_smi_addr[45]  = dtw_req_pkt.smi_dp_data[0][45];         // PA[47]
    end else begin
	  my_smi_addr[45]  = dtw_req_pkt.smi_dp_data[0][49];         // VA[51]
    end
  	my_smi_addr[47:46] = dtw_req_pkt.smi_dp_data[0][47:46];      // PA[49:48]
    <% if (obj.GiuInfo[0].wAddr > 48) { %>
  	my_smi_addr[49:48] = dtw_req_pkt.smi_dp_data[0][49:48];      // PA[51:50]
    <% } %>
    <% } %>
    <% } %>
	my_mpf3_dvmOpPortion = 1'b1;
//	my_mpf2_dvmOpId = rcvd_pkt.smi_mpf2_dvmop_id;
	if(cmd_req_pkt.smi_tof == 3'b001) begin  //Selection for CHI
		my_mpf1_vmId_ext[7:0] = 'h0;
        //if(cmd_req_pkt.smi_addr[41] == 1)
	        my_mpf3_num[3:0] = dtw_req_pkt.smi_dp_data[0][3:0];  //NUM[3:0] CHI
		//else
		//	my_mpf3_num[3:0]   = 4'h0;
		my_mpf3_num[4]   = cmd_req_pkt.smi_addr[42]; //Num[4] CHI
	end
	else begin                               //Selection for ACE
		my_mpf1_vmId_ext[7:4] = 4'h0;
		my_mpf1_vmId_ext[3:0] = dtw_req_pkt.smi_dp_data[0][54:51];
		//if(cmd_req_pkt.smi_addr[41] == 1) begin
	        my_mpf3_num[2:0] = dtw_req_pkt.smi_dp_data[0][2:0]; //NUM[2:0]
        //end else
		//	my_mpf3_num[2:0]   = 3'h0;
	    my_mpf3_num[3]   = dtw_req_pkt.smi_dp_data[0][3];   //NUM[3]/PA[4]/VA[4] for ACE
		my_mpf3_num[4]   = dtw_req_pkt.smi_dp_data[0][55];  //Num[4]/PA[5]/VA[5] for ACE


	end
  expd_snp_req2_pkt = new();
  expd_snp_req2_pkt.construct_snpmsg(
//    .smi_targ_ncore_unit_id(cmd_req_pkt.smi_src_ncore_unit_id),
//    .smi_src_ncore_unit_id(cmd_req_pkt.smi_targ_ncore_unit_id),
    .smi_targ_ncore_unit_id(rcvd_pkt.smi_targ_ncore_unit_id),
    .smi_src_ncore_unit_id(rcvd_pkt.smi_src_ncore_unit_id),
    .smi_msg_type(SNP_DVM_MSG),
    .smi_msg_id(rcvd_pkt.smi_msg_id),
    .smi_msg_tier('h0),
    .smi_steer('h0),
    .smi_msg_pri(cmd_req_pkt.smi_msg_pri),
    .smi_msg_qos('h0),
    .smi_msg_err(1'b0),
    .smi_cmstatus(cmd_req_pkt.smi_cmstatus),
//    .smi_addr(cmd_req_pkt.smi_addr),
    .smi_addr(my_smi_addr),
    .smi_vz(cmd_req_pkt.smi_vz),
    .smi_ac(cmd_req_pkt.smi_ac),
    .smi_ca(cmd_req_pkt.smi_ca),
    .smi_ns(cmd_req_pkt.smi_ns),
    .smi_pr(cmd_req_pkt.smi_pr),
    .smi_rl(cmd_req_pkt.smi_rl),
    .smi_tm(cmd_req_pkt.smi_tm),
    .smi_up(cmd_req_pkt.smi_up),
    .smi_mpf1_stash_valid(cmd_req_pkt.smi_mpf1_stash_valid),
    .smi_mpf1_stash_nid(cmd_req_pkt.smi_mpf1_stash_nid),
    .smi_mpf1_dtr_tgt_id(cmd_req_pkt.smi_mpf1_dtr_tgt_id),
//    .smi_mpf1_vmid_ext(dtw_req_pkt.smi_mpf1_vmid_ext),
    .smi_mpf1_vmid_ext(my_mpf1_vmId_ext),
    .smi_mpf2_dtr_msg_id(cmd_req_pkt.smi_mpf2_dtr_msg_id),
    .smi_mpf2_stash_valid(cmd_req_pkt.smi_mpf2_stash_valid),
    .smi_mpf2_stash_lpid(cmd_req_pkt.smi_mpf2_stash_lpid),
//    .smi_mpf2_dvmop_id(cmd_req_pkt.smi_mpf2_dvmop_id),
    .smi_mpf2_dvmop_id(rcvd_pkt.smi_mpf2_dvmop_id),
    .smi_mpf3_intervention_unit_id(rcvd_pkt.smi_mpf3_intervention_unit_id),
//    .smi_mpf3_dvmop_portion(cmd_req_pkt.smi_mpf3_dvmop_portion),
    .smi_mpf3_dvmop_portion(my_mpf3_dvmOpPortion),
    .smi_mpf3_range('h0),
    .smi_mpf3_num(my_mpf3_num),
    .smi_intfsize('h0), //Should be 0 since GIU's data bus will always be 64bits wide, as per test plan review discussion.
    .smi_dest_id('h0), //dont care in case of GIU.
    .smi_tof(cmd_req_pkt.smi_tof),
    .smi_qos(cmd_req_pkt.smi_qos),
    .smi_rbid(cmd_req_pkt.smi_rbid),
    .smi_ndp_aux(cmd_req_pkt.smi_ndp_aux)
  );
     snp_req2_pkt_q.push_back(snp_req2_pkt);
  end
  else begin
     save_snp_req2_pkt_q.push_back(snp_req2_pkt);
  end
  //`uvm_info(">> save_snp_req2_pkt <<", $psprintf("Saving SNPReq2: %0s", expd_snp_req2_pkt.convert2string()), UVM_LOW)
endfunction // save_snp_req2_pkt

function void giu_sb_txn::save_snp_rsp_pkt(const ref smi_seq_item rcvd_pkt);
  snp_rsp_pkt = new();
  snp_rsp_pkt.copy(rcvd_pkt);

  if(rcvd_dtw_req == 0) begin
     save_snp_rsp_pkt_q.push_back(snp_rsp_pkt);
  end
endfunction // save_snp_rsp_pkt

function void giu_sb_txn::save_cmp_rsp_pkt(const ref smi_seq_item rcvd_pkt);
  bit dbad_err = 0;
  cmp_rsp_pkt = new();
  cmp_rsp_pkt.copy(rcvd_pkt);

  foreach(dtw_req_pkt.smi_dp_dbad[idx]) begin
      if (dtw_req_pkt.smi_dp_dbad[idx] !== 0) begin
          dbad_err = 1;
      end
  end

  expd_cmp_rsp_pkt = new();
  expd_cmp_rsp_pkt.construct_cmprsp(
    .smi_steer('h0),
    .smi_targ_ncore_unit_id(cmd_req_pkt.smi_src_ncore_unit_id),
    .smi_src_ncore_unit_id(cmd_req_pkt.smi_targ_ncore_unit_id),
    .smi_msg_tier('h0),
    .smi_msg_qos('h0), 
    .smi_msg_pri(cmd_req_pkt.smi_msg_pri),
    .smi_msg_type(CMP_RSP),
    .smi_msg_id(cmd_req_pkt.smi_msg_id),
    .smi_msg_err(1'b0),
    .smi_cmstatus({snp_rsp_cmstatus_err, snp_rsp_cmstatus_err_payload[WSMICMSTATUSERRPAYLOAD - 1:0]}),
    .smi_tm(cmd_req_pkt.smi_tm),
    .smi_rmsg_id(cmd_req_pkt.smi_msg_id)
  );
  if (dbad_err) begin
      expd_cmp_rsp_pkt.smi_cmstatus_err = 1'b1;
      expd_cmp_rsp_pkt.smi_cmstatus_err_payload = 'h3;
      //GIU COV
      drop_bad_dvm_msg=2;
  end
endfunction // save_cmp_rsp_pkt

function void giu_sb_txn::save_str_rsp_pkt(const ref smi_seq_item rcvd_pkt);
  str_rsp_pkt = new();
  str_rsp_pkt.copy(rcvd_pkt);
endfunction // save_str_rsp_pkt

function void giu_sb_txn::save_sys_req_pkt(const ref smi_seq_item rcvd_pkt);
  sys_req_pkt = new();
  sys_req_pkt.copy(rcvd_pkt);

  <% if (obj.system.ResilienceEnable) { %>
  if (sys_req_pkt.hdr_corr_error | sys_req_pkt.hdr_parity_error) begin
    sys_req_pkt.correct_smi_hdr_error();
    sys_req_pkt.unpack_smi_seq_item();
  end

  if (sys_req_pkt.ndp_corr_error | sys_req_pkt.ndp_parity_error) begin
    sys_req_pkt.correct_smi_ndp_error();
    sys_req_pkt.unpack_smi_seq_item();
  end
  <% } %>
endfunction // save_sys_req_pkt

function void giu_sb_txn::save_sys_rsp_pkt(const ref smi_seq_item rcvd_pkt);
  sys_rsp_pkt = new();
  sys_rsp_pkt.copy(rcvd_pkt);

  expd_sys_rsp_pkt = new();
  expd_sys_rsp_pkt.construct_sysrsp(
    .smi_targ_ncore_unit_id(sys_req_pkt.smi_src_ncore_unit_id),
    .smi_src_ncore_unit_id(sys_req_pkt.smi_targ_ncore_unit_id),
    .smi_msg_type(SYS_RSP),
    .smi_msg_id(sys_req_pkt.smi_msg_id),
    .smi_rmsg_id(sys_req_pkt.smi_msg_id),
    .smi_msg_tier('h0),
    .smi_steer('h0),
    .smi_msg_qos('h0), 
    .smi_msg_pri(sys_req_pkt.smi_msg_pri),
    .smi_tm(sys_req_pkt.smi_tm),
    .smi_msg_err(1'b0),
    .smi_cmstatus(sys_req_pkt.smi_cmstatus),
    .smi_ndp_aux(sys_req_pkt.smi_ndp_aux)
   );
endfunction // save_sys_rsp_pkt

class giu_debug_txn extends uvm_object;
  `uvm_object_utils(giu_debug_txn);

  bit[7:0] srcid;
  bit[31:0] timestamp;
  bit[31:0] data [15:0];
  // Does the DtwDbgReader expect transactions near this one to have been dropped?
  bit dropping;
  bit circular;
  bit empty, full;
  bit cleared; // has the buffer been cleared?
  // to be filled by SB before passing to coverage
  bit[7:0] correction;

  function string convert2string();
    string s;
    
    $sformat(s, "DtwDbgTxn srcid:%0d, timestamp:0x%0h data:%0p dropping:%0b circular:%0b empty:%0b full:%0b cleared:%0b correction:%0h",
               srcid,
               timestamp,
               data,
               dropping,
               circular,
               empty,
               full,
               cleared,
               correction
               );
  
      return (s);
  endfunction

endclass: giu_debug_txn
