//=====================================================================================================================================
// uvm_sequence <-- io_subsys_base_seq <-- io_subsys_ace_directed_coh_wr_rd_check_seq 
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
class io_subsys_ace_directed_coh_wr_rd_check_seq extends io_subsys_base_seq;
  `svt_xvm_object_utils(io_subsys_ace_directed_coh_wr_rd_check_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
 
  /** Configuration of sequencer attached to this sequence */ 
  svt_axi_port_configuration port_cfg;

  int sequence_length = 1;

  svt_axi_ace_master_generic_sequence seq;
  bit [addr_trans_mgr_pkg::addrMgrConst::W_SEC_ADDR-1:0] all_dmi_dii_start_addr[int][$]; 
  bit [addr_trans_mgr_pkg::addrMgrConst::W_SEC_ADDR-1:0] all_dii_start_addr[int][$]; 
  bit [addr_trans_mgr_pkg::addrMgrConst::W_SEC_ADDR-1:0] all_dmi_start_addr[int][$]; 
  bit all_dmi_nc[int][$]; 
  bit bypass_data_in_data_out_checks=0;
  bit use_single_mem_region_in_test=0;

  int log_base_2_cache_line_size;
  int log_base_2_data_width_in_bytes;
  int width;
  /** Active transaction queue */
  svt_axi_master_transaction active_xacts[$];


  function new(string name = "io_subsys_ace_directed_coh_wr_rd_check_seq");
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
  bit [addrMgrConst::W_SEC_ADDR-1:0] non_coh_addr;
  bit [addrMgrConst::W_SEC_ADDR-1:0] coh_addr;
  bit rand_success;
  svt_axi_master_transaction master_xact;
  svt_axi_transaction::prot_type_enum t_prot_type;
 `SVT_XVM(sequence_item) rsp;
 bit run_stimulus;
      `uvm_info(get_full_name(), $psprintf("Entered body ..."), UVM_LOW)
      seq = svt_axi_ace_master_generic_sequence::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", nativeif, instname, portid));
      `uvm_info(get_full_name(), $psprintf("Starting io_subsys_ace_directed_coh_wr_rd_check_seq sequence_length:%0d", seq.sequence_length), UVM_LOW)
      //seq.start(p_sequencer);
       for(int crit_dw=0;crit_dw<8;crit_dw=crit_dw+1) begin : looping_for_each_critical_DW
           for(int len = 0; len < 4; len++) begin : looping_for_each_len
             if((len+1) inside {[1:((port_cfg.cache_line_size * 8) / (port_cfg.data_width))]}) begin
                 run_stimulus = 1; 
             end else begin
                 run_stimulus = 0; 
             end

             if(run_stimulus==1) begin : run_stimulus_
               for(int all_dmi=0;all_dmi<(use_single_mem_region_in_test ? 1 :all_dmi_start_addr.size());all_dmi=all_dmi+1) begin : looping_for_each_dmi
                   if($test$plusargs("k_directed_test_wr_rd_to_all_dmi")) begin : k_directed_test_wr_rd_to_all_dmi
                       for(int all_dmi_in_ig=0;all_dmi_in_ig<(use_single_mem_region_in_test ? 1 :all_dmi_start_addr[all_dmi].size());all_dmi_in_ig=all_dmi_in_ig+1) begin : looping_for_each_dmi_in_ig
                           if(all_dmi_nc[all_dmi][all_dmi_in_ig]==0) begin : coh_regions
                               for(int i = 0; i < sequence_length; i++) begin : looping_for_sequence_length
                                   coh_addr = all_dmi_start_addr[all_dmi][all_dmi_in_ig] + (i*64);
                                   coh_addr[5:3] = crit_dw;

                                   //64B or less, should not cross 64B boundary CONC-15999, CONC-15559
                                   if((coh_addr[addr_trans_mgr_pkg::addrMgrConst::SYS_wSysCacheline-1:0] + ((len+1) * 2** log_base_2_data_width_in_bytes))<=64) begin
                                       run_stimulus = 1; 
                                   end else begin
                                       run_stimulus = 0; 
                                   end

                                 if(run_stimulus==1) begin : _run_stimulus_
                                   /********** WRITE ***********/
                                   `svt_xvm_create(master_xact);
                                   master_xact.port_cfg = port_cfg;
                                   master_xact.port_id = port_cfg.port_id;
                                   master_xact.reasonable_readonce_writeunique_burst_length.constraint_mode(0);
                                   rand_success = master_xact.randomize() with
                                   {
                                       coherent_xact_type == svt_axi_transaction::WRITEUNIQUE;
                                       xact_type == svt_axi_transaction::COHERENT;
                                       addr == local::coh_addr;
                                       burst_length == (local::len+1);
                                       burst_type == svt_axi_transaction::INCR;
                                       burst_size == local::log_base_2_data_width_in_bytes;
                                       foreach (wstrb[index]) {
                                           wstrb[index] == ((1 << (1 << burst_size)) - 1);
                                       }
                                       //prot_type inside {svt_axi_transaction::DATA_SECURE_NORMAL,svt_axi_transaction::DATA_SECURE_PRIVILEGED,svt_axi_transaction::INSTRUCTION_SECURE_NORMAL,svt_axi_transaction::INSTRUCTION_SECURE_PRIVILEGED};
                                       prot_type inside {svt_axi_transaction::DATA_SECURE_NORMAL,svt_axi_transaction::DATA_SECURE_PRIVILEGED};
                                   };
                                   if(!rand_success) 
                                       `uvm_error(get_full_name,"Randomization failure!!");
                                   `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Coherent Addr=0x%x Sending master_xact", portid,all_dmi,all_dmi_in_ig,coh_addr), UVM_MEDIUM)
                                   `svt_xvm_send(master_xact);
                                   foreach(master_xact.data[index]) begin
                                       for(int data_bit=0; data_bit<port_cfg.data_width;data_bit=data_bit+1) begin
                                           data_out[index*port_cfg.data_width + data_bit] = master_xact.data[index][data_bit];
                                       end
                                   end
                                   fork
                                   begin
                                       master_xact.wait_for_transaction_end();
                                       `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Coherent Addr=0x%x END of master_xact.wait_for_transaction_end", portid,all_dmi,all_dmi_in_ig,coh_addr), UVM_LOW)
                                   end
                                   begin
                                       master_xact.wait_for_addr_phase_ended();
                                       `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Coherent Addr=0x%x END of master_xact.wait_for_addr_phase_ended", portid,all_dmi,all_dmi_in_ig,coh_addr), UVM_LOW)
                                   end
                                   begin
                                       master_xact.wait_for_data_phase_ended();
                                       `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Coherent Addr=0x%x END of master_xact.wait_for_data_phase_ended", portid,all_dmi,all_dmi_in_ig,coh_addr), UVM_LOW)
                                   end
                                   begin
                                       master_xact.wait_for_write_resp_phase_ended();
                                       `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Coherent Addr=0x%x END of master_xact.wait_for_write_resp_phase_ended", portid,all_dmi,all_dmi_in_ig,coh_addr), UVM_LOW)
                                   end
                                   join
                                   t_prot_type = master_xact.prot_type;
                                   //active_xacts.push_back(master_xact);
                                   //wait_for_active_xacts_to_end();
                                   get_response(rsp);
                                   `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Coherent Addr=0x%x, data_out = 0x%x, width=%0d len=%0d Critical DW=%0d", portid,all_dmi,all_dmi_in_ig,coh_addr, data_out, width,len,crit_dw), UVM_LOW)

                                   /********** READ  ***********/
                                   `svt_xvm_create(master_xact);
                                   master_xact.port_cfg = port_cfg;
                                   master_xact.port_id = port_cfg.port_id;
                                   master_xact.reasonable_readonce_writeunique_burst_length.constraint_mode(0);
                                   rand_success = master_xact.randomize() with
                                   {
                                       coherent_xact_type == svt_axi_transaction::READONCE;
                                       xact_type == svt_axi_transaction::COHERENT;
                                       addr == local::coh_addr;
                                       burst_length == (local::len+1);
                                       burst_type == svt_axi_transaction::INCR;
                                       burst_size == local::log_base_2_data_width_in_bytes;
                                       prot_type == local::t_prot_type;
                                   };
                                   if(!rand_success) 
                                       `uvm_error(get_full_name,"Randomization failure!!");
                                   `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] AXI Read Coherent Addr=0x%x Sending master_xact", portid,all_dmi,all_dmi_in_ig,coh_addr), UVM_MEDIUM)
                                   `svt_xvm_send(master_xact);
                                   //master_xact.wait_for_transaction_end();
                                   //active_xacts.push_back(master_xact);
                                   //wait_for_active_xacts_to_end();
                                   fork
                                   begin
                                       master_xact.wait_for_transaction_end();
                                       `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] AXI Read Coherent Addr=0x%x END of master_xact.wait_for_transaction_end", portid,all_dmi,all_dmi_in_ig,coh_addr), UVM_LOW)
                                   end
                                   begin
                                       master_xact.wait_for_addr_phase_ended();
                                       `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] AXI Read Coherent Addr=0x%x END of master_xact.wait_for_addr_phase_ended", portid,all_dmi,all_dmi_in_ig,coh_addr), UVM_LOW)
                                   end
                                   begin
                                       master_xact.wait_for_data_phase_ended();
                                       `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] AXI Read Coherent Addr=0x%x END of master_xact.wait_for_data_phase_ended", portid,all_dmi,all_dmi_in_ig,coh_addr), UVM_LOW)
                                   end
                                   join
                                   foreach(master_xact.data[index]) begin
                                       for(int data_bit=0; data_bit<port_cfg.data_width;data_bit=data_bit+1) begin
                                           data_in[index*port_cfg.data_width + data_bit] = master_xact.data[index][data_bit];
                                       end
                                   end
                                   get_response(rsp);

                                   `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] AXI Read Coherent Addr=0x%x, data_in= 0x%x, width=%0d len=%0d Critical DW=%0d", portid,all_dmi,all_dmi_in_ig,coh_addr, data_in, width,len,crit_dw), UVM_LOW)

                                   if (data_out != data_in) begin
                                     if(!bypass_data_in_data_out_checks) 
                                         `uvm_error(get_full_name, $sformatf("IOAIU-%0d DMI [%0d][IG-%0d] Data Mismatch. Address = 0x%x,len = %d , Read Data = %x, Write Data = %x, Critical DW=%0d",portid,all_dmi,all_dmi_in_ig, coh_addr, len, data_in,data_out,crit_dw)) 
                                     else
                                         `uvm_info(get_full_name, $sformatf("IOAIU-%0d DMI [%0d][IG-%0d] Data Mismatch. Address = 0x%x,len = %d , Read Data = %x, Write Data = %x, Critical DW=%0d",portid,all_dmi,all_dmi_in_ig, coh_addr, len, data_in,data_out,crit_dw), UVM_LOW) 
                                   end
                                   else
                                     `uvm_info(get_full_name, $sformatf("IOAIU-%0d DMI [%0d][IG-%0d] Data Write-Read Test Match. Address = 0x%x,len = %d , Read Data = %x, Write Data = %x, Critical DW=%0d",portid,all_dmi,all_dmi_in_ig, coh_addr, len, data_in,data_out,crit_dw), UVM_LOW) 
                                 end : _run_stimulus_
                               end : looping_for_sequence_length
                           end : coh_regions
                       end : looping_for_each_dmi_in_ig
                   end : k_directed_test_wr_rd_to_all_dmi
               end : looping_for_each_dmi
             end : run_stimulus_
           end : looping_for_each_len
       end : looping_for_each_critical_DW
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

endclass:io_subsys_ace_directed_coh_wr_rd_check_seq
