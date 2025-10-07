

//
//DCE SMI Slave Base Sequence
//
class dce_slv_base_seq extends uvm_sequence#(smi_seq_item);

  `uvm_object_utils(dce_slv_base_seq)

  //Properties
  uvm_phase      m_phase;
  dce_container  m_dce_cntr;
  dce_unit_args  m_unit_args;
  smi_sequencer  m_smi_tx_port;
  smi_sequencer  m_smi_rx_port;
  smi_seq_item   m_smi_rsps[$];
  smi_seq_item   m_smi_rbreq_q[$];
  int            m_att_rbid_map[int][int];
  event          e_single_step;
  dce_scb        m_scb;
  addr_width_t bit_mask_const = 'h1_FFFF_FFFF_FFFF << ncoreConfigInfo::WCACHE_OFFSET;

  //Local flags
  local bit m_handles_fwded;
  local bit m_seqrs_fwded;  
  local int wait_iteration;

  //Methods
  extern function new(string name = "dce_slv_base_seq");
  extern function void get_handles(ref uvm_phase phase, ref dce_container container, ref dce_unit_args unit_args);
  extern function void get_seqrs(const ref smi_sequencer tx_port, const ref smi_sequencer rx_port);
  extern task body();

  //Internal Methods
  extern task receive_smi_msgs();
  extern task issue_smi_msgs();
  extern task apply_random_delay();
  extern task send_rb_rsp();
  
  extern function void construct_snp_rsp(const ref smi_seq_item snpreq);
  extern function void construct_mrd_rsp(const ref smi_seq_item mrdreq);
  extern function void construct_str_rsp(const ref smi_seq_item strreq);
  extern function void construct_rbr_rsp(          smi_seq_item rbrreq);
  extern function void construct_sys_rsp(const ref smi_seq_item sysreq);
  extern function void get_scb_handle();
endclass: dce_slv_base_seq

function dce_slv_base_seq::new(string name = "dce_slv_base_seq");
  super.new(name);
  wait_iteration = 0;
endfunction: new

function void dce_slv_base_seq::get_handles(ref uvm_phase phase, ref dce_container container, ref dce_unit_args unit_args);

  m_phase    = phase;
  m_dce_cntr = container;
  m_unit_args = unit_args;
  m_handles_fwded = 1;
endfunction: get_handles

function void dce_slv_base_seq::get_seqrs(const ref smi_sequencer tx_port, const ref smi_sequencer rx_port);

  m_smi_tx_port = tx_port;
  m_smi_rx_port = rx_port;
  m_seqrs_fwded = 1;
endfunction: get_seqrs

function void dce_slv_base_seq::get_scb_handle();
      if (!uvm_config_db#(dce_scb)::get(.cntxt( null ),
                                              .inst_name( "*" ),
                                              .field_name( "dce_sb" ),
                                              .value( m_scb ))) begin
         `uvm_error("dce_ral_csr_base_seq", "dce_scb handle not found")
      end
