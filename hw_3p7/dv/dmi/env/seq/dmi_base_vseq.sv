class dmi_base_vseq extends uvm_sequence;
  //UVM Factory
  `uvm_object_utils(dmi_base_vseq)
  `uvm_declare_p_sequencer(smi_virtual_sequencer)
  //Queues
  smi_seq_item smi_dispatch_q[$], MW_primary_dtw_q[$];
  //Instances
  dmi_env_config    m_cfg;    
  resource_manager  m_rsrc_mgr;
  dmi_cmd_args      m_args;
  
  smi_sequencer        m_smi_seqr_rx_hash[string];
  smi_sequencer        m_smi_seqr_tx_hash[string];
  smi_seq              smi_tx_req;
  smi_seq              smi_tx_dtw,smi_tx_MW;
  smi_seq              smi_rx_rsp;
  smi_seq_item         exp_str_req_q[$];
  smi_seq_item         smi_rx_rsp_q[$];

  uvm_event            e_smi_rx_rsp;

  //Variables

  int t_num, p_num, glb_num, max_t_num;
  AIUIDQ_t unq_smi_id_q;
  int credits;
  int smi_tx_count;
  int num_rbrs_sent, num_merging_writes, num_clear_pending_rls, num_int_rls;
  bit SCP_warmup_active = 0;
  //Old Declarations embedded in test that can't be evicted FIXME VIK
  Addr_t cache_addr_list[$];
  int aiu_txn_count;
  

  //Functions
  extern function new(string name=get_type_name());
  extern function initialize();
  extern function get_args(ref dmi_cmd_args _args);
  extern function get_rsrc_mgr(ref resource_manager _mgr);
  extern function set_sequencers();
  extern function bit dispatch_queue_at_threshold();
  extern function bit dispatch_queue_empty();
  extern function print_exp_str_req_q();
  extern function push_rx_rsp(smi_seq_item m_item);
  extern function waivers();
  extern function atomic_compare_waiver();
  extern function print_abort();
  //Tasks
  extern task body();
  extern task smi_tx_mgr();
  extern task smi_rx_mgr();
  extern task smi_rx_rsp_mgr();
  //extern task monitor_rx_rsp_dispatch();
  extern task timeout_state(dmi_timeout_state_t t_state, input dmi_credit_table_type_t _type=CMD_CT, bit needs_home_dce_id=0, traffic_type_pair_t traffic_info='{'h00,DMI_RAND_p,NONCOH,0});
  extern task get_credit(dmi_credit_table_type_t _type);
  extern task get_RBID(ref traffic_seq m_seq,input bit drain_mode=0);
  extern task manage_str_req(smi_seq_item m_item);
  extern task push_exp_str_req(int _index);
  extern task send_dtw_req(data_seq_item m_item, smi_rbid_t m_rbid, input smi_prim_t m_prim=1);
  extern task send_primary_dtw_for_MW(smi_rbid_t mw_rbid);
  <% for (var i = 0; i < obj.nSmiTx; i++) { %>
  extern task monitor_smi<%=i%>_rx_seqr();
  <%} %>
endclass

//Functions Begin//////////////////////////////////////////////////////////////////////////////////////////////////////////

function dmi_base_vseq::new(string name = get_type_name());
  super.new(name);
  e_smi_rx_rsp = new("e_smi_rx_rsp");
endfunction : new

