 
class ccp_agent_config extends uvm_object;

  `uvm_object_param_utils(ccp_agent_config)

  virtual  <%=obj.BlockId + '_ccp_if'%> m_vif;
  
  uvm_active_passive_enum active      = UVM_PASSIVE;

  bit has_scoreboard                         = 0;
  bit has_functional_coverage                = 1;
  bit delay_export                           = 0; 
  int k_timeout                              = 200000;
  int k_num_txn                              = 6;
  int k_cache_warm_depth                     = 0;    
  int k_cache_used_idx_depth                 = 5;    
  int k_num_addr                             = 1;
  int k_num_read                             = 5;
  int k_num_write                            = 5;
  int wt_used_addr                           = 20;
  int wt_nop                                 = 10;
  int wt_wrtoarray                           = 50;
  int wt_wrtoarray_and_rdrsp_port            = 10;
  int wt_wrtoarray_and_evct_port             = 10;
  int wt_bypass_wrtordrsp_port               = 10;
  int wt_bypass_wrtordevct_port              = 10;
  int wt_rdtordrsp_port                      = 50;
  int wt_rdtoevct_port                       = 50;
  int wt_rdtoevct_wrbypasstorsp              = 10;
  int wt_rdtoevct_wrbypasstoevctp            = 10;
  int wt_wrtoarray_rdtoevctp                 = 10;
  int wt_used_index                          = 50; 
  
  int k_fill_if_delay_min                    = 1;
  int k_fill_if_delay_max                    = 10;
  int k_fill_if_delay_pct                    = 80;

  extern function new(string name = "ccp_agent_config");

endclass: ccp_agent_config

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function ccp_agent_config::new(string name = "ccp_agent_config");
  super.new(name);
endfunction : new

