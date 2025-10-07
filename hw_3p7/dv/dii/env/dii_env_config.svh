////////////////////////////////////////////////////////////////////////////////
//
// DII Environment Configuration
//
////////////////////////////////////////////////////////////////////////////////
class dii_env_config extends uvm_object;

   `uvm_object_param_utils(dii_env_config)

    //these are enabled in each test case
   bit has_scoreboard = 0;
   bit has_tcap_scb = 0;
   bit has_functional_coverage = 0; 
   
   smi_agent_config     m_smi_agent_cfg;
   axi_agent_config     m_axi_slave_agent_cfg;

<% if(obj.testBench=="emu") { %>
  virtual mgc_axi_master_if mgc_ace_vif ; 
 <% } %>
   `ifndef USE_VIP_SNPS_APB
   apb_agent_config     m_apb_agent_cfg;
   `endif
   dii_rtl_agent_config m_dii_rtl_agent_cfg;

   q_chnl_agent_config  m_q_chnl_agent_cfg;
  <% if(obj.testBench=="dii") { %>
   `ifdef USE_VIP_SNPS
  // AMBA System ENV CFG
    dii_amba_env_config    m_dii_amba_env_config;
  `endif // !`ifdef USE_VIP_SNPS
  <% } %>  
   extern function new(string name = "dii_env_config");

endclass : dii_env_config

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dii_env_config::new(string name = "dii_env_config");
  super.new(name);
endfunction : new

////////////////////////////////////////////////////////////////////////////////
