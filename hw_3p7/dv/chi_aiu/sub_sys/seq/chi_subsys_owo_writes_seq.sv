class chi_subsys_owo_writes_seq extends chi_subsys_base_seq;
    `svt_xvm_object_utils(chi_subsys_owo_writes_seq)
    `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

    bit send_mkrdunq_txn = 0;
    chi_aiu_unit_args m_args;

    function new(string name = "chi_subsys_owo_writes_seq");
        super.new(name);
        use_directed_addr = 0;
        use_directed_mem_attr = 0;
        use_directed_snp_attr = 0;
        use_directed_allocate_in_cache = 0;
        use_directed_data_size = 0;
        use_seq_order_type = 1;
        $cast(seq_order_type, 2);
    endfunction: new

    virtual task body();
        super.body();
    endtask: body

    virtual function void assign_weights();
        super.assign_weights();
        disable_all_weights();
        k_exp_comp_ack = 1;
        writeuniqueptl_wt                           = 1;
        writeuniquefull_wt                          = 1;
        writenosnpptl_wt                            = 1;
        writenosnpfull_wt                           = 1;
	<% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
        writeuniquezero_wt                          = 1;
        writenosnpzero_wt                           = 1;
        writenosnpfull_cleanshared_wt               = 1;
        writenosnpfull_cleaninvalid_wt              = 1;
        writenosnpfull_cleansharedpersistsep_wt     = 1;
        writebackfull_cleanshared_wt                = 1;
        writebackfull_cleaninvalid_wt               = 1;
        writebackfull_cleansharedpersistsep_wt      = 1;
        writecleanfull_cleanshared_wt               = 1;
        writecleanfull_cleansharedpersistsep_wt     = 1;
	<% } %>
    endfunction: assign_weights

endclass: chi_subsys_owo_writes_seq
