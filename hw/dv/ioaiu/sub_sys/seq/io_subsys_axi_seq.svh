//=====================================================================================================================================
// uvm_sequence <-- io_subsys_base_seq <-- io_subsys_axi_seq 
// svt_sequence <-- svt_axi_master_base_sequence <-- svt_axi_master_random_sequence
/* 
 *  This sequence generates random master transactions.
 */
//====================================================================================================================================
class io_subsys_axi_seq extends io_subsys_base_seq;
  `svt_xvm_object_utils(io_subsys_axi_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  
  svt_axi_seq seq;
  svt_atomic_seq atomic_seq;
  svt_rd_after_wr_to_dii_seq rd_after_wr_to_dii;
  int total_wt_atm_txns;
  int total_wt_all_txns;
  function new(string name = "io_subsys_axi_seq");
    super.new(name);
  endfunction: new

  virtual task pre_body();
    super.pre_body();
  endtask:pre_body;

  virtual task body();
    `uvm_info(get_full_name(), $psprintf("Entered body ..."), UVM_LOW)
   if ((nativeif == "axi5") && (cfg.useCache==0) && (cfg.atomic_transactions_enable==1)) begin
   atomic_seq = svt_atomic_seq::type_id::create("atomic_seq");
   init_seq(atomic_seq);
   end
    rd_after_wr_to_dii = svt_rd_after_wr_to_dii_seq::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", nativeif, instname, portid));
    seq = svt_axi_seq::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", nativeif, instname, portid));
    init_seq(seq);
    `uvm_info(get_full_name(), $psprintf("Starting svt_axi_seq sequence_length:%0d", seq.sequence_length), UVM_LOW)
fork
         begin
             seq.start(p_sequencer);
         end
         begin
           if ((nativeif == "axi5") && (cfg.useCache==0) && (cfg.atomic_transactions_enable==1)) begin  
              atomic_seq.start(p_sequencer);  
           end
         end
         if($test$plusargs("svt_rd_after_wr_to_dii_with_loaded_traffic"))begin
           rd_after_wr_to_dii.start(p_sequencer);
         end
    join
    `uvm_info(get_full_name(), $psprintf("Exited body ..."), UVM_LOW)
  endtask:body

  virtual task init_seq(svt_axi_master_base_sequence tmp_seq);
    svt_axi_seq seq;
    svt_atomic_seq atomic_seq; 
    bit found = 0;
   total_wt_atm_txns = (cfg.atmstr+cfg.atmld+cfg.atmcmp+cfg.atmswp); 
    
    total_wt_all_txns = (cfg.atmstr+cfg.atmld+cfg.atmcmp+cfg.atmswp+cfg.rdnosnp + cfg.rdonce +cfg.wrnosnp+cfg.wrunq);
 
    if (mstr_cfg.reduce_addr_area && mstr_cfg.use_user_addrq) begin 
      `uvm_info(get_name(), $psprintf("fn:init_seq size:%0d coh user_addrq:%0p", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].size(), ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH]), UVM_LOW);
      foreach(ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i]) begin 
        user_cacheline_coh_addrq.push_back(ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i] >> 6);
      end
      if (cfg.core_id >= 0) begin: _multicore_
        `uvm_info(get_name(), $psprintf("fn:init_seq check to make sure if there are addresses for this core:%0d", cfg.core_id), UVM_LOW);
        foreach(ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i]) begin 
          if (ncoreConfigInfo::get_addr_core_id(ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], cfg.funitid) == cfg.core_id) begin 
            found = 1;
            break;
          end
        end
        if (found == 0) begin 
          mstr_cfg.num_txns = 0;
          `uvm_info(get_name(), $psprintf("fn:init_seq forcing num_txn to 0 since no address found in useraddrq for core:%0d", cfg.core_id), UVM_LOW);
        end 
      end: _multicore_
    end
 
    if ($cast(seq, tmp_seq)) begin 
        if(nativeif == "axi5")begin 
	  cal_wr_rd_txn((((total_wt_all_txns-total_wt_atm_txns) * mstr_cfg.num_txns)/total_wt_all_txns),seq.num_wrs,seq.num_rds);
        end
        else begin
                cal_wr_rd_txn(mstr_cfg.num_txns,seq.num_wrs,seq.num_rds); 
        end
        seq.reduce_addr_area = mstr_cfg.reduce_addr_area;
        seq.use_user_addrq   = mstr_cfg.use_user_addrq;
        seq.user_cacheline_coh_addrq = this.user_cacheline_coh_addrq;
        seq.start_addr = mstr_cfg.start_addr;
        seq.end_addr   = mstr_cfg.end_addr;
        seq.wrnosnp_wt = cfg.wrnosnp;
        seq.rdnosnp_wt = cfg.rdnosnp;
        seq.wrunq_wt = cfg.wrunq;
        seq.rdonce_wt = cfg.rdonce;
        seq.core_id = cfg.core_id;
        seq.funitid = cfg.funitid;
        seq.nativeif = nativeif;
   end
   if($cast(atomic_seq,tmp_seq))begin
          atomic_seq.sequence_length = (total_wt_atm_txns * mstr_cfg.num_txns)/total_wt_all_txns;
          atomic_seq.atmstr_wt  = cfg.atmstr;
          atomic_seq.atmld_wt   = cfg.atmld;
          atomic_seq.atmcmp_wt  = cfg.atmcmp;
          atomic_seq.atmswp_wt  = cfg.atmswp;
  end
  endtask: init_seq 
  function void cal_wr_rd_txn(int num_txns,output int num_wrs,num_rds);
     
     if((cfg.num_write > 0)||(cfg.num_read>0))begin
          num_wrs = (num_txns*cfg.num_write)/(cfg.num_read+cfg.num_write);
           num_rds = num_txns - num_wrs; 
                   
     end
     else begin
         num_wrs = num_txns/2;
         num_rds  =num_txns/2; 
     end     
        
  endfunction
endclass:io_subsys_axi_seq

