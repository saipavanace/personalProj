`ifndef DMI_BASE_TEST
`define DMI_BASE_TEST

////////////////////////////////////////////////////////////////////////////////
//
// Common Javascript functions at the top
//
////////////////////////////////////////////////////////////////////////////////
<% var realTestCorr;
   realTestCorr = (((obj.nHttCtrlEntries > 0) && (obj.DmiInfo[obj.Id].cmpInfo.HttDataErrorInfo.fnErrDetectCorrect.substring(0,6) === "SECDED")) || ((obj.useRttDataEntries > 0) && (obj.DmiInfo[obj.Id].cmpInfo.RttDataErrorInfo.fnErrDetectCorrect.substring(0,6) === "SECDED")));
  
%>
<% var realTestUncorr = 0;
 if (((obj.nHttCtrlEntries !== 0) || (obj.useRttDataEntries !== 0))) {
     realTestUncorr = 1;
 }
%>
<% var rttUncorr = 0;
 if((obj.useRttDataEntries > 0) && (obj.DmiInfo[obj.Id].cmpInfo.RttDataErrorInfo.fnErrDetectCorrect.substring(0,4) !== "NONE")) { 
    rttUncorr = 1;
}
%>
<% var httUncorr = 0;
 if((obj.nHttCtrlEntries > 0) && (obj.DmiInfo[obj.Id].cmpInfo.HttDataErrorInfo.fnErrDetectCorrect.substring(0,4) !== "NONE")) {
    httUncorr = 1;
}%>
<% var rttCorr = 0;
 if((obj.useRttDataEntries > 0) && (obj.DmiInfo[obj.Id].cmpInfo.RttDataErrorInfo.fnErrDetectCorrect.substring(0,6) === "SECDED")) { 
    rttCorr = 1;
}
%>
<% var httCorr = 0;
 if((obj.nHttCtrlEntries > 0) && (obj.DmiInfo[obj.Id].cmpInfo.HttDataErrorInfo.fnErrDetectCorrect.substring(0,6) === "SECDED")) {
    httCorr = 1;
}%>

