import common_knob_pkg::*;

//Display outstanding objections upon hbfail.
class timeout_catcher extends uvm_report_catcher;
    uvm_phase phase;

    `uvm_object_utils(timeout_catcher)

<% if(obj.testBench == 'chi_aiu') { %>
 `ifdef CDNS
    function new(string name = "timeout_catcher");
        super.new(name);
    endfunction: new
 `endif 
<% }  %>

<% if(obj.testBench == 'chi_aiu') { %>
 `ifdef VCS 
  function new (string name="timeout_catcher",uvm_component parent=null);
    super.new (name);
  endfunction : new
 `endif 
<% }  %>
    function action_e catch();
        if(get_severity() == UVM_FATAL && get_id() == "HBFAIL") begin
            uvm_objection obj = phase.get_objection();
            `uvm_error("HBFAIL", $psprintf("Heartbeat failure! Objections:"));
            obj.display_objections();
        end
        return THROW;
    endfunction

endclass

<% if(obj.testBench == 'chi_aiu') { %>
 `ifdef VCS 
class my_report_server extends uvm_default_report_server;

   function new(string name = "my_report_server");
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
    foreach(q2[s])
      m_id_count[q2[s]] = svr.get_id_count(q2[s]);

    svr.get_severity_set(q1);
    foreach(q1[s])
      m_severity_count[q1[s]] = svr.get_severity_count(q1[s]);


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
////////////////////////////////////////////////////////////////////////////////
// 
// Author       : Muffadal 
// Purpose      : CHI-AIU Base test
// Revision     :
//
// [ Browse code using this sections ]
//
// [ Notes ]
//
//
////////////////////////////////////////////////////////////////////////////////
class chi_aiu_base_test extends uvm_test;

  `macro_perf_cnt_test_all_declarations
  `macro_connectivity_test_all_declarations
  addr_trans_mgr m_addr_mgr;

`ifdef USE_VIP_SNPS
  /** Instance of the environment */
  svt_amba_env_class_pkg::svt_amba_env env;
  
  /** AMBA System Configuration */
  cust_svt_amba_system_configuration cfg;
`endif // USE_VIP_SNPS
  //Instatiate the env
  chiaiu_env m_env;

  //Instatiate the system bfm
  system_bfm_seq     m_system_bfm_seq;

  chiaiu_env_config m_env_cfg;
<% if(obj.INHOUSE_APB_VIP && obj.testBench=="chi_aiu") { %>
  apb_agent_config  m_apb_cfg;
<% } %>

  <%=obj.BlockId%>_chi_container_pkg::chi_container#(<%=obj.AiuInfo[obj.Id].FUnitId%>) m_chi_container;

  int timeout;
  bit flag                                   = 0;
  bit k_smi_cov_en                           = 1;
  string k_csr_seq = "";
  // control knobs
<% if(obj.INHOUSE_APB_VIP && obj.testBench=="chi_aiu") { %>
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
   virtual chi_aiu_csr_probe_if u_csr_probe_vif;

  //Command line processor UVM utility
  uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();

`uvm_component_utils_begin(chi_aiu_base_test)
<% if(obj.INHOUSE_APB_VIP && obj.testBench=="chi_aiu") { %>
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
<% } %>
  `uvm_field_string(k_csr_seq                          ,UVM_STRING);
  `uvm_component_utils_end

  //Methods
  extern function new(
    string name="chi_aiu_base_test",
    uvm_component parent = null);

 extern function void build_phase(uvm_phase phase);
 extern function void connect_phase(uvm_phase phase);
 extern function void start_of_simulation_phase(uvm_phase phase);
 extern function void end_of_elaboration_phase (uvm_phase phase);
 extern function void check_phase (uvm_phase phase);
 extern function void report_phase(uvm_phase phase);
 extern task run_phase(uvm_phase phase);

`ifdef USE_VIP_SNPS
// extern function void test_cfg();
`endif // USE_VIP_SNPS


endclass: chi_aiu_base_test

//Construtor
function chi_aiu_base_test::new(
  string name="chi_aiu_base_test",
  uvm_component parent = null);

    super.new(name,parent);
    m_addr_mgr = addr_trans_mgr::get_instance();
    m_chi_container = <%=obj.BlockId%>_chi_container_pkg::chi_container#(<%=obj.AiuInfo[obj.Id].FUnitId%>)::type_id::create("chi_container");
  //m_chi_container.set_chi_node_type(<%=obj.BlockId%>_chi_bfm_types_pkg::BFM_RN, WBE);
endfunction


//========================================================================
// Function : build_phase
// Purpose  :
//========================================================================
function void chi_aiu_base_test::build_phase(uvm_phase phase);
  string arg_value;

  super.build_phase(phase);

`ifdef USE_VIP_SNPS
  /** Create the environment class */
  env = svt_amba_env_class_pkg::svt_amba_env::type_id::create ("env", this);
  
  /** Create the AMBA configuration */
  cfg = cust_svt_amba_system_configuration::type_id::create("cfg");

  /** set AMBA Configuration */
  cfg.set_amba_sys_config();

  //test_cfg();

  /** Apply the configuration to the AMBA ENV */
  uvm_config_db#(cust_svt_amba_system_configuration)::set(this, "env", "cfg", cfg);
`endif // USE_VIP_SNPS

  //Instantiate config object
  m_env_cfg = chiaiu_env_config::type_id::create("m_env_cfg");
  m_env_cfg.m_smi_cfg = smi_agent_config::type_id::create("m_smi_cfg");
  m_env_cfg.m_chi_cfg = chi_agent_cfg::type_id::create("m_chi_cfg");

  //Get Interface
  if (!uvm_config_db #(virtual <%=obj.BlockId%>_chi_if)::get(
         .cntxt(this),
         .inst_name(""),
         .field_name("chi_rn_vif"),
         .value(m_env_cfg.m_chi_vif))
  ) begin
    `uvm_fatal(get_name(), "unable to find chi virtual interface")
  end

  //if (!uvm_config_db #(chi_rn_driver_vif)::get(
  //     .cntxt(this),
  //     .inst_name(""),
  //     .field_name("chi_rn_driver_vif"),
  //     .value(m_env_cfg.m_rn_drv_vif))) begin
  //  
  //  `uvm_fatal(get_name(), "Unable to find chi_rn_driver_vif")
  //end

  //if (!uvm_config_db #(chi_rn_monitor_vif)::get(
  //     .cntxt(this),
  //     .inst_name(""),
  //     .field_name("chi_rn_monitor_vif"),
  //     .value(m_env_cfg.m_rn_mon_vif))) begin
  //  
  //  `uvm_fatal(get_name(), "Unable to find chi_rn_monitor_vif")
  //end

  //SMI TX interface
