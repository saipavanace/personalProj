
//
//CHI AIU ENV
//

<% var aiu_frequency;
for(var clk=0; clk<obj.Clocks.length; clk++) {
   if(obj.AiuInfo[obj.Id].nativeClk == obj.Clocks[clk].name) {
      aiu_frequency = obj.Clocks[clk].params.frequency;
      break;
   }
}
%>

class chiaiu_env extends uvm_env;

  `uvm_component_param_utils(chiaiu_env)

  //CHI BFM
  chi_agent    m_chi_agent;

  //SMI BFM
  smi_agent    m_smi_agent;
  bit en_new_scb;

  //CHI AIU Scoreboard
  chi_aiu_scb  m_scb;

  trace_debug_scb  m_trace_debug_scb;

<% if (obj.testBench=="fsys") { %>
  chi_scoreboard m_new_scb;

  //sys_event agent config
  <% if((obj.interfaces.eventRequestOutInt._SKIP_ == false) || (obj.interfaces.eventRequestInInt._SKIP_ == false )) { %>
  event_agent m_event_agent;
  <%}%>
	// newperf test scoreboard
	newperf_test_chi_scb m_newperf_test_chi_scb;
<%}%>

<% if(obj.INHOUSE_APB_VIP && obj.testBench=="chi_aiu"|| obj.testBench == "cust_tb") { %>
   <%=obj.instanceName%>_concerto_register_map_pkg::ral_sys_ncore m_regs;
<%} else if(obj.testBench=="fsys" || obj.testBench=="emu") {%>
   concerto_register_map_pkg::ral_sys_ncore      m_regs;
<%}%>

<% if(obj.INHOUSE_APB_VIP && obj.testBench=="chi_aiu") { %>
   apb_agent                       m_apb_agent;
<% } %>

   // Q-Channel Agent
   q_chnl_agent  m_q_chnl_agent;
   int time_bw_Q_chnl_req;

  //Agent Config
  chiaiu_env_config  m_cfg;
  //Interface Methods
  extern function new(string name="chiaiu_env", uvm_component parent=null);
`ifndef VCS
  extern function void build_phase(uvm_phase);
  extern function void connect_phase(uvm_phase);
  extern virtual task run_phase(uvm_phase phase);
`else // `ifndef VCS
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern virtual task run_phase(uvm_phase phase);
`endif // `ifndef VCS
  //Helper Methods
  extern function void assign_smi_vif();

endclass: chiaiu_env


//Constructor
function chiaiu_env::new(string name="chiaiu_env", uvm_component parent=null);
  super.new(name,parent);
endfunction


