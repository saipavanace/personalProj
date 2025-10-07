///////////////////////////////
// Event Agent
// Author: Abdelaziz EL HAMADI
//////////////////////////////
class event_agent extends uvm_agent;

`uvm_component_param_utils(event_agent)

    event_agent_config m_cfg;
    event_driver       m_driver;
    event_monitor      m_monitor;
    event_sequencer    m_sequencer;
    
    uvm_analysis_port #(event_pkt)  event_sender_ap_master;
    uvm_analysis_port #(event_pkt)  event_receiver_ap_slave;

    extern function new(string name = "event_agent", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);    

endclass

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function event_agent::new(string name = "event_agent", uvm_component parent = null);
  super.new(name, parent);
  event_sender_ap_master  = new("event_sender_ap_master",this);
  event_receiver_ap_slave = new("event_receiver_ap_slave",this);
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void event_agent::build_phase(uvm_phase phase);

  <% if(obj.testBench=="fsys" || obj.testBench =="io_aiu"){ %>
  <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %>
 if (!uvm_config_db#(<%=obj.BlockId%>_event_agent_pkg::event_agent_config)::get(.cntxt( this ), 
                                             .inst_name ( "" ), 
                                             .field_name( "event_agent_config" ),
                                             .value( m_cfg ))) begin
    `uvm_error( "event_agent", "event_agent_config not found" )
  end
   <% } %>
   <% } %>
  m_monitor    = event_monitor::type_id::create("m_monitor", this);
  m_driver     = event_driver::type_id::create("m_driver", this);
  m_sequencer  = event_sequencer::type_id::create("m_sequencer", this);

endfunction: build_phase

//------------------------------------------------------------------------------
// Connect Phase
//------------------------------------------------------------------------------
function void event_agent::connect_phase(uvm_phase phase);

  super.connect_phase(phase);

  <% if(obj.testBench=="fsys"|| obj.testBench =="io_aiu"){ %>
  <% if( obj.AiuInfo[obj.Id].interfaces.eventRequestInInt._SKIP_ == false) { %>
  m_driver.m_vif_master = m_cfg.m_vif_master;
  m_monitor.m_vif_master  = m_cfg.m_vif_master;
  event_sender_ap_master  = m_monitor.event_sender_ap_master;
   <% } %>

  <% if(obj.AiuInfo[obj.Id].interfaces.eventRequestOutInt._SKIP_ == false  ) { %>
  m_driver.m_vif_slave  = m_cfg.m_vif_slave;
  m_monitor.m_vif_slave   = m_cfg.m_vif_slave;
  event_receiver_ap_slave = m_monitor.event_receiver_ap_slave;
   <% } %>
  m_driver.seq_item_port.connect(m_sequencer.seq_item_export);
   <% } %>
endfunction: connect_phase
