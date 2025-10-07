class chi_subsys_regular_noncoh_item extends chi_subsys_noatomic_item; 

bit write_test, read_test;

bit force_mem_attr_is_cacheable     = 0;
bit force_mem_attr_allocate_hint    = 0;
bit force_mem_attr_device           = 0;
bit force_mem_attr_ewa              = 0;
bit force_order                     = 0;
int force_size                      = 0;
int force_size_less_than_or_eq      = 0;
bit force_is_non_secure_access      = 0;

int val_mem_attr_is_cacheable       = 0;
int val_mem_attr_allocate_hint      = 0;
int val_mem_attr_ewa                = 0;
int val_mem_attr_device             = 0;
int val_order                       = 0;
int val_size                        = 0;
bit val_is_non_secure_access        = 0;

  `svt_xvm_object_utils(chi_subsys_regular_noncoh_item)

  constraint c_regular {
        if (write_test) {
             xact_type inside {
     WRITENOSNPFULL
    ,WRITENOSNPPTL 
`ifdef SVT_CHI_ISSUE_E_ENABLE
    ,WRITENOSNPZERO             
`endif 
          };
        } else if(read_test) {
             xact_type inside {
     READNOSNP  
          };
        } else {
             xact_type inside {
     READNOSNP  
    ,WRITENOSNPFULL
    ,WRITENOSNPPTL 
`ifdef SVT_CHI_ISSUE_E_ENABLE
    ,WRITENOSNPZERO             
`endif 
          };
        }
    }

    constraint c_txn_mem_attr {
        if(force_mem_attr_is_cacheable){
            mem_attr_is_cacheable == val_mem_attr_is_cacheable ; // Indicates a Cacheable transaction for which the cache must be looked up in servicing the transaction
        }
        if(force_mem_attr_allocate_hint){
            mem_attr_allocate_hint == val_mem_attr_allocate_hint ; // Indicates whether or not the cache receiving the transaction is recommended to allocate the transaction
        }
        if(force_mem_attr_device){
            if(val_mem_attr_device==0){
                mem_attr_mem_type == NORMAL;
            } else if(val_mem_attr_device==1) {
                mem_attr_mem_type == DEVICE;
            }
        }
        if(force_mem_attr_ewa){
            mem_attr_is_early_wr_ack_allowed == val_mem_attr_ewa ; // EWA  Early Write Acknowledge (EWA) bit. Specifies the EWA status for the transaction: EWA permitted
        }
    }

    constraint c_txn_order {
        if(force_order){
            if(val_order==0){
                order_type == NO_ORDERING_REQUIRED;   
            } else if(val_order==2) {
                order_type == REQ_ORDERING_REQUIRED;   
            } else if(val_order==3) {
                order_type == REQ_EP_ORDERING_REQUIRED;   
            }
        }     
    }

    constraint c_txn_size {
        if(force_size){
            data_size == val_size ;
        } else if(force_size_less_than_or_eq){
            data_size <= val_size ;
        } else {
            data_size inside { 'b100,'b101,'b110} ;  // 4 => 16 Bytes (128bits) // 5 => 32 Bytes (256bits) // 6 => 64 Bytes
        }

    }
    
    constraint c_txn_is_non_secure_access {
        if(force_is_non_secure_access){
            is_non_secure_access == val_is_non_secure_access;
        } 
    }

    function new(string name = "chi_subsys_regular_noncoh_item");
        super.new(name);
    endfunction: new
    
    function void pre_randomize();
        super.pre_randomize();
        if(!$value$plusargs("write_test=%0b",write_test))  write_test= 0;
        if(!$value$plusargs("read_test=%0b",read_test))  read_test= 0;
        if ($test$plusargs("force_test_mem_attr_cacheable")) begin
            force_mem_attr_is_cacheable = 1;
            $value$plusargs("force_test_mem_attr_cacheable=%d", val_mem_attr_is_cacheable);
        end
        if ($test$plusargs("force_test_mem_attr_allocate")) begin
            force_mem_attr_allocate_hint = 1;
            $value$plusargs("force_test_mem_attr_allocate=%d", val_mem_attr_allocate_hint);
        end
        if ($test$plusargs("force_test_mem_attr_device")) begin
            force_mem_attr_device = 1;
            $value$plusargs("force_test_mem_attr_device=%d", val_mem_attr_device);
        end
        if ($test$plusargs("force_test_mem_attr_ewa")) begin
            force_mem_attr_ewa = 1;
            $value$plusargs("force_test_mem_attr_ewa=%d", val_mem_attr_ewa);
        end
        if ($test$plusargs("force_test_order")) begin
            force_order = 1;
            $value$plusargs("force_test_order=%d", val_order);
        end
        if ($test$plusargs("force_size")) begin
            force_size = 1;
            $value$plusargs("force_size=%d", val_size);
        end
        if ($test$plusargs("force_size_less_than_or_eq")) begin
            force_size_less_than_or_eq = 1;
            $value$plusargs("force_size_less_than_or_eq=%d", val_size);
        end
        if ($test$plusargs("force_is_non_secure_access")) begin
            force_is_non_secure_access = 1;
            $value$plusargs("force_is_non_secure_access=%b", val_is_non_secure_access);
        end



    endfunction: pre_randomize

endclass: chi_subsys_regular_noncoh_item
