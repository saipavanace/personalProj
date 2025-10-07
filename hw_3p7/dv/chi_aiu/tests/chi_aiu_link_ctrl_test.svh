

class chi_aiu_link_ctrl_test extends chi_aiu_base_test;

  `uvm_component_utils(chi_aiu_link_ctrl_test)
  //properties

  int num_trans;
  int k_num_snoop;
  int k_writedatacancel_pct;

  addr_trans_mgr     m_addr_mgr;
  chi_aiu_unit_args  m_args;
  chi_aiu_ral_addr_map_seq  addr_map_seq;

`ifdef USE_VIP_SNPS
  uvm_reg_sequence   csr_seq;
  //snps_chi_aiu_vseq  snps_vseq; 
  <%=obj.BlockId%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq#(<%=obj.AiuInfo[obj.Id].FUnitId%>)   m_snps_chi<%=obj.Id%>_vseq;
  svt_chi_rn_transaction_random_sequence svt_chi_rn_transaction_random_seq;
  svt_chi_link_service_activate_sequence svt_chi_link_service_activate_seq;
  svt_chi_link_service_deactivate_sequence svt_chi_link_service_deactivate_seq;
  svt_chi_link_service_random_sequence svt_chi_link_service_link_strv_seq;
  cust_svt_report_catcher syncdvmop_error_catcher;
  bit vip_snps_non_coherent_txn = 0;
  bit vip_snps_coherent_txn = 0;
  int vip_snps_seq_length = 5;
  bit rand_success;
`else   
  //properties
  chi_txn_seq#(chi_req_seq_item)  m_req_seq;
  chi_txn_seq#(chi_lnk_seq_item)  m_lnk_seq;
  chi_txn_seq#(chi_base_seq_item) m_txs_seq;
  chi_aiu_vseq#(<%=obj.AiuInfo[obj.Id].FUnitId%>)   m_vseq;
`endif  

  //Interface Methods
  extern function new(
    string name = "chi_aiu_link_ctrl_test",
    uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);
  //Run task
  extern task run_phase(uvm_phase phase);

  //Helper methods
  extern function void set_testplusargs();
