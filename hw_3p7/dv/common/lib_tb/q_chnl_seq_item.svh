////////////////////////////////////////////////////////////////////////////////
//
// Q channel Seq Item 
//
////////////////////////////////////////////////////////////////////////////////
class q_chnl_seq_item extends uvm_sequence_item;

  rand bit QREQn;
  bit QACCEPTn;
  bit QDENY;
  bit QACTIVE;
  // Currently this is not being used, may delete it later
  bit [2:0] IF_state_before_req;

  `uvm_object_utils_begin(q_chnl_seq_item)
     `uvm_field_int  (QREQn, UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_int  (QACCEPTn, UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_int  (QDENY, UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_int  (QACTIVE, UVM_DEFAULT + UVM_NOPRINT)
     `uvm_field_int  (IF_state_before_req, UVM_DEFAULT + UVM_NOPRINT)
  `uvm_object_utils_end
  //------------------------------------------------------------------------------
  // Constructor
  //------------------------------------------------------------------------------
  function new(string name = "q_chnl_seq_item");
    super.new(name);
  endfunction : new
  ////////////////////////////////////////////////////////////////////////////////
  
  endclass : q_chnl_seq_item 


