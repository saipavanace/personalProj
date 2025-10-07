class svt_rd_after_wr_to_dii_seq extends svt_axi_seq;
  `svt_xvm_object_utils(svt_rd_after_wr_to_dii_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  io_subsys_axi_master_transaction full_cacheline_init_txn,wr_txn, rd_txn,full_cacheline_rd_txn;
  
  function new(string name = "svt_rd_after_wr_to_dii_seq");
    super.new(name);
  endfunction: new

  virtual task pre_body();
    super.pre_body();
  endtask:pre_body;

  virtual task body();
    bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] wr_addr,temp_wr_addr,prev_core_addr[$];
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] wr_data[];
    int idx = -1;
    int num_beats;
    string port_name ; 
    int mp_aiu_pri_bitsq [$];
    int axcache[$],arcache[$];
    bit random_axcache;
    bit dmi_target,coh_dmi_target,loaded_traffic;
    bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] addr[$];
		

    `uvm_info(get_full_name(), $psprintf("Entered body ...nonshareable_start_addr.size:%0d", cfg.nonshareable_start_addr.size()), UVM_LOW)
    if($test$plusargs("random_axcache")) begin : set_random_axcache
      random_axcache = 1'b1;
    end
    
    dmi_target = $test$plusargs("non_coh_dmi_target");
    coh_dmi_target = $test$plusargs("coh_dmi_target");
		loaded_traffic = $test$plusargs("svt_rd_after_wr_to_dii_with_loaded_traffic");
    
    if (coh_dmi_target) begin : set_coherent_address_region
      addr = cfg.innershareable_start_addr;
    end else begin : set_non_coherent_address_region
      addr = cfg.nonshareable_start_addr;
    end
    
    // Loop through each memory region for initialization
    foreach (addr[i]) begin : loop_mem_regions_for_init 
      axcache = {};
      temp_wr_addr = addr[i] + 64;
      temp_wr_addr[5:0] = 6'b000000; 

      // Skip if the address doesn't match the target type
      if ((dmi_target && (!ncoreConfigInfo::is_dmi_addr(temp_wr_addr) || ncoreConfigInfo::is_dce_addr(temp_wr_addr))) ||
          (coh_dmi_target && (!ncoreConfigInfo::is_dce_addr(temp_wr_addr) || (loaded_traffic && temp_wr_addr inside {ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH]}))) ||
          (!(dmi_target || coh_dmi_target) && !ncoreConfigInfo::is_dii_addr(temp_wr_addr))) begin
        continue;
      end
      
      // Initialize 20 addresses in each memregion
      for (int j = 0; j < 20 ; j++) begin : init_addresses_in_region
			  wr_addr = temp_wr_addr + 64*j + (64*20*cfg.port_id);
			  if(core_id >=0)begin
        	wr_addr = ncoreConfigInfo::update_addr_for_core(wr_addr,funitid, core_id);
				  if(wr_addr inside {prev_core_addr})
						continue;
					prev_core_addr.push_back(wr_addr);
				end
        
        // Perform initialization writes with different prot_type settings
        for(int k = 0; k < 2; k++) begin : perform_init_write 
          `svt_xvm_do_with(full_cacheline_init_txn,
          {
            if(port_cfg.axi_interface_type inside{ svt_axi_port_configuration::AXI_ACE,svt_axi_port_configuration :: ACE_LITE} ){
              xact_type == COHERENT;
              if(coh_dmi_target)
                coherent_xact_type == svt_axi_transaction::WRITEUNIQUE;
              else
                coherent_xact_type == svt_axi_transaction::WRITENOSNOOP;
            } else {
              xact_type == svt_axi_transaction::WRITE;
            }
            addr == wr_addr;
            prot_type[1] == k;
            burst_size == $clog2(cfg.data_width/8);
            burst_length == 64 / (cfg.data_width/8);
            foreach(wstrb[index]){
              wstrb[index]==(1<<(1<<(burst_size)))-1;
              data[index] == '1;
            }
            if (coh_dmi_target) {
              local_axi4_addr_region_pick_ctl == 1;
            } else {
              local_axi4_addr_region_pick_ctl == 0;
            }
          })
          
          axcache.push_back(full_cacheline_init_txn.cache_type);
          full_cacheline_init_txn.wait_for_transaction_end();
          `uvm_info(get_name(), $sformatf("init full cacheline to addr:0x%0h ns:%0b is completed ...",full_cacheline_init_txn.addr, full_cacheline_init_txn.prot_type[1]), UVM_LOW)
        end : perform_init_write
      end : init_addresses_in_region
    end : loop_mem_regions_for_init
    // Main test loop: Loop through each memory region to perform writes and reads
		prev_core_addr = {};
    foreach (addr[i]) begin : loop_mem_regions_for_test
      axcache = {};
      arcache = {};
      temp_wr_addr = addr[i] + 64;
      temp_wr_addr[5:0] = 6'b000000;
      
      // Skip if the address doesn't match the target type
      if ((dmi_target && (!ncoreConfigInfo::is_dmi_addr(temp_wr_addr) || ncoreConfigInfo::is_dce_addr(temp_wr_addr))) ||
          (coh_dmi_target && (!ncoreConfigInfo::is_dce_addr(temp_wr_addr) || (loaded_traffic && temp_wr_addr inside {ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH]}))) ||
          (!(dmi_target || coh_dmi_target) && !ncoreConfigInfo::is_dii_addr(temp_wr_addr))) begin
        continue;
      end
      
      // Perform write-and-read sequence for 20 addresses
      for (int j = 0; j < 20 ; j++) begin : perform_wr_rd_sequence
        wr_addr = temp_wr_addr + 64*j + (64*20*cfg.port_id);
			  if(core_id >=0)begin
        	wr_addr = ncoreConfigInfo::update_addr_for_core(wr_addr,funitid, core_id);
				  if(wr_addr inside {prev_core_addr})
						continue;
					prev_core_addr.push_back(wr_addr);
				end

							 
        // Reset cache arrays if they reach a certain size
				// 10 unique values of awcache/arcache from ARM H_c Spec TABLE A4-5 Memory Type Encoding
				if ((coh_dmi_target || dmi_target) ? axcache.size() == 8 : axcache.size() == 10) begin : reset_awcache_array
          axcache = {};
        end 
        
        // Perform a write transaction
        `svt_xvm_do_with(wr_txn,
        {
          if(port_cfg.axi_interface_type inside{ svt_axi_port_configuration::AXI_ACE,svt_axi_port_configuration :: ACE_LITE} ){
            xact_type == COHERENT;
            if(coh_dmi_target)
              coherent_xact_type == svt_axi_transaction::WRITEUNIQUE;
            else
              coherent_xact_type == svt_axi_transaction::WRITENOSNOOP;
          } else {
            xact_type == svt_axi_transaction::WRITE;
          }
          addr == wr_addr;
					if(coh_dmi_target || dmi_target)
						cache_type[1] == 1'b1;
          !(cache_type inside{axcache});
          //prot_type[1] == 1;
          burst_length == 64 / (cfg.data_width/8);
          burst_size == $clog2(cfg.data_width/8);
          if (coh_dmi_target) {
            local_axi4_addr_region_pick_ctl == 1;
          } else {
            local_axi4_addr_region_pick_ctl == 0;
          }
          foreach(wstrb[index]){
            wstrb[index]==(1<<(1<<(burst_size)))-1;
          }
        })
        
        axcache.push_back(wr_txn.cache_type);
        wr_txn.wait_for_transaction_end();
        `uvm_info(get_full_name(), $sformatf("wr_txn to addr:0x%0h ns:%0b len:%0d size:%0d is completed ...", wr_txn.addr, wr_txn.prot_type[1], wr_txn.burst_length, wr_txn.burst_size), UVM_LOW)
        
        // Reset read cache array if it reaches a certain size
        if ((coh_dmi_target || dmi_target) ? arcache.size() == 8 : arcache.size() == 10) begin : reset_arcache_array
          arcache = {};
        end
        
        // Perform a read transaction to the same address
        `svt_xvm_do_with(rd_txn,
        {
          if(port_cfg.axi_interface_type inside{ svt_axi_port_configuration::AXI_ACE,svt_axi_port_configuration :: ACE_LITE} ){
            xact_type == COHERENT;
            if(coh_dmi_target)
              coherent_xact_type == svt_axi_transaction::READONCE;
            else
              coherent_xact_type == svt_axi_transaction::READNOSNOOP;
          } else {
            xact_type == svt_axi_transaction::READ;
          }
          addr == wr_txn.addr;
          if(random_axcache){
            !(cache_type inside{arcache});
						if(coh_dmi_target || dmi_target)
							cache_type[1] == 1'b1;
          }else
            cache_type == wr_txn.cache_type;
          prot_type[1] == wr_txn.prot_type[1];
          burst_length == 64 / (cfg.data_width/8);
          burst_size == $clog2(cfg.data_width/8);
          if (coh_dmi_target) {
            local_axi4_addr_region_pick_ctl == 1;
          } else {
            local_axi4_addr_region_pick_ctl == 0;
          }
        })
        
        arcache.push_back(rd_txn.cache_type);
        rd_txn.wait_for_transaction_end();
        get_response(rsp, rd_txn.get_transaction_id());
        `uvm_info(get_full_name(), $sformatf("rd_txn to addr:0x%0h ns:%0b len:%0d size:%0d is completed ...", rd_txn.addr, rd_txn.prot_type[1], rd_txn.burst_length, rd_txn.burst_size), UVM_LOW)
        
        // Check data integrity
        data_integrity_check(rd_txn,wr_txn);
      end : perform_wr_rd_sequence
    end : loop_mem_regions_for_test
    
    `uvm_info(get_full_name(), $psprintf("Exit body ..."), UVM_LOW)
  endtask:body 
endclass:svt_rd_after_wr_to_dii_seq


