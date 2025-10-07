class dve_qchannel_test extends dve_base_test;
  `uvm_component_utils(dve_qchannel_test)

  dve_env_config m_env_cfg;
  dve_env m_dve_env;
  uvm_event toggle_rstn;
//  dve_unit_args m_dve_unit_args;

  dve_csr_init_seq csr_init_seq;
  dve_seq m_dve_seq;
  q_chnl_seq m_q_chnl_seq;
  virtual <%=obj.BlockId%>_q_chnl_if qc_if;
  int m_timeout_us;

  function new(string name = "dve_qchannel_test", uvm_component parent = null);
    super.new(name, parent);
    uvm_config_db#(virtual <%=obj.BlockId%>_q_chnl_if )::get(.cntxt(null),
                                        .inst_name( "" ),
                                        .field_name( "m_q_chnl_if" ),
                                        .value(qc_if ));
  endfunction // new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("dve_qchannel_test", "build_phase", UVM_DEBUG);

    // env config
    m_env_cfg = dve_env_config::type_id::create("m_env_cfg");
    //m_q_chnl_seq = q_chnl_seq::type_id::create("m_q_chnl_seq");
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

    toggle_rstn = new("toggle_rstn");
    if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                    .inst_name(""),
                                    .field_name( "toggle_rstn" ),
                                    .value( toggle_rstn ))) begin
       `uvm_error("Q-chnl test", "Event toggle_rstn is not found")
    end
    <% for (var i = 0; i < obj.nSmiTx; i++) { %>
      m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_delay_min.set_value(100);
      m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_delay_max.set_value(500);
      m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_burst_pct.set_value(100);
    <% } %>
    <% for (var i = 0; i < obj.nSmiRx; i++) { %>
      m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_delay_min.set_value(1000);
      m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_delay_max.set_value(5000);
      m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_burst_pct.set_value(100);
    <% } %>
      m_env_cfg.m_smi_agent_cfg.m_smi0_tx_port_config.k_burst_pct.set_value(50);
 
  endfunction // build_phase

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.set_timeout(m_timeout_us);
  endfunction // end_of_elaboration_phase

  task run_phase(uvm_phase phase);
      super.run_phase(phase);
      `uvm_info("dve_qchannel_test", "run_phase", UVM_DEBUG);
      run_main(phase);
  endtask
  
  task run_main(uvm_phase phase);

    csr_init_seq = dve_csr_init_seq::type_id::create("csr_init_seq");
    csr_init_seq.model = m_dve_env.m_regs;

    phase.raise_objection(this, "dve_csr_init_seq");
    `uvm_info("dve_qchannel_test", "Start CSR init", UVM_DEBUG)
    csr_init_seq.start(m_dve_env.m_apb_agent.m_apb_sequencer);
    `uvm_info("dve_qchannel_test", "Finished CSR init", UVM_DEBUG)
    phase.drop_objection(this, "dve_csr_init_seq");

//Sanity test
if($test$plusargs("dve_qchannel_sanity_test"))begin 
    
    m_dve_seq = dve_seq::type_id::create("m_dve_seq");
    m_dve_seq.m_smi_virtual_seqr = m_dve_env.m_smi_agent.m_smi_virtual_seqr;
//    m_dve_seq.m_dve_unit_args = m_dve_unit_args;
    m_q_chnl_seq = q_chnl_seq::type_id::create("m_q_chnl_seq");

    phase.raise_objection(this, "dve_qchannel_test");
     `uvm_info("dve_qchannel_test", "Start DVE sequence", UVM_DEBUG)
       m_dve_seq.m_regs = m_dve_env.m_regs;
       m_dve_seq.start(null);
     `uvm_info("dve_qchannel_test", "Done DVE sequence", UVM_DEBUG)
    phase.phase_done.set_drain_time(this,50us);
    phase.drop_objection(this, "dve_qchannel_test");
    
  <% if(obj.DveInfo[obj.Id].usePma) { %>
    phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
     #1000ns;       
     `uvm_info("dvi_qchannel_sanity_test", "Q_SEQ_START",UVM_DEBUG)
       m_q_chnl_seq.start(m_dve_env.m_q_chnl_agent.m_q_chnl_seqr);
     `uvm_info("dvi_qchannel_sanity_test", "Q_SEQ_END",UVM_DEBUG)
     phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
  <% } %>

end

//dve_qchannel_req_during_cmd_test
if($test$plusargs("dve_qchannel_req_during_cmd_test"))begin 
    m_dve_seq = dve_seq::type_id::create("m_dve_seq");
    m_dve_seq.m_smi_virtual_seqr = m_dve_env.m_smi_agent.m_smi_virtual_seqr;
    m_q_chnl_seq = q_chnl_seq::type_id::create("m_q_chnl_seq");
    fork 
    begin
      phase.raise_objection(this, "dve_qchannel_test");
      `uvm_info("dve_qchannel_test", "Start DVE sequence", UVM_DEBUG)
      m_dve_seq.m_regs = m_dve_env.m_regs;
      m_dve_seq.start(null);
      `uvm_info("dve_qchannel_test", "Done DVE sequence", UVM_DEBUG)
      phase.phase_done.set_drain_time(this,50us);
      phase.drop_objection(this, "dve_qchannel_test");
    end
    begin
  <% if(obj.DveInfo[obj.Id].usePma) { %>
     repeat(5) begin
       wait(qc_if.QACTIVE);
       repeat(10)  @(posedge qc_if.clk); ///delay
       phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
       `uvm_info("dve_qchannel_req_during_cmd_test", "Q_SEQ_START",UVM_DEBUG)
         m_q_chnl_seq.start(m_dve_env.m_q_chnl_agent.m_q_chnl_seqr);
       `uvm_info("dve_qchannel_req_during_cmd_test", "Q_SEQ_END",UVM_DEBUG)
        phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
     end
  <% } %>
    end
  join
end

//dve_qchannel_req_between_cmd_test
if($test$plusargs("dve_qchannel_req_between_cmd_test"))begin 
  m_dve_seq = dve_seq::type_id::create("m_dve_seq");
  m_dve_seq.m_smi_virtual_seqr = m_dve_env.m_smi_agent.m_smi_virtual_seqr;
  m_q_chnl_seq = q_chnl_seq::type_id::create("m_q_chnl_seq");
  fork 
     begin
      phase.raise_objection(this, "dve_qchannel_test");
      `uvm_info("dve_qchannel_test", "Start DVE sequence", UVM_DEBUG)
        m_dve_seq.m_regs = m_dve_env.m_regs;
        m_dve_seq.start(null);
      `uvm_info("dve_qchannel_test", "Done DVE sequence", UVM_DEBUG)
      phase.phase_done.set_drain_time(this,50us);
      phase.drop_objection(this, "dve_qchannel_test");
     end
    
     begin
  <% if(obj.DveInfo[obj.Id].usePma) { %>
     #500ns;
      repeat(10) begin
         wait(!qc_if.QACTIVE);
         repeat(10)  @(posedge qc_if.clk); ///delay
         phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
         `uvm_info("dve_qchannel_req_between_cmd_test", "Q_SEQ_START",UVM_DEBUG)
         m_q_chnl_seq.start(m_dve_env.m_q_chnl_agent.m_q_chnl_seqr);
         `uvm_info("dve_qchannel_req_between_cmd_test", "Q_SEQ_END",UVM_DEBUG)
         phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
         wait(qc_if.QACTIVE);
      end
  <% } %>
     end
    join
end

//dve_qchannel_multiple_request_test
if($test$plusargs("dve_qchannel_multiple_request_test"))begin 
    
    m_dve_seq = dve_seq::type_id::create("m_dve_seq");
    m_dve_seq.m_smi_virtual_seqr = m_dve_env.m_smi_agent.m_smi_virtual_seqr;
    m_q_chnl_seq = q_chnl_seq::type_id::create("m_q_chnl_seq");

    fork 
     begin
      phase.raise_objection(this, "dve_qchannel_test");
      `uvm_info("dve_qchannel_test", "Start DVE sequence", UVM_DEBUG)
      m_dve_seq.m_regs = m_dve_env.m_regs;
      m_dve_seq.start(null);
      `uvm_info("dve_qchannel_test", "Done DVE sequence", UVM_DEBUG)
      phase.phase_done.set_drain_time(this,50us);
      phase.drop_objection(this, "dve_qchannel_test");
     end
    
     begin
  <% if(obj.DveInfo[obj.Id].usePma) { %>
     #500ns;
     repeat(50) begin
       wait(!qc_if.QACTIVE);
       repeat(10)  @(posedge qc_if.clk); ///delay
       repeat($urandom_range(2,10)) begin
        phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
        `uvm_info("dve_qchannel_multiple_request_test", "Q_SEQ_START",UVM_DEBUG)
        m_q_chnl_seq.start(m_dve_env.m_q_chnl_agent.m_q_chnl_seqr);
        `uvm_info("dve_qchannel_multiple_request_test", "Q_SEQ_END",UVM_DEBUG)
        phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
        end
        wait(qc_if.QACTIVE);
      end
  <% } %>
     end
    join
end

//dve_qchannel_reset_test
if($test$plusargs("dve_qchannel_reset_test"))begin 
  m_dve_seq = dve_seq::type_id::create("m_dve_seq");
  m_dve_seq.m_smi_virtual_seqr = m_dve_env.m_smi_agent.m_smi_virtual_seqr;
  m_q_chnl_seq = q_chnl_seq::type_id::create("m_q_chnl_seq");
  fork 
     begin
      phase.raise_objection(this, "dve_qchannel_test");
      `uvm_info("dve_qchannel_test", "Start DVE sequence", UVM_DEBUG)
        m_dve_seq.m_regs = m_dve_env.m_regs;
        m_dve_seq.start(null);
      `uvm_info("dve_qchannel_test", "Done DVE sequence", UVM_DEBUG)
      phase.phase_done.set_drain_time(this,50us);
      phase.drop_objection(this, "dve_qchannel_test");
     end
    
     begin
  <% if(obj.DveInfo[obj.Id].usePma) { %>
     #500ns;
      repeat(5) begin
         wait(!qc_if.QACTIVE);
         repeat(10)  @(posedge qc_if.clk); ///delay
         phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
         `uvm_info("dve_qchannel_reset_test", "Q_SEQ_START",UVM_DEBUG)
         m_q_chnl_seq.start(m_dve_env.m_q_chnl_agent.m_q_chnl_seqr);
         `uvm_info("dve_qchannel_reset_test", "Q_SEQ_END",UVM_DEBUG)
         phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
         wait(qc_if.QACTIVE);
      end
     end
    begin
    repeat(1) begin
        wait(!qc_if.QACCEPTn && !qc_if.QREQn && !qc_if.QACTIVE);
        repeat(2)@(posedge qc_if.clk); 
        `uvm_info("dve_qchannel_test", "Toggling RESET", UVM_NONE)
        toggle_rstn.trigger();
         #30ns;//repeat(3)@(posedge qc_if.clk); 
        toggle_rstn.trigger();
        wait(qc_if.QACTIVE);

        `uvm_info("dve_qchannel_test", "Restart CSR init", UVM_NONE)
        csr_init_seq.start(m_dve_env.m_apb_agent.m_apb_sequencer);
        `uvm_info("dve_qchannel_test", "Finished CSR init", UVM_NONE)

	// reset SNPreq msg_id running counter
        m_dve_env.m_dve_sb.snpreq_msg_id = 0;
    end
  <% } %>
  end 
  join
end

  endtask // run_main

  function void report_phase(uvm_phase phase);
    uvm_report_server urs;
    int uvm_err_cnt, uvm_fatal_cnt;
  
    urs = uvm_report_server::get_server();
    uvm_err_cnt = urs.get_severity_count(UVM_ERROR);
    uvm_fatal_cnt = urs.get_severity_count(UVM_FATAL);

    if((uvm_err_cnt != 0) || (uvm_fatal_cnt != 0))
      `uvm_info("dve_qchannel_test", "\n ============ \n UVM FAILED!\n ============", UVM_DEBUG)
    else
      `uvm_info("dve_qchannel_test", "\n ============ \n UVM PASSED!\n ============", UVM_DEBUG)
  endfunction // report_phase
endclass // dve_qchannel_test