function dmi_base_vseq::initialize();
  //Get knobs
  if(!uvm_config_db#(dmi_env_config)::get(.cntxt( null ),
                                       .inst_name( get_full_name() ),
                                       .field_name( "dmi_env_config" ),
                                       .value( m_cfg ))) begin
      `uvm_error("dmi_base_vseq::init", "dmi_env_config handle not found")
  end
  set_sequencers();
  get_args(m_cfg.m_args);
  get_rsrc_mgr(m_cfg.m_rsrc_mgr);
  <% if(obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
  m_rsrc_mgr.gen_SP_addr();
  <% } %>
endfunction : initialize

function dmi_base_vseq::get_args(ref dmi_cmd_args _args);
  m_args = _args;
endfunction

function dmi_base_vseq::get_rsrc_mgr(ref resource_manager _mgr);
  m_rsrc_mgr = _mgr;
endfunction

function dmi_base_vseq::set_sequencers();
  <% for (var i = 0; i < obj.nSmiTx; i++) { 
     for (var j = 0; j < obj.DmiInfo[obj.Id].smiPortParams.tx[i].params.fnMsgClass.length; j++) { %>
  if(!$cast(m_smi_seqr_rx_hash["<%=obj.DmiInfo[obj.Id].smiPortParams.tx[i].params.fnMsgClass[j]%>"],p_sequencer.m_smi<%=i%>_rx_seqr))begin //--"  JS highlighter fix
    `uvm_error(get_type_name(),"::init:: p_sequencer.m_smi<%=i%>_rx_seqr type missmatch"); 
  end
  <% } } %>
  <% for (var i = 0; i < obj.nSmiRx; i++) { 
     for (var j = 0; j < obj.DmiInfo[obj.Id].smiPortParams.rx[i].params.fnMsgClass.length; j++) { %>
  if(!$cast(m_smi_seqr_tx_hash["<%=obj.DmiInfo[0].smiPortParams.rx[i].params.fnMsgClass[j]%>"],p_sequencer.m_smi<%=i%>_tx_seqr))begin //--" JS highlighter fix
    `uvm_error(get_type_name(),"::init:: p_sequencer.m_smi<%=i%>_tx_seqr type missmatch");
  end
  <% } } %>
  smi_tx_req = smi_seq::type_id::create("smi_tx_req");
  smi_tx_dtw = smi_seq::type_id::create("smi_tx_dtw");
  smi_tx_MW  = smi_seq::type_id::create("smi_tx_MW");
  smi_rx_rsp = smi_seq::type_id::create("smi_rx_rsp");
  `uvm_info(get_type_name(),"::set_sequencers:: Done.",UVM_DEBUG)
endfunction

function bit dmi_base_vseq::dispatch_queue_at_threshold();
//Checks main packet queue if required level of packets have been assembled
  int min_pkts_needed;
  if(m_args.k_num_cmd-smi_tx_count < CMD_SKID_BUF_SIZE) begin//At the very end, throttle and drain the queue
    min_pkts_needed = 1;
  end
  else begin
    case(m_rsrc_mgr.dispatch_delay_type)
      FILL    : min_pkts_needed = 1;
      BURST   : min_pkts_needed = CMD_SKID_BUF_SIZE;
      default : min_pkts_needed = 1;
    endcase
  end
  if(smi_dispatch_q.size >= min_pkts_needed) begin
    return(1);
  end
  else begin
    return(0);
  end
endfunction

function bit dmi_base_vseq::dispatch_queue_empty();
  if(smi_dispatch_q.size==0) begin
    return(1);
  end
  else begin
    return(0);
  end
endfunction

function dmi_base_vseq::print_exp_str_req_q();
  foreach(exp_str_req_q[i]) begin
    `uvm_info("exp_str_req",$sformatf("[%0d] :: MsgType:%0h AiuId:%0h MsgId:%0h",
                                        i,exp_str_req_q[i].smi_msg_type,exp_str_req_q[i].smi_src_ncore_unit_id,
                                        exp_str_req_q[i].smi_msg_id),UVM_DEBUG)
  end
endfunction
//Functions End//////////////////////////////////////////////////////////////////////////////////////////////////////////

task dmi_base_vseq::body();
  initialize();
  fork
    smi_rx_mgr();
    smi_tx_mgr();
  join_none
endtask

//RX aka everything received from DMI DUT control///////////////////////////////////////////////////////////////////////////////////////
task dmi_base_vseq::smi_rx_mgr();
  //Receive from DUT and update the dmi_table
  fork
    smi_rx_rsp_mgr();
    <% for (var i = 0; i < obj.nSmiTx; i++) { %>
    monitor_smi<%=i%>_rx_seqr();
    <% } %>
  join_none
endtask
<% for (var i = 0; i < obj.nSmiTx; i++) { %>
task dmi_base_vseq::monitor_smi<%=i%>_rx_seqr();
   forever begin
    smi_seq_item m_item;
    `uvm_guarded_info(m_args.k_stimulus_debug,get_type_name(),$sformatf("::monitor_rx:: Waiting for RX<%=i%> activity..."),UVM_DEBUG)
    p_sequencer.m_smi<%=i%>_rx_seqr.m_rx_analysis_fifo.get(m_item);
    `uvm_info(get_type_name(),$sformatf("::monitor_rx:: Processing resources for RX<%=i%> type:%0s",
                                        m_cfg.smi_type_string(m_item.smi_msg_type)),UVM_DEBUG)
    if(m_item.isStrMsg) begin
      manage_str_req(m_item);
      push_rx_rsp(m_item);
      `uvm_info(get_type_name(),$sformatf("::monitor_rx:: Processing response for StrReq..."),UVM_DEBUG)
      //FIXME-priority-5 directed test case should be hit in normal tests
    end
    else if(m_item.isSysReqMsg) begin
      `uvm_info(get_type_name(),$sformatf("::monitor_rx:: Processing response for SysReq..."),UVM_DEBUG)
      push_rx_rsp(m_item);
    end
    else if(m_item.isDtrMsg) begin
      `uvm_info(get_type_name(),$sformatf("::monitor_rx:: Processing response for DtrReq..."),UVM_DEBUG)
      //FIXME-priority-3 add Delayed DTRs
      push_rx_rsp(m_item);
    end
    else if(m_item.isDtwDbgReqMsg) begin
      `uvm_info(get_type_name(),$sformatf("::monitor_rx:: Processing response for DtwDbgReq..."),UVM_DEBUG)
      push_rx_rsp(m_item);
    end
    else begin
      resource_semaphore_t computed_outcome;
      m_rsrc_mgr.update_LUT(m_item, computed_outcome);
      if(computed_outcome.flag && computed_outcome._type == MERGING_WRITE) begin
        send_primary_dtw_for_MW(computed_outcome.mw_rbid);
      end
      else begin
        m_rsrc_mgr.release_credit(m_item.smi_msg_type);
      end
    end
  end
endtask
<% } %>

function dmi_base_vseq::push_rx_rsp(smi_seq_item m_item);
  smi_rx_rsp_q.push_back(m_item);
  e_smi_rx_rsp.trigger();
endfunction

task dmi_base_vseq::smi_rx_rsp_mgr();
  forever begin
    if(smi_rx_rsp_q.size() == 0) begin
      e_smi_rx_rsp.wait_trigger();
      e_smi_rx_rsp.reset();
    end
    else begin
      smi_seq_item m_item;
      m_item = smi_rx_rsp_q.pop_front();
      smi_rx_rsp.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
      if (m_args.k_wrong_targ_id_str_rsp       && m_item.isStrMsg() || 
          m_args.k_wrong_arg_id_dtr_rsp        && m_item.isDtrMsg() ||
          m_args.k_wrong_targ_id_on_dtwdbg_rsp && m_item.isDtwDbgReqMsg()) begin
        smi_rx_rsp.m_seq_item.smi_targ_ncore_unit_id = m_item.smi_src_ncore_unit_id ^ {WSMINCOREUNITID{1'h1}}; 
      end else begin
        smi_rx_rsp.m_seq_item.smi_targ_ncore_unit_id = m_item.smi_src_ncore_unit_id;
      end
      smi_rx_rsp.m_seq_item.smi_src_ncore_unit_id  = m_item.smi_targ_ncore_unit_id;
      if(m_item.isStrMsg())begin
        smi_rx_rsp.m_seq_item.smi_msg_type = STR_RSP;
      end
      else if(m_item.isDtrMsg()) begin
        smi_rx_rsp.m_seq_item.smi_msg_type = DTR_RSP;
      end
      else if(m_item.isDtwDbgReqMsg()) begin
        smi_rx_rsp.m_seq_item.smi_msg_type = DTW_DBG_RSP;
      end
      else if(m_item.isSysReqMsg()) begin
        smi_rx_rsp.m_seq_item.smi_msg_type  = SYS_RSP;
      end
      smi_rx_rsp.m_seq_item.smi_cmstatus    = 0; // This needs to be driven to non-zero for error testing
      smi_rx_rsp.m_seq_item.smi_dp_present  = 0; // This needs to be driven to non-zero for ndp
      smi_rx_rsp.m_seq_item.smi_msg_tier    = 0;
      smi_rx_rsp.m_seq_item.smi_steer       = 0;
      smi_rx_rsp.m_seq_item.smi_msg_pri     = 0;
      smi_rx_rsp.m_seq_item.smi_cmstatus    = 0;
      smi_rx_rsp.m_seq_item.smi_rl          = 0;
      smi_rx_rsp.m_seq_item.smi_tm          = m_item.smi_tm;
      smi_rx_rsp.m_seq_item.smi_rmsg_id     = m_item.smi_msg_id;
      smi_rx_rsp.m_seq_item.smi_msg_id      = $urandom;
      
      if(m_item.isStrMsg())begin
        resource_semaphore_t dummy;
        `uvm_info(get_type_name(), "::smi_rx_rsp_mgr:: Sending StrRsp item...",UVM_DEBUG);
        m_rsrc_mgr.update_LUT(m_item,dummy);
        smi_rx_rsp.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["STRRSP"]]);
      end
      else if(m_item.isDtrMsg()) begin
        resource_semaphore_t dummy;
        `uvm_info(get_type_name(), "::smi_rx_rsp_mgr:: Sending DtrRsp item...",UVM_DEBUG);
        m_rsrc_mgr.update_LUT(m_item,dummy);
        smi_rx_rsp.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["DTRRSP"]]);
      end
      else if(m_item.isDtwDbgReqMsg()) begin
        `uvm_info(get_type_name(), "::smi_rx_rsp_mgr:: Sending DtwDbgRsp item....",UVM_DEBUG);
        smi_rx_rsp.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["DTWDBGRSP"]]);    
      end
      else if(m_item.isSysReqMsg()) begin
      `uvm_info(get_type_name(), "::smi_rx_rsp_mgr:: Sending SysRsp item....",UVM_DEBUG);
        if(m_smi_seqr_tx_hash.exists("sys_rsp_rx_")) begin
          smi_rx_rsp.return_response(m_smi_seqr_tx_hash["sys_rsp_rx_"]);    
        end
        else begin
          `uvm_error(get_type_name(),"::smi_rx_rsp_mgr:: Attempting to send a SysRsp on a configuration with no SysReq port")
        end
      end
    end
  end
