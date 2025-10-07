
////////////////////////////////////////////////////////////////////////////////
//
// Q channel Agent Configuration
//
////////////////////////////////////////////////////////////////////////////////
class q_chnl_agent_config extends uvm_object;

  `uvm_object_param_utils(q_chnl_agent_config)

<% if (obj.testBench=="fsys" || obj.testBench=="cust_tb" || obj.testBench=="emu") { %> 
    virtual concerto_q_chnl_if  m_vif;
<% } else { %>
    virtual <%=obj.BlockId%>_q_chnl_if  m_vif;
<% } %>
  int     time_bw_Q_chnl_req;
  uvm_active_passive_enum active      = UVM_ACTIVE;

  extern function new(string name = "q_chnl_agent_config");

endclass: q_chnl_agent_config

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function q_chnl_agent_config::new(string name = "q_chnl_agent_config");
  super.new(name);
endfunction : new

////////////////////////////////////////////////////////////////////////////////
