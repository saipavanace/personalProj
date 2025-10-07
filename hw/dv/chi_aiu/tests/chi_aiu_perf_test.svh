

class chi_aiu_perf_test extends chi_aiu_base_test;

  `uvm_component_utils(chi_aiu_perf_test)

  //properties
   `ifndef USE_VIP_SNPS
  chi_aiu_vseq#(<%=obj.AiuInfo[obj.Id].FUnitId%>)   m_vseq;
   `endif
  addr_trans_mgr     m_addr_mgr;
  chi_aiu_unit_args  m_args;
  chi_aiu_ral_addr_map_seq  addr_map_seq;
  `ifdef USE_VIP_SNPS
   //snps_chi_aiu_vseq  snps_vseq; 
  <%=obj.BlockId%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq#(<%=obj.AiuInfo[obj.Id].FUnitId%>)   m_snps_chi<%=obj.Id%>_vseq;
  `endif 

  int num_trans;
  int k_num_snoop;
  int k_writedatacancel_pct;

  `ifdef USE_VIP_SNPS
   svt_chi_rn_transaction_random_sequence svt_chi_rn_transaction_random_seq;
   svt_chi_link_service_activate_sequence svt_chi_link_service_activate_seq;
   bit vip_snps_non_coherent_txn = 0;
   bit vip_snps_coherent_txn = 0;
   int vip_snps_seq_length = 5;
  `endif //USE_VIP_SNPS

  //Interface Methods
  extern function new(
    string name = "chi_aiu_perf_test",
    uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);
  extern function void check_phase(uvm_phase phase);
  //Run task
  extern task run_phase(uvm_phase phase);

  //Helper methods
  extern function void set_testplusargs();

  virtual function void pre_abort();
   `ifndef USE_VIP_SNPS
    m_vseq.print_pending_txns();
   `endif
    m_system_bfm_seq.end_of_test_checks();
    extract_phase(null);
    report_phase(null);
  endfunction : pre_abort

endclass: chi_aiu_perf_test

function chi_aiu_perf_test::new(
  string name = "chi_aiu_perf_test",
  uvm_component parent = null);

  super.new(name, parent);
   //User knobs for ADDRESS manager configuration
   m_addr_mgr = addr_trans_mgr::get_instance();
   m_addr_mgr.gen_memory_map();
endfunction: new

function void chi_aiu_perf_test::build_phase(uvm_phase phase);

  `ifdef USE_VIP_SNPS
   svt_chi_item m_svt_chi_item;
  `endif
  super.build_phase(phase);

   m_args = chi_aiu_unit_args::type_id::create(
     $psprintf("chi_aiu_unit_args[%0d]", 0));
   set_testplusargs();
   
    `ifdef USE_VIP_SNPS
   /** Factory override of the master transaction object */
    if(vip_snps_non_coherent_txn) begin
      set_type_override_by_type(svt_chi_rn_transaction::get_type(),rn_noncoherent_transaction::get_type());
      `uvm_info(get_name(),$psprintf("Overrode svt_chi_rn_transaction by rn_noncoherent_transaction"),UVM_DEBUG)
    end
    else if(vip_snps_coherent_txn) begin
      set_type_override_by_type(svt_chi_rn_transaction::get_type(),rn_coherent_transaction::get_type());
      `uvm_info(get_name(),$psprintf("Overrode svt_chi_rn_transaction by rn_coherent_transaction"),UVM_DEBUG)
    end
    else begin
      set_type_override_by_type(svt_chi_rn_transaction::get_type(),svt_chi_item::get_type());
      set_type_override_by_type (svt_chi_rn_snoop_transaction::get_type(), chi_snoop_item::get_type());
      //set_type_override_by_type(svt_chi_rn_snoop_response_sequence::get_type(),cust_svt_chi_rn_directed_snoop_response_sequence::get_type());
      m_svt_chi_item = svt_chi_item::type_id::create("m_svt_chi_item");
      m_svt_chi_item.m_args = m_args;
      `uvm_info(get_name(),$psprintf("Overrode svt_chi_rn_transaction by svt_chi_item"),UVM_DEBUG)
    end
    
    /** Apply the null sequence to the AMBA ENV virtual sequencer to override the default sequence. */
    uvm_config_db#(uvm_object_wrapper)::set(this, "env.amba_system_env.sequencer.main_phase", "default_sequence", null);

    //uvm_config_db#(uvm_object_wrapper)::set(this, "env.amba_system_env.chi_system[0].rn[0].rn_xact_seqr.main_phase", "default_sequence", svt_chi_rn_transaction_random_sequence::type_id::get());
    //uvm_config_db#(int unsigned)::set(this, "env.amba_system_env.chi_system[0].rn[0].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "sequence_length", vip_snps_seq_length);
    uvm_config_db#(int unsigned)::set(this, "env.amba_system_env.chi_system[0].rn[0].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "sequence_length", m_args.k_num_requests.get_value());
    uvm_config_db#(bit)::set(this, "env.amba_system_env.chi_system[0].rn[0].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "enable_non_blocking", 1);
  
  `endif

