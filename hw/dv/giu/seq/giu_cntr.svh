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

class giu_cntr extends uvm_object;
  `uvm_object_utils(giu_cntr)

  smi_seq_item m_cmd_rsp_pkt;
  smi_seq_item m_str_req_pkt;
  smi_seq_item m_dtw_rsp_pkt;
  smi_seq_item m_snp_req_pkt;
  smi_seq_item m_cmp_rsp_pkt;
  smi_seq_item m_dtw_dbg_rsp_pkt;
  smi_seq_item m_sys_rsp_pkt;

  smi_seq_item m_sysEvent_req_pkt;
  smi_seq_item m_sysEvent_rsp_pkt;

  smi_seq m_cmd_req_seq;
  smi_seq_item m_cmd_req_pkt;

  smi_seq m_str_rsp_seq;
  smi_seq_item m_str_rsp_pkt;

  smi_seq m_snp_rsp_seq;
  smi_seq_item m_snp_rsp_pkt;

  smi_seq m_dtw_req_seq;
  smi_seq_item m_dtw_req_pkt;

  smi_seq m_dtw_dbg_req_seq;
  smi_seq_item m_dtw_dbg_req_pkt;

  smi_seq m_sys_req_seq;
  smi_seq_item m_sys_req_pkt;

  smi_seq m_sysEvent_rsp_seq;

  // Queues
  smi_seq_item snp_req_pkt_q[$]; // 2 SNPreq for 1 AIU
  smi_seq_item sysEvent_req_pkt_q[$]; // 1 event req fpr 1 Active AIU

  // Counts
  int txn_id = 0;

  int cmd_type_weight = 0;
  int k_cmd_cm_status_err_wgt;
  int k_dtw_cm_status_err_wgt;
  int k_dtw_dbad_err_wgt;
  int k_snp_rsp_err_wgt;
  int k_str_rsp_err_wgt;
  int k_sysreq_cm_status_err_wgt;
  int k_cmd_msg_err_wgt;

  // Flags
  bit can_issue_cmd_req = 0;
  bit can_issue_dtw_req = 0;
  bit can_issue_dtw_dbg_req = 0;
  bit can_issue_snp_rsp = 0;
  bit can_issue_str_rsp = 0;
  bit can_issue_sys_req = 0;
  bit issued_cmd_req = 0;
  bit issued_dtw_req = 0;
  bit issued_dtw_dbg_req = 0;
  bit issued_snp_rsp = 0;
  bit issued_str_rsp = 0;
  bit issued_sys_req = 0;
  bit issued_sysEvent_req = 0;
  bit rcvd_cmd_rsp = 0;
  bit rcvd_str_req = 0;
  bit rcvd_sys_req = 0;
  bit rcvd_dtw_rsp = 0;
  bit rcvd_snp_req1 = 0;
  bit rcvd_snp_req2 = 0;
  bit rcvd_cmp_rsp = 0;
  bit rcvd_dtw_dbg_rsp = 0;
  bit rcvd_sys_rsp = 0;
  bit is_sync_pending = 0;
  bit sysEvent_rsp = 0;

  // Time stamps
  time t_cmd_req;
  time t_cmd_rsp;
  time t_str_req;
  time t_dtw_req;
  time t_dtw_rsp;
  time t_snp_req_q[$];
  time t_snp_rsp;
  time t_cmp_rsp;
  time t_str_rsp;
  time t_dtw_dbg_req;
  time t_dtw_dbg_rsp;
  time t_sys_req;
  time t_sys_rsp;
  time t_sysEvent_req_q[$];
  time t_sysEvent_rsp;

  static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  static uvm_event ev = ev_pool.get("ev");
  static uvm_event ev_addr = ev_pool.get("ev_addr");

  // Constructor
  function new(string name = "giu_cntr");
    super.new(name);
    m_cmd_req_seq = smi_seq::type_id::create("m_cmd_req_seq");
    m_str_rsp_seq = smi_seq::type_id::create("m_str_rsp_seq");
    m_snp_rsp_seq = smi_seq::type_id::create("m_snp_rsp_seq");
    m_dtw_req_seq = smi_seq::type_id::create("m_dtw_req_seq");
    m_dtw_dbg_req_seq = smi_seq::type_id::create("m_dtw_dbg_req_seq");
    m_sys_req_seq = smi_seq::type_id::create("m_sys_req_seq");
    m_sysEvent_rsp_seq = smi_seq::type_id::create("m_sysEvent_rsp_seq");
  endfunction // new

  extern function eMsgCMD get_random_cmdreq_msg();

  // Save packets
  extern function void construct_cmd_req_pkt(smi_ncore_unit_id_bit_t src_id);
  extern function void construct_dtw_req_pkt();
  extern function void construct_snp_rsp_pkt();
  extern function void construct_sysEvent_rsp_pkt();
  extern function void construct_str_rsp_pkt();
  extern function void construct_dtw_dbg_req_pkt(smi_ncore_unit_id_bit_t src_id, int timestamp=0);
  extern function void construct_sys_req_pkt(smi_ncore_unit_id_bit_t src_id, smi_sysreq_op_enum_t sys_req_op);
  extern function void save_cmd_rsp_pkt(const ref smi_seq_item rcvd_pkt);
  extern function void save_str_req_pkt(const ref smi_seq_item rcvd_pkt);
  extern function void save_dtw_rsp_pkt(const ref smi_seq_item rcvd_pkt);
  extern function void save_snp_req_pkt(const ref smi_seq_item rcvd_pkt);
  extern function void save_sysEvent_req_pkt(const ref smi_seq_item rcvd_pkt);
  extern function void save_cmp_rsp_pkt(const ref smi_seq_item rcvd_pkt);
  extern function void save_dtw_dbg_rsp_pkt(const ref smi_seq_item rcvd_pkt);
  extern function void save_sys_rsp_pkt(const ref smi_seq_item rcvd_pkt);
endclass // giu_cntr

//function void giu_cntr::save_cmd_req_pkt(const ref smi_seq_item rcvd_pkt);
//  cmd_req_pkt = new();
//  cmd_req_pkt.copy(rcvd_pkt);
//  t_cmd_req = $time;
//endfunction // save_cmd_req_pkt

function void giu_cntr::save_cmd_rsp_pkt(const ref smi_seq_item rcvd_pkt);
  m_cmd_rsp_pkt = new();
  m_cmd_rsp_pkt.copy(rcvd_pkt);
  t_cmd_rsp = $time;
endfunction // save_cmd_rsp_pkt

function void giu_cntr::save_str_req_pkt(const ref smi_seq_item rcvd_pkt);
  m_str_req_pkt = new();
  m_str_req_pkt.copy(rcvd_pkt);
  t_str_req = $time;
endfunction // save_str_req_pkt

function void giu_cntr::save_dtw_rsp_pkt(const ref smi_seq_item rcvd_pkt);
  m_dtw_rsp_pkt = new();
  m_dtw_rsp_pkt.copy(rcvd_pkt);
  t_dtw_rsp = $time;
endfunction // save_dtw_rsp_pkt

function void giu_cntr::save_snp_req_pkt(const ref smi_seq_item rcvd_pkt);
  m_snp_req_pkt = new();
  m_snp_req_pkt.copy(rcvd_pkt);

  t_snp_req_q.push_back($time);
  snp_req_pkt_q.push_back(m_snp_req_pkt);
endfunction // save_snp_req_pkt

function void giu_cntr::save_sysEvent_req_pkt(const ref smi_seq_item rcvd_pkt);
  m_sysEvent_req_pkt = new();
  m_sysEvent_req_pkt.copy(rcvd_pkt);

  t_sysEvent_req_q.push_back($time);
  sysEvent_req_pkt_q.push_back(m_sysEvent_req_pkt);

endfunction : save_sysEvent_req_pkt 

function void giu_cntr::save_cmp_rsp_pkt(const ref smi_seq_item rcvd_pkt);
  m_cmp_rsp_pkt = new();
  m_cmp_rsp_pkt.copy(rcvd_pkt);
  t_cmp_rsp = $time;
endfunction // save_cmp_rsp_pkt

function void giu_cntr::save_dtw_dbg_rsp_pkt(const ref smi_seq_item rcvd_pkt);
  m_dtw_dbg_rsp_pkt = new();
  m_dtw_dbg_rsp_pkt.copy(rcvd_pkt);
  t_dtw_dbg_rsp = $time;
endfunction // save_dtw_rsp_pkt

function void giu_cntr::save_sys_rsp_pkt(const ref smi_seq_item rcvd_pkt);
  m_sys_rsp_pkt = new();
  m_sys_rsp_pkt.copy(rcvd_pkt);
  t_sys_rsp = $time;
endfunction // save_sys_rsp_pkt


function eMsgCMD giu_cntr::get_random_cmdreq_msg();
  eMsgCMD msg_types[]='{
               eCmdRdCln,
               eCmdRdNShD,
               eCmdRdVld,
               eCmdRdUnq,
               eCmdClnUnq,
               eCmdMkUnq,
               eCmdRdNITC,
               eCmdClnVld,
               eCmdClnInv,
               eCmdMkInv,
               eCmdRdNC,
               eCmdDvmMsg,
               eCmdWrUnqPtl,
               eCmdWrUnqFull,
               eCmdWrAtm,
               eCmdRdAtm,
               eCmdWrBkFull,
               eCmdWrClnFull,
               eCmdWrEvict,
               eCmdEvict,
               eCmdWrBkPtl,
               eCmdWrClnPtl,
               eCmdWrNCPtl,
               eCmdWrNCFull,
               eCmdWrStshPtl,
               eCmdWrStshFull,
               eCmdLdCchShd,
               eCmdLdCchUnq,
               eCmdRdNITCClnInv,
               eCmdRdNITCMkInv,
               eCmdClnShdPer,
               eCmdSwAtm,
               eCmdCompAtm,
               eCmdPref
  };
  return msg_types[$urandom_range(0, msg_types.size() - 1)];
endfunction

function void giu_cntr::construct_cmd_req_pkt(smi_ncore_unit_id_bit_t src_id);
    smi_addr_t                  m_random_addr       = ($urandom() << 4);  // lower 4-bit can be 0
    smi_msg_id_t                m_random_msg_id     = $urandom();
    smi_ch_t                    ch_field;
    //#Stimulus.GIU.CmdReq.TgGIU_FUNIT_ID
    smi_cmstatus_err_t          m_cmstatus_err;
    smi_cmstatus_err_payload_t  m_cmstatus_err_pld;
    smi_msg_err_bit_t           smi_msg_err;
    smi_ncore_link_id_bit_t     ncore_link_id;
    smi_ncore_chiplet_id_bit_t  ncore_chiplet_id;
    smi_ncore_unit_id_bit_t     ncore_unit_id;
    smi_ncore_port_id_bit_t     ncore_port_id;
    smi_targ_id_bit_t           targt_id; //         = GIU_FUNIT_IDS[0];

    int inject_cmdreq_transport_err;

    t_cmd_req                                = $time;
    m_cmd_req_seq                            = smi_seq::type_id::create("m_cmd_req_seq");
    m_cmd_req_pkt                            = smi_seq_item::type_id::create("m_cmd_req_pkt");
    if (!$value$plusargs("inject_cmdreq_transport_err=%d", inject_cmdreq_transport_err)) begin
        inject_cmdreq_transport_err = 0;
    end
    if(inject_cmdreq_transport_err) begin
        m_cmstatus_err = 1'b1;
        m_cmstatus_err_pld = 7'b1000101;
        m_cmd_req_pkt.smi_cmstatus_err         = m_cmstatus_err;
        m_cmd_req_pkt.smi_cmstatus_err_payload = m_cmstatus_err_pld;
    end
    else begin
        void'(m_cmd_req_pkt.randomize() with{smi_cmstatus == 'h0;
                                    smi_cmstatus_err dist {1'b1 :/ k_cmd_cm_status_err_wgt, 1'b0 :/ 100-k_cmd_cm_status_err_wgt}; 
                                    if (smi_cmstatus_err == 0) smi_cmstatus_err_payload == 'h0;
                                    else smi_cmstatus_err_payload inside {[7'b1000001:7'b1000101]}; //Refer to table 4-4 in CCMP protocol
                                    smi_cmstatus_so == 'h0;
                                    smi_cmstatus_ss == 'h0;
                                    smi_cmstatus_sd == 'h0;
                                    smi_cmstatus_st == 'h0;
                                    smi_cmstatus_snarf == 'h0;
                                    smi_cmstatus_exok == 'h0;
                                    smi_cmstatus_rv == 'h0;
                                    smi_cmstatus_rs == 'h0;
                                    smi_cmstatus_dc == 'h0;
                                    smi_cmstatus_dt_aiu == 'h0;
                                    smi_cmstatus_dt_dmi == 'h0;
                                    smi_ndp_aux == 'h0;
                                    });  //FIXME: Randomize AUX bits and check it gets propagated to SnpReq
    end

    smi_msg_err = 0;
    if(k_cmd_msg_err_wgt > 0) begin
        if(($urandom()%100) < k_cmd_msg_err_wgt)
        smi_msg_err = 1;
    end

    if ($test$plusargs("inject_cmd_trgt_id_err")) begin
        targt_id = $urandom();
        if(targt_id == GIU_FUNIT_IDS[0]) begin
            targt_id = targt_id ^ {WSMINCOREUNITID{1'h1}};
        end
    end
    
    //#Stimulus.GIU.CmdReq
    //#Stimulus.GIU.MsgID
    //#Stimulus.GIU.TargetID
    //#Stimulus.GIU.SrcID
    // randomize the CH bit so if target is in DMI address space then the cmd is
    // sent to DMI if 0 and DCE if 1.  Long term we might not want this randomized
    // but more controlled.
    if (!std::randomize(ch_field)) begin
        `uvm_fatal("RAND", "CH field Randomization failed")
    end

    // randomize the TargetId field {LinkId, ChipletId, FUnitId, PortId}
    if (!std::randomize(ncore_link_id)) begin
        `uvm_fatal("RAND", "Target LinkId field Randomization failed")
    end 
    if (!std::randomize(ncore_chiplet_id)) begin
        `uvm_fatal("RAND", "Target ChipletId field Randomization failed")
    end 
    if (!std::randomize(ncore_unit_id)) begin
        `uvm_fatal("RAND", "Target FUnitId field Randomization failed")
    end 
    // PortId is always zero for Ncore 3.8
    ncore_port_id = 1'b0;

    targt_id = {
        ncore_link_id,
        ncore_chiplet_id,
        ncore_unit_id,
        ncore_port_id
        };

    // randomize the InitiatortId field {LinkId, ChipletId, FUnitId, PortId}
    if (!std::randomize(ncore_link_id)) begin
        `uvm_fatal("RAND", "Target LinkId field Randomization failed")
    end 
    if (!std::randomize(ncore_chiplet_id)) begin
        `uvm_fatal("RAND", "Target ChipletId field Randomization failed")
    end 
    if (!std::randomize(ncore_unit_id)) begin
        `uvm_fatal("RAND", "Target FUnitId field Randomization failed")
    end 

    src_id = {
        ncore_link_id,
        ncore_chiplet_id,
        ncore_unit_id,
        ncore_port_id
        };
    
    `uvm_info("EDS", $sformatf("CMDREQ src_id = %X, targt_id = %X",src_id,targt_id), UVM_NONE)

    m_cmd_req_pkt.construct_cmdmsg(
        .smi_steer              (m_cmd_req_pkt.smi_steer),
        .smi_targ_ncore_unit_id (targt_id),
        .smi_src_ncore_unit_id  (src_id), 
        .smi_msg_tier           (m_cmd_req_pkt.smi_msg_tier), 
        .smi_msg_qos            (m_cmd_req_pkt.smi_msg_qos), // In Header
        .smi_msg_pri            (m_cmd_req_pkt.smi_msg_pri), 
        .smi_msg_type           (get_random_cmdreq_msg), 
        .smi_msg_id             (m_random_msg_id),
        .smi_msg_err            (smi_msg_err), 
        .smi_cmstatus           ('h0), 
        .smi_addr               (m_random_addr), 
        .smi_vz                 ('h0), 
        .smi_ac                 ('h0), 
        .smi_ca                 ('h0), 
        .smi_ch                 (ch_field), 
        .smi_st                 (m_cmd_req_pkt.smi_st), 
        .smi_en                 (m_cmd_req_pkt.smi_en), 
        .smi_es                 ('h0), 
        .smi_ns                 (m_cmd_req_pkt.smi_ns), 
        .smi_pr                 (m_cmd_req_pkt.smi_pr), 
        .smi_order              ('h0), 
        .smi_lk                 (m_cmd_req_pkt.smi_lk), 
        .smi_rl                 (2'b01), 
        .smi_tm                 (m_cmd_req_pkt.smi_tm),
        .smi_mpf1_stash_valid   ('h0), 
        .smi_mpf1_stash_nid     ('h0), 
        .smi_mpf1_argv          ('h0), 
        .smi_mpf1_burst_type    ('h0), 
        .smi_mpf1_alength       ('h0), 
        .smi_mpf1_asize         ('h0),
        .smi_mpf1_awunique      ('h0),
        .smi_mpf2_stash_valid   ('h0), 
        .smi_mpf2_stash_lpid    ('h0), 
        .smi_mpf2_flowid_valid  ('h0), 
        .smi_mpf2_flowid        ('h0), 
        .smi_size               ('h3), 
        .smi_intfsize           (m_cmd_req_pkt.smi_intfsize), 
        .smi_dest_id            (m_cmd_req_pkt.smi_dest_id), 
        .smi_tof                ('h0), 
        .smi_qos                (m_cmd_req_pkt.smi_qos),  //QoS in Body
        .smi_ndp_aux            (m_cmd_req_pkt.smi_ndp_aux)  
    );
    if ($test$plusargs("inject_cmd_trgt_id_err")) begin
            ev_addr.trigger(m_cmd_req_pkt);  
    end
    m_cmd_req_seq.m_seq_item = m_cmd_req_pkt;
endfunction // construct_cmd_req_pkt

function void giu_cntr::construct_dtw_req_pkt();
  int num_data_beats = 1; // can't be more than 1 beat
  int msg_id_init_id;
  smi_dp_data_bit_t  m_random_data[] = new [num_data_beats];
  smi_dp_be_t        m_random_be[] = new [num_data_beats];
  bit                inject_dtw_dbad_err = 0;
  smi_cmstatus_err_t m_cmstatus_err;
  smi_cmstatus_err_payload_t m_cmstatus_err_pld;
  static int 	     dtw_pkt_cnt = 0;
  int 		     inject_dtw_dbad_err_pkt;
  int 		     inject_dtw_transport_err;
   
  //foreach(m_random_data[i]) begin
  //    m_random_data[i] = {$urandom,$urandom,$urandom,$urandom};
  //    m_random_be[i] = 16'hffff;
  //end

  if ($test$plusargs("inject_dtw_trgt_id_err")) begin
      m_str_req_pkt.smi_src_ncore_unit_id = $urandom();
  end

  if (!$value$plusargs("inject_dtw_transport_err=%d", inject_dtw_transport_err)) begin
      inject_dtw_transport_err = 0;
  end

  t_dtw_req = $time;
  //m_dtw_req_seq = smi_seq::type_id::create("m_dtw_req_seq");
  m_dtw_req_seq.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
  m_dtw_req_pkt = smi_seq_item::type_id::create("m_dtw_req_pkt");

  m_dtw_req_pkt.smi_dp_data  = new[m_random_data.size()];
  m_dtw_req_pkt.smi_dp_be    = new[m_random_be.size()];
  m_dtw_req_pkt.smi_dp_dwid  = new[m_dtw_req_pkt.smi_dp_data.size()];
  m_dtw_req_pkt.smi_dp_dbad  = new[m_dtw_req_pkt.smi_dp_data.size()];
  m_dtw_req_pkt.smi_dp_concuser = new[m_dtw_req_pkt.smi_dp_data.size()];
  m_dtw_req_pkt.smi_dp_protection = new[m_dtw_req_pkt.smi_dp_data.size()];
  foreach (m_dtw_req_pkt.smi_dp_data[i]) begin
    m_dtw_req_pkt.smi_dp_data[i] = $random;
    m_dtw_req_pkt.smi_dp_be[i] = 'hffff_ffff;
  end
  foreach (m_dtw_req_pkt.smi_dp_dwid[i]) begin
      m_dtw_req_pkt.smi_dp_dwid[i] = 'h0; 
      m_dtw_req_pkt.smi_dp_dbad[i] = 'h0;
      m_dtw_req_pkt.smi_dp_concuser[i] = 'h0;
  end

  if($test$plusargs("alt_dtw_dbad_err")) begin
     inject_dtw_dbad_err = (dtw_pkt_cnt%2) ? 1 : 0;  // inject dbad err on odd dtw packets
     `uvm_info(get_full_name(), $sformatf("DTW Pkt %0d: inject_dtw_dbad_err=%0d", dtw_pkt_cnt, inject_dtw_dbad_err), UVM_MEDIUM)
  end else if($value$plusargs("inj_dtw_dbad_err_pkt=%d", inject_dtw_dbad_err_pkt)) begin
     inject_dtw_dbad_err = (dtw_pkt_cnt==inject_dtw_dbad_err_pkt) ? 1 : 0;  // inject dbad err on specified dtw packet
     `uvm_info(get_full_name(), $sformatf("DTW Pkt %0d: inject_dtw_dbad_err=%0d", dtw_pkt_cnt, inject_dtw_dbad_err), UVM_MEDIUM)
  end else begin
     void'(std::randomize(inject_dtw_dbad_err) with {inject_dtw_dbad_err dist {1'b1 :/ k_dtw_dbad_err_wgt, 1'b0 :/ 100-k_dtw_dbad_err_wgt};});
  end
//  void'(std::randomize(m_dtw_req_pkt.smi_cmstatus_err) with {m_dtw_req_pkt.smi_cmstatus_err dist {1'b1 :/ k_dtw_cm_status_err_wgt, 1'b0 :/ 100-k_dtw_cm_status_err_wgt};});
//  void'(std::randomize(m_dtw_req_pkt.smi_cmstatus_err_payload) with {if (m_dtw_req_pkt.smi_cmstatus_err == 0) m_dtw_req_pkt.smi_cmstatus_err_payload == 'h0;
//  void'(std::randomize(y_cmstatus_err) with (m                               else m_dtw_req_pkt.smi_cmstatus_err_payload inside {[7'b0000010:7'b0000111], [7'b0100000:7'b0100000], [7'b0100101:7'b0100110], [7'b1000001:7'b1000101]};}); //Refer to table 4-4 in CCMP protocol};

  if(inject_dtw_transport_err) begin
     m_cmstatus_err = 1'b1;
     m_cmstatus_err_pld = 7'b1000101; 
  end
  else begin
  void'(std::randomize(m_cmstatus_err) with { m_cmstatus_err dist {1'b1 :/ k_dtw_cm_status_err_wgt, 1'b0 :/(100-k_dtw_cm_status_err_wgt) }; });
  void'(std::randomize(m_cmstatus_err_pld) with { (m_cmstatus_err == 0) -> m_cmstatus_err_pld == 0;
						  (m_cmstatus_err == 1) -> m_cmstatus_err_pld
						  inside {[7'b0000010:7'b0000111], [7'b0100000:7'b0100000], [7'b0100101:7'b0100110]};
						 } );
  end
  m_dtw_req_pkt.smi_cmstatus_err         = m_cmstatus_err;
  m_dtw_req_pkt.smi_cmstatus_err_payload = m_cmstatus_err_pld;

  if (inject_dtw_dbad_err) begin
      foreach (m_dtw_req_pkt.smi_dp_dwid[i]) begin
          m_dtw_req_pkt.smi_dp_dbad[i] = 1;
      end
  end
//#Stimulus.GIU.v3.2.construct_dtw_req_pkt
//#Stimulus.GIU.DTWreqMsgID
//#Stimulus.GIU.DTWreqSrcID
//#Stimulus.GIU.DTWreqTargetID
  m_dtw_req_pkt.construct_dtwmsg(
    .smi_targ_ncore_unit_id(m_str_req_pkt.smi_src_ncore_unit_id),
    .smi_src_ncore_unit_id(m_str_req_pkt.smi_targ_ncore_unit_id),
    .smi_msg_type(DTW_DATA_CLN),
    .smi_msg_id(m_cmd_req_pkt.smi_msg_id), 
    .smi_msg_tier('h0),
    .smi_steer('h0),
    .smi_msg_pri('h0),
    .smi_msg_qos('h0),
    .smi_rbid(m_str_req_pkt.smi_rbid),
    .smi_msg_err('h0),
    .smi_cmstatus('h0),
    .smi_rl('h1),
    .smi_tm(m_str_req_pkt.smi_tm),
    .smi_prim('h0),
//    .smi_mpf1_stash_nid('h0),
//    .smi_mpf1_argv('h0),
    .smi_mpf1('h0),
    .smi_mpf2('h0),
//    .smi_rmsg_id(m_str_req_pkt.smi_msg_id), 
    .smi_intfsize(0),   // FIXME: WHAT the value should be
    .smi_ndp_aux(m_str_req_pkt.smi_ndp_aux),
    .smi_dp_last('h1),
    .smi_dp_data(m_dtw_req_pkt.smi_dp_data),
    .smi_dp_be(m_dtw_req_pkt.smi_dp_be),
    .smi_dp_protection(m_dtw_req_pkt.smi_dp_protection),
    .smi_dp_dwid(m_dtw_req_pkt.smi_dp_dwid),
    .smi_dp_dbad(m_dtw_req_pkt.smi_dp_dbad),
    .smi_dp_concuser(m_dtw_req_pkt.smi_dp_concuser)
  );

//  `uvm_info(get_type_name(), $psprintf("construct_dtw_req_pkt: smi_msg_id = 0x%0h and SrcId : %0h", m_cmd_req_pkt.smi_msg_id,m_str_req_pkt.smi_targ_ncore_unit_id), UVM_NONE)
  ev.trigger(m_dtw_req_pkt);  
  if ($test$plusargs("inject_dtw_trgt_id_err")) begin
        ev_addr.trigger(m_dtw_req_pkt);  
  end
  m_dtw_req_seq.m_seq_item = m_dtw_req_pkt;
   dtw_pkt_cnt = dtw_pkt_cnt + 1;