<% if(obj.testBench == 'dmi') { %>
 `ifdef VCS 
// Add for UVM-1.2 compatibility
class local_report_server extends uvm_default_report_server;

   function new(string name = "local_report_server");
    super.new();
   endfunction
 
   virtual function void report_summarize(UVM_FILE file = 0);
   uvm_report_server svr;
    string id;
    string name;
    string output_str;
    string q[$],q2[$];
    int m_max_quit_count,m_quit_count;
    int m_severity_count[uvm_severity];
    int m_id_count[string];
    bit enable_report_id_count_summary =1 ;
    uvm_severity q1[$];

    svr = uvm_report_server::get_server();
    m_max_quit_count = get_max_quit_count();
    m_quit_count = get_quit_count();

    svr.get_id_set(q2);
    foreach(q2[s]) begin
      m_id_count[q2[s]] = svr.get_id_count(q2[s]);
    end
    svr.get_severity_set(q1);
    foreach(q1[s]) begin
      m_severity_count[q1[s]] = svr.get_severity_count(q1[s]);
    end
    uvm_report_catcher::summarize();
    q.push_back("\n--- UVM Report Summary ---\n\n");
    if(m_max_quit_count != 0) begin
      if ( m_quit_count >= m_max_quit_count )
        q.push_back("Quit count reached!\n");
      q.push_back($sformatf("Quit count : %5d of %5d\n",m_quit_count, m_max_quit_count));
    end
    q.push_back("** Report counts by severity\n");
    foreach(m_severity_count[s]) begin
      q.push_back($sformatf("%s :%5d\n", s.name(), m_severity_count[s]));
    end
    if (enable_report_id_count_summary) begin
      q.push_back("** Report counts by id\n");
      foreach(m_id_count[id])
        q.push_back($sformatf("[%s] %5d\n", id, m_id_count[id]));
    end
    `uvm_info("UVM/REPORT/SERVER",`UVM_STRING_QUEUE_STREAMING_PACK(q),UVM_NONE)
  endfunction
endclass
`endif 
<% }  %>
////////////////////////////////////////////////////////////////////////////////
//
// DMI Test Base
//
////////////////////////////////////////////////////////////////////////////////
class dmi_base_test extends uvm_test;

  `macro_perf_cnt_test_all_declarations

  axi_memory_model m_axi_memory_model;


  dmi_env               m_env;
  dmi_env_config        m_env_cfg;
  smi_agent_config      m_smi_agent_cfg;
  <%=obj.BlockId%>_rtl_agent_config  m_dmi_rtl_agent_cfg;
  <%=obj.BlockId%>_tt_agent_config   m_dmi_tt_agent_cfg;
  <%=obj.BlockId%>_read_probe_agent_config  m_dmi_read_probe_agent_cfg;
  <%=obj.BlockId%>_write_probe_agent_config  m_dmi_write_probe_agent_cfg;
  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event ev = ev_pool.get("ev");
  uvm_event ev_uesr_error = ev_pool.get("ev_uesr_error");
  uvm_event dmi_reset_event = ev_pool.get("dmi_rest_event");
  uvm_event toggle_rstn;

  virtual dmi_csr_probe_if u_csr_probe_vif;

  <% var NSMIIFTX = obj.DmiInfo[0].nSmiTx;
  for (var i = 0; i < NSMIIFTX; i++) { %>
  smi_port_config m_smi<%=i%>_tx_port_config;
  <% } %>
  <% var NSMIIFRX = obj.DmiInfo[0].nSmiRx;
  for (var i = 0; i < NSMIIFRX; i++) { %>
  smi_port_config m_smi<%=i%>_rx_port_config;
  <% } %>

  <% if(obj.INHOUSE_APB_VIP) { %>
  apb_agent_config  m_apb_cfg;
  <% } %>
  <% if(obj.useCmc) { %>
  ccp_agent_config  m_ccp_cfg;
  <% } %>
   axi_agent_config  m_axi_slave_cfg;

  <% if(obj.USE_VIP_SNPS) { %>
   cust_svt_axi_cfg m_snps_axi_cfg;
  <% } %>
  `ifndef PSEUDO_SYS_TB
   //dmi_rtl_agent_config m_dmi_rtl_agent_cfg;
  `endif

  Addr_t  cache_addr_list[$];
  uvm_report_server urs;
  int               error_count;
  int               fatal_count;
  int               bfm_pending_wr_txn;

  uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();

  // control knobs
  int   k_timeout                        = 1000000;
  int   k_prob_ccp_single_bit_tag_error  = 100;
  int   k_prob_ccp_double_bit_tag_error  = 100;
  int   k_prob_ccp_single_bit_data_error = 100;
  int   k_prob_ccp_double_bit_data_error = 100;
  int   k_num_addr                    = 1; 
  int   k_num_cmd                     = 1; 
  int   k_mntop_cmd                   = 4; 
  int   n_pending_txn_mode            = 0;
  int   k_full_cl_only                = 0;
  int   k_force_size                  = 0;
  int   k_force_mw                    = 0;

  //  Atomic cmd wt
  int   k_atomic_opcode               = 0;
  int   k_intfsize                    = 8;

  int   k_back_to_back_types          = 999;
  int   k_back_to_back_chains         = 1;
  bit   k_force_allocate              = 0;
  bit   k_addr_trans_hit              = 0;
  int  use_last_dealloc              = 0;
  int  use_adj_addr                  = 0;
  int  mrd_use_last_mrd_pref         = 0;

  bit k_slow_system                   = 0; 

  bit targ_id_err                     = 0;

  int  tb_delay = 0;
  bit  k_smi_cov_en = 1;
  bit  EN_DMI_VSEQ = 0;
  bit  dmi_scb_en = 1;
  `ifdef CCP_SCB_EN
  bit  ccp_scb_en = 1;
  `else
  bit  ccp_scb_en = 0;
  `endif
  int k_ace_slave_read_addr_chnl_delay_min   = 0;
  int k_ace_slave_read_addr_chnl_delay_max   = 1;
  int k_ace_slave_read_addr_chnl_burst_pct   = 80;
  int k_ace_slave_read_data_chnl_delay_min   = 0;
  int k_ace_slave_read_data_chnl_delay_max   = 1;
  int k_ace_slave_read_data_chnl_burst_pct   = 80;
  int k_ace_slave_read_data_reorder_size     = 4;
  int k_ace_slave_write_addr_chnl_delay_min  = 0;
  int k_ace_slave_write_addr_chnl_delay_max  = 1;
  int k_ace_slave_write_addr_chnl_burst_pct  = 80;
  int k_ace_slave_write_data_chnl_delay_min  = 0;
  int k_ace_slave_write_data_chnl_delay_max  = 1;
  int k_ace_slave_write_data_chnl_burst_pct  = 80;
  int k_ace_slave_write_resp_chnl_delay_min  = 0;
  int k_ace_slave_write_resp_chnl_delay_max  = 1;
  int k_ace_slave_write_resp_chnl_burst_pct  = 80;
  int k_ace_slave_read_data_interleave_dis   = 0;
  int k_min_reuse_q_size = 4;
  int k_max_reuse_q_size = 4;
  int k_reuse_q_pct = 50;

  bit k_slow_agent                           = 0;
  bit k_slow_read_agent                      = 0;
  bit k_slow_write_agent                     = 0;

  bit k_use_all_str_msg_id                   = 0;
  bit k_atomic_directed                      = 0;
  bit k_WrDataClnPropagateEn                 = 0;
  bit k_SysEventDisable                      = 0;
  bit atomic_traffic_enabled                 = 0; 
  bit reuse_q_flag                           = 0;
  int randval;
  bit uncorr_wrbuffer_err                    = 0;
  int timeout_threshold;

  // bit useRttDataEntries                      = <%=obj.useRttDataEntries%>;
  bit useMemRspIntrlv                          = <%=obj.DmiInfo[obj.Id].cmpInfo.useMemRspIntrlv%>;

  int prob_ace_rd_resp_error                = 10;
  int prob_ace_wr_resp_error                = 10;

  bit ScPadEn=0;
  smi_addr_t ScPadBaseAddr;
  int NumScPadWays;
  smi_addr_t k_sp_base_addr                = 0; 
  smi_addr_t k_sp_max_addr                 = 0; 
  bit        k_sp_ns                       = 0;
  bit [5:0]  k_cmc_policy;

  bit [ADDR_WIDTH-1:0] lower_sp_addr;
  bit [ADDR_WIDTH-1:0] upper_sp_addr;
  int sp_ways = 0;
  int sp_size = 0;
  bit sp_en = 0;

  <% if(obj.INHOUSE_APB_VIP) { %>
  int k_apb_mcmd_delay_min                      = 0;
  int k_apb_mcmd_delay_max                      = 1;
  int k_apb_mcmd_burst_pct                      = 90;
  bit k_apb_mcmd_wait_for_scmdaccept            = 0;

  int k_apb_maccept_delay_min                   = 0;
  int k_apb_maccept_delay_max                   = 1;
  int k_apb_maccept_burst_pct                   = 90;
  bit k_apb_maccept_wait_for_sresp              = 0;

  bit k_slow_apb_agent                          = 0;
  bit k_slow_apb_mcmd_agent                     = 0;
  bit k_slow_apb_mrespaccept_agent              = 0;
  <% } %>
  bit k_inj_smi_delay                           = 0;

  string k_csr_seq = "";
  string k_csr_SMC_mntop_seq = "";
  string k_csr_SMC_mntop_seq_for_error = "";
  bit inject_random_csr_seq                     = 0;
  bit inject_ccp_online_csr_seq                 = 0;
  bit inject_ccp_offline_csr_seq                = 0;
  int inject_ccp_random_flush_csr_seq           = 0;
  int inject_ccp_random_flush_csr_seq_last      = 0;
  int inject_ccp_random_online_offline_csr_seq  = 0;
  bit inject_ccp_terminating_flush_csr_seq      = 0;
  bit inject_ttdebug                            = 0;

  bit [31:0] cctrlr_value   = 0; 

  `uvm_component_utils_begin(dmi_base_test)
    `uvm_field_int(k_timeout,                   UVM_DEC); // control test timeout
    `uvm_field_int(k_prob_ccp_single_bit_tag_error,       UVM_DEC); // control test timeout
    `uvm_field_int(k_prob_ccp_double_bit_tag_error,       UVM_DEC); // control test timeout
    `uvm_field_int(k_prob_ccp_single_bit_data_error,      UVM_DEC); // control test timeout
    `uvm_field_int(k_prob_ccp_double_bit_data_error,      UVM_DEC); // control test timeout
    `uvm_field_int(k_num_addr,                  UVM_DEC); // controls number of addresses generated
    `uvm_field_int(k_num_cmd,                   UVM_DEC); // controls number of transactions test initiates
    `uvm_field_int(k_mntop_cmd,                 UVM_DEC); // controls number of transactions test initiates
    `uvm_field_int(n_pending_txn_mode,          UVM_DEC);
    `uvm_field_int(k_full_cl_only,              UVM_DEC);
    `uvm_field_int(k_force_size  ,              UVM_DEC);
    `uvm_field_int(k_force_mw    ,              UVM_DEC);
    `uvm_field_int(k_atomic_opcode,             UVM_DEC);  // set atomic opcode
    `uvm_field_int(k_intfsize,                  UVM_DEC);  // set interface size of initiator
    `uvm_field_int(k_back_to_back_types,        UVM_DEC);  // directs ordering of transactions
    `uvm_field_int(k_back_to_back_chains,       UVM_DEC);  // controls number of back to back transactions of same type
    `uvm_field_int(k_force_allocate,            UVM_BIN);  // force alloacte bit
    `uvm_field_int(k_addr_trans_hit,            UVM_DEC);
    `uvm_field_int(use_last_dealloc,            UVM_DEC);
    `uvm_field_int(use_adj_addr,                UVM_DEC);
    `uvm_field_int(mrd_use_last_mrd_pref,            UVM_DEC);
    `uvm_field_int(tb_delay,    UVM_DEC);
    `uvm_field_int(dmi_scb_en,  UVM_BIN);
    `uvm_field_int(ccp_scb_en,  UVM_BIN);
    `uvm_field_int(k_smi_cov_en,UVM_BIN);
    `uvm_field_int(EN_DMI_VSEQ,  UVM_BIN);
    `uvm_field_int(k_min_reuse_q_size,  UVM_DEC);
    `uvm_field_int(k_max_reuse_q_size,  UVM_DEC);
    `uvm_field_int(k_reuse_q_pct,       UVM_DEC);
    `uvm_field_int(k_ace_slave_read_addr_chnl_delay_min  ,UVM_DEC);
    `uvm_field_int(k_ace_slave_read_addr_chnl_delay_max  ,UVM_DEC);
    `uvm_field_int(k_ace_slave_read_addr_chnl_burst_pct  ,UVM_DEC);
    `uvm_field_int(k_ace_slave_read_data_chnl_delay_min  ,UVM_DEC);
    `uvm_field_int(k_ace_slave_read_data_chnl_delay_max  ,UVM_DEC);
    `uvm_field_int(k_ace_slave_read_data_chnl_burst_pct  ,UVM_DEC);
    `uvm_field_int(k_ace_slave_read_data_reorder_size    ,UVM_DEC);
    `uvm_field_int(k_ace_slave_write_addr_chnl_delay_min ,UVM_DEC);
    `uvm_field_int(k_ace_slave_write_addr_chnl_delay_max ,UVM_DEC);
    `uvm_field_int(k_ace_slave_write_addr_chnl_burst_pct ,UVM_DEC);
    `uvm_field_int(k_ace_slave_write_data_chnl_delay_min ,UVM_DEC);
    `uvm_field_int(k_ace_slave_write_data_chnl_delay_max ,UVM_DEC);
    `uvm_field_int(k_ace_slave_write_data_chnl_burst_pct ,UVM_DEC);
    `uvm_field_int(k_ace_slave_write_resp_chnl_delay_min ,UVM_DEC);
    `uvm_field_int(k_ace_slave_write_resp_chnl_delay_max ,UVM_DEC);
    `uvm_field_int(k_ace_slave_write_resp_chnl_burst_pct ,UVM_DEC);
    `uvm_field_int(k_ace_slave_read_data_interleave_dis  ,UVM_DEC);
    `uvm_field_int(k_slow_agent                          ,UVM_DEC);
    `uvm_field_int(k_slow_read_agent                     ,UVM_DEC);
    `uvm_field_int(k_slow_write_agent                    ,UVM_DEC);
    `uvm_field_int(k_use_all_str_msg_id                  ,UVM_DEC);
    `uvm_field_int(k_atomic_directed                     ,UVM_DEC);
    `uvm_field_int(prob_ace_rd_resp_error               ,UVM_DEC);
    `uvm_field_int(prob_ace_wr_resp_error               ,UVM_DEC);
    `uvm_field_int(k_sp_base_addr                       ,UVM_DEC);
    `uvm_field_int(k_sp_max_addr                        ,UVM_DEC);
    `uvm_field_int(k_sp_ns                              ,UVM_DEC); 
    <% if(obj.INHOUSE_APB_VIP) { %>
    `uvm_field_int(k_apb_mcmd_delay_min                  ,UVM_DEC);
    `uvm_field_int(k_apb_mcmd_delay_max                  ,UVM_DEC);
    `uvm_field_int(k_apb_mcmd_burst_pct                  ,UVM_DEC);
    `uvm_field_int(k_apb_mcmd_wait_for_scmdaccept        ,UVM_DEC);
    `uvm_field_int(k_apb_maccept_delay_min               ,UVM_DEC);
    `uvm_field_int(k_apb_maccept_delay_max               ,UVM_DEC);
    `uvm_field_int(k_apb_maccept_burst_pct               ,UVM_DEC);
    `uvm_field_int(k_apb_maccept_wait_for_sresp          ,UVM_DEC);
    `uvm_field_int(k_slow_apb_agent                      ,UVM_DEC);
    `uvm_field_int(k_slow_apb_mcmd_agent                 ,UVM_DEC);
    `uvm_field_int(k_slow_apb_mrespaccept_agent          ,UVM_DEC);
    `uvm_field_int(k_inj_smi_delay                       ,UVM_DEC);
    <% } %>
    `uvm_field_string(k_csr_seq                          ,UVM_STRING);
    `uvm_field_string(k_csr_SMC_mntop_seq                ,UVM_STRING);
    `uvm_field_string(k_csr_SMC_mntop_seq_for_error      ,UVM_STRING);
    `uvm_field_int(inject_random_csr_seq                 ,UVM_DEC);
    `uvm_field_int(inject_ttdebug                        ,UVM_DEC);
    `uvm_field_int(inject_ccp_online_csr_seq             ,UVM_DEC);
    `uvm_field_int(inject_ccp_offline_csr_seq            ,UVM_DEC);
    `uvm_field_int(inject_ccp_random_flush_csr_seq       ,UVM_DEC);
    `uvm_field_int(inject_ccp_random_flush_csr_seq_last  ,UVM_DEC);
    `uvm_field_int(cctrlr_value                          ,UVM_DEC);
  `uvm_component_utils_end
  extern function new(string name = "dmi_base_test", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual function void connect_phase(uvm_phase phase);
  extern virtual function void start_of_simulation_phase(uvm_phase phase);
  extern virtual function void check_phase(uvm_phase phase);
  extern virtual function void report_phase(uvm_phase phase);
  extern virtual function void run_report(uvm_phase phase);
  extern function void set_smi_if_delay_control();
  extern function void set_axi_delays();
  extern function void get_cmdline_args();
  extern function void override_cmdline_args();
  extern function void initialize_scratchpad();
  extern function void randomize_config(bit EN);

  task reset_system();
    toggle_rstn = new("toggle_rstn");
    uvm_config_db#(uvm_event)::get(.cntxt(this),
                                   .inst_name( "" ),
                                   .field_name( "toggle_rstn" ),
                                   .value(toggle_rstn));
    toggle_rstn.trigger();
    repeat(32) @(posedge u_csr_probe_vif.clk);
    toggle_rstn.trigger();
  endtask

  function void heartbeat(uvm_phase phase);
    uvm_callbacks_objection cb;
    uvm_heartbeat hb;
    uvm_event e;
    uvm_component comp_q[$];
    timeout_catcher catcher;
    uvm_phase run_phase;

    e = new("e");
    run_phase = phase.find_by_name("run", 0);

    catcher            = timeout_catcher::type_id::create("catcher", this);
    catcher.phase      = run_phase;
    catcher.env        = m_env;
    catcher.dmi_scb_en = dmi_scb_en;
    uvm_report_cb::add(null, catcher);
    
    if(!$cast(cb, run_phase.get_objection()))
        `uvm_fatal("Run", "run phase objection type isn't of type uvm_callbacks_objection. you need to define UVM_USE_CALLBACKS_OBJECTION_FOR_TEST_DONE!");

    hb = new("activity_heartbeat", this, cb);
    uvm_top.find_all("*", comp_q, this);
    hb.set_mode(UVM_ANY_ACTIVE);
    hb.set_heartbeat(e, comp_q);

    fork
      forever begin
        #(k_timeout*1ns) e.trigger();
      end
    join_none
  endfunction: heartbeat

endclass: dmi_base_test

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dmi_base_test::new(string name = "dmi_base_test", uvm_component parent = null);
  super.new(name, parent);
  if ($test$plusargs("wrong_targ_id_mrd") || $test$plusargs("wrong_targ_id_cmd") || $test$plusargs("wrong_targ_id_dtw") || $test$plusargs("wrong_targ_id_dtr_rsp") || $test$plusargs("wrong_targ_id_str_rsp") || $test$plusargs("wrong_targ_id_rb_req") || $test$plusargs("wrong_targ_id_rb_use_rsp") || $test$plusargs("wrong_targ_id_on_dtwdbg_rsp")) begin
    this.targ_id_err = 1;
  end
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void dmi_base_test::build_phase(uvm_phase phase);

  super.build_phase(phase);

  m_axi_memory_model = new();
  get_cmdline_args();
  m_env_cfg = dmi_env_config::type_id::create("m_env_cfg", this);

  uvm_config_db#(int)::get(this,"","tb_delay", tb_delay);

  <% if(obj.useCmc) { %>
  m_ccp_cfg = ccp_agent_config::type_id::create("m_ccp_cfg", this);
  m_ccp_cfg.active = UVM_PASSIVE;

  if (!uvm_config_db#(virtual <%=obj.BlockId%>_ccp_if)::get(.cntxt( this ),
                                                            .inst_name( "*" ),
                                                            .field_name("ccp<%=obj.Id + '_vif'%>"),
                                                            .value(m_ccp_cfg.m_vif ))) begin
    `uvm_error("dmi_base_test", "ccp_vif not found")
  end

  m_env_cfg.ccp_agent_cfg = m_ccp_cfg;
  <% } %>

  <% if(obj.INHOUSE_APB_VIP) { %>
  m_apb_cfg = apb_agent_config::type_id::create("m_apb_cfg", this);

  if (!uvm_config_db#(virtual <%=obj.BlockId%>_apb_if)::get(.cntxt( this ),
                                                            .inst_name( "*" ),
                                                            .field_name( "apb_if" ),
                                                            .value( m_apb_cfg.m_vif ))) begin
    `uvm_error("dmi_base_test", "APB if not found")
  end

  m_env_cfg.m_apb_cfg = m_apb_cfg;
  <% } %>

  m_env_cfg.m_q_chnl_agent_cfg = q_chnl_agent_config::type_id::create("m_q_chnl_agent_config",  this);

  if (!uvm_config_db#(virtual <%=obj.BlockId%>_q_chnl_if)::get(.cntxt( this ),
                                                               .inst_name( "" ),
                                                               .field_name( "m_q_chnl_if" ),
                                                               .value(m_env_cfg.m_q_chnl_agent_cfg.m_vif ))) begin
    `uvm_error("dmi_base_test", "m_q_chnl_if not found")
  end

  m_smi_agent_cfg = smi_agent_config::type_id::create("m_smi_agent_cfg",this); 
  m_smi_agent_cfg.cov_en = k_smi_cov_en;
  <% var NSMIIFTX = obj.DmiInfo[0].nSmiRx;
  for (var i = 0; i < NSMIIFTX; i++) { %>
  m_smi<%=i%>_tx_port_config = smi_port_config::type_id::create("m_smi<%=i%>_tx_port_config",this); 
  <% } %>
  <% var NSMIIFRX = obj.DmiInfo[0].nSmiTx;
  for (var i = 0; i < NSMIIFRX; i++) { %>
  m_smi<%=i%>_rx_port_config = smi_port_config::type_id::create("m_smi<%=i%>_rx_port_config",this);
  <% } %>
  m_axi_slave_cfg      = axi_agent_config::type_id::create("m_axi_slave_cfg",  this);

  set_axi_delays();
  
  if(k_slow_agent || k_slow_read_agent || k_slow_write_agent ) begin
     k_slow_system = 1; 
  end

  <% var NSMIIFTX = obj.DmiInfo[0].nSmiRx;
  for (var i = 0; i < NSMIIFTX; i++) { %>
  if (!uvm_config_db#(virtual <%=obj.BlockId + '_smi_if'%>)::get(.cntxt( this ),
                                           .inst_name( "" ),
                                           .field_name( "m_smi<%=i%>_tx_smi_if" ),
                                           .value( m_smi<%=i%>_tx_port_config.m_vif ))) begin
    `uvm_error("dmi_base_test", "m_smi<%=i%>_tx_smi_if not found")
  end
  <% } %>
  <% var NSMIIFRX = obj.DmiInfo[0].nSmiTx;
  for (var i = 0; i < NSMIIFRX; i++) { %>
  if (!uvm_config_db#(virtual <%=obj.BlockId + '_smi_if'%>)::get(.cntxt( this ),
                                           .inst_name( "" ),
                                           .field_name( "m_smi<%=i%>_rx_smi_if" ),
                                           .value( m_smi<%=i%>_rx_port_config.m_vif ))) begin
    `uvm_error("dmi_base_test", "m_smi<%=i%>_rx_smi_if not found")
  end
  <% } %>
  if (!uvm_config_db#(virtual <%=obj.BlockId + '_axi_if'%>)::get(.cntxt( this ),
                                       .inst_name( "" ),
                                       .field_name( "m_<%=obj.BlockId%>_axi_slv_if" ),
                                       .value(m_axi_slave_cfg.m_vif ))) begin
     `uvm_error("dmi_env", "m_<%=obj.BlockId%>_axi_slv_if not found")
  end
  m_axi_slave_cfg.active  = UVM_ACTIVE;
  m_env_cfg.m_axi_slave_agent_cfg  = m_axi_slave_cfg;
  m_dmi_rtl_agent_cfg = <%=obj.BlockId%>_rtl_agent_config::type_id::create("m_dmi_rtl_agent_cfg",this); 
  if (!uvm_config_db#(virtual <%=obj.BlockId%>_rtl_if)::get(.cntxt( this ),
                                       .inst_name( "" ),
                                       .field_name( "u_<%=obj.BlockId%>_rtl_if" ),
                                       .value(m_dmi_rtl_agent_cfg.m_vif ))) begin
     `uvm_error("dmi_env", "u_<%=obj.BlockId%>_rtl_if not found")
  end
  m_env_cfg.m_dmi_rtl_agent_cfg = m_dmi_rtl_agent_cfg;

  m_dmi_tt_agent_cfg = <%=obj.BlockId%>_tt_agent_config::type_id::create("m_dmi_tt_agent_cfg",this); 
  if (!uvm_config_db#(virtual <%=obj.BlockId%>_tt_if)::get(.cntxt( this ),
                                       .inst_name( "" ),
                                       .field_name( "u_<%=obj.BlockId%>_tt_if" ),
                                       .value(m_dmi_tt_agent_cfg.m_vif ))) begin
     `uvm_error("dmi_env", "u_<%=obj.BlockId%>_tt_if not found")
  end
  m_env_cfg.m_dmi_tt_agent_cfg = m_dmi_tt_agent_cfg;

  m_dmi_read_probe_agent_cfg = <%=obj.BlockId%>_read_probe_agent_config::type_id::create("m_dmi_read_probe_agent_cfg",this); 
  if (!uvm_config_db#(virtual <%=obj.BlockId%>_read_probe_if)::get(.cntxt( this ),
                                       .inst_name( "" ),
                                       .field_name( "u_<%=obj.BlockId%>_read_probe_if" ),
                                       .value(m_dmi_read_probe_agent_cfg.m_vif ))) begin
     `uvm_error("dmi_env", "u_<%=obj.BlockId%>_read_probe_if not found")
  end
  m_env_cfg.m_dmi_read_probe_agent_cfg = m_dmi_read_probe_agent_cfg;

  m_dmi_write_probe_agent_cfg = <%=obj.BlockId%>_write_probe_agent_config::type_id::create("m_dmi_write_probe_agent_cfg",this); 
  if (!uvm_config_db#(virtual <%=obj.BlockId%>_write_probe_if)::get(.cntxt( this ),
                                       .inst_name( "" ),
                                       .field_name( "u_<%=obj.BlockId%>_write_probe_if" ),
                                       .value(m_dmi_write_probe_agent_cfg.m_vif ))) begin
     `uvm_error("dmi_env", "u_<%=obj.BlockId%>_write_probe_if not found")
  end
  m_env_cfg.m_dmi_write_probe_agent_cfg = m_dmi_write_probe_agent_cfg;

  m_env_cfg.m_smi_agent_cfg = m_smi_agent_cfg;

  `ifndef PSEUDO_SYS_TB
  // m_env_cfg.m_dmi_rtl_agent_cfg    = m_dmi_rtl_agent_cfg;
  `endif
  if((("<%=obj.DmiInfo[obj.Id].fnErrDetectCorrect%>" == "PARITYENTRY") && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test"))) || $test$plusargs("wbuffer_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_double_bit_error_test") || $test$plusargs("address_error_test_wbuff") ) begin
    uncorr_wrbuffer_err = 1;
    `uvm_info("dmi_base_test",$sformatf("****************************uncorr_wrbuffer_err = 1"),UVM_NONE);
  end
  else begin
    uncorr_wrbuffer_err = 0;
  end

  if($test$plusargs("uncorr_error_test") || $test$plusargs("uncorr_error_inj_test") || $test$plusargs("double_bit_tag_error_test") || $test$plusargs("double_bit_data_error_test")) begin
    ccp_scb_en = 0;
  end
  m_env_cfg.has_scoreboard = dmi_scb_en; // FIXME
  <% if(obj.useCmc) {%>
  m_env_cfg.ccp_agent_cfg.has_scoreboard = ccp_scb_en; // FIXME
  <% } %>
  set_smi_if_delay_control(); 
  <% if(obj.INHOUSE_AXI) { %>
  m_env_cfg.m_axi_slave_agent_cfg.delay_export = 1;
  <% } %>
  <% if(obj.useCmc){ %>
  m_env_cfg.ccp_agent_cfg.delay_export = 1;
  <% } %>
  <% var NSMIIFTX = obj.DmiInfo[0].nSmiRx;
  for (var i = 0; i < NSMIIFTX; i++) { %>
  m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config  = m_smi<%=i%>_tx_port_config;
  <% } %>
  <% var NSMIIFRX = obj.DmiInfo[0].nSmiTx;
  for (var i = 0; i < NSMIIFRX; i++) { %>
  m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config  = m_smi<%=i%>_rx_port_config;
  <% } %>
  m_env_cfg.m_smi_agent_cfg.active = UVM_ACTIVE;

  uvm_config_db#(dmi_env_config)::set(.cntxt( this ),
                                      .inst_name( "*" ),
                                      .field_name( "dmi_env_config" ),
                                      .value( m_env_cfg ));
  m_env = dmi_env::type_id::create("m_env", this);
  <% if(obj.USE_VIP_SNPS) { %>
    //Set type override of base classes extended for dmi use
    m_snps_axi_cfg = cust_svt_axi_cfg::type_id::create("m_snps_axi_cfg", this);
    uvm_config_db#(svt_axi_system_configuration)::set(this, "m_env.m_axi_system_env", "cfg", m_snps_axi_cfg);
    //uvm_config_db#(uvm_object_wrapper)::set(this, "m_env.m_axi_system_env.slave*.sequencer.run_phase", "default_sequence", axi_slave_mem_response_sequence::type_id::get());
    set_type_override_by_type(svt_axi_slave_transaction::get_type(),cust_svt_axi_slave_transaction::get_type());
  <% } %>

  if(!uvm_config_db#(virtual dmi_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_vif))
        `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
  
  <% if(obj.useCmc && obj.DmiInfo[0].useAtomic) { %>
  if($test$plusargs("dmi_atomic_test_only") ||  $test$plusargs("add_atomic")) begin
    atomic_traffic_enabled = 1;
    `uvm_info("dmi_base_test","Atomic Traffic Enabled",UVM_DEBUG)
  end
  <% } %>
