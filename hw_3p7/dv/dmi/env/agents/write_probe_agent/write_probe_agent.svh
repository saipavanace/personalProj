////////////////////////////////////////////////////////////////////////////////
//
// DMI Agent
//
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// Agent to probe the read prot arbiter to help predict read ordering
//
////////////////////////////////////////////////////////////////////////////////
class <%=obj.BlockId%>_write_probe_agent extends uvm_component;

   `uvm_component_utils(<%=obj.BlockId%>_write_probe_agent)


   uvm_analysis_port #(<%=obj.BlockId%>_write_probe_txn) write_probe_ap;

   <%=obj.BlockId%>_write_probe_monitor      m_write_probe_monitor;
   <%=obj.BlockId%>_write_probe_agent_config m_write_cfg;

   extern function new(string name = "<%=obj.BlockId%>_write_probe_agent", uvm_component parent = null);
   extern function void build_phase(uvm_phase phase);
   extern function void connect_phase(uvm_phase phase);

endclass: <%=obj.BlockId%>_write_probe_agent

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function <%=obj.BlockId%>_write_probe_agent::new(string name = "<%=obj.BlockId%>_write_probe_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void <%=obj.BlockId%>_write_probe_agent::build_phase(uvm_phase phase);
   m_write_probe_monitor = <%=obj.BlockId%>_write_probe_monitor::type_id::create("m_write_probe_monitor", this);

   write_probe_ap = new("write_probe_ap", this);

   if (!uvm_config_db#(<%=obj.BlockId%>_write_probe_agent_config)::get(.cntxt( this ), 
                                             .inst_name ( "" ), 
                                             .field_name( "m_<%=obj.BlockId%>_write_probe_agent_config" ),
                                             .value( m_write_cfg ))) begin
    `uvm_error( "dmi_agent", "<%=obj.BlockId%>_write_probe_agent_config not found" )
  end

endfunction: build_phase

//------------------------------------------------------------------------------
// Connect Phase
//------------------------------------------------------------------------------
function void <%=obj.BlockId%>_write_probe_agent::connect_phase(uvm_phase phase);
  //super.connect_phase(phase);

   m_write_probe_monitor.m_vif = m_write_cfg.m_vif;

   write_probe_ap = m_write_probe_monitor.ap;

endfunction: connect_phase
