//=====================================================================================================================================
// uvm_sequence <-- io_subsys_base_seq <-- io_subsys_ace_seq 
// svt_sequence <-- svt_axi_master_base_sequence <-- svt_axi_ace_master_base_sequence <-- svt_axi_ace_master_generic_sequence
/* This sequence run the svt_axi_ace_master_generic_sequence
/**
  * Generic sequence that can be used to generate transactions of all types on
  * a master sequencer.  All controls are provided in the base class
  * svt_axi_ace_master_base_sequence. Please refer documentation of
  * svt_axi_ace_master_base_sequence for controls provided.  This class only
  * adds constraints to make sure that it can be directly used in a testcase
  * outside of a virtual sequence.
  */
//====================================================================================================================================
class io_subsys_ace_seq extends io_subsys_base_seq;
  `svt_xvm_object_utils(io_subsys_ace_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
 
  svt_axi_ace_master_generic_sequence generic_seq;
  svt_atomic_seq atomic_seq;
  svt_dvm_seq dvm_seq;
  svt_axi_seq seq;
  svt_rd_after_wr_to_dii_seq rd_after_wr_to_dii; 
  
  string axi_seq, ace_seq, dvm_enable;
  int total_wt_atm_txns;
  int total_wt_dvm_txns;
  int total_wt_all_txns;

  function new(string name = "io_subsys_ace_seq");
    super.new(name);
  endfunction: new

  virtual task pre_body();
    super.pre_body();
    if(!$value$plusargs("axi_seq=%0s", axi_seq))
      axi_seq = "";
  endtask:pre_body;

  virtual task body();
    `uvm_info(get_full_name(), $psprintf("Entered body ..."), UVM_LOW)

    total_wt_atm_txns = (cfg.atmstr+cfg.atmld+cfg.atmcmp+cfg.atmswp); 
    total_wt_dvm_txns = (cfg.dvmsync+cfg.dvmnonsync); //only sync + non-sync
    total_wt_all_txns = (cfg.atmstr+cfg.atmld+cfg.atmcmp+cfg.atmswp+cfg.rdnosnp + cfg.rdonce + cfg.rdcln + cfg.rdnotshrddty + cfg.rdshrd + cfg.rdunq + cfg.clnunq + cfg.mkunq + cfg.clnshrd + cfg.clninvld + cfg.mkinvld + cfg.clnshardpersist + cfg.rdoncemakeinvld + cfg.rdonceclinvld + cfg.wrnosnp+cfg.wrunq+cfg.wrlnunq + cfg.wrbk+cfg.wrcln + cfg.wrevct + cfg.evct+ cfg.stshonceshrd+cfg.stshonceunq+cfg.wrunqfullstsh+cfg.wrunqptlstsh+cfg.dvmsync+cfg.dvmnonsync);
    seq = svt_axi_seq::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", nativeif, instname, portid));
    generic_seq = svt_axi_ace_master_generic_sequence::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", nativeif, instname, portid));
    atomic_seq = svt_atomic_seq::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", nativeif, instname, portid));
    dvm_seq    = svt_dvm_seq::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", nativeif, instname, portid));
    rd_after_wr_to_dii = svt_rd_after_wr_to_dii_seq::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", nativeif, instname, portid));
    fork
      if (nativeif == "acelite-e" && cfg.atomic_transactions_enable==1) begin
        init_seq(atomic_seq);
        atomic_seq.start(p_sequencer);
      end
      if (dvm_enable == 1) begin
          init_seq(dvm_seq);
          dvm_seq.start(p_sequencer);
      end
      if ((total_wt_all_txns - total_wt_atm_txns - total_wt_dvm_txns) > 0)begin
        init_seq(generic_seq);
        generic_seq.start(p_sequencer);
      end
       
      if(axi_seq == "narrow_single_beat_wr_seq" || axi_seq == "narrow_single_beat_rd_seq" || axi_seq == "svt_rd_after_wr_wrap_seq" || axi_seq == "svt_rd_after_wr_to_dii_seq" || axi_seq == "rd_after_b2b_wr_to_dii_seq")begin
        init_seq(seq);
        seq.start(p_sequencer);
      end
      if($test$plusargs("svt_rd_after_wr_to_dii_with_loaded_traffic"))begin
        rd_after_wr_to_dii.start(p_sequencer);
      end
    join
    `uvm_info(get_full_name(), $psprintf("Exited body ..."), UVM_LOW)
  endtask:body
  
  virtual task init_seq(svt_axi_master_base_sequence tmp_seq);
    svt_axi_ace_master_generic_sequence generic_seq;
    svt_atomic_seq atomic_seq;
    svt_dvm_seq dvm_seq;
    svt_axi_seq seq;
    int num_addr;
    `uvm_info(get_full_name(), $psprintf("cfg.dvmsync %0d cfg.dvmnonsync %0d total_wt_dvm_txns %0d total_wt_all_txns %0d mstr_cfg.num_txns %0d",cfg.dvmsync, cfg.dvmnonsync, total_wt_dvm_txns, total_wt_all_txns, mstr_cfg.num_txns), UVM_LOW)
 
    if($cast(dvm_seq, tmp_seq)) begin
     
      dvm_seq.sequence_length = (total_wt_dvm_txns * mstr_cfg.num_txns)/total_wt_all_txns;
      dvm_seq.dvmsync    = cfg.dvmsync;
      dvm_seq.dvmnonsync = cfg.dvmnonsync;
      `uvm_info(get_full_name(), $psprintf("dvm_seq.dvmsync %0d dvm_seq.dvmnonsync %0d  dvm_seq.sequence_length %0d total_wt_dvm_txns %0d total_wt_all_txns %0d mstr_cfg.num_txns %0d",dvm_seq.dvmsync, dvm_seq.dvmnonsync, dvm_seq.sequence_length, total_wt_dvm_txns, total_wt_all_txns, mstr_cfg.num_txns), UVM_LOW)
    end
    if (!$value$plusargs("ace_seq=%0s", ace_seq)) begin
    ace_seq = "";
    end
    if($cast(atomic_seq, tmp_seq)) begin
      `uvm_info(get_full_name(), $psprintf("atomic_seq.sequence_length %0d total_wt_atm_txns %0d total_wt_all_txns %0d mstr_cfg.num_txns %0d",atomic_seq.sequence_length, total_wt_atm_txns, total_wt_all_txns, mstr_cfg.num_txns), UVM_LOW)
      if(ace_seq != "io_subsys_atomic_seq")begin
      atomic_seq.sequence_length = (total_wt_atm_txns * mstr_cfg.num_txns)/total_wt_all_txns;
      end else begin
      atomic_seq.sequence_length = mstr_cfg.num_txns;
      end
      atomic_seq.atmstr_wt  = cfg.atmstr;
      atomic_seq.atmld_wt   = cfg.atmld;
      atomic_seq.atmcmp_wt  = cfg.atmcmp;
      atomic_seq.atmswp_wt  = cfg.atmswp;
    end
    if($cast(seq,tmp_seq))begin
        seq.wrnosnp_wt = cfg.wrnosnp;
        seq.rdnosnp_wt = cfg.rdnosnp;
        seq.wrunq_wt = cfg.wrunq;
        seq.rdonce_wt = cfg.rdonce;
        seq.core_id = cfg.core_id;
        seq.funitid = cfg.funitid;
        seq.nativeif = nativeif;
    end
    else if($cast(generic_seq, tmp_seq))begin
      if(nativeif == "acelite-e") begin
      generic_seq.sequence_length = mstr_cfg.num_txns - ((total_wt_atm_txns * mstr_cfg.num_txns)/total_wt_all_txns); 
      end else begin
      generic_seq.sequence_length = mstr_cfg.num_txns;
      end  
      generic_seq.reasonable_sequence_length.constraint_mode(0);
      generic_seq.exclusive_access_enable = mstr_cfg.en_excl_txn;
      if ($test$plusargs("blocking_mode")) begin 
        generic_seq.use_blocking_mode = 1;
      end
      //read txn wts
      generic_seq.readnosnoop_wt          = cfg.rdnosnp;
      generic_seq.readonce_wt             = cfg.rdonce;
      generic_seq.readclean_wt            = cfg.rdcln;
      generic_seq.readnotshareddirty_wt   = cfg.rdnotshrddty;
      generic_seq.readshared_wt           = cfg.rdshrd;
      generic_seq.readunique_wt           = cfg.rdunq;
      generic_seq.cleanunique_wt          = cfg.clnunq;
      generic_seq.makeunique_wt           = cfg.mkunq;
      generic_seq.cleanshared_wt          = cfg.clnshrd;
      generic_seq.cleaninvalid_wt         = cfg.clninvld;
      generic_seq.makeinvalid_wt          = cfg.mkinvld;
      generic_seq.cleansharedpersist_wt   = cfg.clnshardpersist;
      generic_seq.readoncemakeinvalid_wt  = cfg.rdoncemakeinvld; 
      generic_seq.readoncecleaninvalid_wt = cfg.rdonceclinvld;
      generic_seq.writenosnoop_wt         = cfg.wrnosnp;
      generic_seq.writeunique_wt          = cfg.wrunq;
      generic_seq.writelineunique_wt      = cfg.wrlnunq; 
      generic_seq.writeback_wt            = cfg.wrbk;
      generic_seq.writeclean_wt           = cfg.wrcln; 
      generic_seq.writeevict_wt           = cfg.wrevct; 
      generic_seq.evict_wt                = cfg.evct; 
      generic_seq.stashonceshared_wt      = cfg.stshonceshrd;
      generic_seq.stashonceunique_wt      = cfg.stshonceunq;
      generic_seq.writeuniquefullstash_wt = cfg.wrunqfullstsh;
      generic_seq.writeuniqueptlstash_wt  = cfg.wrunqptlstsh; 
    if (mstr_cfg.reduce_addr_area) begin
      generic_seq.use_directed_addr = 1;
      if (mstr_cfg.use_user_addrq==0) begin: _not_use_user_addrq_
       //addr >= mstr_cfg.start_addr and addr < mstr_cfg.end_addr CONC-14668
        num_addr = 0;
        addr_coh =mstr_cfg.start_addr;
        while (num_addr < generic_seq.sequence_length) begin 
          generic_seq.directed_addr_mailbox.put(addr_coh);
          num_addr++;
          addr_coh += (1<< <%=obj.wCacheLineOffset%>);
          if (addr_coh >= mstr_cfg.end_addr) begin 
              break;
          end
        end
      end: _not_use_user_addrq_ 
      else if (mstr_cfg.use_user_addrq==1) begin: _use_user_addrq_
        if (ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].size() == 0) 
          `uvm_error(get_full_name(), $psprintf("reduce_addr_area is passed in but coh_user_addrq size is 0"))
        //if (ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].size() == 0) 
          //`uvm_error(get_full_name(), $psprintf("reduce_addr_area is passed in but noncoh_user_addrq size is 0"))

        num_addr = 0;
        while (num_addr < generic_seq.sequence_length) begin: _loop_until_num_addr_in_mailbox_equal_to_num_txns_
            if($test$plusargs("directed_stash")) begin
                addr_coh =ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][num_addr]; 
                `uvm_info(get_full_name(), $psprintf("ncoreConfigInfo::coh_addr:0x%0h ",ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][num_addr]), UVM_LOW)
            end
            else begin
               ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].shuffle();
               addr_coh =ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][0];
                `uvm_info(get_full_name(), $psprintf("ncoreConfigInfo::coh_addr:0x%0h ",ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][0]), UVM_LOW)
            end
          if ($urandom_range(1,0)) begin 
            addr_coh[3:0] = $urandom_range(15,1);
          end
          generic_seq.directed_addr_mailbox.put(addr_coh);
          num_addr++;
          `uvm_info(get_full_name(), $psprintf("Putting coh_addr:0x%0h into the directed_addr_mailbox num_addr:%0d",addr_coh, num_addr), UVM_LOW)
        end:_loop_until_num_addr_in_mailbox_equal_to_num_txns_
      end: _use_user_addrq_ 
    end else begin 
      generic_seq.use_directed_addr = 0;
    end
    end
 
  endtask: init_seq 

endclass:io_subsys_ace_seq

