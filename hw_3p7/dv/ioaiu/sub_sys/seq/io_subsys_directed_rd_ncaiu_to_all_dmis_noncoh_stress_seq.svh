//=====================================================================================================================================
// uvm_sequence <-- io_subsys_base_seq <-- io_subsys_directed_rd_ncaiu_to_all_dmis_noncoh_stress_seq 
// svt_sequence <-- svt_axi_master_base_sequence <-- svt_axi_master_random_sequence
/* 
 *  This sequence generates random master transactions.
 */
//====================================================================================================================================

class io_subsys_directed_rd_ncaiu_to_all_dmis_noncoh_stress_seq extends io_subsys_base_seq;
  `svt_xvm_object_utils(io_subsys_directed_rd_ncaiu_to_all_dmis_noncoh_stress_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  
  /** Configuration of sequencer attached to this sequence */ 
  svt_axi_port_configuration port_cfg;

  int ioaiu_num_trans = 1;

  bit [addr_trans_mgr_pkg::addrMgrConst::W_SEC_ADDR-1:0] all_dmi_dii_start_addr[int][$]; 
  bit [addr_trans_mgr_pkg::addrMgrConst::W_SEC_ADDR-1:0] all_dii_start_addr[int][$]; 
  bit [addr_trans_mgr_pkg::addrMgrConst::W_SEC_ADDR-1:0] all_dmi_start_addr[int][$]; 
  bit all_dmi_nc[int][$]; 

  int log_base_2_cache_line_size;
  int log_base_2_data_width_in_bytes;
  int width;
  svt_axi_master_transaction active_xacts[$];

  function new(string name = "io_subsys_directed_rd_ncaiu_to_all_dmis_noncoh_stress_seq");
      super.new(name);
  endfunction: new

  virtual task pre_body();
      bit [addr_trans_mgr_pkg::addrMgrConst::W_SEC_ADDR-1:0] temp_addr;
      // preliminary create a queue of start addr by DII or DMI using in the task
      int ig;
      addr_trans_mgr_pkg::addrMgrConst::sys_addr_csr_t csrq[$];

      svt_configuration base_cfg;
      `SVT_XVM(object) base_obj;
      svt_axi_ace_master_base_virtual_sequence my_parent;
      bit status, status_end_addr;

      super.pre_body();

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
  bit [addrMgrConst::W_SEC_ADDR-1:0] addr;
  bit rand_success;
  svt_axi_master_transaction master_xact;
  bit [1:0]bank_sel;
 `SVT_XVM(sequence_item) rsp;
      `uvm_info(get_full_name(), $psprintf("Entered body ..."), UVM_LOW)
      for(int i = 0; i < ioaiu_num_trans; i++) begin : looping_for_ioaiu_num_trans 
          for(int all_dmi=0;all_dmi<all_dmi_start_addr.size();all_dmi=all_dmi+1) begin : looping_for_each_dmi
              for(int all_dmi_in_ig=0;all_dmi_in_ig<all_dmi_start_addr[all_dmi].size();all_dmi_in_ig=all_dmi_in_ig+1) begin : looping_for_each_dmi_in_ig
                   addr = all_dmi_start_addr[all_dmi][all_dmi_in_ig] + (i*64);
                   for(int x=0; x<addr_trans_mgr_pkg::addrMgrConst::ioaiu_ccp_DataBankSelBits[portid].size;x=x+1) begin
                   automatic int y = addr_trans_mgr_pkg::addrMgrConst::ioaiu_ccp_DataBankSelBits[portid][x];
                       addr[addr_trans_mgr_pkg::addrMgrConst::ioaiu_ccp_PriSubDiagAddrBits[portid][y]] = bank_sel[x];
                   end

                   /********** READ  ***********/
                   `svt_xvm_create(master_xact);
                   master_xact.port_cfg = port_cfg;
                   master_xact.port_id = port_cfg.port_id;
                   master_xact.reasonable_readonce_writeunique_burst_length.constraint_mode(0);
                   rand_success = master_xact.randomize() with
                   {
                       //coherent_xact_type == svt_axi_transaction::READNOSNOOP;
                       xact_type == svt_axi_transaction::READ;
                       addr == local::addr;
                       burst_length == (64/local::width);
                       burst_type == svt_axi_transaction::INCR;
                       cache_type == 4'b1111;
                       burst_size == local::log_base_2_data_width_in_bytes;
                   };
                   if(!rand_success) 
                       `uvm_error(get_full_name,"Randomization failure!!");
                   `uvm_info(get_full_name(),$psprintf("Generated transaction 'd%0d: %0s", i, `SVT_AXI_PRINT_PREFIX1(master_xact)),UVM_LOW);
                   `svt_xvm_send(master_xact);
                   active_xacts.push_back(master_xact);
                   //master_xact.wait_for_transaction_end();
                   foreach(master_xact.data[index]) begin
                       for(int data_bit=0; data_bit<port_cfg.data_width;data_bit=data_bit+1) begin
                           data_in[index*port_cfg.data_width + data_bit] = master_xact.data[index][data_bit];
                       end
                   end
                   //get_response(rsp);
                   bank_sel = bank_sel + 1;
                   `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] AXI Read Non-Coherent Addr=0x%x, data_in= 0x%x, width=%0d", portid,all_dmi,all_dmi_in_ig,addr, data_in, width), UVM_LOW)
              end : looping_for_each_dmi_in_ig
          end : looping_for_each_dmi
      end : looping_for_ioaiu_num_trans 

      `uvm_info(get_full_name(),"Waiting for all transactions to complete",UVM_LOW);
      wait_for_active_xacts_to_end(); 
      `uvm_info(get_full_name(),"All transactions are now complete",UVM_LOW);
      `uvm_info(get_full_name(), $psprintf("Exited body ..."), UVM_LOW)
  endtask:body

  /** Waits until all transactions in active_xacts queue have ended */
  task wait_for_active_xacts_to_end();
    int indx_q[$];
    int indx_q_size, inactive_xacts_cnt;
    foreach (active_xacts[i]) begin
        if(active_xacts[i].is_transaction_ended() == 0)
            indx_q.push_back(i);
        else
            `uvm_info("wait_for_active_xacts_to_end",{`SVT_AXI_PRINT_PREFIX1(active_xacts[i]),"Transaction has now ended"},UVM_MEDIUM) ;
    end
    indx_q_size = indx_q.size();
    fork begin
      foreach (indx_q[ix]) begin
        active_xacts[indx_q[ix]].wait_for_transaction_end();
        inactive_xacts_cnt = inactive_xacts_cnt+1;
        `uvm_info("wait_for_active_xacts_to_end",$sformatf(" is_cached Transaction has now ended %s ('d%0d / 'd%0d)", `SVT_AXI_PRINT_PREFIX1(active_xacts[indx_q[ix]]), ix, indx_q.size()),UVM_MEDIUM);
      end
    end
    join_none
    wait(inactive_xacts_cnt == indx_q_size);
  endtask

endclass:io_subsys_directed_rd_ncaiu_to_all_dmis_noncoh_stress_seq