endfunction : build_phase

function void dmi_base_test::override_cmdline_args();
  k_num_cmd = m_env_cfg.m_args.k_num_cmd;
endfunction

function void dmi_base_test::initialize_scratchpad();
  <% if(obj.useCmc) { %>
  // Enabling and configuring Scratchpad using force
  if($test$plusargs("k_sp_en")) begin
    sp_en = 1;
  end
  <%if(obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
  else if(EN_DMI_VSEQ) begin
    sp_en = ($urandom_range(0,100) > 90) ? 0 : 1;
  end
  <% } %>
  if($test$plusargs("all_ways_for_sp")) begin
    sp_ways = atomic_traffic_enabled ? CCP_WAYS-1 : CCP_WAYS;
  end 
  else if ($test$plusargs("half_ways_for_sp")) begin
    sp_ways = CCP_WAYS/2;
  end 
  else if ($test$plusargs("all_ways_for_cache")) begin
    sp_ways = 0;
  end
  else if ($test$plusargs("one_way_for_sp")) begin
    sp_ways = 1;
  end
  else begin
    randcase
      15 : sp_ways = sp_en ? $urandom_range(1,(CCP_WAYS-1)) : 0;
      15 : sp_ways = atomic_traffic_enabled ? CCP_WAYS-1 : CCP_WAYS;
      30 : sp_ways = (CCP_WAYS/2);
      40 : sp_ways = $urandom_range(1,(CCP_WAYS-1));
    endcase
  end
  sp_size = CCP_SETS * sp_ways;
  m_env_cfg.k_sp_size = sp_size;
  m_env_cfg.k_sp_enabled = sp_en;
  m_env_cfg.sp_ways_rsvd = sp_ways;
  
  randomize_config(1);

  if(k_sp_base_addr == 0) begin
    k_sp_base_addr = m_env_cfg.sp_base_addr;
    k_sp_ns        = m_env_cfg.sp_ns;
  end
  else begin
    `uvm_warning("dmi_base_test",$sformatf("::init_SP:: You've specified a +k_sp_base_addr=%0h value, hope you know what you're doing",k_sp_base_addr))
  end
  k_sp_base_addr[CCP_CL_OFFSET-1:0] = 'b0;
  k_sp_max_addr = m_env_cfg.sp_roof_addr;

  ScPadBaseAddr = k_sp_base_addr >> CCP_CL_OFFSET;
  NumScPadWays  = (sp_ways > 0) ? sp_ways-1 : 0;

  `uvm_info("dmi_base_test",$sformatf("::init_SP:: csr_programmed_base_addr:0x%0h k_sp_base_addr:'h%0h sp_base_addr 'h%0h, sp_roof_addr: 'h%0h, addr_diff: 'h%0h sp_size:%0d sp_ways: %0d sp_ns: %0b",
                                       ScPadBaseAddr, k_sp_base_addr, m_env_cfg.sp_base_addr, m_env_cfg.sp_roof_addr, (m_env_cfg.sp_roof_addr-m_env_cfg.sp_base_addr), sp_size, sp_ways, k_sp_ns), UVM_NONE)
  `uvm_info("dmi_base_test",$sformatf("::init_SP:: Interleave Removed | sp_base_addr_i: 'h%0h, sp_roof_addr_i: 'h%0h",
                                      m_env_cfg.sp_base_addr_i, m_env_cfg.sp_roof_addr_i), UVM_NONE)
  `uvm_info("dmi_base_test",$sformatf("::init_SP:: Interleave Removed and CL Shifted | sp_base_addr_i: 'h%0h, sp_roof_addr_i: 'h%0h diff:%0h",
                                      m_env_cfg.sp_base_addr_i >> CCP_CL_OFFSET, m_env_cfg.sp_roof_addr_i >> CCP_CL_OFFSET, (m_env_cfg.sp_roof_addr_i - m_env_cfg.sp_base_addr_i)), UVM_NONE)
  <%}%>
