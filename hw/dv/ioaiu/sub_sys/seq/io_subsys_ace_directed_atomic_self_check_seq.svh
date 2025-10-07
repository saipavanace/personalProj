//=====================================================================================================================================
// uvm_sequence <-- io_subsys_base_seq <-- io_subsys_ace_directed_atomic_self_check_seq 
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
class io_subsys_ace_directed_atomic_self_check_seq extends io_subsys_base_seq;
  `svt_xvm_object_utils(io_subsys_ace_directed_atomic_self_check_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
 
  /** Configuration of sequencer attached to this sequence */ 
  svt_axi_port_configuration port_cfg;

  int sequence_length = 1;

  svt_axi_ace_master_generic_sequence seq;
  bit bypass_data_in_data_out_checks=0;
  bit use_single_mem_region_in_test=0;

  int log_base_2_cache_line_size;
  int log_base_2_data_width_in_bytes;
  int width;
  svt_axi_master_transaction active_xacts[$];

  function new(string name = "io_subsys_ace_directed_atomic_self_check_seq");
      super.new(name);
  endfunction: new

  virtual task pre_body();
      bit [ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:0] temp_addr;
      // preliminary create a queue of start addr by DII or DMI using in the task
      int ig;
      ncore_config_pkg::ncoreConfigInfo::sys_addr_csr_t csrq[$];

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
                     all_dmi_start_addr[csrq[ig].mig_nunitid].push_back(temp_addr);
                     all_dmi_nc[csrq[ig].mig_nunitid].push_back(csrq[ig].nc);
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
  bit [1023:0] data_in, data_in_1;
  bit [1023:0] data_out, data_out_1;
  int data_size;
  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] non_coh_addr;
  bit rand_success;
  io_subsys_axi_master_transaction master_xact;
  bit [3:0]aXcache;
  svt_axi_transaction::prot_type_enum t_prot_type;
 `SVT_XVM(sequence_item) rsp;
      `uvm_info(get_full_name(), $psprintf("Entered body ..."), UVM_LOW)

      `uvm_info(get_full_name(), $psprintf("Exited body ..."), UVM_LOW)
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

endclass:io_subsys_ace_directed_atomic_self_check_seq
