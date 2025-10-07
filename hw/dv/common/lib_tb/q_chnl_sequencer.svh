class q_chnl_sequencer extends uvm_sequencer #(q_chnl_seq_item);
    `uvm_component_param_utils(q_chnl_sequencer)

    //Constructor 
    function new(input string name = "", uvm_component parent = null);
        super.new(name,parent);
    endfunction

endclass

