class chi_subsys_write_excl_seq extends chi_subsys_base_seq;
    `svt_xvm_object_utils(chi_subsys_write_excl_seq)
    `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

    function new(string name = "chi_subsys_write_excl_seq");
        super.new(name);
        use_directed_mem_attr = 0;
        use_directed_snp_attr = 0;
        use_directed_addr = 1;
        use_directed_snp_attr = 1;
        use_directed_non_secure_access = 1;
        use_directed_allocate_in_cache = 0;
        use_directed_data_size = 0;
        blocking_mode = 1;
    endfunction: new

    virtual task body();
        super.body();
    endtask: body
    virtual function void assign_weights();

    endfunction: assign_weights

endclass: chi_subsys_write_excl_seq