endfunction // construct_dtw_req_pkt

function void giu_cntr::construct_dtw_dbg_req_pkt(smi_ncore_unit_id_bit_t src_id, int timestamp=0);
  int num_data_beats = 8;
  smi_msg_id_t m_random_msg_id                    = $urandom();
  smi_ncore_unit_id_bit_t targt_id          = GIU_FUNIT_IDS[0];
  smi_dp_data_bit_t  m_random_data[] = new [num_data_beats];
  smi_dp_be_t        m_random_be[] = new [num_data_beats];
  bit                inject_dtw_dbad_err = 0;
  smi_cmstatus_err_t m_cmstatus_err;
  smi_cmstatus_err_payload_t m_cmstatus_err_pld;
  static int 	     dtw_dbg_pkt_cnt = 0;
  int 		     inject_dtw_dbad_err_pkt;

  //foreach(m_random_data[i]) begin
  //    m_random_data[i] = {$urandom,$urandom,$urandom,$urandom};
  //    m_random_be[i] = 16'hffff;
  //end

  if ($test$plusargs("inject_dtw_trgt_id_err")) begin
      m_str_req_pkt.smi_src_ncore_unit_id = $urandom();
  end

  t_dtw_dbg_req = $time;
  //m_dtw_dbg_req_seq = smi_seq::type_id::create("m_dtw_dbg_req_seq");
  m_dtw_dbg_req_seq.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
  m_dtw_dbg_req_pkt = smi_seq_item::type_id::create("m_dtw_dbg_req_pkt");

  void'(m_dtw_dbg_req_pkt.randomize() with{smi_cmstatus == 'h0;
                                 smi_cmstatus_err dist {1'b1 :/ k_cmd_cm_status_err_wgt, 1'b0 :/ 100-k_cmd_cm_status_err_wgt}; 
                                 if (smi_cmstatus_err == 0) smi_cmstatus_err_payload == 'h0;
                                 else smi_cmstatus_err_payload inside {[7'b1000001:7'b1000101]}; //Refer to table 4-4 in CCMP protocol
                                 smi_cmstatus_so == 'h0;
                                 smi_cmstatus_ss == 'h0;
                                 smi_cmstatus_sd == 'h0;
                                 smi_cmstatus_st == 'h0;
                                 smi_cmstatus_snarf == 'h0;
                                 smi_cmstatus_exok == 'h0;
                                 smi_cmstatus_rv == 'h0;
                                 smi_cmstatus_rs == 'h0;
                                 smi_cmstatus_dc == 'h0;
                                 smi_cmstatus_dt_aiu == 'h0;
                                 smi_cmstatus_dt_dmi == 'h0;
                                 smi_ndp_aux == 'h0;});  //FIXME: Randomize AUX bits and check it gets propagated to SnpReq

  m_dtw_dbg_req_pkt.smi_dp_data  = new[m_random_data.size()];
  m_dtw_dbg_req_pkt.smi_dp_be    = new[m_random_be.size()];
  m_dtw_dbg_req_pkt.smi_dp_dwid  = new[m_dtw_dbg_req_pkt.smi_dp_data.size()];
  m_dtw_dbg_req_pkt.smi_dp_dbad  = new[m_dtw_dbg_req_pkt.smi_dp_data.size()];
  m_dtw_dbg_req_pkt.smi_dp_concuser = new[m_dtw_dbg_req_pkt.smi_dp_data.size()];
  m_dtw_dbg_req_pkt.smi_dp_protection = new[m_dtw_dbg_req_pkt.smi_dp_data.size()];
  foreach (m_dtw_dbg_req_pkt.smi_dp_data[i]) begin
    m_dtw_dbg_req_pkt.smi_dp_data[i] = {$urandom, $urandom}; // we need 64 bits
    m_dtw_dbg_req_pkt.smi_dp_be[i] = 'hffff_ffff;
  end
  if(timestamp != 0) begin
    // use timestamp suggested by sequencer
    m_dtw_dbg_req_pkt.smi_dp_data[0][31:0] = timestamp;
  end
  foreach (m_dtw_dbg_req_pkt.smi_dp_dwid[i]) begin
      m_dtw_dbg_req_pkt.smi_dp_dwid[i] = 'h0; 
      m_dtw_dbg_req_pkt.smi_dp_dbad[i] = 'h0;
      m_dtw_dbg_req_pkt.smi_dp_concuser[i] = 'h0;
  end

