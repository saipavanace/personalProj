/// How to use it:
// for example : "+chi_txn_seq_name": "chi_subsys_regular_item_connect)",
// all the item type like chi_subys_regular_item should have just add some contraints should not add attributes  

class chi_subsys_connectivity_item #( type T_ = svt_chi_rn_transaction) extends svt_chi_rn_transaction; 
  `svt_xvm_object_utils(chi_subsys_connectivity_item)
  bit k_decode_err_illegal_acc_format_test_unsupported_size=0;

  rand T_ pool_item[75]; // randomize 75 items to have one with the right address connect to the right Dxx target regarding the source id
                          //!!!! In this queue, the constraints in "with" in the case of randomize with() doesn't work !!! we have to use only the constraints in the item  
  bit csr_access = 0;

  constraint ncore_test_constraint_exclusive {
     if(k_decode_err_illegal_acc_format_test_unsupported_size==1) {
         is_exclusive == 0;
     }
   }

   function void pre_randomize();
      super.pre_randomize();
      foreach(pool_item[i]) begin
          pool_item[i].copy(this); // mainly to copy svt_amba_cfg processed in parent.pre_randomize()
          pool_item[i].set_item_context(this.get_parent_sequence(),this.get_sequencer());
          pool_item[i].pre_randomize();
        end
   endfunction

   function void post_randomize();
    bit find;
    if(csr_access == 0) begin
      foreach (pool_item[i]) begin:_foreach_pool_item
        // static value cfg.node_id = src_id 
        //$display("CLUDBG TRY cfg id:%0d , pool_item_%0d %0s",pool_item[i].cfg.node_id,i,pool_item[i].xact_type.name());
        if (addr_trans_mgr::check_unmapped_add_c(pool_item[i].addr,pool_item[i].cfg.node_id) == 0 && !find) begin // target ADDRESS must be connected ( ==0) to SRC_ID
          if (!uvm_re_match(uvm_glob_to_re("*ATOMIC*"),pool_item[i].xact_type.name())) begin:_check_atomic
            int allow_atomic_txn = addr_trans_mgr::allow_atomic_txn_with_addr(pool_item[i].addr);
            //$display("CLUDEBUG_item type:%0s addr:%0h allow_atomic:%0d",pool_item[i].xact_type.name(),pool_item[i].addr,allow_atomic_txn);
            if (!allow_atomic_txn) continue; // next item in pool
          end:_check_atomic
          pool_item[i].post_randomize(); // reprocess byte_enable in post_randomize ( cf .../svt/amba_svt/latest/sverilog/src/vcs/svt_chi_transaction.svp)
          this.copy(pool_item[i]);
          //$display("CLUDBG FOUND cfg id:%0d , pool_item_%0d %0s",pool_item[i].cfg.node_id,i,pool_item[i].xact_type.name());
          find =1;
          break;
        end 
      end:_foreach_pool_item 
      if (!find) `uvm_error(get_full_name(), "TRY to generate an connected addr but can't reach the constraints. increase size of pool_item")
    end
   endfunction

    function new(string name = "chi_subsys_connectivity_item");
      super.new(name);
      foreach(pool_item[i]) begin
          pool_item[i] = T_::type_id::create($sformatf("pool_item[%0d]",i));
        end
        if ((!($value$plusargs("k_csr_access_only=%d",csr_access))) || k_disable_boot_addr)  csr_access = 0;
        if (!($value$plusargs("k_decode_err_illegal_acc_format_test_unsupported_size=%d",k_decode_err_illegal_acc_format_test_unsupported_size))) k_decode_err_illegal_acc_format_test_unsupported_size= 0;
    endfunction: new

endclass: chi_subsys_connectivity_item

// equivalent to : typedef chi_subsys_connectivity_item #(chi_subsys_regular_item) chi_subsys_regular_item_connect;
// but to be able to override by type name (string) the seq item need to be register in factory with `uvm_object_utils
`define FACTORY_REGISTER(ITEM_NAME) \
class ``ITEM_NAME``_connect extends chi_subsys_connectivity_item #(``ITEM_NAME``); \
   `svt_xvm_object_utils(``ITEM_NAME``_connect) \
   function new(string name = "``ITEM_NAME``_connect");\
   super.new(name);\
   endfunction \
endclass

//typedef chi_subsys_connectivity_item #(chi_subsys_regular_item) chi_subsys_regular_item_connect;
`FACTORY_REGISTER(chi_subsys_regular_item)
//typedef chi_subsys_connectivity_item #(chi_subsys_regular_noncoh_item) chi_subsys_regular_noncoh_item_connect;
`FACTORY_REGISTER(chi_subsys_regular_noncoh_item)
//typedef chi_subsys_connectivity_item #(chi_subsys_nondata_item) chi_subsys_nondata_item_connect;
`FACTORY_REGISTER(chi_subsys_nondata_item)
//typedef chi_subsys_connectivity_item #(chi_subsys_copyback_item) chi_subsys_copyback_item_connect;
`FACTORY_REGISTER(chi_subsys_copyback_item)
//typedef chi_subsys_connectivity_item #(chi_subsys_noatomic_item) chi_subsys_noatomic_item_connect;
`FACTORY_REGISTER(chi_subsys_noatomic_item)
//typedef chi_subsys_connectivity_item #(chi_subsys_error_item) chi_subsys_error_item_connect;
`FACTORY_REGISTER(chi_subsys_error_item)
//typedef chi_subsys_connectivity_item #(chi_subsys_regular_error_item) chi_subsys_regular_error_item_connect;
`FACTORY_REGISTER(chi_subsys_regular_error_item)
//typedef chi_subsys_connectivity_item #(chi_subsys_regular_perf_item) chi_subsys_regular_perf_item_connect;
`FACTORY_REGISTER(chi_subsys_regular_perf_item)
//typedef chi_subsys_connectivity_item #(chi_subsys_atomic_item) chi_subsys_copyback_item_connect;
`FACTORY_REGISTER(chi_subsys_atomic_item)
//typedef chi_subsys_connectivity_item #(chi_subsys_regular_cohexcl_item) chi_subsys_regular_cohexcl_item_connect;
`FACTORY_REGISTER(chi_subsys_regular_cohexcl_item)
//typedef chi_subsys_connectivity_item #(chi_subsys_stash_item) chi_subsys_regular_cohexcl_item_connect;
`FACTORY_REGISTER(chi_subsys_stash_item)

