<%
    //all csr sequences
    var csr_seqs = [
        "uvm_reg_hw_reset_seq",
        "uvm_reg_bit_bash_seq"
        //TODO seqs from dii_ral_csr_seq.sv
    ];
%>


import common_knob_pkg::*;


class dve_ral_built_in_test extends dve_base_test;
  `uvm_component_utils(dve_ral_built_in_test)

  uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
  virtual <%=obj.BlockId%>_apb_if      m_apb_if;

  dve_env_config           m_env_cfg;
  dve_env               m_dve_env;

  dve_seq               m_dve_seq;

  // sequence knobs
  string  k_csr_seq   = "";
  int m_timeout_us;

  function new(string name = "dve_ral_built_in_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction // new

  function bit plusarg_get_str(ref string field, input string name);
      string arg_value;
      // 
      if (clp.get_arg_value({"+",name,"="}, arg_value)) begin
          field = arg_value;
          `uvm_info("", $sformatf("plusarg got \t%s \t== \t%p",name, field), UVM_MEDIUM);
          return 1;
      end
      else
          return 0;
  endfunction : plusarg_get_str

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("dve_ral_built_in_test", "build_phase", UVM_NONE);

    // env config
    m_env_cfg = dve_env_config::type_id::create("m_env_cfg");

    // SMI agent config
    m_env_cfg.m_smi_agent_cfg = smi_agent_config::type_id::create("m_smi_agent_cfg");
    m_env_cfg.m_smi_agent_cfg.active = UVM_ACTIVE;

    m_env_cfg.m_apb_agent_cfg = apb_agent_config::type_id::create("m_apb_agent_config",  this);
    
    m_env_cfg.m_q_chnl_agent_cfg = q_chnl_agent_config::type_id::create("m_q_chnl_agent_config",  this);
  
    if (!uvm_config_db#(virtual q_chnl_if)::get(.cntxt( this ),
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
    uvm_reg_sequence csr_seq;

    super.run_phase(phase);
    `uvm_info("dve_ral_built_in_test", "run_phase", UVM_NONE);

    plusarg_get_str(k_csr_seq,"k_csr_seq");

    //instantiate the csr seq
    if (k_csr_seq) begin
    <% for (i in csr_seqs) { %>
        if (k_csr_seq == "<%=csr_seqs[i]%>")
            csr_seq = <%=csr_seqs[i]%>::type_id::create("csr_seq"); 
    <% } %>
        csr_seq.model = m_dve_env.m_regs;
    end

//    m_dve_seq.m_dve_unit_args = m_dve_unit_args;
    //exclude from automated register testing unit ids, which are passed from tb_top
    uvm_resource_db#(bit)::set({"REG::",m_dve_env.m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUIDR.get_full_name()}, "NO_REG_TESTS", 1,this);
    uvm_resource_db#(bit)::set({"REG::",m_dve_env.m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUFUIDR.get_full_name()}, "NO_REG_TESTS", 1,this);
    uvm_resource_db#(bit)::set({"REG::",m_dve_env.m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUINFOR.get_full_name()}, "NO_REG_TESTS", 1,this);
    if(k_csr_seq == "uvm_reg_bit_bash_seq") begin
      uvm_resource_db#(bit)::set({"REG::",m_dve_env.m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.get_full_name()}, "NO_REG_TESTS", 1,this);
    end

    phase.raise_objection(this, "dve_ral_built_in_test");
    `uvm_info("dve_ral_built_in_test", "Start DVE sequence", UVM_NONE)
    csr_seq.start(m_dve_env.m_apb_agent.m_apb_sequencer);
    `uvm_info("dve_ral_built_in_test", "Done DVE sequence", UVM_NONE)
    
    phase.phase_done.set_drain_time(this,500us);
    phase.drop_objection(this, "dve_ral_built_in_test");

  endtask // run_phase

  function void report_phase(uvm_phase phase);
    uvm_report_server urs;
    int uvm_err_cnt, uvm_fatal_cnt;
  
    urs = uvm_report_server::get_server();
    uvm_err_cnt = urs.get_severity_count(UVM_ERROR);
    uvm_fatal_cnt = urs.get_severity_count(UVM_FATAL);

    if((uvm_err_cnt != 0) || (uvm_fatal_cnt != 0))
      `uvm_info("dve_ral_built_in_test", "\n ============ \n UVM FAILED!\n ============", UVM_NONE)
    else
      `uvm_info("dve_ral_built_in_test", "\n ============ \n UVM PASSED!\n ============", UVM_NONE)
  endfunction // report_phase
endclass // dve_ral_built_in_test
