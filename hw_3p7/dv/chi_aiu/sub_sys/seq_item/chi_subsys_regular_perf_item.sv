class chi_subsys_regular_perf_item extends chi_subsys_base_item; 

    int coherent_perf_test              = 0;
    int force_mem_attr_is_cacheable     = 0;
    int force_mem_attr_allocate_hint    = 0;
    int force_mem_attr_device           = 0;
    int force_mem_attr_ewa              = 0;
    int force_exp_comp_ack              = 0;
    int force_exclusive                 = 0;
    int force_no_order                  = 0;
    int force_non_secure                = 0;
    int force_snoopable_perf_test       = 0;
    int force_size                      = 0;

    int val_mem_attr_is_cacheable       = 0;
    int val_mem_attr_allocate_hint      = 0;
    int val_mem_attr_ewa                = 0;
    int val_mem_attr_device             = 0;
    int val_exp_comp_ack                = 0;
    int val_exclusive                   = 0;
    int val_no_order                    = 0;
    int val_non_secure                  = 0;
    int val_snoopable                   = 0;
    int val_size                        = 0;

    `svt_xvm_object_utils(chi_subsys_regular_perf_item)

    constraint c_perf_txn_type {
        if(!coherent_perf_test){
            xact_type inside {
                READNOSNP  
                ,WRITENOSNPFULL
                ,WRITENOSNPPTL
            };
        } else {
            xact_type inside {
                READONCE
                ,READUNIQUE
                ,WRITEUNIQUEFULL
                ,WRITEUNIQUEPTL
                ,CLEANSHARED,CLEANSHAREDPERSIST//,CLEANSHAREDPERSISTSEP
                ,CLEANINVALID
                ,ATOMICSTORE_ADD, ATOMICSTORE_CLR, ATOMICSTORE_EOR, ATOMICSTORE_SET, ATOMICSTORE_SMAX, ATOMICSTORE_SMIN,
                ATOMICSTORE_UMAX, ATOMICSTORE_UMIN, ATOMICLOAD_ADD, ATOMICLOAD_CLR, ATOMICLOAD_EOR, ATOMICLOAD_SET, ATOMICLOAD_SMAX, ATOMICLOAD_SMIN,
                ATOMICLOAD_UMAX, ATOMICLOAD_UMIN, ATOMICSWAP,ATOMICCOMPARE

                };
        }
    }

    constraint c_perf_txn_fixed_attributes {
        qos == 'b0 ;    // Highest priority
    }

    constraint c_perf_txn_size {
        if(force_size){
            data_size == val_size ;
        } else {
            data_size inside { 'b100,'b101,'b110} ;  // 4 => 16 Bytes (128bits) // 5 => 32 Bytes (256bits) // 6 => 64 Bytes
        }

    }

    constraint c_perf_txn_size_x_txn_type{
        if (data_size <= 'b101) {
            !(xact_type inside {WRITEUNIQUEFULL,WRITENOSNPFULL});
        } else {
            !(xact_type inside {WRITEUNIQUEPTL,WRITENOSNPPTL});
        }       
    }
    
    constraint c_perf_txn_constraint_order{

        solve data_size             before xact_type;

    }

    constraint c_perf_txn_mem_attr {
        if(force_mem_attr_is_cacheable){
            mem_attr_is_cacheable == val_mem_attr_is_cacheable ; // Indicates a Cacheable transaction for which the cache must be looked up in servicing the transaction
        }
        if(force_mem_attr_allocate_hint){
            mem_attr_allocate_hint == val_mem_attr_allocate_hint ; // Indicates whether or not the cache receiving the transaction is recommended to allocate the transaction
        }
        if(force_mem_attr_device){
            mem_attr_mem_type == val_mem_attr_device ; // Indicates whether or not the target is a Device(1) or NORMAL(0)
        }
        if(force_mem_attr_ewa){
            mem_attr_is_early_wr_ack_allowed == val_mem_attr_ewa ; // EWA  Early Write Acknowledge (EWA) bit. Specifies the EWA status for the transaction: EWA permitted
        }
    }

    constraint c_perf_txn_expcompack {
        if(force_exp_comp_ack){
            exp_comp_ack == val_exp_comp_ack ;
        }
    }

    constraint c_perf_txn_order {
        if(force_no_order){
            order_type == val_no_order ;   
        } else {
            order_type == 0 ;   // Value NO_ORDERING_REQUIRED
        }
    }

    constraint c_perf_txn_secure {
        if(force_non_secure){
            is_non_secure_access == val_non_secure ;    // physical_addr_space_type == CHI_NON_SECURE;
        } 
    }

    constraint c_perf_txn_exclusive {
        if(force_exclusive){
            is_exclusive == val_exclusive ;
        } else {
            is_exclusive == 0;
        }
    }

    constraint c_perf_txn_snoopable{
        if(force_snoopable_perf_test){
            snp_attr_is_snoopable == val_snoopable ;
        }

        solve addr before snp_attr_is_snoopable;
    }
    constraint c_perf_txn_tracetag{
        trace_tag == 0 ;
    }

    function new(string name = "chi_subsys_regular_perf_item");
        super.new(name);
    endfunction: new

    function void pre_randomize();
        super.pre_randomize();
        if ($test$plusargs("force_perf_test_coherent_txn")) begin
            $value$plusargs("force_perf_test_coherent_txn=%d", coherent_perf_test);
        end
        if ($test$plusargs("force_perf_test_mem_attr_cacheable")) begin
            force_mem_attr_is_cacheable = 1;
            $value$plusargs("force_perf_test_mem_attr_cacheable=%d", val_mem_attr_is_cacheable);
        end
        if ($test$plusargs("force_perf_test_mem_attr_allocate")) begin
            force_mem_attr_allocate_hint = 1;
            $value$plusargs("force_perf_test_mem_attr_allocate=%d", val_mem_attr_allocate_hint);
        end
        if ($test$plusargs("force_perf_test_mem_attr_device")) begin
            force_mem_attr_device = 1;
            $value$plusargs("force_perf_test_mem_attr_device=%d", val_mem_attr_device);
        end
        if ($test$plusargs("force_perf_test_mem_attr_ewa")  && (!($test$plusargs("coherent_test"))) ) begin
            force_mem_attr_ewa = 1;
            $value$plusargs("force_perf_test_mem_attr_ewa=%d", val_mem_attr_ewa);
        end
        if ($test$plusargs("force_perf_test_exp_comp_ack")) begin
            force_exp_comp_ack = 1;
            $value$plusargs("force_perf_test_exp_comp_ack=%d", val_exp_comp_ack);
        end
        if ($test$plusargs("force_perf_test_no_order")) begin
            force_no_order = 1;
            $value$plusargs("force_perf_test_no_order=%d", val_no_order);
        end
        if ($test$plusargs("force_perf_test_non_secure")) begin
            force_non_secure = 1;
            $value$plusargs("force_perf_test_non_secure=%d", val_non_secure);
        end
        if ($test$plusargs("force_perf_test_exclusive")) begin
            force_exclusive = 1;
            $value$plusargs("force_perf_test_exclusive=%d", val_exclusive);
        end

        if ($test$plusargs("force_snoopable_perf_test")) begin
            force_snoopable_perf_test = 1;
            $value$plusargs("force_snoopable_perf_test=%d", val_snoopable);
        end
        if ($test$plusargs("force_size")) begin
            force_size = 1;
            $value$plusargs("force_size=%d", val_size);
        end
    endfunction: pre_randomize


    function void post_randomize();
        super.post_randomize();
    endfunction: post_randomize 
endclass: chi_subsys_regular_perf_item

