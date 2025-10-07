class chi_subsys_directed_coh_wr_rd_check_seq extends svt_chi_rn_coherent_transaction_base_sequence;

  /** Handle to CHI Node configuration */
  svt_chi_node_configuration cfg;
  int chiaiu_idx=0;

  bit [addr_trans_mgr_pkg::addrMgrConst::W_SEC_ADDR-1:0] all_dmi_dii_start_addr[int][$]; 
  bit [addr_trans_mgr_pkg::addrMgrConst::W_SEC_ADDR-1:0] all_dii_start_addr[int][$]; 
  bit [addr_trans_mgr_pkg::addrMgrConst::W_SEC_ADDR-1:0] all_dmi_start_addr[int][$]; 
  bit all_dmi_nc[int][$]; 
  bit bypass_data_in_data_out_checks=0;
  bit use_single_mem_region_in_test=0;
  string chi_rn_arg_mem_attr_mem_type = "NORMAL";
  int wt_chi_rn_arg_mem_attr_mem_type_normal = 100;

  /** @endcond */
  /** UVM/OVM Object Utility macro */
  `svt_xvm_object_utils(chi_subsys_directed_coh_wr_rd_check_seq)
  `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

    function new(string name="chi_subsys_directed_coh_wr_rd_check_seq");
        super.new(name);
        //Set the response depth to -1, to accept infinite number of responses
        this.set_response_queue_depth(-1);
    endfunction

    /** pre_body */
    virtual task pre_body();
        bit [addr_trans_mgr_pkg::addrMgrConst::W_SEC_ADDR-1:0] temp_addr;
        // preliminary create a queue of start addr by DII or DMI using in the task
        int ig;
        addr_trans_mgr_pkg::addrMgrConst::sys_addr_csr_t csrq[$];

        csrq = addr_trans_mgr_pkg::addrMgrConst::get_all_gpra();
        foreach (csrq[ig]) begin:_foreach_csrq_ig
                    temp_addr[addr_trans_mgr_pkg::addrMgrConst::W_SEC_ADDR-1:44] = csrq[ig].upp_addr;
                    temp_addr[43:12] = csrq[ig].low_addr;
                    all_dmi_dii_start_addr[csrq[ig].mig_nunitid].push_back(temp_addr);
                    if(csrq[ig].unit.name=="DII")
                       all_dii_start_addr[csrq[ig].mig_nunitid].push_back(temp_addr);
                    else begin
                       all_dmi_start_addr[csrq[ig].mig_nunitid].push_back(temp_addr);
                       all_dmi_nc[csrq[ig].mig_nunitid].push_back(csrq[ig].nc);
                    end
        end:_foreach_csrq_ig

        if($test$plusargs("bypass_data_in_data_out_checks"))  bypass_data_in_data_out_checks=1;
        if($test$plusargs("use_single_mem_region_in_test"))   use_single_mem_region_in_test=1;
        if($value$plusargs("chi_rn_arg_mem_attr_mem_type=%0s",chi_rn_arg_mem_attr_mem_type)) begin
            `uvm_info(get_full_name(), $psprintf("Plusarg chi_rn_arg_mem_attr_mem_type=%0s is set",chi_rn_arg_mem_attr_mem_type), UVM_LOW)
        end
        if($value$plusargs("wt_chi_rn_arg_mem_attr_mem_type_normal=%0d",wt_chi_rn_arg_mem_attr_mem_type_normal)) begin
            `uvm_info(get_full_name(), $psprintf("Plusarg wt_chi_rn_arg_mem_attr_mem_type_normal=%0s is set",wt_chi_rn_arg_mem_attr_mem_type_normal), UVM_LOW)
            if(wt_chi_rn_arg_mem_attr_mem_type_normal>100)
              `uvm_error(get_full_name(),$psprintf("Plusarg wt_chi_rn_arg_mem_attr_mem_type_normal must be less than 100"))
        end
    endtask:pre_body

  // -----------------------------------------------------------------------------
  virtual task body();
    svt_configuration get_cfg;
    bit rand_success;
    bit [511:0] data_in, data_in_1;
    bit [511:0] data_out, data_out_1;
    bit [addr_trans_mgr_pkg::addrMgrConst::W_SEC_ADDR-1:0] addr;
    bit [addr_trans_mgr_pkg::addrMgrConst::W_SEC_ADDR-1:0] coh_addr;
    bit [addr_trans_mgr_pkg::addrMgrConst::W_SEC_ADDR-1:0] non_coh_addr;
    int data_size;

    `uvm_info(get_full_name(), "Starting CHISEQ chi_subsys_directed_coh_wr_rd_check_seq ...",UVM_LOW)
    /** Obtain a handle to the port configuration */
    p_sequencer.get_cfg(get_cfg);
    if (!$cast(cfg, get_cfg)) begin
      `svt_xvm_fatal("body", "Unable to $cast the configuration to a svt_chi_node_configuration class");
    end
    get_rn_virt_seqr();
    
    for(int crit_dw=0;crit_dw<8;crit_dw=crit_dw+1) begin : looping_for_each_critical_DW
      for (int j = 0; j < 7; j++) begin : looping_for_each_req_size
        for(int all_dmi=0;all_dmi<(use_single_mem_region_in_test ? 1 :all_dmi_start_addr.size());all_dmi=all_dmi+1) begin : looping_for_each_dmi
          if($test$plusargs("k_directed_test_wr_rd_to_all_dmi")) begin : if_plusarg_en_k_directed_test_wr_rd_to_all_dmi
            for(int all_dmi_in_ig=0;all_dmi_in_ig<(use_single_mem_region_in_test ? 1 :all_dmi_start_addr[all_dmi].size());all_dmi_in_ig=all_dmi_in_ig+1) begin : looping_for_each_dmi_in_ig
              if(all_dmi_nc[all_dmi][all_dmi_in_ig]==0) begin : coh_regions
                for(int i = 0; i < sequence_length; i++) begin : looping_for_sequence_length
    svt_chi_rn_transaction           rn_xact,atomic_rn_req, atomic_auto_read_req;
    bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] directed_addr,rand_addr;
    bit                              is_error,randomize_with_directed_addr;
    bit                              directed_snp_attr_is_snoopable;
    svt_chi_common_transaction::snp_attr_snp_domain_type_enum directed_snp_attr_snp_domain_type;
    bit                              directed_mem_attr_allocate_hint;
    bit                              directed_is_non_secure_access;
    bit                              directed_allocate_in_cache;
    `ifdef SVT_CHI_ISSUE_F_ENABLE
    bit                              directed_non_secure_ext;
    `endif
    svt_chi_common_transaction::data_size_enum directed_data_size; 
    bit [(`SVT_CHI_MAX_DATA_WIDTH-1):0] directed_data; 
    bit [(`SVT_CHI_MAX_BE_WIDTH-1):0] directed_byte_enable; 
    svt_chi_rn_transaction  rn_xacts[$];
    bit [5:0]addr_lower_bits;

    chi_subsys_pkg::chi_subsys_read_directed_seq svt_seq;



                      // Used to sink the responses from the response queue.
                      sink_responses();
                      if(initialize_cachelines == 0) begin
                        initialize_cachelines_done = 1; 
                      end

                      assert(std::randomize(data_out));
                      data_size = j;  // 2,4,8,16,32,64 bytes
                      coh_addr = all_dmi_start_addr[all_dmi][all_dmi_in_ig] + (i*64);
                      coh_addr[5:3] = crit_dw;

                      directed_data = data_out;
                      directed_data_size = data_size;
                      directed_addr = coh_addr;
                      sequence_length = 1;
                      directed_addr_mailbox.put(directed_addr);
                      directed_data_mailbox.put(directed_data);
                      directed_data_size_mailbox.put(directed_data_size);
                      directed_is_non_secure_access_mailbox.put(0);
                      directed_byte_enable_mailbox.put({`SVT_CHI_MAX_BE_WIDTH{1'b1}});
                      directed_snp_attr_is_snoopable_mailbox.put(1);
                      //randomize_with_directed_data = 1;
                      use_directed_addr = 1;
                      use_directed_snp_attr = 1;
                      use_directed_mem_attr = 0;
                      use_seq_order_type = 0;
                      use_directed_non_secure_access = 1;
                      use_directed_allocate_in_cache = 0;
                      use_directed_data_size = 1;
                      use_directed_byte_enable = 1;
                      use_directed_data = 1;
                      readnosnp_wt = 0;
                      writeuniqueptl_wt = 1;
                      blocking_mode = 1;

                      get_directed_addr((i+1),is_error,randomize_with_directed_addr,directed_addr,directed_snp_attr_is_snoopable, 
                            directed_snp_attr_snp_domain_type,directed_mem_attr_allocate_hint,directed_is_non_secure_access, 
                            `ifdef SVT_CHI_ISSUE_F_ENABLE
                            directed_non_secure_ext,
                            `endif
                            directed_allocate_in_cache,directed_data_size, directed_data, directed_byte_enable);
                      if (is_error)
                          `uvm_error(get_full_name, $sformatf("Error after get_directed_addr")) 



                      `svt_xvm_create_on(rn_xact, p_sequencer);
                      randomize_xact(rn_xact,randomize_with_directed_addr,directed_addr,directed_snp_attr_is_snoopable, directed_snp_attr_snp_domain_type,
                         directed_mem_attr_allocate_hint, directed_is_non_secure_access,
                         `ifdef SVT_CHI_ISSUE_F_ENABLE
                         directed_non_secure_ext,
                         `endif
                         directed_allocate_in_cache, directed_data_size, directed_data, directed_byte_enable, rand_success, i,generate_unique_txn_id);


                      if (!rand_success) 
                        `uvm_error(get_full_name,"Randomization failure!!");
                      if(initialize_cachelines) begin
                        initialize_cache(rn_xact);
                        rn_xacts.push_back(rn_xact);        
                        foreach(rn_xacts[i])begin
                          `svt_xvm_debug("generate_transactions", $sformatf("rn_xacts[%d].addr=%0h is %0s", i,rn_xacts[i].addr,rn_xacts[i].sprint()));
                        end
                      end
                      `svt_xvm_send(rn_xact);
                      output_xact_mailbox.put(rn_xact);
                      output_xacts.push_back(rn_xact);
                      active_xacts.push_back(rn_xact);
                      active_rn_xacts.push_back(rn_xact);
                      if(blocking_mode) wait_for_active_xacts_to_end();

                      `uvm_info(get_full_name, $sformatf("CHI-%0d DMI [%0d][IG-%0d] Coherent Write Address = 0x%x,size = %d, Write Data = %x Critical DW=%0d",chiaiu_idx,all_dmi,all_dmi_in_ig, coh_addr, data_size, data_out,crit_dw), UVM_LOW) 

                      `svt_xvm_create_on(svt_seq, p_sequencer);
                      svt_seq.sequence_length = 1;
                      svt_seq.enable_outstanding = 0;
                      svt_seq.rd_coh=1;
                      //randcase
                      //1 : svt_seq.readunique_wt  =1;
                      //1 : svt_seq.readshared_wt  =1;
                      //1 : svt_seq.readonce_wt    =1;
                      //1 : svt_seq.readclean_wt   =1;
                      //1 : svt_seq.readnotshareddirty_wt=1;
                      //endcase
                      svt_seq.readonce_wt    =1;
                      //svt_seq.size=directed_data_size;
                      svt_seq.size=6; // Size less than 64 bytes not allowed for CHI-E & previous version Read coherent txns
                      svt_seq.min_addr = directed_addr;
                      svt_seq.max_addr = directed_addr;
                      svt_seq.hn_addr_rand_type = svt_chi_rn_transaction_base_sequence::DIRECTED_ADDR_RANGE_RAND_TYPE;
                      svt_seq.by_pass_read_data_check = 1;
                      svt_seq.use_seq_is_non_secure_access = 1;
                      svt_seq.seq_is_non_secure_access = 0;
                      svt_seq.seq_exp_comp_ack = 1;
                      svt_seq.seq_order_type = svt_chi_common_transaction::NO_ORDERING_REQUIRED;
                      if(chi_rn_arg_mem_attr_mem_type == "NORMAL") begin
                          svt_seq.seq_mem_attr_mem_type = svt_chi_transaction::NORMAL;
                      end else if(chi_rn_arg_mem_attr_mem_type == "DEVICE") begin
                          svt_seq.seq_mem_attr_mem_type = svt_chi_transaction::DEVICE;
                      end
                     `svt_xvm_send(svt_seq);  
                      data_in = svt_seq.read_tran.data;
                      `uvm_info(get_full_name, $sformatf("CHI-%0d DMI [%0d][IG-%0d] Coherent Read Address = 0x%x,size = %d, Read Data = %x Critical DW=%0d",chiaiu_idx,all_dmi,all_dmi_in_ig, coh_addr, data_size, data_in,crit_dw), UVM_LOW) 
                      svt_seq = null;
                      addr_lower_bits = coh_addr;
                      addr_lower_bits = (addr_lower_bits/(2 ** data_size))*(2 ** data_size);  

                      for(int set_zero_bits= 0; set_zero_bits<(addr_lower_bits*8);  set_zero_bits=set_zero_bits+1) begin
                          data_in = data_in>>1;
                      end
                      for(int set_zero_bits=(8 * (2 ** data_size)); set_zero_bits<512; set_zero_bits=set_zero_bits+1) begin
                          data_out[set_zero_bits] = 1'b0; data_in[set_zero_bits] = 1'b0;
                      end
                      if (data_out != data_in) begin
                        if(!bypass_data_in_data_out_checks) 
                            `uvm_error(get_full_name, $sformatf("CHI-%0d DMI [%0d][IG-%0d] Data Mismatch. Address = 0x%x,size = %d Bytes, Read Data = %x, Write Data = %x, Critical DW=%0d",chiaiu_idx,all_dmi,all_dmi_in_ig, coh_addr, data_size, data_in,data_out,crit_dw)) 
                        else
                            `uvm_info(get_full_name, $sformatf("CHI-%0d DMI [%0d][IG-%0d] Data Mismatch. Address = 0x%x,size = %d Bytes, Read Data = %x, Write Data = %x, Critical DW=%0d",chiaiu_idx,all_dmi,all_dmi_in_ig, coh_addr, data_size, data_in,data_out,crit_dw), UVM_LOW) 
                      end
                      else
                        `uvm_info(get_full_name, $sformatf("CHI-%0d DMI [%0d][IG-%0d] Data Write-Read Test Match. Address = 0x%x,size = %d Bytes, Read Data = %x, Write Data = %x, Critical DW=%0d",chiaiu_idx,all_dmi,all_dmi_in_ig, coh_addr, data_size, data_in,data_out,crit_dw), UVM_LOW) 

                end : looping_for_sequence_length
              end : coh_regions
            end : looping_for_each_dmi_in_ig
          end : if_plusarg_en_k_directed_test_wr_rd_to_all_dmi
        end : looping_for_each_dmi
      end : looping_for_each_req_size
    end : looping_for_each_critical_DW

    `uvm_info(get_full_name(), "Finished CHISEQ chi_subsys_directed_coh_wr_rd_check_seq ...",UVM_LOW);
  endtask: body

  /** Randomizes a single transaction based on the weights assigned.  If
 * randomized_with_directed_addr is set, the transaction is randomized with
 * the address specified in directed_addr
 */
task randomize_xact(svt_chi_rn_transaction           rn_xact,
                                                                   bit                              randomize_with_directed_addr, 
                                                                   bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] directed_addr,
                                                                   bit                              directed_snp_attr_is_snoopable,
                                                                   svt_chi_common_transaction::snp_attr_snp_domain_type_enum directed_snp_attr_snp_domain_type,
                                                                   bit                              directed_mem_attr_allocate_hint,
                                                                   bit                              directed_is_non_secure_access,
                                                                   `ifdef SVT_CHI_ISSUE_F_ENABLE
                                                                   bit                              directed_non_secure_ext,
                                                                   `endif
                                                                   bit                              directed_allocate_in_cache,
                                                                   svt_chi_common_transaction::data_size_enum directed_data_size, 
                                                                   bit [(`SVT_CHI_MAX_DATA_WIDTH-1):0] directed_data,
                                                                   bit [(`SVT_CHI_MAX_BE_WIDTH-1):0] directed_byte_enable,
                                                                   output bit                       req_success,
                                                                   input  int                       sequence_index = 0,
                                                                   input  bit                       gen_uniq_txn_id = 0);
  bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] _end_addr_for_sequential_addr_mode = 0;
  
  // Get config from corresponding sequencer and assign it here.
  rn_xact.cfg      = node_cfg;

`ifdef SVT_CHI_ISSUE_F_ENABLE
  `svt_debug("randomize_xact",$psprintf("writenosnpfull_cleaninvalidpopa_wt  = %d",writenosnpfull_cleaninvalidpopa_wt ));
  `svt_debug("randomize_xact",$psprintf("writenosnpptl_cleaninvalidpopa_wt  = %d",writenosnpptl_cleaninvalidpopa_wt ));
  `svt_debug("randomize_xact",$psprintf("writebackfull_cleaninvalidpopa_wt  = %d",writebackfull_cleaninvalidpopa_wt ));
  `svt_debug("randomize_xact",$psprintf("cleaninvalidpopa_wt  = %d",cleaninvalidpopa_wt ));
  `svt_debug("randomize_xact",$psprintf("writenosnpdef_wt  = %d",writenosnpdef_wt ));
`endif
`ifdef SVT_CHI_ISSUE_E_ENABLE
  `svt_debug("randomize_xact",$psprintf("writeevictorevict_wt   = %d",writeevictorevict_wt  ));       
  `svt_debug("randomize_xact",$psprintf("writenosnpzero_wt   = %d",writenosnpzero_wt  ));       
  `svt_debug("randomize_xact",$psprintf("writeuniquezero_wt  = %d",writeuniquezero_wt ));       
  `svt_debug("randomize_xact",$psprintf("makereadunique_wt  = %d",makereadunique_wt ));       
  `svt_debug("randomize_xact",$psprintf("readpreferunique_wt  = %d",readpreferunique_wt ));
  `svt_debug("randomize_xact",$psprintf("writenosnpfull_cleanshared_wt  = %d",writenosnpfull_cleanshared_wt ));
  `svt_debug("randomize_xact",$psprintf("writenosnpfull_cleansharedpersistsep_wt  = %d",writenosnpfull_cleansharedpersistsep_wt ));
  `svt_debug("randomize_xact",$psprintf("writeuniquefull_cleanshared_wt  = %d",writeuniquefull_cleanshared_wt ));
  `svt_debug("randomize_xact",$psprintf("writeuniquefull_cleansharedpersistsep_wt  = %d",writeuniquefull_cleansharedpersistsep_wt ));
  `svt_debug("randomize_xact",$psprintf("writeuniqueptl_cleanshared_wt  = %d",writeuniqueptl_cleanshared_wt ));
  `svt_debug("randomize_xact",$psprintf("writeuniqueptl_cleansharedpersistsep_wt  = %d",writeuniqueptl_cleansharedpersistsep_wt ));  
  `svt_debug("randomize_xact",$psprintf("writenosnpfull_cleaninvalid_wt  = %d",writenosnpfull_cleaninvalid_wt ));
  `svt_debug("randomize_xact",$psprintf("writenosnpptl_cleanshared_wt  = %d",writenosnpptl_cleanshared_wt ));
  `svt_debug("randomize_xact",$psprintf("writenosnpptl_cleansharedpersistsep_wt  = %d",writenosnpptl_cleansharedpersistsep_wt ));  
  `svt_debug("randomize_xact",$psprintf("writenosnpptl_cleaninvalid_wt  = %d",writenosnpptl_cleaninvalid_wt ));
  `svt_debug("randomize_xact",$psprintf("writebackfull_cleaninvalid_wt  = %d",writebackfull_cleaninvalid_wt ));
  `svt_debug("randomize_xact",$psprintf("writebackfull_cleanshared_wt  = %d",writebackfull_cleanshared_wt ));
  `svt_debug("randomize_xact",$psprintf("writebackfull_cleansharedpersistsep_wt  = %d",writebackfull_cleansharedpersistsep_wt )); 
  `svt_debug("randomize_xact",$psprintf("writcleanfull_cleanshared_wt  = %d",writecleanfull_cleanshared_wt ));
  `svt_debug("randomize_xact",$psprintf("writcleanfull_cleansharedpersistsep_wt  = %d",writecleanfull_cleansharedpersistsep_wt ));
  `svt_debug("randomize_xact",$psprintf("stashoncesepunique_wt        = %d",stashoncesepunique_wt      ));       
  `svt_debug("randomize_xact",$psprintf("stashoncesepshared_wt        = %d",stashoncesepshared_wt      ));       
`endif
`ifdef SVT_CHI_ISSUE_D_ENABLE
  `svt_debug("randomize_xact",$psprintf("cleansharedpersistsep_wt  = %d",cleansharedpersistsep_wt ));
`endif
  `svt_debug("randomize_xact",$psprintf("readnosnp_wt        = %d",readnosnp_wt       ));       
  `svt_debug("randomize_xact",$psprintf("readonce_wt         = %d",readonce_wt        ));        
  `svt_debug("randomize_xact",$psprintf("readclean_wt        = %d",readclean_wt       ));       
  `svt_debug("randomize_xact",$psprintf("gen_uniq_txn_id     = %d",gen_uniq_txn_id    ));       
`ifdef SVT_CHI_ISSUE_B_ENABLE
  `svt_debug("randomize_xact",$psprintf("readspec_wt               = %d",readspec_wt             ));       
  `svt_debug("randomize_xact",$psprintf("readnotshareddirty_wt     = %d",readnotshareddirty_wt   ));       
  `svt_debug("randomize_xact",$psprintf("readoncecleaninvalid_wt   = %d",readoncecleaninvalid_wt ));       
  `svt_debug("randomize_xact",$psprintf("readoncemakeinvalid_wt    = %d",readoncemakeinvalid_wt  ));       
  `svt_debug("randomize_xact",$psprintf("cleansharedpersist_wt     = %d",cleansharedpersist_wt   ));       
  `svt_debug("randomize_xact",$psprintf("atomicstore_add_wt        = %d",atomicstore_add_wt      ));       
  `svt_debug("randomize_xact",$psprintf("atomicstore_clr_wt        = %d",atomicstore_clr_wt      ));       
  `svt_debug("randomize_xact",$psprintf("atomicstore_eor_wt        = %d",atomicstore_eor_wt      ));       
  `svt_debug("randomize_xact",$psprintf("atomicstore_set_wt        = %d",atomicstore_set_wt      ));       
  `svt_debug("randomize_xact",$psprintf("atomicstore_smax_wt       = %d",atomicstore_smax_wt     ));       
  `svt_debug("randomize_xact",$psprintf("atomicstore_smin_wt       = %d",atomicstore_smin_wt     ));       
  `svt_debug("randomize_xact",$psprintf("atomicstore_umax_wt       = %d",atomicstore_umax_wt     ));       
  `svt_debug("randomize_xact",$psprintf("atomicstore_umin_wt       = %d",atomicstore_umin_wt     ));       
  `svt_debug("randomize_xact",$psprintf("atomicload_add_wt         = %d",atomicload_add_wt       ));       
  `svt_debug("randomize_xact",$psprintf("atomicload_clr_wt         = %d",atomicload_clr_wt       ));       
  `svt_debug("randomize_xact",$psprintf("atomicload_eor_wt         = %d",atomicload_eor_wt       ));       
  `svt_debug("randomize_xact",$psprintf("atomicload_set_wt         = %d",atomicload_set_wt       ));       
  `svt_debug("randomize_xact",$psprintf("atomicload_smax_wt        = %d",atomicload_smax_wt      ));       
  `svt_debug("randomize_xact",$psprintf("atomicload_smin_wt        = %d",atomicload_smin_wt      ));       
  `svt_debug("randomize_xact",$psprintf("atomicload_umax_wt        = %d",atomicload_umax_wt      ));       
  `svt_debug("randomize_xact",$psprintf("atomicload_umin_wt        = %d",atomicload_umin_wt      ));       
  `svt_debug("randomize_xact",$psprintf("atomicswap_wt             = %d",atomicswap_wt           ));       
  `svt_debug("randomize_xact",$psprintf("atomiccompare_wt          = %d",atomiccompare_wt        ));       
  `svt_debug("randomize_xact",$psprintf("prefetchtgt_wt            = %d",prefetchtgt_wt          ));       
  `svt_debug("randomize_xact",$psprintf("writeuniquefullstash_wt   = %d",writeuniquefullstash_wt ));       
  `svt_debug("randomize_xact",$psprintf("writeuniqueptlstash_wt    = %d",writeuniqueptlstash_wt  ));       
  `svt_debug("randomize_xact",$psprintf("stashonceunique_wt        = %d",stashonceunique_wt      ));       
  `svt_debug("randomize_xact",$psprintf("stashonceshared_wt        = %d",stashonceshared_wt      ));       
`endif
  `svt_debug("randomize_xact",$psprintf("readshared_wt       = %d",readshared_wt      ));      
  `svt_debug("randomize_xact",$psprintf("readunique_wt       = %d",readunique_wt      ));      
  `svt_debug("randomize_xact",$psprintf("cleanunique_wt      = %d",cleanunique_wt     ));     
  `svt_debug("randomize_xact",$psprintf("makeunique_wt       = %d",makeunique_wt      ));      
  `svt_debug("randomize_xact",$psprintf("writebackfull_wt    = %d",writebackfull_wt   ));   
  `svt_debug("randomize_xact",$psprintf("writebackptl_wt     = %d",writebackptl_wt    ));    
  `svt_debug("randomize_xact",$psprintf("writeevictfull_wt   = %d",writeevictfull_wt  ));  
  `svt_debug("randomize_xact",$psprintf("writecleanfull_wt   = %d",writecleanfull_wt  ));  
  `svt_debug("randomize_xact",$psprintf("writecleanptl_wt    = %d",writecleanptl_wt   ));   
  `svt_debug("randomize_xact",$psprintf("evict_wt            = %d",evict_wt           ));           
  `svt_debug("randomize_xact",$psprintf("writenosnpfull_wt   = %d",writenosnpfull_wt  ));  
  `svt_debug("randomize_xact",$psprintf("writenosnpptl_wt    = %d",writenosnpptl_wt   ));   
  `svt_debug("randomize_xact",$psprintf("writeuniquefull_wt  = %d",writeuniquefull_wt )); 
  `svt_debug("randomize_xact",$psprintf("writeuniqueptl_wt   = %d",writeuniqueptl_wt  ));  
  `svt_debug("randomize_xact",$psprintf("cleanshared_wt      = %d",cleanshared_wt     ));     
  `svt_debug("randomize_xact",$psprintf("cleaninvalid_wt     = %d",cleaninvalid_wt    ));    
  `svt_debug("randomize_xact",$psprintf("makeinvalid_wt      = %d",makeinvalid_wt     ));     
  `svt_debug("randomize_xact",$psprintf("eobarrier_wt        = %d",eobarrier_wt       ));       
  `svt_debug("randomize_xact",$psprintf("ecbarrier_wt        = %d",ecbarrier_wt       ));       
  `svt_debug("randomize_xact",$psprintf("dvmop_wt            = %d",dvmop_wt           ));           
  `svt_debug("randomize_xact",$psprintf("pcrdreturn_wt       = %d",pcrdreturn_wt      ));      
  `svt_debug("randomize_xact",$psprintf("reqlinkflit_wt      = %d",reqlinkflit_wt     ));

  
  _end_addr_for_sequential_addr_mode = (end_addr - ((sequence_length-1) * node_cfg.cache_line_size));
  req_success = rn_xact.randomize() with 
  { 
  // Test specific constraints 
  // 1) to avoid unwanted scenarios such as exclusive, writedatacancel, error etc.
  // 2) to control normal and device memory type
    //mem_attr_is_early_wr_ack_allowed == 0;
    if(xact_type inside {svt_chi_common_transaction::WRITENOSNPPTL,svt_chi_common_transaction::WRITEUNIQUEPTL}) {
        is_writedatacancel_used_for_write_xact == 0;
    }
    is_exclusive == 1'b0;
    if(chi_rn_arg_mem_attr_mem_type == "NORMAL") {
        mem_attr_mem_type == svt_chi_transaction::NORMAL;
    } else if(chi_rn_arg_mem_attr_mem_type == "DEVICE") {
        mem_attr_mem_type == svt_chi_transaction::DEVICE;
    } else {
        mem_attr_mem_type dist { 
            svt_chi_transaction::NORMAL := wt_chi_rn_arg_mem_attr_mem_type_normal,   
            svt_chi_transaction::DEVICE := (100 - wt_chi_rn_arg_mem_attr_mem_type_normal) 
        };
    }
    if (
            (xact_type == WRITEBACKFULL) ||
            (xact_type == WRITEBACKPTL) ||
            (xact_type == WRITECLEANFULL) ||
            (xact_type == WRITECLEANPTL) ||
            (xact_type == WRITENOSNPFULL) ||
            (xact_type == WRITENOSNPPTL) ||
            (xact_type == WRITEUNIQUEFULL) ||
            (xact_type == WRITEUNIQUEFULLSTASH) ||
            (xact_type == WRITEUNIQUEPTLSTASH) ||
     `ifdef SVT_CHI_ISSUE_E_ENABLE
            (xact_type == WRITEEVICTOREVICT) ||
            (xact_type == WRITENOSNPFULL_CLEANSHARED ||
            xact_type == WRITENOSNPFULL_CLEANINVALID ||
            xact_type == WRITENOSNPFULL_CLEANSHAREDPERSISTSEP ||
            xact_type == WRITENOSNPPTL_CLEANSHARED ||
            xact_type == WRITENOSNPPTL_CLEANINVALID ||
            xact_type == WRITENOSNPPTL_CLEANSHAREDPERSISTSEP) ||
            (xact_type == WRITEUNIQUEFULL_CLEANSHARED ||
            xact_type == WRITEUNIQUEPTL_CLEANSHARED ||
            xact_type == WRITEUNIQUEPTL_CLEANSHAREDPERSISTSEP ||
            xact_type == WRITEUNIQUEFULL_CLEANSHAREDPERSISTSEP) ||
            (xact_type == WRITEBACKFULL_CLEANSHARED ||
            xact_type == WRITEBACKFULL_CLEANINVALID ||
            xact_type == WRITEBACKFULL_CLEANSHAREDPERSISTSEP ||
            xact_type == WRITECLEANFULL_CLEANSHARED ||
            xact_type == WRITECLEANFULL_CLEANSHAREDPERSISTSEP) ||
     `endif
            (xact_type == WRITEUNIQUEPTL) ||
            (xact_type == WRITEEVICTFULL) ||
            xact_type == DVMOP
    ){
        foreach (data_resp_err_status[index]){
            data_resp_err_status[index] inside {NORMAL_OKAY};
        }
    }
    response_resp_err_status == NORMAL_OKAY;
    if ((xact_type == ATOMICSTORE_ADD) || (xact_type == ATOMICSTORE_CLR) ||
        (xact_type == ATOMICSTORE_EOR) || (xact_type == ATOMICSTORE_SET) ||
        (xact_type == ATOMICSTORE_SMAX) || (xact_type == ATOMICSTORE_SMIN) ||
        (xact_type == ATOMICSTORE_UMAX) || (xact_type == ATOMICSTORE_UMIN) ||
        (xact_type == ATOMICLOAD_ADD) || (xact_type == ATOMICLOAD_CLR) ||
        (xact_type == ATOMICLOAD_EOR) || (xact_type == ATOMICLOAD_SET) ||
        (xact_type == ATOMICLOAD_SMAX) || (xact_type == ATOMICLOAD_SMIN) ||
        (xact_type == ATOMICLOAD_UMAX) || (xact_type == ATOMICLOAD_UMIN) ||
        (xact_type == ATOMICSWAP) || (xact_type == ATOMICCOMPARE)
    ){
         foreach (atomic_write_data_resp_err_status[idx]){
             atomic_write_data_resp_err_status[idx] inside {
                 NORMAL_OKAY
             }; 
         }
    }

  // Constraints copied over from base class - svt_chi_rn_coherent_transaction_base_sequence
    if (node_cfg.chi_interface_type == svt_chi_node_configuration::RN_F) {
    xact_type dist {
                    svt_chi_common_transaction::READNOSNP       := readnosnp_wt,       
                    svt_chi_common_transaction::READONCE        := readonce_wt,        
                    svt_chi_common_transaction::READCLEAN       := readclean_wt,       
                    `ifdef SVT_CHI_ISSUE_B_ENABLE
                    svt_chi_common_transaction::READSPEC             := readspec_wt,       
                    svt_chi_common_transaction::READNOTSHAREDDIRTY   := readnotshareddirty_wt,       
                    svt_chi_common_transaction::READONCECLEANINVALID := readoncecleaninvalid_wt,       
                    svt_chi_common_transaction::READONCEMAKEINVALID  := readoncemakeinvalid_wt,       
                    svt_chi_common_transaction::CLEANSHAREDPERSIST   := cleansharedpersist_wt,       
                    svt_chi_common_transaction::ATOMICSTORE_ADD      := atomicstore_add_wt,       
                    svt_chi_common_transaction::ATOMICSTORE_CLR      := atomicstore_clr_wt,       
                    svt_chi_common_transaction::ATOMICSTORE_EOR      := atomicstore_eor_wt,       
                    svt_chi_common_transaction::ATOMICSTORE_SET      := atomicstore_set_wt,       
                    svt_chi_common_transaction::ATOMICSTORE_SMAX     := atomicstore_smax_wt,       
                    svt_chi_common_transaction::ATOMICSTORE_SMIN     := atomicstore_smin_wt,       
                    svt_chi_common_transaction::ATOMICSTORE_UMAX     := atomicstore_umax_wt,       
                    svt_chi_common_transaction::ATOMICSTORE_UMIN     := atomicstore_umin_wt,       
                    svt_chi_common_transaction::ATOMICLOAD_ADD       := atomicload_add_wt,       
                    svt_chi_common_transaction::ATOMICLOAD_CLR       := atomicload_clr_wt,       
                    svt_chi_common_transaction::ATOMICLOAD_EOR       := atomicload_eor_wt,       
                    svt_chi_common_transaction::ATOMICLOAD_SET       := atomicload_set_wt,       
                    svt_chi_common_transaction::ATOMICLOAD_SMAX      := atomicload_smax_wt,       
                    svt_chi_common_transaction::ATOMICLOAD_SMIN      := atomicload_smin_wt,       
                    svt_chi_common_transaction::ATOMICLOAD_UMAX      := atomicload_umax_wt,       
                    svt_chi_common_transaction::ATOMICLOAD_UMIN      := atomicload_umin_wt,       
                    svt_chi_common_transaction::ATOMICSWAP           := atomicswap_wt,       
                    svt_chi_common_transaction::ATOMICCOMPARE        := atomiccompare_wt,       
                    svt_chi_common_transaction::PREFETCHTGT          := prefetchtgt_wt,       
                    svt_chi_common_transaction::WRITEUNIQUEFULLSTASH := writeuniquefullstash_wt,       
                    svt_chi_common_transaction::WRITEUNIQUEPTLSTASH  := writeuniqueptlstash_wt,       
                    svt_chi_common_transaction::STASHONCEUNIQUE      := stashonceunique_wt,       
                    svt_chi_common_transaction::STASHONCESHARED      := stashonceshared_wt,       
                    `endif          //issue_b_enable
                    `ifdef SVT_CHI_ISSUE_D_ENABLE
                    svt_chi_common_transaction::CLEANSHAREDPERSISTSEP := cleansharedpersistsep_wt,
                    `endif //issue_d_enable
                    svt_chi_common_transaction::READSHARED      := readshared_wt,      
                    svt_chi_common_transaction::READUNIQUE      := readunique_wt,      
                    svt_chi_common_transaction::CLEANUNIQUE     := cleanunique_wt,     
                    svt_chi_common_transaction::MAKEUNIQUE      := makeunique_wt,      
                    svt_chi_common_transaction::WRITEBACKFULL   := writebackfull_wt,   
                    svt_chi_common_transaction::WRITEBACKPTL    := writebackptl_wt,    
                    svt_chi_common_transaction::WRITEEVICTFULL  := writeevictfull_wt,  
                    svt_chi_common_transaction::WRITECLEANFULL  := writecleanfull_wt,  
                    svt_chi_common_transaction::WRITECLEANPTL   := writecleanptl_wt,   
                    svt_chi_common_transaction::EVICT           := evict_wt,           
                    svt_chi_common_transaction::WRITENOSNPFULL  := writenosnpfull_wt,  
`ifdef SVT_CHI_ISSUE_F_ENABLE
                    svt_chi_common_transaction::WRITENOSNPFULL_CLEANINVALIDPOPA := writenosnpfull_cleaninvalidpopa_wt,
                    svt_chi_common_transaction::WRITENOSNPPTL_CLEANINVALIDPOPA := writenosnpptl_cleaninvalidpopa_wt,
                    svt_chi_common_transaction::WRITEBACKFULL_CLEANINVALIDPOPA := writebackfull_cleaninvalidpopa_wt,
                    svt_chi_common_transaction::CLEANINVALIDPOPA := cleaninvalidpopa_wt,
                    svt_chi_common_transaction::WRITENOSNPDEF := writenosnpdef_wt,
`endif
`ifdef SVT_CHI_ISSUE_E_ENABLE
                    svt_chi_common_transaction::WRITEEVICTOREVICT  := writeevictorevict_wt,  
                    svt_chi_common_transaction::WRITENOSNPZERO  := writenosnpzero_wt,  
                    svt_chi_common_transaction::WRITEUNIQUEZERO := writeuniquezero_wt,  
                    svt_chi_common_transaction::MAKEREADUNIQUE  := makereadunique_wt,  
                    svt_chi_common_transaction::READPREFERUNIQUE  := readpreferunique_wt,
                    svt_chi_common_transaction::WRITENOSNPFULL_CLEANSHARED := writenosnpfull_cleanshared_wt,
                    svt_chi_common_transaction::WRITENOSNPFULL_CLEANSHAREDPERSISTSEP := writenosnpfull_cleansharedpersistsep_wt,
                    svt_chi_common_transaction::WRITEUNIQUEFULL_CLEANSHARED := writeuniquefull_cleanshared_wt,
                    svt_chi_common_transaction::WRITEUNIQUEFULL_CLEANSHAREDPERSISTSEP := writeuniquefull_cleansharedpersistsep_wt,
                    svt_chi_common_transaction::WRITEUNIQUEPTL_CLEANSHAREDPERSISTSEP := writeuniqueptl_cleansharedpersistsep_wt,
                    svt_chi_common_transaction::WRITEUNIQUEPTL_CLEANSHARED := writeuniqueptl_cleanshared_wt,
                    svt_chi_common_transaction::WRITENOSNPFULL_CLEANINVALID := writenosnpfull_cleaninvalid_wt,
                    svt_chi_common_transaction::WRITENOSNPPTL_CLEANSHARED := writenosnpptl_cleanshared_wt,
                    svt_chi_common_transaction::WRITENOSNPPTL_CLEANSHAREDPERSISTSEP := writenosnpptl_cleansharedpersistsep_wt,
                    svt_chi_common_transaction::WRITENOSNPPTL_CLEANINVALID := writenosnpptl_cleaninvalid_wt,
                    svt_chi_common_transaction::WRITEBACKFULL_CLEANSHARED := writebackfull_cleanshared_wt,
                    svt_chi_common_transaction::WRITEBACKFULL_CLEANSHAREDPERSISTSEP := writebackfull_cleansharedpersistsep_wt,
                    svt_chi_common_transaction::WRITEBACKFULL_CLEANINVALID := writebackfull_cleaninvalid_wt,
                    svt_chi_common_transaction::WRITECLEANFULL_CLEANSHARED := writecleanfull_cleanshared_wt,
                    svt_chi_common_transaction::WRITECLEANFULL_CLEANSHAREDPERSISTSEP := writecleanfull_cleansharedpersistsep_wt,
                    svt_chi_common_transaction::STASHONCESEPUNIQUE      := stashoncesepunique_wt,       
                    svt_chi_common_transaction::STASHONCESEPSHARED      := stashoncesepshared_wt,       
`endif
                    svt_chi_common_transaction::WRITENOSNPPTL   := writenosnpptl_wt,   
                    svt_chi_common_transaction::WRITEUNIQUEFULL := writeuniquefull_wt, 
                    svt_chi_common_transaction::WRITEUNIQUEPTL  := writeuniqueptl_wt,  
                    svt_chi_common_transaction::CLEANSHARED     := cleanshared_wt,     
                    svt_chi_common_transaction::CLEANINVALID    := cleaninvalid_wt,    
                    svt_chi_common_transaction::MAKEINVALID     := makeinvalid_wt,     
                    svt_chi_common_transaction::EOBARRIER       := eobarrier_wt,       
                    svt_chi_common_transaction::ECBARRIER       := ecbarrier_wt,       
                    svt_chi_common_transaction::DVMOP           := dvmop_wt,           
                    svt_chi_common_transaction::PCRDRETURN      := pcrdreturn_wt,      
                    svt_chi_common_transaction::REQLINKFLIT     := reqlinkflit_wt      
                    };
    }
    else if (node_cfg.chi_interface_type == svt_chi_node_configuration::RN_D) 
    {
      xact_type dist {
                      svt_chi_common_transaction::READNOSNP       := readnosnp_wt,       
                      svt_chi_common_transaction::READONCE        := readonce_wt,        
                      `ifdef SVT_CHI_ISSUE_B_ENABLE
                      svt_chi_common_transaction::READONCECLEANINVALID := readoncecleaninvalid_wt,       
                      svt_chi_common_transaction::READONCEMAKEINVALID  := readoncemakeinvalid_wt,       
                      svt_chi_common_transaction::CLEANSHAREDPERSIST   := cleansharedpersist_wt,       
                      svt_chi_common_transaction::PREFETCHTGT          := prefetchtgt_wt,       
                      svt_chi_common_transaction::WRITEUNIQUEFULLSTASH := writeuniquefullstash_wt,       
                      svt_chi_common_transaction::WRITEUNIQUEPTLSTASH  := writeuniqueptlstash_wt,       
                      svt_chi_common_transaction::STASHONCEUNIQUE      := stashonceunique_wt,       
                      svt_chi_common_transaction::STASHONCESHARED      := stashonceshared_wt,       
                      `endif     //issue_b_enable
                      `ifdef SVT_CHI_ISSUE_D_ENABLE
                      svt_chi_common_transaction::CLEANSHAREDPERSISTSEP := cleansharedpersistsep_wt,
                      `endif
                      `ifdef SVT_CHI_ISSUE_F_ENABLE
                      svt_chi_common_transaction::WRITENOSNPFULL_CLEANINVALIDPOPA := writenosnpfull_cleaninvalidpopa_wt,
                      svt_chi_common_transaction::WRITENOSNPPTL_CLEANINVALIDPOPA := writenosnpptl_cleaninvalidpopa_wt,
                      svt_chi_common_transaction::CLEANINVALIDPOPA    := cleaninvalidpopa_wt,    
                      svt_chi_common_transaction::WRITENOSNPDEF := writenosnpdef_wt,
                      `endif
`ifdef SVT_CHI_ISSUE_E_ENABLE
                      svt_chi_common_transaction::WRITENOSNPZERO  := writenosnpzero_wt,  
                      svt_chi_common_transaction::WRITEUNIQUEZERO := writeuniquezero_wt,  
                      svt_chi_common_transaction::MAKEREADUNIQUE  := makereadunique_wt,  
                      svt_chi_common_transaction::READPREFERUNIQUE  := readpreferunique_wt,
                      svt_chi_common_transaction::WRITENOSNPFULL_CLEANSHARED := writenosnpfull_cleanshared_wt,
                      svt_chi_common_transaction::WRITENOSNPFULL_CLEANSHAREDPERSISTSEP := writenosnpfull_cleansharedpersistsep_wt,
                      svt_chi_common_transaction::WRITEUNIQUEFULL_CLEANSHARED := writeuniquefull_cleanshared_wt,
                      svt_chi_common_transaction::WRITEUNIQUEFULL_CLEANSHAREDPERSISTSEP := writeuniquefull_cleansharedpersistsep_wt,
                      svt_chi_common_transaction::WRITEUNIQUEPTL_CLEANSHARED := writeuniqueptl_cleanshared_wt,
                      svt_chi_common_transaction::WRITEUNIQUEPTL_CLEANSHAREDPERSISTSEP := writeuniqueptl_cleansharedpersistsep_wt,
                      svt_chi_common_transaction::WRITENOSNPFULL_CLEANINVALID := writenosnpfull_cleaninvalid_wt,
                      svt_chi_common_transaction::WRITENOSNPPTL_CLEANINVALID := writenosnpptl_cleaninvalid_wt,
                      svt_chi_common_transaction::WRITENOSNPPTL_CLEANSHAREDPERSISTSEP := writenosnpptl_cleansharedpersistsep_wt,
                      svt_chi_common_transaction::WRITENOSNPPTL_CLEANSHARED := writenosnpptl_cleanshared_wt,
                      svt_chi_common_transaction::STASHONCESEPUNIQUE      := stashoncesepunique_wt,       
                      svt_chi_common_transaction::STASHONCESEPSHARED      := stashoncesepshared_wt,       
`endif
                      svt_chi_common_transaction::WRITENOSNPFULL  := writenosnpfull_wt,  
                      svt_chi_common_transaction::WRITENOSNPPTL   := writenosnpptl_wt,   
                      svt_chi_common_transaction::WRITEUNIQUEFULL := writeuniquefull_wt, 
                      svt_chi_common_transaction::WRITEUNIQUEPTL  := writeuniqueptl_wt,  
                      svt_chi_common_transaction::CLEANSHARED     := cleanshared_wt,     
                      svt_chi_common_transaction::CLEANINVALID    := cleaninvalid_wt,    
                      svt_chi_common_transaction::MAKEINVALID     := makeinvalid_wt,     
                      svt_chi_common_transaction::EOBARRIER       := eobarrier_wt,       
                      svt_chi_common_transaction::ECBARRIER       := ecbarrier_wt,       
                      svt_chi_common_transaction::DVMOP           := dvmop_wt,           
                      svt_chi_common_transaction::PCRDRETURN      := pcrdreturn_wt,      
                      svt_chi_common_transaction::REQLINKFLIT     := reqlinkflit_wt      
                      };
  
    }
    else if (node_cfg.chi_interface_type == svt_chi_node_configuration::RN_I) 
    {
      xact_type dist {
                      svt_chi_common_transaction::READNOSNP       := readnosnp_wt,       
                      svt_chi_common_transaction::READONCE        := readonce_wt,        
                      `ifdef SVT_CHI_ISSUE_B_ENABLE
                      svt_chi_common_transaction::READONCECLEANINVALID := readoncecleaninvalid_wt,       
                      svt_chi_common_transaction::READONCEMAKEINVALID  := readoncemakeinvalid_wt,       
                      svt_chi_common_transaction::CLEANSHAREDPERSIST   := cleansharedpersist_wt,       
                      svt_chi_common_transaction::PREFETCHTGT          := prefetchtgt_wt,       
                      svt_chi_common_transaction::WRITEUNIQUEFULLSTASH := writeuniquefullstash_wt,       
                      svt_chi_common_transaction::WRITEUNIQUEPTLSTASH  := writeuniqueptlstash_wt,       
                      svt_chi_common_transaction::STASHONCEUNIQUE      := stashonceunique_wt,       
                      svt_chi_common_transaction::STASHONCESHARED      := stashonceshared_wt,       
                      `endif             //issue_b_enable
                      `ifdef SVT_CHI_ISSUE_D_ENABLE
                      svt_chi_common_transaction::CLEANSHAREDPERSISTSEP := cleansharedpersistsep_wt,
                      `endif
                      svt_chi_common_transaction::WRITENOSNPFULL  := writenosnpfull_wt,  
                      `ifdef SVT_CHI_ISSUE_F_ENABLE
                      svt_chi_common_transaction::WRITENOSNPFULL_CLEANINVALIDPOPA := writenosnpfull_cleaninvalidpopa_wt,
                      svt_chi_common_transaction::WRITENOSNPPTL_CLEANINVALIDPOPA := writenosnpptl_cleaninvalidpopa_wt,
                      svt_chi_common_transaction::CLEANINVALIDPOPA    := cleaninvalidpopa_wt,    
                      svt_chi_common_transaction::WRITENOSNPDEF := writenosnpdef_wt,
                      `endif
`ifdef SVT_CHI_ISSUE_E_ENABLE
                      svt_chi_common_transaction::WRITENOSNPZERO  := writenosnpzero_wt,  
                      svt_chi_common_transaction::WRITEUNIQUEZERO := writeuniquezero_wt, 
                      svt_chi_common_transaction::WRITENOSNPFULL_CLEANSHARED := writenosnpfull_cleanshared_wt,
                      svt_chi_common_transaction::WRITENOSNPFULL_CLEANSHAREDPERSISTSEP := writenosnpfull_cleansharedpersistsep_wt,
                      svt_chi_common_transaction::WRITEUNIQUEFULL_CLEANSHARED := writeuniquefull_cleanshared_wt,
                      svt_chi_common_transaction::WRITEUNIQUEFULL_CLEANSHAREDPERSISTSEP := writeuniquefull_cleansharedpersistsep_wt,
                      svt_chi_common_transaction::WRITEUNIQUEPTL_CLEANSHARED := writeuniqueptl_cleanshared_wt,
                      svt_chi_common_transaction::WRITEUNIQUEPTL_CLEANSHAREDPERSISTSEP := writeuniqueptl_cleansharedpersistsep_wt,
                      svt_chi_common_transaction::WRITENOSNPFULL_CLEANINVALID := writenosnpfull_cleaninvalid_wt,
                      svt_chi_common_transaction::WRITENOSNPPTL_CLEANINVALID := writenosnpptl_cleaninvalid_wt,
                      svt_chi_common_transaction::WRITENOSNPPTL_CLEANSHARED := writenosnpptl_cleanshared_wt,
                      svt_chi_common_transaction::WRITENOSNPPTL_CLEANSHAREDPERSISTSEP := writenosnpptl_cleansharedpersistsep_wt,
                      svt_chi_common_transaction::STASHONCESEPUNIQUE      := stashoncesepunique_wt,       
                      svt_chi_common_transaction::STASHONCESEPSHARED      := stashoncesepshared_wt,       
`endif
                      svt_chi_common_transaction::WRITENOSNPPTL   := writenosnpptl_wt,   
                      svt_chi_common_transaction::WRITEUNIQUEFULL := writeuniquefull_wt, 
                      svt_chi_common_transaction::WRITEUNIQUEPTL  := writeuniqueptl_wt,  
                      svt_chi_common_transaction::CLEANSHARED     := cleanshared_wt,     
                      svt_chi_common_transaction::CLEANINVALID    := cleaninvalid_wt,    
                      svt_chi_common_transaction::MAKEINVALID     := makeinvalid_wt,     
                      svt_chi_common_transaction::EOBARRIER       := eobarrier_wt,       
                      svt_chi_common_transaction::ECBARRIER       := ecbarrier_wt,       
                      svt_chi_common_transaction::PCRDRETURN      := pcrdreturn_wt,      
                      svt_chi_common_transaction::REQLINKFLIT     := reqlinkflit_wt      
                      };
  
    }

    `ifdef SVT_CHI_ISSUE_B_ENABLE
    if(seq_order_type == svt_chi_transaction::REQ_EP_ORDERING_REQUIRED && mem_attr_mem_type == svt_chi_transaction::NORMAL &&
       ((xact_type == svt_chi_transaction::ATOMICSTORE_ADD)  || (xact_type == svt_chi_transaction::ATOMICSTORE_CLR) ||
        (xact_type == svt_chi_transaction::ATOMICSTORE_EOR)  || (xact_type == svt_chi_transaction::ATOMICSTORE_SET) ||
        (xact_type == svt_chi_transaction::ATOMICSTORE_SMAX) || (xact_type == svt_chi_transaction::ATOMICSTORE_SMIN) ||
        (xact_type == svt_chi_transaction::ATOMICSTORE_UMAX) || (xact_type == svt_chi_transaction::ATOMICSTORE_UMIN) ||
        (xact_type == svt_chi_transaction::ATOMICLOAD_ADD)   || (xact_type == svt_chi_transaction::ATOMICLOAD_CLR) ||
        (xact_type == svt_chi_transaction::ATOMICLOAD_EOR)   || (xact_type == svt_chi_transaction::ATOMICLOAD_SET) ||
        (xact_type == svt_chi_transaction::ATOMICLOAD_SMAX)  || (xact_type == svt_chi_transaction::ATOMICLOAD_SMIN) ||
        (xact_type == svt_chi_transaction::ATOMICLOAD_UMAX)  || (xact_type == svt_chi_transaction::ATOMICLOAD_UMIN) ||
        (xact_type == svt_chi_transaction::ATOMICSWAP)       || (xact_type == svt_chi_transaction::ATOMICCOMPARE))) {
         order_type == REQ_ORDERING_REQUIRED;
       } else {
     `endif
       if (use_seq_order_type)
         order_type == seq_order_type;
    `ifdef SVT_CHI_ISSUE_B_ENABLE
    }
    `endif

    if (use_coherent_xacts_mem_attr_snp_attr_for_cmo_atomics) {
      if (xact_type == svt_chi_transaction::CLEANSHARED || xact_type == svt_chi_transaction::CLEANINVALID  || 
          xact_type == svt_chi_transaction::MAKEINVALID 
          `ifdef SVT_CHI_ISSUE_F_ENABLE
           || xact_type == svt_chi_transaction::CLEANINVALIDPOPA
          `endif
          `ifdef SVT_CHI_ISSUE_B_ENABLE
           || xact_type == svt_chi_transaction::CLEANSHAREDPERSIST || 
          xact_type == svt_chi_transaction::ATOMICSTORE_ADD  || xact_type == svt_chi_transaction::ATOMICSTORE_CLR ||
          xact_type == svt_chi_transaction::ATOMICSTORE_EOR  || xact_type == svt_chi_transaction::ATOMICSTORE_SET ||
          xact_type == svt_chi_transaction::ATOMICSTORE_SMAX || xact_type == svt_chi_transaction::ATOMICSTORE_SMIN ||
          xact_type == svt_chi_transaction::ATOMICSTORE_UMAX || xact_type == svt_chi_transaction::ATOMICSTORE_UMIN ||
          xact_type == svt_chi_transaction::ATOMICLOAD_ADD   || xact_type == svt_chi_transaction::ATOMICLOAD_CLR ||
          xact_type == svt_chi_transaction::ATOMICLOAD_EOR   || xact_type == svt_chi_transaction::ATOMICLOAD_SET ||
          xact_type == svt_chi_transaction::ATOMICLOAD_SMAX  || xact_type == svt_chi_transaction::ATOMICLOAD_SMIN ||
          xact_type == svt_chi_transaction::ATOMICLOAD_UMAX  || xact_type == svt_chi_transaction::ATOMICLOAD_UMIN ||
          xact_type == svt_chi_transaction::ATOMICSWAP       || xact_type == svt_chi_transaction::ATOMICCOMPARE
          `endif
          `ifdef SVT_CHI_ISSUE_D_ENABLE
           || xact_type == svt_chi_transaction::CLEANSHAREDPERSISTSEP 
          `endif
         ){
           mem_attr_is_early_wr_ack_allowed == 1;
           mem_attr_is_cacheable == 1;
           mem_attr_mem_type == svt_chi_transaction::NORMAL;
           snp_attr_is_snoopable == 1;
      }
    }
    if(use_seq_data_size)
      data_size == seq_data_size; 
    if(use_seq_p_crd_return_on_retry_ack)
      p_crd_return_on_retry_ack == seq_p_crd_return_on_retry_ack; 
    if (gen_uniq_txn_id)
      txn_id ==  sequence_index % (2^`SVT_CHI_TXN_ID_WIDTH);
    // If directed address is enabled, that gets priority.
    // Otherwise, decided based on addr_mode. If addr_mode
    // is TARGET_HN_INDEX, no need to constrain the address,
    // but need to constrain the hn_node_index. Proceed 
    // further for other types of addr_mode based on the
    // intended functionality.
    if (randomize_with_directed_addr) {
      addr == directed_addr;
      if(xact_type == svt_chi_transaction::EVICT
         `ifdef SVT_CHI_ISSUE_B_ENABLE
         || xact_type == svt_chi_transaction::READONCEMAKEINVALID
         `endif
        ) {
        mem_attr_allocate_hint == 1'b0;
      }
      `ifdef SVT_CHI_ISSUE_B_ENABLE
        else if(xact_type == svt_chi_transaction::WRITEEVICTFULL){
          mem_attr_allocate_hint == 1'b1;
        }
        else if(use_directed_mem_attr) {
          mem_attr_allocate_hint == directed_mem_attr_allocate_hint;
        }
      `else
        mem_attr_allocate_hint == directed_mem_attr_allocate_hint;
      `endif
      if(use_directed_non_secure_access) {
        is_non_secure_access == directed_is_non_secure_access;
      }
      `ifdef SVT_CHI_ISSUE_F_ENABLE
      if(node_cfg.rme_support == svt_chi_node_configuration::CHI_RME_TRUE && use_directed_non_secure_ext) {
        non_secure_ext == directed_non_secure_ext;
      }
      `endif
      if(use_directed_snp_attr) {
        snp_attr_is_snoopable == directed_snp_attr_is_snoopable;
          if (directed_snp_attr_is_snoopable) {
              snp_attr_snp_domain_type == directed_snp_attr_snp_domain_type;
          }
      }
      if(use_directed_data_size){
        data_size == directed_data_size; 
      }
      if(use_directed_data){
        data == directed_data; 
      }
      if(use_directed_byte_enable){
        byte_enable == directed_byte_enable; 
      }
      if(use_directed_allocate_in_cache){
        if(xact_type == svt_chi_transaction::CLEANUNIQUE){
          allocate_in_cache == directed_allocate_in_cache;
        }
      }
    }
    else if (addr_mode == TARGET_HN_INDEX)
    {
      hn_node_idx == seq_hn_node_idx;
    }
    else  if ((addr_mode == SEQUENTIAL_OVERLAPPED_ADDRESS) ||
              (addr_mode == SEQUENTIAL_NONOVERLAPPED_ADDRESS)) 
    {
      if (sequence_index == 0)
        addr inside {[start_addr:_end_addr_for_sequential_addr_mode]};
      else
        addr == (_previous_xact_addr + node_cfg.cache_line_size);
    }
    else if (addr_mode == RANDOM_ADDRESS_IN_RANGE) { 
      addr inside {[start_addr:end_addr]};
    }
    else if (addr_mode != RANDOM_ADDRESS) {
      if (addr_mode != IGNORE_ADDRESSING_MODE) { 
          addr inside {[start_addr:end_addr]};
`protected
+8gZRTC<ZOTJEPRPX\65+8V3@e#BA(+;Ya01IRfGO.A68^\R\J:<1)MV[RBcX^QR
E2;gQXE71>b.gZbJF/_,;\V34$
`endprotected
 
          addr[5:0] == 'h0;
      }
      else {
        addr[5:0] == 0;
      }
    }

  };

`ifdef SVT_CHI_ISSUE_B_ENABLE
  local_rn_xact=rn_xact;
  if((rn_xact.xact_type == svt_chi_common_transaction::ATOMICSTORE_ADD) ||
     (rn_xact.xact_type == svt_chi_common_transaction::ATOMICSTORE_CLR) ||     
     (rn_xact.xact_type == svt_chi_common_transaction::ATOMICSTORE_EOR) ||    
     (rn_xact.xact_type == svt_chi_common_transaction::ATOMICSTORE_SET) ||     
     (rn_xact.xact_type == svt_chi_common_transaction::ATOMICSTORE_SMAX) ||       
     (rn_xact.xact_type == svt_chi_common_transaction::ATOMICSTORE_SMIN) ||      
     (rn_xact.xact_type == svt_chi_common_transaction::ATOMICSTORE_UMAX) ||       
     (rn_xact.xact_type == svt_chi_common_transaction::ATOMICSTORE_UMIN) ||      
     (rn_xact.xact_type == svt_chi_common_transaction::ATOMICLOAD_ADD) ||  
     (rn_xact.xact_type == svt_chi_common_transaction::ATOMICLOAD_CLR) ||    
     (rn_xact.xact_type == svt_chi_common_transaction::ATOMICLOAD_EOR) ||    
     (rn_xact.xact_type == svt_chi_common_transaction::ATOMICLOAD_SET) ||    
     (rn_xact.xact_type == svt_chi_common_transaction::ATOMICLOAD_SMAX) ||      
     (rn_xact.xact_type == svt_chi_common_transaction::ATOMICLOAD_SMIN) ||     
     (rn_xact.xact_type == svt_chi_common_transaction::ATOMICLOAD_UMAX) ||      
     (rn_xact.xact_type == svt_chi_common_transaction::ATOMICLOAD_UMIN) ||     
     (rn_xact.xact_type == svt_chi_common_transaction::ATOMICSWAP) ||
     (rn_xact.xact_type == svt_chi_common_transaction::ATOMICCOMPARE))begin 
      
	 if ( rn_xact.snp_attr_is_snoopable == 1'b1 ) begin
	   rn_xact.snoopme = seq_snoopme;
	 end
       rn_xact.endian = seq_endian;
       `svt_xvm_debug("randomize_xact",$sformatf("seq_snoopme=%0d seq_endian=%s",seq_snoopme,seq_endian.name()));
  end
`endif

  if(req_success == 1)
     _previous_xact_addr = rn_xact.addr;

  `svt_debug("randomize_xact",$psprintf("req_success - %b", req_success));
  `svt_verbose("randomize_xact", rn_xact.sprint());
endtask // randomize_xact

endclass: chi_subsys_directed_coh_wr_rd_check_seq