<% for (var i = 0; i < obj.nSmiRx; i++) { %>
  if (!uvm_config_db #(virtual <%=obj.BlockId%>_smi_if)::get(
       .cntxt(this),
       .inst_name(""),
       .field_name("m_smi<%=i%>_tx_vif"),
       .value(m_env_cfg.m_smi<%=i%>_tx_vif))) begin

       `uvm_fatal(get_name(), "unable to find m_smi<%=i%>_tx_vif")
  end
<% } %>

  //SMI RX interface
<% for (var i = 0; i < obj.nSmiTx; i++) { %>
  if (!uvm_config_db #(virtual <%=obj.BlockId%>_smi_if)::get(
       .cntxt(this),
       .inst_name(""),
       .field_name("m_smi<%=i%>_rx_vif"),
       .value(m_env_cfg.m_smi<%=i%>_rx_vif))) begin

       `uvm_fatal(get_name(), "unable to find m_smi<%=i%>_rx_vif")
  end
<% } %>

<% var NSMIIFTX = obj.nSmiRx;
  for (var i = 0; i < NSMIIFTX; i++) { %>
  <% } %>
  <% var NSMIIFRX = obj.nSmiTx;
  for (var i = 0; i < NSMIIFRX; i++) { %>
  <% } %>

  m_env_cfg.m_chi_cfg.delay_export = 1;

  //push chi_env_config objected to uvm resource db
  //Env Config Object
  uvm_config_db #(chiaiu_env_config)::set(
    .cntxt(this),
    .inst_name("m_env"),
    .field_name("chi_aiu_env_config"),
    .value(m_env_cfg));

  if(clp.get_arg_value("+k_smi_cov_en=", arg_value)) begin
    k_smi_cov_en = arg_value.atoi();
  end
  m_env_cfg.m_smi_cfg.cov_en = k_smi_cov_en;

  //Instatiate the env
  m_env = chiaiu_env::type_id::create("m_env", this);

  //m_chi_container = <%=obj.BlockId%>_chi_container_pkg::chi_container#(<%=obj.AiuInfo[obj.Id].FUnitId%>)::type_id::create("chi_container");
  m_chi_container.set_chi_node_type(<%=obj.BlockId%>_chi_bfm_types_pkg::BFM_RN, WBE);

  //Instatiate the system bfm
  m_system_bfm_seq = system_bfm_seq::type_id::create("m_system_bfm_seq",this);
  m_system_bfm_seq.k_num_snp_q_pending.set_value(<%=obj.DutInfo.nSttEntries%>);

  if(!$value$plusargs("k_timeout=%d", timeout)) begin
      timeout = 1500000; //1.5ms
  end
  `uvm_info(get_type_name(), $psprintf("TIMEOUT is set to: %0d", timeout), UVM_LOW);
<% if(obj.INHOUSE_APB_VIP && obj.testBench=="chi_aiu") { %>
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
   if (clp.get_arg_value("+k_csr_seq=", arg_value)) begin
      k_csr_seq = arg_value;
      `uvm_info(get_name(), $sformatf("k_csr_seq = %s",k_csr_seq),UVM_MEDIUM)
   end
