//=====================================================================================================================================
// uvm_sequence <-- io_subsys_base_seq <-- io_subsys_owo_axi_directed_noncoh_wr_rd_check_seq 
// svt_sequence <-- svt_axi_master_base_sequence <-- svt_axi_master_random_sequence
/* 
 *  This sequence generates random master transactions.
 */
//====================================================================================================================================

class io_subsys_owo_axi_directed_noncoh_wr_rd_check_seq extends io_subsys_base_seq;
  localparam int DATA_WIDTH=4096;
  localparam int cacheline_size_in_bytes=64;
  `svt_xvm_object_utils(io_subsys_owo_axi_directed_noncoh_wr_rd_check_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  
  /** Configuration of sequencer attached to this sequence */ 
  svt_axi_port_configuration port_cfg;

  int sequence_length = 1;

  bit bypass_data_in_data_out_checks=0;
  bit use_single_mem_region_in_test=0;
  bit back_to_back_writes_and_then_read=0;

  int log_base_2_cache_line_size;
  int log_base_2_data_width_in_bytes;
  int width;
  svt_axi_master_transaction active_xacts[$];

  function new(string name = "io_subsys_owo_axi_directed_noncoh_wr_rd_check_seq");
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
      int temp;
                  temp_addr[addr_trans_mgr_pkg::addrMgrConst::W_SEC_ADDR-1:44] = csrq[ig].upp_addr;
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
      if($test$plusargs("back_to_back_writes_and_then_read"))   back_to_back_writes_and_then_read=1;

      p_sequencer.get_cfg(base_cfg);
      if (!$cast(port_cfg, base_cfg)) begin
        `uvm_fatal("pre_body", "Unable to $cast the configuration to a svt_axi_port_configuration class");
      end
      log_base_2_cache_line_size = port_cfg.log_base_2(port_cfg.cache_line_size);
      log_base_2_data_width_in_bytes = port_cfg.log_base_2(port_cfg.data_width/8);
      width = port_cfg.data_width/8;

  endtask:pre_body;

  virtual task body();
  bit [DATA_WIDTH-1:0] data_in, data_in_1;
  bit [DATA_WIDTH-1:0] data_out, data_out_1;
  bit [(cacheline_size_in_bytes*8) -1 :0] data_in_a[64];
  bit [(cacheline_size_in_bytes*8) -1 :0] data_out_a[64];
  string data_out_str="";
  string data_in_str="";
  int data_index_cacheline_size;
  string data_mismatch_str=""; //cacheline size data granual
  bit is_data_mismatch;

  int data_size;
  bit [addrMgrConst::W_SEC_ADDR-1:0] non_coh_addr;
  bit rand_success;
  svt_axi_master_transaction master_xact,master_xact1;
  bit [3:0]aXcache;
 `SVT_XVM(sequence_item) rsp;
  svt_axi_transaction::prot_type_enum t_prot_type;
  io_subsys_axi_master_transaction io_master_xact_to_dis_inject_intf_parity_err;
  bit [`SVT_AXI_MAX_ID_WIDTH - 1:0] t_awid = 0;
  bit test_arg_inject_slv_error;
      `uvm_info(get_full_name(), $psprintf("Entered body ..."), UVM_LOW)
       for(int crit_dw=0;crit_dw<8;crit_dw=crit_dw+1) begin : looping_for_each_critical_DW
           for(int len = 0; len < 4; len++) begin : looping_for_each_len
               for(int all_dmi=0;all_dmi<(use_single_mem_region_in_test ? 1 :all_dmi_start_addr.size());all_dmi=all_dmi+1) begin : looping_for_each_dmi
                   if($test$plusargs("k_directed_test_wr_rd_to_all_dmi")) begin : k_directed_test_wr_rd_to_all_dmi
                       for(int all_dmi_in_ig=0;all_dmi_in_ig<(use_single_mem_region_in_test ? 1 :all_dmi_start_addr[all_dmi].size());all_dmi_in_ig=all_dmi_in_ig+1) begin : looping_for_each_dmi_in_ig
                           //if(all_dmi_nc[all_dmi][all_dmi_in_ig]==0) begin : coh_regions
                               for(int i = 0; i < sequence_length; i++) begin : looping_for_sequence_length
                                   test_arg_inject_slv_error = 0;
                                   if($test$plusargs("test_arg_inject_slv_error")) begin
                                       randcase
                                       90:test_arg_inject_slv_error = 1;
                                       10:test_arg_inject_slv_error = 0;
                                       endcase
                                   end
                                   if(test_arg_inject_slv_error)
                                       addrMgrConst::general_global_var["inject_slv_error"] = 1;
                                   non_coh_addr = all_dmi_start_addr[all_dmi][all_dmi_in_ig] + (i*64);
                                   non_coh_addr[5:3] = crit_dw;
                                   /********** WRITE ***********/
                                   `svt_xvm_create(master_xact);
                                   master_xact.port_cfg = port_cfg;
                                   master_xact.port_id = port_cfg.port_id;
                                   master_xact.reasonable_readonce_writeunique_burst_length.constraint_mode(0);
                                   rand_success = master_xact.randomize() with
                                   {
                                       //coherent_xact_type == svt_axi_transaction::WRITENOSNOOP;
                                       xact_type == svt_axi_transaction::WRITE;
                                       addr == local::non_coh_addr;
                                       burst_length == (local::len+1);
                                       burst_type == svt_axi_transaction::INCR;
                                       burst_size == local::log_base_2_data_width_in_bytes;
                                       foreach (wstrb[index]) {
                                           wstrb[index] == ((1 << (1 << burst_size)) - 1);
                                       }
                                       prot_type inside {svt_axi_transaction::DATA_SECURE_NORMAL,svt_axi_transaction::DATA_SECURE_PRIVILEGED};
                                   };
                                   if(!rand_success) 
                                       `uvm_error(get_full_name,"Randomization failure!!");
                                   `svt_xvm_send(master_xact);
                                   foreach(master_xact.data[index]) begin
                                       for(int data_bit=0; data_bit<port_cfg.data_width;data_bit=data_bit+1) begin
                                           data_out[index*port_cfg.data_width + data_bit] = master_xact.data[index][data_bit];
                                       end
                                   end
                                   master_xact.wait_for_transaction_end();
                                   t_prot_type = master_xact.prot_type;
                                   get_response(rsp);
                                   `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Non-Coherent Addr=0x%x, data_out = 0x%x, width=%0d len=%0d Critical DW=%0d", portid,all_dmi,all_dmi_in_ig,non_coh_addr, data_out, width,len,crit_dw), UVM_LOW)
                                   test_arg_inject_slv_error = addrMgrConst::general_global_var["slv_error_injected"];
                                   if(test_arg_inject_slv_error) begin
                                      if(master_xact.bresp inside {svt_axi_transaction::SLVERR, svt_axi_transaction::DECERR})
                                          `uvm_info(get_full_name(), $sformatf("[test_arg_inject_slv_error case] IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Non-Coherent Addr=0x%x. BRESP inside {SLVERR, DECERR} as expected", portid,all_dmi,all_dmi_in_ig,non_coh_addr), UVM_LOW)
                                      else
                                          `uvm_error(get_full_name(), $sformatf("[test_arg_inject_slv_error case] IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Non-Coherent Addr=0x%x. BRESP=%0s not found inside {SLVERR, DECERR} as expected", portid,all_dmi,all_dmi_in_ig,non_coh_addr,master_xact.bresp.name()))
                                   end
                                   if($test$plusargs("inject_interface_parity_error")) begin : _inject_interface_parity_error_
                                       //Enable interface parity injection
                                       foreach(io_master_xact_to_dis_inject_intf_parity_err.io_subsys_axi_dis_inject_intf_parity_err[x])
                                           io_master_xact_to_dis_inject_intf_parity_err.io_subsys_axi_dis_inject_intf_parity_err[x] = 0;

                                       `svt_xvm_create(master_xact);
                                       master_xact.port_cfg = port_cfg;
                                       master_xact.port_id = port_cfg.port_id;
                                       master_xact.reasonable_readonce_writeunique_burst_length.constraint_mode(0);
                                       rand_success = master_xact.randomize() with
                                       {
                                           //coherent_xact_type == svt_axi_transaction::WRITENOSNOOP;
                                           xact_type == svt_axi_transaction::WRITE;
                                           addr == local::non_coh_addr;
                                           burst_length == (local::len+1);
                                           burst_type == svt_axi_transaction::INCR;
                                           burst_size == local::log_base_2_data_width_in_bytes;
                                           foreach (wstrb[index]) {
                                               wstrb[index] == ((1 << (1 << burst_size)) - 1);
                                           }
                                           prot_type == local::t_prot_type;
                                       };
                                       if(!rand_success) 
                                           `uvm_error(get_full_name,"Randomization failure!!");
                                       `svt_xvm_send(master_xact);
                                       master_xact.wait_for_transaction_end();
                                       t_prot_type = master_xact.prot_type;
                                       get_response(rsp);
                                       `uvm_info(get_full_name(), $sformatf("[inject_interface_parity_error] IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Non-Coherent Addr=0x%x", portid,all_dmi,all_dmi_in_ig,non_coh_addr), UVM_LOW)

                                       //Disable interface parity injection
                                       foreach(io_master_xact_to_dis_inject_intf_parity_err.io_subsys_axi_dis_inject_intf_parity_err[x])
                                           io_master_xact_to_dis_inject_intf_parity_err.io_subsys_axi_dis_inject_intf_parity_err[x] = 1;
                                   end : _inject_interface_parity_error_


                                   /********** READ  ***********/
                                   `svt_xvm_create(master_xact);
                                   master_xact.port_cfg = port_cfg;
                                   master_xact.port_id = port_cfg.port_id;
                                   master_xact.reasonable_readonce_writeunique_burst_length.constraint_mode(0);
                                   rand_success = master_xact.randomize() with
                                   {
                                       //coherent_xact_type == svt_axi_transaction::READNOSNOOP;
                                       xact_type == svt_axi_transaction::READ;
                                       addr == local::non_coh_addr;
                                       burst_length == (local::len+1);
                                       burst_type == svt_axi_transaction::INCR;
                                       burst_size == local::log_base_2_data_width_in_bytes;
                                       prot_type == local::t_prot_type;
                                   };
                                   if(!rand_success) 
                                       `uvm_error(get_full_name,"Randomization failure!!");
                                   `svt_xvm_send(master_xact);
                                   master_xact.wait_for_transaction_end();
                                   foreach(master_xact.data[index]) begin
                                       for(int data_bit=0; data_bit<port_cfg.data_width;data_bit=data_bit+1) begin
                                           data_in[index*port_cfg.data_width + data_bit] = master_xact.data[index][data_bit];
                                       end
                                   end
                                   get_response(rsp);
                                   `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] AXI Read Non-Coherent Addr=0x%x, data_in= 0x%x, width=%0d len=%0d Critical DW=%0d", portid,all_dmi,all_dmi_in_ig,non_coh_addr, data_in, width,len,crit_dw), UVM_LOW)

                                   test_arg_inject_slv_error = addrMgrConst::general_global_var["slv_error_injected"];
                                   if(test_arg_inject_slv_error) begin
                                      foreach(master_xact.rresp[index]) begin
                                        if(master_xact.rresp[index] inside {svt_axi_transaction::SLVERR, svt_axi_transaction::DECERR})
                                            `uvm_info(get_full_name(), $sformatf("[test_arg_inject_slv_error case] IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Non-Coherent Addr=0x%x. RRESP[%0d] inside {SLVERR, DECERR} as expected", portid,all_dmi,all_dmi_in_ig,non_coh_addr,index), UVM_LOW)
                                        else
                                            `uvm_error(get_full_name(), $sformatf("[test_arg_inject_slv_error case] IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Non-Coherent Addr=0x%x. RRESP[%0d]=%0s not found inside {SLVERR, DECERR} as expected", portid,all_dmi,all_dmi_in_ig,non_coh_addr,index,master_xact.rresp[index].name()))
                                       end
                                   end

                                 if(!test_arg_inject_slv_error)
                                   if (data_out != data_in) begin
                                     if(!bypass_data_in_data_out_checks) 
                                         `uvm_error(get_full_name, $sformatf("IOAIU-%0d DMI [%0d][IG-%0d] Data Mismatch. Address = 0x%x,len = %d , Read Data = %x, Write Data = %x, Critical DW=%0d",portid,all_dmi,all_dmi_in_ig, non_coh_addr, len, data_in,data_out,crit_dw)) 
                                     else
                                         `uvm_info(get_full_name, $sformatf("IOAIU-%0d DMI [%0d][IG-%0d] Data Mismatch. Address = 0x%x,len = %d , Read Data = %x, Write Data = %x, Critical DW=%0d",portid,all_dmi,all_dmi_in_ig, non_coh_addr, len, data_in,data_out,crit_dw), UVM_LOW) 
                                   end
                                   else
                                     `uvm_info(get_full_name, $sformatf("IOAIU-%0d DMI [%0d][IG-%0d] Data Write-Read Test Match. Address = 0x%x,len = %d , Read Data = %x, Write Data = %x, Critical DW=%0d",portid,all_dmi,all_dmi_in_ig, non_coh_addr, len, data_in,data_out,crit_dw), UVM_LOW) 
 
                                   if(test_arg_inject_slv_error) begin
                                       addrMgrConst::general_global_var["inject_slv_error"] = 0;
                                       addrMgrConst::general_global_var["slv_error_injected"] = 0;
                                   end
                               end : looping_for_sequence_length
                           //end : coh_regions
                       end : looping_for_each_dmi_in_ig
                   end : k_directed_test_wr_rd_to_all_dmi
               end : looping_for_each_dmi
           end : looping_for_each_len
       end : looping_for_each_critical_DW

       for(int crit_dw=0;crit_dw<8;crit_dw=crit_dw+1) begin : looping_for_each_critical_DW
           for(int len = 0; len < 4; len++) begin : looping_for_each_len
               for(int all_dii=0;all_dii<(use_single_mem_region_in_test ? 1 :all_dii_start_addr.size());all_dii=all_dii+1) begin : looping_for_each_dii
                   if($test$plusargs("k_directed_test_wr_rd_to_all_dii")) begin : k_directed_test_wr_rd_to_all_dii
                       for(int all_dii_in_ig=0;all_dii_in_ig<(use_single_mem_region_in_test ? 1 :all_dii_start_addr[all_dii].size());all_dii_in_ig=all_dii_in_ig+1) begin : looping_for_each_dii_in_ig
                           //if(all_dii_nc[all_dii][all_dii_in_ig]==0) begin : coh_regions
                               for(int i = 0; i < sequence_length; i++) begin : looping_for_sequence_length
                                   test_arg_inject_slv_error = 0;
                                   if(($test$plusargs("test_arg_inject_slv_error")) && (all_dii_sub_region_type[all_dii][all_dii_in_ig]!=2)) begin
                                       randcase
                                       90:test_arg_inject_slv_error = 1;
                                       10:test_arg_inject_slv_error = 0;
                                       endcase
                                   end
                                   if(test_arg_inject_slv_error)
                                       addrMgrConst::general_global_var["inject_slv_error"] = 1;
                                   non_coh_addr = all_dii_start_addr[all_dii][all_dii_in_ig] + (i*64);
                                   non_coh_addr[5:3] = crit_dw;

                                   /********** WRITE ***********/
                                   `svt_xvm_create(master_xact);
                                   master_xact.port_cfg = port_cfg;
                                   master_xact.port_id = port_cfg.port_id;
                                   master_xact.reasonable_readonce_writeunique_burst_length.constraint_mode(0);
                                   rand_success = master_xact.randomize() with
                                   {
                                       //coherent_xact_type == svt_axi_transaction::WRITENOSNOOP;
                                       xact_type == svt_axi_transaction::WRITE;
                                       addr == local::non_coh_addr;
                                       burst_length == (local::len+1);
                                       burst_type == svt_axi_transaction::INCR;
                                       burst_size == local::log_base_2_data_width_in_bytes;
                                       foreach (wstrb[index]) {
                                           wstrb[index] == ((1 << (1 << burst_size)) - 1);
                                       }
                                       prot_type inside {svt_axi_transaction::DATA_SECURE_NORMAL,svt_axi_transaction::DATA_SECURE_PRIVILEGED};
                                       if(all_dii_sub_region_type[all_dii][all_dii_in_ig]==0) { //DEV
                                           cache_type inside {0,1};
                                       } else if(all_dii_sub_region_type[all_dii][all_dii_in_ig]==1) { //NONCACHEABLE
                                           cache_type inside {2,3};
                                       } else if(all_dii_sub_region_type[all_dii][all_dii_in_ig]==2) { //CACHEABLE
                                           cache_type inside {'h6,'h7,'h8,'h9,'he,'hf};
                                       }
                                       cache_type[0] == 0;
                                   };
                                   if(!rand_success) 
                                       `uvm_error(get_full_name,"Randomization failure!!");
                                   `svt_xvm_send(master_xact);
                                   foreach(master_xact.data[index]) begin
                                       for(int data_bit=0; data_bit<port_cfg.data_width;data_bit=data_bit+1) begin
                                           data_out[index*port_cfg.data_width + data_bit] = master_xact.data[index][data_bit];
                                       end
                                   end
                                   master_xact.wait_for_transaction_end();
                                   wait_for_active_xacts_to_end();
                                   t_prot_type = master_xact.prot_type;
                                   get_response(rsp);
                                   `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DII[%0d][IG-%0d] AXI Write Non-Coherent Addr=0x%x, data_out = 0x%x, width=%0d len=%0d Critical DW=%0d", portid,all_dii,all_dii_in_ig,non_coh_addr, data_out, width,len,crit_dw), UVM_LOW)
                                   test_arg_inject_slv_error = addrMgrConst::general_global_var["slv_error_injected"];
                                   if(test_arg_inject_slv_error) begin
                                      if(master_xact.bresp inside {svt_axi_transaction::SLVERR, svt_axi_transaction::DECERR})
                                          `uvm_info(get_full_name(), $sformatf("[test_arg_inject_slv_error case] IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Non-Coherent Addr=0x%x. BRESP inside {SLVERR, DECERR} as expected", portid,all_dii,all_dii_in_ig,non_coh_addr), UVM_LOW)
                                      else
                                          `uvm_error(get_full_name(), $sformatf("[test_arg_inject_slv_error case] IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Non-Coherent Addr=0x%x. BRESP=%0s not found inside {SLVERR, DECERR} as expected", portid,all_dii,all_dii_in_ig,non_coh_addr,master_xact.bresp.name()))
                                   end

                                   if($test$plusargs("inject_interface_parity_error")) begin : _inject_interface_parity_error_
                                       //Enable interface parity injection
                                       foreach(io_master_xact_to_dis_inject_intf_parity_err.io_subsys_axi_dis_inject_intf_parity_err[x])
                                           io_master_xact_to_dis_inject_intf_parity_err.io_subsys_axi_dis_inject_intf_parity_err[x] = 0;

                                       `svt_xvm_create(master_xact);
                                       master_xact.port_cfg = port_cfg;
                                       master_xact.port_id = port_cfg.port_id;
                                       master_xact.reasonable_readonce_writeunique_burst_length.constraint_mode(0);
                                       rand_success = master_xact.randomize() with
                                       {
                                           //coherent_xact_type == svt_axi_transaction::WRITENOSNOOP;
                                           xact_type == svt_axi_transaction::WRITE;
                                           addr == local::non_coh_addr;
                                           burst_length == (local::len+1);
                                           burst_type == svt_axi_transaction::INCR;
                                           burst_size == local::log_base_2_data_width_in_bytes;
                                           foreach (wstrb[index]) {
                                               wstrb[index] == ((1 << (1 << burst_size)) - 1);
                                           }
                                           if(all_dii_sub_region_type[all_dii][all_dii_in_ig]==0) { //DEV
                                               cache_type inside {0,1};
                                           } else if(all_dii_sub_region_type[all_dii][all_dii_in_ig]==1) { //NONCACHEABLE
                                               cache_type inside {2,3};
                                           } else if(all_dii_sub_region_type[all_dii][all_dii_in_ig]==2) { //CACHEABLE
                                               cache_type inside {'h6,'h7,'h8,'h9,'he,'hf};
                                           }
                                           prot_type == local::t_prot_type;
                                           cache_type[0] == 0;
                                       };
                                       if(!rand_success) 
                                           `uvm_error(get_full_name,"Randomization failure!!");
                                       `svt_xvm_send(master_xact);
                                       master_xact.wait_for_transaction_end();
                                       wait_for_active_xacts_to_end();
                                       t_prot_type = master_xact.prot_type;
                                       get_response(rsp);
                                       `uvm_info(get_full_name(), $sformatf("[inject_interface_parity_error] IOAIU-%0d DII[%0d][IG-%0d] AXI Write Non-Coherent Addr=0x%x", portid,all_dii,all_dii_in_ig,non_coh_addr), UVM_LOW)

                                       //Disable interface parity injection
                                       foreach(io_master_xact_to_dis_inject_intf_parity_err.io_subsys_axi_dis_inject_intf_parity_err[x])
                                           io_master_xact_to_dis_inject_intf_parity_err.io_subsys_axi_dis_inject_intf_parity_err[x] = 1;
                                   end : _inject_interface_parity_error_


                                   /********** READ  ***********/
                                   `svt_xvm_create(master_xact);
                                   master_xact.port_cfg = port_cfg;
                                   master_xact.port_id = port_cfg.port_id;
                                   master_xact.reasonable_readonce_writeunique_burst_length.constraint_mode(0);
                                   rand_success = master_xact.randomize() with
                                   {
                                       //coherent_xact_type == svt_axi_transaction::READNOSNOOP;
                                       xact_type == svt_axi_transaction::READ;
                                       addr == local::non_coh_addr;
                                       burst_length == (local::len+1);
                                       burst_type == svt_axi_transaction::INCR;
                                       burst_size == local::log_base_2_data_width_in_bytes;
                                       prot_type == local::t_prot_type;
                                       if(all_dii_sub_region_type[all_dii][all_dii_in_ig]==0) { //DEV
                                           cache_type inside {0,1};
                                       } else if(all_dii_sub_region_type[all_dii][all_dii_in_ig]==1) { //NONCACHEABLE
                                           cache_type inside {2,3};
                                       } else if(all_dii_sub_region_type[all_dii][all_dii_in_ig]==2) { //CACHEABLE
                                           cache_type inside {'h6,'h7,'h8,'h9,'he,'hf};
                                       }
                                       cache_type[0] == 0;
                                   };
                                   if(!rand_success) 
                                       `uvm_error(get_full_name,"Randomization failure!!");
                                   `svt_xvm_send(master_xact);
                                   master_xact.wait_for_transaction_end();
                                   foreach(master_xact.data[index]) begin
                                       for(int data_bit=0; data_bit<port_cfg.data_width;data_bit=data_bit+1) begin
                                           data_in[index*port_cfg.data_width + data_bit] = master_xact.data[index][data_bit];
                                       end
                                   end
                                   wait_for_active_xacts_to_end();
                                   get_response(rsp);
                                   `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DII[%0d][IG-%0d] AXI Read Non-Coherent Addr=0x%x, data_in= 0x%x, width=%0d len=%0d Critical DW=%0d", portid,all_dii,all_dii_in_ig,non_coh_addr, data_in, width,len,crit_dw), UVM_LOW)

                                   test_arg_inject_slv_error = addrMgrConst::general_global_var["slv_error_injected"];
                                   if(test_arg_inject_slv_error) begin
                                      foreach(master_xact.rresp[index]) begin
                                        if(master_xact.rresp[index] inside {svt_axi_transaction::SLVERR, svt_axi_transaction::DECERR})
                                            `uvm_info(get_full_name(), $sformatf("[test_arg_inject_slv_error case] IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Non-Coherent Addr=0x%x. RRESP[%0d] inside {SLVERR, DECERR} as expected", portid,all_dii,all_dii_in_ig,non_coh_addr,index), UVM_LOW)
                                        else
                                            `uvm_error(get_full_name(), $sformatf("[test_arg_inject_slv_error case] IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Non-Coherent Addr=0x%x. RRESP[%0d]=%0s not found inside {SLVERR, DECERR} as expected", portid,all_dii,all_dii_in_ig,non_coh_addr,index,master_xact.rresp[index].name()))
                                       end
                                   end

                                 if(!test_arg_inject_slv_error)
                                   if (data_out != data_in) begin
                                     if(!bypass_data_in_data_out_checks) 
                                         `uvm_error(get_full_name, $sformatf("IOAIU-%0d DII [%0d][IG-%0d] Data Mismatch. Address = 0x%x,len = %d , Read Data = %x, Write Data = %x, Critical DW=%0d",portid,all_dii,all_dii_in_ig, non_coh_addr, len, data_in,data_out,crit_dw)) 
                                     else
                                         `uvm_info(get_full_name, $sformatf("IOAIU-%0d DII [%0d][IG-%0d] Data Mismatch. Address = 0x%x,len = %d , Read Data = %x, Write Data = %x, Critical DW=%0d",portid,all_dii,all_dii_in_ig, non_coh_addr, len, data_in,data_out,crit_dw), UVM_LOW) 
                                   end
                                   else
                                     `uvm_info(get_full_name, $sformatf("IOAIU-%0d DII [%0d][IG-%0d] Data Write-Read Test Match. Address = 0x%x,len = %d , Read Data = %x, Write Data = %x, Critical DW=%0d",portid,all_dii,all_dii_in_ig, non_coh_addr, len, data_in,data_out,crit_dw), UVM_LOW) 
 
                                   if(test_arg_inject_slv_error) begin
                                       addrMgrConst::general_global_var["inject_slv_error"] = 0;
                                       addrMgrConst::general_global_var["slv_error_injected"] = 0;
                                   end
                               end : looping_for_sequence_length
                           //end : coh_regions
                       end : looping_for_each_dii_in_ig
                   end : k_directed_test_wr_rd_to_all_dii
               end : looping_for_each_dii
           end : looping_for_each_len
       end : looping_for_each_critical_DW

       for(int crit_dw=0;crit_dw<8;crit_dw=crit_dw+1) begin : looping_for_each_critical_DW
           for(int len = 63; len < ((port_cfg.data_width==256)?128:64); len=len+64) begin : looping_for_each_len // Creating 2048 or 4096 bytes burst for IOAIUp
               for(int all_dmi=0;all_dmi<(use_single_mem_region_in_test ? 1 :all_dmi_start_addr.size());all_dmi=all_dmi+1) begin : looping_for_each_dmi
                   if($test$plusargs("k_owo_directed_test_2k_4k_wr_rd_to_all_dmi")) begin : k_owo_directed_test_2k_4k_wr_rd_to_all_dmi
                       for(int all_dmi_in_ig=0;all_dmi_in_ig<(use_single_mem_region_in_test ? 1 :all_dmi_start_addr[all_dmi].size());all_dmi_in_ig=all_dmi_in_ig+1) begin : looping_for_each_dmi_in_ig
                       int temp_len=0;
                       int total_axi_data_bytes=0;
                           //if(all_dmi_nc[all_dmi][all_dmi_in_ig]==0) begin : coh_regions
                               for(int i = 0; i < sequence_length; i++) begin : looping_for_sequence_length
                                   test_arg_inject_slv_error = 0;
                                   if($test$plusargs("test_arg_inject_slv_error")) begin
                                       randcase
                                       90:test_arg_inject_slv_error = 1;
                                       10:test_arg_inject_slv_error = 0;
                                       endcase
                                   end
                                   if(test_arg_inject_slv_error)
                                       addrMgrConst::general_global_var["inject_slv_error"] = 1;
                                   non_coh_addr = all_dmi_start_addr[all_dmi][all_dmi_in_ig] + (i*4096);
                                   non_coh_addr[11:0] = 12'h0; // 4k aligned
                                   non_coh_addr[5:3] = crit_dw;
                                   temp_len = len+1;
                                   total_axi_data_bytes= non_coh_addr[5:0] + ((temp_len) * (port_cfg.data_width/8));
                                   if(total_axi_data_bytes>4096) begin
                                       do begin
                                           temp_len = temp_len - 1;
                                           total_axi_data_bytes= non_coh_addr[5:0] + ((temp_len) * (port_cfg.data_width/8));
                                       end
                                       while(total_axi_data_bytes>4096);
                                   end
                                   foreach(data_in_a[index]) begin
                                       data_in_a[index] = 0;
                                       data_out_a[index] = 0;
                                   end

                                   /********** WRITE ***********/
                                   `svt_xvm_create(master_xact);
                                   master_xact.port_cfg = port_cfg;
                                   master_xact.port_id = port_cfg.port_id;
                                   master_xact.reasonable_readonce_writeunique_burst_length.constraint_mode(0);
                                   rand_success = master_xact.randomize() with
                                   {
                                       //coherent_xact_type == svt_axi_transaction::WRITENOSNOOP;
                                       xact_type == svt_axi_transaction::WRITE;
                                       addr == local::non_coh_addr;
                                       burst_length == (local::temp_len);
                                       burst_type == svt_axi_transaction::INCR;
                                       burst_size == local::log_base_2_data_width_in_bytes;
                                       foreach (wstrb[index]) {
                                           wstrb[index] == ((1 << (1 << burst_size)) - 1);
                                       }
                                       prot_type inside {svt_axi_transaction::DATA_SECURE_NORMAL,svt_axi_transaction::DATA_SECURE_PRIVILEGED};
                                   };
                                   if(!rand_success) 
                                       `uvm_error(get_full_name,"Randomization failure!!");
                                   `svt_xvm_send(master_xact);
                                   t_prot_type = master_xact.prot_type;
                                   t_awid = master_xact.id;

                                   if(back_to_back_writes_and_then_read==1) begin : _back_to_back_writes_and_then_read
                                       `svt_xvm_create(master_xact1);
                                       master_xact1.port_cfg = port_cfg;
                                       master_xact1.port_id = port_cfg.port_id;
                                       master_xact1.reasonable_readonce_writeunique_burst_length.constraint_mode(0);
                                       rand_success = master_xact1.randomize() with
                                       {
                                           //coherent_xact_type == svt_axi_transaction::WRITENOSNOOP;
                                           xact_type == svt_axi_transaction::WRITE;
                                           prot_type == local::t_prot_type;
                                           id == local::t_awid;
                                           addr == local::non_coh_addr;
                                           burst_length == (local::temp_len);
                                           burst_type == svt_axi_transaction::INCR;
                                           burst_size == local::log_base_2_data_width_in_bytes;
                                           foreach (wstrb[index]) {
                                               wstrb[index] == ((1 << (1 << burst_size)) - 1);
                                           }
                                       };
                                       if(!rand_success) 
                                           `uvm_error(get_full_name,"Randomization failure!!");
                                       `svt_xvm_send(master_xact1);
                                   end : _back_to_back_writes_and_then_read

                                   data_index_cacheline_size = 0;
                                   data_out_str = "";
                                   if(back_to_back_writes_and_then_read==1) begin : __back_to_back_writes_and_then_read
                                       foreach(master_xact1.data[index]) begin
                                           for(int data_bit=0; data_bit<port_cfg.data_width;data_bit=data_bit+1) begin
                                               data_out_a[data_index_cacheline_size][(index%((cacheline_size_in_bytes*8)/port_cfg.data_width))*port_cfg.data_width + data_bit] = master_xact1.data[index][data_bit];
                                           end
                                           //data_out_str = ((index%((cacheline_size_in_bytes*8)/port_cfg.data_width))==0)?data_out_str:$sformatf("%0s_%0h",data_out_str,data_out_a[data_index_cacheline_size]);
                                           data_index_cacheline_size = ((index%((cacheline_size_in_bytes*8)/port_cfg.data_width))==0)?data_index_cacheline_size:(data_index_cacheline_size+1);
                                       end
                                       fork
                                       master_xact.wait_for_transaction_end();
                                       master_xact1.wait_for_transaction_end();
                                       join
                                       foreach(data_out_a[index]) begin
                                           data_out_str= $sformatf("%0s{%0d:0x%0h}",data_out_str,index,data_out_a[index]);
                                       end
                                       get_response(rsp);
                                       `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] Sent 2nd AXI Write(Back to Back) Non-Coherent Addr=0x%x, data_out = 0x%0s, width=%0d len=%0d Critical DW=%0d", portid,all_dmi,all_dmi_in_ig,non_coh_addr, data_out_str, width,temp_len,crit_dw), UVM_LOW)
                                       //t_prot_type = master_xact1.prot_type;
                                   end : __back_to_back_writes_and_then_read
                                   else begin : else_back_to_back_writes_and_then_read
                                       foreach(master_xact.data[index]) begin
                                           for(int data_bit=0; data_bit<port_cfg.data_width;data_bit=data_bit+1) begin
                                               data_out_a[data_index_cacheline_size][(index%((cacheline_size_in_bytes*8)/port_cfg.data_width))*port_cfg.data_width + data_bit] = master_xact.data[index][data_bit];
                                           end
                                           //data_out_str = ((index%((cacheline_size_in_bytes*8)/port_cfg.data_width))==0)?data_out_str:$sformatf("%0s_%0h",data_out_str,data_out_a[data_index_cacheline_size]);
                                           data_index_cacheline_size = ((index%((cacheline_size_in_bytes*8)/port_cfg.data_width))==0)?data_index_cacheline_size:(data_index_cacheline_size+1);
                                       end
                                       master_xact.wait_for_transaction_end();
                                       foreach(data_out_a[index]) begin
                                           data_out_str= $sformatf("%0s{%0d:0x%0h}",data_out_str,index,data_out_a[index]);
                                       end
                                       `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Non-Coherent Addr=0x%x, data_out = 0x%0s, width=%0d len=%0d Critical DW=%0d", portid,all_dmi,all_dmi_in_ig,non_coh_addr, data_out_str, width,temp_len,crit_dw), UVM_LOW)
                                       //t_prot_type = master_xact.prot_type;
                                   end : else_back_to_back_writes_and_then_read
                                   get_response(rsp);
                                   test_arg_inject_slv_error = addrMgrConst::general_global_var["slv_error_injected"];
                                   if(test_arg_inject_slv_error) begin
                                      if(master_xact.bresp inside {svt_axi_transaction::SLVERR, svt_axi_transaction::DECERR})
                                          `uvm_info(get_full_name(), $sformatf("[test_arg_inject_slv_error case] IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Non-Coherent Addr=0x%x. BRESP inside {SLVERR, DECERR} as expected", portid,all_dmi,all_dmi_in_ig,non_coh_addr), UVM_LOW)
                                      else
                                          `uvm_error(get_full_name(), $sformatf("[test_arg_inject_slv_error case] IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Non-Coherent Addr=0x%x. BRESP=%0s not found inside {SLVERR, DECERR} as expected", portid,all_dmi,all_dmi_in_ig,non_coh_addr,master_xact.bresp.name()))
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
                                       addr == local::non_coh_addr;
                                       burst_length == (local::temp_len);
                                       burst_type == svt_axi_transaction::INCR;
                                       burst_size == local::log_base_2_data_width_in_bytes;
                                       prot_type == local::t_prot_type;
                                   };
                                   if(!rand_success) 
                                       `uvm_error(get_full_name,"Randomization failure!!");
                                   `svt_xvm_send(master_xact);
                                   master_xact.wait_for_transaction_end();
                                   data_index_cacheline_size = 0;
                                   data_in_str="";
                                   foreach(master_xact.data[index]) begin
                                       for(int data_bit=0; data_bit<port_cfg.data_width;data_bit=data_bit+1) begin
                                           data_in_a[data_index_cacheline_size][(index%((cacheline_size_in_bytes*8)/port_cfg.data_width))*port_cfg.data_width + data_bit] = master_xact.data[index][data_bit];
                                       end
                                       //data_in_str = ((index%((cacheline_size_in_bytes*8)/port_cfg.data_width))==0)?data_in_str:$sformatf("%0s_%0h",data_in_str,data_in_a[data_index_cacheline_size]);
                                       data_index_cacheline_size = ((index%((cacheline_size_in_bytes*8)/port_cfg.data_width))==0)?data_index_cacheline_size:(data_index_cacheline_size+1);
                                   end
                                   foreach(data_in_a[index]) begin
                                       data_in_str= $sformatf("%0s{%0d:0x%0h}",data_in_str,index,data_in_a[index]);
                                   end
                                   get_response(rsp);
                                   `uvm_info(get_full_name(), $sformatf("IOAIU-%0d DMI[%0d][IG-%0d] AXI Read Non-Coherent Addr=0x%x, data_in= %0s, width=%0d len=%0d Critical DW=%0d", portid,all_dmi,all_dmi_in_ig,non_coh_addr, data_in_str, width,temp_len,crit_dw), UVM_LOW)


                                   test_arg_inject_slv_error = addrMgrConst::general_global_var["slv_error_injected"];
                                   if(test_arg_inject_slv_error) begin
                                      foreach(master_xact.rresp[index]) begin
                                        if(master_xact.rresp[index] inside {svt_axi_transaction::SLVERR, svt_axi_transaction::DECERR})
                                            `uvm_info(get_full_name(), $sformatf("[test_arg_inject_slv_error case] IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Non-Coherent Addr=0x%x. RRESP[%0d] inside {SLVERR, DECERR} as expected", portid,all_dmi,all_dmi_in_ig,non_coh_addr,index), UVM_LOW)
                                        else
                                            `uvm_error(get_full_name(), $sformatf("[test_arg_inject_slv_error case] IOAIU-%0d DMI[%0d][IG-%0d] AXI Write Non-Coherent Addr=0x%x. RRESP[%0d]=%0s not found inside {SLVERR, DECERR} as expected", portid,all_dmi,all_dmi_in_ig,non_coh_addr,index,master_xact.rresp[index].name()))
                                       end
                                   end

                                   is_data_mismatch = 0;
                                   data_mismatch_str = "";
                                   foreach(data_out_a[index]) begin
                                       if (data_out_a[index] != data_in_a[index]) begin
                                           is_data_mismatch = 1;
                                           data_mismatch_str = $sformatf("%0s %0d",data_mismatch_str,index);
                                       end
                                   end

                                 if(!test_arg_inject_slv_error)
                                   if (is_data_mismatch) begin
                                     if(!bypass_data_in_data_out_checks) begin
                                         `uvm_error(get_full_name, $sformatf("IOAIU-%0d DMI [%0d][IG-%0d] Data Mismatch. Address = 0x%x,len = %d , Read Data = %x, Write Data = %x, Critical DW=%0d  Refer these cacheline data ==> %0s",portid,all_dmi,all_dmi_in_ig, non_coh_addr, temp_len, data_in_str,data_out_str,crit_dw,data_mismatch_str)) end
                                     else
                                         `uvm_info(get_full_name, $sformatf("IOAIU-%0d DMI [%0d][IG-%0d] Data Mismatch. Address = 0x%x,len = %d , Read Data = %x, Write Data = %x, Critical DW=%0d",portid,all_dmi,all_dmi_in_ig, non_coh_addr, temp_len, data_in_str,data_out_str,crit_dw), UVM_LOW) 
                                   end
                                   else begin
                                     `uvm_info(get_full_name, $sformatf("IOAIU-%0d DMI [%0d][IG-%0d] Data Write-Read Test Match. Address = 0x%x,len = %d , Read Data = %x, Write Data = %x, Critical DW=%0d",portid,all_dmi,all_dmi_in_ig, non_coh_addr, temp_len, data_in_str,data_out_str,crit_dw), UVM_LOW) 
                                   end
 
                                   if(test_arg_inject_slv_error) begin
                                       addrMgrConst::general_global_var["inject_slv_error"] = 0;
                                       addrMgrConst::general_global_var["slv_error_injected"] = 0;
                                   end
                               end : looping_for_sequence_length
                           //end : coh_regions
                       end : looping_for_each_dmi_in_ig
                   end : k_owo_directed_test_2k_4k_wr_rd_to_all_dmi
               end : looping_for_each_dmi
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

endclass:io_subsys_owo_axi_directed_noncoh_wr_rd_check_seq
