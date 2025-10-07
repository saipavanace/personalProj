////////////////////////////////////////////////////////////////////////////////
//
// SMI Sequence 
<% if (1 == 0) { %>
// Author: Chirag Gandhi
<% } %>
//
////////////////////////////////////////////////////////////////////////////////


class smi_seq extends uvm_sequence;

    `uvm_object_param_utils(smi_seq)

    smi_seq_item m_seq_item;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new (string name = "smi_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;
    bit success;
//   `uvm_info("SMI_SEQ_BODY", $psprintf("MsgType:%p MsgId:%p Addr:%p", m_seq_item.smi_msg_type, m_seq_item.smi_msg_id, m_seq_item.smi_addr), UVM_NONE)
    start_item(m_seq_item);
    finish_item(m_seq_item);
endtask : body

task return_response(/*output smi_seq_item m_return_seq_item,*/ input uvm_sequencer_base seqr, input uvm_sequence_base parent = null);
    //smi_seq_item m_local_return_seq_item;
    //m_local_return_seq_item = smi_seq_item::type_id::create("m_local_return_seq_item");
    if (seqr == null) begin
        `uvm_error("smi_seq", "sequencer passed to sequence is null")
    end 
//    `uvm_info("SMI_SEQ_RTN_RSP", $psprintf("MsgType:%p MsgId:%p Addr:%p", m_seq_item.smi_msg_type, m_seq_item.smi_msg_id, m_seq_item.smi_addr), UVM_NONE)
    this.start(seqr, parent);
    //m_local_return_seq_item.do_copy(m_seq_item);
    //m_return_seq_item = m_local_return_seq_item;
endtask : return_response

endclass : smi_seq 


