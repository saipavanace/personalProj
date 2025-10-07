<%
    //all csr sequences
    var csr_seqs = [
        "dve_csr_dveuedr_TransErrDetEn_seq",
        "dve_csr_dveueir_TransErrInt_seq",
        "dve_csr_dveuedr_noDetEn_seq",    
        "dve_csr_dveuelr_seq",    
        "uvm_reg_hw_reset_seq",
	"dve_sw_TransErrDetEn_seq",
        "uvm_reg_bit_bash_seq"
        //TODO seqs from dve_ral_csr_seq.sv
    ];
%>


import common_knob_pkg::*;


class dve_targt_id_err_test extends dve_base_test;
  `uvm_component_utils(dve_targt_id_err_test)

  uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
  virtual <%=obj.BlockId%>_apb_if      m_apb_if;

  dve_env_config           m_env_cfg;
  dve_env               m_dve_env;

  dve_csr_init_seq csr_init_seq;
  dve_targt_id_err_seq               m_dve_targt_id_err_seq;

  <% if (obj.useResiliency) { %>
    virtual dve_csr_probe_if u_csr_probe_vif;
    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event ev_bist_reset_done = ev_pool.get("bist_reset_done");
  <% } %>
  // sequence knobs
  string name = "dve_targt_id_err_test";
  string  k_csr_seq   = "";
  int m_timeout_us;
  bit test_done, test_done_run_pd; //pd: phase objection drop

  function new(string _name = "dve_targt_id_err_test", uvm_component parent = null);
    super.new(_name, parent);
    name = _name;
  endfunction // new

  function bit plusarg_get_str(ref string field, input string name);
      string arg_value;
      // 
      if (clp.get_arg_value({"+",name,"="}, arg_value)) begin
          field = arg_value;
          `uvm_info(name, $sformatf("plusarg got \t%s \t== \t%p",name, field), UVM_MEDIUM);
          return 1;
      end
      else
          return 0;
  endfunction : plusarg_get_str

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(name, "build_phase", UVM_NONE);

    // env config
    m_env_cfg = dve_env_config::type_id::create("m_env_cfg");

    m_env_cfg.disable_sb();

    // SMI agent config
    m_env_cfg.m_smi_agent_cfg = smi_agent_config::type_id::create("m_smi_agent_cfg");
    m_env_cfg.m_smi_agent_cfg.active = UVM_ACTIVE;

    m_env_cfg.m_apb_agent_cfg = apb_agent_config::type_id::create("m_apb_agent_config",  this);
    
    m_env_cfg.m_q_chnl_agent_cfg = q_chnl_agent_config::type_id::create("m_q_chnl_agent_config",  this);
  
    if (!uvm_config_db#(virtual <%=obj.BlockId%>_q_chnl_if)::get(.cntxt( this ),
                                        .inst_name( "" ),
                                        .field_name( "m_q_chnl_if" ),
                                        .value(m_env_cfg.m_q_chnl_agent_cfg.m_vif ))) begin
        `uvm_error(name, "m_q_chnl_if not found")
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
        `uvm_error(name, "m_apb_if not found")
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

  <% if (obj.useResiliency) { %>
    if(!uvm_config_db#(virtual dve_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_vif)) begin
      `uvm_error({"fault_injector_checker_", get_name()},{"virtual interface must be set  for :",get_full_name(),".vif"})
    end
  <% } %>
  endfunction // build_phase

function void connect_phase(uvm_phase phase);
   super.connect_phase(phase);

endfunction : connect_phase

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.set_timeout(m_timeout_us);
  endfunction // end_of_elaboration_phase

  task run_phase(uvm_phase phase);
    uvm_reg_sequence csr_seq;
    super.run_phase(phase);
    `uvm_info(name, "run_phase", UVM_NONE);

    void'(plusarg_get_str(k_csr_seq,"k_csr_seq"));

    //instantiate the csr seq
   <% if(obj.testBench == 'dve') { %>
   `ifndef VCS
    if (k_csr_seq) begin
   `else // `ifndef VCS
    if (k_csr_seq != "") begin
   `endif // `ifndef VCS ... `else ... 
    <% } else {%>
    if (k_csr_seq) begin
    <% } %>
    <% for (i in csr_seqs) { %>
        if (k_csr_seq == "<%=csr_seqs[i]%>")
            csr_seq = <%=csr_seqs[i]%>::type_id::create("csr_seq"); 
    <% } %>
        csr_seq.model = m_dve_env.m_regs;
    end

    csr_init_seq = dve_csr_init_seq::type_id::create("csr_init_seq");
    csr_init_seq.model = m_dve_env.m_regs;

    m_dve_targt_id_err_seq = dve_targt_id_err_seq::type_id::create("m_dve_targt_id_err_seq");
    m_dve_targt_id_err_seq.m_smi_virtual_seqr = m_dve_env.m_smi_agent.m_smi_virtual_seqr;
//    m_dve_targt_id_err_seq.m_dve_unit_args = m_dve_unit_args;
    //exclude from automated register testing unit ids, which are passed from tb_top
    uvm_resource_db#(bit)::set({"REG::",m_dve_env.m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUIDR.get_full_name()}, "NO_REG_TESTS", 1,this);
    uvm_resource_db#(bit)::set({"REG::",m_dve_env.m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUFUIDR.get_full_name()}, "NO_REG_TESTS", 1,this);
    uvm_resource_db#(bit)::set({"REG::",m_dve_env.m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUINFOR.get_full_name()}, "NO_REG_TESTS", 1,this);
    if(k_csr_seq == "uvm_reg_bit_bash_seq") begin
      uvm_resource_db#(bit)::set({"REG::",m_dve_env.m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.get_full_name()}, "NO_REG_TESTS", 1,this);
    end

    phase.raise_objection(this, "CSR init");
<% if(obj.useResiliency) { %>
    ev_bist_reset_done.wait_trigger();
<% } %>
    `uvm_info(name, "Start CSR init", UVM_NONE)
    csr_init_seq.start(m_dve_env.m_apb_agent.m_apb_sequencer);
    phase.drop_objection(this, "CSR init");

    fork
        begin
            phase.raise_objection(this, "dve_targt_id_err_test");
            #400ns;
            `uvm_info(name, "Start DVE sequence", UVM_NONE)
            m_dve_targt_id_err_seq.start(null);
            `uvm_info(name, "Done DVE sequence", UVM_NONE)
            phase.phase_done.set_drain_time(this,50us);
            phase.drop_objection(this, "dve_targt_id_err_test");
        end
        <% if(obj.testBench == 'dve') { %>
       `ifndef VCS
        if (k_csr_seq) begin
       `else // `ifndef VCS
        if (k_csr_seq != "") begin
       `endif // `ifndef VCS ... `else ... 
        <% } else {%>
        if (k_csr_seq) begin
        <% } %>
            `uvm_info(name, $sformatf("Start %s sequence", k_csr_seq), UVM_NONE)
            phase.raise_objection(this, $sformatf("Start CSR %s sequence", k_csr_seq));
            //note: inheritance allows us to get child seq behavior without casing back to child type.
            csr_seq.start(m_dve_env.m_apb_agent.m_apb_sequencer);
            `uvm_info(name, $sformatf("Done %s sequence", k_csr_seq), UVM_NONE)
            phase.drop_objection(this, $sformatf("Finish CSR %s sequence", k_csr_seq));
        end
    join

    // ready to finish stimulus
    test_done = 1'b1;
    if(test_done_run_pd)
      phase.drop_objection(this);

  endtask // run_phase

  function void check_phase(uvm_phase phase);
    bit targ_id_err;
    super.check_phase(phase);
<%  if (obj.useResiliency) { %>
    //To check mission fault for wrong_target_id/memory uncorrectable error injection(Ncore3.0/section 5.4)
    if($test$plusargs("inject_cmd_trgt_id_err") || $test$plusargs("inject_dtw_trgt_id_err") || $test$plusargs("inject_snp_trgt_id_err") || $test$plusargs("inject_str_trgt_id_err") || $test$plusargs("inject_sys_trgt_id_err") || $test$plusargs("inject_dtw_dbg_trgt_id_err")) begin
      targ_id_err = 1'b1;
    end
    if(targ_id_err) begin
      string log_s = "wrong traget ID error injection";

      if (u_csr_probe_vif.fault_mission_fault === 0) begin
        `uvm_error(get_full_name(),$sformatf("mission fault should be asserted for %0s", log_s))
      end else if (u_csr_probe_vif.fault_mission_fault === 1) begin
        `uvm_info(get_full_name(),$sformatf("mission fault asserted due to %0s", log_s), UVM_NONE)
      end else if (u_csr_probe_vif.fault_mission_fault === 'hx) begin
        `uvm_error(get_full_name(),$sformatf("mission fault goes unknown for %0s", log_s))
      end
    end
<% } %>
  endfunction

  function void phase_ready_to_end (uvm_phase phase);
    if(!test_done && phase.get_name == "run") begin
      phase.raise_objection(this);
      fork
        test_done_run_pd = 1'b1;
      join_none
    end
  endfunction

  function void report_phase(uvm_phase phase);
    uvm_report_server urs;
    int uvm_err_cnt, uvm_fatal_cnt;
  
    urs = uvm_report_server::get_server();
    uvm_err_cnt = urs.get_severity_count(UVM_ERROR);
    uvm_fatal_cnt = urs.get_severity_count(UVM_FATAL);

    if((uvm_err_cnt != 0) || (uvm_fatal_cnt != 0))
      `uvm_info(name, "\n ============ \n UVM FAILED!\n ============", UVM_NONE)
    else
      `uvm_info(name, "\n ============ \n UVM PASSED!\n ============", UVM_NONE)
  endfunction // report_phase
endclass // dve_targt_id_err_test
