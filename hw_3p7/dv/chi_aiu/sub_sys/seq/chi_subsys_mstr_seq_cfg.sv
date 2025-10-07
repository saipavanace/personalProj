class chi_subsys_mstr_seq_cfg extends uvm_object;
    `uvm_object_utils(chi_subsys_mstr_seq_cfg);

    int num_txns;
    bit reduce_addr_area;
    int use_user_addrq=-1;
    bit en_excl_txn;

    
    function new(string name = "chi_subsys_mstr_seq_cfg");
        super.new(name);
	
         uvm_config_db#(bit)::get(null,"*","chi_subsys_mstr_seq_cfg_en_excl_txn",en_excl_txn); 

    endfunction:new


endclass: chi_subsys_mstr_seq_cfg
