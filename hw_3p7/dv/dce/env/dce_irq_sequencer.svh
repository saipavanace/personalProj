////////////////////////////////////////////////////////////////////////////////
//
// DCE IRQ Sequencer
//
////////////////////////////////////////////////////////////////////////////////
class <%=obj.BlockId%>_irq_sequencer extends uvm_sequencer #(<%=obj.BlockId%>_irq_seq_item);

  `uvm_component_utils(<%=obj.BlockId%>_irq_sequencer)

  extern function new(string name="<%=obj.BlockId%>_irq_sequencer", uvm_component parent = null);

endclass: <%=obj.BlockId%>_irq_sequencer

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function <%=obj.BlockId%>_irq_sequencer::new(string name="<%=obj.BlockId%>_irq_sequencer",
    uvm_component parent = null);

  super.new(name, parent);
endfunction: new

////////////////////////////////////////////////////////////////////////////////
//
// DCE IRQ Config Object
//
////////////////////////////////////////////////////////////////////////////////

class <%=obj.BlockId%>_irq_cfg extends uvm_object;

  `uvm_object_utils(<%=obj.BlockId%>_irq_cfg)

  //properties
  virtual <%=obj.BlockId%>_irq_if m_vif;
  //0 Slave mode
  //1 Master mode
  bit mode_of_operation;

  extern function new(string name="<%=obj.BlockId%>_irq_cfg");
  extern function set_master_mode();

endclass: <%=obj.BlockId%>_irq_cfg

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function <%=obj.BlockId%>_irq_cfg::new(string name="<%=obj.BlockId%>_irq_cfg");
  super.new(name);
endfunction: new

function <%=obj.BlockId%>_irq_cfg::set_master_mode();
    mode_of_operation = 1'b1;
endfunction: set_master_mode
