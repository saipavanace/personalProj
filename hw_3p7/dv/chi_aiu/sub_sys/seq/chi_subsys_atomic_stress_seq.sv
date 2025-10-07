class chi_subsys_atomic_stress_seq extends chi_subsys_base_seq;
    `svt_xvm_object_utils(chi_subsys_atomic_stress_seq)
    `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

    function new(string name = "chi_subsys_atomic_stress_seq");
        super.new(name);
        use_directed_addr = 1;
        use_directed_mem_attr = 0;
        use_directed_non_secure_access = 1;
        use_directed_snp_attr = 0;
        use_seq_order_type = 0;
    endfunction: new

    virtual task body();
        enable_all_weights();
        super.body();
    endtask: body

    virtual function void assign_weights();
        disable_all_weights();
        atomiccompare_wt = 1; 
        atomicload_add_wt = 1; 
        atomicload_clr_wt = 1; 
        atomicload_eor_wt = 1; 
        atomicload_set_wt = 1; 
        atomicload_smax_wt = 1; 
        atomicload_smin_wt = 1; 
        atomicload_umax_wt = 1; 
        atomicload_umin_wt = 1; 
        atomicstore_add_wt = 1; 
        atomicstore_clr_wt = 1; 
        atomicstore_eor_wt = 1; 
        atomicstore_set_wt = 1; 
        atomicstore_smax_wt = 1; 
        atomicstore_smin_wt = 1; 
        atomicstore_umax_wt = 1; 
        atomicstore_umin_wt = 1; 
        atomicswap_wt = 1; 
    endfunction: assign_weights

endclass: chi_subsys_atomic_stress_seq