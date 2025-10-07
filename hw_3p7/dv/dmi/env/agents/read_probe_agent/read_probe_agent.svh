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
class <%=obj.BlockId%>_read_probe_agent extends uvm_component;

   `uvm_component_utils(<%=obj.BlockId%>_read_probe_agent)


   uvm_analysis_port #(<%=obj.BlockId%>_read_probe_txn) read_probe_ap;

   <%=obj.BlockId%>_read_probe_monitor      m_read_probe_monitor;
   <%=obj.BlockId%>_read_probe_agent_config m_read_probe_cfg;

   extern function new(string name = "<%=obj.BlockId%>_read_probe_agent", uvm_component parent = null);
   extern function void build_phase(uvm_phase phase);
   extern function void connect_phase(uvm_phase phase);

endclass: <%=obj.BlockId%>_read_probe_agent

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function <%=obj.BlockId%>_read_probe_agent::new(string name = "<%=obj.BlockId%>_read_probe_agent", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void <%=obj.BlockId%>_read_probe_agent::build_phase(uvm_phase phase);
   m_read_probe_monitor = <%=obj.BlockId%>_read_probe_monitor::type_id::create("m_read_probe_monitor", this);

   read_probe_ap = new("read_probe_ap", this);

   if (!uvm_config_db#(<%=obj.BlockId%>_read_probe_agent_config)::get(.cntxt( this ), 
                                             .inst_name ( "" ), 
                                             .field_name( "m_<%=obj.BlockId%>_read_probe_agent_config" ),
                                             .value( m_read_probe_cfg ))) begin
    `uvm_error( "dmi_agent", "<%=obj.BlockId%>_read_probe_agent_config not found" )
  end

endfunction: build_phase

//------------------------------------------------------------------------------
// Connect Phase
//------------------------------------------------------------------------------
function void <%=obj.BlockId%>_read_probe_agent::connect_phase(uvm_phase phase);
  //super.connect_phase(phase);

   m_read_probe_monitor.m_vif = m_read_probe_cfg.m_vif;

   read_probe_ap = m_read_probe_monitor.ap;

endfunction: connect_phase
