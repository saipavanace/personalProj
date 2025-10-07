//////////////////////////////////////////////////////////////////////////
//
// CHI AIU Environment Configuration
//
//////////////////////////////////////////////////////////////////////////

class chiaiu_env_config extends uvm_object;
  `uvm_object_param_utils(chiaiu_env_config)

  bit has_scoreboard = 1;
  bit has_functional_coverage;

  //CHI Agent
  //Instantiate config object
  smi_agent_config   m_smi_cfg;
  chi_agent_cfg      m_chi_cfg;
  //sys_event agent config
  <% if(obj.testBench=="fsys"){ %>
  <% if((obj.interfaces.eventRequestOutInt._SKIP_ == false) || (obj.interfaces.eventRequestInInt._SKIP_ == false )) { %>
  event_agent_config m_event_agent_cfg;
  <%}%>  
  <% } %>
<% if(obj.testBench=="emu") { %>
  virtual <%=obj.BlockId%>_chi_emu_if m_chi_emu_vif; <% } %> 
  virtual <%=obj.BlockId%>_chi_if m_chi_vif;

  chi_rn_driver_vif  m_rn_drv_vif;
  chi_rn_monitor_vif m_rn_mon_vif;

//SMI Interface
<% for (var i = 0; i < obj.nSmiRx; i++) { %>
  virtual <%=obj.BlockId%>_smi_if m_smi<%=i%>_tx_vif;
    `ifdef CHI_SUBSYS
  virtual <%=obj.BlockId%>_smi_force_if m_smi<%=i%>_tx_force_vif;
    `endif
<% } %>

<% for (var i = 0; i < obj.nSmiTx; i++) { %>
  virtual <%=obj.BlockId%>_smi_if m_smi<%=i%>_rx_vif;
    `ifdef CHI_SUBSYS
  virtual <%=obj.BlockId%>_smi_force_if m_smi<%=i%>_rx_force_vif;
    `endif
<% } %>

  virtual <%=obj.BlockId%>_smi_if m_smi_vif;
    `ifdef CHI_SUBSYS
  virtual <%=obj.BlockId%>_smi_force_if m_smi_force_vif;
    `endif

  //APB Agent
<% if(obj.INHOUSE_APB_VIP && obj.testBench=="chi_aiu") { %>
   apb_agent_config m_apb_cfg;
<% } %>
   int k_snp_rsp_non_data_err_wgt;

  // Q -Channel
  q_chnl_agent_config  m_q_chnl_agent_cfg;

  //Methods
  extern function new(string name = "chiaiu_env_config");
  extern function void disable_scoreboard();
  extern function void transform_chi_if_type();

endclass : chiaiu_env_config


function chiaiu_env_config::new(string name = "chiaiu_env_config");
  super.new(name);
endfunction : new

function void chiaiu_env_config::disable_scoreboard();
  has_scoreboard = 0;
endfunction: disable_scoreboard

function void chiaiu_env_config::transform_chi_if_type();
  if (m_chi_vif == null)
    `uvm_fatal(get_name(), "m_chi_vif is not set")

  m_rn_drv_vif = m_chi_vif.rn_drv_mp;
  m_rn_mon_vif = m_chi_vif.rn_mon_mp;
endfunction: transform_chi_if_type
