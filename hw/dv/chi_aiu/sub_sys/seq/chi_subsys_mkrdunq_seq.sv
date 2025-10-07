class chi_subsys_mkrdunq_seq extends svt_chi_rn_coherent_transaction_base_sequence;
    `svt_xvm_object_utils(chi_subsys_mkrdunq_seq)
    `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

    function new(string name = "chi_subsys_mkrdunq_seq");
        super.new(name);
        use_directed_addr = 1;
        use_directed_mem_attr = 0;
        use_directed_snp_attr = 0;
        use_directed_non_secure_access = 1;
        use_directed_allocate_in_cache = 0;
        use_directed_data_size = 0;
        blocking_mode = 1;
    endfunction: new

    virtual task body();
        super.body();
    endtask: body

    virtual function assign_weights();

    endfunction: assign_weights

endclass: chi_subsys_mkrdunq_seq