endfunction: get_scb_handle
//*****************************************************************
task dce_slv_base_seq::body();
  `ASSERT(m_handles_fwded && m_seqrs_fwded);
  fork
    begin //Thread that receives SMI req messages SNP+STR, MRD+HNT+RBREQ
      forever 
        receive_smi_msgs();
    end
    begin //Thread that issues SMI rsp messages SNP+STR, MRD+HNT
      forever begin
        apply_random_delay();
        if (m_smi_rsps.size()) begin
          issue_smi_msgs();
        end
      end
    end
    begin
        send_rb_rsp();
    end
  join_none
endtask: body

//******************************************************************
task dce_slv_base_seq::send_rb_rsp();
    smi_seq_item rbr_req;
    logic shuffle_rsp = $random();
    
    forever begin
        wait(m_smi_rbreq_q.size() > 0);
        #($urandom_range(100,500)*<%=obj.Clocks[0].params.period%>ps);
        if(shuffle_rsp) m_smi_rbreq_q.shuffle();
        rbr_req = m_smi_rbreq_q.pop_front();
        construct_rbr_rsp(rbr_req);
    end
endtask: send_rb_rsp

//******************************************************************
task dce_slv_base_seq::receive_smi_msgs();
 smi_seq_item req_item;
 int idxq[$], cohreq_idxq[$];
 bit valid_tgt_identified;
 int j, prob;
 int sys_rsp_delay, min_delay, max_delay;
 ncore_cache_state_t req_state;

  m_smi_rx_port.m_rx_analysis_fifo.get(req_item);

  //get_scb_handle(); 

  //`uvm_info("DCE_SLV_SEQ", $psprintf("Received REQ %0s", req_item.convert2string()), UVM_LOW)
  if (m_scb != null) begin 
    if (m_scb.garbage_dmiid) begin
        `uvm_info("DCE SLV SEQ", "Do not issue any Rsps since garbage_dmiid is set", UVM_LOW)
        return;
    end
  end

  req_item.unpack_smi_seq_item();

  case (req_item.smi_conc_msg_class)
    eConcMsgSnpReq:   begin
                          if(req_item.smi_msg_type inside {eSnpStshShd, eSnpStshUnq}) begin
                              idxq = m_dce_cntr.m_inflight_txns.find_index(x) with (x.is_msgid_inuse() && (x.get_addr() == {req_item.smi_ns, req_item.smi_addr}) && (dce_goldenref_model::is_stash_read(x.get_msg_type())) );
                              //Check inly one entry exists
                              if (idxq.size() == 0) begin
                                //foreach( m_dce_cntr.m_inflight_txns[i]) `uvm_info("DCE SLV SEQ",$sformatf("%0d : %0s",i,m_dce_cntr.m_inflight_txns[i].convert2string),UVM_LOW)
                                idxq = m_dce_cntr.m_inflight_txns.find_index(x) with (!x.is_msgid_inuse() && (x.get_addr() == {req_item.smi_ns, req_item.smi_addr}) && (dce_goldenref_model::is_stash_read(x.get_msg_type())) );
                                if(idxq.size() == 0)
                                    `uvm_error("DCE SLV SEQ", "No match for SnpReq")
                              end
                              //since we are filtering out based on address, we can be sure to set the 1st match, and ignore subsequent matches, since they are sleeping
                              else if (idxq.size() > 1) begin
                      //          foreach( idxq[i]) `uvm_info("DCE SLV SEQ",$sformatf("%0d : %0s",i,m_dce_cntr.m_inflight_txns[idxq[i]].convert2string),UVM_LOW)
                      //          `uvm_error("DCE SLV SEQ", "More than one match for SnpReq") 
                      //        end 
                      //        else begin
                                 // set the SnpRecvd flag
                                 m_dce_cntr.m_inflight_txns[idxq[0]].set_snpreq_rcvd(req_item.smi_msg_id, req_item.smi_rbid);
                                 //if(m_dce_cntr.m_inflight_txns[idxq[0]].get_strreq_flag) m_dce_cntr.release_msgid(m_dce_cntr.m_inflight_txns[idxq[0]].get_master_id(), m_dce_cntr.m_inflight_txns[idxq[0]].get_msg_id());
                              end
                          end
                          construct_snp_rsp(req_item);
                      end
    eConcMsgMrdReq:   construct_mrd_rsp(req_item);
    eConcMsgStrReq:   begin
                            if (m_scb != null) begin
                                if(!(m_scb.num_smi_uncorr_err>0 || m_scb.num_smi_parity_err>0)) begin
                                    idxq = m_scb.m_dce_txnq.find_index(item) with (    (item.m_req_type == CMD_REQ)
                                                                                    && (item.m_initcmdupd_req_pkt.smi_msg_id == req_item.smi_rmsg_id) 
                                                                                    && (item.m_initcmdupd_req_pkt.smi_src_ncore_unit_id == req_item.smi_targ_ncore_unit_id) 
                                                                                    && (item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP})
                                                                                    && (item.m_attid == req_item.smi_msg_id)
                                                                                    && (item.m_dm_pktq.size() != 0));
                                
                                    if (idxq.size() == 0 && ($test$plusargs("wrong_rbrsp_target_id") || $test$plusargs("wrong_mrdrsp_target_id"))) begin
                                        return;
                                    end else if (idxq.size() != 1) begin
                                        `uvm_error("DCE_SLV_SEQ", $psprintf("Incorrect matches in scb for the rmsgid of StrReq since idxq.size:%0d",idxq.size()))
                                    end
    

                                    if (    dce_goldenref_model::is_stash_request(m_scb.m_dce_txnq[idxq[0]].m_cmd_type) 
                                         && m_scb.m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_mpf1_stash_valid
                                         && (m_scb.m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_mpf1_stash_nid inside {ncoreConfigInfo::stash_nids,ncoreConfigInfo::stash_nids_ace_aius})
                                         && ncoreConfigInfo::is_stash_enable(ncoreConfigInfo::agentid_assoc2funitid(m_scb.m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_mpf1_stash_nid))) begin
                                        valid_tgt_identified = 1;
                                    end else begin
                                        valid_tgt_identified = 0;
                                    end
                            if(m_scb.m_dce_txnq[idxq[0]].dtrreq == DtrDataUCln)
                                req_state = UC;
                            else if(m_scb.m_dce_txnq[idxq[0]].dtrreq == DtrDataSCln)
                                req_state = SC;
                            else if(m_scb.m_dce_txnq[idxq[0]].dtrreq == DtrDataUDty)
                                req_state = UD;
                            else if(m_scb.m_dce_txnq[idxq[0]].dtrreq == DtrDataSDty)
                                req_state = SD;
                            else
                                req_state = IX; //Ignore case
                    //`uvm_info("DCE_SLV_SEQ_DBG", $psprintf("value of str_cm_state: %p",req_item.smi_cmstatus_state),UVM_LOW)
                                    m_dce_cntr.predict_master_final_state(req_item.smi_targ_ncore_unit_id, req_item.smi_rmsg_id, req_item.smi_cmstatus_exok, m_scb.m_dce_txnq[idxq[0]].m_dm_pktq[m_scb.m_dce_txnq[idxq[0]].m_dm_pktq.size() - 1].m_owner_val, valid_tgt_identified, req_state,req_item.smi_cmstatus_state);

                                    idxq.delete();
                                end //if !(m_scb.num_smi_uncorr_err>0 || m_scb.num_smi_parity_err>0)
                          end //if m_scb != null
                          
                          idxq = m_dce_cntr.m_inflight_txns.find_index(x) with (x.is_msgid_inuse() && (x.get_msg_id() == req_item.smi_rmsg_id) && (x.get_master_id() == ncoreConfigInfo::agentid_assoc2funitid(req_item.smi_targ_ncore_unit_id)));
                          
                          //Check inly one entry exists
                          if (idxq.size() == 0)
                            `uvm_error("DCE SLV SEQ", "No match for StrReq")
                          else if (idxq.size() > 1)
                            `uvm_error("DCE SLV SEQ", "More than one match for StrReq")

                          m_dce_cntr.m_inflight_txns[idxq[0]].set_strreq_rcvd(req_item.smi_msg_id, req_item.smi_rbid);
                          
                          // always release msg_id on STRreq
                          m_dce_cntr.release_msgid(req_item.smi_targ_ncore_unit_id, req_item.smi_rmsg_id);

                          m_dce_cntr.update_outstanding_addrq(0, req_item.smi_targ_ncore_unit_id, (m_dce_cntr.m_inflight_txns[idxq[0]].get_addr() & bit_mask_const));
                          construct_str_rsp(req_item);

                          if ($test$plusargs("en_silent_cache_st_transition")) begin 
                             prob  = $urandom_range(100, 0);
                            
                             `uvm_info("DCE_SLV_SEQ", $psprintf("k_silent_pct:%0d calculated_prob:%0d", m_unit_args.k_silent_pct.get_value(), prob), UVM_LOW)
                             if (prob < m_unit_args.k_silent_pct.get_value()) begin 
                                apply_random_delay();
                                m_dce_cntr.invoke_silent_cache_state_transition($urandom_range(1));
                             end
                          end
                      end
    eConcMsgRbReq: begin
                if (m_dce_cntr.m_rbreq[req_item.smi_targ_ncore_unit_id][req_item.smi_rbid] == 1) begin
                   `uvm_error("DCE_SLV_SEQ", $psprintf("RBReq Reserve rcvd: dmiid:0x%0h rbid:0x%0h value already set", req_item.smi_targ_ncore_unit_id, req_item.smi_rbid));
                end

                    m_dce_cntr.m_rbreq[req_item.smi_targ_ncore_unit_id][req_item.smi_rbid] = 1;
                    m_smi_rbreq_q.push_back(req_item);
                    // CONC-11806: Improved RBID update
                    // construct_rbr_rsp(req_item);
                end
    eConcMsgSysReq: begin
            min_delay = -1;
            max_delay = -1;
            if($test$plusargs("en_dce_ev_protocol_timeout")) begin // enable protocol_timeout scenarios
                if($test$plusargs("en_ev_prot_max_delay")) // protocol_timeout with maximum delay
                    sys_rsp_delay = (m_unit_args.ev_prot_timeout_val * 4096)+($urandom_range(64,0)); 
                else begin
                    if (!$value$plusargs("sys_rsp_min_delay=%0d", min_delay))
                        min_delay = ($urandom_range(500, 100) * m_unit_args.ev_prot_timeout_val);
                    if (!$value$plusargs("sys_rsp_max_delay=%0d", max_delay))
                        max_delay = ($urandom_range(2000, 1000) * m_unit_args.ev_prot_timeout_val);
                    sys_rsp_delay = $urandom_range(max_delay,min_delay); // protocol timeout with random delays
                end
               `uvm_info(get_name(), $psprintf("[%-35s] [minDly: %1d] [maxDly: %1d] [protToutVal: %1d] [sysRspDelay: %d]", "DceSlvSeq-SysRspDelayInit", min_delay, max_delay, m_unit_args.ev_prot_timeout_val, sys_rsp_delay), UVM_LOW)  
                #(<%=obj.Clocks[0].params.period%>ps * sys_rsp_delay);  // delay 0 to 512 cycles more than protocol timeout before driving response
               `uvm_info(get_name(), $psprintf("[%-35s] [minDly: %1d] [maxDly: %1d] [protToutVal: %1d] [sysRspDelay: %d]", "DceSlvSeq-SysRspDelayDone", min_delay, max_delay, m_unit_args.ev_prot_timeout_val, sys_rsp_delay), UVM_LOW)  
  
                if(!m_scb.prot_timeout_err) // construct sys rsp only if there is no protocol timeout error
                  construct_sys_rsp(req_item);
            end
            else begin
              sys_rsp_delay = $urandom_range(64,0);
              construct_sys_rsp(req_item);
            end
        end

    default:          `ASSERT(0, $psprintf("TbError unexpected req %s",
                                req_item.smi_conc_msg_class));
  endcase
endtask: receive_smi_msgs

//******************************************************************
task dce_slv_base_seq::issue_smi_msgs();
    smi_seq      tmp_seq;
    int          fndq[$];
    smi_seq_item tmp_seq_item;
    int          attid, rbid, j;

    tmp_seq = smi_seq::type_id::create("smi_sequence");
    tmp_seq.m_seq_item = smi_seq_item::type_id::create("smi_seq_item");
    m_smi_rsps.shuffle();

    if (    ($test$plusargs("snp_credit_chk_seq") && m_smi_rsps[0].isSnpRspMsg())
         || ($test$plusargs("mrd_credit_chk_seq") && m_smi_rsps[0].isMrdRspMsg())
         || ($test$plusargs("rbs_credit_chk_seq") && m_smi_rsps[0].isRbUseMsg())) begin 
        if (wait_iteration != 100) begin
            `uvm_info("DBG", $psprintf("wait_itr:%0d Delay issue of Rsp packet since it is a credit_chk_seq:%0s", m_smi_rsps[0].convert2string(), wait_iteration), UVM_LOW)
            wait_iteration++;
            return;
        end
    end
    if(($test$plusargs("dce_directed_same_set_target_all_SF_seq") || $test$plusargs("dce_directed_same_set_target_all_SF_seq_hw_cfg_41"))&& m_smi_rsps[0].isStrRspMsg()) begin
        if(wait_iteration != 25) begin
            `uvm_info("DBG", $psprintf("wait_itr:%0d Delay issue of Rsp packet to get a retry from directory:%0s", wait_iteration,m_smi_rsps[0].convert2string()), UVM_LOW)
            wait_iteration++;
            return;
        end
        else
            wait_iteration = 0;
    end
            
    
    //We need to save and work with the original seq_item to access dce_cntr.m_rbreq since the m_seq_item in tmp_seq could be corrupted due to single bit error. 
    void'($cast(tmp_seq_item, m_smi_rsps[0].clone()));
    tmp_seq.m_seq_item = m_smi_rsps.pop_front(); 
    tmp_seq.return_response(m_smi_tx_port);
   `uvm_info(get_name(), $psprintf("[%-35s] Model rsp done  : {%20s} (src: 0x%02h) (tgt: 0x%02h) (msgId: 0x%02h) (rmsgId: 0x%02h) (rbid: 0x%02h) (addr: 0x%016h)\n%s", "DceScbd-RbRsp-Model", tmp_seq_item.type2cmdname(), tmp_seq_item.smi_src_ncore_unit_id, tmp_seq_item.smi_targ_ncore_unit_id, tmp_seq_item.smi_msg_id, tmp_seq_item.smi_rmsg_id, tmp_seq_item.smi_rbid, tmp_seq_item.smi_addr, tmp_seq_item.convert2string()), UVM_LOW);

    if (tmp_seq_item.isRbRspMsg()) begin
        rbid  = tmp_seq_item.smi_rbid;
        attid = m_att_rbid_map[tmp_seq_item.smi_targ_ncore_unit_id][rbid];
       `uvm_info(get_name(), $psprintf("[%-35s] RBRsp send      : {%20s} (src: 0x%02h) (tgt: 0x%02h) (msgId: 0x%02h) (rmsgId: 0x%02h) (rbid: 0x%02h) (addr: 0x%016h)\n%s", "DceScbd-RbRsp-Model", tmp_seq_item.type2cmdname(), tmp_seq_item.smi_src_ncore_unit_id, tmp_seq_item.smi_targ_ncore_unit_id, tmp_seq_item.smi_msg_id, tmp_seq_item.smi_rmsg_id, tmp_seq_item.smi_rbid, tmp_seq_item.smi_addr, tmp_seq_item.convert2string()), UVM_LOW);
        m_dce_cntr.m_rbreq[tmp_seq_item.smi_src_ncore_unit_id][rbid] = 0;
    end

    if (tmp_seq_item.isRbUseMsg()) begin
        // CONC-11806: Improved RBID update
       `uvm_fatal(get_name(), $psprintf("unexpected rbuse msg being sent! %s", tmp_seq_item.convert2string()));
    end
