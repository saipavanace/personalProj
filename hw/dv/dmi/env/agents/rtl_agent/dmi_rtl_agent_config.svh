
////////////////////////////////////////////////////////////////////////////////

class <%=obj.BlockId%>_rtl_agent_config extends uvm_object;

  virtual <%=obj.BlockId%>_rtl_if  m_vif;
  `uvm_object_utils(<%=obj.BlockId%>_rtl_agent_config)

  uvm_active_passive_enum active = UVM_PASSIVE;

  extern function new(string name = "<%=obj.BlockId%>_rtl_agent_config");

endclass: <%=obj.BlockId%>_rtl_agent_config

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function <%=obj.BlockId%>_rtl_agent_config::new(string name = "<%=obj.BlockId%>_rtl_agent_config");
  super.new(name);
endfunction : new

////////////////////////////////////////////////////////////////////////////////

