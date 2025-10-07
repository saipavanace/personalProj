///////////////////////////////
// Event Monitor
// Author: Abdelaziz EL HAMADI
//////////////////////////////

class event_signals extends uvm_sequence_item;

   `uvm_object_param_utils(event_signals)
   bit     req=0;
   bit     ack=1;
   bit     has_error=1;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------

    function new(string name = "event_signals");
     super.new(name);  
     // enbaling sys_event master to create sys_req
     if(!$value$plusargs("en_sys_event_master=%0d", req)) begin
        req = 0;
     end
     if(!$value$plusargs("en_sys_event_hds_timeout=%0d", has_error)) begin
        has_error = 0;
     end
    endfunction : new

//------------------------------------------------------------------------------
// Do Copy
//------------------------------------------------------------------------------
function void do_copy(uvm_object rhs);
  event_signals rhs_;

  if(!$cast(rhs_, rhs)) begin
    `uvm_fatal("do_copy", "cast of rhs object failed")
  end
  super.do_copy(rhs);
  // Copy over data members:
  req       = rhs_.req;
  ack       = rhs_.ack;
  has_error = rhs_.has_error;

endfunction : do_copy

endclass // event_signals