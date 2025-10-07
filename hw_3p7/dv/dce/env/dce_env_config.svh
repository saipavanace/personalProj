////////////////////////////////////////////////////////////////////////////////
//
// DCE Environment Configuration
//
////////////////////////////////////////////////////////////////////////////////
class dce_env_config extends uvm_object;

   `uvm_object_param_utils(dce_env_config)
    
    bit                  has_scoreboard             = 0;
    bit                  has_coverage               = 0;
    bit                  en_dm_interface_chks       = 0;
    bit                  en_dirm_dbg_msg            = 0;
    bit                  en_dv_rec                  = 0;
    bit                  en_up_chks                 = 0;
    bit                  en_rl_chks                 = 0;
    bit                  en_mpf1_tgtid_chks         = 0;
    bit                  m_probe_agent_delay_export = 0;
    int                  m_qoscr_event_threshold    = 0;
    int                  ev_prot_timeout_val        = 0;
    smi_agent_config     m_smi_agent_cfg;
    q_chnl_agent_config  m_q_chnl_agent_cfg;
    
    // CONC-13159
    // There are better ways to do this. But this seems the less intrusive way
    // of doing it with the existing env setup
    <%if(obj.DceInfo[0].fnEnableQos == 1) {%>
    rand bit             m_use_evict_qos;
    rand bit [3:0]       m_evict_qos;
    <%} else {%>
    bit                  m_use_evict_qos = 0;
    bit [3:0]            m_evict_qos = 'd15;
    <%}%>
    
    //SMI Interface
    <% for (var i = 0; i < obj.nSmiRx; i++) { %>
    virtual <%=obj.BlockId%>_smi_if     m_smi<%=i%>_tx_vif;
    <% } %>
    
    <% for (var i = 0; i < obj.nSmiTx; i++) { %>
    virtual <%=obj.BlockId%>_smi_if     m_smi<%=i%>_rx_vif;
    <% } %>
    
    virtual <%=obj.BlockId%>_probe_if   m_probe_vif;
    
    <% if((obj.testBench=='dce') && (obj.INHOUSE_APB_VIP)) { %>
    apb_agent_config m_apb_cfg;
    <% } %>
    
    extern function new(string name = "dce_env_config");
    extern function void set_dce_scb(int status);
    extern function void set_fun_cov(int status);
    extern function void en_dm_chks(int status);
    extern function void en_dm_dbg(int status);
endclass : dce_env_config

function dce_env_config::new(string name = "dce_env_config");
    super.new(name);
endfunction : new

function void dce_env_config::set_dce_scb(int status);
    has_scoreboard = status;
endfunction: set_dce_scb

function void dce_env_config::set_fun_cov(int status);
    has_coverage = status;
endfunction: set_fun_cov

function void dce_env_config::en_dm_chks(int status);
    en_dm_interface_chks = status;
endfunction: en_dm_chks

function void dce_env_config::en_dm_dbg(int status);
    en_dirm_dbg_msg = status;
endfunction: en_dm_dbg

