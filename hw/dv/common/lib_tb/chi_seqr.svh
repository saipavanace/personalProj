////////////////////////////////////////////////////////////////////////////////
// 
// Author       : Muffadal 
// Purpose      : CHI sequence item 
// Revision     :
//
//
////////////////////////////////////////////////////////////////////////////////

class chi_chnl_sequencer#(type REQ = chi_base_seq_item, type RSP = REQ) extends uvm_sequencer#(REQ, RSP);

    `uvm_component_param_utils(chi_chnl_sequencer#(REQ, RSP))

    //Methods
    function new(string name = "chi_chnl_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new
endclass: chi_chnl_sequencer