endfunction: build_phase

function void chi_aiu_perf_test::connect_phase(uvm_phase phase);
     super.connect_phase(phase);
   <% for (var i = 0; i < 3; i++) { %>
         m_env.m_smi_agent.m_smi<%=i%>_tx_driver.m_vif.k_burst_pct = 100;
   <% } %>
   <% for (var i = 0; i < 3; i++) { %>
         m_env.m_smi_agent.m_smi<%=i%>_rx_driver.m_vif.k_burst_pct = 100;
   <% } %>

endfunction: connect_phase

function void chi_aiu_perf_test::report_phase(uvm_phase phase);
  super.report_phase(phase);
endfunction: report_phase

function void chi_aiu_perf_test::check_phase(uvm_phase phase);
  super.check_phase(phase);
  `ifndef USE_VIP_SNPS
  if (m_vseq.m_chi_container.m_txnid_pool.size() != 256)
    `uvm_fatal(get_name(), "Test didnt end gracefully, CHI BFM has pending transactions")
  if (m_system_bfm_seq.end_of_test_checks())
    `uvm_fatal(get_name(), "Test didnt end gracefully, System BFM has pending transactions")
  `endif //USE_VIP_SNPS

endfunction: check_phase

task chi_aiu_perf_test::run_phase(uvm_phase phase);
  `ifndef USE_VIP_SNPS
  bit timeout;

  super.run_phase(phase);

  m_vseq = chi_aiu_vseq#(<%=obj.AiuInfo[obj.Id].FUnitId%>)::type_id::create("m_vseq");
  m_vseq.m_chi_container = m_chi_container;
  m_vseq.m_rn_tx_req_chnl_seqr = m_env.m_chi_agent.m_rn_tx_req_chnl_seqr;
  m_vseq.m_rn_tx_dat_chnl_seqr = m_env.m_chi_agent.m_rn_tx_dat_chnl_seqr;
  m_vseq.m_rn_tx_rsp_chnl_seqr = m_env.m_chi_agent.m_rn_tx_rsp_chnl_seqr;
  m_vseq.m_rn_rx_rsp_chnl_seqr = m_env.m_chi_agent.m_rn_rx_rsp_chnl_seqr;
  m_vseq.m_rn_rx_dat_chnl_seqr = m_env.m_chi_agent.m_rn_rx_dat_chnl_seqr;
  m_vseq.m_rn_rx_snp_chnl_seqr = m_env.m_chi_agent.m_rn_rx_snp_chnl_seqr;
  m_vseq.m_lnk_hske_seqr       = m_env.m_chi_agent.m_lnk_hske_seqr;
  m_vseq.m_txs_actv_seqr       = m_env.m_chi_agent.m_txs_actv_seqr;
  m_vseq.m_sysco_seqr          = m_env.m_chi_agent.m_sysco_seqr;
  m_vseq.set_unit_args(m_args);

  addr_map_seq = chi_aiu_ral_addr_map_seq::type_id::create("addr_map_seq");
  addr_map_seq.model     = m_env.m_regs;

  if (!$value$plusargs("num_trans=%d",num_trans)) begin
      num_trans = 1;
  end

  phase.raise_objection(this, "bringup_test");
  
  `uvm_info(get_name(), "Start Address map sequence", UVM_NONE)
  addr_map_seq.start(m_env.m_apb_agent.m_apb_sequencer);
  `uvm_info(get_name(), "Done Address map sequence", UVM_NONE)

  fork: tFrok
    begin
      `uvm_info(get_name(), "Start CHI AIU VSEQ", UVM_NONE)
      m_vseq.start(null);
      `uvm_info(get_name(), "Done CHI AIU VSEQ", UVM_NONE)
    end
    //begin
    //  #1.5ms;
    //  //m_vseq.print_pending_txns();
    //  if (m_vseq.m_chi_container.m_txnid_pool.size() != 256)
    //    `uvm_fatal(get_name(), "Test Timeout")
    //end
    begin
      m_system_bfm_seq.k_num_snp.set_value(k_num_snoop); 
      m_system_bfm_seq.bw_test = 1;
      m_system_bfm_seq.dis_delay_dtr_req              = 1;
      m_system_bfm_seq.dis_delay_str_req              = 1;
      m_system_bfm_seq.dis_delay_dtr_req              = 1;
      m_system_bfm_seq.dis_delay_tx_resp           = 1;
      m_system_bfm_seq.dis_delay_cmd_resp             = 1;
      m_system_bfm_seq.dis_delay_dtw_resp             = 1;
      m_system_bfm_seq.dis_delay_upd_resp             = 1;
      m_system_bfm_seq.high_system_bfm_slv_rsp_delays = 0;
      m_system_bfm_seq.start(null);
    end
    
  join_any

  #0.5ms;
  `uvm_info(get_name(), "Dropping objection for bringup_test", UVM_NONE)
   phase.drop_objection(this, "bringup_test");

 `else //USE_VIP_SNPS

    phase.raise_objection(this, "bringup_test");
    //snps_vseq = snps_chi_aiu_vseq::type_id::create("snps_vseq");
    //snps_vseq.rn_xact_seqr = env.amba_system_env.chi_system[0].rn[0].rn_xact_seqr;
    //snps_vseq.rn_snp_xact_seqr = env.amba_system_env.chi_system[0].rn[0].rn_snp_xact_seqr; 
    //snps_vseq.vip_snps_seq_length = m_args.k_num_requests.get_value();
    //snps_vseq.set_unit_args(m_args);
    //$display("%0t DEBUG: SVT mode starting chi_aiu_bringup_test::run_phase",$realtime);
    m_snps_chi<%=obj.Id%>_vseq = <%=obj.BlockId%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq#(<%=obj.AiuInfo[obj.Id].FUnitId%>)::type_id::create("m_chi<%=obj.Id%>_seq");
    m_snps_chi<%=obj.Id%>_vseq.rn_xact_seqr = env.amba_system_env.chi_system[0].rn[<%=obj.Id%>].rn_xact_seqr;
    //m_snps_chi<%=obj.Id%>_vseq.rn_snp_xact_seqr = env.amba_system_env.chi_system[0].rn[<%=obj.Id%>].rn_snp_xact_seqr; 
    m_snps_chi<%=obj.Id%>_vseq.vip_snps_seq_length = m_args.k_num_requests.get_value();
    m_snps_chi<%=obj.Id%>_vseq.set_unit_args(m_args);
    addr_map_seq = chi_aiu_ral_addr_map_seq::type_id::create("addr_map_seq");
    addr_map_seq.model     = m_env.m_regs;
    `uvm_info(get_name(), "Start Address map sequence", UVM_NONE)
    addr_map_seq.start(m_env.m_apb_agent.m_apb_sequencer);
    `uvm_info(get_name(), "Done Address map sequence", UVM_NONE)
    `uvm_info(get_name(), "Start svt_chi_link_service_sequence", UVM_NONE)
    svt_chi_link_service_activate_seq = svt_chi_link_service_activate_sequence::type_id::create("svt_chi_link_service_activate_seq");
    svt_chi_link_service_activate_seq.start(env.amba_system_env.chi_system[0].rn[0].link_svc_seqr) ;
    `uvm_info(get_name(), "Done svt_chi_link_service_sequence", UVM_NONE)

   fork
    begin
      if(vip_snps_coherent_txn || vip_snps_non_coherent_txn) begin
        `uvm_info(get_name(), "Start svt_chi_rn_transaction_random_sequence", UVM_NONE)
        svt_chi_rn_transaction_random_seq = svt_chi_rn_transaction_random_sequence::type_id::create("svt_chi_rn_transaction_random_seq");
        svt_chi_rn_transaction_random_seq.start(env.amba_system_env.chi_system[0].rn[0].rn_xact_seqr) ;
        `uvm_info(get_name(), "Done svt_chi_rn_transaction_random_sequence", UVM_NONE)
      end
      else begin
        `uvm_info(get_name(), "Start snps_vseq", UVM_NONE)
        //snps_vseq.start(null);
        m_snps_chi<%=obj.Id%>_vseq.start(null);
        `uvm_info(get_name(), "Done snps_vseq", UVM_NONE)
      end
    end
    begin
      m_system_bfm_seq.k_num_snp.set_value(k_num_snoop); 
      m_system_bfm_seq.bw_test = 1;
      m_system_bfm_seq.dis_delay_dtr_req              = 1;
      m_system_bfm_seq.dis_delay_str_req              = 1;
      m_system_bfm_seq.dis_delay_dtr_req              = 1;
      m_system_bfm_seq.dis_delay_tx_resp           = 1;
      m_system_bfm_seq.dis_delay_cmd_resp             = 1;
      m_system_bfm_seq.dis_delay_dtw_resp             = 1;
      m_system_bfm_seq.dis_delay_upd_resp             = 1;
      m_system_bfm_seq.high_system_bfm_slv_rsp_delays = 0;
      m_system_bfm_seq.start(null);
    end

    join_any
    //#1ms;
    #50000ns;
    `uvm_info(get_name(), "Dropping objection for bringup_test", UVM_NONE)
     phase.phase_done.set_drain_time(this, 500ns);
     phase.drop_objection(this, "bringup_test");
`endif //USE_VIP_SNPS

