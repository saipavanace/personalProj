
//
// dce_irq_agent.svh
//

class <%=obj.BlockId%>_irq_agent extends uvm_component;

    `uvm_component_utils(<%=obj.BlockId%>_irq_agent)

    <%=obj.BlockId%>_irq_driver     m_drvr;
    <%=obj.BlockId%>_irq_sequencer  m_seqr;
    <%=obj.BlockId%>_irq_cfg        m_cfg;
    
    virtual <%=obj.BlockId%>_irq_if m_vif;

    extern function new(string name = "<%=obj.BlockId%>_irq_agent", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

endclass: <%=obj.BlockId%>_irq_agent

//new
function <%=obj.BlockId%>_irq_agent::new(string name = "<%=obj.BlockId%>_irq_agent",
    uvm_component parent = null);
    super.new(name, parent);
endfunction: new

//build_phase
function void <%=obj.BlockId%>_irq_agent::build_phase(uvm_phase phase);

  if (!uvm_config_db #(<%=obj.BlockId%>_irq_cfg)::get(.cntxt(this), 
                                                      .inst_name ( "" ), 
                                                      .field_name( "<%=obj.BlockId%>_irq_cfg" ),
                                                      .value(m_cfg))) begin
    `uvm_error( "sfi_master_agent", "sfi_agent_config not found" )
  end

  m_vif = m_cfg.m_vif;
  m_drvr = <%=obj.BlockId%>_irq_driver::type_id::create("m_drvr", this);
  m_seqr =<%=obj.BlockId%>_irq_sequencer::type_id::create("m_seqr", this); 

endfunction: build_phase

function void <%=obj.BlockId%>_irq_agent::connect_phase(uvm_phase phase);
    m_drvr.m_vif = m_vif;
    m_drvr.mode_of_operation = m_cfg.mode_of_operation;
    m_drvr.seq_item_port.connect(m_seqr.seq_item_export);
endfunction: connect_phase