endtask : smi_rx_rsp_mgr
//RX control end //////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//TX aka everything sent from DMI TB control///////////////////////////////////////////////////////////////////////////////////////
task dmi_base_vseq::smi_tx_mgr(); 
  //Waits for a threshold of transaction items to be collected and dispatches transactions assembled in smi_dispatch_q to the SMI TX I/F 
  smi_seq_item str_req;
  smi_rbid_t   curr_rbid;
  dce_id_t     curr_gen_id;
  bit          cpy_rb_data=0;
  forever begin
    if(dispatch_queue_at_threshold) begin
      `uvm_info(get_type_name(),$sformatf("::smi_tx_mgr:: Sending smi_dispatch_q(size=%0d).",smi_dispatch_q.size), UVM_HIGH)
      while(smi_dispatch_q.size!=0) begin
        smi_msg_type_bit_t msg_type;
        smi_tx_req.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
        smi_tx_req.m_seq_item.do_copy(smi_dispatch_q[0]);
        //Send to appropriate sequencer
        if(smi_tx_req.m_seq_item.isCmdMsg()) begin
          get_credit(CMD_CT);
          `uvm_info(get_type_name(),$sformatf("::smi_tx_mgr:: Sending TXN#%0d PKT_UID:%0d:: CMD_REQ | Addr:'h%0h | smi_dispatch_q(size=%0d)",
                                                              smi_tx_count,smi_dispatch_q[0].pkt_uid,smi_dispatch_q[0].smi_addr,smi_dispatch_q.size-1), UVM_MEDIUM)
          smi_tx_req.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["CMDREQ"]]);
          push_exp_str_req(0);
        end
        else if(smi_tx_req.m_seq_item.isMrdMsg()) begin
          `uvm_info(get_type_name(),$sformatf("::smi_tx_mgr:: Sending TXN#%0d PKT_UID:%0d:: MRD_REQ | Addr:'h%0h | smi_dispatch_q(size=%0d)",
                                                              smi_tx_count,smi_dispatch_q[0].pkt_uid,smi_dispatch_q[0].smi_addr,smi_dispatch_q.size-1), UVM_MEDIUM)
          get_credit(MRD_CT);
          smi_tx_req.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["MRDREQ"]]);
        end
        else if(smi_tx_req.m_seq_item.isRbMsg()) begin
          `uvm_info(get_type_name(),$sformatf("::smi_tx_mgr:: Sending TXN#%0d PKT_UID:%0d:: RB_REQ | Addr:'h%0h | RBID:%0h | smi_dispatch_q(size=%0d)",
                                                              smi_tx_count,smi_dispatch_q[0].pkt_uid,smi_dispatch_q[0].smi_addr,smi_dispatch_q[0].smi_rbid,smi_dispatch_q.size-1), UVM_MEDIUM)
          smi_tx_req.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["RBRREQ"]]);
        end
        else if(smi_tx_req.m_seq_item.isDtwMsg()) begin
          `uvm_info(get_type_name(),$sformatf("::smi_tx_mgr:: Sending TXN#%0d PKT_UID:%0d:: DTW_REQ | Addr:'h%0h | RBID:%0h | smi_dispatch_q(size=%0d)",
                                                              smi_tx_count,smi_dispatch_q[0].pkt_uid,smi_dispatch_q[0].smi_addr,smi_dispatch_q[0].smi_rbid,smi_dispatch_q.size-1), UVM_MEDIUM)
          smi_tx_req.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["DTWREQ"]]);
        end
        else begin
          `uvm_error(get_type_name(),$sformatf("::smi_tx_mgr:: Unsupported CCMP Type:%0s",m_cfg.smi_type_string(msg_type)))
        end
        `uvm_guarded_info(m_args.k_stimulus_debug,get_type_name(),$sformatf("::smi_tx_mgr:: %p",smi_tx_req.m_seq_item),UVM_DEBUG)
        smi_tx_count++;
        smi_dispatch_q.delete(0);
      end
    end
    else if( smi_tx_count == (m_args.k_num_cmd + num_rbrs_sent  + num_merging_writes + num_clear_pending_rls - num_int_rls))  begin
      `uvm_info(get_type_name(),$sformatf("::smi_tx_mgr:: Exiting || k_num_cmd=%0d num_RBRs=%0d num_int_rls=%0d num_MWs=%0d num_rls=%0d | smi_tx_count:%0d ",
                                           m_args.k_num_cmd, num_rbrs_sent, num_int_rls, num_merging_writes, num_clear_pending_rls, smi_tx_count),UVM_LOW)
      break;
    end
    else begin
      `uvm_info(get_type_name(),$sformatf("::smi_tx_mgr:: Waiting for smi_dispatch_q(size=%0d) to hit threshold | Txns Expected:%0d Sent:%0d ",
                                           smi_dispatch_q.size(),(m_args.k_num_cmd + num_rbrs_sent + num_merging_writes + num_clear_pending_rls -num_int_rls),smi_tx_count),UVM_LOW)
      #(m_args.k_seq_delay);
    end
  end
endtask

task dmi_base_vseq::send_primary_dtw_for_MW(smi_rbid_t mw_rbid);
  int collision_q[$];
  collision_q = MW_primary_dtw_q.find_index with (item.smi_rbid == mw_rbid);
  if(collision_q.size > 1 || collision_q.size == 0) begin
    `uvm_error(get_type_name(),$sformatf("::send_primary_dtw_for_MW:: Found %0d entries in MW_primary_dtw_q with RBID:%0h", collision_q.size, mw_rbid))
  end
  else begin
    smi_tx_MW.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
    smi_tx_MW.m_seq_item.do_copy(MW_primary_dtw_q[collision_q[0]]);
    `uvm_info(get_type_name(),$sformatf("::send_primary_dtw_for_MW:: Sending TXN#%0d Merging DtwReq on RBID:%0h",smi_tx_count,mw_rbid), UVM_MEDIUM)
    smi_tx_MW.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["DTWREQ"]]);
    smi_tx_count++;
    MW_primary_dtw_q.delete(collision_q[0]);
  end
endtask
task dmi_base_vseq::push_exp_str_req(int _index); 
//Populates StrReq expected queue to assert DMI is sending only StrReqs for commands queued
  if(smi_dispatch_q[_index].smi_msg_type inside {CMD_WR_NC_PTL,CMD_WR_NC_FULL,CMD_RD_NC,CMD_RD_ATM,CMD_WR_ATM,CMD_SW_ATM,CMD_CMP_ATM,CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV,CMD_PREF})begin
    smi_seq_item str_req;
    str_req = smi_seq_item::type_id::create("str_req");
    str_req.do_copy(smi_dispatch_q[0]);
    `uvm_info(get_type_name(),$sformatf("Adding CmdReq:%0s AiuId:%0h MsgId:%0h item to expected StrReq q(size=%0d)",
                                          m_cfg.smi_type_string(str_req.smi_msg_type),
                                          str_req.smi_src_ncore_unit_id, str_req.smi_msg_id,
                                          exp_str_req_q.size()),UVM_MEDIUM)
    exp_str_req_q.push_back(str_req); 
  end
