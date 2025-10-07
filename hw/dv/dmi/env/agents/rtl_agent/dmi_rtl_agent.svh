////////////////////////////////////////////////////////////////////////////////
//
// DMI Agent
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// DMI RTL Agents
//
////////////////////////////////////////////////////////////////////////////////
class <%=obj.BlockId%>_rtl_agent extends uvm_component;

   `uvm_component_utils(<%=obj.BlockId%>_rtl_agent)


   uvm_analysis_port #(<%=obj.BlockId%>_rtl_cmd_rsp_pkt) rtl_cmd_rsp_ap;

   <%=obj.BlockId%>_rtl_monitor      m_rtl_monitor;
   <%=obj.BlockId%>_rtl_agent_config m_rtl_cfg;

   extern function new(string name = "<%=obj.BlockId%>_rtl_agent", uvm_component parent = null);
   extern function void build_phase(uvm_phase phase);
   extern function void connect_phase(uvm_phase phase);

endclass: <%=obj.BlockId%>_rtl_agent

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function <%=obj.BlockId%>_rtl_agent::new(string name = "<%=obj.BlockId%>_rtl_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void <%=obj.BlockId%>_rtl_agent::build_phase(uvm_phase phase);
   m_rtl_monitor = <%=obj.BlockId%>_rtl_monitor::type_id::create("m_rtl_monitor", this);

   rtl_cmd_rsp_ap = new("rtl_cmd_rsp_ap", this);

   if (!uvm_config_db#(<%=obj.BlockId%>_rtl_agent_config)::get(.cntxt( this ), 
                                             .inst_name ( "" ), 
                                             .field_name( "m_<%=obj.BlockId%>_rtl_agent_config" ),
                                             .value( m_rtl_cfg ))) begin
    `uvm_error( "dmi_agent", "<%=obj.BlockId%>_rtl_agent_config not found" )
  end

  m_rtl_monitor.m_vif = m_rtl_cfg.m_vif;

endfunction: build_phase

//------------------------------------------------------------------------------
// Connect Phase
//------------------------------------------------------------------------------
function void <%=obj.BlockId%>_rtl_agent::connect_phase(uvm_phase phase);
  //super.connect_phase(phase);

   m_rtl_monitor.m_vif = m_rtl_cfg.m_vif;

   rtl_cmd_rsp_ap = m_rtl_monitor.cmd_rsp_ap;

endfunction: connect_phase
