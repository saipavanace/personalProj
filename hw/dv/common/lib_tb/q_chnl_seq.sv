
//NOTE: randomization of QREQn is independent of QACTIVE in below sequence
class q_chnl_seq extends uvm_sequence #(q_chnl_seq_item);

    `uvm_object_param_utils(q_chnl_seq)

    q_chnl_seq_item    m_seq_item;
    bit                should_randomize=1;

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function new(string name = "q_chnl_seq");
    super.new(name);
endfunction : new

//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task body;

    // FIXME: is it needed to constrain the randomization to send different output than
    //previous one as the next request would come after some specified cycles.
       bit success=0;

       m_seq_item = q_chnl_seq_item::type_id::create("m_seq_item");
       start_item(m_seq_item);
       //Asserting QREQn 
       m_seq_item.QREQn = 0;
       finish_item(m_seq_item);

endtask : body

endclass : q_chnl_seq

