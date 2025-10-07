/////////////////////////TB_ apb_sequencer //////////////////////
// Unidirectional driver uses the get_next_item(), item_done() approach
//////////////////////////////////////////////////////////////////
class apb_sequencer extends uvm_sequencer#(apb_pkt_t);

`uvm_component_param_utils(apb_sequencer)

function new(string name = "apb_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction

endclass: apb_sequencer


