
////////////////////////////////////////////////////////////////////////////////
//
// DCE Environment
// Integrates all components
////////////////////////////////////////////////////////////////////////////////


class dce_env extends uvm_env;

   `uvm_component_param_utils(dce_env)

    dce_probe_monitor m_probe_mon; 
    dce_env_config    m_env_cfg;
    smi_agent         m_smi_agent;
    q_chnl_agent      m_q_chnl_agent;
    int               time_bw_Q_chnl_req;

    dce_scb           m_dce_scb;
    //<%=obj.BlockId%>_directory_mgr   m_dirm_mgr;
    //<%=obj.BlockId%>_dirm_scoreboard m_dirm_scb;

    <% if(obj.testBench == 'dce') { %>
   `ifndef VCS
    <% if(obj.COVER_ON) { %>
      dce_coverage m_cov_obj;
      virtual <%=obj.BlockId%>_tf_cov_if m_cov_if;
    <% } %>
   `else // `ifndef VCS
    <% if(obj.COVER_ON) { %>
    //dce_coverage m_cov_obj;
    //virtual <%=obj.BlockId%>_tf_cov_if m_cov_if;
    <% } %>
   `endif
    <% } else { %>
    <% if(obj.COVER_ON) { %>
   `ifndef FSYS_COVER_ON
       `ifndef IOAIU_SUBSYS_COVER_ON
            dce_coverage m_cov_obj;
            virtual <%=obj.BlockId%>_tf_cov_if m_cov_if;
       `endif
    `endif
    <% } %>
    <% } %>

    <% if((obj.testBench=='dce') && (obj.INHOUSE_APB_VIP) && 
    ((obj.instanceName) ? (obj.strRtlNamePrefix == obj.instanceName) : (obj.Id=="0")) || (obj.testBench == 'cust_tb'))  { %> 
   <%=obj.BlockId%>_concerto_register_map_pkg::ral_sys_ncore m_regs;
   <%} else if(obj.testBench == "fsys" || obj.testBench == "emu") { %>
   concerto_register_map_pkg::ral_sys_ncore m_regs;
   <% } %>

   /* <% if((obj.testBench=='dce') && (obj.INHOUSE_APB_VIP) && 
    ((obj.instanceName) ? (obj.strRtlNamePrefix == obj.instanceName) : (obj.Id=="0"))) { %>
    ral_sys_ncore                     m_regs;
    <% } %> */ //vyshak
    <% if(obj.testBench == 'dce') { %>                   
    apb_agent                       m_apb_agent;
    <% } %>

    <% 
    var sf_cnt  = 0;
    var plru_en = 0;   
    obj.SnoopFilterInfo.forEach(function(bundle,indx, array) {
        sf_cnt++;
        if(bundle.RepPolicy == "PLRU") {
            plru_en = 1;
        }
    });%>

    <%if(obj.testBench == 'dce') { %>
    <% for(var x = 0; x < sf_cnt; x++) { %>
    snoop_filter_monitor #(<%=obj.SnoopFilterInfo[x].nSets%>, <%=obj.SnoopFilterInfo[x].nWays%>, 8) m_sf_monitor_<%=x%>;
    <% if(plru_en == 1) { %>
    snoop_filter_monitor #(<%=obj.SnoopFilterInfo[x].nSets%>, 1, 8) m_plru_mem_wr_monitor_<%=x%>;
    <% } %>
    <% } %>
    <% } %>

    extern function new(string name = "dce_env", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
endclass : dce_env

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dce_env::new(string name = "dce_env", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void dce_env::build_phase(uvm_phase phase);
  super.build_phase(phase);

  `uvm_info("dce_env",$sformatf("build_phase"),UVM_NONE);
  if (!uvm_config_db#(dce_env_config)::get(.cntxt(this),
                                           .inst_name(""),
                                           .field_name("dce_env_config"),
                                           .value(m_env_cfg))) begin
    `uvm_fatal(get_name(), "dce_env_config not found")
  end

  //SMI Agents
  m_smi_agent = smi_agent::type_id::create("m_smi_agent", this);
  m_smi_agent.m_cfg = m_env_cfg.m_smi_agent_cfg; 
  
  //Probe Monitor
  m_probe_mon = dce_probe_monitor::type_id::create("m_probe_mon", this);
  m_probe_mon.m_vif = m_env_cfg.m_probe_vif;
  m_probe_mon.m_delay_export = 1;

  //Create DCE Scoreboard if enabled
  if(m_env_cfg.has_scoreboard) begin
      m_dce_scb = dce_scb::type_id::create("m_dce_scb", this);
      m_dce_scb.m_dm_dbg               = m_env_cfg.en_dirm_dbg_msg;
      m_dce_scb.m_dm_output_chks_en    = m_env_cfg.en_dm_interface_chks;
      m_dce_scb.m_dv_rec_support_en    = m_env_cfg.en_dv_rec;
      m_dce_scb.m_dv_snpreq_up_chks_en = m_env_cfg.en_up_chks;
      m_dce_scb.m_dv_tgtid_chks_en 	   = m_env_cfg.en_mpf1_tgtid_chks;
      m_dce_scb.m_env_cfg			   = m_env_cfg;
  end
  else dce_goldenref_model::build();

   <% if (obj.testBench == 'dce') { %>
   if (! m_env_cfg.m_q_chnl_agent_cfg) `uvm_fatal( get_name(), "m_env_cfg.m_q_chnl_agent_cfg not found" )
   uvm_config_db#(q_chnl_agent_config )::set(.cntxt( this ),
       .inst_name( "m_q_chnl_agent" ),
       .field_name( "q_chnl_agent_config" ),
       .value( m_env_cfg.m_q_chnl_agent_cfg ));

   m_env_cfg.m_q_chnl_agent_cfg.time_bw_Q_chnl_req = time_bw_Q_chnl_req;
   m_q_chnl_agent = q_chnl_agent::type_id::create("m_q_chnl_agent", this);
   <% } %>

   <%if(obj.testBench == 'dce') { %>
   // snoop_filter_monitor instance
   <% for(var x = 0; x < sf_cnt; x++){ %>
   m_sf_monitor_<%=x%> = snoop_filter_monitor #(<%=obj.SnoopFilterInfo[x].nSets%>, <%=obj.SnoopFilterInfo[x].nWays%>, 8)::type_id::create("sf_monitor[<%=x%>]", this);
   <% if(plru_en == 1) { %>
   m_plru_mem_wr_monitor_<%=x%> = snoop_filter_monitor #(<%=obj.SnoopFilterInfo[x].nSets%>, 1, 8)::type_id::create("plru_mem_wr_monitor[<%=x%>]", this);
   <% } %>
   <% } %>
   <% } %>

  //m_dirm_mgr = <%=obj.BlockId%>_directory_mgr::type_id::create("<%=obj.BlockId%>_directory_mgr");

  //Build in dce dirm scoreboard
  //if(m_env_cfg.has_dirm_scoreboard) begin
  //  m_dirm_scb = <%=obj.BlockId%>_dirm_scoreboard::type_id::create(
  //      "<%=obj.BlockId%>_dirm_scoreboard", this);
  //  m_dirm_scb.m_dirm_mgr = m_dirm_mgr;
  //  m_dirm_scb.m_scb_db   = m_env_cfg.en_dirm_dbg_msg;
  //end