`ifdef USE_VIP_SNPS
     extern task construct_lk_down_seq_snps();
     extern task construct_lk_up_seq_snps();
     extern task construct_lk_strv_snps();
`else
  extern task construct_lk_down_seq(
    ref chi_txn_seq#(chi_lnk_seq_item) m_lnk_seq);
  extern task construct_txs_seq(
    ref chi_txn_seq#(chi_base_seq_item) m_txs_seq);
`endif

endclass: chi_aiu_link_ctrl_test

function chi_aiu_link_ctrl_test::new(
  string name = "chi_aiu_link_ctrl_test",
  uvm_component parent = null);

  super.new(name, parent);
`ifdef USE_VIP_SNPS
   m_addr_mgr = addr_trans_mgr::get_instance();
   m_addr_mgr.gen_memory_map();
`endif  
endfunction: new

function void chi_aiu_link_ctrl_test::build_phase(uvm_phase phase);
`ifdef USE_VIP_SNPS
  svt_chi_item m_svt_chi_item;
`endif  
  super.build_phase(phase);
`ifdef USE_VIP_SNPS
      syncdvmop_error_catcher = new();
      m_args = chi_aiu_unit_args::type_id::create($psprintf("chi_aiu_unit_args[%0d]", 0));
      set_type_override_by_type(svt_chi_rn_transaction::get_type(),svt_chi_item::get_type());
      set_type_override_by_type (svt_chi_rn_snoop_transaction::get_type(), chi_snoop_item::get_type());
      //set_type_override_by_type(svt_chi_rn_snoop_response_sequence::get_type(),cust_svt_chi_rn_directed_snoop_response_sequence::get_type());
      m_svt_chi_item = svt_chi_item::type_id::create("m_svt_chi_item");
      m_svt_chi_item.m_args = m_args;
      `uvm_info(get_name(),$psprintf("Overrode svt_chi_rn_transaction by svt_chi_item"),UVM_DEBUG)
    uvm_config_db#(uvm_object_wrapper)::set(this, "env.amba_system_env.sequencer.main_phase", "default_sequence", null);
    uvm_config_db#(int unsigned)::set(this, "env.amba_system_env.chi_system[0].rn[0].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "sequence_length", m_args.k_num_requests.get_value());
    uvm_config_db#(bit)::set(this, "env.amba_system_env.chi_system[0].rn[0].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "enable_non_blocking", 1);
   set_testplusargs();
     uvm_report_cb::add(null,syncdvmop_error_catcher); 

`endif  
endfunction: build_phase

function void chi_aiu_link_ctrl_test::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

`ifndef USE_VIP_SNPS
   //User knobs for ADDRESS manager configuration
   m_addr_mgr = addr_trans_mgr::get_instance();
   m_addr_mgr.gen_memory_map();
   m_args = chi_aiu_unit_args::type_id::create(
     $psprintf("chi_aiu_unit_args[%0d]", 0));
   set_testplusargs();
`endif  
endfunction: connect_phase

function void chi_aiu_link_ctrl_test::report_phase(uvm_phase phase);
  super.report_phase(phase);
endfunction: report_phase

task chi_aiu_link_ctrl_test::run_phase(uvm_phase phase);

`ifndef USE_VIP_SNPS
  bit timeout;
  super.run_phase(phase);
  //m_req_seq = chi_txn_seq#(chi_req_seq_item)::type_id::create("m_req_seq");
  m_lnk_seq = chi_txn_seq#(chi_lnk_seq_item)::type_id::create("m_lnk_seq");
  //m_txs_seq = chi_txn_seq#(chi_base_seq_item)::type_id::create("m_txs_seq");

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
      repeat (20) begin
        `uvm_info(get_name(), "Start CHI AIU VSEQ", UVM_NONE)
        m_vseq.start(null);
        `uvm_info(get_name(), "Done CHI AIU VSEQ", UVM_NONE)
        #100000ns;
        `uvm_info(get_name(), "BALA_DEBUG Start power down", UVM_NONE)
        construct_lk_down_seq(m_lnk_seq);
        `uvm_info(get_name(), "BALA_DEBUG Done power down", UVM_NONE)
      end
    end
    begin
      if (k_num_snoop >= 0)
          m_system_bfm_seq.k_num_snp.set_value(k_num_snoop); 
      //m_system_bfm_seq.bw_test = 1;
      //m_system_bfm_seq.dis_delay_dtr_req              = 1;
      //m_system_bfm_seq.dis_delay_str_req              = 1;
      //m_system_bfm_seq.dis_delay_dtr_req              = 1;
      //m_system_bfm_seq.dis_delay_tx_resp           = 1;
      //m_system_bfm_seq.dis_delay_cmd_resp             = 1;
      //m_system_bfm_seq.dis_delay_dtw_resp             = 1;
      //m_system_bfm_seq.dis_delay_upd_resp             = 1;
      //m_system_bfm_seq.high_system_bfm_slv_rsp_delays = 0;
      m_system_bfm_seq.start(null);
    end
    
  join_any


  #1.2ms;
  `uvm_info(get_name(), "Dropping objection for bringup_test", UVM_NONE)
  phase.drop_objection(this, "bringup_test");
`else //USE_VIP_SNPS


  uvm_config_db#(chi_aiu_scb)::set(uvm_root::get(), 
                                  "*", 
                                  "chi_aiu_scb", 
                                  m_env.m_scb);

<% if (obj.INHOUSE_APB_VIP) { %>
<% if(obj.testBench == 'chi_aiu') { %>
 `ifndef VCS
  if (k_csr_seq) begin
`else // `ifndef VCS
  if (k_csr_seq != "") begin
 `endif // `ifndef VCS ... `else ... 
<% } else {%>
  if (k_csr_seq) begin
<% } %>
      csr_seq.model = m_env.m_regs;
  end
<% } %>
  
  m_snps_chi<%=obj.Id%>_vseq = <%=obj.BlockId%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq#(<%=obj.AiuInfo[obj.Id].FUnitId%>)::type_id::create("m_chi<%=obj.Id%>_seq");
  m_snps_chi<%=obj.Id%>_vseq.rn_xact_seqr = env.amba_system_env.chi_system[0].rn[<%=obj.Id%>].rn_xact_seqr;
  //m_snps_chi<%=obj.Id%>_vseq.rn_snp_xact_seqr = env.amba_system_env.chi_system[0].rn[<%=obj.Id%>].rn_snp_xact_seqr; 
  m_snps_chi<%=obj.Id%>_vseq.vip_snps_seq_length = m_args.k_num_requests.get_value();
  m_snps_chi<%=obj.Id%>_vseq.set_unit_args(m_args);



  if (!$value$plusargs("num_trans=%d",num_trans)) begin
      num_trans = 1;
  end


  phase.raise_objection(this, "chi_aiu_qchannel_test");
  addr_map_seq = chi_aiu_ral_addr_map_seq::type_id::create("addr_map_seq");
  addr_map_seq.model     = m_env.m_regs;
  `uvm_info(get_name(), "Start Address map sequence", UVM_DEBUG)
  addr_map_seq.start(m_env.m_apb_agent.m_apb_sequencer);
  `uvm_info(get_name(), "Done Address map sequence", UVM_DEBUG)

  `uvm_info(get_name(), "Start svt_chi_link_service_sequence", UVM_NONE)
   svt_chi_link_service_activate_seq = svt_chi_link_service_activate_sequence::type_id::create("svt_chi_link_service_activate_seq");
   svt_chi_link_service_activate_seq.start(env.amba_system_env.chi_system[0].rn[0].link_svc_seqr) ;
  `uvm_info(get_name(), "Done svt_chi_link_service_sequence", UVM_NONE)

  fork: tFrok
    begin
      repeat (20) begin
        `uvm_info(get_name(), "Start CHI AIU VSEQ", UVM_NONE)
         construct_lk_up_seq_snps();
         m_snps_chi<%=obj.Id%>_vseq.start(null);
        `uvm_info(get_name(), "Done CHI AIU VSEQ", UVM_NONE)
        #25000ns;
        `uvm_info(get_name(), " Start power down", UVM_NONE)
        construct_lk_down_seq_snps();
          #100ns; //added for snps
        `uvm_info(get_name(), " Done power down", UVM_NONE)
      end
    end
    begin
      if (k_num_snoop >= 0)
          m_system_bfm_seq.k_num_snp.set_value(k_num_snoop); 
      //m_system_bfm_seq.bw_test = 1;
      //m_system_bfm_seq.dis_delay_dtr_req              = 1;
      //m_system_bfm_seq.dis_delay_str_req              = 1;
      //m_system_bfm_seq.dis_delay_dtr_req              = 1;
      //m_system_bfm_seq.dis_delay_tx_resp           = 1;
      //m_system_bfm_seq.dis_delay_cmd_resp             = 1;
      //m_system_bfm_seq.dis_delay_dtw_resp             = 1;
      //m_system_bfm_seq.dis_delay_upd_resp             = 1;
      //m_system_bfm_seq.high_system_bfm_slv_rsp_delays = 0;
      m_system_bfm_seq.start(null);
    end
    
  join_any


  #1.2ms;
  `uvm_info(get_name(), "Dropping objection for bringup_test", UVM_NONE)
  phase.drop_objection(this, "bringup_test");

`endif
endtask: run_phase

`ifdef USE_VIP_SNPS
    task chi_aiu_link_ctrl_test::construct_lk_down_seq_snps();
       `uvm_info(get_name(), "Start svt_chi_link_down_service_sequence", UVM_NONE)
        svt_chi_link_service_deactivate_seq = svt_chi_link_service_deactivate_sequence::type_id::create("svt_chi_link_service_deactivate_seq");
        svt_chi_link_service_deactivate_seq.min_cycles_in_deactive = 30;
        svt_chi_link_service_deactivate_seq.start(env.amba_system_env.chi_system[0].rn[0].link_svc_seqr) ;
       `uvm_info(get_name(), "Done svt_chi_link_down_service_sequence", UVM_NONE)
    endtask: construct_lk_down_seq_snps


   task chi_aiu_link_ctrl_test::construct_lk_up_seq_snps();
       `uvm_info(get_name(), "Start svt_chi_link_up_service_sequence", UVM_NONE)
        svt_chi_link_service_activate_seq = svt_chi_link_service_activate_sequence::type_id::create("svt_chi_link_service_activate_seq");
        svt_chi_link_service_activate_seq.start(env.amba_system_env.chi_system[0].rn[0].link_svc_seqr) ;
       `uvm_info(get_name(), "Done svt_chi_link_up_service_sequence", UVM_NONE)
   endtask: construct_lk_up_seq_snps


   task chi_aiu_link_ctrl_test::construct_lk_strv_snps();
       `uvm_info(get_name(), "Start svt_chi_lk_strv_snps_sequence", UVM_NONE)
        svt_chi_link_service_link_strv_seq = svt_chi_link_service_random_sequence::type_id::create("svt_chi_link_service_link_strv_seq");
        //svt_chi_link_service_link_strv_seq.randomize_service_request(.rand_success(rand_success));
        svt_chi_link_service_link_strv_seq.start(env.amba_system_env.chi_system[0].rn[0].link_svc_seqr) ;
       `uvm_info(get_name(), "Done svt_chi_lk_strv_snps_sequence", UVM_NONE)
    endtask: construct_lk_strv_snps

`else
task chi_aiu_link_ctrl_test::construct_lk_down_seq(
  ref chi_txn_seq#(chi_lnk_seq_item) m_lnk_seq);

  chi_lnk_seq_item seq_item;

  seq_item = chi_lnk_seq_item::type_id::create("chi_lnk_seq_item");

  seq_item.n_cycles = 30;
  seq_item.m_txactv_st = POWDN_TX_LN;
  m_lnk_seq.push_back(seq_item);
  `uvm_info(get_name(), "Power Down Link seq", UVM_NONE)
  m_lnk_seq.start(m_env.m_chi_agent.m_lnk_hske_seqr);
  `uvm_info(get_name(), "Done Powr Down Link seq", UVM_NONE)

endtask: construct_lk_down_seq

task chi_aiu_link_ctrl_test::construct_txs_seq(
    ref chi_txn_seq#(chi_base_seq_item) m_txs_seq);

    chi_base_seq_item seq_item;

    seq_item = chi_base_seq_item::type_id::create("chi_base_seq_item");
    seq_item.txsactv = 1'b1;
    m_txs_seq.push_back(seq_item);
    m_txs_seq.start(m_env.m_chi_agent.m_txs_actv_seqr);

endtask: construct_txs_seq

`endif

function void chi_aiu_link_ctrl_test::set_testplusargs();

    m_args.k_txreq_hld_dly.set_value(1);
    m_args.k_txreq_dly_min.set_value(0);
    m_args.k_txreq_dly_max.set_value(5);
    m_args.k_txrsp_hld_dly.set_value(1);
    m_args.k_txrsp_dly_min.set_value(0);
    m_args.k_txrsp_dly_max.set_value(15);
    m_args.k_txdat_hld_dly.set_value(1);
    m_args.k_txdat_dly_min.set_value(0);
    m_args.k_txdat_dly_max.set_value(15);
 
    if($test$plusargs("SNPrsp_time_out_test")) begin
      m_args.k_txdat_dly_min.set_value(9000);
      m_args.k_txdat_dly_max.set_value(10000);
    end

    if($test$plusargs("chi_intf_b2b")) begin
        m_args.k_txreq_hld_dly.set_value(1);
        m_args.k_txreq_dly_min.set_value(0);
        m_args.k_txreq_dly_max.set_value(0);
        m_args.k_txrsp_hld_dly.set_value(1);
        m_args.k_txrsp_dly_min.set_value(0);
        m_args.k_txrsp_dly_max.set_value(0);
        m_args.k_txdat_hld_dly.set_value(1);
        m_args.k_txdat_dly_min.set_value(0);
        m_args.k_txdat_dly_max.set_value(0);
    end

    if($test$plusargs("read_txn_test")) begin
        m_args.k_rd_noncoh_pct.set_value(90);
        m_args.k_rd_rdonce_pct.set_value(90);
        m_args.k_rd_ldrstr_pct.set_value(90);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(0);
        m_args.k_wr_cohunq_pct.set_value(0);
        m_args.k_wr_cpybck_pct.set_value(0);
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_unsupported_txn_pct.set_value(0);
    end else if ($test$plusargs("dataless_txn_test")) begin
        m_args.k_rd_noncoh_pct.set_value(0);
        m_args.k_rd_rdonce_pct.set_value(0);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(90);
        m_args.k_dt_ls_cmo_pct.set_value(90);
        m_args.k_dt_ls_sth_pct.set_value(90);
        m_args.k_wr_noncoh_pct.set_value(0);
        m_args.k_wr_cohunq_pct.set_value(0);
        m_args.k_wr_cpybck_pct.set_value(0);
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_unsupported_txn_pct.set_value(0);
    end else if ($test$plusargs("write_txn_test")) begin
        m_args.k_rd_noncoh_pct.set_value(0);
        m_args.k_rd_rdonce_pct.set_value(0);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(90);
        m_args.k_wr_cohunq_pct.set_value(90);
        m_args.k_wr_cpybck_pct.set_value(90);
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_unsupported_txn_pct.set_value(0);
    end else if ($test$plusargs("write_coh_noncoh_txn_test")) begin
        m_args.k_rd_noncoh_pct.set_value(0);
        m_args.k_rd_rdonce_pct.set_value(0);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(90);
        m_args.k_wr_cohunq_pct.set_value(90);
        m_args.k_wr_cpybck_pct.set_value(0);
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_unsupported_txn_pct.set_value(0);
    end else if ($test$plusargs("random_txn_test")) begin
        m_args.k_rd_noncoh_pct.set_value(90);
        m_args.k_rd_rdonce_pct.set_value(90);
        m_args.k_rd_ldrstr_pct.set_value(90);
        m_args.k_dt_ls_upd_pct.set_value(90);
        m_args.k_dt_ls_cmo_pct.set_value(90);
        m_args.k_dt_ls_sth_pct.set_value(90);
        m_args.k_wr_noncoh_pct.set_value(90);
        m_args.k_wr_cohunq_pct.set_value(90);
        m_args.k_wr_cpybck_pct.set_value(90);
        m_args.k_atomic_st_pct.set_value(70);
        m_args.k_atomic_ld_pct.set_value(70);
        m_args.k_atomic_sw_pct.set_value(70);
        m_args.k_atomic_cm_pct.set_value(70);
        m_args.k_dvm_opert_pct.set_value(40);
        m_args.k_pre_fetch_pct.set_value(40);
        m_args.k_unsupported_txn_pct.set_value(0);
    end else if ($test$plusargs("atomic_txn_test")) begin
        m_args.k_rd_noncoh_pct.set_value(0);
        m_args.k_rd_rdonce_pct.set_value(0);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(0);
        m_args.k_wr_cohunq_pct.set_value(0);
        m_args.k_wr_cpybck_pct.set_value(0);
        m_args.k_atomic_st_pct.set_value(80);
        m_args.k_atomic_ld_pct.set_value(80);
        m_args.k_atomic_sw_pct.set_value(80);
        m_args.k_atomic_cm_pct.set_value(80);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_rq_lcrdrt_pct.set_value(20);
        m_args.k_unsupported_txn_pct.set_value(0);
    end else if ($test$plusargs("dvm_op_test")) begin
        m_args.k_rd_noncoh_pct.set_value(0);
        m_args.k_rd_rdonce_pct.set_value(0);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(0);
        m_args.k_wr_cohunq_pct.set_value(0);
        m_args.k_wr_cpybck_pct.set_value(0);
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(80);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_unsupported_txn_pct.set_value(0);
    end else if ($test$plusargs("reqlcrd_op_test")) begin
        m_args.k_rd_noncoh_pct.set_value(0);
        m_args.k_rd_rdonce_pct.set_value(0);
        m_args.k_rd_ldrstr_pct.set_value(0);
        m_args.k_dt_ls_upd_pct.set_value(0);
        m_args.k_dt_ls_cmo_pct.set_value(0);
        m_args.k_dt_ls_sth_pct.set_value(0);
        m_args.k_wr_noncoh_pct.set_value(0);
        m_args.k_wr_cohunq_pct.set_value(0);
        m_args.k_wr_cpybck_pct.set_value(0);
        m_args.k_atomic_st_pct.set_value(0);
        m_args.k_atomic_ld_pct.set_value(0);
        m_args.k_atomic_sw_pct.set_value(0);
        m_args.k_atomic_cm_pct.set_value(0);
        m_args.k_dvm_opert_pct.set_value(0);
        m_args.k_pre_fetch_pct.set_value(0);
        m_args.k_rq_lcrdrt_pct.set_value(100);
        m_args.k_unsupported_txn_pct.set_value(0);
    end else if ($test$plusargs("unsupported_txn")) begin
        int wt_unsupported_txn;
        $value$plusargs("unsupported_txn=%d",wt_unsupported_txn);
        m_args.k_unsupported_txn_pct.set_value(wt_unsupported_txn);
        m_args.k_rd_noncoh_pct.set_value(90);
        m_args.k_rd_rdonce_pct.set_value(90);
        m_args.k_rd_ldrstr_pct.set_value(90);
        m_args.k_dt_ls_upd_pct.set_value(90);
        m_args.k_dt_ls_cmo_pct.set_value(90);
        m_args.k_dt_ls_sth_pct.set_value(90);
        m_args.k_wr_noncoh_pct.set_value(90);
        m_args.k_wr_cohunq_pct.set_value(90);
        m_args.k_wr_cpybck_pct.set_value(90);
        m_args.k_atomic_st_pct.set_value(70);
        m_args.k_atomic_ld_pct.set_value(70);
        m_args.k_atomic_sw_pct.set_value(70);
        m_args.k_atomic_cm_pct.set_value(70);
        m_args.k_dvm_opert_pct.set_value(40);
        m_args.k_pre_fetch_pct.set_value(40);
    end

    m_args.k_coh_addr_pct.set_value(100);
    m_args.k_alloc_hint_pct.set_value(90);
    m_args.k_cacheable_pct.set_value(90);
    m_args.k_wr_sthunq_pct.set_value(0); // Not supported in NCore3.0

    if (!$value$plusargs("k_num_snoop=%d",k_num_snoop)) begin
        k_num_snoop = -1;
    end 
  if (!$value$plusargs("wr_dat_cancel_pct=%d",k_writedatacancel_pct)) begin
      m_args.k_writedatacancel_pct.set_value(k_writedatacancel_pct);
  end 

  if($test$plusargs("STRreq_time_out_test") || $test$plusargs("CMDrsp_time_out_test")) begin
    m_args.k_rq_lcrdrt_pct.set_value(0);
  end
  if($test$plusargs("user_addr_for_csr")) begin
    m_args.k_device_type_mem_pct.set_value(0);
    m_args.k_wr_cpybck_pct.set_value(0);
    m_args.k_rq_lcrdrt_pct.set_value(0);
  end

endfunction: set_testplusargs
