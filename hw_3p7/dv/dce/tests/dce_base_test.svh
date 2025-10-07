//**********************************************************
// DCE Base Test
// Class Decription: All tests extend from this test class
// All basic test initialization done in this class
//*********************************************************

<% if(obj.testBench == 'dce') { %>
 `ifdef VCS 
// Add for UVM-1.2 compatibility
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



class dce_base_test extends uvm_test;

  //perf monitor
  `macro_perf_cnt_test_all_declarations

  //environment class 	
  dce_env           m_env;

  //configuration objects
  dce_env_config         m_env_cfg;

  //misc objects
  dce_unit_args          m_args;
  addr_trans_mgr         m_addr_mgr;
  dce_report_test_status m_reporter;
  string arg_value;
  bit flag = 0;
  bit k_smi_cov_en = 1;
  virtual  <%=obj.BlockId%>_probe_if u_csr_probe_vif;

  //properties
  longint m_timeout_ns;

  <% var filter_secded = 0; %>
  <% var filter_parity = 0; %>

  <% obj.SnoopFilterInfo.forEach(function sfways(item,index){ %>
    <%if(item.TagFilterErrorInfo.fnErrDetectCorrect === "SECDED") {%>
       <% filter_secded = 1; %>
  <% } %>
  <% }); %>

  <% obj.SnoopFilterInfo.forEach(function sfways(item,index){ %>
    <%if(item.TagFilterErrorInfo.fnErrDetectCorrect === "PARITY") {%>
      <% filter_parity = 1; %>
  <% } %>
  <% }); %>

  <% if (filter_secded == 1) { %>
    bit filter_secded = 1;
  <% } else { %>
    bit filter_secded = 0;
  <% } %>

  <% if (filter_parity == 1) { %>
     bit filter_parity = 1;
  <% } else { %>
     bit filter_parity = 0;
  <% } %>

  //seq handles
  dce_virtual_seq   m_vseq;
  uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();

  //Assign knobs to the assoc array nad pass it over to virtual seq
  //This is done to simplify the process of adding new knobs
  int test_knobs[string];

<% if(obj.INHOUSE_APB_VIP) { %>
  apb_agent_config  m_apb_cfg;
<% } %>
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
   string k_csr_seq = "";
  `uvm_component_utils_begin(dce_base_test)
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
<% } %>
    `uvm_field_string(k_csr_seq                          ,UVM_STRING);
  `uvm_component_utils_end

  extern function new(string name = "dce_base_test", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void start_of_simulation_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);
  extern function void check_phase(uvm_phase phase);

  //Utility functions
  extern function void heartbeat(uvm_phase phase);
  extern function void assign_sqr_and_misc_handles(uvm_phase phase);
  extern function void configure_smi_agent(smi_agent_config cfg);
  extern function void assign_smi_vif();
  extern function void assign_probe_vif();
  extern function void configure_smi_port_delays();
  extern virtual task reset_phase(uvm_phase phase); 
endclass: dce_base_test


//*************************************
// Default UVM Methods
//*************************************

function dce_base_test::new( string name = "dce_base_test", uvm_component parent = null);
  super.new(name, parent);
  m_timeout_ns = 1000000;
endfunction: new

task dce_base_test::reset_phase(uvm_phase phase); 

  super.reset_phase(phase);

  <%if(obj.DceInfo[obj.Id].CMDOverflowBufInSRAM == true) { %>

  if ($test$plusargs("inject_sram_skid_single_err") && filter_parity) begin
    u_csr_probe_vif.inject_single_error(); 
    `uvm_info("SKIDBUFERROR","Single bit error injection enabled in SRAM skid buffer with PARITY protection from reset_phase",UVM_HIGH);
  end  

  if ($test$plusargs("inject_sram_skid_double_err") && filter_secded) begin
    u_csr_probe_vif.inject_double_error();
    `uvm_info("SKIDBUFERROR","Single bit error injection enabled in SRAM skid buffer with PARITY protection from reset_phase",UVM_HIGH);
  end  

  if ($test$plusargs("inject_sram_skid_addr_err")) begin
    u_csr_probe_vif.inject_addr_error();
    `uvm_info("SKIDBUFERROR","Address error injection enabled in SRAM skid buffer from reset_phase",UVM_HIGH);
  end  

  <% } %> 
    
