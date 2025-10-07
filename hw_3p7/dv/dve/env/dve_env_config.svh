class dve_env_config extends uvm_object;
  `uvm_object_utils(dve_env_config)

  bit has_sb = 1;

  smi_agent_config m_smi_agent_cfg;
  apb_agent_config m_apb_agent_cfg;

<% for (var i = 0; i < obj.nSmiRx; i++) { %>
  virtual <%=obj.BlockId%>_smi_if           m_smi<%=i%>_tx_vif;
<% } %>

<% for (var i = 0; i < obj.nSmiTx; i++) { %>
  virtual <%=obj.BlockId%>_smi_if           m_smi<%=i%>_rx_vif;
<% } %>
  q_chnl_agent_config  m_q_chnl_agent_cfg;

  virtual <%=obj.BlockId%>_clock_counter_if   m_clock_counter_vif;

  function new(string name = "dve_env_config");
    super.new(name);
  endfunction // new

  extern function void disable_sb();
endclass // dve_env_config

function void dve_env_config::disable_sb();
  has_sb = 0;
endfunction // disable_sb