//Build Phase
function void chiaiu_env::build_phase(uvm_phase phase);
  bit default_chi_sysco;

  super.build_phase(phase);

  if(!$value$plusargs("chi_new_scb_en=%d", en_new_scb)) begin
    en_new_scb = 0;
  end

  //Env Config Object
  if (!uvm_config_db#(chiaiu_env_config)::get(
      .cntxt( this ),
      .inst_name( "" ),
      .field_name( "chi_aiu_env_config" ),
      .value(m_cfg))) begin

      `uvm_fatal( get_name(), "chi_aiu_env_config not found" )
  end

<% if(obj.INHOUSE_APB_VIP && obj.testBench=="chi_aiu") { %>

     uvm_config_db#(apb_agent_config )::set(.cntxt( this ),
                                             .inst_name( "m_apb_agent" ),
                                             .field_name( "apb_agent_config" ),
                                             .value( m_cfg.m_apb_cfg ));

     m_apb_agent = apb_agent::type_id::create("m_apb_agent", this);
<% } %>

   // Q-Channel
   <% if (obj.testBench == 'chi_aiu') { %>
   if (! m_cfg.m_q_chnl_agent_cfg) `uvm_fatal( get_name(), "m_cfg.m_q_chnl_agent_cfg not found" )
   uvm_config_db#(q_chnl_agent_config )::set(.cntxt( this ),
       .inst_name( "m_q_chnl_agent" ),
       .field_name( "q_chnl_agent_config" ),
       .value( m_cfg.m_q_chnl_agent_cfg ));

   m_cfg.m_q_chnl_agent_cfg.time_bw_Q_chnl_req = time_bw_Q_chnl_req;
   m_q_chnl_agent = q_chnl_agent::type_id::create("m_q_chnl_agent", this);
   <% } %>

  m_cfg.transform_chi_if_type();
  //push CHI agent config object
  // Commentin out below line because below object has already been constructed in the test
  //m_cfg.m_chi_cfg = chi_agent_cfg::type_id::create("m_chi_cfg");
  m_cfg.m_chi_cfg.chi_node_type = RN_F;
  if ($test$plusargs("lnk_credit_strv_mode")) begin
    `uvm_info(get_full_name(), "m_rxcrd_mode set to STRV_MODE", UVM_NONE)
    m_cfg.m_chi_cfg.m_rxcrd_mode = STRV_MODE;
  end
  `ifdef USE_VIP_SNPS_CHI
  m_cfg.m_chi_cfg.agent_cfg     = AGENT_PASSIVE;
  $display("CHIAIU ENV DEBUG PASSIVE");
  `else  // USE_VIP_SNPS_CHI
  m_cfg.m_chi_cfg.agent_cfg     = AGENT_ACTIVE;
  $display("CHIAIU ENV DEBUG ACTIVE");
  `endif // USE_VIP_SNPS_CHI

  if(uvm_config_db #(bit)::get(this, "", "default_chi_sysco", default_chi_sysco)) begin
    `uvm_info(get_full_name(), $sformatf("config_db get() of CHI sysco is found. default_sysco=%0d", default_chi_sysco), UVM_LOW)
  end
  m_cfg.m_chi_cfg.default_sysco = default_chi_sysco;

  uvm_config_db #(chi_agent_cfg)::set(
    this, "m_chi_agent", "config_object", m_cfg.m_chi_cfg);

  //push SMI agent config object
  m_cfg.m_smi_cfg = smi_agent_config::type_id::create("m_smi_cfg");
  assign_smi_vif();
  uvm_config_db #(smi_agent_config)::set(
    this, "m_smi_agent", "smi_agent_config", m_cfg.m_smi_cfg);

  //push CHI virtual interfaces
  uvm_config_db #(chi_rn_driver_vif)::set(this,
    "m_chi_agent", "chi_rn_driver_vif", m_cfg.m_rn_drv_vif);

  uvm_config_db #(chi_rn_monitor_vif)::set(this,
    "m_chi_agent", "chi_rn_monitor_vif", m_cfg.m_rn_mon_vif);

  //CHI Agents
  m_chi_agent = chi_agent::type_id::create("m_chi_agent",this);


<% if(obj.testBench=="emu") { %>
  uvm_config_db #(virtual <%=obj.BlockId%>_chi_emu_if)::set(this,
    "m_chi_agent.*", "<%=obj.BlockId%>_chi_emu_if", m_cfg.m_chi_emu_vif); <% } %>

  //SMI Agents
  m_smi_agent = smi_agent::type_id::create("m_smi_agent",this);
  //CHI Scoreboard
  m_scb  = chi_aiu_scb::type_id::create("m_scb",this);

  if ($test$plusargs("tcap_scb_en")) begin
  m_trace_debug_scb  = trace_debug_scb::type_id::create("m_trace_debug_scb",this);
  end
  
 <% if (obj.testBench=="fsys") { %>
  if(en_new_scb) m_new_scb = chi_scoreboard::type_id::create("m_new_scb", this);

  //sys_event agent
  <% if((obj.interfaces.eventRequestOutInt._SKIP_ == false) || (obj.interfaces.eventRequestInInt._SKIP_ == false )) { %>
  m_event_agent = event_agent::type_id::create("m_event_agent",this);
  <%}%>
	// newperf test scoreboard
	if ($test$plusargs("newperf_test_scb")) begin
    int doff_nbr_rd_tx;
    int doff_nbr_wr_tx;
    //deactivate check of bw in case of cache init using write txn
  
    $value$plusargs("doff_chi<%=obj.Id%>_nbr_rd_tx=%d",doff_nbr_rd_tx);
    $value$plusargs("doff_chi<%=obj.Id%>_nbr_wr_tx=%d",doff_nbr_wr_tx);
    m_newperf_test_chi_scb = newperf_test_chi_scb#(.T_REQ(chi_req_seq_item),.T_DATA(chi_dat_seq_item), .T_RSP(chi_rsp_seq_item))::type_id::create("m_newperf_test_chi_scb",this);
    m_newperf_test_chi_scb.cfg_e_type = CHI;
    m_newperf_test_chi_scb.cfg_aiu_id = <%=obj.Id%>;
    m_newperf_test_chi_scb.aiu_name = "<%=obj.AiuInfo[Id].strRtlNamePrefix%>";
    m_newperf_test_chi_scb.frequency  = <%=aiu_frequency%>;
    m_newperf_test_chi_scb.doff_nbr_rd_tx = ($test$plusargs("read_test")) ? doff_nbr_rd_tx  : ($test$plusargs("write_test"))? 0 : doff_nbr_rd_tx+doff_nbr_wr_tx; 
    m_newperf_test_chi_scb.doff_nbr_wr_tx = ($test$plusargs("write_test")) ? doff_nbr_wr_tx : ($test$plusargs("read_test")) ? 0 : doff_nbr_rd_tx+doff_nbr_wr_tx;

    if($test$plusargs("init_all_cache")) begin // Only CHI0 is used to initialize all DMI cache
      $value$plusargs("chi_num_trans=%d",doff_nbr_wr_tx); 
      m_newperf_test_chi_scb.doff_nbr_wr_tx += doff_nbr_wr_tx;
    end

    end 
<%}%>

  <% if(obj.INHOUSE_APB_VIP && obj.testBench=="chi_aiu" || obj.testBench == 'cust_tb') { %>
    m_regs = <%=obj.instanceName%>_concerto_register_map_pkg::ral_sys_ncore::type_id::create("ral_sys_ncore", this);
    m_regs.build();
    m_regs.lock_model();
  <%} else if (obj.testBench=="fsys" || obj.testBench=="emu") { %>
    if(!(uvm_config_db #(concerto_register_map_pkg::ral_sys_ncore)::get(null,"","m_regs",m_regs))) `uvm_fatal(get_name(),"Failed to get m_regs from db for fsys");
  <% } %>


  if ($test$plusargs("CMDrsp_time_out_test")) begin
    `uvm_info(get_full_name(), "Delay is added on CMDrsp SMI port for time out error test", UVM_NONE)
    m_cfg.m_smi_cfg.m_smi1_tx_port_config.k_burst_pct.set_value(0);
    m_cfg.m_smi_cfg.m_smi1_tx_port_config.k_delay_min.set_value(10000);
    m_cfg.m_smi_cfg.m_smi1_tx_port_config.k_delay_max.set_value(10500);
  end
  if ($test$plusargs("STRreq_time_out_test")) begin
    `uvm_info(get_full_name(), "Delay is added on STRreq SMI port for time out error test", UVM_NONE)
    m_cfg.m_smi_cfg.m_smi0_tx_port_config.k_burst_pct.set_value(0);
    m_cfg.m_smi_cfg.m_smi0_tx_port_config.k_delay_min.set_value(10000);
    m_cfg.m_smi_cfg.m_smi0_tx_port_config.k_delay_max.set_value(10500);
  end

  if ($test$plusargs("cmd_req_delay")) begin
    `uvm_info(get_full_name(), "Delay is added on CMDreq SMI port for time out error test", UVM_NONE)
    m_cfg.m_smi_cfg.m_smi0_rx_port_config.k_burst_pct.set_value(0);
    m_cfg.m_smi_cfg.m_smi0_rx_port_config.k_delay_min.set_value(0);
    m_cfg.m_smi_cfg.m_smi0_rx_port_config.k_delay_max.set_value(2000);
  end
endfunction: build_phase


function void chiaiu_env::assign_smi_vif();
  bit k_smi_cov_en = 1;
  $value$plusargs("k_smi_cov_en=%d",k_smi_cov_en);
  //TX ports from TB presepctive
<% for (var i = 0; i < obj.nSmiRx; i++) { %>
  m_cfg.m_smi_cfg.m_smi<%=i%>_tx_port_config =
    smi_port_config::type_id::create("m_smi<%=i%>_tx_port_config");

  m_cfg.m_smi_cfg.m_smi<%=i%>_tx_port_config.m_vif = m_cfg.m_smi<%=i%>_tx_vif;
    `ifdef CHI_SUBSYS
  m_cfg.m_smi_cfg.m_smi<%=i%>_tx_port_config.m_force_vif = m_cfg.m_smi<%=i%>_tx_force_vif;
    `endif
<% } %>

  //RX ports from TB presective
<% for (var i = 0; i < obj.nSmiTx; i++) { %>
  m_cfg.m_smi_cfg.m_smi<%=i%>_rx_port_config =
    smi_port_config::type_id::create("m_smi<%=i%>_rx_port_config");

  m_cfg.m_smi_cfg.m_smi<%=i%>_rx_port_config.m_vif = m_cfg.m_smi<%=i%>_rx_vif;
    `ifdef CHI_SUBSYS
  m_cfg.m_smi_cfg.m_smi<%=i%>_rx_port_config.m_force_vif = m_cfg.m_smi<%=i%>_rx_force_vif;
    `endif
<% } %>

  m_cfg.m_smi_cfg.active = UVM_ACTIVE;
  `ifndef FSYS_COVER_ON
  m_cfg.m_smi_cfg.cov_en = k_smi_cov_en;
  `elsif CHI_SUBSYS_COVER_ON
  m_cfg.m_smi_cfg.cov_en = k_smi_cov_en;
  `endif
