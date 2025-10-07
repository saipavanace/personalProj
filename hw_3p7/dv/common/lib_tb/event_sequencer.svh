///////////////////////////////
// EVent Sequencer
// Author: Abdelaziz EL HAMADI
//////////////////////////////
class event_sequencer extends uvm_sequencer #(event_signals);

`uvm_component_param_utils(event_sequencer)

function new(string name = "event_sequencer", uvm_component parent = null);
  super.new(name, parent);
endfunction

endclass: event_sequencer