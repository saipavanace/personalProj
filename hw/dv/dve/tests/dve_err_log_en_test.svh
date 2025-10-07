class dve_err_log_en_test extends dve_base_test;
  `uvm_component_utils(dve_err_log_en_test)

  dve_env_config m_env_cfg;
  dve_env m_dve_env;
//  dve_unit_args m_dve_unit_args;

  dve_csr_init_seq csr_init_seq;
  dve_seq m_dve_seq;

  int m_timeout_us;

  function new(string name = "dve_err_log_en_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction // new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("dve_err_log_en_test", "build_phase", UVM_NONE);

    // env config
    m_env_cfg = dve_env_config::type_id::create("m_env_cfg");

    // SMI agent config
    m_env_cfg.m_smi_agent_cfg = smi_agent_config::type_id::create("m_smi_agent_cfg");
    m_env_cfg.m_smi_agent_cfg.active = UVM_ACTIVE;

    m_env_cfg.m_apb_agent_cfg = apb_agent_config::type_id::create("m_apb_agent_config",  this);

    m_env_cfg.m_q_chnl_agent_cfg = q_chnl_agent_config::type_id::create("m_q_chnl_agent_config",  this);
  
    if (!uvm_config_db#(virtual <%=obj.BlockId%>_q_chnl_if)::get(.cntxt( this ),
                                        .inst_name( "" ),
                                        .field_name( "m_q_chnl_if" ),
                                        .value(m_env_cfg.m_q_chnl_agent_cfg.m_vif ))) begin
        `uvm_error(get_name(), "m_q_chnl_if not found")
    end

    if (!uvm_config_db#(virtual <%=obj.BlockId%>_clock_counter_if)::get(.cntxt( this ),
                                        .inst_name( "" ),
                                        .field_name( "m_clock_counter_if" ),
                                        .value(m_env_cfg.m_clock_counter_vif ))) begin
        `uvm_error(get_name(), "m_clock_counter_if not found")
    end

    // SMI RX/TX interfaces from TB perspective
    <% for (var i = 0; i < obj.nSmiRx; i++) { %>
        if (!uvm_config_db #(virtual dve0_smi_if)::get(
            .cntxt(this),
            .inst_name(""),
            .field_name("m_smi<%=i%>_tx_vif"),
        .value(m_env_cfg.m_smi<%=i%>_tx_vif))) begin

            `uvm_fatal(get_name(), "unable to find m_smi<%=i%>_tx_vif")
        end
    <% } %>

    //SMI RX interface
    <% for (var i = 0; i < obj.nSmiTx; i++) { %>
        if (!uvm_config_db #(virtual dve0_smi_if)::get(
            .cntxt(this),
            .inst_name(""),
            .field_name("m_smi<%=i%>_rx_vif"),
        .value(m_env_cfg.m_smi<%=i%>_rx_vif))) begin

            `uvm_fatal(get_name(), "unable to find m_smi<%=i%>_rx_vif")
        end
    <% } %>

    if (!uvm_config_db#(virtual <%=obj.BlockId%>_apb_if)::get(.cntxt( this ),
                                        .inst_name( "" ),
                                        .field_name( "m_apb_if" ),
                                        .value(m_env_cfg.m_apb_agent_cfg.m_vif ))) begin
        `uvm_error("dve_ral_built_in_test", "m_apb_if not found")
    end

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

    uvm_config_db#(smi_agent_config)::set(
      .cntxt(null),
      .inst_name("*"),
      .field_name("smi_agent_config"),
      .value(m_env_cfg.m_smi_agent_cfg)
    );

    // Get command line args
//    m_dve_unit_args = dve_unit_args::type_id::create("m_dve_unit_args");

    // Put the env config object into configuration database.
    uvm_config_db#(dve_env_config)::set(
      .cntxt(null),
      .inst_name("*"),
      .field_name("dve_env_config"),
      .value(m_env_cfg)
    );
  
    //Create the env
    m_dve_env = dve_env::type_id::create("m_dve_env", this);

    if(!$value$plusargs("k_timeout_us=%0d", m_timeout_us))
        m_timeout_us = 1s; 

  endfunction // build_phase

function void connect_phase(uvm_phase phase);
   super.connect_phase(phase);

endfunction : connect_phase
  
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.set_timeout(m_timeout_us);
  endfunction // end_of_elaboration_phase

  task run_phase(uvm_phase phase);
    dve_csr_dveuedr_noError_seq csr_seq;

    super.run_phase(phase);
    `uvm_info("dve_bringup_test", "run_phase", UVM_NONE);

    csr_init_seq = dve_csr_init_seq::type_id::create("csr_init_seq");
    csr_init_seq.model = m_dve_env.m_regs;

    csr_seq = dve_csr_dveuedr_noError_seq::type_id::create("csr_seq"); 
    csr_seq.model = m_dve_env.m_regs;
      
    m_dve_seq = dve_seq::type_id::create("m_dve_seq");
    m_dve_seq.m_smi_virtual_seqr = m_dve_env.m_smi_agent.m_smi_virtual_seqr;
//    m_dve_seq.m_dve_unit_args = m_dve_unit_args;

    `uvm_info("dve_err_log_en_test", "Start CSR init", UVM_NONE)
    csr_init_seq.start(m_dve_env.m_apb_agent.m_apb_sequencer);

    fork
        begin
            phase.raise_objection(this, "dve_err_log_en_test");
            `uvm_info("dve_err_log_en_test", "Start DVE sequence", UVM_NONE)
            m_dve_seq.m_regs = m_dve_env.m_regs;
            m_dve_seq.start(null);
            `uvm_info("dve_err_log_en_test", "Done DVE sequence", UVM_NONE)
            phase.phase_done.set_drain_time(this,50us);
            phase.drop_objection(this, "dve_err_log_en_test");
        end
        begin
            //note: inheritance allows us to get child seq behavior without casing back to child type.
            csr_seq.start(m_dve_env.m_apb_agent.m_apb_sequencer);
        end
    join_any
  endtask // run_phase

  function void report_phase(uvm_phase phase);
    uvm_report_server urs;
    int uvm_err_cnt, uvm_fatal_cnt;
  
    urs = uvm_report_server::get_server();
    uvm_err_cnt = urs.get_severity_count(UVM_ERROR);
    uvm_fatal_cnt = urs.get_severity_count(UVM_FATAL);

    if((uvm_err_cnt != 0) || (uvm_fatal_cnt != 0))
      `uvm_info("dve_err_log_en_test", "\n ============ \n UVM FAILED!\n ============", UVM_NONE)
    else
      `uvm_info("dve_err_log_en_test", "\n ============ \n UVM PASSED!\n ============", UVM_NONE)
  endfunction // report_phase
endclass // dve_err_log_en_test
