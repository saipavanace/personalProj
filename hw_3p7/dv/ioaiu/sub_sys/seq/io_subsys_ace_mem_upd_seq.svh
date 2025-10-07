//=====================================================================================================================================
// uvm_sequence <-- io_subsys_base_seq <-- io_subsys_ace_seq <-- io_subsys_ace_mem_upd_seq
// svt_sequence <-- svt_axi_master_base_sequence <-- svt_axi_ace_master_generic_sequence
/* 
/ *   This sequence performs Memory update Transactions
 */
//====================================================================================================================================

class io_subsys_ace_mem_upd_seq extends io_subsys_base_seq;
  `svt_xvm_object_utils(io_subsys_ace_mem_upd_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)

  svt_axi_ace_master_generic_sequence genric_seq;
  int cache_size;
  

  function new(string name = "io_subsys_ace_mem_upd_seq");
    super.new(name);
  endfunction: new

  virtual task pre_body();
    super.pre_body();
  endtask:pre_body;

  virtual task body();

    `uvm_info(get_full_name(), $psprintf("Entered body io_subsys_ace_mem_upd_seq ...cache_size %0d",cache_size), UVM_LOW)
    genric_seq = svt_axi_ace_master_generic_sequence::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", nativeif, instname, portid));
    this.init_seq(genric_seq);
    genric_seq.start(p_sequencer);
    `uvm_info(get_full_name(), $psprintf("Exited body io_subsys_ace_mem_upd_seq ..."), UVM_LOW)
  endtask:body

  virtual task init_seq(svt_axi_master_base_sequence tmp_seq);
    svt_axi_ace_master_generic_sequence genric_seq;
    if($cast(genric_seq, tmp_seq))begin
      genric_seq.sequence_length = cache_size;
      //read txn wts
      genric_seq.readnosnoop_wt          =0; 
      genric_seq.readonce_wt             =0; 
      genric_seq.readclean_wt            =0; 
      genric_seq.readnotshareddirty_wt   =0; 
      genric_seq.readshared_wt           =0; 
      genric_seq.readunique_wt           =0; 
      genric_seq.cleanunique_wt          =0; 
      genric_seq.makeunique_wt           =0; 
      genric_seq.cleanshared_wt          =0; 
      genric_seq.cleaninvalid_wt         =0; 
      genric_seq.makeinvalid_wt          =0; 
      genric_seq.cleansharedpersist_wt   =0; 
      genric_seq.readoncemakeinvalid_wt  =0; 
      genric_seq.readoncecleaninvalid_wt =0; 
      genric_seq.writenosnoop_wt         =0; 
      genric_seq.writeunique_wt          =0; 
      genric_seq.writelineunique_wt      =0; 
      genric_seq.writeback_wt            =1; 
      genric_seq.writeclean_wt           =1; 
      genric_seq.writeevict_wt           =1; 
      genric_seq.evict_wt                =1; 
      genric_seq.stashonceshared_wt      =0; 
      genric_seq.stashonceunique_wt      =0; 
      genric_seq.writeuniquefullstash_wt =0; 
      genric_seq.writeuniqueptlstash_wt  =0; 
      if (mstr_cfg.reduce_addr_area) begin
      genric_seq.use_directed_addr = 1;
      if (mstr_cfg.use_user_addrq) begin: _use_user_addrq_
        if (addrMgrConst::user_addrq[addrMgrConst::COH].size() == 0) 
          `uvm_error(get_full_name(), $psprintf("reduce_addr_area is passed in but coh_user_addrq size is 0"))
        //if (addrMgrConst::user_addrq[addrMgrConst::NONCOH].size() == 0) 
          //`uvm_error(get_full_name(), $psprintf("reduce_addr_area is passed in but noncoh_user_addrq size is 0"))

        num_addr = 0;
        while (num_addr < genric_seq.sequence_length) begin: _loop_until_num_addr_in_mailbox_equal_to_num_txns_
          addrMgrConst::user_addrq[addrMgrConst::COH].shuffle();
          addr_coh =addrMgrConst::user_addrq[addrMgrConst::COH][0];
          `uvm_info(get_full_name(), $psprintf("addrMgrConst::coh_addr:0x%0h ",addrMgrConst::user_addrq[addrMgrConst::COH][0]), UVM_LOW)
          if ($urandom_range(1,0)) begin 
            addr_coh[3:0] = $urandom_range(15,1);
          end
          genric_seq.directed_addr_mailbox.put(addr_coh);
          num_addr++;
          `uvm_info(get_full_name(), $psprintf("Putting coh_addr:0x%0h into the directed_addr_mailbox num_addr:%0d",addr_coh, num_addr), UVM_LOW)
        end:_loop_until_num_addr_in_mailbox_equal_to_num_txns_
      end: _use_user_addrq_ 
    end else begin 
      genric_seq.use_directed_addr = 0;
    end
    end

  endtask: init_seq 

endclass:io_subsys_ace_mem_upd_seq
