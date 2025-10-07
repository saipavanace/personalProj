class <%=obj.BlockId%>_clock_counter_seq_item extends uvm_sequence_item;

  longint cycle_counter;
  time   current_time;
  bit [127:0] probe_sig1;
   
  `uvm_object_utils_begin(<%=obj.BlockId%>_clock_counter_seq_item)
     `uvm_field_int  (cycle_counter, UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_int  (current_time, UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_int  (probe_sig1, UVM_DEFAULT + UVM_NOPRINT)
  `uvm_object_utils_end

  function new(string name = "clock_counter_seq_item");
    super.new(name);
  endfunction : new

endclass : <%=obj.BlockId%>_clock_counter_seq_item