endtask : reset_phase

function void dce_base_test::build_phase(uvm_phase phase);

  super.build_phase(phase);
  
  //`uvm_info("base_test",$sformatf("build_phase"),UVM_NONE);
  //env configuration
  m_env_cfg = dce_env_config::type_id::create("m_env_cfg", this);
  m_env_cfg.randomize();
  m_env_cfg.m_probe_agent_delay_export = 1;

  //smi agent configuration
  m_env_cfg.m_smi_agent_cfg = smi_agent_config::type_id::create("m_smi_agent_cfg", this);
  if(clp.get_arg_value("+k_smi_cov_en=", arg_value)) begin
    k_smi_cov_en = arg_value.atoi();
  end
  m_env_cfg.m_smi_agent_cfg.cov_en = k_smi_cov_en;
  configure_smi_agent(m_env_cfg.m_smi_agent_cfg);
  assign_smi_vif();
  assign_probe_vif();
  
  //put the smi_agent_config object into configuration database since the smi_agent code looks for this.
  uvm_config_db#(smi_agent_config)::set(.cntxt( null ),
                                      .inst_name( "*" ),
                                      .field_name( "smi_agent_config" ),
                                      .value( m_env_cfg.m_smi_agent_cfg ));

  m_env_cfg.m_q_chnl_agent_cfg = q_chnl_agent_config::type_id::create("m_q_chnl_agent_config",  this);

  if (!uvm_config_db#(virtual <%=obj.BlockId%>_q_chnl_if)::get(.cntxt( this ),
                                      .inst_name( "" ),
                                      .field_name( "m_q_chnl_if" ),
                                      .value(m_env_cfg.m_q_chnl_agent_cfg.m_vif ))) begin
      `uvm_error(get_name(), "m_q_chnl_if not found")
  end

  //Get command-line args and put it in config db
  m_args = dce_unit_args::type_id::create("m_args");
  m_args.grab_and_parse_args_from_cmdline(m_env_cfg);

  uvm_config_db#(dce_unit_args)::set(.cntxt( null ),
                                      .inst_name( "*" ),
                                      .field_name( "dce_args" ),
                                      .value( m_args ));

//  `uvm_info("base_test",$sformatf("build_phase:%0s", m_args.k_cmd_rd_cln_pct.convert2string()),UVM_LOW);
//  `uvm_info("base_test",$sformatf("build_phase:%0s", m_args.k_cmd_rd_vld_pct.convert2string()),UVM_LOW); 
  //`uvm_info("base_test",$sformatf("m_timeout_ns:%0d before_build_phase:%0s", m_timeout_ns, m_args.k_hb_timeout.convert2string()),UVM_LOW);
   //m_timeout_ns = m_args.k_hb_timeout.get_value();
   configure_smi_port_delays();
  //`uvm_info("base_test",$sformatf("m_timeout_ns:%0d after_build_phase:%0s", m_timeout_ns, m_args.k_hb_timeout.convert2string()),UVM_LOW);
  //`uvm_info("base_test", $sformatf("before m_timeout_ns = %0d", m_timeout_ns), UVM_LOW);
  if (clp.get_arg_value("+k_hb_timeout=", arg_value)) begin
   	 m_timeout_ns = longint'(arg_value.atoi());
  end
  //`uvm_info("base_test", $sformatf("after m_timeout_ns = %0d", m_timeout_ns), UVM_LOW);

  //`uvm_info("base_test",$sformatf("build_phase:%0s", m_args.k_slow_dmi_rsp_port.convert2string()),UVM_LOW);
  //`uvm_error("base_test",$sformatf("Intentionally error out"));
  
  //User knobs for ADDRESS manager configuration
  m_addr_mgr = addr_trans_mgr::get_instance();
  m_addr_mgr.gen_memory_map();

  //put the env config object into configuration database.
  uvm_config_db#(dce_env_config)::set(.cntxt( null ),
                                      .inst_name( "*" ),
                                      .field_name( "dce_env_config" ),
                                      .value( m_env_cfg ));

  //create the env
  m_env = dce_env::type_id::create("m_env", this);

  //create the reporter and pass handle to the env
  m_reporter = dce_report_test_status::type_id::create("m_reporter");
  m_reporter.m_env = this.m_env;

  if (clp.get_arg_value("+k_csr_seq=", arg_value)) begin
     k_csr_seq = arg_value;
     $display("k_csr_seq = %s",k_csr_seq);
     flag = 1;
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
<% if(obj.INHOUSE_APB_VIP) { %>
   m_apb_cfg = apb_agent_config::type_id::create("m_apb_cfg", this);

   if (!uvm_config_db#(virtual <%=obj.BlockId%>_apb_if)::get(.cntxt( this ),
                                        .inst_name( "*" ),
                                        .field_name( "apb_if" ),
                                        .value( m_apb_cfg.m_vif ))) begin
      `uvm_error("ioaiu_base_test", "APB if not found")
   end

  m_env_cfg.m_apb_cfg = m_apb_cfg;
<% } %>
   if(!uvm_config_db#(virtual  <%=obj.BlockId%>_probe_if )::get(null, get_full_name(), "probe_vif",u_csr_probe_vif)) begin
       `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
   end