endfunction: assign_smi_vif

//Connect Phase
function void chiaiu_env::connect_phase(uvm_phase phase);
  super.connect_phase(phase);
    <%if (obj.testBench=="fsys") { %>
        if(en_new_scb) begin
            <% for (var i = 0; i < obj.nSmiRx; i++) { %>
                m_smi_agent.m_smi<%=i%>_tx_monitor.smi_ap.connect(m_new_scb.smi_port);
            <%}%>
            <% for (var i = 0; i < obj.nSmiTx; i++) { %>
                m_smi_agent.m_smi<%=i%>_tx_monitor.smi_ap.connect(m_new_scb.smi_port);
            <%}%>
            // experimental scoreboard connections
            m_chi_agent.chi_txreq_pkt_ap.connect(m_new_scb.chi_req_port);
            m_chi_agent.chi_txrsp_pkt_ap.connect(m_new_scb.chi_srsp_port);
            m_chi_agent.chi_txdat_pkt_ap.connect(m_new_scb.chi_wdata_port);
            m_chi_agent.chi_rxrsp_pkt_ap.connect(m_new_scb.chi_crsp_port);
            m_chi_agent.chi_rxdat_pkt_ap.connect(m_new_scb.chi_rdata_port);
            m_chi_agent.chi_rxsnp_pkt_ap.connect(m_new_scb.chi_snpaddr_port);
        end
    <%}%>

  if(m_cfg.has_scoreboard) begin
      //SMI Ports
      //Calculate based on the jscript numPorts
      <% for (var i = 0; i < obj.nSmiRx; i++) { %>
      m_smi_agent.m_smi<%=i%>_tx_monitor.smi_ap.connect(m_scb.smi_port);
      if ($test$plusargs("tcap_scb_en")) begin
        <% if(i == (obj.nSmiRx-1)) { %>
        m_smi_agent.m_smi<%=i%>_tx_monitor.smi_ndp_ap.connect(m_trace_debug_scb.analysis_smi_dntx_ndp_only_port);
        <% } %>
        m_smi_agent.m_smi<%=i%>_tx_monitor.smi_ap.connect(m_trace_debug_scb.analysis_smi<%=i%>_tx_port);
      end
      <%}%>
      <% for (var i = 0; i < obj.nSmiTx; i++) { %>
      m_smi_agent.m_smi<%=i%>_rx_monitor.smi_ap.connect(m_scb.smi_port);
      if ($test$plusargs("tcap_scb_en")) begin
        <% if(i == (obj.nSmiTx-1)) { %>
        m_smi_agent.m_smi<%=i%>_rx_monitor.smi_ndp_ap.connect(m_trace_debug_scb.analysis_smi_dnrx_ndp_only_port);
        <% } %>
        m_smi_agent.m_smi<%=i%>_rx_monitor.smi_ap.connect(m_trace_debug_scb.analysis_smi<%=i%>_rx_port);
      end
      <%}%>

      //CHI Ports 
      m_chi_agent.chi_txreq_pkt_ap.connect(m_scb.chi_req_port);
      m_chi_agent.chi_txrsp_pkt_ap.connect(m_scb.chi_srsp_port);
      m_chi_agent.chi_txdat_pkt_ap.connect(m_scb.chi_wdata_port);
      m_chi_agent.chi_rxrsp_pkt_ap.connect(m_scb.chi_crsp_port);
      m_chi_agent.chi_rxdat_pkt_ap.connect(m_scb.chi_rdata_port);
      m_chi_agent.chi_rxsnp_pkt_ap.connect(m_scb.chi_snpaddr_port);
      m_chi_agent.chi_sysco_pkt_ap.connect(m_scb.chi_sysco_port);
    <% if (obj.testBench == 'chi_aiu') { %>
      m_q_chnl_agent.q_chnl_ap.connect(m_scb.q_chnl_port);
    <% } %>
    <% if (obj.testBench=="fsys") { %>
	   //newperf test scb : connect scb to the ports
      if ($test$plusargs("newperf_test_scb")) begin
        m_chi_agent.chi_txreq_pkt_ap.connect(m_newperf_test_chi_scb.req_port);
        m_chi_agent.chi_rxdat_pkt_ap.connect(m_newperf_test_chi_scb.rdata_port); 
        m_chi_agent.chi_txdat_pkt_ap.connect(m_newperf_test_chi_scb.wdata_port); 
        m_chi_agent.chi_rxrsp_pkt_ap.connect(m_newperf_test_chi_scb.crsp_port);
      end 
      //end newperf test	
    <% } %>
  end
<% if(obj.INHOUSE_APB_VIP && obj.testBench=="chi_aiu" || obj.testBench == 'cust_tb') { %>
    m_regs.default_map.set_auto_predict(1);
    m_regs.default_map.set_sequencer(.sequencer(m_apb_agent.m_apb_sequencer),
                                     .adapter(m_apb_agent.m_apb_reg_adapter));
<% } %> 
<% if(obj.testBench!="fsys") { %>
if(m_cfg.has_scoreboard ) begin
   m_scb.m_regs = this.m_regs; 
end
<%}%> 
endfunction: connect_phase

task chiaiu_env::run_phase(uvm_phase phase);
<%if(obj.testBench == "fsys" || obj.testBench == "emu"){ %>
`ifdef VCS
    #1;
`endif  // ifdef VCS
m_scb.k_snp_rsp_non_data_err_wgt = m_cfg.k_snp_rsp_non_data_err_wgt;
<%}%>
endtask: run_phase