endtask: run_phase

function void chi_aiu_perf_test::set_testplusargs();

    m_args.k_txreq_hld_dly.set_value(1);
    m_args.k_txreq_dly_min.set_value(0);
    m_args.k_txreq_dly_max.set_value(0);
    m_args.k_txrsp_hld_dly.set_value(1);
    m_args.k_txrsp_dly_min.set_value(0);
    m_args.k_txrsp_dly_max.set_value(0);
    m_args.k_txdat_hld_dly.set_value(1);
    m_args.k_txdat_dly_min.set_value(0);
    m_args.k_txdat_dly_max.set_value(0);

    if($test$plusargs("read_txn_test")) begin
        //m_args.k_num_requests.set_value(1);
        m_args.k_rd_noncoh_pct.set_value(90);
        m_args.k_rd_rdonce_pct.set_value(90);
        m_args.k_rd_ldrstr_pct.set_value(90);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(0);
        m_args.k_wr_cohunq_pct.set_value(0);
        m_args.k_wr_sthunq_pct.set_value(0);
        m_args.k_wr_cpybck_pct.set_value(0);
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_rq_lcrdrt_pct.set_value(0);
        m_args.k_coh_addr_pct.set_value(80);
        m_args.k_noncoh_addr_pct.set_value(20);
        m_args.k_new_addr_pct.set_value(100);
        m_args.k_alloc_hint_pct.set_value(90);
        m_args.k_cacheable_pct.set_value(90);
    end else if ($test$plusargs("dataless_txn_test")) begin
        //m_args.k_num_requests.set_value(1);
        m_args.k_rd_noncoh_pct.set_value(0);
        m_args.k_rd_rdonce_pct.set_value(0);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(90);
        m_args.k_dt_ls_cmo_pct.set_value(90);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(0);
        m_args.k_wr_cohunq_pct.set_value(0);
        m_args.k_wr_sthunq_pct.set_value(0);
        m_args.k_wr_cpybck_pct.set_value(0);
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_rq_lcrdrt_pct.set_value(0);
        m_args.k_coh_addr_pct.set_value(90);
        m_args.k_noncoh_addr_pct.set_value(10);
        m_args.k_new_addr_pct.set_value(100);
        m_args.k_alloc_hint_pct.set_value(90);
        m_args.k_cacheable_pct.set_value(90);
    end else if ($test$plusargs("write_txn_test")) begin
        //m_args.k_num_requests.set_value(1);
        m_args.k_rd_noncoh_pct.set_value(0);
        m_args.k_rd_rdonce_pct.set_value(0);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(90);
        m_args.k_wr_cohunq_pct.set_value(90);
        m_args.k_wr_sthunq_pct.set_value(0);
        m_args.k_wr_cpybck_pct.set_value(90);
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_rq_lcrdrt_pct.set_value(0);
        m_args.k_coh_addr_pct.set_value(80);
        m_args.k_noncoh_addr_pct.set_value(20);
        m_args.k_new_addr_pct.set_value(100);
        m_args.k_alloc_hint_pct.set_value(90);
        m_args.k_cacheable_pct.set_value(90);
    end else if ($test$plusargs("latency_test")) begin
        m_args.k_rd_noncoh_pct.set_value(90);
        m_args.k_rd_rdonce_pct.set_value(0);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(90);
        m_args.k_wr_cohunq_pct.set_value(0);
        m_args.k_wr_sthunq_pct.set_value(0);
        m_args.k_wr_cpybck_pct.set_value(0);
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_rq_lcrdrt_pct.set_value(0);
        m_args.k_coh_addr_pct.set_value(10);
        m_args.k_noncoh_addr_pct.set_value(90);
        m_args.k_new_addr_pct.set_value(100);
        m_args.k_alloc_hint_pct.set_value(90);
        m_args.k_cacheable_pct.set_value(90);
    end else if ($test$plusargs("random_txn_test")) begin
        m_args.k_rd_noncoh_pct.set_value(0);
        m_args.k_rd_rdonce_pct.set_value(90);
        m_args.k_rd_ldrstr_pct.set_value(90);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(0);
        m_args.k_wr_cohunq_pct.set_value(90);
        m_args.k_wr_cpybck_pct.set_value(90);
        m_args.k_atomic_st_pct.set_value(70);
        m_args.k_atomic_ld_pct.set_value(70);
        m_args.k_atomic_sw_pct.set_value(70);
        m_args.k_atomic_cm_pct.set_value(70);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_unsupported_txn_pct.set_value(0);
    end

    m_args.k_coh_addr_pct.set_value(60);
    m_args.k_noncoh_addr_pct.set_value(40);
    m_args.k_new_addr_pct.set_value(100);
    m_args.k_alloc_hint_pct.set_value(90);
    m_args.k_cacheable_pct.set_value(90);
    m_args.k_dt_ls_sth_pct.set_value(0);
    m_args.k_wr_sthunq_pct.set_value(0);
    m_args.k_pre_fetch_pct.set_value(0);
    m_args.k_rq_lcrdrt_pct.set_value(0);

    if (!$value$plusargs("k_num_snoop=%d",k_num_snoop)) begin
        k_num_snoop = 0;
    end 
  if (!$value$plusargs("wr_dat_cancel_pct=%d",k_writedatacancel_pct)) begin
      m_args.k_writedatacancel_pct.set_value(k_writedatacancel_pct);
  end 

endfunction: set_testplusargs


