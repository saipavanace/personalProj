class dmi_vseq extends dmi_base_vseq;

  `uvm_object_utils(dmi_vseq)

  //Sequences
  packet_generator_seq m_pkt_gen_seq;
  traffic_seq m_traffic_seq;
  //Functions
  extern function new(string name="dmi_vseq");

  //Tasks
  extern task body();
  extern task packet_arbiter();
  extern task end_of_test_control();
  extern task release_pending_RBs();
endclass

function dmi_vseq::new(string name = "dmi_vseq");
  super.new(name);
endfunction : new////////////////////////////////////////////////////////////////////////////////////////////////////


task dmi_vseq::body();
  super.body();
  m_pkt_gen_seq = packet_generator_seq::type_id::create("m_pkt_gen_seq");
  m_traffic_seq = traffic_seq::type_id::create("m_traffic_seq");
  fork
    packet_arbiter();
  join
endtask

task dmi_vseq::packet_arbiter();
  `uvm_info(get_type_name(),$sformatf("::flow_control:: Beginning transaction production for k_num_cmd=%0d.",m_args.k_num_cmd),UVM_LOW)
  `uvm_info(get_type_name(),$sformatf("::packet_arbiter:: Starting packet arbiter for k_num_cmd=%0d.",m_args.k_num_cmd),UVM_DEBUG)
  for(int pkt_num=1; pkt_num <= m_args.k_num_cmd; pkt_num++) begin
    if(m_args.tb_delay) begin
      #2000ns; //Use sparingly, only for qchannel testing
    end
    if(!m_args.k_cmdline_user_pattern_mode) begin //Randomize traffic
      <% if(obj.useCmc) { %>
      if(m_args.k_cache_warmup) begin 
        if(pkt_num <= SET_X_WAY) begin
          m_args.only_traffic_mode = 0;
          //m_traffic_seq.pattern_c.constraint_mode(0);
          `ASSERT(m_traffic_seq.randomize with {
                                                m_pattern == DMI_CACHE_WARMUP_p;
                                                cache_warmup_mode == 1;
                                              });
        end
        else begin
          m_traffic_seq.pattern_c.constraint_mode(1);
          `ASSERT(m_traffic_seq.randomize());
        end
      end
      else if(m_args.k_SP_warmup) begin
        if(pkt_num <= m_cfg.k_sp_size) begin 
          //m_traffic_seq.pattern_c.constraint_mode(0);
          SCP_warmup_active = 1;
          m_args.only_traffic_mode = 0;
          m_args.k_force_mw = 0;
          m_args.k_force_allocate = 1;
          m_args.wt_sp_addr_range.set_value(100);
          m_args.wt_exclusives.set_value(0);
          m_args.wt_rb_release.set_value(0);
          m_args.send_dtw_with_data = 1;
          //m_traffic_seq.pattern_c.constraint_mode(1);
          `ASSERT(m_traffic_seq.randomize with {
                                      m_pattern == DMI_SP_WARMUP_p;
                                      SP_warmup_mode == 1;
                                    });
        end
        else begin
          //Reset traffic randomization once SP is full initialized
          SCP_warmup_active = 0;
          m_args.k_force_mw = -1;
          m_args.k_force_allocate = 0;
          m_args.wt_sp_addr_range.set_value(50);
          m_args.wt_exclusives.set_value($urandom);
          m_args.wt_rb_release.set_value($urandom);
          //m_traffic_seq.pattern_c.constraint_mode(1);
          `ASSERT(m_traffic_seq.randomize());
        end
      end
      else begin
        `ASSERT(m_traffic_seq.randomize());
      end
      <%} else { %>
      `ASSERT(m_traffic_seq.randomize());
      <% } %>
    end
    else begin //+k_pattern | USER defined pattern
      smi_type_t cmd_opcode = m_args.DMI_USER_pattern_q.pop_front();
      if(pkt_num==1) begin
        `uvm_info(get_type_name(),$sformatf("::packet_arbiter:: Exercising DMI_USER_p mode."),UVM_LOW)
      end
      `ASSERT(m_traffic_seq.randomize() with {m_opcode == cmd_opcode;});
      m_args.DMI_USER_pattern_q.push_back(cmd_opcode);
    end

    if(m_traffic_seq.m_pattern == DMI_CMP_ATM_MATCH_p) begin
      if(pkt_num == m_args.k_num_cmd) begin 
        //Final transaction is not an atomic hit couplet to maintain end of test sanity.
         m_args.wt_cmd_wr_nc_ptl.set_value(100);
        `ASSERT(m_traffic_seq.randomize() with {
                                                m_opcode == CMD_WR_NC_PTL;
                                                m_pattern == DMI_RAW_p;
                                                m_addr_type == NONCOH;
                                               });
        `uvm_info(get_type_name(),$sformatf("::packet_arbiter:: Constructing CMD_WR_NC_PTL instead of a DMI_CMP_ATM_HIT couplet %0d", pkt_num),UVM_DEBUG)
      end
      else begin
        `uvm_info(get_type_name(),$sformatf("::packet_arbiter:: Constructing Atomic Compare Hit Couplet %0d,%0d.",pkt_num,pkt_num+1),UVM_DEBUG)
        pkt_num++;
      end
      m_cfg.m_rsrc_mgr.MIN_AIU_TABLE_REQUIRED = 2;
    end
    else begin
      `uvm_info(get_type_name(),$sformatf("::packet_arbiter:: Constructing packet %0d.",pkt_num),UVM_DEBUG)
      if(m_traffic_seq.merging_write_success_flag) begin
        m_cfg.m_rsrc_mgr.MIN_AIU_TABLE_REQUIRED = m_cfg.isDtwMrgMrd(m_traffic_seq.m_opcode) ? 3 : 2;
        num_merging_writes++;
      end
      else begin
        m_cfg.m_rsrc_mgr.MIN_AIU_TABLE_REQUIRED = m_cfg.isDtwMrgMrd(m_traffic_seq.m_opcode) ? 2 : 1;
      end
    end

    if(m_rsrc_mgr.aiu_msg_id_q.size < m_cfg.m_rsrc_mgr.MIN_AIU_TABLE_REQUIRED) begin
      //AIU BFM and timeout and resource populating mechanism
      if(!m_rsrc_mgr.aiu_table_ready()) begin
        timeout_state(AIU_TABLE_TIMEOUT);
      end
      m_rsrc_mgr.prepare_aiu_msg_ids();    
    end

    if(m_cfg.isAnyDtw(m_traffic_seq.m_opcode))begin
      get_RBID(m_traffic_seq);
      num_rbrs_sent++;
      if(m_traffic_seq.internal_release) begin
        num_int_rls++;
      end
    end
    if(m_rsrc_mgr.dce_msg_id_q.size == 0) begin
      //DCE BFM and timeout and resource populating mechanism
       if(!m_rsrc_mgr.dce_table_ready(m_cfg.isAnyDtw(m_traffic_seq.m_opcode))) begin
        timeout_state(DCE_TABLE_TIMEOUT,CMD_CT,m_cfg.isAnyDtw(m_traffic_seq.m_opcode));
      end
      m_rsrc_mgr.prepare_dce_msg_ids();
    end
    else if(m_cfg.isAnyDtw(m_traffic_seq.m_opcode) && !m_rsrc_mgr.dce_table_ready(1,1)) begin
      `uvm_guarded_info(m_args.k_stimulus_debug,get_type_name(),$sformatf("::packet_arbiter:: Hitting a condition where dispatched RB is not in available DCE queue, entering timeout."),UVM_HIGH)
      timeout_state(DCE_TABLE_TIMEOUT,CMD_CT,1);
      m_rsrc_mgr.prepare_dce_msg_ids();
    end
    
    if(m_cfg.sp_exists) begin
      if(!SCP_warmup_active && (m_rsrc_mgr.get_SP_addr_q_size(m_traffic_seq.traffic_info) == 0) ) begin
        m_traffic_seq.avoid_scratchpad = 1;
      end
    end
    // I need atleast 1 address, doesn't make sense to evict all relevant addresses 
    //
    if(m_rsrc_mgr.get_m_addr_q_size_by_type(m_traffic_seq.traffic_info) == 0) begin
      //Address timeout and resource populating mechanism
      timeout_state(ADDRESS_TIMEOUT,.traffic_info(m_traffic_seq.traffic_info));
    end
    m_pkt_gen_seq.construct_packet(m_traffic_seq,smi_dispatch_q,MW_primary_dtw_q); 
  end
  if(m_rsrc_mgr.rbid_release_q.size != 0) begin
    release_pending_RBs();
  end
  end_of_test_control();
endtask : packet_arbiter

task dmi_vseq::release_pending_RBs();
  int max_drain= m_rsrc_mgr.rbid_release_q.size();
  `uvm_info(get_type_name(),$sformatf("::flow_control:: Begin pending RB release process for %0d RBs.",max_drain),UVM_LOW)
  `uvm_info("flow_control",$sformatf("rbid_release_q:%0p",m_rsrc_mgr.rbid_release_q),UVM_LOW)
  num_clear_pending_rls = 2*max_drain;
  wait(smi_tx_count >= m_args.k_num_cmd);
  `uvm_info(get_type_name(),$sformatf("::flow_control:: Adequate amount of transactions(%0d) sent",smi_tx_count),UVM_LOW)
  if(!m_rsrc_mgr.is_RBID_release_resolved())begin
    timeout_state(RBID_RELEASE_TIMEOUT);
  end
  m_args.wt_dtw_no_dt.set_value(100);
  m_args.k_cmdline_pattern_mode = 0;
  m_args.only_traffic_mode = 0;
  m_traffic_seq.internal_release_c.constraint_mode(0);
  for(int rls_itr=0; rls_itr < max_drain; rls_itr++) begin
    `ASSERT(m_traffic_seq.randomize () with { 
                                  pattern_mode     == 1;
                                  m_pattern        == DMI_RAND_p;
                                  m_opcode         == DTW_NO_DATA;
                                  internal_release == 0;
                                  });
    
    if(m_rsrc_mgr.aiu_msg_id_q.size < 1) begin
      //AIU BFM and timeout and resource populating mechanism
      if(!m_rsrc_mgr.aiu_table_ready()) begin
        timeout_state(AIU_TABLE_TIMEOUT);
      end
      m_rsrc_mgr.prepare_aiu_msg_ids();     
    end
  
    get_RBID(m_traffic_seq,1);
    
    `uvm_info(get_type_name(),$sformatf("::release_pending_RBs:: Releasing RBID:%0h using %s. Pending(%0d)",m_traffic_seq.m_rbid,m_traffic_seq.msg_s,m_rsrc_mgr.rbid_release_q.size),UVM_HIGH)
    
    if(m_rsrc_mgr.dce_msg_id_q.size == 0) begin
      //DCE BFM and timeout and resource populating mechanism
       if(!m_rsrc_mgr.dce_table_ready(m_cfg.isAnyDtw(m_traffic_seq.m_opcode))) begin
        timeout_state(DCE_TABLE_TIMEOUT,CMD_CT,m_cfg.isAnyDtw(m_traffic_seq.m_opcode));
      end
      m_rsrc_mgr.prepare_dce_msg_ids();
    end
    else if(m_cfg.isAnyDtw(m_traffic_seq.m_opcode) && !m_rsrc_mgr.dce_table_ready(1,1)) begin
      `uvm_guarded_info(m_args.k_stimulus_debug,get_type_name(),$sformatf("::release_pending_RBs:: Hitting a condition where dispatched RB is not in available DCE queue, entering timeout."),UVM_HIGH)
      timeout_state(DCE_TABLE_TIMEOUT,CMD_CT,1);
      m_rsrc_mgr.prepare_dce_msg_ids();
    end

    if(m_rsrc_mgr.get_m_addr_q_size_by_type(m_traffic_seq.traffic_info) == 0) begin
      //Address timeout and resource populating mechanism
      timeout_state(ADDRESS_TIMEOUT,.traffic_info(m_traffic_seq.traffic_info));
    end
    m_pkt_gen_seq.construct_packet(m_traffic_seq,smi_dispatch_q,MW_primary_dtw_q);
  end
  if(m_rsrc_mgr.rbid_release_q.size!=0) begin
    `uvm_info(get_type_name(),$sformatf("::release_pending_RBs:: rbid_release_q:%0p", m_rsrc_mgr.rbid_release_q),UVM_LOW)
    `uvm_error(get_type_name(),$sformatf("::release_pending_RBs:: Executed RB release for %0d RBs. Yet, there are %0d pending",max_drain,m_rsrc_mgr.rbid_release_q.size))
  end
  else begin
    `uvm_info(get_type_name(),$sformatf("::flow_control:: Finished pending RB release process for %0d RBs.",max_drain),UVM_LOW)
  end
  uvm_config_db#(int)::set(null,"uvm_test_top","pending_release_count",max_drain);
endtask : release_pending_RBs

task dmi_vseq::end_of_test_control();
  //Gracefully exit virtual sequence, conserve simulation time.
  `uvm_info(get_type_name(),$sformatf("::flow_control:: Finished producing transactions, entering end of test control."),UVM_LOW)
  if(m_cfg.disable_vseq_flw_ctrl_timeout) begin
    `uvm_info(get_type_name(),$sformatf("::flow_control:: Waiting on smi_tx_mgr to complete smi_tx_count=%0d (k_num_cmd=%0d,num_RBRs=%0d,num_int_rls=%0d,num_MWs=%0d,num_clear_pending=%0d)"
                                          ,smi_tx_count,m_args.k_num_cmd,num_rbrs_sent,num_int_rls,num_merging_writes,num_clear_pending_rls),UVM_LOW)
    wait(smi_tx_count == (m_args.k_num_cmd + (num_rbrs_sent - num_int_rls) + num_merging_writes  + num_clear_pending_rls));
    `uvm_info(get_type_name(),$sformatf("::flow_control:: Waiting on in-flight transactions to complete (pending=%0d)",m_rsrc_mgr.m_table.size),UVM_LOW)
    wait(m_rsrc_mgr.m_table.size()==0);
    `uvm_info(get_type_name(),$sformatf("::flow_control:: Recorded completion of all in-flight transactions, exiting."),UVM_LOW)
  end
  else begin
    fork 
      begin
        `uvm_info(get_type_name(),$sformatf("::flow_control::WD_ON:: Waiting on smi_tx_mgr to complete smi_tx_count=%0d (k_num_cmd=%0d,num_RBRs=%0d,num_int_rls=%0d,num_MWs=%0d,num_clear_pending=%0d)"
                                              ,smi_tx_count,m_args.k_num_cmd,num_rbrs_sent,num_int_rls,num_merging_writes,num_clear_pending_rls),UVM_LOW)
        wait(smi_tx_count == (m_args.k_num_cmd + (num_rbrs_sent - num_int_rls) + num_merging_writes  + num_clear_pending_rls));
      // waivers();
        `uvm_info(get_type_name(),$sformatf("::flow_control::WD_ON:: Waiting on in-flight transactions to complete (pending=%0d)",m_rsrc_mgr.m_table.size),UVM_LOW)
        wait(m_rsrc_mgr.m_table.size()==0);
      end
      begin
        if(m_args.k_timeout/10 < 0) `uvm_error(get_type_name(),$sformatf("::flow_control::WD_ON:: Please use a reasonable value for +k_timeout %0d/10 > 0",m_args.k_timeout))
        #((m_args.k_timeout/10)*1ns);
        `uvm_info(get_type_name(),$sformatf("::flow_control::WD_ON:: Watchdog timer complete, dmi_table(pending=%0d) smi_dispatch_q(pending=%0d)", m_rsrc_mgr.m_table.size(),smi_dispatch_q.size()),UVM_NONE)
        if(m_rsrc_mgr.m_table.size()!=0) begin
          `uvm_error(get_type_name(),$sformatf("::flow_control::WD_ON:: Watchdog timeout | Transactions in-flight=%0d smi_dispatch_q(pending=%0d)",m_rsrc_mgr.m_table.size, smi_dispatch_q.size()))
        end
      end
    join_any
    `uvm_info(get_type_name(),$sformatf("::flow_control::WD_ON: Recorded completion of all in-flight transactions, exiting."),UVM_LOW)
  end
  `uvm_info(get_type_name(),$sformatf(" ===================END OF TEST==================="),UVM_LOW)
  `uvm_info(get_type_name(),$sformatf("| Size of aiu_table:%0d dce_table:%0d m_table:%0d |",m_rsrc_mgr.aiu_table_size, m_rsrc_mgr.dce_table_size, m_rsrc_mgr.m_table.size),UVM_LOW)
  `uvm_info(get_type_name(),$sformatf(" ================================================="),UVM_LOW)
endtask : end_of_test_control