<% if(obj.INHOUSE_APB_VIP && obj.testBench=="chi_aiu") { %>
   m_apb_cfg = apb_agent_config::type_id::create("m_apb_cfg", this);

   if (!uvm_config_db#(virtual <%=obj.BlockId%>_apb_if)::get(.cntxt( this ),
                                        .inst_name( "*" ),
                                        .field_name( "apb_if" ),
                                        .value( m_apb_cfg.m_vif ))) begin
      `uvm_error(get_type_name(), "APB if not found")
   end

  m_env_cfg.m_apb_cfg = m_apb_cfg;
<% } %>
  m_env_cfg.m_q_chnl_agent_cfg = q_chnl_agent_config::type_id::create("m_q_chnl_agent_config",  this);

  if (!uvm_config_db#(virtual <%=obj.BlockId%>_q_chnl_if)::get(.cntxt( this ),
                                      .inst_name( "" ),
                                      .field_name( "m_q_chnl_if" ),
                                      .value(m_env_cfg.m_q_chnl_agent_cfg.m_vif ))) begin
      `uvm_error(get_type_name(), "m_q_chnl_if not found")
  end
  if(!uvm_config_db#(virtual chi_aiu_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_vif)) begin
       `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
  end

endfunction: build_phase

`ifdef USE_VIP_SNPS
//virtual function void chi_aiu_base_test::test_cfg();
//endfunction
`endif // USE_VIP_SNPS

function void chi_aiu_base_test::connect_phase(uvm_phase phase);
  super.connect_phase(phase);

  m_system_bfm_seq.m_smi_virtual_seqr = m_env.m_smi_agent.m_smi_virtual_seqr;
endfunction: connect_phase

function void chi_aiu_base_test::start_of_simulation_phase(uvm_phase phase);
<% if(obj.testBench == 'chi_aiu') { %>
 `ifdef VCS 
    my_report_server my_server = new();
  `endif
<% } %>
    super.start_of_simulation_phase(phase);

<% if(obj.testBench == 'chi_aiu') { %>
 `ifdef VCS 
    uvm_report_server::set_server( my_server );
  `endif
<% } %>
endfunction : start_of_simulation_phase


function void chi_aiu_base_test::end_of_elaboration_phase (uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    uvm_top.set_timeout(timeout*1ns);
endfunction: end_of_elaboration_phase


task chi_aiu_base_test::run_phase(uvm_phase phase);
  fork
    begin
      m_addr_mgr.get_connectivity_if();
    end
  join_none
endtask: run_phase

function void chi_aiu_base_test::check_phase(uvm_phase phase);
  int inj_cntl;
  bit targ_id_err;
  bit perfmon_smi_stall = 0;
  int timeout_uc_err;
  super.check_phase(phase);
  $value$plusargs("inj_cntl=%d",inj_cntl);
  uvm_config_db#(int)::get(null,"*","timeout_uc_err",timeout_uc_err);
<%  if (obj.useResiliency) { %>
  //To check mission fault for wrong_target_id/memory uncorrectable error injection(Ncore3.0/section 5.4)
  if($test$plusargs("wrong_cmdrsp_target_id") || $test$plusargs("wrong_dtwrsp_target_id") || $test$plusargs("wrong_dtrrsp_target_id") || $test$plusargs("wrong_snpreq_target_id") || $test$plusargs("wrong_dtrreq_target_id") || $test$plusargs("wrong_strreq_target_id") || ($test$plusargs("wrong_sysrsp_target_id") && ($test$plusargs("check4_attach") || $test$plusargs("check4_detach"))) || $test$plusargs("wrong_DtwDbg_rsp_target_id") || $test$plusargs("wrong_sysreq_target_id")) begin
    targ_id_err = 1'b1;
  end
<% if(obj.AiuInfo[obj.Id].ResilienceInfo.enableUnitDuplication) { %>
  if(smi_rx_stall_en) begin
    perfmon_smi_stall = 1'b0;
  end
<% } %>

  if(targ_id_err || perfmon_smi_stall) begin
    string log_s = targ_id_err ? "wrong traget ID error injection" : "perfmon smi stall forcing";

    if (u_csr_probe_vif.fault_mission_fault === 0) begin
      `uvm_error(get_full_name(),$sformatf("mission fault should be asserted for %0s", log_s))
    end else if (u_csr_probe_vif.fault_mission_fault === 1) begin
      `uvm_info(get_full_name(),$sformatf("mission fault asserted due to %0s", log_s), UVM_NONE)
    end else if (u_csr_probe_vif.fault_mission_fault === 'hx) begin
      `uvm_error(get_full_name(),$sformatf("mission fault goes unknown for %0s", log_s))
    end
  end

  uvm_config_db#(bit)::set(null,"*","perfmon_smi_stall",perfmon_smi_stall);
  //if (!(inj_cntl > 1) && !(targ_id_err) && (timeout_uc_err == 0) && m_env.m_scb.num_smi_uncorr_err == 0 && m_env.m_scb.num_smi_parity_err == 0 && !($test$plusargs("uncorr_error_inj_pcnt") || $test$plusargs("parity_error_inj_pcnt") || $test$plusargs("test_unit_duplication")) && (!smi_rx_stall_en)) begin
  //  if (u_csr_probe_vif.fault_mission_fault !== 0) begin
  //    `uvm_error(get_full_name(),"mission fault should be zero at the end of the test for no error injection")
  //  end
  //  if (u_csr_probe_vif.fault_latent_fault !== 0) begin
  //    `uvm_error(get_full_name(),"latent fault should be zero at the end of the test for no error injection")
  //  end
  //end
<% } %>
  endfunction: check_phase

//Report Phase.
function void chi_aiu_base_test::report_phase(uvm_phase phase);
    string spkt;
    uvm_report_server urs;
    int error_count, fatal_count;

    //run_report(phase);
    urs         = uvm_report_server::get_server();
    error_count = urs.get_severity_count(UVM_ERROR);
    fatal_count = urs.get_severity_count(UVM_FATAL);
    if ((error_count != 0) | (fatal_count != 0)) begin
        `uvm_info("TEST", "\n ===========\nUVM FAILED!\n===========", UVM_NONE);
    end else begin
        `uvm_info("TEST", "\n===========\nUVM PASSED!\n===========", UVM_NONE);
    end
endfunction : report_phase

