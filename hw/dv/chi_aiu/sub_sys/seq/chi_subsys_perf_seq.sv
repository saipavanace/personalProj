class chi_subsys_perf_seq extends chi_subsys_base_seq;


    `svt_xvm_object_utils(chi_subsys_perf_seq)
    `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

    /** Node configuration obtained from the sequencer */
    svt_chi_node_configuration  cfg;

    svt_axi_cache               rn_cache;
    svt_chi_rn_agent            my_agent;
    `SVT_XVM(component)         my_component;

    svt_chi_rn_transaction txn;
    int txn_idx;
    int total_txn;

    int qos;

    int duty_cycle_enable_perf_test;
    int loop_number;
    int ratio_number;

    int read_perf_test;
    int write_perf_test;

    int atomic_allowed_perf_test;
    int cmo_allowed_perf_test;

    int read_wt_perf_test;
    int write_wt_perf_test;
    int atomic_wt_perf_test;
    int cmo_wt_perf_test;

    int individual_initiator_addrq;
    int coherent_perf_test;


    int aiu_id;
    int addr_idx;
    addr_t addr_to_use;
    int use_user_addrq;
    int init_all_cache;

    int debug_print;


    extern function new(string name = "chi_subsys_perf_seq");

    extern function void set_read_wt(int value, int coherent_read_txn);
    extern function void set_write_wt(int value);
    extern function void set_atomic_wt(int value);
    extern function void set_cmo_wt(int value);

    extern virtual task body();
    //extern virtual task generate_transactions();

endclass: chi_subsys_perf_seq


function chi_subsys_perf_seq::new(string name = "chi_subsys_perf_seq");
    super.new(name);

    if ($test$plusargs("atomic_allowed_perf_test")) begin
        atomic_allowed_perf_test = 1;
    end
    if ($test$plusargs("cmo_allowed_perf_test")) begin
        cmo_allowed_perf_test = 1;
    end
    if ($test$plusargs("read_test")) begin
        read_perf_test = 1;
    end
    if ($test$plusargs("write_test")) begin
        write_perf_test = 1;
    end
    if ($test$plusargs("duty_cycle_enable_perf_test")) begin
        duty_cycle_enable_perf_test = 1;
    end
    if (!($value$plusargs("duty_cycle_loop_number_perf_test=%d", loop_number))) begin
        loop_number = 2;
    end
    if (!($value$plusargs("duty_cycle_ratio_number_perf_test=%d", ratio_number))) begin
        ratio_number = 1;
    end
    if (!($value$plusargs("read_wt_perf_test=%d", read_wt_perf_test))) begin
        read_wt_perf_test = 100;
    end
    if (!($value$plusargs("write_wt_perf_test=%d", write_wt_perf_test))) begin
        write_wt_perf_test = 100;
    end
    if (!($value$plusargs("atomic_wt_perf_test=%d", atomic_wt_perf_test))) begin
        atomic_wt_perf_test = 5;
    end
    if (!($value$plusargs("cmo_wt_perf_test=%d", cmo_wt_perf_test))) begin
        cmo_wt_perf_test = 5;
    end
    if ($test$plusargs("individual_initiator_addrq")) begin
        individual_initiator_addrq = 1;
    end
    if ($test$plusargs("use_user_addrq")) begin
        $value$plusargs("use_user_addrq=%d", use_user_addrq);
    end
    if ($test$plusargs("force_perf_test_coherent_txn")) begin
        $value$plusargs("force_perf_test_coherent_txn=%d", coherent_perf_test);
    end
    if ($test$plusargs("debug_print_rf")) begin
        debug_print = 1;
    end
    generate_unique_txn_id = 1;
endfunction: new


function void chi_subsys_perf_seq::set_read_wt(int value, int coherent_read_txn);
    readnosnp_wt    = value; 
    if(coherent_read_txn == 1) begin
        readonce_wt     = value; 
    end else if(coherent_read_txn == 2) begin
        readunique_wt   = value;
    end else begin
        readonce_wt     = value; 
        readunique_wt   = value;
    end
endfunction

function void chi_subsys_perf_seq::set_write_wt(int value);
    writeuniquefull_wt  = value; 
    writenosnpfull_wt   = value; 
    writeuniqueptl_wt   = value;
    writenosnpptl_wt    = value;

endfunction: set_write_wt

function void chi_subsys_perf_seq::set_atomic_wt(int value);
    // Only few first to test
    atomicload_set_wt  = value;
    atomicstore_add_wt = value;
endfunction: set_atomic_wt

function void chi_subsys_perf_seq::set_cmo_wt(int value);
    //cleansharedpersistsep_wt    = value;
    cleansharedpersist_wt       = value;
    cleanshared_wt              = value;
    makeinvalid_wt              = value;
    cleaninvalid_wt             = value;
endfunction: set_cmo_wt

task chi_subsys_perf_seq::body();

        my_component = p_sequencer.get_parent();

        void'($cast(my_agent,my_component));
        if (my_agent != null) begin
            my_cache = my_agent.rn_cache;
        end 

        svt_chi_rn_transaction_base_sequence::body(); // Base body method to obtain a handle to the rn node configuration

// ################################################################################################################################################

        disable_all_weights();

        if (init_all_cache>0 ) begin: init_dmi_cache
            set_write_wt(1);
        end : init_dmi_cache
        
        else if (read_perf_test) begin: read_perf_test
            set_read_wt(1,coherent_perf_test);
        end : read_perf_test

        else if(write_perf_test) begin : write_perf_test
            set_write_wt(1);
        end : write_perf_test

        else if(duty_cycle_enable_perf_test) begin : duty_cycle_enable_perf_test

            randcase 

                (read_wt_perf_test+write_wt_perf_test) : begin
                    if(txn_idx % loop_number >= ratio_number) begin 
                        set_read_wt(1,coherent_perf_test);
                    end else begin
                        set_write_wt(1);
                    end
                end
                atomic_wt_perf_test*atomic_allowed_perf_test : begin
                    set_atomic_wt(1);
                end
                cmo_wt_perf_test*cmo_allowed_perf_test : begin
                    set_cmo_wt(1);
                end 
                
            endcase

        end : duty_cycle_enable_perf_test

        else begin : random_txn
            
            randcase
                read_wt_perf_test : begin
                    set_read_wt(1,coherent_perf_test);
                end 
                write_wt_perf_test : begin
                    set_write_wt(1);
                end 
                (atomic_wt_perf_test*atomic_allowed_perf_test) : begin
                    set_atomic_wt(1);
                end 
                (cmo_wt_perf_test*cmo_allowed_perf_test) : begin
                    set_cmo_wt(1);
                end 
            endcase

        end : random_txn

// ################################################################################################################################################

        if(use_user_addrq > 0) begin // use_user_addrq
            if (individual_initiator_addrq) begin 
                addr_idx = (aiu_id*total_txn) + txn_idx;
            end else begin
                addr_idx = txn_idx;
            end 

            addr_idx = addr_idx % use_user_addrq;

            if (coherent_perf_test) begin 
                addr_to_use = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][addr_idx];
            end else begin
                addr_to_use = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][addr_idx];                       
            end 

            if(init_all_cache) begin
                addr_to_use[<%=obj.wCacheLineOffset%>-1:0] ='b0;
            end 
            
            if(debug_print) begin
                $display("RFRF ADDR COH     idx%0d = %0h", txn_idx, ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][addr_idx]);
                $display("RFRF ADDR NONCOH  idx%0d = %0h", txn_idx, ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][addr_idx]);
                $display("RFRF ADDR txn     idx%0d = %0h", txn_idx, addr_to_use);
            end 

            use_directed_non_secure_access  = 1;
            use_directed_snp_attr           = 1;
            use_directed_addr               = 1;

            directed_addr_mailbox.put(addr_to_use);
            directed_snp_attr_is_snoopable_mailbox.put(0);

            if($test$plusargs("sp_ns_1")) begin
                directed_is_non_secure_access_mailbox.put(1);
            end else begin
                directed_is_non_secure_access_mailbox.put(0);
            end

        end            
// ################################################################################################################################################

        svt_chi_rn_coherent_transaction_base_sequence::generate_transactions();
            
    endtask: body