//  if($test$plusargs("alt_dtw_dbad_err")) begin
//     inject_dtw_dbad_err = (dtw_pkt_cnt%2) ? 1 : 0;  // inject dbad err on odd dtw packets
//     `uvm_info(get_full_name(), $sformatf("DTW Pkt %0d: inject_dtw_dbad_err=%0d", dtw_pkt_cnt, inject_dtw_dbad_err), UVM_MEDIUM)
//  end else if($value$plusargs("inj_dtw_dbad_err_pkt=%d", inject_dtw_dbad_err_pkt)) begin
//     inject_dtw_dbad_err = (dtw_pkt_cnt==inject_dtw_dbad_err_pkt) ? 1 : 0;  // inject dbad err on specified dtw packet
//     `uvm_info(get_full_name(), $sformatf("DTW Pkt %0d: inject_dtw_dbad_err=%0d", dtw_pkt_cnt, inject_dtw_dbad_err), UVM_MEDIUM)
//  end else begin
//     void'(std::randomize(inject_dtw_dbad_err) with {inject_dtw_dbad_err dist {1'b1 :/ k_dtw_dbad_err_wgt, 1'b0 :/ 100-k_dtw_dbad_err_wgt};});
//  end

//  void'(std::randomize(m_dtw_dbg_req_pkt.smi_cmstatus_err) with {m_dtw_dbg_req_pkt.smi_cmstatus_err dist {1'b1 :/ k_dtw_cm_status_err_wgt, 1'b0 :/ 100-k_dtw_cm_status_err_wgt};});
//  void'(std::randomize(m_dtw_dbg_req_pkt.smi_cmstatus_err_payload) with {if (m_dtw_dbg_req_pkt.smi_cmstatus_err == 0) m_dtw_dbg_req_pkt.smi_cmstatus_err_payload == 'h0;
//  void'(std::randomize(y_cmstatus_err) with (m                               else m_dtw_dbg_req_pkt.smi_cmstatus_err_payload inside {[7'b0000010:7'b0000111], [7'b0100000:7'b0100000], [7'b0100101:7'b0100110], [7'b1000001:7'b1000101]};}); //Refer to table 4-4 in CCMP protocol};

  void'(std::randomize(m_cmstatus_err) with { m_cmstatus_err dist {1'b1 :/ k_dtw_cm_status_err_wgt, 1'b0 :/(100-k_dtw_cm_status_err_wgt) }; });
  void'(std::randomize(m_cmstatus_err_pld) with { (m_cmstatus_err == 0) -> m_cmstatus_err_pld == 0;
						  (m_cmstatus_err == 1) -> m_cmstatus_err_pld
						  inside {[7'b0000010:7'b0000111], [7'b0100000:7'b0100000], [7'b0100101:7'b0100110], [7'b1000001:7'b1000101]};
						 } );
