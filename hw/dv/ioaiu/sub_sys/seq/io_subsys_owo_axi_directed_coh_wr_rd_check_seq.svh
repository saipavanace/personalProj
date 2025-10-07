//=====================================================================================================================================
// uvm_sequence <-- io_subsys_base_seq <-- io_subsys_owo_axi_directed_coh_wr_rd_check_seq 
// svt_sequence <-- svt_axi_master_base_sequence <-- svt_axi_master_random_sequence
/* 
 *  This sequence generates random master transactions.
 */
//====================================================================================================================================

class io_subsys_owo_axi_directed_coh_wr_rd_check_seq extends io_subsys_base_seq;
  `svt_xvm_object_utils(io_subsys_owo_axi_directed_coh_wr_rd_check_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  
  svt_axi_master_random_sequence seq;
  
  /** Configuration of sequencer attached to this sequence */ 
  svt_axi_port_configuration port_cfg;

  int sequence_length = 1;

  svt_axi_ace_master_generic_sequence seq;
  bit [ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:0] all_dmi_dii_start_addr[int][$]; 
  bit [ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:0] all_dii_start_addr[int][$]; 
  bit [ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:0] all_dmi_start_addr[int][$]; 
  bit all_dmi_nc[int][$]; 
  bit bypass_data_in_data_out_checks=0;
  bit use_single_mem_region_in_test=0;

  int log_base_2_cache_line_size;
  int log_base_2_data_width_in_bytes;
  int width;

  function new(string name = "io_subsys_owo_axi_directed_coh_wr_rd_check_seq");
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
                  temp_addr[ncore_config_pkg::ncoreConfigInfo::W_SEC_ADDR-1:44] = csrq[ig].upp_addr;
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
  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] non_coh_addr;
  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] coh_addr;
      `uvm_info(get_full_name(), $psprintf("Entered body ..."), UVM_LOW)
      seq = svt_axi_master_random_sequence::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", nativeif, instname, portid));
      `uvm_info(get_full_name(), $psprintf("Starting svt_axi_master_random_sequence sequence_length:%0d", seq.sequence_length), UVM_LOW)
      //seq.start(p_sequencer);
       for(int crit_dw=0;crit_dw<8;crit_dw=crit_dw+1) begin : looping_for_each_critical_DW
           for(int len = 0; len < 4; len++) begin : looping_for_each_len
               for(int all_dmi=0;all_dmi<(use_single_mem_region_in_test ? 1 :all_dmi_start_addr.size());all_dmi=all_dmi+1) begin : looping_for_each_dmi
                   if($test$plusargs("k_directed_test_wr_rd_to_all_dmi")) begin : k_directed_test_wr_rd_to_all_dmi
                       for(int all_dmi_in_ig=0;all_dmi_in_ig<(use_single_mem_region_in_test ? 1 :all_dmi_start_addr[all_dmi].size());all_dmi_in_ig=all_dmi_in_ig+1) begin : looping_for_each_dmi_in_ig
                           if(all_dmi_nc[all_dmi][all_dmi_in_ig]==0) begin : coh_regions
                               for(int i = 0; i < sequence_length; i++) begin : looping_for_sequence_length
                                   assert(std::randomize(data_out));
                                   coh_addr = all_dmi_start_addr[all_dmi][all_dmi_in_ig] + (i*64);
                                   coh_addr[5:3] = crit_dw;
                                   `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Coherent Addr=0x%x, data_out = 0x%x, width=%0d len=%0d Critical DW=%0d", portid,all_dmi,all_dmi_in_ig,coh_addr, data_out, width,len,crit_dw), UVM_LOW)
                                   //write_ioaiu(non_coh_addr, len, size, data_out[1023:0], 0);
                                   //read_ioaiu(non_coh_addr, len, size, data_in[1023:0]);
                                   `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] AXI Read Coherent Addr=0x%x, data_in= 0x%x, width=%0d len=%0d Critical DW=%0d", portid,all_dmi,all_dmi_in_ig,coh_addr, data_in, width,len,crit_dw), UVM_LOW)
                               end : looping_for_sequence_length
                           end : coh_regions
                       end : looping_for_each_dmi_in_ig
                   end : k_directed_test_wr_rd_to_all_dmi
               end : looping_for_each_dmi
           end : looping_for_each_len
       end : looping_for_each_critical_DW
      `uvm_info(get_full_name(), $psprintf("Exited body ..."), UVM_LOW)
  endtask:body

endclass:io_subsys_owo_axi_directed_coh_wr_rd_check_seq
