class chi_subsys_comb_wrcmo_seq extends chi_subsys_base_seq;
    `svt_xvm_object_utils(chi_subsys_comb_wrcmo_seq)
    `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

    function new(string name = "chi_subsys_comb_wrcmo_seq");
        super.new(name);
        use_directed_addr = 0;
        use_directed_mem_attr = 0;
        use_directed_non_secure_access = 0;
        use_directed_snp_attr = 0;
        use_seq_order_type = 0;
    endfunction: new

    virtual task body();
        super.body();
    endtask: body

    virtual function void assign_weights();
        <%if (obj.AiuInfo[obj.Id].fnNativeInterface == "CHI-E") {%>
            writenosnpfull_cleaninvalid_wt = 1;
            writenosnpfull_cleanshared_wt = 1;
            writenosnpfull_cleansharedpersistsep_wt = 1;
            writebackfull_cleanshared_wt = 1;
            writebackfull_cleansharedpersistsep_wt = 1;
            writecleanfull_cleanshared_wt = 1;
            writecleanfull_cleansharedpersistsep_wt = 1;
            writecleanfull_wt = 1;
        <%}%>
    endfunction: assign_weights

endclass: chi_subsys_comb_wrcmo_seq
