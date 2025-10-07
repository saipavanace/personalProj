//=====================================================================================================================================
// uvm_sequence <-- io_subsys_base_seq <-- io_subsys_axi_directed_atomic_self_check_seq 
// svt_sequence <-- svt_axi_master_base_sequence <-- svt_axi_master_random_sequence
/* 
 *  This sequence generates random master transactions.
 */
//====================================================================================================================================

class io_subsys_axi_directed_atomic_self_check_seq extends io_subsys_base_seq;
  `svt_xvm_object_utils(io_subsys_axi_directed_atomic_self_check_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  
  /** Configuration of sequencer attached to this sequence */ 
  svt_axi_port_configuration port_cfg;

  int sequence_length = 1;

  bit bypass_data_in_data_out_checks=0;
  bit use_single_mem_region_in_test=0;

  int log_base_2_cache_line_size;
  int log_base_2_data_width_in_bytes;
  int width;
  svt_axi_master_transaction active_xacts[$];

  function new(string name = "io_subsys_axi_directed_atomic_self_check_seq");
      super.new(name);
  endfunction: new

  function bit check_addr_falls_in_dmi_add_range_with_no_atomic_engine([ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:0] addr);
        <%for(let i=0; i< obj.nDMIs; i++){%>
            <%if(obj.DmiInfo[i].useAtomic == 0){%>
                foreach(ncoreConfigInfo::memregions_info[j]) begin
                    foreach(ncoreConfigInfo::memregions_info[j].UnitIds[k]) begin
                        if((addr >= ncoreConfigInfo::memregions_info[j].start_addr) && (addr <= ncoreConfigInfo::memregions_info[j].end_addr && (ncoreConfigInfo::memregions_info[j].hut == ncoreConfigInfo::DMI)) && (ncoreConfigInfo::memregions_info[j].UnitIds[k] == <%=i%>)) begin
                            return 0;
                        end
                    end
                end
            <%}%>
        <%}%>
        return 1;
  endfunction:check_addr_falls_in_dmi_add_range_with_no_atomic_engine

  virtual task pre_body();
      bit [ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:0] temp_addr;
      // preliminary create a queue of start addr by DII or DMI using in the task
      int ig;
      ncore_config_pkg::ncoreConfigInfo::sys_addr_csr_t csrq[$];
      bit push_dmi_addr_with_atomic_engine;

      svt_configuration base_cfg;
      `SVT_XVM(object) base_obj;
      svt_axi_ace_master_base_virtual_sequence my_parent;
      bit status, status_end_addr;

      super.pre_body();

      csrq = ncore_config_pkg::ncoreConfigInfo::get_all_gpra();
      foreach (csrq[ig]) begin:_foreach_csrq_ig
      int temp;
                  temp_addr[ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:44] = csrq[ig].upp_addr;
                  temp_addr[43:12] = csrq[ig].low_addr;
                  all_dmi_dii_start_addr[csrq[ig].mig_nunitid].push_back(temp_addr);
                  if(csrq[ig].unit.name=="DII") begin
                     all_dii_start_addr[csrq[ig].mig_nunitid].push_back(temp_addr);
                     if(all_dii_sub_region_type_cfg_done==0) begin : all_dii_sub_region_type_cfg_done_0
                         do begin
                             temp = $urandom_range(2,0);
                             if($countones(dii_region_rsvd)==3)
                                 break;
                             else if(dii_region_rsvd[temp]==0) 
                                 break;
                         end
                         while(1);
                         dii_region_rsvd[temp] = 1;
                         all_dii_sub_region_type[csrq[ig].mig_nunitid].push_back(temp); // DEV=0, NONCACHEABLE=1, CACHEABLE=2
                         `uvm_info(get_full_name(), $psprintf("dii start addr 0x%0h, dii_sub_region_type=%0d  [DEV=0, NONCACHEABLE=1, CACHEABLE=2]",temp_addr,temp), UVM_LOW)
                     end : all_dii_sub_region_type_cfg_done_0
                  end
                  else begin
                     //push_dmi_addr_with_atomic_engine = check_addr_falls_in_dmi_add_range_with_no_atomic_engine(temp_addr);
                     push_dmi_addr_with_atomic_engine = m_addr_mgr.allow_atomic_txn_with_addr(temp_addr);
                     `uvm_info(get_full_name(), $psprintf("dmi start addr 0x%0h, push_dmi_addr_with_atomic_engine=%0d",temp_addr,push_dmi_addr_with_atomic_engine), UVM_LOW)
                     if(push_dmi_addr_with_atomic_engine==1) begin
                         all_dmi_start_addr[csrq[ig].mig_nunitid].push_back(temp_addr);
                         all_dmi_nc[csrq[ig].mig_nunitid].push_back(csrq[ig].nc);
                     end
                  end
      end:_foreach_csrq_ig
      all_dii_sub_region_type_cfg_done = 1;

      if($test$plusargs("bypass_data_in_data_out_checks"))  bypass_data_in_data_out_checks=1;
      if($test$plusargs("use_single_mem_region_in_test"))   use_single_mem_region_in_test=1;

      p_sequencer.get_cfg(base_cfg);
      if (!$cast(port_cfg, base_cfg)) begin
        `uvm_fatal("pre_body", "Unable to $cast the configuration to a svt_axi_port_configuration class");
      end
      log_base_2_cache_line_size = port_cfg.log_base_2(port_cfg.cache_line_size);
      log_base_2_data_width_in_bytes = port_cfg.log_base_2(port_cfg.data_width/8);
      width = port_cfg.data_width/8;

  endtask:pre_body;

  virtual task body();
    svt_axi_master_transaction atomic_tran,master_xact;
    bit [3:0]aXcache;
    `SVT_XVM(sequence_item) rsp;
    svt_axi_transaction::prot_type_enum t_prot_type;
    bit rand_success;
    bit [511:0] data_in, data_in_1;
    bit [511:0] data_out, data_out_1, exp_data;
    bit [ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:0] addr;
    bit [ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:0] coh_addr;
    bit [ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:0] non_coh_addr;
    int data_size;
    bit en_atomic_op[string];
    bit atomicStore, atomicLoad, atomicSwap, atomicCompare;
    svt_axi_transaction::atomic_xact_op_type_enum atomic_op_type;
    svt_axi_transaction::burst_type_enum t_burst_type;
    bit [63:0] atomic_compare_data, atomic_swap_data, atomic_txndata;
    bit [255:0] atomic_initial_data;
    bit run_stimulus = 1;
    `uvm_info(get_full_name(), $psprintf("io_subsys_axi_directed_atomic_self_check_seq - Entered body ..."), UVM_LOW)

    if($value$plusargs("AtomicStore_ADD=%0b",en_atomic_op["AtomicStore_ADD"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicStore_ADD"), UVM_LOW)
        atomic_op_type = svt_axi_transaction::ATOMICSTORE_ADD  ;
    end
    else if($value$plusargs("AtomicStore_CLR=%0b",en_atomic_op["AtomicStore_CLR"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicStore_CLR"), UVM_LOW)
        atomic_op_type = svt_axi_transaction::ATOMICSTORE_CLR  ;
    end
    else if($value$plusargs("AtomicStore_OR=%0b",en_atomic_op["AtomicStore_OR"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicStore_OR"), UVM_LOW)
        atomic_op_type = svt_axi_transaction::ATOMICSTORE_EOR  ;
    end
    else if($value$plusargs("AtomicStore_SET=%0b",en_atomic_op["AtomicStore_SET"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicStore_SET"), UVM_LOW)
        atomic_op_type = svt_axi_transaction::ATOMICSTORE_SET  ;
    end
    else if($value$plusargs("AtomicStore_MAX=%0b",en_atomic_op["AtomicStore_MAX"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicStore_MAX"), UVM_LOW)
        atomic_op_type = svt_axi_transaction::ATOMICSTORE_SMAX ;
    end
    else if($value$plusargs("AtomicStore_MIN=%0b",en_atomic_op["AtomicStore_MIN"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicStore_MIN"), UVM_LOW)
        atomic_op_type = svt_axi_transaction::ATOMICSTORE_SMIN ;
    end
    else if($value$plusargs("AtomicStore_UMAX=%0b",en_atomic_op["AtomicStore_UMAX"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicStore_UMAX"), UVM_LOW)
        atomic_op_type = svt_axi_transaction::ATOMICSTORE_UMAX ;
    end
    else if($value$plusargs("AtomicStore_UMIN=%0b",en_atomic_op["AtomicStore_UMIN"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicStore_UMIN"), UVM_LOW)
        atomic_op_type = svt_axi_transaction::ATOMICSTORE_UMIN ;
    end
    else if($value$plusargs("AtomicLoad_ADD=%0b",en_atomic_op["AtomicLoad_ADD"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicLoad_ADD"), UVM_LOW)
        atomic_op_type = svt_axi_transaction::ATOMICLOAD_ADD   ;
    end
    else if($value$plusargs("AtomicLoad_CLR=%0b",en_atomic_op["AtomicLoad_CLR"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicLoad_CLR"), UVM_LOW)
        atomic_op_type = svt_axi_transaction::ATOMICLOAD_CLR   ;
    end
    else if($value$plusargs("AtomicLoad_OR=%0b",en_atomic_op["AtomicLoad_OR"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicLoad_OR"), UVM_LOW)
        atomic_op_type = svt_axi_transaction::ATOMICLOAD_EOR   ;
    end
    else if($value$plusargs("AtomicLoad_SET=%0b",en_atomic_op["AtomicLoad_SET"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicLoad_SET"), UVM_LOW)
        atomic_op_type = svt_axi_transaction::ATOMICLOAD_SET   ;
    end
    else if($value$plusargs("AtomicLoad_MAX=%0b",en_atomic_op["AtomicLoad_MAX"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicLoad_MAX"), UVM_LOW)
        atomic_op_type = svt_axi_transaction::ATOMICLOAD_SMAX  ;
    end
    else if($value$plusargs("AtomicLoad_MIN=%0b",en_atomic_op["AtomicLoad_MIN"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicLoad_MIN"), UVM_LOW)
        atomic_op_type = svt_axi_transaction::ATOMICLOAD_SMIN  ;
    end
    else if($value$plusargs("AtomicLoad_UMAX=%0b",en_atomic_op["AtomicLoad_UMAX"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicLoad_UMAX"), UVM_LOW)
        atomic_op_type = svt_axi_transaction::ATOMICLOAD_UMAX  ;
    end
    else if($value$plusargs("AtomicLoad_UMIN=%0b",en_atomic_op["AtomicLoad_UMIN"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicLoad_UMIN"), UVM_LOW)
        atomic_op_type = svt_axi_transaction::ATOMICLOAD_UMIN  ;
    end
    else if($value$plusargs("AtomicSwap=%0b",en_atomic_op["AtomicSwap"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicSwap"), UVM_LOW)
        atomic_op_type = svt_axi_transaction::ATOMICSWAP       ;
    end
    else if($value$plusargs("AtomicCompare=%0b",en_atomic_op["AtomicCompare"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run AtomicCompare"), UVM_LOW)
        atomic_op_type = svt_axi_transaction::ATOMICCOMPARE    ;
    end
    else if($value$plusargs("WrapAtomicCompare=%0b",en_atomic_op["WrapAtomicCompare"])) begin
        `uvm_info(get_full_name, $psprintf("Plusarg is set to run WrapAtomicCompare"), UVM_LOW)
        atomic_op_type = svt_axi_transaction::ATOMICCOMPARE    ;
    end else begin // by default
        en_atomic_op["AtomicStore_ADD"]=1;
        atomic_op_type = svt_axi_transaction::ATOMICSTORE_ADD  ;
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
    else if(en_atomic_op["WrapAtomicCompare"]) begin
        atomicCompare = 1;
    end
    else if(en_atomic_op["AtomicCompare"]) begin
        atomicCompare = 1;
    end
    `uvm_info(get_full_name(), $sformatf("IOAIU-%0d Starting test for Atomic OP=%0s ", portid,atomic_op_type.name()), UVM_LOW)

    for(int crit_dw=0;crit_dw<8;crit_dw=crit_dw+1) begin : looping_for_each_critical_DW
      for (int j = ((atomicCompare==1)?1:0); j < ((atomicCompare==1)?6:4); j++) begin : looping_for_each_req_size
        for(int all_dmi=0;all_dmi<(use_single_mem_region_in_test ? 1 :all_dmi_start_addr.size());all_dmi=all_dmi+1) begin : looping_for_each_dmi
          if($test$plusargs("k_directed_test_wr_rd_to_all_dmi")) begin : if_plusarg_en_k_directed_test_wr_rd_to_all_dmi
            for(int all_dmi_in_ig=0;all_dmi_in_ig<(use_single_mem_region_in_test ? 1 :all_dmi_start_addr[all_dmi].size());all_dmi_in_ig=all_dmi_in_ig+1) begin : looping_for_each_dmi_in_ig
                for(int i = 0; i < sequence_length; i++) begin : looping_for_sequence_length
                io_subsys_axi_master_transaction write_xact, atomic_xact, read_xact;
                int axi_len,axi_size,temp;
                int atm_axi_len,atm_axi_size,temp;
                
                    data_size = j;  // For atomicCompare 2,4,8,16,32 bytes. For others 1,2,4,8,16
                    non_coh_addr = all_dmi_start_addr[all_dmi][all_dmi_in_ig] + (i*64);
                    non_coh_addr[5:3] = crit_dw;
                    if (en_atomic_op["WrapAtomicCompare"]) begin
                        if(data_size==1) 
                            non_coh_addr[0] = 1'b1;
                        else if(data_size==2) 
                            non_coh_addr[1] = 1'b1;
                        else if(data_size==3) 
                            non_coh_addr[2] = 1'b1;
                        else if(data_size==4) 
                            non_coh_addr[3] = 1'b1;
                        else if(data_size==5) 
                            non_coh_addr[4] = 1'b1;
                    end

                    if (en_atomic_op["AtomicCompare"] && ($test$plusargs("AtomicCompare_case1") || $test$plusargs("AtomicCompare_case2"))) begin
                        if(/*((j== 3'b010) && (non_coh_addr[0] == 1'b0))*/
                        /*||*/ ((j== 3'b010)  && (non_coh_addr[1:0] == 2'b0))
                        || ((j== 3'b011)  && (non_coh_addr[2:0] == 3'b0))
                        || ((j== 3'b100)  && (non_coh_addr[3:0] == 4'b0))) begin
                            run_stimulus = 1;
                        end else begin
                            run_stimulus = 0;  // Invalid cases for atomic compare with wrap burst
                        end
                    end
                    else if (en_atomic_op["WrapAtomicCompare"] && ($test$plusargs("AtomicCompare_case1") || $test$plusargs("AtomicCompare_case2"))) begin
                        if(/*((j== 3'b010) && (non_coh_addr[0] == 1'b0))*/
                        /*||*/ ((j== 3'b010)  && (non_coh_addr[1:0] == 2'b10))
                        || ((j== 3'b011)  && (non_coh_addr[2:0] == 3'b100))
                        || ((j== 3'b100)  && (non_coh_addr[3:0] == 4'b1000))
                        || ((j== 3'b101)  && (non_coh_addr[4:0] == 5'b10000))
                        ) begin
                            run_stimulus = 1;
                        end else begin
                            run_stimulus = 0;  // Invalid cases for atomic compare with incr burst
                        end
                    end
                    else begin
                        run_stimulus = 1;
                    end
                    if(run_stimulus==1) begin : run_stimulus_
                                  `uvm_info(get_full_name(), $sformatf("IOAIU-%0d Atomic OP=%0s Loop variables crit_dw=%0d j=%0d all_dmi=%0d all_dmi_in_ig=%0d i=%0d", portid,atomic_op_type.name(),crit_dw,j,all_dmi,all_dmi_in_ig,i), UVM_LOW)
                                   /********** WRITE ***********/
                                   `svt_xvm_create(write_xact);
                                   write_xact.port_cfg = port_cfg;
                                   write_xact.port_id = port_cfg.port_id;
                                   write_xact.reasonable_readonce_writeunique_burst_length.constraint_mode(0);
                                   if(atomicCompare==1) begin
                                       temp = (2**data_size)/2;
                                   end else begin
                                       temp = (2**data_size);
                                   end
                                   axi_size = (port_cfg.log_base_2(temp)>log_base_2_data_width_in_bytes)
                                              ? log_base_2_data_width_in_bytes
                                              :  port_cfg.log_base_2(temp);
                                   //axi_len = temp/(port_cfg.data_width/8);
                                   if(atomicCompare==1) begin
                                   axi_len = temp/(2**axi_size);
                                   end else begin
                                   axi_len = (((2**axi_size)%(port_cfg.data_width/8))==0)
                                             ?((2**axi_size)/(port_cfg.data_width/8))
                                             :(((2**axi_size)/(port_cfg.data_width/8)) + 1) ;
                                   end
                                                                           ;
                                   rand_success = write_xact.randomize() with
                                   {
                                       xact_type == svt_axi_transaction::WRITE;
                                       addr == local::non_coh_addr;
                                       burst_length == local::axi_len;
                                       burst_type == svt_axi_transaction::INCR;
                                       burst_size == local::axi_size;
                                       foreach (wstrb[index]) {
                                           wstrb[index] == ((1 << (1 << burst_size)) - 1);
                                       }
                                       prot_type inside {svt_axi_transaction::DATA_SECURE_NORMAL,svt_axi_transaction::DATA_SECURE_PRIVILEGED};
                                   };
                                   if(!rand_success) 
                                       `uvm_error(get_full_name,"Randomization failure!!");
                                   `svt_xvm_send(write_xact);
                                   foreach(write_xact.data[index]) begin
                                       for(int data_bit=0; data_bit<port_cfg.data_width;data_bit=data_bit+1) begin
                                           data_out[index*port_cfg.data_width + data_bit] = write_xact.data[index][data_bit];
                                       end
                                   end
                                   write_xact.wait_for_transaction_end();
                                   t_prot_type = write_xact.prot_type;
                                   get_response(rsp);
                                   `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Non-Coherent Addr=0x%x, data_out = 0x%x, width=%0d axi_len=%0d axi_size=%0d Critical DW=%0d", portid,all_dmi,all_dmi_in_ig,non_coh_addr, data_out, width,axi_len,axi_size,crit_dw), UVM_LOW)

                                   /********** Atomic ***********/
                                   `svt_xvm_create(atomic_xact);
                                   atomic_xact.port_cfg = port_cfg;
                                   atomic_xact.port_id = port_cfg.port_id;
                                   atm_axi_size = (port_cfg.log_base_2(2**data_size)>log_base_2_data_width_in_bytes)
                                              ? log_base_2_data_width_in_bytes
                                              :  port_cfg.log_base_2(2**data_size);
                                   //atm_axi_len = (2**data_size)/(port_cfg.data_width/8);
                                   if(atomicCompare==1) begin
                                       atm_axi_len = (2**data_size)/(2**atm_axi_size);
                                   end else begin
                                       atm_axi_len = (((2**atm_axi_size)%(port_cfg.data_width/8))==0)
                                             ?((2**atm_axi_size)/(port_cfg.data_width/8))
                                             :(((2**atm_axi_size)/(port_cfg.data_width/8)) + 1) ;
                                   end

                                   if(en_atomic_op["WrapAtomicCompare"]) begin
                                       t_burst_type = svt_axi_transaction::WRAP;
                                   end else begin
                                       t_burst_type = svt_axi_transaction::INCR;
                                   end

                                   rand_success = atomic_xact.randomize() with
                                   {
                                       atomic_xact_op_type== atomic_op_type;
                                       xact_type == svt_axi_transaction::ATOMIC;
                                       addr == local::non_coh_addr;
                                       burst_length == local::atm_axi_len;
                                       burst_type == local::t_burst_type;

                                       burst_size == local::atm_axi_size;
                                       foreach (wstrb[index]) {
                                           wstrb[index] == ((1 << (1 << burst_size)) - 1);
                                       }
                                       prot_type == local::t_prot_type;
                                   };
                                   if(!rand_success) 
                                       `uvm_error(get_full_name,"Randomization failure!!");
                                   `svt_xvm_send(atomic_xact);
                                   if(atomicCompare==1) begin
                                        foreach(atomic_xact.atomic_compare_data[index]) begin
                                            for(int data_bit=0; data_bit<port_cfg.data_width;data_bit=data_bit+1) begin
                                                atomic_compare_data[index*port_cfg.data_width + data_bit] = atomic_xact.atomic_compare_data[index][data_bit];
                                                atomic_swap_data[index*port_cfg.data_width + data_bit] = atomic_xact.atomic_swap_data[index][data_bit];
                                            end
                                        end
                                   end else begin
                                        foreach(atomic_xact.data[index]) begin
                                            for(int data_bit=0; data_bit<port_cfg.data_width;data_bit=data_bit+1) begin
                                                atomic_txndata[index*port_cfg.data_width + data_bit] = atomic_xact.data[index][data_bit];
                                            end
                                        end
                                   end
                                   atomic_xact.wait_for_transaction_end();
                                   t_prot_type = atomic_xact.prot_type;
                                   get_response(rsp);
                                   foreach(atomic_xact.atomic_read_data[index]) begin
                                       for(int data_bit=0; data_bit<port_cfg.data_width;data_bit=data_bit+1) begin
                                           if(atomicCompare==1 || atomicLoad==1 || atomicSwap==1)
                                               atomic_initial_data[index*port_cfg.data_width + data_bit] = atomic_xact.atomic_read_data[index][data_bit];
                                       end
                                   end
                                   `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] AXI Atomic OP=%0s Addr=0x%x, atomic_txndata=0x%x, atomic_initial_data=0x%x, atomic_compare_data=0x%x, atomic_swap_data=0x%x, width=%0d atm_axi_len=%0d atm_axi_size=%0d Critical DW=%0d", portid,all_dmi,all_dmi_in_ig,atomic_op_type.name(),non_coh_addr, atomic_txndata,atomic_initial_data, atomic_compare_data,atomic_swap_data,width,atm_axi_len,atm_axi_size,crit_dw), UVM_LOW)

                                   /********** READ  ***********/
                                   `svt_xvm_create(read_xact);
                                   read_xact.port_cfg = port_cfg;
                                   read_xact.port_id = port_cfg.port_id;
                                   read_xact.reasonable_readonce_writeunique_burst_length.constraint_mode(0);
                                   rand_success = read_xact.randomize() with
                                   {
                                       xact_type == svt_axi_transaction::READ;
                                       addr == local::non_coh_addr;
                                       burst_length == local::axi_len;
                                       burst_size == local::axi_size;
                                       burst_type == svt_axi_transaction::INCR;
                                       prot_type == local::t_prot_type;
                                   };
                                   if(!rand_success) 
                                       `uvm_error(get_full_name,"Randomization failure!!");
                                   `svt_xvm_send(read_xact);
                                   read_xact.wait_for_transaction_end();
                                   foreach(read_xact.data[index]) begin
                                       for(int data_bit=0; data_bit<port_cfg.data_width;data_bit=data_bit+1) begin
                                           data_in[index*port_cfg.data_width + data_bit] = read_xact.data[index][data_bit];
                                       end
                                   end
                                   wait_for_active_xacts_to_end();
                                   get_response(rsp);
                                   `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] AXI Read Non-Coherent Addr=0x%x, data_in= 0x%x, width=%0d axi_len=%0d axi_size=%0d axi_size=%0d Critical DW=%0d", portid,all_dmi,all_dmi_in_ig,non_coh_addr, data_in, width,axi_len,axi_size,axi_size,crit_dw), UVM_LOW)

                                   if(atomicLoad || atomicSwap || atomicCompare) begin
                                       if (data_out != atomic_initial_data) begin
                                         if(!bypass_data_in_data_out_checks) 
                                             `uvm_error(get_full_name, $sformatf("IOAIU-%0d DMI [%0d][IG-%0d] Data Mismatch. Address = 0x%x,size = %d Bytes, Atomic Initial Data = %x, Write Data = %x, Critical DW=%0d",portid,all_dmi,all_dmi_in_ig, non_coh_addr, 2**data_size, atomic_initial_data,data_out,crit_dw)) 
                                         else
                                             `uvm_info(get_full_name, $sformatf("IOAIU-%0d DMI [%0d][IG-%0d] Data Mismatch. Address = 0x%x,size = %d Bytes, Atomic Initial Data = %x, Write Data = %x, Critical DW=%0d",portid,all_dmi,all_dmi_in_ig, non_coh_addr, 2**data_size, atomic_initial_data,data_out,crit_dw), UVM_LOW) 
                                       end
                                       else
                                         `uvm_info(get_full_name, $sformatf("IOAIU-%0d DMI [%0d][IG-%0d] Data Write-Atomic Test Match. Address = 0x%x,size = %d Bytes, Atomic Initial Data = %x, Write Data = %x, Critical DW=%0d",portid,all_dmi,all_dmi_in_ig, non_coh_addr, 2**data_size, atomic_initial_data,data_out,crit_dw), UVM_LOW) 
                                   end

                                   if(atomicStore || atomicLoad) begin
                                       exp_data = perform_atomic_op(atomic_op_type.name,data_out,atomic_txndata,(2**data_size),non_coh_addr);
                                   end
                                   else if(atomicSwap)
                                       exp_data = atomic_txndata;
                                   else if(atomicCompare) begin
                                       exp_data = (atomic_compare_data==data_in)?atomic_swap_data:data_in;
                                   end

                                   if(atomicLoad || atomicStore) begin : _clear_carry_overflow_
                                       for(int fill_zero=((2**axi_size)*8);fill_zero<512;fill_zero=fill_zero+1)
                                           exp_data[fill_zero] = 1'b0;
                                   end : _clear_carry_overflow_

                                   if (exp_data != data_in) begin
                                     if(!bypass_data_in_data_out_checks) 
                                         `uvm_error(get_full_name, $sformatf("IOAIU-%0d Data Mismatch Address = %x, size = %d Bytes, Exp Data = %x, Act Data = %x", portid,non_coh_addr, 2**data_size,exp_data, data_in))
                                     else
                                     `uvm_info(get_full_name,$sformatf("IOAIU-%0d Data Mismatch Address = %x, size = %d Bytes, Exp Data = %x, Act Data = %x", portid,non_coh_addr, 2**data_size,exp_data, data_in),UVM_NONE)
                                   end
                                   else begin
                                       `uvm_info(get_full_name, $sformatf("IOAIU-%0d Data Transfer Write-Atomic-Read Test Match. DMI Target GPR[%0d] Address = %x, size = %d Bytes, Exp Data = %x, Act Data = %x Critical DW=%0d",portid,all_dmi, non_coh_addr, 2**data_size,exp_data, data_in,crit_dw), UVM_LOW)
                                   end

                    end : run_stimulus_
                end : looping_for_sequence_length
            end : looping_for_each_dmi_in_ig
          end : if_plusarg_en_k_directed_test_wr_rd_to_all_dmi
        end : looping_for_each_dmi
      end : looping_for_each_req_size
    end : looping_for_each_critical_DW


    `uvm_info(get_full_name(), $psprintf("io_subsys_axi_directed_atomic_self_check_seq - Exited body ..."), UVM_LOW)
  endtask:body

  /** Waits until all transactions in active_xacts queue have ended */
  task wait_for_active_xacts_to_end();
    int indx_q[$];
    foreach (active_xacts[i]) begin
      `svt_xvm_debug("wait_for_active_xacts_to_end",{`SVT_AXI_PRINT_PREFIX1(active_xacts[i]),"Waiting for transaction to end"}) ;
      fork
        begin
          fork
          begin
            if (active_xacts[i].transmitted_channel == svt_axi_master_transaction::READ) begin 
              wait((active_xacts[i].addr_status == svt_axi_master_transaction::ABORTED || 
                    active_xacts[i].data_status == svt_axi_master_transaction::ABORTED ||
                    active_xacts[i].ack_status == svt_axi_master_transaction::ABORTED 
                   ) || 
                   (active_xacts[i].ack_status == svt_axi_master_transaction::ACCEPT)  ||  //for ACE Only
                   (
                      (port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE) &&
                      (active_xacts[i].data_status == svt_axi_master_transaction::ACCEPT)
                   )); 
            end
            else if (active_xacts[i].transmitted_channel == svt_axi_master_transaction::WRITE) begin 
              wait((active_xacts[i].addr_status == svt_axi_master_transaction::ABORTED || 
                    active_xacts[i].data_status == svt_axi_master_transaction::ABORTED ||
                    active_xacts[i].write_resp_status == svt_axi_master_transaction::ABORTED ||
                    active_xacts[i].ack_status == svt_axi_master_transaction::ABORTED 
                    ) || 
                   (active_xacts[i].ack_status == svt_axi_master_transaction::ACCEPT)  ||  //for ACE Only
                   (
                      (port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE) &&
                      (active_xacts[i].write_resp_status == svt_axi_master_transaction::ACCEPT)
                   )); 
            end
          end
          begin
            wait ((active_xacts[i].is_cached_data == 1) || (active_xacts[i].is_coherent_xact_dropped == 1));
          end
          join_any
          disable fork;
        end
        join
        if(((active_xacts[i].is_cached_data == 1) && (active_xacts[i].is_coherent_xact_dropped == 0) && active_xacts[i].is_transaction_ended() == 0))
          indx_q.push_back(i);
        else
        `svt_xvm_debug("wait_for_active_xacts_to_end",{`SVT_AXI_PRINT_PREFIX1(active_xacts[i]),"Transaction has now ended"}) ;
    end
    fork begin
      foreach (indx_q[ix]) begin
        active_xacts[indx_q[ix]].wait_for_transaction_end();
        `svt_xvm_debug("wait_for_active_xacts_to_end",$sformatf(" is_cached Transaction has now ended %s ('d%0d / 'd%0d)", `SVT_AXI_PRINT_PREFIX1(active_xacts[indx_q[ix]]), ix, indx_q.size()));
      end
    end
    join_none
  endtask

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

endclass:io_subsys_axi_directed_atomic_self_check_seq