//  m_dtw_dbg_req_pkt.smi_cmstatus_err         = m_cmstatus_err;
//  m_dtw_dbg_req_pkt.smi_cmstatus_err_payload = m_cmstatus_err_pld;

//  if (inject_dtw_dbad_err) begin
//      foreach (m_dtw_dbg_req_pkt.smi_dp_dwid[i]) begin
//          m_dtw_dbg_req_pkt.smi_dp_dbad[i] = 1;
//      end
//  end

  if ($test$plusargs("inject_dtw_dbg_trgt_id_err")) begin
     targt_id = $urandom();
     if(targt_id == GIU_FUNIT_IDS[0]) begin
	targt_id = targt_id ^ {WSMINCOREUNITID{1'h1}};
     end
  end

  m_dtw_dbg_req_pkt.construct_dtwdbgmsg(
    .smi_targ_ncore_unit_id(targt_id),
    .smi_src_ncore_unit_id(src_id),
    .smi_msg_type(DTW_DBG_REQ),
    .smi_msg_id(m_random_msg_id), 
    .smi_msg_tier('h0),
    .smi_steer('h0),
    .smi_msg_pri('h0),
    .smi_msg_qos('h0),
    .smi_msg_err('h0),
    .smi_cmstatus('h0),
    .smi_rl(2'b01),
    .smi_tm('h0),
    .smi_ndp_aux(m_dtw_dbg_req_pkt.smi_ndp_aux),
    .smi_dp_last('h1),
    .smi_dp_data(m_dtw_dbg_req_pkt.smi_dp_data),
    .smi_dp_be(m_dtw_dbg_req_pkt.smi_dp_be),
    .smi_dp_protection(m_dtw_dbg_req_pkt.smi_dp_protection),
    .smi_dp_dwid(m_dtw_dbg_req_pkt.smi_dp_dwid),
    .smi_dp_dbad(m_dtw_dbg_req_pkt.smi_dp_dbad),
    .smi_dp_concuser(m_dtw_dbg_req_pkt.smi_dp_concuser)
  );

  `uvm_info(get_type_name(), $psprintf("construct_dtw_dbg_req_pkt: smi_msg_id = 0x%0h and SrcId : %0h", m_dtw_dbg_req_pkt.smi_msg_id, src_id), UVM_NONE)
   ev_addr.trigger(m_dtw_dbg_req_pkt);
  if ($test$plusargs("inject_dtw_dbg_trgt_id_err")) begin
        ev_addr.trigger(m_dtw_dbg_req_pkt);
  end
  m_dtw_dbg_req_seq.m_seq_item = m_dtw_dbg_req_pkt;
  dtw_dbg_pkt_cnt = dtw_dbg_pkt_cnt + 1;
endfunction // construct_dtw_dbg_req_pkt

function void giu_cntr::construct_snp_rsp_pkt();
  smi_cmstatus_err_t         m_cmstatus_err;
  smi_cmstatus_err_payload_t m_cmstatus_err_pld;
  int 		     inject_snprsp_transport_err;

  if (!$value$plusargs("inject_snprsp_transport_err=%d", inject_snprsp_transport_err)) begin
      inject_snprsp_transport_err = 0;
  end

  t_snp_rsp = $time;

  m_snp_rsp_seq = smi_seq::type_id::create("m_snp_rsp_seq");
  m_snp_rsp_pkt = smi_seq_item::type_id::create("m_snp_rsp_pkt");

  if ($test$plusargs("inject_snp_trgt_id_err")) begin
      m_snp_req_pkt.smi_src_ncore_unit_id = $urandom();
  end

  if(inject_snprsp_transport_err) begin
     m_cmstatus_err = 1'b1;
     m_cmstatus_err_pld = 7'b1000101; 
  end
  else begin
  void'(std::randomize(m_cmstatus_err) with { m_cmstatus_err dist {1'b1 :/ k_snp_rsp_err_wgt, 1'b0 :/ (100-k_snp_rsp_err_wgt) }; });
  void'(std::randomize(m_cmstatus_err_pld) with {if (m_cmstatus_err == 0) m_cmstatus_err_pld == 'h0;
                                 else m_cmstatus_err_pld inside {[7'b0000010:7'b0000111], [7'b0100000:7'b0100000], [7'b0100101:7'b0100110]};}); //Refer to table 4-4 in CCMP protocol};
  end
   
  m_snp_rsp_pkt.smi_cmstatus_err         = m_cmstatus_err;
  m_snp_rsp_pkt.smi_cmstatus_err_payload = m_cmstatus_err_pld;
//#Stimulus.GIU.v3.2.construct_snprsp
  m_snp_rsp_pkt.construct_snprsp(
    .smi_targ_ncore_unit_id(m_snp_req_pkt.smi_src_ncore_unit_id),
    .smi_src_ncore_unit_id(m_snp_req_pkt.smi_targ_ncore_unit_id),
    .smi_msg_type(SNP_RSP),
    .smi_msg_id('h0),
    .smi_msg_tier('h0),
    .smi_steer('h0),
    .smi_msg_pri('h0),
    .smi_msg_qos('h0),
    .smi_msg_err('h0),
    .smi_cmstatus           ('h0), // (cmstatus),
    .smi_cmstatus_rv        ('h0), // (cmstatus[5]),
    .smi_cmstatus_rs        ('h0), // (cmstatus[4]),
    .smi_cmstatus_dc        ('h0), // (cmstatus[3]),
    .smi_cmstatus_dt_aiu    ('h0), // (cmstatus[2]),
    .smi_cmstatus_dt_dmi    ('h0), // (cmstatus[1]),
    .smi_cmstatus_snarf     ('h0), // (cmstatus[0]),
    .smi_tm                 (m_snp_req_pkt.smi_tm),
    .smi_rmsg_id            (m_snp_req_pkt.smi_msg_id),
    .smi_mpf1_dtr_msg_id    ('h0),
    .smi_intfsize('h0)
  );

  if ($test$plusargs("inject_snp_trgt_id_err")) begin
      ev_addr.trigger(m_snp_rsp_pkt);
  end
  m_snp_rsp_seq.m_seq_item = m_snp_rsp_pkt;
endfunction // construct_snp_rsp_pkt


function void giu_cntr::construct_sysEvent_rsp_pkt();
  smi_cmstatus_err_t         m_cmstatus_err;
  smi_cmstatus_err_payload_t m_cmstatus_err_pld;
  int 		     inject_snprsp_transport_err;

  // if (!$value$plusargs("inject_snprsp_transport_err=%d", inject_snprsp_transport_err)) begin
  //     inject_snprsp_transport_err = 0;
  // end

  t_sysEvent_rsp = $time;

  m_sysEvent_rsp_seq = smi_seq::type_id::create("m_snp_rsp_seq");
  m_sysEvent_rsp_pkt = smi_seq_item::type_id::create("m_snp_rsp_pkt");

  // if ($test$plusargs("inject_snp_trgt_id_err")) begin
  //     m_snp_req_pkt.smi_src_ncore_unit_id = $urandom();
  // end

  // if(inject_snprsp_transport_err) begin
  //    m_cmstatus_err = 1'b1;
  //    m_cmstatus_err_pld = 7'b1000101; 
  // end
  // else begin
  // void'(std::randomize(m_cmstatus_err) with { m_cmstatus_err dist {1'b1 :/ k_snp_rsp_err_wgt, 1'b0 :/ (100-k_snp_rsp_err_wgt) }; });
  // void'(std::randomize(m_cmstatus_err_pld) with {if (m_cmstatus_err == 0) m_cmstatus_err_pld == 'h0;
  //                                else m_cmstatus_err_pld inside {[7'b0000010:7'b0000111], [7'b0100000:7'b0100000], [7'b0100101:7'b0100110]};}); //Refer to table 4-4 in CCMP protocol};
  // end
   
  // m_snp_rsp_pkt.smi_cmstatus_err         = m_cmstatus_err;
  // m_snp_rsp_pkt.smi_cmstatus_err_payload = m_cmstatus_err_pld;
//#Stimulus.GIU.v3.2.construct_snprsp
  m_sysEvent_rsp_pkt.construct_sysrsp(
    .smi_targ_ncore_unit_id(m_sysEvent_req_pkt.smi_src_ncore_unit_id),
    .smi_src_ncore_unit_id(m_sysEvent_req_pkt.smi_targ_ncore_unit_id),
    .smi_msg_type(SYS_RSP),
    .smi_msg_id('h0),
    .smi_msg_tier('h0),
    .smi_steer('h0),
    .smi_msg_pri('h0),
    .smi_msg_qos('h0),
    .smi_tm (m_sysEvent_req_pkt.smi_tm),
    .smi_rmsg_id (m_sysEvent_req_pkt.smi_msg_id),
    .smi_msg_err('h0),
    .smi_cmstatus ('h0), // (cmstatus),
    .smi_ndp_aux ('h0)
  );

  // if ($test$plusargs("inject_snp_trgt_id_err")) begin
  //     ev_addr.trigger(m_snp_rsp_pkt);
  // end
  m_sysEvent_rsp_seq.m_seq_item = m_sysEvent_rsp_pkt;
endfunction // construct_syEvent_rsp_pkt

//#Stimulus.GIU.v3.2.construct_str_rsp_pkt
function void giu_cntr::construct_str_rsp_pkt();
  t_str_rsp = $time;

  m_str_rsp_seq = smi_seq::type_id::create("m_str_rsp_seq");
  m_str_rsp_pkt = smi_seq_item::type_id::create("m_str_rsp_pkt");

  if ($test$plusargs("inject_str_trgt_id_err")) begin
      m_str_req_pkt.smi_src_ncore_unit_id = $urandom();
  end

  void'(std::randomize(m_str_rsp_pkt.smi_cmstatus_err) with {m_str_rsp_pkt.smi_cmstatus_err dist {1'b1 :/ k_str_rsp_err_wgt, 1'b0 :/ 100-k_str_rsp_err_wgt};});
  void'(std::randomize(m_str_rsp_pkt.smi_cmstatus_err_payload) with {if (m_str_rsp_pkt.smi_cmstatus_err == 0) m_str_rsp_pkt.smi_cmstatus_err_payload == 'h0;
							     else m_str_rsp_pkt.smi_cmstatus_err_payload inside {[7'b0000010:7'b0000111], [7'b0100000:7'b0100000], [7'b0100101:7'b0100110]};}); //Refer to table 4-4 in CCMP protocol};

  m_str_rsp_pkt.construct_strrsp(
    .smi_steer              ('h0),
    .smi_targ_ncore_unit_id (m_str_req_pkt.smi_src_ncore_unit_id),
    .smi_src_ncore_unit_id  (m_str_req_pkt.smi_targ_ncore_unit_id),
    .smi_msg_tier           ('h0),
    .smi_msg_qos            ('h0),
    .smi_msg_pri            ('h0),
    .smi_msg_type           (STR_RSP),
    .smi_msg_id             ('h0),
    .smi_msg_err            ('h0),
    .smi_cmstatus           ('h0), // ({5'h0,cmstatus[1:0]}),
    .smi_tm                 (m_str_req_pkt.smi_tm),
    .smi_rmsg_id            (m_str_req_pkt.smi_msg_id)
//    .smi_mpf2_dtr_msg_id    ('h0),
//    .smi_intfsize           ('h0)
  );

  if ($test$plusargs("inject_str_trgt_id_err")) begin
      ev_addr.trigger(m_str_rsp_pkt);
  end
  m_str_rsp_seq.m_seq_item = m_str_rsp_pkt;
endfunction // construct_str_rsp_pkt

function void giu_cntr::construct_sys_req_pkt(smi_ncore_unit_id_bit_t src_id, smi_sysreq_op_enum_t sys_req_op);
  smi_ncore_unit_id_bit_t targt_id         = GIU_FUNIT_IDS[0];
  smi_msg_id_bit_t  my_msg_id = 'h0;
  t_sys_req                                = $time;
  m_sys_req_seq                            = smi_seq::type_id::create("m_sys_req_seq");
  m_sys_req_pkt                            = smi_seq_item::type_id::create("m_sys_req_pkt");
 

  // Seting msg ID =  1 for Event Req and 0 for Sys Req
  if(sys_req_op == 3'h3)
   my_msg_id ='h1;
  else
   my_msg_id ='h0;
  void'(m_sys_req_pkt.randomize() with{smi_cmstatus == 'h0;
                                 smi_cmstatus_err dist {1'b1 :/ k_sysreq_cm_status_err_wgt, 1'b0 :/ 100-k_sysreq_cm_status_err_wgt}; 
                                 if (smi_cmstatus_err == 0) smi_cmstatus_err_payload == 'h0;
                                 else smi_cmstatus_err_payload inside {[7'b0000010:7'b0000111], [7'b1000001:7'b1000101]}; //Refer to table 4-4 in CCMP protocol
                                 smi_cmstatus_so == 'h0;
                                 smi_cmstatus_ss == 'h0;
                                 smi_cmstatus_sd == 'h0;
                                 smi_cmstatus_st == 'h0;
                                 smi_cmstatus_snarf == 'h0;
                                 smi_cmstatus_exok == 'h0;
                                 smi_cmstatus_rv == 'h0;
                                 smi_cmstatus_rs == 'h0;
                                 smi_cmstatus_dc == 'h0;
                                 smi_cmstatus_dt_aiu == 'h0;
                                 smi_cmstatus_dt_dmi == 'h0;
                                 smi_ndp_aux == 'h0;});  //FIXME: Randomize AUX bits and check it gets propagated to SnpReq

  if ($test$plusargs("inject_cmd_trgt_id_err") || $test$plusargs("inject_sys_trgt_id_err")) begin
     targt_id = $urandom();
     if(targt_id == GIU_FUNIT_IDS[0]) begin
	targt_id = targt_id ^ {WSMINCOREUNITID{1'h1}};
     end
  end
  m_sys_req_pkt.construct_sysmsg(
      .smi_targ_ncore_unit_id (targt_id),
      .smi_src_ncore_unit_id  (src_id), 
      .smi_msg_type           (SYS_REQ), 
      .smi_msg_id             (my_msg_id),
      .smi_rmsg_id            (my_msg_id),
      .smi_msg_tier           (m_sys_req_pkt.smi_msg_tier), 
      .smi_steer              (m_sys_req_pkt.smi_steer),
      .smi_msg_qos            (m_sys_req_pkt.smi_msg_qos),
      .smi_msg_pri            (m_sys_req_pkt.smi_msg_pri), 
      .smi_msg_err            ('h0), 
      .smi_cmstatus           ('h0), 
      .smi_sysreq_op          (sys_req_op),
      .smi_ndp_aux            (m_sys_req_pkt.smi_ndp_aux)
  );
  if ($test$plusargs("inject_cmd_trgt_id_err") || $test$plusargs("inject_sys_trgt_id_err")) begin
        ev_addr.trigger(m_sys_req_pkt);  
  end
  m_sys_req_seq.m_seq_item = m_sys_req_pkt;
endfunction // construct_sys_req_pkt
