class chi_subsys_random_seq extends chi_subsys_base_seq;
    `svt_xvm_object_utils(chi_subsys_random_seq)
    `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

    svt_axi_cache rn_cache;

    function new(string name = "chi_subsys_random_seq");
        super.new(name);
        use_directed_addr = 0;
        use_directed_mem_attr = 0;
        use_directed_non_secure_access = 0;
        use_directed_snp_attr = 0;
        use_seq_order_type = 0;
       if ($test$plusargs("en_ext_silent_txn")) blocking_mode = 1; // wait end of txn before send another
    endfunction: new

    virtual task body();
        enable_all_weights();
        reqlinkflit_wt = 0;
        if ($test$plusargs("snps_chi_txn_blocking_mode")) begin
           blocking_mode = 1;
        end
        super.body();
    endtask: body

`ifndef CHI_SUBSYS  
    virtual task post_body();
    // Silent txn
    //RN-F action    | RN-F Cache state| Notes
    //               | Present | Next |
    //1-Cache eviction | UC | I | Can use Evict, WriteEvictFull, or WriteEvictOrEvict transaction.
    //               | UCE| I | Can use Evict transaction.
    //               | SC | I | Can use Evict transaction.
    //2-Local sharing  | UC | SC| -
    //               | UD | SD| -
    //3-Store          | UC | UD| Full or partial cache line store
    //               | UCE| UDP| Partial cache line store
    //               | UCE| UD |Full cache line store
    //               | UDP| UD |Store that fills the cache line
    //4-Cache Invalidate| UD |I | Can use Evict transaction.
    //                | UDP|I |Can use Evict transaction.
    svt_chi_transaction txn;
    bit is_clean,is_uniq,is_partial;

    bit do_silent_txn=1;
    enum { cache_evict, local_sharing, store,cache_invalidate} silent_type;
   
    bit [7:0] data;
    bit [7:0] q_data[$];
    bit      q_byteen[$];

    // TODO use weights with plusargs
    if ($test$plusargs("en_ext_silent_txn")) begin:_enable_silent_txn 
    if (local_rn_xact) begin:_txn  // if txn exist
        txn = local_rn_xact;
        txn.wait_end();
        if (rn_cache.get_status(txn.addr,is_uniq,is_clean)) begin:_in_the_cache
            std::randomize(do_silent_txn) with {do_silent_txn dist {0 :=60, 1 :=40} ;};
            if (do_silent_txn) begin:_silent_txn
            is_partial = rn_cache.is_partial_dirty_line(txn.addr,0);
           if ($test$plusargs("dtrudty_case"))  
                std::randomize(silent_type) with {silent_type dist {cache_evict :=0, local_sharing :=0,store := 100, cache_invalidate :=0} ;};
           else std::randomize(silent_type) with {silent_type dist {cache_evict :=5, local_sharing :=45,store := 45, cache_invalidate :=5} ;};
            `uvm_info(get_name(), $sformatf("SILENT_TXN TRY: chi.node_id:%0d addr:0x%0h type:%0s previous_state: U:%0b C:%0b DirtyPartial:%0b",txn.cfg.node_id,txn.addr,silent_type.name(),is_uniq,is_clean,is_partial), UVM_LOW)
            case (silent_type)
               cache_evict: if (is_clean) begin
                               rn_cache.invalidate_addr(txn.addr);
                            end else begin
                                do_silent_txn =0; // finaly cache state doesn't allow silent txn
                            end 
                local_sharing: if (is_uniq && !is_partial) begin
                               rn_cache.update_status(.addr(txn.addr),.is_unique(0), .is_clean (is_clean)); // set share
                              end else begin
                                do_silent_txn =0; // finaly cache state doesn't allow silent txn
                              end  
                store: if (is_uniq) begin
                          bit full_access;
                          if (is_partial) full_access=1; // case state UDP -> UD 
                          else   std::randomize(full_access) with {full_access dist { 0:=60 , 1:=40};};
                          for (int i=0; i< 2**<%=obj.wCacheLineOffset%>;i++) begin:_each_byte
                            std::randomize(data);
                            q_data.push_back(data); 
                            if (full_access) begin:_full
                              q_byteen.push_back(1);
                            end:_full else begin:_partial
                              q_byteen.push_back($urandom()); 
                            end:_partial
                          end:_each_byte
                          rn_cache.write(-1,txn.addr,q_data,q_byteen,is_uniq,0); // uniq dirty 
                       end  else begin
                          do_silent_txn =0; // finaly cache state doesn't allow silent txn
                       end  
               cache_invalidate : if (is_uniq && !is_clean) begin
                                      rn_cache.invalidate_addr(txn.addr);
                                  end else begin
                                      do_silent_txn =0; // finaly cache state doesn't allow silent txn
                                  end 
        endcase 
            if (do_silent_txn) begin
                  `uvm_info(get_name(), $sformatf("SILENT_TXN DOING: chi.node_id:%0d addr:0x%0h type:%0s previous_state: U:%0b C:%0b DirtyPartial:%0b",txn.cfg.node_id,txn.addr,silent_type.name(),is_uniq,is_clean,is_partial), UVM_LOW)
                if (rn_cache.get_status(txn.addr,is_uniq,is_clean))  `uvm_info(get_name(),$sformatf("SILENT_TXN DONE addr:0x%0h new_state U:%0b C:%0b DirtyPartial:%0b",txn.addr,is_uniq,is_clean,rn_cache.is_partial_dirty_line(txn.addr,0)), UVM_LOW)
            end else begin
                 `uvm_info(get_name(), $sformatf("SILENT_TXN ABORT: chi.node_id:%0d addr:0x%0h",txn.cfg.node_id,txn.addr), UVM_LOW)
            end
          end:_silent_txn
        end:_in_the_cache
    end:_txn
    end:_enable_silent_txn 
    endtask:post_body
`endif
endclass: chi_subsys_random_seq
