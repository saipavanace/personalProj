///////////////////////////////
// Event Monitor
// Author: Abdelaziz EL HAMADI
//////////////////////////////

class event_pkt extends uvm_object;

   bit     req, prev_req;
   bit     ack,prev_ack;
  longint cycle_counter;
//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
    `uvm_object_param_utils_begin(event_pkt)
        `uvm_field_int     (req, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (prev_req, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (ack, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int     (prev_ack, UVM_DEFAULT + UVM_NOPRINT)
        `uvm_field_int (cycle_counter, UVM_DEFAULT + UVM_NOPRINT)
    `uvm_object_utils_end

    function new(string name = "event_pkt");
     super.new(name);  
    endfunction : new

   function string convert2string();
      string s;

      $sformat (s, "%s req:%0b prev_req:%0b ack:%0b prev_ack:%0b ", s, req,prev_req, ack,prev_ack); 

      return s;
   endfunction: convert2string


endclass // event_pkt