endfunction

function void dmi_base_test::randomize_config(bit EN);
  if(EN) begin
    if(!m_env_cfg.randomize())begin
      `uvm_error("dmi_base_test","::randomize_config:: Randomization failure for dmi_env_config")
    end
    override_cmdline_args();
  end
endfunction

function void dmi_base_test::connect_phase(uvm_phase phase);
   super.connect_phase(phase);
endfunction : connect_phase

//------------------------------------------------------------------------------
// Start Of Simulation Phase
//------------------------------------------------------------------------------
function void dmi_base_test::start_of_simulation_phase(uvm_phase phase);
<% if(obj.testBench == 'dmi') { %>
 `ifdef VCS 
    local_report_server m_server = new();
  `endif
<% } %>
  super.start_of_simulation_phase(phase);
  heartbeat(phase);
  if (this.get_report_verbosity_level() > UVM_LOW) begin
    uvm_top.print_topology();
  end
  `uvm_info("dmi_base_test",$sformatf("$get_initial_random_seed()=%0d", $get_initial_random_seed()),UVM_LOW)
<% if(obj.testBench == 'dmi') { %>
 `ifdef VCS 
    uvm_report_server::set_server(m_server);
  `endif
<% } %>
endfunction : start_of_simulation_phase


//------------------------------------------------------------------------------
// check Phase
//------------------------------------------------------------------------------
function void dmi_base_test::check_phase(uvm_phase phase);
     int tmp_rtt_q[$];
     int ace_rd_resp_err;
     int ace_wr_resp_err;
     int inj_cntl;
     int pending_rb_released_count;
  if ((!smi_rx_stall_en) && (!force_axi_stall_en)) begin:perfmon_disable_check_phase// disable main seq in a specific perf mon test case
  super.check_phase(phase);
  if (m_env.m_cfg.has_scoreboard == 1 && !this.targ_id_err) begin
     tmp_rtt_q = {};
     tmp_rtt_q = m_env.m_sb.rtt_q.find_index with (!((item.isCmdPref && item.CMD_rsp_recd && item.STR_req_recd && item.STR_rsp_recd)));
     
     //Only check if uncorr ecc or parity error not injected
     if(!(((m_env.m_sb.num_smi_uncorr_err != 0) || (m_env.m_sb.num_smi_parity_err != 0)) 
          && 
          ($test$plusargs("uncorr_error_inj_pcnt") || $test$plusargs("parity_error_inj_pcnt") || $test$plusargs("test_unit_duplication")) )
         && !m_env_cfg.m_args.sram_uc_error_test
         && m_env.m_sb.uncorr_wrbuffer_err == 0) begin
       if($test$plusargs("dmi_qchannel_reset_test"))begin
        <% if(obj.DmiInfo[obj.Id].usePma) { %>
           k_num_cmd = k_num_cmd + k_num_cmd;
        <% } %>
       end
       uvm_config_db#(int)::get(null,"uvm_test_top","pending_release_count",pending_rb_released_count);
       if(m_env.m_sb.numCmd != k_num_cmd+pending_rb_released_count)begin
          `uvm_error("DMI BASE_TEST", $sformatf("Number of Cmd Received by Dut :%0d, Configured :%0d Pending RBs Released:%0d",m_env.m_sb.numCmd,k_num_cmd,pending_rb_released_count))
       end
       if(tmp_rtt_q.size() > 0) begin
          `uvm_error("DMI BASE_TEST", "rtt_q  not empty")
       end
       if(m_env.m_sb.wtt_q.size() > 0 ) begin
          `uvm_error("DMI BASE_TEST", "wtt_q not  empty")
       end
     end
     else if(m_env_cfg.m_args.sram_uc_error_test) begin
      if(m_env.m_sb.rtt_q.size + m_env.m_sb.wtt_q.size != u_csr_probe_vif.irq_uc_count) begin
        `uvm_info("DMI_BASE_TEST",$sformatf("IRQ detection was suppressed. Interrupts weren't logged,RTT=%0d + WTT=%0d != IRQ_UC=%0d",m_env.m_sb.rtt_q.size,m_env.m_sb.wtt_q.size,u_csr_probe_vif.irq_uc_count),UVM_LOW)
      end
     end
   end

  $value$plusargs("prob_ace_rd_resp_error=%d",ace_rd_resp_err);
  $value$plusargs("prob_ace_wr_resp_error=%d",ace_wr_resp_err);
  $value$plusargs("inj_cntl=%d",inj_cntl);

