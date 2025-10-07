class chi_subsys_rd_txn_directed_seq extends svt_chi_rn_transaction_base_sequence;

  /** Parameter that controls the number of transactions that will be generated */
  rand int unsigned sequence_length = 10;

  /** @cond PRIVATE */  
  /** Defines the byte enable */
  rand bit [(`SVT_CHI_MAX_BE_WIDTH-1):0] byte_enable = 0;
  
  /** Stores the data written in Cache */
  rand bit [511:0]   data_in_cache;
  
  /** Transaction address */
  rand bit [(`SVT_CHI_MAX_ADDR_WIDTH-1):0]   addr; 
  
  /** Transaction txn_id */
  rand bit[(`SVT_CHI_TXN_ID_WIDTH-1):0] seq_txn_id = 0;

  /** Parameter that controls Suspend CompAck bit of the transaction */
  bit seq_suspend_comp_ack = 0;

  /** Parameter that controls Expect CompAck bit of the transaction */
  bit seq_exp_comp_ack = 0;
  bit seq_exp_comp_ack_status;
  bit seq_suspend_comp_ack_status;
  
  bit enable_outstanding = 0;
  
  /** Flag used to bypass read data check */
  rand bit by_pass_read_data_check = 0;
  
  /** Order type for transaction  is no_ordering_required */
  rand svt_chi_transaction::order_type_enum seq_order_type = svt_chi_transaction::REQ_EP_ORDERING_REQUIRED;

  /** Parameter that controls the MemAttr and SnpAttr of the transaction */
  rand bit seq_mem_attr_allocate_hint = 0;
  rand bit seq_mem_attr_is_early_wr_ack_allowed = 0;
  rand bit seq_mem_attr_mem_type = 1;
  rand bit seq_snp_attr_snp_domain_type = 0;
  rand bit seq_is_non_secure_access = 0;

  /** Handle to CHI Node configuration */
  svt_chi_node_configuration cfg;

  /** Controls using seq_is_non_secure_access or not */
  rand bit use_seq_is_non_secure_access;
  
  /** Local variables */
  int received_responses = 0;

  /** Parameter that controls the type of transaction that will be generated */
  rand svt_chi_transaction::xact_type_enum seq_xact_type;
  
  /** Handle to the read transaction sent out */
  svt_chi_rn_transaction read_tran;

  bit k_decode_err_illegal_acc_format_test_unsupported_size = 0; 
  bit datasize_8bytes_or_16bytes = 1;

  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length <= 100;
  }

  `ifdef SVT_CHI_ISSUE_E_ENABLE
  constraint valid_txn_id_values {
      /** Constraining the txn_id to be less than 1024 when macro SVT_CHI_ISSUE_E_ENABLE is defined and chi_spec_revision is equal to ISSUE_D */
       if (node_cfg.chi_spec_revision == svt_chi_node_configuration::ISSUE_D) {
         seq_txn_id inside {[0:1023]};
       }
      /** Constraining the txn_id to be less than 256 when macro SVT_CHI_ISSUE_E_ENABLE is defined and chi_spec_revision is less than ISSUE_D */
       else if (node_cfg.chi_spec_revision <= svt_chi_node_configuration::ISSUE_C) {
         seq_txn_id inside {[0:255]};
       }
  }
  `elsif SVT_CHI_ISSUE_D_ENABLE
  constraint valid_txn_id_values {
      /** Constraining the txn_id to be less than 256 when macro SVT_CHI_ISSUE_D_ENABLE is defined and chi_spec_revision is less than ISSUE_D */
       if (node_cfg.chi_spec_revision <= svt_chi_node_configuration::ISSUE_C) {
         seq_txn_id inside {[0:255]};
       }
  }
  `endif

  constraint reasonable_coherent_load_xact_type {
`ifdef SVT_CHI_ISSUE_E_ENABLE
      seq_xact_type inside {
                          svt_chi_transaction::READSHARED, 
                          svt_chi_transaction::READONCE, 
                          svt_chi_transaction::READCLEAN, 
                          svt_chi_transaction::READUNIQUE,
                          svt_chi_transaction::READSPEC,
                          svt_chi_transaction::READNOTSHAREDDIRTY,
                          svt_chi_transaction::READPREFERUNIQUE,
                          svt_chi_transaction::READONCECLEANINVALID,
                          svt_chi_transaction::READONCEMAKEINVALID,
                          svt_chi_transaction::READNOSNP
                         };
`elsif SVT_CHI_ISSUE_B_ENABLE
    //Can't look at svt_chi_node_configuration::chi_spec_revision here as the node configuration handle is only obtained in the body()
    //The code which calls this sequence should ensure that the CHIE Read transaction types are selected only if the corresponding
    //node configuration has svt_chi_node_configuration::chi_spec_revision set to svt_chi_node_configuration::ISSUE_B
    //if(cfg.chi_spec_revision >= svt_chi_node_configuration::ISSUE_B) {
      seq_xact_type inside {
                          svt_chi_transaction::READSHARED, 
                          svt_chi_transaction::READONCE, 
                          svt_chi_transaction::READCLEAN, 
                          svt_chi_transaction::READUNIQUE,
                          svt_chi_transaction::READSPEC,
                          svt_chi_transaction::READNOTSHAREDDIRTY,
                          svt_chi_transaction::READONCECLEANINVALID,
                          svt_chi_transaction::READONCEMAKEINVALID,
                          svt_chi_transaction::READNOSNP
                         };
 `else
      seq_xact_type inside {
                          svt_chi_transaction::READSHARED, 
                          svt_chi_transaction::READONCE, 
                          svt_chi_transaction::READCLEAN, 
                          svt_chi_transaction::READUNIQUE,
                          svt_chi_transaction::READNOSNP 
                         };
 `endif
  } 

  /** @endcond */
  /** UVM/OVM Object Utility macro */
  `svt_xvm_object_utils(chi_subsys_rd_txn_directed_seq)
  `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

    function new(string name="chi_subsys_rd_txn_directed_seq");
        super.new(name);
        //Set the response depth to -1, to accept infinite number of responses
        this.set_response_queue_depth(-1);
    endfunction

  // -----------------------------------------------------------------------------
  virtual task pre_start();
    bit status;
    bit enable_outstanding_status;
    super.pre_start();
    raise_phase_objection();
    status = uvm_config_db #(int unsigned)::get(null, get_full_name(), "sequence_length", sequence_length);
    `svt_xvm_debug("body", $sformatf("sequence_length is %0d as a result of %0s.", sequence_length, status ? "config DB" : "randomization"));
    enable_outstanding_status = uvm_config_db#(bit)::get(m_sequencer, get_type_name(), "enable_outstanding", enable_outstanding);
    `svt_xvm_debug("body", $sformatf("enable_outstanding is %0d as a result of %0s", enable_outstanding, (enable_outstanding_status?"config DB":"default setting")));
    seq_exp_comp_ack_status = uvm_config_db#(bit)::get(m_sequencer, get_type_name(), "seq_exp_comp_ack", seq_exp_comp_ack);
    `svt_xvm_debug("body", $sformatf("seq_exp_comp_ack is %0d as a result of %0s", seq_exp_comp_ack, (seq_exp_comp_ack_status?"config DB":"default setting")));
    seq_suspend_comp_ack_status = uvm_config_db#(bit)::get(m_sequencer, get_type_name(), "seq_suspend_comp_ack", seq_suspend_comp_ack);
    `svt_xvm_debug("body", $sformatf("seq_suspend_comp_ack is %0d as a result of %0s", seq_suspend_comp_ack, (seq_suspend_comp_ack_status?"config DB":"default setting")));
  endtask // pre_start
  
  // -----------------------------------------------------------------------------
  virtual task body();
    svt_configuration get_cfg;
    bit rand_success;
 
    `svt_xvm_debug("body", "Entered ...")

    if (enable_outstanding)
      track_responses();
   
    /** Obtain a handle to the port configuration */
    p_sequencer.get_cfg(get_cfg);
    if (!$cast(cfg, get_cfg)) begin
      `svt_xvm_fatal("body", "Unable to $cast the configuration to a svt_chi_node_configuration class");
    end
    get_rn_virt_seqr();
    
    for(int i = 0; i < sequence_length; i++) begin
       
      /** Set up the write transaction */
      `svt_xvm_create(read_tran)
      read_tran.chi_reasonable_exp_comp_ack.constraint_mode(0);
      read_tran.cfg = this.cfg;
      rand_success = read_tran.randomize() with {
        if(hn_addr_rand_type == svt_chi_rn_transaction_base_sequence::DIRECTED_HN_NODE_IDX_RAND_TYPE)
          hn_node_idx == seq_hn_node_idx;
        else if (hn_addr_rand_type == svt_chi_rn_transaction_base_sequence::DIRECTED_ADDR_RANGE_RAND_TYPE) {
          addr >= min_addr;
          addr <= max_addr;
        //   `ifndef SVT_CHI_ISSUE_A_ENABLE
           if(xact_type == svt_chi_transaction::READONCEMAKEINVALID) {
             mem_attr_allocate_hint == 0;
           }
           else {    
             mem_attr_allocate_hint == seq_mem_attr_allocate_hint;
           }
        //   `else
            // mem_attr_allocate_hint == seq_mem_attr_allocate_hint;
        //   `endif
          seq_snp_attr_snp_domain_type == seq_snp_attr_snp_domain_type;
        }
        mem_attr_is_early_wr_ack_allowed == seq_mem_attr_is_early_wr_ack_allowed;
        mem_attr_mem_type  == seq_mem_attr_mem_type;
        order_type == seq_order_type;
        
        xact_type == seq_xact_type;
        //order_type == seq_order_type;
        // order_type == svt_chi_rn_transaction::REQ_ORDERING_REQUIRED;
        txn_id == seq_txn_id;
        data_size == (k_decode_err_illegal_acc_format_test_unsupported_size==0) ? svt_chi_rn_transaction::SIZE_4BYTE : svt_chi_rn_transaction::SIZE_8BYTE;
        if (use_seq_is_non_secure_access) is_non_secure_access == seq_is_non_secure_access;
        is_likely_shared == 0;
        is_exclusive == 0;
        exp_comp_ack == 0;
       
        if (xact_type == svt_chi_transaction::CLEANUNIQUE){
          data == data_in_cache;
        }
      };
      void'($value$plusargs("datasize_8bytes=%0b",datasize_8bytes_or_16bytes));
      read_tran.data_size = (k_decode_err_illegal_acc_format_test_unsupported_size==0) ? svt_chi_rn_transaction::SIZE_4BYTE : ((datasize_8bytes_or_16bytes==1) ? svt_chi_rn_transaction::SIZE_8BYTE : svt_chi_rn_transaction::SIZE_16BYTE);

      `svt_xvm_debug("body", $sformatf("Sending CHI READ transaction %0s", `SVT_CHI_PRINT_PREFIX(read_tran)));
      `svt_xvm_verbose("body", $sformatf("Sending CHI READ transaction %0s", read_tran.sprint()));
      
      if(seq_exp_comp_ack_status)begin
        /** Expect CompAck field is optional for ReadOnce, ReadNoSnp, CleanShared, CleanInvalid, MakeInvalid in case of RN-I/RN-D */
        if ((cfg.sys_cfg.chi_version == svt_chi_system_configuration::VERSION_5_0) &&
           ((cfg.chi_interface_type == svt_chi_node_configuration::RN_I) ||
            (cfg.chi_interface_type == svt_chi_node_configuration::RN_F) || 
            (cfg.chi_interface_type == svt_chi_node_configuration::RN_D)) 
           ) begin
          read_tran.exp_comp_ack=seq_exp_comp_ack;
        end 
      end
    
      if (read_tran.exp_comp_ack)begin
        read_tran.suspend_comp_ack = seq_suspend_comp_ack;
      end 
      
      `svt_xvm_verbose("body", $sformatf("CHI READ transaction %0s sent", read_tran.sprint()));

      /** Send the Read transaction */
      `svt_xvm_send(read_tran)
      output_xacts.push_back(read_tran);
      if (!enable_outstanding) begin
        get_response(rsp);
        `svt_xvm_verbose("chi_subsys_rd_txn_directed_seq::body",$sformatf("data %0h wysiwyg_data %0h",read_tran.data,read_tran.wysiwyg_data));
         //read_tran.wysiwyg_to_right_aligned_data;
         //read_tran.wysiwyg_to_right_aligned_byte_enable;
        // read_tran.right_aligned_to_wysiwyg_data;
        // read_tran.right_aligned_to_wysiwyg_byte_enable;
        //`svt_xvm_verbose("chi_subsys_rd_txn_directed_seq::body",$sformatf("\ndata %0h after wysiwyg_to_right_aligned_data",read_tran.data));
        // Exclude data checking for CLEANUNIQUE xact_type
        // Also for READSPEC in cases where data is not updated in the RN
        // cache
        if ((seq_xact_type != svt_chi_transaction::CLEANUNIQUE) 
            && (read_tran.is_error_response_received(0) == 0)
// `ifndef SVT_CHI_ISSUE_A_ENABLE
            && (!((seq_xact_type == svt_chi_transaction::READSPEC) && 
                (read_tran.req_status == svt_chi_transaction::ACCEPT) && 
                (read_tran.data_status == svt_chi_transaction::INITIAL))
                )
// `endif
           ) begin
          // Check READ DATA with data written in Cache 
          if(!by_pass_read_data_check) begin
            if (read_tran.data == data_in_cache) begin
              `svt_xvm_debug("body",{`SVT_CHI_PRINT_PREFIX(read_tran),$sformatf("DATA MATCH: Read data is same as data written to cache. Data = %0x", data_in_cache)});
            end
            else begin
              `svt_xvm_error("body",{`SVT_CHI_PRINT_PREFIX(read_tran),$sformatf("DATA MISMATCH: Read data did not match with data written in cache: GOLDEN DATA %x READ DATA %x",data_in_cache,read_tran.data)});
            end
          end
        end
      end
    end//seq_len

    `svt_xvm_debug("body", "Exiting...");
  endtask: body

  virtual task post_body();
    if (enable_outstanding) begin
      `svt_xvm_debug("body", "Waiting for all responses to be received");
      wait (received_responses == sequence_length);
      `svt_xvm_debug("body", "Received all responses. Dropping objections");
    end
    drop_phase_objection();
  endtask

  task track_responses();
    fork
    begin
      forever begin
        read_tran.wait_end();
        if (read_tran.req_status == svt_chi_transaction::RETRY) begin
          if (read_tran.p_crd_return_on_retry_ack == 0) begin
            `svt_xvm_debug("body", $sformatf({`SVT_CHI_PRINT_PREFIX(read_tran), "received retry response. p_crd_return_on_retry_ack = 0. continuing to wait for completion"}));
            wait (read_tran.req_status == svt_chi_transaction::ACTIVE);
          end
          else begin
            `svt_xvm_debug("body", $sformatf({`SVT_CHI_PRINT_PREFIX(read_tran), "received retry response. p_crd_return_on_retry_ack = 1. As request will be cancelled, not waiting for completion"}));
          end
        end
        else begin
          received_responses++;
          `svt_xvm_debug("body", $sformatf({`SVT_CHI_PRINT_PREFIX(read_tran), "transaction complete"}));
          `svt_xvm_verbose("body", $sformatf({$sformatf("load_directed_seq_received response. received_responses = %0d:\n",received_responses), read_tran.sprint()}));
          break;
        end
      end//forever
    end
    join_none
  endtask

endclass: chi_subsys_rd_txn_directed_seq

