class chi_subsys_directed_atomic_self_check_seq extends svt_chi_rn_coherent_transaction_base_sequence;

  /** Handle to CHI Node configuration */
  svt_chi_node_configuration cfg;
  int chiaiu_idx=0;

  bit [ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:0] all_dmi_dii_start_addr[int][$]; 
  bit [ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:0] all_dii_start_addr[int][$]; 
  bit [ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:0] all_dmi_start_addr[int][$]; 
  bit all_dmi_nc[int][$]; 
  bit bypass_data_in_data_out_checks=0;
  bit use_single_mem_region_in_test=0;
  string chi_rn_arg_mem_attr_mem_type = "NORMAL";
  int wt_chi_rn_arg_mem_attr_mem_type_normal = 100;
  ncore_config_pkg::ncoreConfigInfo::sys_addr_csr_t csrq[$];
  addr_trans_mgr_pkg::addr_trans_mgr  m_addr_mgr;

  /** @endcond */
  /** UVM/OVM Object Utility macro */
  `svt_xvm_object_utils(chi_subsys_directed_atomic_self_check_seq)
  `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

    function new(string name="chi_subsys_directed_atomic_self_check_seq");
        super.new(name);
        //Set the response depth to -1, to accept infinite number of responses
        this.set_response_queue_depth(-1);
    endfunction

    function bit check_addr_falls_in_dmi_add_range_with_no_atomic_engine([ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:0] addr);
        <%for(let i=0; i< obj.nDMIs; i++){%>
            <%if(obj.DmiInfo[i].useAtomic == 0){%>
                foreach(ncoreConfigInfo::memregions_info[j]) begin
                    foreach(ncoreConfigInfo::memregions_info[j].UnitIds[k]) begin
                        if((addr >= ncoreConfigInfo::memregions_info[j].start_addr) && (addr <= ncoreConfigInfo::memregions_info[j].end_addr && (ncoreConfigInfo::memregions_info[j].hut == DMI)) && (ncoreConfigInfo::memregions_info[j].UnitIds[k] == <%=i%>)) begin
                            return 0;
                        end
                    end
                end
            <%}%>
        <%}%>
        return 1;
    endfunction:check_addr_falls_in_dmi_add_range_with_no_atomic_engine

    /** pre_body */
    virtual task pre_body();
        bit [ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:0] temp_addr;
        bit push_dmi_addr_with_atomic_engine;
        // preliminary create a queue of start addr by DII or DMI using in the task
        int ig;

        csrq = ncore_config_pkg::ncoreConfigInfo::get_all_gpra();
        m_addr_mgr = addr_trans_mgr::get_instance();
        foreach (csrq[ig]) begin:_foreach_csrq_ig
                    temp_addr[ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:44] = csrq[ig].upp_addr;
                    temp_addr[43:12] = csrq[ig].low_addr;
                    all_dmi_dii_start_addr[csrq[ig].mig_nunitid].push_back(temp_addr);
                    if(csrq[ig].unit.name=="DII")
                       all_dii_start_addr[csrq[ig].mig_nunitid].push_back(temp_addr);
                    else begin
                        //push_dmi_addr_with_atomic_engine = check_addr_falls_in_dmi_add_range_with_no_atomic_engine(temp_addr);
                        push_dmi_addr_with_atomic_engine = m_addr_mgr.allow_atomic_txn_with_addr(temp_addr);
                        if(push_dmi_addr_with_atomic_engine==1) begin
                            all_dmi_start_addr[csrq[ig].mig_nunitid].push_back(temp_addr);
                            all_dmi_nc[csrq[ig].mig_nunitid].push_back(csrq[ig].nc);
                        end
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
    bit [511:0] data_out, data_out_1, exp_data;
    bit [ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:0] addr;
    bit [ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:0] coh_addr;
    bit [ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:0] non_coh_addr;
    int data_size;
    bit en_atomic_op[string];
    bit atomicStore, atomicLoad, atomicSwap, atomicCompare;
    svt_chi_common_transaction::xact_type_enum atomic_op_type;
    bit [63:0] atomic_compare_data, atomic_swap_data, atomic_txndata;
    bit [255:0] atomic_initial_data;
    /** Handle to the read transaction sent out */
    svt_chi_rn_transaction atomic_tran;
    bit run_stimulus = 1;

    if($value$plusargs("AtomicStore_ADD=%0b",en_atomic_op["AtomicStore_ADD"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicStore_ADD"), UVM_LOW)
        atomic_op_type = svt_chi_common_transaction::ATOMICSTORE_ADD  ;
    end
    else if($value$plusargs("AtomicStore_CLR=%0b",en_atomic_op["AtomicStore_CLR"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicStore_CLR"), UVM_LOW)
        atomic_op_type = svt_chi_common_transaction::ATOMICSTORE_CLR  ;
    end
    else if($value$plusargs("AtomicStore_OR=%0b",en_atomic_op["AtomicStore_OR"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicStore_OR"), UVM_LOW)
        atomic_op_type = svt_chi_common_transaction::ATOMICSTORE_EOR  ;
    end
    else if($value$plusargs("AtomicStore_SET=%0b",en_atomic_op["AtomicStore_SET"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicStore_SET"), UVM_LOW)
        atomic_op_type = svt_chi_common_transaction::ATOMICSTORE_SET  ;
    end
    else if($value$plusargs("AtomicStore_MAX=%0b",en_atomic_op["AtomicStore_MAX"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicStore_MAX"), UVM_LOW)
        atomic_op_type = svt_chi_common_transaction::ATOMICSTORE_SMAX ;
    end
    else if($value$plusargs("AtomicStore_MIN=%0b",en_atomic_op["AtomicStore_MIN"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicStore_MIN"), UVM_LOW)
        atomic_op_type = svt_chi_common_transaction::ATOMICSTORE_SMIN ;
    end
    else if($value$plusargs("AtomicStore_UMAX=%0b",en_atomic_op["AtomicStore_UMAX"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicStore_UMAX"), UVM_LOW)
        atomic_op_type = svt_chi_common_transaction::ATOMICSTORE_UMAX ;
    end
    else if($value$plusargs("AtomicStore_UMIN=%0b",en_atomic_op["AtomicStore_UMIN"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicStore_UMIN"), UVM_LOW)
        atomic_op_type = svt_chi_common_transaction::ATOMICSTORE_UMIN ;
    end
    else if($value$plusargs("AtomicLoad_ADD=%0b",en_atomic_op["AtomicLoad_ADD"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicLoad_ADD"), UVM_LOW)
        atomic_op_type = svt_chi_common_transaction::ATOMICLOAD_ADD   ;
    end
    else if($value$plusargs("AtomicLoad_CLR=%0b",en_atomic_op["AtomicLoad_CLR"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicLoad_CLR"), UVM_LOW)
        atomic_op_type = svt_chi_common_transaction::ATOMICLOAD_CLR   ;
    end
    else if($value$plusargs("AtomicLoad_OR=%0b",en_atomic_op["AtomicLoad_OR"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicLoad_OR"), UVM_LOW)
        atomic_op_type = svt_chi_common_transaction::ATOMICLOAD_EOR   ;
    end
    else if($value$plusargs("AtomicLoad_SET=%0b",en_atomic_op["AtomicLoad_SET"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicLoad_SET"), UVM_LOW)
        atomic_op_type = svt_chi_common_transaction::ATOMICLOAD_SET   ;
    end
    else if($value$plusargs("AtomicLoad_MAX=%0b",en_atomic_op["AtomicLoad_MAX"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicLoad_MAX"), UVM_LOW)
        atomic_op_type = svt_chi_common_transaction::ATOMICLOAD_SMAX  ;
    end
    else if($value$plusargs("AtomicLoad_MIN=%0b",en_atomic_op["AtomicLoad_MIN"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicLoad_MIN"), UVM_LOW)
        atomic_op_type = svt_chi_common_transaction::ATOMICLOAD_SMIN  ;
    end
    else if($value$plusargs("AtomicLoad_UMAX=%0b",en_atomic_op["AtomicLoad_UMAX"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicLoad_UMAX"), UVM_LOW)
        atomic_op_type = svt_chi_common_transaction::ATOMICLOAD_UMAX  ;
    end
    else if($value$plusargs("AtomicLoad_UMIN=%0b",en_atomic_op["AtomicLoad_UMIN"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicLoad_UMIN"), UVM_LOW)
        atomic_op_type = svt_chi_common_transaction::ATOMICLOAD_UMIN  ;
    end
    else if($value$plusargs("AtomicSwap=%0b",en_atomic_op["AtomicSwap"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicSwap"), UVM_LOW)
        atomic_op_type = svt_chi_common_transaction::ATOMICSWAP       ;
    end
    else if($value$plusargs("AtomicCompare=%0b",en_atomic_op["AtomicCompare"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicCompare"), UVM_LOW)
        atomic_op_type = svt_chi_common_transaction::ATOMICCOMPARE    ;
    end else begin // by default
        en_atomic_op["AtomicStore_ADD"]=1;
        atomic_op_type = svt_chi_common_transaction::ATOMICSTORE_ADD  ;
    end

    if(
       en_atomic_op["AtomicStore_ADD"] || en_atomic_op["AtomicStore_CLR"] || en_atomic_op["AtomicStore_OR"] || en_atomic_op["AtomicStore_SET"] ||
       en_atomic_op["AtomicStore_MAX"] || en_atomic_op["AtomicStore_MIN"] || en_atomic_op["AtomicStore_UMAX"] || en_atomic_op["AtomicStore_UMIN"]
    ) begin
        atomicStore = 1;
    end
    else if(
       en_atomic_op["AtomicLoad_ADD"] || en_atomic_op["AtomicLoad_CLR"] || en_atomic_op["AtomicLoad_OR"] || en_atomic_op["AtomicLoad_SET"] ||
       en_atomic_op["AtomicLoad_MAX"] || en_atomic_op["AtomicLoad_MIN"] || en_atomic_op["AtomicLoad_UMAX"] || en_atomic_op["AtomicLoad_UMIN"]
    ) begin
        atomicLoad = 1;
    end
    else if(en_atomic_op["AtomicSwap"]) begin
        atomicSwap = 1;
    end
    else if(en_atomic_op["AtomicCompare"]) begin
        atomicCompare = 1;
    end

    `uvm_info(get_full_name(), "Starting CHISEQ chi_subsys_directed_atomic_self_check_seq ...",UVM_LOW)
    /** Obtain a handle to the port configuration */
    p_sequencer.get_cfg(get_cfg);
    if (!$cast(cfg, get_cfg)) begin
      `svt_xvm_fatal("body", "Unable to $cast the configuration to a svt_chi_node_configuration class");
    end
    get_rn_virt_seqr();
    
    for(int crit_dw=0;crit_dw<8;crit_dw=crit_dw+1) begin : looping_for_each_critical_DW
      for (int j = ((atomicCompare==1)?1:0); j < ((atomicCompare==1)?6:4); j++) begin : looping_for_each_req_size
        for(int all_dmi=0;all_dmi<(use_single_mem_region_in_test ? 1 :all_dmi_start_addr.size());all_dmi=all_dmi+1) begin : looping_for_each_dmi
          if($test$plusargs("k_directed_test_wr_rd_to_all_dmi")) begin : if_plusarg_en_k_directed_test_wr_rd_to_all_dmi
            for(int all_dmi_in_ig=0;all_dmi_in_ig<(use_single_mem_region_in_test ? 1 :all_dmi_start_addr[all_dmi].size());all_dmi_in_ig=all_dmi_in_ig+1) begin : looping_for_each_dmi_in_ig
              //if(all_dmi_nc[all_dmi][all_dmi_in_ig]==1) begin : non_coh_regions
                for(int i = 0; i < sequence_length; i++) begin : looping_for_sequence_length
    svt_chi_rn_transaction           rn_xact;
    bit[`SVT_CHI_MAX_ADDR_WIDTH-1:0] directed_addr;
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

    chi_subsys_pkg::chi_subsys_read_directed_seq svt_seq;

                      /************/
                      /* Write    */
                      /************/

                      // Used to sink the responses from the response queue.
                      sink_responses();
                      if(initialize_cachelines == 0) begin
                        initialize_cachelines_done = 1; 
                      end

                      assert(std::randomize(data_out));
                      data_size = j;  // 2,4,8,16,32,64 bytes
                      non_coh_addr = all_dmi_start_addr[all_dmi][all_dmi_in_ig] + (i*64);
                      non_coh_addr[5:3] = crit_dw;
       if ( $test$plusargs("AtomicCompare_case1") || $test$plusargs("AtomicCompare_case2")) begin
           if(((j== 3'b010) && (non_coh_addr[0] == 1'b0))
           || ((j== 3'b011)  && (non_coh_addr[1:0] == 2'b0))
           || ((j== 3'b100)  && (non_coh_addr[2:0] == 3'b0))
           || ((j== 3'b101)  && (non_coh_addr[3:0] == 4'b0))) begin
               run_stimulus = 1;
           end else begin
               run_stimulus = 0;  // Invalid cases for atomic compare
           end
       end
       else begin
           run_stimulus = 1;
       end
           
                if(run_stimulus==1) begin : run_stimulus_

                      directed_data = data_out;
                      directed_data_size = data_size;
                      directed_addr = non_coh_addr;
                      sequence_length = 1;
                      directed_addr_mailbox.put(directed_addr);
                      directed_data_mailbox.put(directed_data);
                      directed_data_size_mailbox.put(directed_data_size);
                      directed_is_non_secure_access_mailbox.put(0);
                      directed_byte_enable_mailbox.put({`SVT_CHI_MAX_BE_WIDTH{1'b1}});
                      directed_snp_attr_is_snoopable_mailbox.put(0);
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
                      writenosnpfull_wt = 0;
                      writenosnpptl_wt = 1;
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

                      `uvm_info(get_full_name, $sformatf("CHI-%0d DMI [%0d][IG-%0d] Non-coherent Write Address = 0x%x,size = %d, Write Data = %x Critical DW=%0d",chiaiu_idx,all_dmi,all_dmi_in_ig, non_coh_addr, data_size, data_out,crit_dw), UVM_LOW) 

                      /************/
                      /* Atomic   */
                      /************/
                      `svt_xvm_create(atomic_tran)
                      atomic_tran.cfg = this.cfg;
                      assert(std::randomize(atomic_txndata));
                      assert(std::randomize(atomic_compare_data));
                      assert(std::randomize(atomic_swap_data));
                      if ( $test$plusargs("AtomicCompare_case1") || $test$plusargs("AtomicCompare_case2")) begin
                          if(directed_addr[5:3]!=0) begin
                              case(data_size)
                               3 : begin
                                 if((directed_addr[2:0]<(2**directed_data_size)) && (directed_addr[2:0]!=0)) 
                                   data_out = data_out >> (8*((2**directed_data_size) - directed_addr[2:0]));
                               end
                               4 : begin
                                 if((directed_addr[3:0]<(2**directed_data_size)) && (directed_addr[3:0]!=0)) 
                                   data_out = data_out >> (8*((2**directed_data_size) - directed_addr[3:0]));
                               end
                               5 : begin
                                 if((directed_addr[4:0]<(2**directed_data_size)) && (directed_addr[4:0]!=0)) 
                                   data_out = data_out >> (8*((2**directed_data_size) - directed_addr[4:0]));
                               end
                              endcase
                          end
                      end

                      if($test$plusargs("AtomicCompare_case1")) begin
                          case(data_size)
                          1 : atomic_compare_data = data_out[7:0];
                          2 : atomic_compare_data = data_out[15:0];
                          3 : atomic_compare_data = data_out[31:0];
                          4 : atomic_compare_data = data_out[63:0];
                          5 : atomic_compare_data = data_out[127:0];
                          endcase
                      end
                      rand_success = atomic_tran.randomize() with {
                          addr == directed_addr;
                          if(atomicStore || atomicLoad) {    
                            atomic_store_load_txn_data == atomic_txndata; 
                            atomic_store_load_byte_enable == {`SVT_CHI_MAX_ATOMIC_LD_ST_BE_WIDTH{1'b1}};
                          } else if(atomicSwap) {
                            atomic_swap_data == local::atomic_swap_data; 
                            atomic_swap_byte_enable == {`SVT_CHI_MAX_ATOMIC_BE_WIDTH{1'b1}};
                          } else if(atomicCompare) {
                            atomic_swap_data == local::atomic_swap_data; 
                            atomic_swap_byte_enable == {`SVT_CHI_MAX_ATOMIC_BE_WIDTH{1'b1}};
                            atomic_compare_data == local::atomic_compare_data; 
                            atomic_compare_byte_enable == {`SVT_CHI_MAX_ATOMIC_BE_WIDTH{1'b1}};
                          }
                          //mem_attr_allocate_hint == seq_mem_attr_allocate_hint;
                          //seq_snp_attr_snp_domain_type == seq_snp_attr_snp_domain_type;
                          is_non_secure_access == 0;
                          p_crd_return_on_retry_ack ==  1'b0;
                          xact_type == atomic_op_type;
                          endian == svt_chi_base_transaction::LITTLE_ENDIAN;
                          order_type == svt_chi_common_transaction::REQ_ORDERING_REQUIRED;
                          data_size==directed_data_size;
                          response_resp_err_status == NORMAL_OKAY;
                          atomic_dbid_resp_err == NORMAL_OKAY;
                          atomic_comp_resp_err == NORMAL_OKAY;
                          foreach (atomic_write_data_resp_err_status[idx]){
                              atomic_write_data_resp_err_status[idx] inside {
                                  NORMAL_OKAY
                              }; 
                          }
                      };

                      atomic_tran.suspend_wr_data = 0;

                      `uvm_info(get_full_name,$sformatf("Sending CHI ATOMIC transaction %0s", `SVT_CHI_PRINT_PREFIX(atomic_tran)),UVM_LOW)
                      `uvm_info(get_full_name,$sformatf("Sending CHI ATOMIC transaction %0s", atomic_tran.sprint()),UVM_LOW)

                      /** Send the Read transaction */
                      `svt_xvm_send(atomic_tran)
                      output_xacts.push_back(atomic_tran);
                      //if (!enable_outstanding) begin
                        get_response(rsp);
                      //end
                      atomic_initial_data = atomic_tran.atomic_returned_initial_data;
                      `uvm_info(get_full_name, $sformatf("CHI-%0d DMI [%0d][IG-%0d] Atomic %0s Address = 0x%x,size = %d, Write Data = %x Txn Data = %x Init Data = %x Critical DW=%0d",chiaiu_idx,all_dmi,all_dmi_in_ig, atomic_op_type.name(),non_coh_addr, data_size, data_out,atomic_txndata,atomic_initial_data,crit_dw), UVM_LOW) 

                      /************/
                      /* Read     */
                      /************/
                      `svt_xvm_create_on(svt_seq, p_sequencer);
                      svt_seq.sequence_length = 1;
                      svt_seq.enable_outstanding = 0;
                      svt_seq.rd_coh=0;
                      svt_seq.size=directed_data_size;
                      svt_seq.min_addr = directed_addr;
                      svt_seq.max_addr = directed_addr;
                      svt_seq.hn_addr_rand_type = svt_chi_rn_transaction_base_sequence::DIRECTED_ADDR_RANGE_RAND_TYPE;
                      svt_seq.by_pass_read_data_check = 1;
                      svt_seq.use_seq_is_non_secure_access = 1;
                      svt_seq.seq_is_non_secure_access = 0;
                      svt_seq.seq_exp_comp_ack = 0;
                      svt_seq.seq_order_type = svt_chi_common_transaction::REQ_ORDERING_REQUIRED;
                      if(chi_rn_arg_mem_attr_mem_type == "NORMAL") begin
                          svt_seq.seq_mem_attr_mem_type = svt_chi_transaction::NORMAL;
                      end else if(chi_rn_arg_mem_attr_mem_type == "DEVICE") begin
                          svt_seq.seq_mem_attr_mem_type = svt_chi_transaction::DEVICE;
                      end
                     `svt_xvm_send(svt_seq);  
                      data_in = svt_seq.read_tran.data;
                      `uvm_info(get_full_name, $sformatf("CHI-%0d DMI [%0d][IG-%0d] Non-coherent Read Address = 0x%x,size = %d, Read Data = %x Critical DW=%0d",chiaiu_idx,all_dmi,all_dmi_in_ig, non_coh_addr, data_size, data_in,crit_dw), UVM_LOW) 
                      svt_seq = null;

                      for(int set_zero_bits=(8 * (2 ** data_size)); set_zero_bits<512; set_zero_bits=set_zero_bits+1) begin
                          data_out[set_zero_bits] = 1'b0; data_in[set_zero_bits] = 1'b0; atomic_initial_data[set_zero_bits] = 1'b0;
                      end

                      if(atomicLoad || atomicSwap || atomicCompare) begin
                          if(atomicCompare) begin
                              case (data_size)
                              1: begin
                                  data_out[15:8] = 0;
                                  atomic_initial_data[15:8] = 0;
                                  data_in[15:8] = 0;
                              end
                              2: begin
                                  data_out[31:16] = 0;
                                  atomic_initial_data[31:16] = 0;
                                  data_in[31:16] = 0;
                              end
                              3: begin
                                  data_out[63:32] = 0;
                                  atomic_initial_data[63:32] = 0;
                                  data_in[63:32] = 0;
                              end
                              4: begin
                                  data_out[127:64] = 0;
                                  atomic_initial_data[127:64] = 0;
                                  data_in[127:64] = 0;
                              end
                              5: begin
                                  data_out[255:128] = 0;
                                  atomic_initial_data[255:128] = 0;
                                  data_in[255:128] = 0;
                              end
                              endcase
                          end
                          if (data_out != atomic_initial_data) begin
                            if(!bypass_data_in_data_out_checks) 
                                `uvm_error(get_full_name, $sformatf("CHI-%0d DMI [%0d][IG-%0d] Data Mismatch. Address = 0x%x,size = %d Bytes, Atomic Initial Data = %x, Write Data = %x, Critical DW=%0d",chiaiu_idx,all_dmi,all_dmi_in_ig, non_coh_addr, 2**data_size, atomic_initial_data,data_out,crit_dw)) 
                            else
                                `uvm_info(get_full_name, $sformatf("CHI-%0d DMI [%0d][IG-%0d] Data Mismatch. Address = 0x%x,size = %d Bytes, Atomic Initial Data = %x, Write Data = %x, Critical DW=%0d",chiaiu_idx,all_dmi,all_dmi_in_ig, non_coh_addr, 2**data_size, atomic_initial_data,data_out,crit_dw), UVM_LOW) 
                          end
                          else
                            `uvm_info(get_full_name, $sformatf("CHI-%0d DMI [%0d][IG-%0d] Data Write-Atomic Test Match. Address = 0x%x,size = %d Bytes, Atomic Initial Data = %x, Write Data = %x, Critical DW=%0d",chiaiu_idx,all_dmi,all_dmi_in_ig, non_coh_addr, 2**data_size, atomic_initial_data,data_out,crit_dw), UVM_LOW) 
                      end

                      if(atomicStore || atomicLoad || atomicSwap|| atomicCompare) begin
                          for(int set_zero_bits=(8 * (2 ** data_size)); set_zero_bits<512; set_zero_bits=set_zero_bits+1) begin
                              atomic_txndata[set_zero_bits] = 1'b0;
                          end

                          if(atomicStore || atomicLoad) begin
                              exp_data = perform_atomic_op(atomic_op_type.name,data_out,atomic_txndata,(2**data_size),non_coh_addr);
                          end
                          else if(atomicSwap)
                              exp_data = atomic_swap_data;
                          else if(atomicCompare) begin
                              exp_data = (atomic_compare_data==data_in)?atomic_swap_data:data_in;
                          end

                          for(int set_zero_bits=(8 * (2 ** data_size)); set_zero_bits<512; set_zero_bits=set_zero_bits+1) begin
                              exp_data[set_zero_bits] = 1'b0; data_in[set_zero_bits] = 1'b0;
                          end

                          if (exp_data != data_in) begin
                            if(!bypass_data_in_data_out_checks) 
                                `uvm_error(get_full_name, $sformatf("Data Mismatch CHI-%0d. Address = %x, size = %d Bytes, Exp Data = %x, Act Data = %x", chiaiu_idx,non_coh_addr, 2**data_size,exp_data, data_in))
                            else
                            `uvm_info(get_full_name,$sformatf("Data Mismatch CHI-%0d. Address = %x, size = %d Bytes, Exp Data = %x, Act Data = %x", chiaiu_idx,non_coh_addr, 2**data_size,exp_data, data_in),UVM_NONE)
                          end
                          else begin
                              `uvm_info(get_full_name, $sformatf("CHIAIU-%0d Data Transfer Write-Atomic-Read Test Match. DMI Target GPR[%0d] Address = %x, size = %d Bytes, Exp Data = %x, Act Data = %x Critical DW=%0d",chiaiu_idx,all_dmi, non_coh_addr, 2**data_size,exp_data, data_in,crit_dw), UVM_LOW)
                          end
                      end // if(atomicStore) begin
                      else begin
                      end

                end : run_stimulus_
                end : looping_for_sequence_length
              //end : non_coh_regions
            end : looping_for_each_dmi_in_ig
          end : if_plusarg_en_k_directed_test_wr_rd_to_all_dmi
        end : looping_for_each_dmi
      end : looping_for_each_req_size
    end : looping_for_each_critical_DW

    `uvm_info(get_full_name(), "Finished CHISEQ chi_subsys_directed_atomic_self_check_seq ...",UVM_LOW);
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
  // 1) to avoid unwanted scenarios such as exclusive, writedatacancel, error, ewa=0 etc.
  // 2) to control normal and device memory type
    mem_attr_is_early_wr_ack_allowed == 0;
    if(xact_type==svt_chi_common_transaction::WRITENOSNPPTL) {
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

function bit [255:0] perform_atomic_op(string atomic_op, bit [63:0]atomic_initial_data, bit [63:0]atomic_txndata, int num_bytes=2,  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr=0);
int mem_region;
int dmi_index ;
<% if(obj.nDMIs>0) { %>
int dmi_width[<%=obj.nDMIs%>];
<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
    bit [<%=obj.DmiInfo[pidx].wData%>-1:0] atomic_initial_data_tmp_<%=pidx%>, atomic_txndata_tmp_<%=pidx%>, atomic_initial_data_<%=pidx%>, atomic_txndata_<%=pidx%>;
    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] byte_addr_<%=pidx%> = addr[<%=Math.log2(obj.DmiInfo[pidx].wData/8)%>-1:0];
<% } %>
<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
    dmi_width[<%=pidx%>]= <%=obj.DmiInfo[pidx].wData%>;
<% }} %>
  dmi_index = ncoreConfigInfo::map_addr2dmi_or_dii(addr, mem_region) - <%=obj.DmiInfo[0].FUnitId%>;
  //$display("concerto_fullsys_direct_wr_rd_legacy_test::perform_atomic_op::dmi_index %0d addr 0x%0h",dmi_index,addr);

  if(atomic_op == "ATOMICSTORE_ADD" || atomic_op == "ATOMICLOAD_ADD") begin
      `uvm_info(get_full_name,$sformatf("perform_atomic_op::atomic_op=%0s atomic_initial_data=0x%0h atomic_txndata=0x%0h num_bytes=%0d addr=0x%0h output=0x%0h",atomic_op,atomic_initial_data,atomic_txndata,num_bytes,addr,(atomic_initial_data + atomic_txndata)),UVM_MEDIUM)
      return(atomic_initial_data + atomic_txndata);
  end
  else if(atomic_op == "ATOMICSTORE_CLR" || atomic_op == "ATOMICLOAD_CLR") begin
      `uvm_info(get_full_name,$sformatf("perform_atomic_op::atomic_op=%0s atomic_initial_data=0x%0h atomic_txndata=0x%0h num_bytes=%0d addr=0x%0h output=0x%0h",atomic_op,atomic_initial_data,atomic_txndata,num_bytes,addr,(atomic_initial_data & (~atomic_txndata))),UVM_MEDIUM)
      return(atomic_initial_data & (~atomic_txndata));
  end
  else if(atomic_op == "ATOMICSTORE_EOR" || atomic_op == "ATOMICLOAD_EOR") begin
      `uvm_info(get_full_name,$sformatf("perform_atomic_op::atomic_op=%0s atomic_initial_data=0x%0h atomic_txndata=0x%0h num_bytes=%0d addr=0x%0h output=0x%0h",atomic_op,atomic_initial_data,atomic_txndata,num_bytes,addr,(atomic_initial_data ^ atomic_txndata)),UVM_MEDIUM)
      return(atomic_initial_data ^ atomic_txndata);
  end
  else if(atomic_op == "ATOMICSTORE_SET" || atomic_op == "ATOMICLOAD_SET") begin
      `uvm_info(get_full_name,$sformatf("perform_atomic_op::atomic_op=%0s atomic_initial_data=0x%0h atomic_txndata=0x%0h num_bytes=%0d addr=0x%0h output=0x%0h",atomic_op,atomic_initial_data,atomic_txndata,num_bytes,addr,(atomic_initial_data | atomic_txndata)),UVM_MEDIUM)
      return(atomic_initial_data | atomic_txndata);
  end
  else if(atomic_op == "ATOMICSTORE_SMAX" || atomic_op == "ATOMICLOAD_SMAX") begin
<% if(obj.nDMIs>0) { %>
<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
    if(dmi_index==<%=pidx%>) begin
      atomic_txndata_<%=pidx%>      = atomic_txndata;
      atomic_initial_data_<%=pidx%> = atomic_initial_data;
      atomic_txndata_tmp_<%=pidx%>      = atomic_txndata_<%=pidx%> <<((dmi_width[dmi_index]/8)- num_bytes)*8;
      atomic_initial_data_tmp_<%=pidx%> = atomic_initial_data_<%=pidx%> <<((dmi_width[dmi_index]/8) - num_bytes)*8;
      `uvm_info(get_full_name,$sformatf("perform_atomic_op::atomic_op=%0s atomic_initial_data=0x%0h atomic_txndata=0x%0h num_bytes=%0d addr=0x%0h output=0x%0h",atomic_op,atomic_initial_data,atomic_txndata,num_bytes,addr,(($signed(atomic_txndata_tmp_<%=pidx%>) > $signed(atomic_initial_data_tmp_<%=pidx%>)) ? atomic_txndata: atomic_initial_data)),UVM_MEDIUM)
      return(($signed(atomic_txndata_tmp_<%=pidx%>) > $signed(atomic_initial_data_tmp_<%=pidx%>)) ? atomic_txndata: atomic_initial_data);
    end
<% }} %>
  end
  else if(atomic_op == "ATOMICSTORE_SMIN" || atomic_op == "ATOMICLOAD_SMIN") begin
<% if(obj.nDMIs>0) { %>
<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
    if(dmi_index==<%=pidx%>) begin
      atomic_txndata_<%=pidx%>      = atomic_txndata;
      atomic_initial_data_<%=pidx%> = atomic_initial_data;
      atomic_txndata_tmp_<%=pidx%>      = atomic_txndata_<%=pidx%> <<((dmi_width[dmi_index]/8)- num_bytes)*8;
      atomic_initial_data_tmp_<%=pidx%> = atomic_initial_data_<%=pidx%> <<((dmi_width[dmi_index]/8) - num_bytes)*8;
      `uvm_info(get_full_name,$sformatf("perform_atomic_op::atomic_op=%0s atomic_initial_data=0x%0h atomic_txndata=0x%0h num_bytes=%0d addr=0x%0h output=0x%0h",atomic_op,atomic_initial_data,atomic_txndata,num_bytes,addr,(($signed(atomic_txndata_tmp_<%=pidx%>) < $signed(atomic_initial_data_tmp_<%=pidx%>)) ? atomic_txndata: atomic_initial_data)),UVM_MEDIUM)
      return(($signed(atomic_txndata_tmp_<%=pidx%>) < $signed(atomic_initial_data_tmp_<%=pidx%>)) ? atomic_txndata: atomic_initial_data);
    end
<% }} %>
      //return(($signed(atomic_txndata) < $signed(atomic_initial_data)) ? atomic_txndata: atomic_initial_data);
  end
  else if(atomic_op == "ATOMICSTORE_UMAX" || atomic_op == "ATOMICLOAD_UMAX") begin
      `uvm_info(get_full_name,$sformatf("perform_atomic_op::atomic_op=%0s atomic_initial_data=0x%0h atomic_txndata=0x%0h num_bytes=%0d addr=0x%0h output=0x%0h",atomic_op,atomic_initial_data,atomic_txndata,num_bytes,addr,((atomic_txndata > atomic_initial_data) ? atomic_txndata: atomic_initial_data)),UVM_MEDIUM)
      return((atomic_txndata > atomic_initial_data) ? atomic_txndata: atomic_initial_data);
  end
  else if(atomic_op == "ATOMICSTORE_UMIN" || atomic_op == "ATOMICLOAD_UMIN") begin
      `uvm_info(get_full_name,$sformatf("perform_atomic_op::atomic_op=%0s atomic_initial_data=0x%0h atomic_txndata=0x%0h num_bytes=%0d addr=0x%0h output=0x%0h",atomic_op,atomic_initial_data,atomic_txndata,num_bytes,addr,((atomic_txndata < atomic_initial_data) ? atomic_txndata: atomic_initial_data)),UVM_MEDIUM)
      return((atomic_txndata < atomic_initial_data) ? atomic_txndata: atomic_initial_data);
  end
endfunction : perform_atomic_op

endclass: chi_subsys_directed_atomic_self_check_seq