endtask

task dmi_base_vseq::manage_str_req(smi_seq_item m_item);
  //On receiving a StrReq from the SMI I/F. Check the lookup table for collisions and update/dispatch write accordingly.
  int ncrd_q[$], ncwr_q[$], atmld_q[$], exp_str_q[$];

  exp_str_q = exp_str_req_q.find_index with((item.smi_src_ncore_unit_id == m_item.smi_targ_ncore_unit_id) &&
                                            (item.smi_msg_id            == m_item.smi_rmsg_id)
                                             );
  
  ncrd_q = m_rsrc_mgr.m_table.find_index with( (item.aiu_id     == m_item.smi_targ_ncore_unit_id) &&
                                               (item.smi_msg_id == m_item.smi_rmsg_id) &&
                                               (!item.str_req_rcvd) &&
                                                item.is_non_coh_rd_TT()
                                             );

  ncwr_q = m_rsrc_mgr.m_table.find_index with((item.aiu_id     == m_item.smi_targ_ncore_unit_id) &&
                                              (item.smi_msg_id == m_item.smi_rmsg_id) &&
                                              (!item.str_req_rcvd) &&
                                               item.is_non_coh_wr_TT()
                                             );

  
  atmld_q = m_rsrc_mgr.m_table.find_index with((item.aiu_id     == m_item.smi_targ_ncore_unit_id) &&
                                               (item.smi_msg_id == m_item.smi_rmsg_id) &&
                                               (!item.str_req_rcvd) &&
                                                item.is_atm_ld_TT()
                                              );
  if(exp_str_q.size()==0) begin
    print_exp_str_req_q();
    `uvm_error(get_type_name(),$sformatf("::manage_str_req:: None of the pending txns match StrReq AiuId:%0h MsgId:%0h",
                                              m_item.smi_targ_ncore_unit_id, m_item.smi_rmsg_id))
  end

  if((ncrd_q.size()+ncwr_q.size()+atmld_q.size())==0) begin
    `uvm_error(get_type_name(),$sformatf("::manage_str_req:: None of the pendig m_table items match StrReq(size=%0d) AiuId:%0h MsgId:%0h",
                                              exp_str_req_q.size(),m_item.smi_targ_ncore_unit_id, m_item.smi_rmsg_id))
  end
  else if((ncrd_q.size()+ncwr_q.size()+atmld_q.size()) > 1) begin
    m_rsrc_mgr.print_LUT_matches({ncrd_q,ncwr_q,atmld_q});
    `uvm_error(get_type_name(),$sformatf("::manage_str_req:: Multiple pending m_table items matching ncrd_q:%0d ncwr_q:%0d atmld_q:%0d",
                                                      ncrd_q.size(),ncwr_q.size(),atmld_q.size()))
  end
  else begin //Mark received
    if(ncwr_q.size()==1) begin //Send Write
      data_seq_item dtw_req;
      dtw_req = data_seq_item::type_id::create("dtw_req");
      `uvm_info("dmi_base_seq",$sformatf("::manage_str_req:: Setting RBID for DtwReq for NcWr:%0h",m_item.smi_rbid),UVM_DEBUG)
      dtw_req.do_copy(exp_str_req_q[exp_str_q[0]]);
      if(dtw_req.smi_msg_type == CMD_WR_NC_FULL) begin
        dtw_req.smi_msg_type = $urandom_range(0,1)? DTW_DATA_CLN : DTW_DATA_DTY;
        if(m_args.axi_suspend_W_resp || m_args.send_dtw_with_data) begin //Always send data to AXI in suspend and data only traffic cases
          dtw_req.smi_msg_type = DTW_DATA_DTY;
        end
      end
      else if(dtw_req.smi_msg_type inside {CMD_RD_ATM,CMD_WR_ATM}) begin
        dtw_req.smi_msg_type =  DTW_DATA_PTL;
      end
      else begin
        dtw_req.smi_msg_type = $urandom_range(0,1)? DTW_DATA_PTL: DTW_NO_DATA;
        if(m_args.axi_suspend_W_resp || m_args.send_dtw_with_data) begin //Always send data to AXI in suspend and data only traffic cases
          dtw_req.smi_msg_type = DTW_DATA_PTL;
        end
      end
      m_rsrc_mgr.m_table[ncwr_q[0]].str_req_rcvd = 1;
      m_rsrc_mgr.m_table[ncwr_q[0]].dtw_req_sent = 1;
      m_rsrc_mgr.m_table[ncwr_q[0]].smi_rbid     = m_item.smi_rbid;
      send_dtw_req(dtw_req,m_item.smi_rbid);
      exp_str_req_q.delete(exp_str_q[0]);
    end
    else if(atmld_q.size()==1) begin //Send Write
      data_seq_item dtw_req;
      dtw_req = data_seq_item::type_id::create("dtw_req");    
      `uvm_info("dmi_base_seq",$sformatf("::manage_str_req:: Setting RBID for DtwReq for Atomics:%0h",m_item.smi_rbid),UVM_DEBUG)
      dtw_req.do_copy(exp_str_req_q[exp_str_q[0]]);
      dtw_req.smi_msg_type = DTW_DATA_PTL;
      dtw_req.smi_mpf1_argv = $urandom_range(0,7);
      m_rsrc_mgr.m_table[atmld_q[0]].str_req_rcvd = 1;
      m_rsrc_mgr.m_table[atmld_q[0]].dtw_req_sent = 1;
      m_rsrc_mgr.m_table[atmld_q[0]].smi_rbid     = m_item.smi_rbid;
      send_dtw_req(dtw_req,m_item.smi_rbid);
      exp_str_req_q.delete(exp_str_q[0]);
    end
    else begin //Evict
      m_rsrc_mgr.m_table[ncrd_q[0]].str_req_rcvd = 1;
      exp_str_req_q.delete(exp_str_q[0]);
    end
  end
endtask

task dmi_base_vseq::send_dtw_req(data_seq_item m_item, smi_rbid_t m_rbid, input smi_prim_t m_prim=1);
  //Sends one DtwReq on the SMI I/F
  smi_tx_dtw.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
  `uvm_info(get_type_name(),$sformatf("Sending DtwReq on RBID:%0h",m_rbid),UVM_HIGH)
  m_item.get_cfg(m_cfg);
  m_item.smi_rl = 'b10;
  m_item.smi_prim = m_prim;
  m_item.smi_rbid = m_rbid;
  if (m_args.k_wrong_targ_id_dtw_req) begin
     m_item.smi_targ_ncore_unit_id   = (m_rsrc_mgr.home_dmi_unit_id ^ {WSMINCOREUNITID{1'b1}}); 
  end
  smi_tx_dtw.m_seq_item.do_copy(m_item);
  smi_tx_dtw.m_seq_item.smi_mpf1 = m_item.smi_mpf1;
  smi_tx_dtw.m_seq_item.smi_mpf2 = m_item.smi_mpf2;
  smi_tx_dtw.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["DTWREQ"]]);
endtask

//TX control end //////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Request resources Begin/////////////////////////////////////////////////////////////////////////////////////////////////////////
task dmi_base_vseq::get_RBID(ref traffic_seq m_seq,input bit drain_mode=0); //Timeout Capable
  //Check RBID full status, if full enter timeout
  //If not full, get RBID and return value
  if(!m_rsrc_mgr.is_RBID_available()) begin
    timeout_state(RBID_TIMEOUT);
  end
  m_seq.m_rbid = m_rsrc_mgr.reserve_RBID(m_seq.internal_release,drain_mode);
endtask

task dmi_base_vseq::get_credit(dmi_credit_table_type_t _type); //Timeout Capable
  //Check credit table, if full enter timeout
  if(m_rsrc_mgr.credit_table_full(_type)) begin
    timeout_state(CREDIT_TIMEOUT,_type);
  end
  if(m_rsrc_mgr.reserve_credit(_type)) begin
    `uvm_guarded_info(m_args.k_stimulus_debug,get_type_name(),$sformatf("::get_credit:: %0s credit available and reserved",_type.name),UVM_DEBUG)
  end
  else begin
    `uvm_error(get_type_name(),$sformatf("::get_credit:: Fix your calling method | %0s Credit Table:%0p(size=%0d)",
                                            _type.name, m_rsrc_mgr.credit_table[_type], m_rsrc_mgr.credit_table_count_ones(_type)))
  end
endtask
//Request resources End///////////////////////////////////////////////////////////////////////////////////////////////////////////

//Timeout control Begin//////////////////////////////////////////////////////////////////////////////////////////////////////////
task dmi_base_vseq::timeout_state(dmi_timeout_state_t t_state, input dmi_credit_table_type_t _type =CMD_CT, bit needs_home_dce_id=0,traffic_type_pair_t traffic_info='{'h00,DMI_RAND_p,NONCOH,0});
  int attempts;
  bit _exit;
  case(t_state)
    AIU_TABLE_TIMEOUT : begin   
      `uvm_info(get_type_name(),$sformatf("::timeout_state:: Entering AIU_TABLE_TIMEOUT:: There are no available SMI MsgIds..."),UVM_LOW)
      while(!m_rsrc_mgr.aiu_table_ready() && attempts < m_args.k_seq_timeout_max) begin
        #(m_args.k_seq_delay);
        attempts++;
        `uvm_info(get_type_name(),$sformatf("::timeout_state:: AIU_TABLE_TIMEOUT:: attempt:%0d",attempts),UVM_LOW)
      end
      if(attempts==m_args.k_seq_timeout_max) begin
        m_rsrc_mgr.print_aiu_table(UVM_MEDIUM);
        _exit = 1;
      end
    end
    DCE_TABLE_TIMEOUT: begin
      `uvm_info(get_type_name(),$sformatf("::timeout_state:: Entering DCE_TABLE_TIMEOUT:: There are no available SMI MsgIds..."),UVM_LOW)
      while(!m_rsrc_mgr.dce_table_ready(needs_home_dce_id) && attempts < m_args.k_seq_timeout_max)begin
        #(m_args.k_seq_delay);
        attempts++;
        `uvm_info(get_type_name(),$sformatf("::timeout_state:: DCE_TABLE_TIMEOUT:: attempt:%0d (Size:%0d,Max:%0d)"
                                              ,attempts,m_rsrc_mgr.dce_table_size,DCE_TABLE_MAX),UVM_LOW)
      end
      if(attempts==m_args.k_seq_timeout_max) begin
        m_rsrc_mgr.print_dce_table(UVM_MEDIUM);
        _exit = 1;
      end
    end
    CREDIT_TIMEOUT : begin
      `uvm_info(get_type_name(),$sformatf("::timeout_state:: Entering CREDIT_TIMEOUT:: The %0s skid buffer is full...",_type.name),UVM_LOW)
      while(m_rsrc_mgr.credit_table_full(_type) && attempts < m_args.k_seq_timeout_max) begin
        #(m_args.k_seq_delay);
        attempts++;
        `uvm_info(get_type_name(),$sformatf("::timeout_state:: CREDIT_TIMEOUT:: %0s attempt:%0d",_type.name,attempts),UVM_LOW)
      end
      if(m_rsrc_mgr.credit_table_full(_type)) begin
        _exit = 1;
      end
    end
    ADDRESS_TIMEOUT : begin
      int MAX_ADDR_LIMIT = CMD_SKID_BUF_SIZE;
      if(m_args.k_limit_addresses != -1) begin
        MAX_ADDR_LIMIT = m_args.k_limit_addresses; 
      end
      `uvm_info(get_type_name(),$sformatf("::timeout_state:: Entering ADDRESS_TIMEOUT:: There are no available %0s addresses to dispatch...(max=%0d)",traffic_info.addr_type.name,MAX_ADDR_LIMIT),UVM_LOW)
      while(!m_rsrc_mgr.prepare_addr_q(traffic_info,MAX_ADDR_LIMIT) && attempts < m_args.k_seq_timeout_max) begin
        if(m_args.k_addr_q_type inside {REUSE,CACHE_EVICT}) begin //Wait longer for resources to get de-allocated 
          #(m_args.k_seq_delay+5000);
        end
        else begin
          #(m_args.k_seq_delay);
        end
        attempts++;
         `uvm_info(get_type_name(),$sformatf("::timeout_state:: ADDRESS_TIMEOUT:: %0s attempt:%0d",traffic_info.addr_type.name,attempts),UVM_LOW)
      end
      if(m_rsrc_mgr.m_addr_q[traffic_info.addr_type].size == 0) begin
        _exit = 1;
      end
    end
    RBID_TIMEOUT : begin
      `uvm_info(get_type_name(),$sformatf("::timeout_state:: Entering RBID_TIMEOUT:: There are no available RBIDs..."),UVM_LOW)
      while(!m_rsrc_mgr.is_RBID_available() && attempts < m_args.k_seq_timeout_max) begin
        #(m_args.k_seq_delay);
        attempts++;
         `uvm_info(get_type_name(),$sformatf("::timeout_state:: RBID_TIMEOUT:: attempt:%0d",attempts),UVM_LOW)
      end
      if(!m_rsrc_mgr.is_RBID_available()) begin
        `uvm_info(get_type_name(),$sformatf("::timeout_state:: smi_dispatch_q(size=%0d)",smi_dispatch_q.size()),UVM_LOW)
        foreach(smi_dispatch_q[i])begin
          if(m_cfg.isAnyDtw(smi_dispatch_q[i].smi_msg_type)) begin
            `uvm_info(get_type_name(),$sformatf("::timeout_state:: smi_dispatch_q[%0d]==[%0s--RBID:%0h]"
              ,i,m_cfg.smi_type_string(smi_dispatch_q[i].smi_msg_type),smi_dispatch_q[i].smi_rbid),UVM_LOW)
          end
        end
        _exit = 1;
      end
    end
    RBID_RELEASE_TIMEOUT : begin
      `uvm_info(get_type_name(),$sformatf("::timeout_state:: Entering RBID_RELEASE_TIMEOUT:: RBIDs waiting on RBRsp still in-flight..."),UVM_LOW)
      while(!m_rsrc_mgr.is_RBID_release_resolved() && attempts < m_args.k_seq_timeout_max) begin
        #(m_args.k_seq_delay);
        attempts++;
         `uvm_info(get_type_name(),$sformatf("::timeout_state:: RBID_RELEASE_TIMEOUT:: attempt:%0d",attempts),UVM_LOW)
      end
      if(!m_rsrc_mgr.is_RBID_release_resolved()) begin
        `uvm_info(get_type_name(),$sformatf("::timeout_state:: smi_dispatch_q(size=%0d)",smi_dispatch_q.size()),UVM_LOW)
        foreach(smi_dispatch_q[i])begin
          if(m_cfg.isRbMsg(smi_dispatch_q[i].smi_msg_type)) begin
            `uvm_info(get_type_name(),$sformatf("::timeout_state:: smi_dispatch_q[%0d]==[%0s--RBID:%0h]"
              ,i,m_cfg.smi_type_string(smi_dispatch_q[i].smi_msg_type),smi_dispatch_q[i].smi_rbid),UVM_LOW)
          end
        end
        _exit = 1;
      end
    end
  endcase
  if(_exit) begin
    `uvm_error(get_type_name(),$sformatf("::timeout_state:: %0s unsuccessful. Exiting after %0d attempts",t_state.name,attempts))
  end
endtask
//Timeout control End////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Waivers Begin//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function dmi_base_vseq::waivers();
  atomic_compare_waiver();
endfunction

function dmi_base_vseq::atomic_compare_waiver();
  for(int i = m_rsrc_mgr.m_table.size-1; i>=0; i--) begin
    if(m_rsrc_mgr.m_table[i].is_cmp_miss()) begin
      m_rsrc_mgr.print_LUT_line("::atomic_compare_waiver::",`__LINE__,i);
      m_rsrc_mgr.delete_LUT(i);
    end
  end
