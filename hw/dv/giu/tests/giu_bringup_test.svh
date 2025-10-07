//--------------------------------------------------------------------------------------
// Copyright(C) 2014-2025 Arteris, Inc. and its applicable subsidiaries.
// All rights reserved.
//
// Disclaimer: This release is not provided nor intended for any chip implementations, 
//             tapeouts, or other features of production releases. 
//
// These files and associated documentation is proprietary and confidential to
// Arteris, Inc. and its applicable subsidiaries. The files and documentation
// may only be used pursuant to the terms and conditions of a signed written
// license agreement with Arteris, Inc. or one of its subsidiaries.
// All other use, reproduction, modification, or distribution of the information
// contained in the files or the associated documentation is strictly prohibited.
// This product and its technology is protected by patents and other forms of 
// intellectual property protection.
//
// License: Arteris Confidential
<%// Project: GIU
// Product: Ncore 3.8
// Author: esherk
// %> 
//--------------------------------------------------------------------------------------

giu_env_config m_env_cfg;
giu_env m_giu_env;

giu_csr_init_seq csr_init_seq;
giu_seq m_giu_seq;

string name = "giu_bringup_test";
bit k_smi_cov_en = 1;
uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
virtual giu_csr_probe_if u_csr_probe_vif;

class giu_bringup_test extends giu_base_test;
    `uvm_component_utils(giu_bringup_test)

    extern function new(string _name = "giu_bringup_test", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);

endclass : giu_bringup_test

function giu_bringup_test::new(string _name = "giu_bringup_test", uvm_component parent = null);
    super.new(_name, parent);
    name = _name;
endfunction : new

function void giu_bringup_test::build_phase(uvm_phase phase);
    string arg_value;

    super.build_phase(phase);
    `uvm_info(name, "build_phase", UVM_NONE);

    if(clp.get_arg_value("+k_smi_cov_en=", arg_value)) begin
        k_smi_cov_en = arg_value.atoi();
    end

    // env config
    m_env_cfg = giu_env_config::type_id::create("m_env_cfg");

    if($test$plusargs("inject_smi_uncorr_error"))begin
        m_env_cfg.disable_sb();
    end
    // SMI agent config
    m_env_cfg.m_smi_agent_cfg = smi_agent_config::type_id::create("m_smi_agent_cfg");
    m_env_cfg.m_smi_agent_cfg.active = UVM_ACTIVE;
    m_env_cfg.m_smi_agent_cfg.cov_en = k_smi_cov_en;

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

    if (!uvm_config_db#(virtual <%=obj.BlockId%>_apb_if)::get(.cntxt( this ),
                                        .inst_name( "" ),
                                        .field_name( "m_apb_if" ),
                                        .value(m_env_cfg.m_apb_agent_cfg.m_vif ))) begin
            `uvm_error("giu_bringup_test", "m_apb_if not found")
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

    // Put the env config object into configuration database.
    uvm_config_db#(giu_env_config)::set(
        .cntxt(null),
        .inst_name("*"),
        .field_name("giu_env_config"),
        .value(m_env_cfg)
    );

    //Create the env
    m_giu_env = giu_env::type_id::create("m_giu_env", this);

    if($test$plusargs("no_smi_delay")) begin : no_smi_delay
    <% for (var i = 0; i < obj.nSmiTx; i++) { %>
        m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_delay_min.set_value(0);
        m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_delay_max.set_value(0);
        m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_burst_pct.set_value(100);
    <% } %>
    <% for (var i = 0; i < obj.nSmiRx; i++) { %>
        m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_delay_min.set_value(0);
        m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_delay_max.set_value(0);
        m_env_cfg.m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_burst_pct.set_value(100);
    <% } %>
    end : no_smi_delay

    if(!uvm_config_db#(virtual giu_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_vif)) begin
        `uvm_error({"fault_injector_checker_", get_name()},{"virtual interface must be set  for :",get_full_name(),".vif"})
    end

endfunction : build_phase

task giu_bringup_test::run_phase(uvm_phase phase);

    string k_csr_seq = "";

    super.run_phase(phase);
    `uvm_info(name, "run_phase", UVM_NONE)

    csr_init_seq = giu_csr_init_seq::type_id::create("csr_init_seq");
    csr_init_seq.model = m_giu_env.m_regs;

    m_giu_seq = giu_seq::type_id::create("m_giu_seq");
    m_giu_seq.m_smi_virtual_seqr = m_giu_env.m_smi_agent.m_smi_virtual_seqr;
    //    m_giu_seq.m_giu_unit_args = m_giu_unit_args;

    phase.raise_objection(this, "csr_init");
    `uvm_info(name, "Start CSR init", UVM_NONE)
    csr_init_seq.start(m_giu_env.m_apb_agent.m_apb_sequencer);
    phase.drop_objection(this, "csr_init");

    if ($test$plusargs("k_csr_seq")) 
        if (!$value$plusargs("k_csr_seq=%s",k_csr_seq)) k_csr_seq = "csr_seq" ;

    fork
        // for (int i = 0; i < 10; i++) begin : forloop_main_seq_iter  // by default main_seq_iter=1
        begin : bringup_test
            phase.raise_objection(this, "bringup_test");
            `uvm_info(name, "Start GIU sequence", UVM_NONE)
            m_giu_seq.m_regs = m_giu_env.m_regs;
            m_giu_seq.start(m_giu_env.m_smi_agent.m_smi_virtual_seqr);
            `uvm_info(name, "Done GIU sequence", UVM_NONE)
            phase.phase_done.set_drain_time(this,500us);
            phase.drop_objection(this, "bringup_test");
        end : bringup_test
        if (k_csr_seq != "") begin : csr_seq
            phase.raise_objection(this, $sformatf("Start %s", k_csr_seq));
            //note: inheritance allows us to get child seq behavior without casing back to child type.
            csr_init_seq.start(m_giu_env.m_apb_agent.m_apb_sequencer);
            phase.drop_objection(this, $sformatf("Finish %s", k_csr_seq));
        end : csr_seq
    join

    // phase.raise_objection(this, "giu_seq");
    // `uvm_info(name,"Start GIU sequence", UVM_NONE)
    // m_giu_seq.start(m_giu_env.m_smi_agent.m_smi_virtual_seqr);
    //   phase.drop_objection(this, "giu_seq");

endtask : run_phase
