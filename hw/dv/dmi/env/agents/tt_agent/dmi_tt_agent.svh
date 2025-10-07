////////////////////////////////////////////////////////////////////////////////
//
// DMI TT Agents
//
////////////////////////////////////////////////////////////////////////////////
class <%=obj.BlockId%>_tt_agent extends uvm_component;

   `uvm_component_utils(<%=obj.BlockId%>_tt_agent)


   uvm_analysis_port #(<%=obj.BlockId%>_tt_alloc_pkt) tt_alloc_ap;

   <%=obj.BlockId%>_tt_alloc_monitor      m_tt_monitor;
   <%=obj.BlockId%>_tt_agent_config       m_tt_agent_cfg;

   extern function new(string name = "<%=obj.BlockId%>_tt_agent", uvm_component parent = null);
   extern function void build_phase(uvm_phase phase);
   extern function void connect_phase(uvm_phase phase);

endclass: <%=obj.BlockId%>_tt_agent

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function <%=obj.BlockId%>_tt_agent::new(string name = "<%=obj.BlockId%>_tt_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void <%=obj.BlockId%>_tt_agent::build_phase(uvm_phase phase);
   m_tt_monitor = <%=obj.BlockId%>_tt_alloc_monitor::type_id::create("m_tt_monitor", this);

   tt_alloc_ap = new("tt_alloc_ap", this);

   if (!uvm_config_db#(<%=obj.BlockId%>_tt_agent_config)::get(.cntxt( this ), 
                                             .inst_name ( "" ), 
                                             .field_name( "m_<%=obj.BlockId%>_tt_agent_config" ),
                                             .value( m_tt_agent_cfg ))) begin
    `uvm_error( "<%=obj.BlockId%>_tt_agent", "<%=obj.BlockId%>_tt_agent_config not found" )
  end

  m_tt_monitor.m_vif = m_tt_agent_cfg.m_vif;

endfunction: build_phase

//------------------------------------------------------------------------------
// Connect Phase
//------------------------------------------------------------------------------
function void <%=obj.BlockId%>_tt_agent::connect_phase(uvm_phase phase);
  //super.connect_phase(phase);

   m_tt_monitor.m_vif = m_tt_agent_cfg.m_vif;

   tt_alloc_ap = m_tt_monitor.tt_alloc_ap;

endfunction: connect_phase
