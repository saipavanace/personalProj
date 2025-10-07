////////////////////////////////////////////////////////////////////////////////
//
// DII RTL Agent config
//
////////////////////////////////////////////////////////////////////////////////
class dii_rtl_agent_config extends uvm_object;

    virtual <%=obj.BlockId%>_dii_rtl_if  m_vif;
    `uvm_object_param_utils(dii_rtl_agent_config)

    uvm_active_passive_enum active = UVM_PASSIVE;

    extern function new(string name = "dii_rtl_agent_config");

endclass: dii_rtl_agent_config

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dii_rtl_agent_config::new(string name = "dii_rtl_agent_config");
    super.new(name);
endfunction : new

