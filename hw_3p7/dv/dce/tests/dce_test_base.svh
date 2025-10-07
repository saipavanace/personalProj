//**********************************************************
// Class Decription: All tests extend from this class
//       This is base test extended from uvm_test
//*********************************************************

class dce_test_base extends uvm_test;

  `uvm_component_utils(dce_test_base)

  //environment class 	
  dce_env           m_env;

  //configuration objects
  dce_env_config         m_env_cfg;
  smi_agent_config       m_smi_cfg;

  dce_unit_args          m_args;
  addr_trans_mgr         m_addr_mgr;
  dce_report_test_status m_reporter;

  //properties
  longint m_timeout_ns;

  //Assign knobs to the assoc array nad pass it over to virtual seq
  //This is done to simplify the process of adding new knobs
  int test_knobs[string];

  extern function new(string name = "dce_test_base", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void start_of_simulation_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern function void report_phase(uvm_phase phase);

  //Utility functions
  extern function void heartbeat(uvm_phase phase);
  extern function void assign_sqr_handles(dce_virtual_base_seq vseq);
  extern virtual function void configure_smi_agent(smi_agent_config cfg);
endclass: dce_test_base


//*************************************
// Default UVM Methods
//*************************************

function dce_test_base::new( string name = "dce_test_base", uvm_component parent = null);
  super.new(name, parent);
  m_timeout_ns = 1000000;
endfunction: new

function void dce_test_base::build_phase(uvm_phase phase);

  super.build_phase(phase);
  
  //env configuration
  m_env_cfg = dce_env_config::type_id::create("m_env_cfg", this);
  
  //smi agent configuration
  m_smi_cfg = smi_agent_config::type_id::create("m_smi_cfg", this);
  configure_smi_agent(m_smi_cfg);

  //pass the smi_agent_config handle to env_cfg
  m_env_cfg.m_smi_agent_cfg = m_smi_cfg;

  m_env_cfg.m_q_chnl_agent_cfg = q_chnl_agent_config::type_id::create("m_q_chnl_agent_config",  this);

  if (!uvm_config_db#(virtual q_chnl_if)::get(.cntxt( this ),
                                      .inst_name( "" ),
                                      .field_name( "m_q_chnl_if" ),
                                      .value(m_env_cfg.m_q_chnl_agent_cfg.m_vif ))) begin
      `uvm_error(get_name(), "m_q_chnl_if not found")
  end
  
  //Get command-line args
  m_args = dce_unit_args::type_id::create("m_args");
  m_args.parse_args(m_env_cfg);

  //User knobs for ADDRESS manager configuration
  m_addr_mgr = addr_trans_mgr::get_instance();
  m_addr_mgr.gen_memory_map();

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

endfunction: build_phase

function void dce_test_base::start_of_simulation_phase(uvm_phase phase);
    heartbeat(phase);
endfunction: start_of_simulation_phase

function void dce_test_base::report_phase(uvm_phase phase);
    m_reporter.report_results();
    m_reporter.print_status();
endfunction: report_phase

task dce_test_base::run_phase(uvm_phase phase);
     //dce_dirutar_blocking_seq m_dirutar;
     dce_virtual_base_seq m_vseq;

     //Setting Drain time
     phase.phase_done.set_drain_time(this, 1000ns);

     m_vseq = dce_virtual_base_seq::type_id::create("m_seq");
     m_vseq.get_misc_handles(phase, m_args);
     m_vseq.get_seqr_handles(
         m_env.m_smi_agent.m_smi0_tx_seqr,
         m_env.m_smi_agent.m_smi0_rx_seqr,
         m_env.m_smi_agent.m_smi1_tx_seqr,
         m_env.m_smi_agent.m_smi1_rx_seqr,
         m_env.m_smi_agent.m_smi2_tx_seqr,
         m_env.m_smi_agent.m_smi2_rx_seqr
     );

     phase.raise_objection(this, "unit_test");
     m_vseq.start(null);
     phase.drop_objection(this, "unit_test");

endtask: run_phase

//***************************
// Utility Functions
//***************************
function void dce_test_base::heartbeat(uvm_phase phase);
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
        `uvm_fatal("Run", "run phase objection type isn't of type
                           uvm_callbacks_objection. you need to define
                           UVM_USE_CALLBACKS_OBJECTION_FOR_TEST_DONE!");

    hb = new("activity_heartbeat", this, cb);
    uvm_top.find_all("*", comp_q, this);

    hb.set_mode(UVM_ANY_ACTIVE);
    hb.set_heartbeat(e, comp_q);
   
    //foreach(comp_q[idx])begin
    //`uvm_info("heatbeat",$sformatf("comp_q =%s",comp_q[idx].get_full_name()),UVM_LOW);
    //end
   
    fork begin
        forever begin
            #(m_timeout_ns*1ns) e.trigger();
        end
    end
    join_none 

endfunction: heartbeat

virtual function void configure_smi_agent(smi_agent_config cfg);
	cfg.active = UVM_ACTIVE;	


endfunction: configure_smi_agent

function void assign_sqr_handles(dce_virtual_base_seq vseq);
   
	vseq.m_smi_cmd_req_port = m_env.m_smi_agent.m_smi0_tx_seqr;
	vseq.m_smi_cmd_rsp_port = m_env.m_smi_agent.m_smi0_rx_seqr;
	vseq.m_smi_snpstr_req_port = m_env.m_smi_agent.m_smi1_tx_seqr;
	vseq.m_smi_snpstr_rsp_port = m_env.m_smi_agent.m_smi1_rx_seqr;
	vseq.m_smi_tgt_req_port = m_env.m_smi_agent.m_smi2_tx_seqr;
	vseq.m_smi_tgt_rsp_port = m_env.m_smi_agent.m_smi2_rx_seqr;

endfunction: assign_sqr_handles

