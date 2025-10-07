class chi_subsys_random_coherency_seq extends chi_subsys_base_seq;
    `svt_xvm_object_utils(chi_subsys_random_coherency_seq)
    `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

    function new(string name = "chi_subsys_random_coherency_seq");
        super.new(name);
        use_directed_addr = 1;
        use_directed_mem_attr = 0;
        use_directed_non_secure_access = 1;
        use_directed_snp_attr = 0;
        use_seq_order_type = 0;
    endfunction: new

    virtual task body();
        super.body();
    endtask: body

endclass: chi_subsys_random_coherency_seq