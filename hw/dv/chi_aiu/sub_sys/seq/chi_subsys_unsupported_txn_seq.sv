class chi_subsys_unsupported_txn_seq extends chi_subsys_base_seq;
    `svt_xvm_object_utils(chi_subsys_unsupported_txn_seq)
    `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

    function new(string name = "chi_subsys_unsupported_txn_seq");
        super.new(name);
        use_directed_addr = 0;
        use_directed_mem_attr = 0;
        use_directed_non_secure_access = 0;
        use_directed_snp_attr = 0;
        use_seq_order_type = 0;
    endfunction: new

    virtual task body();
        enable_all_weights();
        super.body();
    endtask: body

    virtual task disable_unsupported_txns();

    endtask: disable_unsupported_txns

    virtual function void assign_weights();
        disable_all_weights();
        // stashonceunique_wt = 1;
        // writeuniquefullstash_wt = 1;
        // writeuniqueptlstash_wt = 1;
        // pcrdreturn_wt = 1;
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            writeuniquefull_cleanshared_wt = 1;
            writeuniqueptl_cleanshared_wt = 1;
            writeuniquefull_cleansharedpersistsep_wt = 1;
            writeuniqueptl_cleansharedpersistsep_wt = 1;
            writenosnpptl_cleanshared_wt = 1;
            writenosnpptl_cleaninvalid_wt = 1;
            writenosnpptl_cleansharedpersistsep_wt = 1;
            stashoncesepunique_wt = 1;
            stashoncesepshared_wt = 1;
            writeevictorevict_wt = 1;
        <% } %>	
        eobarrier_wt = 1;
        ecbarrier_wt = 1;
    endfunction: assign_weights

endclass: chi_subsys_unsupported_txn_seq