endtask: issue_smi_msgs

//*****************************************************************
//TODO knobs to control delays
task dce_slv_base_seq::apply_random_delay();
  int delay;
  delay = $urandom_range(100, 1);
  #(<%=obj.Clocks[0].params.period%>ps * delay); //wait for random cycles
endtask: apply_random_delay

//*****************************************************************
function void dce_slv_base_seq::construct_snp_rsp(const ref smi_seq_item snpreq);
    smi_intfsize_t possible_intfsizeq[$];
    smi_seq_item snprsp;
    smi_cmstatus_t cmstatus;
    bit [WSMINCOREUNITID-1:0] targ_id;
    ncore_cache_state_t snooper_final_st;
    smi_seq_item rbr_rsp;
    int idxq[$], recreq_idxq[$], cohreq_idxq[$];
    eMsgSNP snp_type;
    eMsgCMD cmd_type;
    int master_agentid, idx;
    bit is_stash_target;
    addr_width_t bit_mask_const = ('h1_FFFF_FFFF_FFFF << ncoreConfigInfo::WCACHE_OFFSET);
    addr_width_t cacheline_addr = {snpreq.smi_ns, snpreq.smi_addr} & bit_mask_const;

    int snooper_agentid = ncoreConfigInfo::agentid_assoc2funitid(snpreq.smi_targ_ncore_unit_id);
    ncore_cache_state_t snooper_initial_st = m_dce_cntr.get_cacheline_st(snooper_agentid, cacheline_addr);
    $cast(snp_type, snpreq.smi_msg_type);
    
    is_stash_target= (     (snpreq.smi_mpf1_stash_valid == 1) 
                        && (snpreq.smi_mpf1_stash_nid == snpreq.smi_targ_ncore_unit_id)
                        && (snpreq.smi_mpf1_stash_nid inside {ncoreConfigInfo::stash_nids,ncoreConfigInfo::stash_nids_ace_aius})
                        && (ncoreConfigInfo::is_stash_enable(ncoreConfigInfo::agentid_assoc2funitid(snpreq.smi_mpf1_stash_nid)))) ? 'b1 : 'b0;

    snprsp = smi_seq_item::type_id::create("snp_rsp");
    `uvm_info("DCE_SLV_DBG",$psprintf("cacheline address : %p",cacheline_addr),UVM_LOW)
    cmstatus = m_dce_cntr.get_snprsp_cmstatus(snpreq.smi_targ_ncore_unit_id, snp_type, snpreq.smi_up, snooper_initial_st, is_stash_target, snpreq.smi_mpf3_intervention_unit_id, snooper_final_st);
        if ($test$plusargs("SNPrsp_data_error_in_cmstatus") && (snpreq.smi_msg_type inside {eSnpVldDtr,eSnpNoSDInt,eSnpInvDtr,eSnpStshUnq,eSnpStshShd, eSnpInvStsh,eSnpClnDtr,eSnpInv,eSnpInvDtw,eSnpClnDtw,eSnpNITC,eSnpNITCCI,eSnpNITCMI})) begin 
          cmstatus = 8'b1000_0011;
        end
        if ($test$plusargs("SNPrsp_sharer_data_error_in_cmstatus") && cmstatus == 0 && (snpreq.smi_msg_type inside {eSnpInvDtr, eSnpNITCCI})) begin 
          cmstatus = 8'b1000_0011;
        end
        if ($test$plusargs("SNPrsp_sharer_data_error_in_cmstatus") && (snpreq.smi_msg_type inside {eSnpStshUnq,eSnpStshShd,eSnpUnqStsh}) && !is_stash_target) begin
        if($test$plusargs("sharer_snprsp_error")) begin
            if(cmstatus[1] == 0)
                    cmstatus = 8'b1000_0011;
        end
        else
                cmstatus = 8'b1000_0011; 
        end
        if ($test$plusargs("SNPrsp_sharer_data_error_in_cmstatus") && (snpreq.smi_msg_type inside {eSnpInvDtw})) begin 
        if($test$plusargs("sharer_snprsp_error")) begin
            if(cmstatus[1] == 0)
                    cmstatus = 8'b1000_0011;
        end
        else
                cmstatus = 8'b1000_0011;
        end
        if ($test$plusargs("SNPrsp_non_data_error_in_cmstatus") && (snpreq.smi_msg_type inside {eSnpVldDtr,eSnpInvDtr})) begin 
          cmstatus = 8'b1000_0100;
        end
        if ($test$plusargs("SNPrsp_sharer_non_data_error_in_cmstatus") && cmstatus == 0 && (snpreq.smi_msg_type inside {eSnpInvDtr, eSnpNITCCI})) begin 
          cmstatus = 8'b1000_0100;
        end
    if($test$plusargs("SnpRsp_OnlyDataError") && cmstatus[7] == 1) begin
            cmstatus = 8'b1000_0011;
    end
        if ($test$plusargs("wrong_snprsp_target_id")) begin
          targ_id = (snpreq.smi_src_ncore_unit_id ^ {WSMINCOREUNITID{1'b1}});
        end else begin
          targ_id = snpreq.smi_src_ncore_unit_id;
        end

    //See Section 4.5.3.7 IntfSize[2:0]
    possible_intfsizeq = '{0,1,2,3,4}; 
    idx = $urandom_range(possible_intfsizeq.size() - 1);
    
    snprsp.construct_snprsp(
        .smi_targ_ncore_unit_id (targ_id),
        .smi_src_ncore_unit_id  (snpreq.smi_targ_ncore_unit_id),
        .smi_msg_type           (SNP_RSP),
        .smi_msg_id             ('h0),
        .smi_msg_tier           ('h0),
        .smi_steer              ('h0),
        .smi_msg_pri            (snpreq.smi_msg_pri),
        .smi_msg_qos            ('h0),
        .smi_tm                 (snpreq.smi_tm),
        .smi_rmsg_id            (snpreq.smi_msg_id),
        .smi_msg_err            ('h0),
        .smi_cmstatus           (cmstatus),
        .smi_cmstatus_rv        (cmstatus[5]),
        .smi_cmstatus_rs        (cmstatus[4]),
        .smi_cmstatus_dc        (cmstatus[3]),
        .smi_cmstatus_dt_aiu    (cmstatus[2]),
        .smi_cmstatus_dt_dmi    (cmstatus[1]),
        .smi_cmstatus_snarf     (cmstatus[0]),
        .smi_mpf1_dtr_msg_id    (m_dce_cntr.m_random_msgid),
        .smi_intfsize           (possible_intfsizeq[idx])
    );

   m_smi_rsps.push_back(snprsp);
  `uvm_info("DCE_SLV_SEQ", $psprintf("UPDATE cmstatus: 0x%0h snooper state: agentid: 0x%0h snooper_initial_state:%0s snooper_final_st:%0s for chacheline:%0h", cmstatus, snpreq.smi_targ_ncore_unit_id, snooper_initial_st.name, snooper_final_st.name,cacheline_addr), UVM_LOW)
   m_dce_cntr.set_cacheline_st(snooper_agentid, cacheline_addr, snooper_final_st);
   m_dce_cntr.print_cache_model(1, cacheline_addr);

   snprsp.unpack_smi_seq_item();
   if (    ((snpreq.smi_msg_type inside {eSnpStshShd, eSnpStshUnq}) && is_stash_target) //dt_dmi==0 from stash target, so return early.
        || ((snpreq.smi_msg_type == eSnpUnqStsh) && !is_stash_target) //Always predict RBUreq for WrStashPtl
       /* || (((snpreq.smi_msg_type == eSnpUnqStsh) && is_stash_target) && $test$plusargs("dce_snprsp_snarf1_error_seq") && !$test$plusargs("sharer_snprsp_error"))
        || ((snprsp.smi_cmstatus_err == 1) && !$test$plusargs("sharer_snprsp_error"))*/
        || ((snpreq.smi_msg_type == eSnpInvStsh) && (!is_stash_target || (snprsp.smi_cmstatus_snarf && !snprsp.smi_cmstatus_err))) //Predict RBUReq for WrStashFull if snarf==0
      ) begin

        `uvm_info("DCE_SLV_SEQ", $psprintf("Return early from RBUReq prediction for stashing Snoops"), UVM_LOW)
        return;
   end


//   foreach(m_dce_cntr.m_inflight_txns[idx]) begin
//      if (m_dce_cntr.m_inflight_txns[idx].get_addr() != 0) begin
//          `uvm_info("DCE_SLV_SEQ", $psprintf("%s", m_dce_cntr.m_inflight_txns[idx].convert2string()), UVM_LOW)
//      end
//   end 
    
    master_agentid = ncoreConfigInfo::agentid_assoc2funitid(snpreq.smi_mpf1_dtr_tgt_id);

   if(snpreq.smi_msg_type inside {eSnpStshShd, eSnpStshUnq}) begin
       idxq = m_dce_cntr.m_inflight_txns.find_index(x) with ( (x.get_addr() == {snpreq.smi_ns, snpreq.smi_addr}) && x.snpreq_maps_to_cmdreq(snp_type) &&  dce_goldenref_model::is_stash_request(x.get_msg_type()));
       //Check inly one entry exists
       if (idxq.size() == 0) begin
           `uvm_error("DCE SLV SEQ", "No match for SnpReq for Stash read ops")
       end else begin
           if (snprsp.smi_cmstatus_dt_dmi == 1 && snprsp.smi_cmstatus_err == 0) begin
              //m_dce_cntr.populate_rbrrsp({snpreq.smi_ns, snpreq.smi_addr}, snpreq.smi_tm, snpreq.smi_msg_id, snpreq.smi_rbid, snpreq.smi_msg_pri, snpreq.smi_qos);  
              //`uvm_info("DCE_SLV_SEQ", $psprintf("Populating rbureqq for rbid:%0d", snpreq.smi_rbid), UVM_LOW)
           end
       end
   end else if(snpreq.smi_msg_type inside {eSnpInvStsh, eSnpUnqStsh}) begin
       idxq = m_dce_cntr.m_inflight_txns.find_index(x) with ( (x.get_addr() == {snpreq.smi_ns, snpreq.smi_addr}) && x.snpreq_maps_to_cmdreq(snp_type) &&  dce_goldenref_model::is_stash_request(x.get_msg_type()));
       //Check inly one entry exists
       if (idxq.size() == 0) begin
           `uvm_error("DCE SLV SEQ", "No match for SnpReq for Stash read ops")
       end else begin
           //m_dce_cntr.populate_rbrrsp({snpreq.smi_ns, snpreq.smi_addr}, snpreq.smi_tm, snpreq.smi_msg_id, snpreq.smi_rbid, snpreq.smi_msg_pri, snpreq.smi_qos);  
           //`uvm_info("DCE_SLV_SEQ", $psprintf("Populating rbureqq for rbid:%0d", snpreq.smi_rbid), UVM_LOW)
       end
   end else begin
       //cant use attid since it might not be set
//       idxq = m_dce_cntr.m_inflight_txns.find_index(x) with (x.is_msgid_inuse() && (x.get_addr() == {snpreq.smi_ns, snpreq.smi_addr}) && x.snpreq_maps_to_cmdreq(snpreq.smi_msg_type) && ( dce_goldenref_model::is_stash_request(x.get_msg_type()) || x.get_msg_id() == snpreq.smi_mpf2_dtr_msg_id));
//       
//       `uvm_info("DCE_SLV_SEQ", $psprintf("idxq_size:%0d", idxq.size()), UVM_LOW)
//
//       //had to add SNP_INV_DTW, SNP_VLD_DTW though it does not need to drive mpf1_dtr_tgt_id correctly, but currently RTL does. WrUnqPtl & Atm txns both give out SNP_INV_DTW and if msg_id is same, leads to idxq>1. Hence needed to get master_agent_id to filter out uniquely. If still issue persists, probably need to peek into dce_scb
//       if ((snpreq.smi_msg_type inside {SNP_NOSDINT, SNP_CLN_DTR, SNP_INV_DTR, SNP_VLD_DTR, SNP_NITC, SNP_NITCCI, SNP_NITCMI, SNP_INV_DTW, SNP_INV, SNP_VLD_DTW}) && (idxq.size() != 1)) begin
//              idxq = m_dce_cntr.m_inflight_txns.find_index(x) with (x.is_msgid_inuse() && (x.get_addr() == {snpreq.smi_ns, snpreq.smi_addr}) && x.snpreq_maps_to_cmdreq(snpreq.smi_msg_type) && (x.get_msg_id() == snpreq.smi_mpf2_dtr_msg_id) && (x.get_master_id() == master_agentid));
//       end
        
       if (m_scb != null) begin

            cohreq_idxq = m_scb.m_dce_txnq.find_index(item) with (        (item.m_req_type == CMD_REQ) 
                                                                       && (item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP})
                                                                       && (item.m_attid == snpreq.smi_msg_id)
                                                                       && ({item.m_initcmdupd_req_pkt.smi_ns, item.m_initcmdupd_req_pkt.smi_addr} == {snpreq.smi_ns, snpreq.smi_addr}));
       end
       if(cohreq_idxq.size() == 1) begin
        if(cmstatus[2] == 1) begin
            case (snpreq.smi_msg_type)
                SNP_CLN_DTR:
                    begin
                        if(cmstatus[5:1] == 5'b00110)
                            m_scb.m_dce_txnq[cohreq_idxq[0]].dtrreq = DtrDataUCln;
                        else if(cmstatus[5:1] inside {5'b11010,5'b10010,5'b11011})
                            m_scb.m_dce_txnq[cohreq_idxq[0]].dtrreq = DtrDataSCln;
                        else if(cmstatus[5:1] == 5'b00011 && (snpreq.smi_up == 2'b00 || snpreq.smi_up == 2'b10))
                            m_scb.m_dce_txnq[cohreq_idxq[0]].dtrreq = DtrDataSCln;
                        else if(cmstatus[5:1] == 5'b00111 && snpreq.smi_up == 2'b01)
                            m_scb.m_dce_txnq[cohreq_idxq[0]].dtrreq = DtrDataUCln;
                        else
                            m_scb.m_dce_txnq[cohreq_idxq[0]].dtrreq = NoDtr;
                    end
                SNP_VLD_DTR:
                    begin
                        if(cmstatus[5:1] == 5'b00110 && snooper_initial_st inside {UC,SC})
                            m_scb.m_dce_txnq[cohreq_idxq[0]].dtrreq = DtrDataUCln;
                        else if(cmstatus[5:1] inside {5'b11010,5'b10010})
                            m_scb.m_dce_txnq[cohreq_idxq[0]].dtrreq = DtrDataSCln;
                        else if((cmstatus[5:1] == 5'b00110 && (snpreq.smi_up == 2'b00 || snpreq.smi_up == 2'b10)) || cmstatus[5:1] == 5'b11110)
                            m_scb.m_dce_txnq[cohreq_idxq[0]].dtrreq = DtrDataSDty;
                        else if(cmstatus[5:1] == 5'b00110 && snpreq.smi_up == 2'b01)
                            m_scb.m_dce_txnq[cohreq_idxq[0]].dtrreq = DtrDataUDty;
                        else
                            m_scb.m_dce_txnq[cohreq_idxq[0]].dtrreq = NoDtr;
                    end
                SNP_INV_DTR:
                    begin
                        if(cmstatus[5:1] == 5'b00110 && snooper_initial_st inside {UC,SC})
                            m_scb.m_dce_txnq[cohreq_idxq[0]].dtrreq = DtrDataUCln;
                        else if(cmstatus[5:1] == 5'b00110 && snpreq.smi_up inside {2'b00,2'b10,2'b01})
                            m_scb.m_dce_txnq[cohreq_idxq[0]].dtrreq = DtrDataUDty;
                        else
                            m_scb.m_dce_txnq[cohreq_idxq[0]].dtrreq = NoDtr;
                    end
                SNP_NOSDINT:
                    begin
                        if(cmstatus[5:1] == 5'b00110 && snooper_initial_st inside {UC,SC})
                            m_scb.m_dce_txnq[cohreq_idxq[0]].dtrreq = DtrDataUCln;
                        else if(cmstatus[5:1] inside {5'b11010,5'b10010,5'b11011})
                            m_scb.m_dce_txnq[cohreq_idxq[0]].dtrreq = DtrDataSCln;
                        else if(cmstatus[5:1] == 5'b00010 && snpreq.smi_up inside {2'b00,2'b10})
                            m_scb.m_dce_txnq[cohreq_idxq[0]].dtrreq = DtrDataSCln;
                        else if(cmstatus[5:1] == 5'b00110 && snpreq.smi_up == 2'b01)
                            m_scb.m_dce_txnq[cohreq_idxq[0]].dtrreq = DtrDataUDty;
                        else
                            m_scb.m_dce_txnq[cohreq_idxq[0]].dtrreq = NoDtr;
                    end
                default:
                    begin
                        m_scb.m_dce_txnq[cohreq_idxq[0]].dtrreq = NoDtr;
                    end
                endcase
        end
       end 

       //Check inly one entry exists
       if (cohreq_idxq.size() == 0) begin

            //Check if any REC_REQ caused this snp
            if (m_scb != null) begin
              if(!(m_scb.num_smi_uncorr_err>0 || m_scb.num_smi_parity_err>0)) begin
                recreq_idxq = m_scb.m_dce_txnq.find_index(item) with (    (item.m_req_type == REC_REQ) 
                                                                       && (item.m_attid_status == ATTID_IS_ACTIVE)
                                                                       && (item.m_attid == snpreq.smi_msg_id)
                                                                       && (snpreq.smi_msg_type == SNP_INV_DTW));

              if (recreq_idxq.size() == 0) begin
                if ($test$plusargs("wrong_rbrsp_target_id") || m_scb.garbage_dmiid)
                    return;
                `uvm_error("DCE SLV SEQ", "No match for SnpReq both regular ops and recall ops")
              end else if (recreq_idxq.size() > 1) begin
                foreach(recreq_idxq[i]) begin
                    `uvm_info("DCE_SLV_SEQ", $psprintf("%0d : %0s", i, m_scb.m_dce_txnq[recreq_idxq[i]].print_txn(0)), UVM_LOW)
                end
                `uvm_error("DCE SLV SEQ", "More than one match for SnpReq in recall ops and no match in regular ops")
              end else begin //single match for SnpReq in recall ops

                snprsp.unpack_smi_seq_item();
                //`uvm_info("DCE_SLV_SEQ", $psprintf("SnpRsp for recall cmstatus_err:%0d cmstatus_dt_dmi:%0d", snprsp.smi_cmstatus_err,snprsp.smi_cmstatus_dt_dmi), UVM_LOW)
                if (snprsp.smi_cmstatus_err == 0 && snprsp.smi_cmstatus_dt_dmi == 1) begin
                    //m_dce_cntr.populate_rbrrsp({snpreq.smi_ns, snpreq.smi_addr}, snpreq.smi_tm, snpreq.smi_msg_id, snpreq.smi_rbid, snpreq.smi_msg_pri, snpreq.smi_qos);  
                    //`uvm_info("DCE_SLV_SEQ", $psprintf("Predicted RBUsed req for RecallReq addr:0x%0h attid:0x%0h rbid:0x%0h", {snpreq.smi_ns, snpreq.smi_addr}, snpreq.smi_msg_id, snpreq.smi_rbid), UVM_LOW)
                end

              end 
            end
            end

       end else if (cohreq_idxq.size() > 1) begin
      //    if (m_scb != null) begin
      //            cohreq_idxq = m_scb.m_dce_txnq.find_index(item) with (     (item.m_req_type == COH_REQ) 
      //                                                                    && (item.m_attid_status == {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP})
      //                                                                && (item.m_attid == snpreq.smi_msg_id));
      //        if (cohreq_idxq.size() != 1) begin
      //            `uvm_error("DCE SLV SEQ", "More than one match for SnpReq in dce_scb_txnq")
      //        end else begin
      //            idxq = m_dce_cntr.m_inflight_txns.find_index(x) with (x.is_msgid_inuse() && (x.get_addr() == {snpreq.smi_ns, snpreq.smi_addr}) && x.snpreq_maps_to_cmdreq(snpreq.smi_msg_type) && ( dce_goldenref_model::is_stash_request(x.get_msg_type()) || x.get_msg_id() == snpreq.smi_mpf2_dtr_msg_id));




      //        end
      //    end
            foreach(cohreq_idxq[i]) `uvm_info("DCE_SLV_SEQ", $psprintf("match i:%0d :%0s", i, m_scb.m_dce_txnq[cohreq_idxq[i]].print_txn(0)), UVM_LOW)
       //   foreach(cohreq_idxq[i]) begin
       //       `uvm_info("DCE_SLV_SEQ", $psprintf("match i:%0d :%0s", i, m_dce_cntr.m_inflight_txns[idxq[i]].convert2string()), UVM_LOW)
       //   end 
            `uvm_error("DCE SLV SEQ", "More than one match for SnpReq in regular ops")
       end else begin // single match for SnpReq in regular ops

           snprsp.unpack_smi_seq_item();
           $cast(cmd_type, m_scb.m_dce_txnq[cohreq_idxq[0]].m_initcmdupd_req_pkt.smi_msg_type);
           //`uvm_info("DCE_SLV_SEQ", $psprintf("cmstatus_dt_dmi:%0d", snpreq.smi_cmstatus_dt_dmi), UVM_LOW)
            //`uvm_info("DCE_SLV_SEQ", $psprintf("SnpRsp for reg ops cmstatus_err:%0d cmstatus_dt_dmi:%0d", snprsp.smi_cmstatus_err,snprsp.smi_cmstatus_dt_dmi), UVM_LOW)
           if (     snprsp.smi_cmstatus_dt_dmi && 
                   !snprsp.smi_cmstatus_err       &&
                  (    dce_goldenref_model::is_read(cmd_type)
                    || dce_goldenref_model::is_stash_read(cmd_type)
                    || dce_goldenref_model::is_clean(cmd_type)
                    || dce_goldenref_model::is_atomic(cmd_type))
              ) begin
              //m_dce_cntr.populate_rbrrsp({snpreq.smi_ns, snpreq.smi_addr}, snpreq.smi_tm, snpreq.smi_msg_id, snpreq.smi_rbid, snpreq.smi_msg_pri, snpreq.smi_qos);  
              `uvm_info("DCE_SLV_SEQ", $psprintf("Predicted RBUsed req for reg-Req addr:0x%0h attid:0x%0h rbid:0x%0h", {snpreq.smi_ns, snpreq.smi_addr}, snpreq.smi_msg_id, snpreq.smi_rbid), UVM_LOW)
           end
       
       end 
   end

endfunction: construct_snp_rsp

//******************************************************************
function void dce_slv_base_seq::construct_mrd_rsp(const ref smi_seq_item mrdreq);
    smi_seq_item   mrd_rsp;
    smi_cmstatus_t cm_status;
    int k_mrd_rsp_addr_err_wgt,k_mrd_rsp_data_err_wgt;
    bit [WSMINCOREUNITID-1:0] targ_id;

    
    mrd_rsp = smi_seq_item::type_id::create("mrd_rsp");
     
    if ($test$plusargs("wrong_mrdrsp_target_id")) begin
        targ_id = (mrdreq.smi_src_ncore_unit_id ^ {WSMINCOREUNITID{1'b1}});
    end else begin
        targ_id = mrdreq.smi_src_ncore_unit_id;
    end

    if(mrdreq.smi_msg_type inside {eMsgMRD'(MRD_FLUSH), eMsgMRD'(MRD_CLN)}) begin
            if ($value$plusargs("Mrdrsp_address_err_in_cmstatus=%d",k_mrd_rsp_addr_err_wgt)) begin
                void'(std::randomize(cm_status) with {cm_status dist {8'b10_0_00_100 :/ k_mrd_rsp_addr_err_wgt, 8'b0 :/ 100-k_mrd_rsp_addr_err_wgt};});
            end else if ($value$plusargs("Mrdrsp_data_err_in_cmstatus=%d",k_mrd_rsp_data_err_wgt)) begin
                void'(std::randomize(cm_status) with {cm_status dist {8'b10_0_00_011 :/ k_mrd_rsp_data_err_wgt, 8'b0 :/ 100-k_mrd_rsp_data_err_wgt};});
        end else begin
                cm_status = 8'b0;
            end
    end

   if ($test$plusargs("Mrdrsp_err_in_cmstatus")) begin
    if(mrdreq.smi_msg_type inside {eMsgMRD'(MRD_FLUSH), eMsgMRD'(MRD_CLN)}) begin
            void'(std::randomize(cm_status) with {cm_status dist {8'b10_0_00_100 := 5, 8'b10_0_00_011 := 5, 8'b0 := 1};});
    end
   end

    mrd_rsp.construct_mrdrsp(
        .smi_targ_ncore_unit_id (targ_id),
        .smi_src_ncore_unit_id  (mrdreq.smi_targ_ncore_unit_id),
        .smi_msg_type           (MRD_RSP),
        .smi_msg_id             ('h0),
        .smi_msg_tier           ('h0),
        .smi_steer              ('h0),
        .smi_msg_pri            (mrdreq.smi_msg_pri),
        .smi_msg_qos            ('h0),
        .smi_tm                 (mrdreq.smi_tm),
        .smi_rmsg_id            (mrdreq.smi_msg_id),
        .smi_msg_err            ('h0),
        .smi_cmstatus           (cm_status)
    );

   m_smi_rsps.push_back(mrd_rsp);
   
   //`uvm_info("DCE_SLV_SEQ", "Put MRD RSP in queue", UVM_HIGH)
endfunction: construct_mrd_rsp

//******************************************************************
function void dce_slv_base_seq::construct_str_rsp(const ref smi_seq_item strreq);

    smi_cmstatus_t cmstatus;
    smi_seq_item   str_rsp;
    bit [WSMINCOREUNITID-1:0] targ_id;
    
    str_rsp = smi_seq_item::type_id::create("str_rsp");
    cmstatus = m_dce_cntr.get_strrsp_cmstatus(strreq);
    
    if ($test$plusargs("wrong_strrsp_target_id")) begin
      targ_id = (strreq.smi_src_ncore_unit_id ^ {WSMINCOREUNITID{1'b1}});
    end else begin
      targ_id = strreq.smi_src_ncore_unit_id;
    end
    str_rsp.construct_strrsp(
        .smi_steer              ('h0),
        .smi_targ_ncore_unit_id (targ_id),
        .smi_src_ncore_unit_id  (strreq.smi_targ_ncore_unit_id),
        .smi_msg_type           (STR_RSP),
        .smi_msg_id             ('h0),
        .smi_msg_tier           ('h0),
        .smi_msg_qos            ('h0),
        .smi_msg_pri            (strreq.smi_msg_pri),
        .smi_msg_err            ('h0),
        .smi_cmstatus           (cmstatus),
        .smi_tm                 (strreq.smi_tm),
        .smi_rmsg_id            (strreq.smi_msg_id)
    );

   m_smi_rsps.push_back(str_rsp);

   //`uvm_info("DCE_SLV_SEQ", "Put STR RSP in queue", UVM_HIGH)
endfunction: construct_str_rsp

//*********************************************************************
function void dce_slv_base_seq::construct_rbr_rsp(smi_seq_item rbrreq);
    int                                     idxq[$];
    int                                     wrong_rbu_targ_id;
    bit             [WSMINCOREUNITID-1:0]   targ_id;
    bit                                     predict_rbrsp = 0;
    bit             [WSMIRBID-1:0]          rbid;
    eMsgCMD                                 cmd_type;
    smi_seq_item                            rbr_rsp;

    rbid = rbrreq.smi_rbid;
    m_att_rbid_map[rbrreq.smi_src_ncore_unit_id][rbid] = rbrreq.smi_msg_id;

    rbr_rsp = smi_seq_item::type_id::create("rbr_rsp");
    rbr_rsp.construct_rbrsp(
                    .smi_steer              ('h0),
                    .smi_targ_ncore_unit_id ($test$plusargs("wrong_rbrsp_target_id") ? rbrreq.smi_src_ncore_unit_id ^ {WSMINCOREUNITID{1'b1}} : rbrreq.smi_src_ncore_unit_id),
                    .smi_src_ncore_unit_id  (rbrreq.smi_targ_ncore_unit_id),
                    .smi_msg_tier           ('h0),
                    .smi_msg_qos            ('h0),
                    .smi_msg_pri            (rbrreq.smi_msg_pri),
                    .smi_msg_type           (RB_RSP),
                    .smi_msg_id             ('h0),
                    .smi_cmstatus           ('h0),
                    .smi_tm                 (rbrreq.smi_tm),
                    .smi_rbid               (rbrreq.smi_rbid)
                );
    m_smi_rsps.push_back(rbr_rsp);
    
    //rb_rsp for writes can only be predicted if scb is enabled.
    /*
     * YRAMASAMY: Not sure if this is required! Old code and prints in this section points to rbureq being sent, which is obsolete in 3.6!
    if(m_scb != null) begin
        idxq = m_scb.m_dce_txnq.find_index(item) with ((item.m_rbid_status == RBID_RESERVED) 
                                                        && (item.m_rbid == rbrreq.smi_rbid) 
                                                        && (item.m_initcmdupd_req_pkt.smi_dest_id == rbrreq.smi_targ_ncore_unit_id) 
                                                        && (item.m_attid_status inside {ATTID_IS_ACTIVE, ATTID_IS_WAKEUP})
                                                        && (item.m_attid == rbrreq.smi_msg_id)
                                                        && (item.m_states["rbrreq"].get_valid_count() == 1)
                                                        &&  item.m_states["rbrreq"].is_complete());
   
        if (idxq.size() == 1) begin 
            $cast(cmd_type, m_scb.m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_msg_type);
            if (dce_goldenref_model::is_nonstash_write(cmd_type)) begin
                predict_rbrsp = 1;
            end 
            else if (dce_goldenref_model::is_stash_write(cmd_type)  
                && (!m_scb.m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_mpf1_stash_valid 
                || !ncoreConfigInfo::is_stash_enable(ncoreConfigInfo::agentid_assoc2funitid(m_scb.m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_mpf1_stash_nid))
                || (m_scb.m_dce_txnq[idxq[0]].snoop_enable_reg_txn[ncoreConfigInfo::agentid_assoc2funitid(m_scb.m_dce_txnq[idxq[0]].m_initcmdupd_req_pkt.smi_mpf1_stash_nid)] == 0))
                ) begin //stash writes with "target not identified" so a dtw directly to dmi.
                    predict_rbrsp = 1;
            end

            if (predict_rbrsp == 1) begin 
                rbr_rsp = smi_seq_item::type_id::create("rbr_rsp");
                if ($value$plusargs("wrong_rbureq_target_id=%d",wrong_rbu_targ_id)) begin
                    std::randomize (targ_id) with {targ_id dist {(rbrreq.smi_src_ncore_unit_id ^ {WSMINCOREUNITID{1'b1}}) :/ wrong_rbu_targ_id, rbrreq.smi_src_ncore_unit_id :/ 100-wrong_rbu_targ_id};};
                end 
                else begin
                     targ_id = rbrreq.smi_src_ncore_unit_id;
                end
                rbr_rsp.construct_rbrsp(
                        .smi_steer              ('h0),
                        .smi_targ_ncore_unit_id (targ_id),
                        .smi_src_ncore_unit_id  (rbrreq.smi_targ_ncore_unit_id),
                        .smi_msg_tier           ('h0),
                        .smi_msg_qos            ('h0),
                        .smi_msg_pri            (rbrreq.smi_msg_pri),
                        .smi_msg_type           (RB_RSP),
                        .smi_msg_id             ('h0),
                        .smi_cmstatus           ('h0),
                        .smi_tm                 (rbrreq.smi_tm),
                        .smi_rbid               (rbrreq.smi_rmsg_id)
                    );
                m_smi_rsps.push_back(rbr_rsp);
               `uvm_info("DCE_SLV_SEQ", $psprintf("Predicted RBU Req for writes for rbid:0x%0h dmiid:0x%0h attid:0x%0h", rbrreq.smi_rbid, rbrreq.smi_targ_ncore_unit_id, rbrreq.smi_msg_id), UVM_LOW)
                m_dce_cntr.m_random_msgid++;
            end 
        end 
        else if (idxq.size() > 1) begin 
            foreach(idxq[i]) begin
               `uvm_info("DCE_SLV_SEQ", $psprintf("multiple_matches_%0d attid: 0x%0h rbid: 0x%0h req_msg_id: 0x%0h", i, m_scb.m_dce_txnq[idxq[i]].m_attid, m_scb.m_dce_txnq[idxq[i]].m_rbid, m_scb.m_dce_txnq[idxq[i]].m_initcmdupd_req_pkt.smi_msg_id), UVM_LOW)
            end
           `uvm_error("DCE_SLV_SEQ", $psprintf("Not predicted RBU Req for rbid: 0x%0h since idxq.size: 0x%0h", rbrreq.smi_rbid, idxq.size()))
        end
    end //scb
    */

endfunction: construct_rbr_rsp


//*********************************************************************
function void dce_slv_base_seq::construct_sys_rsp(const ref smi_seq_item sysreq);

        smi_cmstatus_t cm_status;
        int k_sys_rsp_ev_timeout_err_wgt;
    int trgt_id;
    
    smi_seq_item sys_rsp;

    sys_rsp = smi_seq_item::type_id::create("sys_rsp");

        //cm_status = ($test$plusargs("sysrsp_event_timeout")) ? 8'b0100_0000 : 8'b0000_0011 ;

        if ($value$plusargs("k_sys_rsp_ev_timeout_err_wgt=%d",k_sys_rsp_ev_timeout_err_wgt))
          void'(std::randomize(cm_status) with {cm_status dist {8'b0100_0000 :/ k_sys_rsp_ev_timeout_err_wgt, 8'b0000_0011 :/ 100-k_sys_rsp_ev_timeout_err_wgt};});
        else
          cm_status = 8'b0000_0011;

        if ($test$plusargs("wrong_sysrsp_target_id")) begin
            trgt_id = (sysreq.smi_src_ncore_unit_id ^ {WSMINCOREUNITID{1'b1}});
        `uvm_info("CONSTRUCT_SYS_RSP", $psprintf("Sending sys_rsp with wrong target id"), UVM_LOW);
    end
    else begin
        trgt_id = sysreq.smi_src_ncore_unit_id;
    end
        `uvm_info("CONSTRUCT_SYS_RSP", $psprintf("Sending sys_rsp with cm_status set to %0b", cm_status), UVM_HIGH);
    
    sys_rsp.construct_sysrsp(
            .smi_targ_ncore_unit_id (trgt_id),
            .smi_src_ncore_unit_id  (sysreq.smi_targ_ncore_unit_id),
            .smi_msg_type           (SYS_RSP),
            .smi_msg_id             ('h0),
            .smi_msg_tier           ('h0),
            .smi_steer              (sysreq.smi_steer),
            .smi_msg_pri            (sysreq.smi_msg_pri),
            .smi_msg_qos            (sysreq.smi_msg_qos),
            .smi_tm                 (sysreq.smi_tm),
            .smi_rmsg_id            (sysreq.smi_msg_id),
            .smi_msg_err            ('h0),
            .smi_cmstatus           (cm_status),
            .smi_ndp_aux            (sysreq.smi_ndp_aux)
        );
    m_smi_rsps.push_back(sys_rsp);
    

endfunction: construct_sys_rsp
