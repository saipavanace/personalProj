import common_knob_pkg::*;

<% 
const Dvm_NUnitIds = [] ;

for (const elem of obj.AiuInfo) {
    if(elem.cmpInfo.nDvmSnpInFlight >0) {
        Dvm_NUnitIds.push(elem.nUnitId);   //dve requires corresponding vector of NUnitIds of which aius are dvm capable, ordered by NUnitId
    }
}

const dvm_agent = Dvm_NUnitIds.length;
    
let SnpsEnb = 0;
for(let i in Dvm_NUnitIds) {
    SnpsEnb |= 1 << Dvm_NUnitIds[i]; 
}
%>

class dve_snpcap_ral_test extends dve_base_test;
  `uvm_component_utils(dve_snpcap_ral_test)

  uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
  virtual <%=obj.BlockId%>_apb_if      m_apb_if;

  dve_env_config           m_env_cfg;
  dve_env               m_dve_env;

  dve_seq               m_dve_seq;
  dve_csr_dveuser_SnoopCap_seq csr_seq;

  // sequence knobs
  string  k_csr_seq   = "";
  int m_timeout_us;

  function new(string name = "dve_snpcap_ral_test", uvm_component parent = null);
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
    `uvm_info("dve_snpcap_ral_test", "build_phase", UVM_NONE);

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
        `uvm_error("dve_snpcap_ral_test", "m_apb_if not found")
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
    int SnoopEn,SnoopCapAius;
    int rand_aiu;
     
    super.run_phase(phase);
    `uvm_info("dve_snpcap_ral_test", "run_phase", UVM_NONE);

    csr_seq = dve_csr_dveuser_SnoopCap_seq::type_id::create("csr_seq"); 
    csr_seq.model = m_dve_env.m_regs;

    m_dve_seq = dve_seq::type_id::create("m_dve_seq");
    m_dve_seq.m_smi_virtual_seqr = m_dve_env.m_smi_agent.m_smi_virtual_seqr;
        
    foreach(DVM_AIU_FUNIT_IDS[i]) begin
        `uvm_info("TEST",$sformatf("DVM_AIU_FUNIT_IDS[%0d] = %0d",i, DVM_AIU_FUNIT_IDS[i]), UVM_NONE) 
    end

    SnoopEn = <%=SnpsEnb%>;
    `uvm_info("TEST",$sformatf("Before CSR SnoopEn = %0b",SnoopEn), UVM_NONE) 

    if(<%=dvm_agent%> > 2) begin
       SnoopEn[<%=Dvm_NUnitIds[0]%>] = 'b0; 
    end
    csr_seq.SnoopEn = SnoopEn;

    phase.raise_objection(this, $sformatf("Start CSR sequence"));
    `uvm_info("dve_bringup_test", "Start CSR sequence", UVM_NONE)
    //note: inheritance allows us to get child seq behavior without casing back to child type.
    csr_seq.start(m_dve_env.m_apb_agent.m_apb_sequencer);
    `uvm_info("dve_bringup_test", "Done CSR sequence", UVM_NONE)
    phase.drop_objection(this, $sformatf("Finish CSR sequence"));

    SnoopEn = csr_seq.SnoopEn;

    m_dve_env.m_dve_sb.DveSnpCapAgents = $countones(SnoopEn);
    m_dve_env.m_dve_sb.SnoopEn = SnoopEn;
    m_dve_seq.SysCoAttach_agents = SnoopEn;
    //m_dve_env.m_dve_sb.SnoopEn_FUNIT_IDS = new[$countones(SnoopEn)];
    `uvm_info("TEST",$sformatf("After CSR SnoopEn = %0b, SysCoAttach_agents=0x%0h",SnoopEn, m_dve_seq.SysCoAttach_agents), UVM_NONE) 
/*
     // clear existing IDs
     m_dve_env.m_dve_sb.SnoopEn_FUNIT_IDS = {};
     
    foreach(m_dve_env.m_dve_sb.SnoopEn_FUNIT_IDS[i]) begin
        `uvm_info("TEST",$sformatf("Before: m_dve_env.m_dve_sb.SnoopEn_FUNIT_IDS[%0d] = %0d",i,m_dve_env.m_dve_sb.SnoopEn_FUNIT_IDS[i]), UVM_NONE) 
    end

    foreach(SnoopEn[i]) begin
       if(SnoopEn[i] == 1) begin
       	m_dve_env.m_dve_sb.SnoopEn_FUNIT_IDS.push_back(DVM_AIU_FUNIT_IDS[i]);
        `uvm_info("TEST",$sformatf("Pushing FUnitId %0d to m_dve_env.m_dve_sb.SnoopEn_FUNIT_IDS", DVM_AIU_FUNIT_IDS[i]), UVM_NONE) 
       end
    end
    
    foreach(m_dve_env.m_dve_sb.SnoopEn_FUNIT_IDS[i]) begin
        `uvm_info("TEST",$sformatf("After: m_dve_env.m_dve_sb.SnoopEn_FUNIT_IDS[%0d] = %0d",i,m_dve_env.m_dve_sb.SnoopEn_FUNIT_IDS[i]), UVM_NONE) 
    end
*/
    phase.raise_objection(this, "dve_bringup_test");
    `uvm_info("dve_bringup_test", "Start DVE sequence", UVM_NONE)
    m_dve_seq.m_regs = m_dve_env.m_regs;
    m_dve_seq.start(null);
    `uvm_info("dve_bringup_test", "Done DVE sequence", UVM_NONE)
    phase.phase_done.set_drain_time(this,50us);
    phase.drop_objection(this, "dve_snpcap_ral_test");

  endtask // run_phase

  function void report_phase(uvm_phase phase);
    uvm_report_server urs;
    int uvm_err_cnt, uvm_fatal_cnt;
  
    urs = uvm_report_server::get_server();
    uvm_err_cnt = urs.get_severity_count(UVM_ERROR);
    uvm_fatal_cnt = urs.get_severity_count(UVM_FATAL);

    if((uvm_err_cnt != 0) || (uvm_fatal_cnt != 0))
      `uvm_info("dve_snpcap_ral_test", "\n ============ \n UVM FAILED!\n ============", UVM_NONE)
    else
      `uvm_info("dve_snpcap_ral_test", "\n ============ \n UVM PASSED!\n ============", UVM_NONE)
  endfunction // report_phase
endclass // dve_snpcap_ral_test