endfunction
//Waivers Begin//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function dmi_base_vseq::print_abort();
  `uvm_info(get_type_name(),$sformatf("::flow_control:: Encountered a test failure, stats below."),UVM_LOW)
  `uvm_info(get_type_name(),$sformatf(" ===================END OF TEST==================="),UVM_LOW)
  if(m_rsrc_mgr != null) begin
    `uvm_info(get_type_name(),$sformatf("| Size of aiu_table:%0d dce_table:%0d m_table:%0d |",m_rsrc_mgr.aiu_table_size, m_rsrc_mgr.dce_table_size, m_rsrc_mgr.m_table.size),UVM_LOW)
    `uvm_info(get_type_name(),$sformatf("| Size of smi_dispatch_q:%0d |",smi_dispatch_q.size),UVM_LOW)
    `uvm_info(get_type_name(),$sformatf(" ================================================="),UVM_LOW)
    m_rsrc_mgr.print_LUT();
    begin
      smi_addr_t idx;
      if ( m_rsrc_mgr.addr_governor.first(idx) ) begin
        `uvm_info(get_type_name(),$sformatf("===========addr_governor(size=%0d)=============",m_rsrc_mgr.addr_governor.num()),UVM_LOW)
        do
          `uvm_info(get_type_name(),$sformatf("%s", m_rsrc_mgr.addr_governor[idx].convert2string()),UVM_LOW)
        while (m_rsrc_mgr.addr_governor.next(idx));
        `uvm_info(get_type_name(),$sformatf(" ================================================="),UVM_LOW)
      end
    end
  end


endfunction
