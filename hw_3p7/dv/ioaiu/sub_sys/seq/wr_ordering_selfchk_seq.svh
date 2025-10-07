class wr_ordering_selfchk_seq extends svt_axi_seq;
  `svt_xvm_object_utils(wr_ordering_selfchk_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)

  // Transaction handles for various operations
  io_subsys_axi_master_transaction full_cacheline_init_txn;
  io_subsys_axi_master_transaction wr_txn[50][20][2];
  io_subsys_axi_master_transaction rd_txn[50][20][100];
  
  // Constructor
  function new(string name = "wr_ordering_selfchk_seq");
    super.new(name);
  endfunction: new

  // Pre-body phase: can be used for pre-test setup if needed
  virtual task pre_body();
    super.pre_body();
  endtask: pre_body

  // Main test body
  virtual task body();
    bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] wr_addr, temp_wr_addr,prev_core_addr[$];
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] wr_data[];
    int wait_of_read[50][20][100];
    bit[5:0] temp_id;
    int num_beats, num_txn, fnmem_region_idx, dest_id, agent_id;
    string port_name;
    int mp_aiu_pri_bitsq [$];
    int axcache[$], arcache[$];
    bit random_axcache;
    bit dmi_target, coh_dmi_target;
    bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] addr [$];
    bit ns; // Non-shareable bit
    bit random_id;
    bit[1:0] out_type;

    `uvm_info(get_full_name(), $psprintf("Entered body..."), UVM_LOW)

    // Check for plusargs to configure test behavior
    if ($test$plusargs("random_axcache")) begin: check_random_axcache
      random_axcache = 1'b1;
    end: check_random_axcache
    random_id = $test$plusargs("unique_id");
    dmi_target = $test$plusargs("non_coh_dmi_target");
    coh_dmi_target = $test$plusargs("coh_dmi_target");

    // Select the address region based on plusargs
    if (coh_dmi_target) begin: set_coherent_address_region
      addr = cfg.innershareable_start_addr;
    end else begin: set_non_coherent_address_region
      addr = cfg.nonshareable_start_addr;
    end: set_non_coherent_address_region

    // === Phase 1: Initialize memory regions with full cacheline writes ===
    foreach (addr[i]) begin: loop_mem_regions_for_init
      axcache = {};

      // Align the base address to a 64-byte boundary
      temp_wr_addr = addr[i] + 64;
      temp_wr_addr[5:0] = 6'b0;

      // Skip regions that don't match the target type
      if ((dmi_target && (!addrMgrConst::is_dmi_addr(temp_wr_addr) || addrMgrConst::is_dce_addr(temp_wr_addr))) ||
          (coh_dmi_target && !addrMgrConst::is_dce_addr(temp_wr_addr)) ||
          (!(dmi_target || coh_dmi_target) && (!addrMgrConst::is_dii_addr(temp_wr_addr) || addrMgrConst::check_unmapped_add(temp_wr_addr,funitid,out_type)))) begin: check_address_region_type
        continue;
      end: check_address_region_type

      // Check if the address region allows writes (gprar_writeid != 0)
      if (addrMgrConst::get_mem_writeid_readid_policy(temp_wr_addr) inside {4'b1100,4'b1000,4'b1011}) begin: perform_init_writes_in_region
        for (int j = 0; j < 10; j++) begin: init_cacheline_addresses
          wr_addr = temp_wr_addr + 64 * j + (64 * 20 * cfg.port_id);
					if(core_id >=0)begin
						wr_addr = addrMgrConst::update_addr_for_core(wr_addr,funitid, core_id);
						if(wr_addr inside {prev_core_addr})
							continue;
						prev_core_addr.push_back(wr_addr);
					end
          for (int k = 0; k < 2; k++) begin: perform_init_write
            `svt_xvm_do_with(full_cacheline_init_txn,
            {
              if (port_cfg.axi_interface_type inside {svt_axi_port_configuration::AXI_ACE, svt_axi_port_configuration::ACE_LITE}) {
                xact_type == COHERENT;
                if (coh_dmi_target) {
                  coherent_xact_type == svt_axi_transaction::WRITEUNIQUE;
                } else {
                  coherent_xact_type == svt_axi_transaction::WRITENOSNOOP;
                }
              } else {
                xact_type == svt_axi_transaction::WRITE;
              }
              addr == wr_addr;
              prot_type[1] == k;
              burst_size == $clog2(cfg.data_width / 8);
              burst_length == 64 / (cfg.data_width / 8);
              foreach (wstrb[index]) {
                wstrb[index] == (1 << (1 << (burst_size))) - 1;
                data[index] == '1;
              }
              if (coh_dmi_target) {
                local_axi4_addr_region_pick_ctl == 1;
              } else {
                local_axi4_addr_region_pick_ctl == 0;
              }
            })
            full_cacheline_init_txn.wait_for_transaction_end();
            `uvm_info(get_name(), $sformatf("Initial write to addr:0x%0h ns:%0b completed.", full_cacheline_init_txn.addr, full_cacheline_init_txn.prot_type[1]), UVM_LOW)
          end: perform_init_write
        end: init_cacheline_addresses
      end: perform_init_writes_in_region
    end: loop_mem_regions_for_init
    prev_core_addr = {};
    // === Phase 2: Perform back-to-back writes and parallel reads ===
    foreach (addr[i]) begin: test_b2b_wr_rd_sequence
      automatic int d = i;
      axcache = {};
      arcache = {};

      temp_wr_addr = addr[i] + 64;
      temp_wr_addr[5:0] = 6'b0;

      // Skip regions that don't match the target type or unmapped addr
      if ((dmi_target && (!addrMgrConst::is_dmi_addr(temp_wr_addr) || addrMgrConst::is_dce_addr(temp_wr_addr))) ||
          (coh_dmi_target && !addrMgrConst::is_dce_addr(temp_wr_addr)) ||
          (!(dmi_target || coh_dmi_target) && (!addrMgrConst::is_dii_addr(temp_wr_addr) || addrMgrConst::check_unmapped_add(temp_wr_addr,funitid,out_type)))) begin: check_address_region_type_2
        continue;
      end: check_address_region_type_2

      // Check if the address region allows writes (gprar_writeid != 0)
      if (addrMgrConst::get_mem_writeid_readid_policy(temp_wr_addr) inside {4'b1100,4'b1000,4'b1011}) begin: perform_writes_and_reads_in_region
        for (int j = 0; j < 10; j++) begin: perform_test_on_address
          automatic int c = j;
          wr_addr = temp_wr_addr + 64 * j + (64 * 20 * cfg.port_id);
					if(core_id >=0)begin
						wr_addr = addrMgrConst::update_addr_for_core(wr_addr,funitid, core_id);
						if(wr_addr inside {prev_core_addr})
							continue;
						prev_core_addr.push_back(wr_addr);
					end
          // Reset cache arrays to cycle through cache types
          if ((coh_dmi_target || dmi_target) ? axcache.size() == 8 : axcache.size() == 10) begin: reset_awcache_array
            axcache = {};
          end: reset_awcache_array

          std::randomize(temp_id, ns);
          // Perform two back-to-back writes to the same address
          for (int k = 0; k < 2; k++) begin: perform_b2b_writes
						`uvm_info("i am here",$sformatf("temp_id:%0h,ns:%0b,wr_addr:%0h,k:%0d",temp_id,ns,wr_addr,k),UVM_LOW)
            `svt_xvm_do_with(wr_txn[i][j][k],
            {
              if (port_cfg.axi_interface_type inside {svt_axi_port_configuration::AXI_ACE, svt_axi_port_configuration::ACE_LITE}) {
                xact_type == COHERENT;
                if (coh_dmi_target) {
                  coherent_xact_type == svt_axi_transaction::WRITEUNIQUE;
                } else {
                  coherent_xact_type == svt_axi_transaction::WRITENOSNOOP;
                }
              } else {
                xact_type == svt_axi_transaction::WRITE;
              }
              addr == wr_addr;
              !(cache_type inside {axcache});
              if (!random_id) {
                id == temp_id;
              }
              prot_type[1] == ns;
              reference_event_for_addr_valid_delay == PREV_ADDR_VALID;
              burst_length == 64 / (cfg.data_width / 8);
              burst_size == $clog2(cfg.data_width / 8);
              if (coh_dmi_target) {
                local_axi4_addr_region_pick_ctl == 1;
              } else {
                local_axi4_addr_region_pick_ctl == 0;
              }
              foreach (wstrb[index]) {
                wstrb[index] == (1 << (1 << (burst_size))) - 1;
              }
            })
            axcache.push_back(wr_txn[i][j][k].cache_type);
            
            if (random_id && k == 0) begin: wait_for_unique_id_write
              wr_txn[d][c][k].wait_for_transaction_end();
            end: wait_for_unique_id_write
            `uvm_info(get_full_name(), $sformatf("wr_txn to addr:0x%0h ns:%0b len:%0d size:%0d is completed id:%0d...", wr_txn[i][j][k].addr, wr_txn[i][j][k].prot_type[1], wr_txn[i][j][k].burst_length, wr_txn[i][j][k].burst_size, wr_txn[i][j][k].id), UVM_LOW)
          end: perform_b2b_writes

          // Reset read cache array
          if ((coh_dmi_target || dmi_target) ? arcache.size() == 8 : arcache.size() == 10) begin: reset_arcache_array
            arcache = {};
          end: reset_arcache_array

          // Start read transactions concurrently
          fork: concurrent_reads_and_checks
            // Process 1: Initiate read transactions after the second write is finished
            begin: initiate_reads
              wr_txn[d][c][1].wait_for_transaction_end();
              for (int z = 0; z < 10; z++) begin: send_read_transactions
						`uvm_info("i am here read",$sformatf("wr_addr:%0h,z:%0d",wr_txn[d][c][1].addr,z),UVM_LOW)
                `svt_xvm_do_with(rd_txn[d][c][z],
                {
                  if (port_cfg.axi_interface_type inside {svt_axi_port_configuration::AXI_ACE, svt_axi_port_configuration::ACE_LITE}) {
                    xact_type == COHERENT;
                    if (coh_dmi_target) {
                      coherent_xact_type == svt_axi_transaction::READONCE;
                    } else {
                      coherent_xact_type == svt_axi_transaction::READNOSNOOP;
                    }
                  } else {
                    xact_type == svt_axi_transaction::READ;
                  }
                  addr == wr_txn[d][c][1].addr;
                  if (!random_axcache) {
                    cache_type == wr_txn[d][c][1].cache_type;
                  }
                  prot_type[1] == wr_txn[d][c][1].prot_type[1];
                  burst_length == 64 / (cfg.data_width / 8);
                  burst_size == $clog2(cfg.data_width / 8);
                  if (coh_dmi_target) {
                    local_axi4_addr_region_pick_ctl == 1;
                  } else {
                    local_axi4_addr_region_pick_ctl == 0;
                  }
                })
                arcache.push_back(rd_txn[d][c][z].cache_type);
                wait_of_read[d][c][z] = 1;
                `uvm_info("TAG", $sformatf("Read transaction %0d for address 0x%0h initiated.", z, rd_txn[d][c][z].addr), UVM_LOW)
              end: send_read_transactions
            end: initiate_reads
            
            // Process 2: Wait for read responses and perform data integrity check
            begin: process_read_responses
              for (int z = 0; z < 10; z++) begin: check_responses
                wait(wait_of_read[d][c][z] == 1);
                rd_txn[d][c][z].wait_for_transaction_end();
                get_response(rsp, rd_txn[d][c][z].get_transaction_id());
                
                dest_id = addrMgrConst::map_addr2dmi_or_dii(rd_txn[d][c][z].addr,fnmem_region_idx);
                agent_id = addrMgrConst::agentid_assoc2funitid(dest_id);
					      if((addrMgrConst::io_subsys_owo_en[cfg.port_id] == 1) || (addrMgrConst::get_mem_writeid_readid_policy(rd_txn[d][c][z].addr) != 4'b1011))begin
									`uvm_info(get_full_name(), $sformatf("data_integrity_check with valid policy and ID r0_awcache:0x%0h wr1_awcache:0x%0h rd_arcache:0x%0h (rd #%0d) to addr:0x%0h ns:%0b to tgt:%0d is completed...", wr_txn[d][c][0].cache_type,  wr_txn[d][c][1].cache_type, rd_txn[d][c][z].cache_type, z, rd_txn[d][c][z].addr, rd_txn[d][c][z].prot_type[1], agent_id), UVM_NONE)
									data_integrity_check(rd_txn[d][c][z], wr_txn[d][c][1]);
								end else begin
									`uvm_info(get_full_name(), $sformatf("data_integrity_check with wr0_awcache:0x%0h wr1_awcache:0x%0h rd_arcache:0x%0h (rd #%0d) to addr:0x%0h ns:%0b to tgt:%0d is completed...", wr_txn[d][c][0].cache_type,  wr_txn[d][c][1].cache_type, rd_txn[d][c][z].cache_type, z, rd_txn[d][c][z].addr, rd_txn[d][c][z].prot_type[1], agent_id), UVM_NONE)
								end
              end: check_responses
            end: process_read_responses
          join_none
        end: perform_test_on_address
      end: perform_writes_and_reads_in_region
    end: test_b2b_wr_rd_sequence

    wait fork;
    `uvm_info(get_full_name(), $psprintf("Exit body ..."), UVM_LOW)
  endtask: body
endclass
