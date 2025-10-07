class chi_subsys_dvmop_seq extends chi_subsys_base_seq;
    `svt_xvm_object_utils(chi_subsys_dvmop_seq)
    `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

    function new(string name = "chi_subsys_dvmop_seq");
        super.new(name);
        use_directed_addr = 0;
        use_directed_mem_attr = 0;
        use_directed_non_secure_access = 0;
        use_directed_snp_attr = 0;
        use_seq_order_type = 0;
    endfunction: new

    virtual task body();
    //#Stimulus.CHI.v3.6.DVM_req_p1
    //#Stimulus.CHI.v3.6.DVM_req_p2
        super.body();
    endtask: body

    virtual function void assign_weights();
        disable_all_weights();
        dvmop_wt = 1;
    endfunction: assign_weights

endclass: chi_subsys_dvmop_seq