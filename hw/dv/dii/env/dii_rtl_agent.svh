////////////////////////////////////////////////////////////////////////////////
//
// DII RTL Agent
//
////////////////////////////////////////////////////////////////////////////////
class dii_rtl_agent extends uvm_component;

    `uvm_component_param_utils(dii_rtl_agent)
    dii_rtl_agent_config m_rtl_agent_cfg;


    uvm_analysis_port #(axi2cmd_t) axi2cmd_rtt_ap;
    uvm_analysis_port #(axi2cmd_t) axi2cmd_wtt_ap;
    uvm_analysis_port #(event_in_t) evt_ap;

    dii_rtl_monitor   m_rtl_monitor;

    extern function new(string name = "dii_rtl_agent", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

endclass: dii_rtl_agent

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dii_rtl_agent::new(string name = "dii_rtl_agent", uvm_component parent = null);
    super.new(name, parent);
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void dii_rtl_agent::build_phase(uvm_phase phase);
    m_rtl_monitor = dii_rtl_monitor::type_id::create("m_rtl_monitor", this);

    axi2cmd_rtt_ap = new("axi2cmd_rtt_ap", this);
    axi2cmd_wtt_ap = new("axi2cmd_wtt_ap", this);
    evt_ap	       = new("evt_ap", this);

    if (
        !
        uvm_config_db#(dii_rtl_agent_config)::get(
            .cntxt( this ),
            .inst_name ( "" ),
            .field_name( "dii_rtl_agent_config" ),
            .value( m_rtl_agent_cfg )
        )
    ) begin
        `uvm_error( "dii_agent", "dii_rtl_agent_config not found" )
    end

endfunction: build_phase


//------------------------------------------------------------------------------
// Connect Phase
//------------------------------------------------------------------------------
function void dii_rtl_agent::connect_phase(uvm_phase phase);
    
    m_rtl_monitor.m_vif = m_rtl_agent_cfg.m_vif;

    axi2cmd_rtt_ap = m_rtl_monitor.axi2cmd_rtt_ap;
    axi2cmd_wtt_ap = m_rtl_monitor.axi2cmd_wtt_ap;
    evt_ap	       = m_rtl_monitor.evt_ap;

endfunction: connect_phase

