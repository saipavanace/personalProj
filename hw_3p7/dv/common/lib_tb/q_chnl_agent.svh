////////////////////////////////////////////////////////////////////////////////
//
// Q channel Agent
//
////////////////////////////////////////////////////////////////////////////////
class q_chnl_agent extends uvm_component;

  `uvm_component_param_utils(q_chnl_agent)

  q_chnl_agent_config m_cfg;

  uvm_analysis_port #(q_chnl_seq_item)  q_chnl_ap;
 
  q_chnl_monitor     m_q_chnl_monitor;
  q_chnl_driver      m_q_chnl_driver;
  q_chnl_sequencer   m_q_chnl_seqr;


  extern function new(string name = "q_chnl_agent", uvm_component parent = null);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);

endclass: q_chnl_agent

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function q_chnl_agent::new(string name = "q_chnl_agent", uvm_component parent = null);
    super.new(name, parent);
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void q_chnl_agent::build_phase(uvm_phase phase);
    if (!uvm_config_db#(q_chnl_agent_config)::get(.cntxt( this ), 
                .inst_name ( "" ), 
                .field_name( "q_chnl_agent_config" ),
                .value( m_cfg))) begin
        `uvm_error( "q_chnl_agent", "q_chnl_agent_config not found" )
    end


    m_q_chnl_monitor = q_chnl_monitor::type_id::create("m_monitor", this);
    
    if(m_cfg.active == UVM_ACTIVE) begin
        m_q_chnl_driver  = q_chnl_driver::type_id::create("m_q_chnl_driver", this);
        m_q_chnl_seqr    = q_chnl_sequencer::type_id::create("m_q_chnl_seqr", this);
    end
endfunction: build_phase

//------------------------------------------------------------------------------
// Connect Phase
//------------------------------------------------------------------------------
function void q_chnl_agent::connect_phase(uvm_phase phase);
    m_q_chnl_monitor.m_vif    = m_cfg.m_vif;
    q_chnl_ap                 = m_q_chnl_monitor.q_chnl_ap;

    if(m_cfg.active == UVM_ACTIVE) begin
        //m_q_chnl_monitor.m_vif.IS_ACTIVE = 1;

        m_q_chnl_driver.seq_item_port.connect(m_q_chnl_seqr.seq_item_export);
        m_q_chnl_driver.m_vif = m_cfg.m_vif;
        m_q_chnl_driver.time_bw_Q_chnl_req = m_cfg.time_bw_Q_chnl_req;
    end
endfunction: connect_phase

