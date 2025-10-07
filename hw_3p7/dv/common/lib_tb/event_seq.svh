class event_seq extends uvm_sequence #(event_signals);

  `uvm_object_param_utils(event_seq)

  event_signals m_seq_item;
  
//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "event_seq");
    super.new(name);
endfunction : new
//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;
   m_seq_item = event_signals::type_id::create("m_seq_item");
    start_item(m_seq_item);

    finish_item(m_seq_item);
endtask : body


endclass : event_seq