////////////////////////////////////////////////////////////////////////////////
//
// AXI Master Agent
//
////////////////////////////////////////////////////////////////////////////////

class apb_agent extends uvm_component;

  `uvm_component_param_utils(apb_agent)

  apb_agent_config m_cfg;

  apb_driver  m_apb_driver;
  apb_monitor  m_apb_monitor;
  apb_sequencer m_apb_sequencer;

  apb_reg_adapter m_apb_reg_adapter;

  extern function new(string name = "apb_agent", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass: apb_agent

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function apb_agent::new(string name = "apb_agent", uvm_component parent = null);
   super.new(name, parent);
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void apb_agent::build_phase(uvm_phase phase);
   if (!uvm_config_db#(apb_agent_config)::get(.cntxt( this ), 
                .inst_name ( "" ), 
                .field_name( "apb_agent_config" ),
                .value( m_cfg )))
   begin
      `uvm_error( "apb_agent", "apb_agent_config not found" )
   end

   if (m_cfg.has_driver) begin
      m_apb_driver  = apb_driver::type_id::create("m_apb_driver", this);
      m_apb_sequencer = apb_sequencer::type_id::create("m_apb_sequencer", this);
   end
   m_apb_monitor = apb_monitor::type_id::create("m_apb_monitor", this);
   m_apb_reg_adapter = apb_reg_adapter::type_id::create(.name( "m_apb_reg_adapter"));

endfunction: build_phase

//------------------------------------------------------------------------------
// Connect Phase
//------------------------------------------------------------------------------
function void apb_agent::connect_phase(uvm_phase phase);

   if (m_cfg.has_driver) begin
        m_apb_driver.m_vif                       = m_cfg.m_vif;
        m_apb_driver.seq_item_port.connect(m_apb_sequencer.seq_item_export);
   end
        m_apb_monitor.m_vif                      = m_cfg.m_vif;


endfunction: connect_phase