<% if((obj.testBench=='dce') && (obj.INHOUSE_APB_VIP)) { %>

    uvm_config_db#(apb_agent_config )::set(.cntxt( this ),
                                           .inst_name( "m_apb_agent" ),
                                           .field_name( "apb_agent_config" ),
                                           .value( m_env_cfg.m_apb_cfg ));

    m_apb_agent = apb_agent::type_id::create("m_apb_agent", this);
<% } %>

<% if((obj.testBench=='dce') && (obj.INHOUSE_APB_VIP) && ((obj.instanceName) ? (obj.strRtlNamePrefix == obj.instanceName) : (obj.Id=="0")) || (obj.testBench == 'cust_tb')) { %>
    m_regs = <%=obj.BlockId%>_concerto_register_map_pkg::ral_sys_ncore::type_id::create("ral_sys_ncore", this);
    m_regs.build();
    m_regs.lock_model();
<% } else if (obj.testBench == "fsys") { %>
      if(!(uvm_config_db #(concerto_register_map_pkg::ral_sys_ncore)::get(null,"","m_regs",m_regs))) `uvm_fatal( get_name(), "RAL m_regs not found for fsys");
      
<% } %>


endfunction : build_phase

//------------------------------------------------------------------------------
// Connect Phase
//------------------------------------------------------------------------------
function void dce_env::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    if (m_env_cfg.has_scoreboard) begin
        m_dce_scb.m_regs = this.m_regs; //vyshak 

        //SMI Ports
        //Calculate based on the jscript numPorts
        <% for (var i = 0; i < obj.nSmiRx; i++) { %>
        m_smi_agent.m_smi<%=i%>_tx_port_ap.connect(m_dce_scb.m_smi_port);
        <%}%>
        <% for (var i = 0; i < obj.nSmiTx; i++) { %>
        m_smi_agent.m_smi<%=i%>_rx_port_ap.connect(m_dce_scb.m_smi_port);
        <%}%>
    
        m_probe_mon.dm_ap.connect(m_dce_scb.m_dm_port);
        m_probe_mon.tm_ap.connect(m_dce_scb.m_tm_port);
        m_probe_mon.evt_ap.connect(m_dce_scb.m_evt_port);
        m_probe_mon.sb_cmdrsp_ap.connect(m_dce_scb.m_sb_cmdrsp_port);
        m_probe_mon.sb_syscorsp_ap.connect(m_dce_scb.m_sb_syscorsp_port);
        m_probe_mon.conc_mux_cmdreq_ap.connect(m_dce_scb.m_conc_mux_cmdreq_port);
        m_probe_mon.arb_cmdreq_ap.connect(m_dce_scb.m_arb_cmdreq_port);
        m_probe_mon.cycle_tracker_ap.connect(m_dce_scb.m_cycle_tracker_port);
        <% if (obj.testBench == 'dce') { %>
        m_q_chnl_agent.q_chnl_ap.connect(m_dce_scb.analysis_q_chnl_port);
        <% } %>
    
        <%if(obj.testBench == 'dce') { %>
        <% for(var x = 0; x < sf_cnt; x++){ %>
        m_sf_monitor_<%=x%>.m_snoop_filter_port_out.connect(m_dce_scb.m_sf_port_in_<%=x%>);
        <% if(plru_en == 1) { %>
        m_plru_mem_wr_monitor_<%=x%>.m_snoop_filter_port_out.connect(m_dce_scb.m_plru_mem_wr_port_in_<%=x%>);
        <% } %>
        <% } %>
        <% } %>
    end

    <% if((obj.testBench=='dce') && (obj.INHOUSE_APB_VIP)
      && ((obj.instanceName) ? (obj.strRtlNamePrefix == obj.instanceName) : (obj.Id=="0")) || obj.testBench == 'cust_tb' ) { %>
    m_regs.default_map.set_auto_predict(1);
    m_regs.default_map.set_sequencer(.sequencer(m_apb_agent.m_apb_sequencer),
                                     .adapter(m_apb_agent.m_apb_reg_adapter));
    <% } %> 
endfunction : connect_phase
