import chi_ss_helper_pkg::*;

class chi_subsys_base_seq extends svt_chi_rn_coherent_transaction_base_sequence;

    `svt_xvm_object_utils(chi_subsys_base_seq)
    `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

    chi_aiu_unit_args m_args;

    int wt_read_preferunique;
    int wt_your_trans;
    int wt_make_readunique;
    int wt_cln_shrd_psist_sep;
    int wt_write_unique_zero;
    int wt_write_nosnp_zero;
    int wt_wrnosnpfull_clnshrd;
    int wt_wrnosnpfull_clninv;
    int wt_wrnosnpfull_clnshrd_persep;
    int wt_wrbkfull_clnshrd;
    int wt_wrbkfull_clninv;
    int wt_wrbkfull_clnshrd_persep;
    int wt_wrclnfull_clnshrd;
    int wt_wrclnfull_clnshrd_persep;

    bit disable_dvmop = 0;

    svt_axi_cache rn_cache;

    function new(string name = "chi_subsys_base_seq");
        super.new(name);
        use_directed_addr = 0;
        use_directed_mem_attr = 0;
        use_directed_non_secure_access = 0;
        use_directed_snp_attr = 0;
        use_seq_order_type = 0;
    endfunction // new
  
    virtual task body();
        assign_weights();
        disable_unsupported_txns();
        super.body();
    endtask: body

    virtual task disable_unsupported_txns();
        writeuniquefullstash_wt = 0;
        writeuniqueptlstash_wt = 0;
        reqlinkflit_wt = 0;
        pcrdreturn_wt = 0;
        <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
            writeuniquefull_cleanshared_wt = 0;
            writeuniqueptl_cleanshared_wt = 0;
            writeuniquefull_cleansharedpersistsep_wt = 0;
            writeuniqueptl_cleansharedpersistsep_wt = 0;
            writenosnpptl_cleanshared_wt = 0;
            writenosnpptl_cleaninvalid_wt = 0;
            writenosnpptl_cleansharedpersistsep_wt = 0;
            stashoncesepunique_wt = 0;
            stashoncesepshared_wt = 0;
        <% } %>	
        eobarrier_wt = 0;
        ecbarrier_wt = 0;
    endtask : disable_unsupported_txns

    virtual function void assign_weights();
        bit is_directed_test=0;
        int l_readpreferunique_wt, l_makereadunique_wt, l_cleansharedpersistsep_wt, l_writeuniquezero_wt, l_writenosnpzero_wt, l_writenosnpfull_cleanshared_wt, l_writenosnpfull_cleaninvalid_wt, l_writenosnpfull_cleansharedpersistsep_wt, l_writebackfull_cleanshared_wt, l_writebackfull_cleaninvalid_wt, l_writebackfull_cleansharedpersistsep_wt, l_writecleanfull_cleanshared_wt, l_writecleanfull_cleansharedpersistsep_wt, l_dvmop_wt, l_readshared_wt;

        if ($test$plusargs("wt_read_preferunique")) begin
            $value$plusargs("wt_read_preferunique=%d", l_readpreferunique_wt);
            is_directed_test=1;
        end
        if ($test$plusargs("wt_your_trans")) begin
            $value$plusargs("wt_your_trans=%d", l_readpreferunique_wt);
            is_directed_test=1;
        end
        if ($test$plusargs("wt_make_readunique")) begin
            $value$plusargs("wt_make_readunique=%d", l_makereadunique_wt);
            is_directed_test=1;
        end
        if ($test$plusargs("wt_cln_shrd_psist_sep")) begin
            $value$plusargs("wt_cln_shrd_psist_sep=%d", l_cleansharedpersistsep_wt);
            is_directed_test=1;
        end
        if ($test$plusargs("wt_write_unique_zero")) begin
            $value$plusargs("wt_write_unique_zero=%d", l_writeuniquezero_wt);
            is_directed_test=1;
        end
        if ($test$plusargs("wt_write_nosnp_zero")) begin
            $value$plusargs("wt_write_nosnp_zero=%d", l_writenosnpzero_wt);
            is_directed_test=1;
        end
        if ($test$plusargs("wt_wrnosnpfull_clnshrd")) begin
            $value$plusargs("wt_wrnosnpfull_clnshrd=%d", l_writenosnpfull_cleanshared_wt);
            is_directed_test=1;
        end
        if ($test$plusargs("wt_wrnosnpfull_clninv")) begin
            $value$plusargs("wt_wrnosnpfull_clninv=%d", l_writenosnpfull_cleaninvalid_wt);
            is_directed_test=1;
        end
        if ($test$plusargs("wt_wrnosnpfull_clnshrd_persep")) begin
            $value$plusargs("wt_wrnosnpfull_clnshrd_persep=%d", l_writenosnpfull_cleansharedpersistsep_wt);
            is_directed_test=1;
        end
        if ($test$plusargs("wt_wrbkfull_clnshrd")) begin
            $value$plusargs("wt_wrbkfull_clnshrd=%d", l_writebackfull_cleanshared_wt);
            is_directed_test=1;
        end
        if ($test$plusargs("wt_wrbkfull_clninv")) begin
            $value$plusargs("wt_wrbkfull_clninv=%d", l_writebackfull_cleaninvalid_wt);
            is_directed_test=1;
        end
        if ($test$plusargs("wt_wrbkfull_clnshrd_persep")) begin
            $value$plusargs("wt_wrbkfull_clnshrd_persep=%d", l_writebackfull_cleansharedpersistsep_wt);
            is_directed_test=1;
        end
        if ($test$plusargs("wt_wrclnfull_clnshrd")) begin
            $value$plusargs("wt_wrclnfull_clnshrd=%d", l_writecleanfull_cleanshared_wt);
            is_directed_test=1;
        end
        if ($test$plusargs("wt_wrclnfull_clnshrd_persep")) begin
            $value$plusargs("wt_wrclnfull_clnshrd_persep=%d", l_writecleanfull_cleansharedpersistsep_wt);
            is_directed_test=1;
        end

        // Legacy commands 
        if ($test$plusargs("wt_dvmop")) begin
            $value$plusargs("wt_dvmop=%d", l_dvmop_wt);
            is_directed_test=1;
        end
        if ($test$plusargs("wt_readshared")) begin
            $value$plusargs("wt_readshared=%d", l_readshared_wt);
            is_directed_test=1;
        end
        
        if (is_directed_test) begin
            disable_all_weights();
            <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-E') { %>
                cleansharedpersistsep_wt                = l_cleansharedpersistsep_wt                ;
                readpreferunique_wt                     = l_readpreferunique_wt                     ;
                makereadunique_wt                       = l_makereadunique_wt                       ;
                writeuniquezero_wt                      = l_writeuniquezero_wt                      ;
                writenosnpzero_wt                       = l_writenosnpzero_wt                       ;
                writenosnpfull_cleanshared_wt           = l_writenosnpfull_cleanshared_wt           ;
                writenosnpfull_cleaninvalid_wt          = l_writenosnpfull_cleaninvalid_wt          ;
                writenosnpfull_cleansharedpersistsep_wt = l_writenosnpfull_cleansharedpersistsep_wt ;
                writebackfull_cleanshared_wt            = l_writebackfull_cleanshared_wt            ;
                writebackfull_cleaninvalid_wt           = l_writebackfull_cleaninvalid_wt           ;
                writebackfull_cleansharedpersistsep_wt  = l_writebackfull_cleansharedpersistsep_wt  ;
                writecleanfull_cleanshared_wt           = l_writecleanfull_cleanshared_wt           ;
                writecleanfull_cleansharedpersistsep_wt = l_writecleanfull_cleansharedpersistsep_wt ;
            <% } %>
            // Legacy Commands
            dvmop_wt                                = l_dvmop_wt                                ;
            readshared_wt                           = l_readshared_wt                           ;
        end else begin
            enable_all_weights();
            if (disable_dvmop) begin
                dvmop_wt = 0;
            end
        end

        // if noDVM option is enabled in the config.
        <% if (obj.noDVM) { %>
            dvmop_wt = 0;
        <% } %>

    endfunction: assign_weights
endclass: chi_subsys_base_seq