<%  if (obj.useResiliency) { %>
 // disable in case perf mon test case dropped smi when  uncorrect error is generated
if( m_env.m_cfg.has_scoreboard == 1) begin
  if (   !(inj_cntl > 1) && this.targ_id_err == 0 && m_env.m_sb.uncorr_wrbuffer_err == 0 && m_env.m_sb.num_smi_uncorr_err == 0 && m_env.m_sb.num_smi_parity_err == 0 
      && !($test$plusargs("uncorr_error_inj_pcnt") || $test$plusargs("parity_error_inj_pcnt") || $test$plusargs("test_unit_duplication")) 
      && m_env.m_sb.uncorr_tag_err == 0 && m_env.m_sb.uncorr_data_err == 0) begin
    if (u_csr_probe_vif.fault_mission_fault !== 0) begin
      if(m_env_cfg.m_args.sram_uc_error_test && !m_env_cfg.m_args.k_expect_mission_fault) begin
        `uvm_info(get_full_name(),"mission fault trigerred for UC error injection on SRAM",UVM_LOW)
      end
      else if(m_env_cfg.m_args.k_waive_mission_fault_eos_check) begin
        `uvm_warning(get_full_name(),"Mission fault asserted but waived, used for tests to cover logic areas that inherently inject errors and will cause mission fault.")
      end
      else begin
        `uvm_error(get_full_name(),"mission fault should be zero for no error injection")
      end
    end
    if (u_csr_probe_vif.fault_latent_fault !== 0) begin
      `uvm_error(get_full_name(),"latent fault should be zero for no error injection")
    end
  end 
end
  //To check mission fault for memory uncorrectable error injection
   // disable in case perf mon test case dropped smi when  uncorrect error is generated
  if (inj_cntl > 1 || (u_csr_probe_vif.uncorr_err_injected === 1) || this.targ_id_err || ($test$plusargs("dis_uedr_med_4resiliency") && u_csr_probe_vif.dmi_corr_uncorr_flag === 1)) begin
    string log_s = "";
    if(u_csr_probe_vif.uncorr_err_injected == 1 || ($test$plusargs("dis_uedr_med_4resiliency") && u_csr_probe_vif.dmi_corr_uncorr_flag === 1))
      log_s = "write buffer/CCP tag/CCP data memory uncrroctable error injection";
    else if(this.targ_id_err)
      log_s = "wrong traget ID error injection";
    else if(inj_cntl>1)
      log_s = "uncorrectable error injection";

    if (u_csr_probe_vif.fault_mission_fault === 0) begin
      `uvm_error(get_full_name(),$sformatf("mission fault should be asserted for %0s", log_s))
    end else if (u_csr_probe_vif.fault_mission_fault === 1) begin
      `uvm_info(get_full_name(),$sformatf("mission fault asserted due to %0s", log_s), UVM_NONE)
    end else if (u_csr_probe_vif.fault_mission_fault === 'hx) begin
      `uvm_error(get_full_name(),$sformatf("mission fault goes unknown for %0s", log_s))
    end
  end
<% } %>
     
  if(m_env.m_cfg.has_scoreboard == 1) begin
     if($test$plusargs("wrong_targ_id_rb_req"))begin
       if(m_env.m_sb.wtt_q.size() !== bfm_pending_wr_txn) begin
          `uvm_error("DMI BASE_TEST",$sformatf("wtt_q not  empty wtt_q.size() :%0d bfm_pending_wr_txn :%0d",m_env.m_sb.wtt_q.size(),bfm_pending_wr_txn))
       end
       else begin
          `uvm_info("DMI BASE_TEST",$sformatf("wtt_q not  empty wtt_q.size() :%0d bfm_pending_wr_txn :%0d",m_env.m_sb.wtt_q.size(),bfm_pending_wr_txn),UVM_DEBUG)
       end
     end
  end

  if(!uncorr_wrbuffer_err && m_env.m_cfg.has_scoreboard)begin
    if(
       !($test$plusargs("inj_cntl")) && this.targ_id_err == 0 && m_env.m_sb.num_smi_corr_err == 0  && m_env.m_sb.uncorr_wrbuffer_err == 0 && m_env.m_sb.num_smi_uncorr_err == 0 && m_env.m_sb.num_smi_parity_err == 0 && 
       !($test$plusargs("uncorr_error_inj_pcnt") || $test$plusargs("parity_error_inj_pcnt") || $test$plusargs("test_unit_duplication"))
       && m_env.m_sb.uncorr_tag_err == 0 && m_env.m_sb.uncorr_data_err == 0 && ace_rd_resp_err == 0 && ace_wr_resp_err == 0 &&
       !(m_env_cfg.m_args.k_smc_timeout_error_test)
       && !(m_env_cfg.m_args.k_wtt_timeout_error_test) 
       && !(m_env_cfg.m_args.k_rtt_timeout_error_test) 
       && !($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("ccp_single_bit_tag_direct_error_test") || $test$plusargs("ccp_single_bit_data_direct_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test") || $test$plusargs("ccp_multi_blk_single_tag_direct_error_test") || $test$plusargs("ccp_multi_blk_single_data_direct_error_test"))
       && !$test$plusargs("always_inject_error") 
       && !($test$plusargs("ignore_eos_checks"))
       && !($test$plusargs("ccp_single_bit_tag_error_test") 
            || $test$plusargs("ccp_double_bit_tag_error_test") 
            || $test$plusargs("ccp_single_bit_data_error_test") 
            || $test$plusargs("ccp_double_bit_data_error_test") 
            || $test$plusargs("Data_rand_single_bit_error_test") 
            || $test$plusargs("tag_rand_single_bit_error_test")
            || $test$plusargs("address_error_test_tag")
            || $test$plusargs("address_error_test_data") 
            || m_env_cfg.m_args.sram_error_test
            || m_env_cfg.m_args.sram_uc_error_test
            )) begin
      u_csr_probe_vif.eos_check();
    end
    if (k_csr_seq == "dmi_csr_time_out_error_seq_no_checks") begin
      u_csr_probe_vif.eos_timeout_non_zero_check();
    end
    <%if(obj.DmiInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
    if($test$plusargs("check_eos_plru_err_count")) begin
      `uvm_info("dmi_base_test",$sformatf("Executing PLRU end of test check on error counters plru_error_mode:%0d",m_env_cfg.m_args.k_plru_error_mode),UVM_LOW)
      u_csr_probe_vif.eos_plru_error_check((m_env_cfg.m_args.k_plru_error_mode));
    end
    <% } %>
  end
end:perfmon_disable_check_phase
endfunction:check_phase
//------------------------------------------------------------------------------
// Report Phase
//------------------------------------------------------------------------------
function void dmi_base_test::report_phase(uvm_phase phase);
  super.report_phase(phase);
  run_report(phase);
  urs = uvm_report_server::get_server();
  error_count = urs.get_severity_count(UVM_ERROR);
  fatal_count = urs.get_severity_count(UVM_FATAL);
  if ((error_count != 0) | (fatal_count != 0)) begin
    `uvm_info("DMI BASE_TEST", "\n===========\nUVM FAILED!\n===========", UVM_NONE);
  end else begin
    if(m_env.m_cfg.has_scoreboard)begin
     
     `uvm_info("DMI BASE_TEST", $sformatf("Number of Cmd Received by Dut :%0d, configured :%0d",m_env.m_sb.numCmd,k_num_cmd),UVM_NONE);
     m_env.m_sb.print_rtt_q_eos();
     m_env.m_sb.print_wtt_q_eos();
    end
    `uvm_info("DMI BASE_TEST", "\n===========\nUVM PASSED!\n===========", UVM_NONE);
  end
endfunction : report_phase

//------------------------------------------------------------------------------
// Run Report
//------------------------------------------------------------------------------
function void dmi_base_test::run_report(uvm_phase phase);
endfunction : run_report

function void dmi_base_test::set_smi_if_delay_control();
  <% var NSMIIFTX = obj.DmiInfo[0].nSmiRx;
  for (var i = 0; i < NSMIIFTX; i++) { %>
  if($test$plusargs("zero_delay") || $test$plusargs("smi<%=i%>_tx_zero_delay"))begin
    m_smi<%=i%>_tx_port_config.k_delay_min.set_value(0);
    m_smi<%=i%>_tx_port_config.k_delay_max.set_value(0);
    m_smi<%=i%>_tx_port_config.k_burst_pct.set_value(100);
  end
  else if($test$plusargs("rand_backpressure"))begin 
    m_smi<%=i%>_tx_port_config.k_delay_min.set_value(1);
    m_smi<%=i%>_tx_port_config.k_delay_max.set_value(45);
  end
  else begin
    <% if (obj.DmiInfo[obj.Id].smiPortParams.rx[i].params.fnMsgClass == "dtw_req_") { %>     
    m_smi<%=i%>_tx_port_config.delay_export  = 1;
    <% } else { %>
    m_smi<%=i%>_tx_port_config.delay_export  = 0;
    <% } %>
    <% for(var k = 0; k < obj.DmiInfo[obj.Id].smiPortParams.rx[i].params.fnMsgClass.length; k++) {
       if (obj.DmiInfo[obj.Id].smiPortParams.rx[i].params.fnMsgClass[k] == "sys_rsp_rx_" ) { %>
    if($test$plusargs("sys_rsp_timeout"))begin
      timeout_threshold = $urandom_range(1,2);
      m_smi<%=i%>_tx_port_config.k_delay_min.set_value(4096*2*timeout_threshold);
      m_smi<%=i%>_tx_port_config.k_delay_max.set_value((4096*2*timeout_threshold)+ 10);
      m_smi<%=i%>_tx_port_config.k_burst_pct.set_value(0);
    end
    <% } } %> 
    <%if (obj.DmiInfo[obj.Id].smiPortParams.rx[i].params.fnMsgClass[1] == "dtr_rsp_" ) { %>     
    if($test$plusargs("dtr_rsp_backpressure"))begin
      m_smi<%=i%>_tx_port_config.k_delay_min.set_value(500);
      m_smi<%=i%>_tx_port_config.k_delay_max.set_value(600);
      m_smi<%=i%>_tx_port_config.k_burst_pct.set_value(0);
    end
    else if($test$plusargs("dtr_rsp_no_delay"))begin
      m_smi<%=i%>_tx_port_config.k_delay_min.set_value(0);
      m_smi<%=i%>_tx_port_config.k_delay_max.set_value(0);
      m_smi<%=i%>_tx_port_config.k_burst_pct.set_value(0);
    end
    <% } %>
  end
  <% } %>
  <% var NSMIIFRX = obj.DmiInfo[0].nSmiTx;
  for (var i = 0; i < NSMIIFRX; i++) { %>
    m_smi<%=i%>_rx_port_config.delay_export  = 0;
    if($test$plusargs("zero_delay") || $test$plusargs("smi<%=i%>_rx_zero_delay"))begin
      m_smi<%=i%>_rx_port_config.k_delay_min.set_value(0);
      m_smi<%=i%>_rx_port_config.k_delay_max.set_value(0);
      m_smi<%=i%>_rx_port_config.k_burst_pct.set_value(100);
    end
    else if($test$plusargs("rand_backpressure"))begin 
      m_smi<%=i%>_rx_port_config.k_delay_min.set_value(1);
      m_smi<%=i%>_rx_port_config.k_delay_max.set_value(45);
    end
    else begin
      <% if (obj.DmiInfo[obj.Id].smiPortParams.tx[i].params.fnMsgClass[0] == "str_req_" ) { %>     
      if($test$plusargs("str_req_backpressure"))begin
        m_smi<%=i%>_rx_port_config.k_delay_min.set_value(500);
        m_smi<%=i%>_rx_port_config.k_delay_max.set_value(600);
        m_smi<%=i%>_rx_port_config.k_burst_pct.set_value(0);
      end
      <% } %>
      <%  if (obj.DmiInfo[obj.Id].smiPortParams.tx[i].params.fnMsgClass[1] == "rbr_rsp_") { %>
      if($test$plusargs("rbr_rsp_backpressure"))begin
        m_smi<%=i%>_rx_port_config.k_delay_min.set_value(150);
        m_smi<%=i%>_rx_port_config.k_delay_max.set_value(200);
        m_smi<%=i%>_rx_port_config.k_burst_pct.set_value(0);
      end
      else if($test$plusargs("rbr_rsp_extreme_backpressure"))begin
        m_smi<%=i%>_rx_port_config.k_delay_min.set_value(1800);
        m_smi<%=i%>_rx_port_config.k_delay_max.set_value(2000);
        m_smi<%=i%>_rx_port_config.k_burst_pct.set_value(0);
      end
      <% } %>
      <%  if (obj.DmiInfo[obj.Id].smiPortParams.tx[i].params.fnMsgClass[0] == "dtr_req_") { %>
      if($test$plusargs("dtr_req_backpressure"))begin
        m_smi<%=i%>_rx_port_config.k_delay_min.set_value(500);
        m_smi<%=i%>_rx_port_config.k_delay_max.set_value(600);
        m_smi<%=i%>_rx_port_config.k_burst_pct.set_value(0);
      end
      if($test$plusargs("dtr_req_extreme_backpressure"))begin
        m_smi<%=i%>_rx_port_config.k_delay_min.set_value(10000);
        m_smi<%=i%>_rx_port_config.k_delay_max.set_value(11000);
        m_smi<%=i%>_rx_port_config.k_burst_pct.set_value(0);
      end
      <% } %>
      <%  if (obj.DmiInfo[obj.Id].smiPortParams.tx[i].params.fnMsgClass[1] == "dtw_rsp_") { %>     
      if($test$plusargs("dtw_rsp_backpressure"))begin
        m_smi<%=i%>_rx_port_config.k_delay_min.set_value(1000);
        m_smi<%=i%>_rx_port_config.k_delay_max.set_value(1200);
        m_smi<%=i%>_rx_port_config.k_burst_pct.set_value(0);
      end
      else if($test$plusargs("dtw_rsp_no_delay"))begin
        m_smi<%=i%>_rx_port_config.k_delay_min.set_value(0);
        m_smi<%=i%>_rx_port_config.k_delay_max.set_value(0);
        m_smi<%=i%>_rx_port_config.k_burst_pct.set_value(0);
      end
      <% } %>
    end
  <% } %>
endfunction : set_smi_if_delay_control

function void dmi_base_test::set_axi_delays();
  if($test$plusargs("performance_test"))begin
    `uvm_info("dmi_base_test",$sformatf("******************Configuring for performace Number****************************"),UVM_LOW)
     m_axi_slave_cfg.k_ace_slave_read_addr_chnl_burst_pct.set_value(k_ace_slave_read_addr_chnl_burst_pct);
     m_axi_slave_cfg.k_ace_slave_read_data_chnl_burst_pct.set_value(k_ace_slave_read_data_chnl_burst_pct);
     m_axi_slave_cfg.k_ace_slave_write_addr_chnl_burst_pct.set_value(k_ace_slave_write_addr_chnl_burst_pct);
     m_axi_slave_cfg.k_ace_slave_write_data_chnl_burst_pct.set_value(k_ace_slave_write_data_chnl_burst_pct);
     m_axi_slave_cfg.k_ace_slave_write_resp_chnl_burst_pct.set_value(k_ace_slave_write_resp_chnl_burst_pct);
  end

  if($test$plusargs("zero_delay") && !($test$plusargs("nonzero_axi_delay"))) begin
    m_axi_slave_cfg.k_ace_slave_read_addr_chnl_delay_min.set_value(0);
    m_axi_slave_cfg.k_ace_slave_read_addr_chnl_delay_max.set_value(0);
    m_axi_slave_cfg.k_ace_slave_read_addr_chnl_burst_pct.set_value(100);
    m_axi_slave_cfg.k_ace_slave_read_data_chnl_delay_min.set_value(0);
    m_axi_slave_cfg.k_ace_slave_read_data_chnl_delay_max.set_value(0);
    m_axi_slave_cfg.k_ace_slave_read_data_chnl_burst_pct.set_value(100);
    m_axi_slave_cfg.k_ace_slave_write_addr_chnl_delay_min.set_value(0);
    m_axi_slave_cfg.k_ace_slave_write_addr_chnl_delay_max.set_value(0);
    m_axi_slave_cfg.k_ace_slave_write_addr_chnl_burst_pct.set_value(100);
    m_axi_slave_cfg.k_ace_slave_write_data_chnl_delay_min.set_value(0);
    m_axi_slave_cfg.k_ace_slave_write_data_chnl_delay_max.set_value(0);
    m_axi_slave_cfg.k_ace_slave_write_data_chnl_burst_pct.set_value(100);
    m_axi_slave_cfg.k_ace_slave_write_resp_chnl_delay_min.set_value(0);
    m_axi_slave_cfg.k_ace_slave_write_resp_chnl_delay_max.set_value(0);
    m_axi_slave_cfg.k_ace_slave_write_resp_chnl_burst_pct.set_value(100);
  end

  m_axi_slave_cfg.k_ace_slave_read_data_interleave_dis.set_value(k_ace_slave_read_data_interleave_dis);
  m_axi_slave_cfg.k_slow_agent                           = k_slow_agent;
  m_axi_slave_cfg.k_slow_read_agent                      = k_slow_read_agent;
  m_axi_slave_cfg.k_slow_write_agent                     = k_slow_write_agent;

  m_axi_slave_cfg.prob_ace_rd_resp_error = prob_ace_rd_resp_error;
  m_axi_slave_cfg.prob_ace_wr_resp_error = prob_ace_wr_resp_error;
endfunction : set_axi_delays

function void dmi_base_test::get_cmdline_args();
  bit flag = 0;
  string arg_value;
  if(clp.get_arg_value("+k_smi_cov_en=", arg_value)) begin
    k_smi_cov_en = arg_value.atoi();
  end
  if(clp.get_arg_value("+k_prob_ccp_single_bit_tag_error=", arg_value)) begin
    k_prob_ccp_single_bit_tag_error = arg_value.atoi();
  end
  if(clp.get_arg_value("+k_prob_ccp_double_bit_tag_error=", arg_value)) begin
    k_prob_ccp_double_bit_tag_error = arg_value.atoi();
  end
  if(clp.get_arg_value("+k_prob_ccp_single_bit_data_error=", arg_value)) begin
    k_prob_ccp_single_bit_data_error = arg_value.atoi();
    `uvm_info("PLUS_ARGS",$sformatf("k_prob_ccp_single_bit_data_error = %0d",k_prob_ccp_single_bit_data_error),UVM_MEDIUM)
  end
  if(clp.get_arg_value("+k_prob_ccp_double_bit_data_error=", arg_value)) begin
    k_prob_ccp_double_bit_data_error = arg_value.atoi();
  end
  if(clp.get_arg_value("+performance_test", arg_value)) begin
      k_inj_smi_delay = 1'b0;
  end
  if(clp.get_arg_value("+k_timeout=", arg_value)) begin
    k_timeout = arg_value.atoi();
     `uvm_info("get_cmdline_args",$sformatf("Got timeout value"),UVM_LOW)
  end
  if(clp.get_arg_value("+k_num_addr=", arg_value)) begin
    k_num_addr = arg_value.atoi();
     `uvm_info("get_cmdline_args",$sformatf("Got k_num_addr value"),UVM_LOW)
  end
  else begin
     k_num_addr = $urandom_range(50,250);
  end
  if(clp.get_arg_value("+k_num_cmd=", arg_value)) begin
    k_num_cmd = arg_value.atoi();
     `uvm_info("get_cmdline_args",$sformatf("Got num_cmd value"),UVM_LOW)
  end
  else begin
    if($test$plusargs("saturate_rbs_test")) begin
      if($test$plusargs("rb_shuffle_order"))begin
        
      end
      else begin
        if($test$plusargs("rb_all_release")) begin
          k_num_cmd =  (<%=obj.DmiInfo[obj.Id].cmpInfo.nDmiRbEntries%>*2-1)*2;
        end
        else k_num_cmd =  (<%=obj.DmiInfo[obj.Id].cmpInfo.nDmiRbEntries%>*2-1); 
      end
    end
    else  k_num_cmd = $urandom_range(500,2000);
  end
  if (clp.get_arg_value("+k_mntop_cmd=", arg_value)) begin
    k_mntop_cmd = arg_value.atoi();
     `uvm_info("get_cmdline_args",$sformatf("Got mntop_cmd value"),UVM_LOW)
  end
  else begin
     k_mntop_cmd = $urandom_range(4,6);
  end
  /*if (clp.get_arg_value("+wt_mrd_read=", arg_value)) begin
    wt_mrd_read = arg_value.atoi();
     `uvm_info("get_cmdline_args",$sformatf("Got wt_mrd_read value"),UVM_LOW)
  end
  else begin
     wt_mrd_read = $urandom_range(1,100);
  end*/
  if(clp.get_arg_value("+k_atomic_opcode=", arg_value)) begin
    k_atomic_opcode = arg_value.atoi();
    `uvm_info("get_cmdline_args",$sformatf("Got atomic_opcode value"),UVM_LOW)
  end
  else begin
    k_atomic_opcode = 8;
  end
  if(clp.get_arg_value("+k_intfsize=", arg_value)) begin
    k_intfsize = arg_value.atoi();
    `uvm_info("get_cmdline_args",$sformatf("Got intfsize value"),UVM_LOW)
  end
  else begin
    k_intfsize = 8;
  end
  if(clp.get_arg_value("+n_pending_txn_mode=", arg_value)) begin
    n_pending_txn_mode = arg_value.atoi();
    `uvm_info("get_cmdline_args",$sformatf("Got n_pending_txn_mode value"),UVM_LOW)
  end
  if(clp.get_arg_value("+k_full_cl_only=", arg_value)) begin
    k_full_cl_only = arg_value.atoi();
    `uvm_info("get_cmdline_args",$sformatf("Got k_full_cl_only value"),UVM_LOW)
  end

  if(clp.get_arg_value("+k_force_size=", arg_value)) begin
    k_force_size    = arg_value.atoi();
    `uvm_info("get_cmdline_args",$sformatf("Got k_force_size value"),UVM_LOW)
  end

  if(clp.get_arg_value("+k_force_mw=", arg_value)) begin
    k_force_mw    = arg_value.atoi();
    `uvm_info("get_cmdline_args",$sformatf("Got k_force_mw value"),UVM_LOW)
  end

  if(clp.get_arg_value("+k_back_to_back_types=", arg_value)) begin
    k_back_to_back_types = arg_value.atoi();
    `uvm_info("get_cmdline_args",$sformatf("Got k_back_to_back_types value"),UVM_LOW)
  end
  else begin
    case ($urandom_range(1,100))
      3: begin
      k_back_to_back_types = 901;
      flag = 1;
      end
      6: begin
      k_back_to_back_types = 910;
      flag = 1;
      end
      9: begin
      k_back_to_back_types = 902;
      flag = 1;
      end
      12: begin
      k_back_to_back_types = 920;
      flag = 1;
      end
      15: begin
      k_back_to_back_types = 912;
      flag = 1;
      end
      18: begin
      k_back_to_back_types = 921;
      flag = 1;
      end
      default: begin
      k_back_to_back_types = 999;
      flag = 1;
      end
    endcase // case ($urandom_range(1,100)...
  end
  if (clp.get_arg_value("+k_back_to_back_chains=", arg_value)) begin
     k_back_to_back_chains = arg_value.atoi();
     `uvm_info("get_cmdline_args",$sformatf("Got k_back_to_back_chains value"),UVM_LOW)
  end
  else begin
    if(flag) begin
      k_back_to_back_chains = $urandom_range(1,20);
    end
  end
  flag = 0;
  if(clp.get_arg_value("+k_force_allocate=", arg_value)) begin
    k_force_allocate = arg_value.atoi();
    `uvm_info("get_cmdline_args",$sformatf("Got force_allocate value"),UVM_LOW)
  end
  if(clp.get_arg_value("+k_addr_trans_hit=", arg_value)) begin
    k_addr_trans_hit = arg_value.atoi();
    `uvm_info("get_cmdline_args",$sformatf("Got addr_trans_hit value"),UVM_LOW)
  end
  if(clp.get_arg_value("+use_last_dealloc=", arg_value)) begin
    use_last_dealloc = arg_value.atoi();
    `uvm_info("get_cmdline_args",$sformatf("Got use_last_dealloc value"),UVM_LOW)
  end
  if(clp.get_arg_value("+use_adj_addr=", arg_value)) begin
    use_adj_addr = arg_value.atoi();
    `uvm_info("get_cmdline_args",$sformatf("Got use_adj_addr value"),UVM_LOW)
  end
  if(clp.get_arg_value("+mrd_use_last_mrd_pref=", arg_value)) begin
    mrd_use_last_mrd_pref = arg_value.atoi();
    `uvm_info("get_cmdline_args",$sformatf("Got mrd_use_last_mrd_pref value"),UVM_LOW)
  end
  if(clp.get_arg_value("+tb_delay=", arg_value)) begin
    tb_delay = arg_value.atoi();
  end
  if(clp.get_arg_value("+dmi_scb_en=", arg_value)) begin
    dmi_scb_en = arg_value.atoi();
  end
  if(clp.get_arg_value("+ccp_scb_en=", arg_value)) begin
    ccp_scb_en = arg_value.atoi();
  end
  if (clp.get_arg_value("+k_min_reuse_q_size=", arg_value)) begin
    k_min_reuse_q_size = arg_value.atoi();
    reuse_q_flag = 1;
  end
  else begin
     randval = $urandom_range(1,10);
     case(randval)
       1: begin
          k_min_reuse_q_size = 2;
       end
       2,3,4:begin
          k_min_reuse_q_size = 4;
       end
       default: begin
          k_min_reuse_q_size = 8;
       end
     endcase // case (randval)
  end
  if (clp.get_arg_value("+k_max_reuse_q_size=", arg_value)) begin
    k_max_reuse_q_size = arg_value.atoi();
    reuse_q_flag = 1;
  end
  else begin
    randval = $urandom_range(1,10);
    case(randval)
      1: begin
         k_max_reuse_q_size = k_min_reuse_q_size+1;
      end
      2,3:begin
         k_max_reuse_q_size = 10;
      end
      4,5:begin
         k_max_reuse_q_size = 15;
      end
      default: begin
         k_max_reuse_q_size = 20;
      end
    endcase // case (randval)
  end
  if (clp.get_arg_value("+k_reuse_q_pct=", arg_value)) begin
    k_reuse_q_pct = arg_value.atoi();
    reuse_q_flag = 1;
  end
  else begin
    k_reuse_q_pct = $urandom_range(2,9)*10;
  end

  <% if(obj.INHOUSE_APB_VIP) { %>
   // apb delay knobs
  if (clp.get_arg_value("+k_apb_mcmd_delay_min=", arg_value)) begin
    k_apb_mcmd_delay_min = arg_value.atoi();
  end
  if (clp.get_arg_value("+k_apb_mcmd_delay_max=", arg_value)) begin
    k_apb_mcmd_delay_max = arg_value.atoi();
  end
  if (clp.get_arg_value("+k_apb_mcmd_burst_pct=", arg_value)) begin
    k_apb_mcmd_burst_pct = arg_value.atoi();
  end
  if (clp.get_arg_value("+k_apb_mcmd_wait_for_scmdaccept=", arg_value)) begin
    k_apb_mcmd_wait_for_scmdaccept = arg_value.atoi();
  end
  if (clp.get_arg_value("+k_apb_maccept_delay_min=", arg_value)) begin
    k_apb_maccept_delay_min = arg_value.atoi();
  end
  if (clp.get_arg_value("+k_apb_maccept_delay_max=", arg_value)) begin
    k_apb_maccept_delay_max = arg_value.atoi();
  end
  if (clp.get_arg_value("+k_apb_maccept_burst_pct=", arg_value)) begin
    k_apb_maccept_burst_pct = arg_value.atoi();
  end
  if (clp.get_arg_value("+k_apb_maccept_wait_for_sresp=", arg_value)) begin
    k_apb_maccept_wait_for_sresp = arg_value.atoi();
  end

    flag = 0;
   if (clp.get_arg_value("+k_slow_apb_agent=", arg_value)) begin
      k_slow_apb_agent = arg_value.atoi();
      flag = 1;
   end
   if (clp.get_arg_value("+k_slow_apb_mcmd_agent=", arg_value)) begin
      k_slow_apb_mcmd_agent = arg_value.atoi();
      flag = 1;
   end
   if (clp.get_arg_value("+k_slow_apb_mrespaccept_agent=", arg_value)) begin
      k_slow_apb_mrespaccept_agent = arg_value.atoi();
      flag = 1;
   end
   if (!flag) begin
      randcase
        70: ;
        10: k_slow_apb_agent = 1;
        10: k_slow_apb_mcmd_agent = 1;
        10: k_slow_apb_mrespaccept_agent = 1;
      endcase // randcase
   end

  <% } %>
  flag = 0;
  if(clp.get_arg_value("+inject_ttdebug=", arg_value)) begin
    inject_ttdebug = arg_value.atoi();
    `uvm_info("get_cmdline_args",$sformatf("Got ttdebug knob"),UVM_LOW)
    flag = 1;
  end
  if(clp.get_arg_value("+k_csr_seq=", arg_value)) begin
    k_csr_seq = arg_value;
    `uvm_info("get_cmdline_args",$sformatf("k_csr_seq = %s",k_csr_seq),UVM_LOW)
    flag = 1;
  end
  if(clp.get_arg_value("+k_csr_SMC_mntop_seq=", arg_value)) begin
    k_csr_SMC_mntop_seq = arg_value;
    `uvm_info("get_cmdline_args",$sformatf("k_csr_SMC_mntop_seq = %s",k_csr_SMC_mntop_seq),UVM_LOW)
    flag = 1;
  end
  if(clp.get_arg_value("+k_csr_SMC_mntop_seq_for_error=", arg_value)) begin
    k_csr_SMC_mntop_seq_for_error = arg_value;
    `uvm_info("get_cmdline_args",$sformatf("k_csr_SMC_mntop_seq_for_error = %s",k_csr_SMC_mntop_seq_for_error),UVM_LOW)
    flag = 1;
  end
  if(clp.get_arg_value("+inject_random_csr_seq=", arg_value)) begin
    inject_random_csr_seq = 0; //arg_value.atoi();
    `uvm_info("get_cmdline_args",$sformatf("Inject random csr seq"),UVM_LOW)
    flag = 1;
  end
  if(clp.get_arg_value("+ccp_online_csr_seq=", arg_value)) begin
    inject_ccp_online_csr_seq = 1;
    `uvm_info("get_cmdline_args",$sformatf("Inject ccp online csr seq"),UVM_LOW)
    flag = 1;
  end
  if(clp.get_arg_value("+ccp_offline_csr_seq=", arg_value)) begin
    inject_ccp_offline_csr_seq = 1;
    `uvm_info("get_cmdline_args",$sformatf("Inject ccp offline csr seq"),UVM_LOW)
    flag = 1;
  end
  if(clp.get_arg_value("+ccp_random_flush_csr_seq=", arg_value)) begin
    `uvm_info("get_cmdline_args",$sformatf("Inject ccp random flush csr seq with flush_count=%s", arg_value),UVM_LOW)
     inject_ccp_random_flush_csr_seq = arg_value.atoi();
    `uvm_info("get_cmdline_args",$sformatf("Inject ccp random flush csr seq with flush_count=%0d", inject_ccp_random_flush_csr_seq),UVM_LOW)
    flag = 1;
  end
  if(clp.get_arg_value("+ccp_random_flush_csr_seq_last=", arg_value)) begin
    `uvm_info("get_cmdline_args",$sformatf("Inject ccp random flush csr seq at last of test with flush_count=%s", arg_value),UVM_LOW)
     inject_ccp_random_flush_csr_seq_last = arg_value.atoi();
    `uvm_info("get_cmdline_args",$sformatf("Inject ccp random flush csr seq last with flush_count=%0d", inject_ccp_random_flush_csr_seq_last),UVM_LOW)
    flag = 1;
  end
  if(clp.get_arg_value("+ccp_random_online_offline_csr_seq=", arg_value)) begin
    `uvm_info("get_cmdline_args",$sformatf("Inject ccp random online offline csr seq with flush_count=%s", arg_value),UVM_LOW)
     inject_ccp_random_online_offline_csr_seq = arg_value.atoi();
    `uvm_info("get_cmdline_args",$sformatf("Inject ccp random online offline csr seq with flush_count=%0d", inject_ccp_random_online_offline_csr_seq),UVM_LOW)
    flag = 1;
  end
  if(clp.get_arg_value("+ccp_terminating_flush_csr_seq=", arg_value)) begin
    inject_ccp_terminating_flush_csr_seq = 1;
    `uvm_info("get_cmdline_args",$sformatf("Inject ccp terminating flush csr seq"),UVM_LOW)
    flag = 1;
  end
  if(!flag) begin
    randcase
      50: inject_random_csr_seq = 0;
      50: inject_random_csr_seq = 1;
    endcase // randcase
  end

  if($test$plusargs("k_wrdatacln_propagate")) begin
    k_WrDataClnPropagateEn = 1;
  end
  else begin
    k_WrDataClnPropagateEn = $urandom_range(0,1);
  end

   if(!$test$plusargs("ex_sys_evt")) begin
     k_SysEventDisable = 1;
   end

  //if (clp.get_arg_value("+k_ace_slave_read_data_reorder_size=", arg_value)) begin
  //    k_ace_slave_read_data_reorder_size = arg_value.atoi();
  //end
  if (clp.get_arg_value("+k_slow_agent=", arg_value)) begin
      k_slow_agent = arg_value.atoi();
      flag = 1;
  end
  if (clp.get_arg_value("+k_slow_read_agent=", arg_value)) begin
      k_slow_read_agent = arg_value.atoi();
      flag = 1;
  end
  if (clp.get_arg_value("+k_slow_write_agent=", arg_value)) begin
      k_slow_write_agent = arg_value.atoi();
      flag = 1;
  end

  if (clp.get_arg_value("+k_use_all_str_msg_id=", arg_value)) begin
      k_use_all_str_msg_id = arg_value.atoi();
  end
  
  if (clp.get_arg_value("+k_atomic_directed=", arg_value)) begin
      k_atomic_directed = arg_value.atoi();
  end

  <% if(obj.useCmc) { %>
    if(clp.get_arg_value("+k_cmc_policy_rand=", arg_value)) begin
      k_cmc_policy = arg_value.atobin();
    end
    else begin
      `uvm_info("get_cmdline_args",$sformatf("randomizing cmc_policy"),UVM_LOW)
      randcase
        90 : k_cmc_policy = 6'b000011;
        1  : k_cmc_policy = 6'b000111;
        1  : k_cmc_policy = 6'b001011;
        1  : k_cmc_policy = 6'b010011;
        1  : k_cmc_policy = 6'b100011;
        1  : k_cmc_policy = 6'b000000;
        1  : k_cmc_policy = 6'b000001;
        1  : k_cmc_policy = 6'b111100;
      endcase
    end
  <% } else { %>
         k_cmc_policy = 6'b000000;
  <% } %>

    if(clp.get_arg_value("+random_cctrlr_value=", arg_value)) begin
      bit[ 3:0] rand_cctrlr_gain;
      bit[12:0] rand_cctrlr_inc;      
      if(arg_value.atobin() == 1) begin
        assert(std::randomize(rand_cctrlr_gain));
        assert(std::randomize(rand_cctrlr_inc) with { rand_cctrlr_inc inside {1,2,4,8,16,32,64,128,256,512,1024,2048};})
        else begin
          `uvm_error("get_cmdline_args","+random_cctrlr_value inc randomization failed")
        end
        cctrlr_value = $urandom;
        cctrlr_value[31:20] = rand_cctrlr_inc;
        cctrlr_value[19:16] = rand_cctrlr_gain;
        `uvm_info("get_cmdline_args",$sformatf("+random_cctrlr_value randomization  | cctrl_value:%0h gain:%0d inc:%0d",cctrlr_value,rand_cctrlr_gain,rand_cctrlr_inc),UVM_LOW)
      end
    end

    if(clp.get_arg_value("+k_cctrlr_value=", arg_value)) begin
        cctrlr_value = arg_value.atohex();
        `uvm_info("get_cmdline_args",$sformatf("+k_cctrlr_value received:%0h",cctrlr_value),UVM_LOW)
    end

  //////////////////////////////////////////////////////////////////////////////
  //
  // Directed tests. Set knobs based on testname
  //
  //////////////////////////////////////////////////////////////////////////////
  clp.get_arg_value("+UVM_TESTNAME=", arg_value);
  if (arg_value == "dmi_bresp_backpressure_test") begin
     k_slow_agent       = 0;
     k_slow_read_agent  = 0;
     k_slow_write_agent = 0;
     /*
      k_ace_slave_read_addr_chnl_delay_min  = 0;
      k_ace_slave_read_addr_chnl_delay_max  = 0;
      k_ace_slave_read_addr_chnl_burst_pct  = 100;
      k_ace_slave_read_data_chnl_delay_min  = 0;
      k_ace_slave_read_data_chnl_delay_max  = 0;
      k_ace_slave_read_data_chnl_burst_pct  = 100;
      k_ace_slave_write_addr_chnl_delay_min = 0;
      k_ace_slave_write_addr_chnl_delay_max = 0;
      k_ace_slave_write_addr_chnl_burst_pct = 100;
      k_ace_slave_write_data_chnl_delay_min = 0;
      k_ace_slave_write_data_chnl_delay_max = 0;
      k_ace_slave_write_data_chnl_burst_pct = 100;
      k_ace_slave_write_resp_chnl_delay_min = 50;
      k_ace_slave_write_resp_chnl_delay_max = 100;
      k_ace_slave_write_resp_chnl_burst_pct = 10;
    */
    flag = 1;
  end

  if ((arg_value == "dmi_arready_backpressure_test1") ||
      (arg_value == "dmi_arready_backpressure_test2")) begin
      k_slow_agent       = 0;
      k_slow_read_agent  = 0;
      k_slow_write_agent = 0;
      /*
      k_ace_slave_read_addr_chnl_delay_min  = 50;
      k_ace_slave_read_addr_chnl_delay_max  = 100;
      k_ace_slave_read_addr_chnl_burst_pct  = 10;
      k_ace_slave_read_data_chnl_delay_min  = 0;
      k_ace_slave_read_data_chnl_delay_max  = 0;
      k_ace_slave_read_data_chnl_burst_pct  = 100;
      k_ace_slave_write_addr_chnl_delay_min = 0;
      k_ace_slave_write_addr_chnl_delay_max = 0;
      k_ace_slave_write_addr_chnl_burst_pct = 100;
      k_ace_slave_write_data_chnl_delay_min = 0;
      k_ace_slave_write_data_chnl_delay_max = 0;
      k_ace_slave_write_data_chnl_burst_pct = 100;
      k_ace_slave_write_resp_chnl_delay_min = 0;
      k_ace_slave_write_resp_chnl_delay_max = 0;
      k_ace_slave_write_resp_chnl_burst_pct = 100;
      */
    flag = 1;
  end

  if($test$plusargs("performance_test"))begin
    <% if(obj.useCmc) { %>
     //k_num_addr = <%=obj.nSets%>*<%=obj.nWays%>;
     //k_num_cmd  = <%=obj.nSets%>*<%=obj.nWays%>-1;
    <% } else { %>
      k_num_addr = 1000;
      k_num_cmd  = 1000;
     <% } %>
     k_ace_slave_read_addr_chnl_burst_pct  = 100;
     k_ace_slave_read_data_chnl_burst_pct  = 100;
     k_ace_slave_write_addr_chnl_burst_pct = 100;
     k_ace_slave_write_data_chnl_burst_pct = 100;
     k_ace_slave_write_resp_chnl_burst_pct = 100;
     flag = 1;
   end

  //////////////////////////////////////////////////////////////////////////////
  if (!flag) begin
    randcase
      20: ;
      10: k_slow_agent       = 1;
      10: k_slow_read_agent  = 1;
      10: k_slow_write_agent = 1;
      10: begin
        // k_ace_slave_read_addr_chnl_delay_min = $urandom_range(0,10);
        // k_ace_slave_read_addr_chnl_delay_max = $urandom_range(k_ace_slave_read_addr_chnl_delay_min,200);
        // k_ace_slave_read_addr_chnl_burst_pct = $urandom_range(1,10)*10;
      end
      10: begin
        // k_ace_slave_read_data_chnl_delay_min = $urandom_range(0,10);
        // k_ace_slave_read_data_chnl_delay_max = $urandom_range(k_ace_slave_read_data_chnl_delay_min,200);
        // k_ace_slave_read_data_chnl_burst_pct = $urandom_range(1,10)*10;
      end
      10: begin
        // k_ace_slave_write_addr_chnl_delay_min = $urandom_range(0,10);
        // k_ace_slave_write_addr_chnl_delay_max = $urandom_range(k_ace_slave_write_addr_chnl_delay_min,200);
        // k_ace_slave_write_addr_chnl_burst_pct = $urandom_range(1,10)*10;
      end
      10: begin
        // k_ace_slave_write_data_chnl_delay_min = $urandom_range(0,10);
        // k_ace_slave_write_data_chnl_delay_max = $urandom_range(k_ace_slave_write_data_chnl_delay_min,200);
        // k_ace_slave_write_data_chnl_burst_pct = $urandom_range(1,10)*10;
      end
      10: begin
        // k_ace_slave_write_resp_chnl_delay_min = $urandom_range(0,10);
        // k_ace_slave_write_resp_chnl_delay_max = $urandom_range(k_ace_slave_write_resp_chnl_delay_min,200);
        // k_ace_slave_write_resp_chnl_burst_pct = $urandom_range(1,10)*10;
      end
    endcase
  end // if (!flag)
  if (clp.get_arg_value("+EN_DMI_VSEQ=", arg_value)) begin
      EN_DMI_VSEQ = arg_value.atobin();
  end
  // WARNING: Use this on the commandline carefully. No check for using interleaved memory with no RttDataEntries.
  flag = 0;

  // Code modified for Read Data Interleaving support
  if (clp.get_arg_value("+k_ace_slave_read_data_interleave_dis=", arg_value)) begin
    k_ace_slave_read_data_interleave_dis = arg_value.atoi();
    flag = k_ace_slave_read_data_interleave_dis;
  end
  
  if (!flag) begin
     // #Check.DMI.v3.4.MemRsp_1_IntrDis_0
     // #Check.DMI.v3.4.MemRsp_1_IntrDis_1
     if (useMemRspIntrlv) begin
        //Though useMemRspIntrlv is set, DV might choose not to interleave.
        randcase
          50: k_ace_slave_read_data_interleave_dis = 0;
          50: k_ace_slave_read_data_interleave_dis = 1;
        endcase
     end
     else begin
        k_ace_slave_read_data_interleave_dis = 1;
     end
     // Update the database for functional coverage use only
     uvm_config_db #(int) :: set (this,"*","k_ace_slave_read_data_interleave_dis",k_ace_slave_read_data_interleave_dis);
  end
  // #Check.DMI.v3.4.MemRsp_1_IntrDis_0
  // #Check.DMI.v3.4.MemRsp_1_IntrDis_1
  if((useMemRspIntrlv==1) && (k_ace_slave_read_data_interleave_dis==0))
    `uvm_info(get_full_name(),$sformatf("Read Data Interleaving is ON..."), UVM_NONE)
  else begin
    `uvm_info(get_full_name(),$sformatf("Read Data Interleaving is OFF..."), UVM_NONE)
  end
     
  if(clp.get_arg_value("+prob_ace_rd_resp_error=", arg_value)) begin
    prob_ace_rd_resp_error = arg_value.atoi();
  end
  else begin
    case($urandom_range(0,100))
      10: prob_ace_rd_resp_error = $urandom_range(0,10);
      default: prob_ace_rd_resp_error = 0;
    endcase // case ($urandom_range(0,100))
  end
  if(clp.get_arg_value("+prob_ace_wr_resp_error=", arg_value)) begin
    prob_ace_wr_resp_error = arg_value.atoi();
  end
  else begin
    case($urandom_range(0,100))
      10: prob_ace_wr_resp_error = $urandom_range(0,10);
      default: prob_ace_wr_resp_error = 0;
    endcase // case ($urandom_range(0,100))
  end

  if(clp.get_arg_value("+k_sp_base_addr=", arg_value)) begin
    k_sp_base_addr = arg_value.atohex();
  end
  uvm_config_db#(smi_addr_t)::set(this,
                                 .inst_name("*"),
                                 .field_name("lower_sp_addr"),
                                 .value(k_sp_base_addr));
  if(clp.get_arg_value("+k_sp_max_addr=", arg_value)) begin
    k_sp_max_addr = arg_value.atohex();
    uvm_config_db#(smi_addr_t)::set(this,
                                    .inst_name("*"),
                                    .field_name("upper_sp_addr"),
                                    .value(k_sp_max_addr));
  end
endfunction : get_cmdline_args
`endif // DMI_BASE_TEST
