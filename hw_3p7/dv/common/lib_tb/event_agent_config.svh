///////////////////////////////
// EVent Agent configuration
// Author: Abdelaziz EL HAMADI
//////////////////////////////
class event_agent_config extends uvm_object;

  `uvm_object_param_utils(event_agent_config)

  virtual <%=obj.BlockId%>_event_if #(.IF_MASTER(1))  m_vif_master;
  virtual <%=obj.BlockId%>_event_if #(.IF_MASTER(0))  m_vif_slave;
  int has_driver = 1; 
   
  extern function new(string name = "event_agent_config");

endclass: event_agent_config

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function event_agent_config::new(string name = "event_agent_config");
  super.new(name);
endfunction : new

////////////////////////////////////////////////////////////////////////////////