endfunction: build_phase

function void dce_base_test::start_of_simulation_phase(uvm_phase phase);
    <% if(obj.testBench == 'dce') { %>
 `ifdef VCS 
    my_report_server my_server = new();
  `endif
<% } %>
    super.start_of_simulation_phase(phase);

<% if(obj.testBench == 'dce') { %>
 `ifdef VCS 
    uvm_report_server::set_server( my_server );
  `endif
<% } %>

    heartbeat(phase);
endfunction: start_of_simulation_phase

function void dce_base_test::report_phase(uvm_phase phase);
    //`uvm_info("base_test",$sformatf("report_phase"),UVM_NONE);
   
    m_reporter.report_results();
    m_reporter.print_status();
endfunction: report_phase

//------------------------------------------------------------------------------
// check Phase
//------------------------------------------------------------------------------
function void dce_base_test::check_phase(uvm_phase phase);
<% var filter_parity = 0; %>
<% obj.SnoopFilterInfo.forEach(function sfways(item,index){ %>
  <%if(item.TagFilterErrorInfo.fnErrDetectCorrect === "PARITY") {%>
      <% filter_parity = 1; %>
  <% } %>
<% }); %>
<% if (filter_parity == 1) { %>
  bit filter_parity = 1;
<% } else { %>
  bit filter_parity = 0;
<% } %>
  int inj_cntl;
  $value$plusargs("inj_cntl=%d",inj_cntl);
  <% if(obj.useResiliency) { %>
  if (m_env_cfg.has_scoreboard) begin
    if (!(inj_cntl > 1) && 
  	  m_env.m_dce_scb.num_smi_uncorr_err == 0 && 
  	  m_env.m_dce_scb.num_smi_parity_err == 0 && 
  	  !($test$plusargs("uncorr_error_inj_pcnt") || $test$plusargs("parity_error_inj_pcnt") || $test$plusargs("test_unit_duplication")) && 
  	  !($test$plusargs("dir_double_bit_direct_tag_error_test") || $test$plusargs("dir_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("dir_multi_blk_double_tag_direct_error_test")) && 
  	  !($test$plusargs("dir_single_bit_tag_direct_error_test") && filter_parity) && 
  	  !($test$plusargs("dir_multi_blk_single_tag_direct_error_test") && filter_parity) &&
  	  !($test$plusargs("mission_fault_time_out_test")) &&
  	  !($test$plusargs("wrong_cmdreq_target_id")) &&
  	  !($test$plusargs("wrong_sysreq_target_id")) &&
  	  !($test$plusargs("wrong_sysrsp_target_id")) &&
  	  !($test$plusargs("wrong_updreq_target_id")) &&
  	  !($test$plusargs("wrong_snprsp_target_id")) &&
  	  !($test$plusargs("wrong_strrsp_target_id")) && 
  	  !($test$plusargs("wrong_rbureq_target_id")) && 
  	  !($test$plusargs("wrong_rbrsp_target_id"))  && 
	  !($test$plusargs("wrong_mrdrsp_target_id"))
  	) begin
      if (u_csr_probe_vif.fault_mission_fault !== 0) begin
        `uvm_error(get_full_name(),"mission fault should be zero at end of test for no error injection")
      end
      if (u_csr_probe_vif.fault_latent_fault !== 0) begin
        `uvm_error(get_full_name(),"latent fault should be zero at end of test for no error injection")
      end
    end
  end
  if (inj_cntl > 1 || ($test$plusargs("dir_double_bit_direct_tag_error_test") || $test$plusargs("dir_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("dir_multi_blk_double_tag_direct_error_test")) || ($test$plusargs("dir_single_bit_tag_direct_error_test") && filter_parity) || ($test$plusargs("dir_multi_blk_single_tag_direct_error_test") && filter_parity)) begin
    if (u_csr_probe_vif.fault_mission_fault === 0) begin
      `uvm_error(get_full_name(),"mission fault should be asserted for SF memory uncrroctable error injection")
    end else if (u_csr_probe_vif.fault_mission_fault === 1) begin
      `uvm_info(get_full_name(),"mission fault asserted due to SF memory uncrroctable error injection",UVM_NONE)
    end else if (u_csr_probe_vif.fault_mission_fault === 'hx) begin
      `uvm_error(get_full_name(),"mission fault goes unknown for SF memory uncrroctable error injection")
    end
  end
  //Ncore 3.0 system specs section 5.4 Resiliency Related Error Logging and interrupt, mission fault will be triggered for wrong target ID error.
  if (($test$plusargs("wrong_cmdreq_target_id")) ||
  	  ($test$plusargs("wrong_sysreq_target_id")) ||
  	  ($test$plusargs("wrong_sysrsp_target_id")) ||
  	  ($test$plusargs("wrong_updreq_target_id")) ||
  	  ($test$plusargs("wrong_snprsp_target_id")) ||
  	  ($test$plusargs("wrong_strrsp_target_id")) || 
  	  ($test$plusargs("wrong_rbureq_target_id")) || 
  	  ($test$plusargs("wrong_rbrsp_target_id"))  || 
	  ($test$plusargs("wrong_mrdrsp_target_id"))) begin
		if (u_csr_probe_vif.fault_mission_fault === 0) begin
		  `uvm_error(get_full_name(),"mission fault should be asserted for wrong_target_id error")
		end else if (u_csr_probe_vif.fault_mission_fault === 1) begin
		  `uvm_info(get_full_name(),"mission fault asserted due to wrong_target_id error",UVM_NONE)
		end else if (u_csr_probe_vif.fault_mission_fault === 'hx) begin
		  `uvm_error(get_full_name(),"mission fault goes unknown for wrong_target_id error")
		end
	end
  <% } %>
endfunction: check_phase

//***************************
// Utility Functions
//***************************
function void dce_base_test::heartbeat(uvm_phase phase);
    uvm_callbacks_objection cb;
    uvm_heartbeat hb;
    uvm_event e;
    uvm_component comp_q[$];
    dce_timeout_catcher catcher;
    uvm_phase run_phase;

    e = new("e");
    run_phase = phase.find_by_name("run", 0);
    catcher = dce_timeout_catcher::type_id::create("catcher", this);
    catcher.phase      = run_phase;
    catcher.m_reporter = m_reporter;
    uvm_report_cb::add(null, catcher);
    
    if(!$cast(cb, run_phase.get_objection()))
        `uvm_fatal("Run", "run phase objection type isn't of type uvm_callbacks_objection. you need to define UVM_USE_CALLBACKS_OBJECTION_FOR_TEST_DONE!");

    hb = new("activity_heartbeat", this, cb);
    uvm_top.find_all("*", comp_q, this);

    hb.set_mode(UVM_ANY_ACTIVE);
    hb.set_heartbeat(e, comp_q);
   
   // foreach(comp_q[idx])begin
   // 	`uvm_info("heartbeat",$sformatf("comp_q =%s",comp_q[idx].get_full_name()),UVM_LOW);
   // end
   //`uvm_info("heartbeat",$sformatf("m_timeout_ns =%0d", m_timeout_ns),UVM_LOW);
   
    fork begin
        forever begin
            #(m_timeout_ns*1ns) e.trigger();
        end
    end
    join_none 

endfunction: heartbeat

function void dce_base_test::configure_smi_agent(smi_agent_config cfg);
	cfg.active = UVM_ACTIVE;	


endfunction: configure_smi_agent

//********************************************************************************
function void dce_base_test::assign_sqr_and_misc_handles(uvm_phase phase);
    m_vseq.m_phase     = phase;
    m_vseq.m_unit_args = m_args;
    m_vseq.m_scb       = m_env.m_dce_scb;
    
    <% for (var i = 0; i < obj.nSmiRx; i++) { %>
        <% var z = obj.smiPortParams.rx[i].name[obj.smiPortParams.rx[i].name.length-2]; %>
		<% for (var j = 0; j < obj.smiPortParams.rx[i].params.fnMsgClass.length; j++) { %>
			m_vseq.m_smi_sqr_tx_hash["<%=obj.smiPortParams.rx[i].params.fnMsgClass[j]%>"] = m_env.m_smi_agent.m_smi<%=z%>_tx_seqr;
		<% } %>
    <% } %>
    
    <% for (var i = 0; i < obj.nSmiTx; i++) { %>
        <% var z = obj.smiPortParams.tx[i].name[obj.smiPortParams.tx[i].name.length-2]; %>
		<% for (var j = 0; j < obj.smiPortParams.tx[i].params.fnMsgClass.length; j++) { %>
			m_vseq.m_smi_sqr_rx_hash["<%=obj.smiPortParams.tx[i].params.fnMsgClass[j]%>"] = m_env.m_smi_agent.m_smi<%=z%>_rx_seqr;
		<% } %>
    <% } %>

endfunction: assign_sqr_and_misc_handles

//********************************************************************************
function void dce_base_test::assign_smi_vif();

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

//TX ports from TB presepctive
<% for (var i = 0; i < obj.nSmiRx; i++) { %>
  m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config =
    smi_port_config::type_id::create("m_smi<%=i%>_tx_port_config");

  m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.m_vif = m_env_cfg.m_smi<%=i%>_tx_vif;
<% } %>

  //RX ports from TB presective
<% for (var i = 0; i < obj.nSmiTx; i++) { %>
  m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config =
    smi_port_config::type_id::create("m_smi<%=i%>_rx_port_config");

  m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.m_vif = m_env_cfg.m_smi<%=i%>_rx_vif;
<% } %>

endfunction: assign_smi_vif

//********************************************************************************
function void dce_base_test::assign_probe_vif();
  if (!uvm_config_db #(virtual <%=obj.BlockId%>_probe_if)::get(
    .cntxt(this),
    .inst_name(""),
    .field_name("probe_vif"),
    .value(m_env_cfg.m_probe_vif))) begin

    `uvm_fatal(get_name(), "unable to find probe vif in configuration db")
  end

endfunction: assign_probe_vif

//********************************************************************************
function void dce_base_test::configure_smi_port_delays();

  if (m_args == null) begin
    `uvm_fatal(get_name(), "m_args is null")

  end else if (m_args.k_slow_dmi_rsp_port == null) begin
    `uvm_fatal(get_name(), "k_slow_dmi_rsp_port port is null")

  end

  if ($test$plusargs("time_out_test")) begin
    `uvm_info("DCE_BASE_TEST", "Delay is added on SNPreq SMI port for time out error test", UVM_LOW)
    m_env_cfg.m_smi_agent_cfg.m_smi0_rx_port_config.k_slow_port.set_value(1);
    m_env_cfg.m_smi_agent_cfg.m_smi0_rx_port_config.k_burst_pct.set_value(0);
    m_env_cfg.m_smi_agent_cfg.m_smi0_rx_port_config.k_delay_min.set_value(10000);
    m_env_cfg.m_smi_agent_cfg.m_smi0_rx_port_config.k_delay_max.set_value(10500);
  end

  //slow down the rsp port connected to dmi -- affects ,mrdrsp, rbrsp, rbureq
  if (m_args.k_slow_dmi_rsp_port.get_value() == 1) begin 
    `uvm_info("DCE_BASE_TEST", "k_slow_dmi_rsp_port is enabled credit_chk tests", UVM_LOW)
  	m_env_cfg.m_smi_agent_cfg.m_smi2_tx_port_config.k_slow_port.set_value(1);
  	m_env_cfg.m_smi_agent_cfg.m_smi2_tx_port_config.k_delay_min.set_value(10000);
  	m_env_cfg.m_smi_agent_cfg.m_smi2_tx_port_config.k_delay_max.set_value(10000);
  end 
  
  if ($test$plusargs("k_slow_smi1_rx_port")) begin 
    `uvm_info("DCE_BASE_TEST", "k_slow_smi_rx1_port is enabled -slows down TB acceptance of cmdrsp and updrsp", UVM_LOW)
    m_env_cfg.m_smi_agent_cfg.m_smi1_rx_port_config.k_burst_pct.set_value(0);
  	m_env_cfg.m_smi_agent_cfg.m_smi1_rx_port_config.k_delay_min.set_value(200);
  	m_env_cfg.m_smi_agent_cfg.m_smi1_rx_port_config.k_delay_max.set_value(200);
  end 
  
  if ($test$plusargs("k_slow_smi2_rx_port")) begin 
    `uvm_info("DCE_BASE_TEST", "k_slow_smi_rx2_port is enabled -slows down TB acceptance of mrdreq, rbreq, rbursp", UVM_LOW)
    m_env_cfg.m_smi_agent_cfg.m_smi2_rx_port_config.k_burst_pct.set_value(0);
  	m_env_cfg.m_smi_agent_cfg.m_smi2_rx_port_config.k_delay_min.set_value(100);
  	m_env_cfg.m_smi_agent_cfg.m_smi2_rx_port_config.k_delay_max.set_value(100);
  end 
  
  
  if ($test$plusargs("k_fast_smi0_tx_port")) begin 
    `uvm_info("DCE_BASE_TEST", "k_fast_smi_rx0_port is enabled - speeds up cmdreq and updreq on smi port", UVM_LOW)
    m_env_cfg.m_smi_agent_cfg.m_smi0_tx_port_config.k_burst_pct.set_value(100);
  	m_env_cfg.m_smi_agent_cfg.m_smi0_tx_port_config.k_delay_min.set_value(1);
  	m_env_cfg.m_smi_agent_cfg.m_smi0_tx_port_config.k_delay_max.set_value(1);
  end 
  if ($test$plusargs("k_fast_ports")) begin
    `uvm_info("DCE_BASE_TEST", "k_fast_ports is enabled - speeds up all smi ports", UVM_LOW)
    //m_env_cfg.m_smi_agent_cfg.m_smi0_tx_port_config.k_burst_pct.set_value(80);
  	m_env_cfg.m_smi_agent_cfg.m_smi0_tx_port_config.k_delay_min.set_value(1);
  	m_env_cfg.m_smi_agent_cfg.m_smi0_tx_port_config.k_delay_max.set_value(1);
  	m_env_cfg.m_smi_agent_cfg.m_smi1_rx_port_config.k_delay_min.set_value(1);
  	m_env_cfg.m_smi_agent_cfg.m_smi1_rx_port_config.k_delay_max.set_value(1);
  	m_env_cfg.m_smi_agent_cfg.m_smi2_rx_port_config.k_delay_min.set_value(1);
  	m_env_cfg.m_smi_agent_cfg.m_smi2_rx_port_config.k_delay_max.set_value(1);
  end 

  //always a fast cmd_upd_req_port
  //m_env_cfg.m_smi_agent_cfg.m_smi0_tx_port_config.k_delay_min.set_value(1);
  //m_env_cfg.m_smi_agent_cfg.m_smi0_tx_port_config.k_delay_max.set_value(1);


endfunction: configure_smi_port_delays
