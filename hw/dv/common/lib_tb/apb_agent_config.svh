
////////////////////////////////////////////////////////////////////////////////
//
// APB Agent Configuration
//
////////////////////////////////////////////////////////////////////////////////
//typedef enum {IS_AXI4_INTF, IS_ACE_LITE_INTF, IS_ACE_INTF} e_axi_interface_type;
class apb_agent_config extends uvm_object;

  `uvm_object_param_utils(apb_agent_config)

  virtual <%=obj.BlockId%>_apb_if  m_vif;
  int has_driver = 1; 

  //bit delay_export                    = 0;
   /*int k_apb_mcmd_delay_min                      = 0;
   int k_apb_mcmd_delay_max                      = 1;
   int k_apb_mcmd_burst_pct                      = 90;
   bit k_apb_mcmd_wait_for_scmdaccept            = 0;

   int k_apb_maccept_delay_min                   = 0;
   int k_apb_maccept_delay_max                   = 1;
   int k_apb_maccept_burst_pct                   = 90;
   bit k_apb_maccept_wait_for_sresp              = 0;

   bit k_slow_apb_agent                          = 0;
   bit k_slow_apb_mcmd_agent                     = 0;
   bit k_slow_apb_mrespaccept_agent              = 0;*/
   
  extern function new(string name = "apb_agent_config");

endclass: apb_agent_config

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function apb_agent_config::new(string name = "apb_agent_config");
  super.new(name);
endfunction : new

////////////////////////////////////////////////////////////////////////////////

