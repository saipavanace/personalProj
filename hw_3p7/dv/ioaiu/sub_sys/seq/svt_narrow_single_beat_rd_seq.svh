//=====================================================================================================================================
// svt_sequence <-- svt_axi_master_base_sequence <-- svt_axi_seq <-- svt_narrow_single_beat_rd_seq
/* 
 *  This sequence first writes a full cacheline worth of data
 *  Read from each start_addr 0-63 - (inner loop)
 *  Size of data to be read 1B, 2B, 4B ... log2(bus_width_in_bytes) - (outer loop)
 */
//====================================================================================================================================

class svt_narrow_single_beat_rd_seq extends svt_axi_seq;
  `svt_xvm_object_utils(svt_narrow_single_beat_rd_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
 
  io_subsys_axi_master_transaction full_cacheline_init_txn, rd_txn;
  string mem_type;
  
  function new(string name = "svt_narrow_single_beat_rd_seq");
    super.new(name);
  endfunction: new

  virtual task pre_body();
    super.pre_body();
  endtask:pre_body;

  virtual task body();
    bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] wr_addr;
    int idx = -1;
    int num_beats;

    `uvm_info(get_full_name(), $psprintf("Entered body ..."), UVM_LOW)
    if(!$value$plusargs("mem_type=%0s",mem_type))begin
      mem_type = "";
    end
    if ($test$plusargs("coh_dmi")) begin
      idx = $urandom_range(0, cfg.innershareable_start_addr.size()-1);
      wr_addr = cfg.innershareable_start_addr[idx] + 64*(cfg.port_id + 1); //to make sure different addresses running on each port
    end else begin
      foreach (cfg.nonshareable_start_addr[i]) begin 
        if ($test$plusargs("dii_target") && addrMgrConst::is_dii_addr(cfg.nonshareable_start_addr[i])) begin 
          idx = i;
          break;
        end else if ($test$plusargs("noncoh_dmi") && addrMgrConst::is_dmi_addr(cfg.nonshareable_start_addr[i])) begin
          idx = i;
          break;
        end
      end
      wr_addr = cfg.nonshareable_start_addr[idx] + 64*(cfg.port_id + 1); //to make sure different addresses running on each port
    end
    if (idx == -1) begin
      `uvm_error(get_full_name(), $psprintf("address-region specified not found ..."))
    end
    wr_addr[5:0] = 0;
    if(core_id >= 0)begin
    wr_addr = addrMgrConst::update_addr_for_core(wr_addr,funitid, core_id); 
    end
    num_beats = 64 / (cfg.data_width/8);
    `svt_xvm_do_with(full_cacheline_init_txn,
     {
       if(port_cfg.axi_interface_type inside{ svt_axi_port_configuration::AXI_ACE,svt_axi_port_configuration :: ACE_LITE} ){
       xact_type ==COHERENT;
       if((addrMgrConst::is_dce_addr(wr_addr)))
       coherent_xact_type == svt_axi_transaction::WRITEUNIQUE;
       else
       coherent_xact_type == svt_axi_transaction::WRITENOSNOOP;
       }
       else{
       xact_type == svt_axi_transaction::WRITE;
       }
       addr == wr_addr;
       burst_size == $clog2(cfg.data_width/8);
       burst_length == num_beats;
       burst_type == svt_axi_transaction::INCR;
       if (addrMgrConst::is_dii_addr(wr_addr) && mem_type=="dev") {
       cache_type ==0; //non-bufferable writes
       }else if(addrMgrConst::is_dii_addr(wr_addr) && mem_type=="nor"){
       cache_type ==2;
       }else if(addrMgrConst::is_dii_addr(wr_addr)){
       cache_type inside{0,2};
       }
       else{
       cache_type == 2; //non-bufferable writes
        }
       foreach(wstrb[index]){
          wstrb[index]==(1<<(1<<(burst_size)))-1;
       }
       if (addrMgrConst::is_dce_addr(wr_addr)) {
          local_axi4_addr_region_pick_ctl == 1;
       } else {
          local_axi4_addr_region_pick_ctl == 0;
       }
     })
    full_cacheline_init_txn.wait_for_transaction_end();
    `uvm_info(get_full_name(), $sformatf("full cacheline write to addr:0x%0h ns:%0b is completed ...", full_cacheline_init_txn.addr, full_cacheline_init_txn.prot_type[1]), UVM_LOW)

	  for (int i = 0; i <= $clog2(cfg.data_width/8); i++) begin
	    for (int j = 0; j < 64; j++) begin
               if(addrMgrConst::is_dce_addr(wr_addr) && (nativeif == "ace" || nativeif == "ace5"))begin                
                if(!(((wr_addr[addrMgrConst::SYS_wSysCacheline-1:0]+j) + ((1) * (2**i)))<=64))begin
                  continue;
                end
              end
      `svt_xvm_do_with(rd_txn,
       {
         if(port_cfg.axi_interface_type inside{ svt_axi_port_configuration::AXI_ACE,svt_axi_port_configuration :: ACE_LITE} ){
         xact_type ==COHERENT;
         if((addrMgrConst::is_dce_addr(wr_addr)))
         coherent_xact_type == svt_axi_transaction::READONCE;
         else
         coherent_xact_type == svt_axi_transaction::READNOSNOOP;
         }
         else{
         xact_type == svt_axi_transaction::READ;
         }
         addr == wr_addr + j;
         prot_type[1] == full_cacheline_init_txn.prot_type[1];
         burst_size == i;
         burst_length == 1;
         burst_type == svt_axi_transaction::INCR;
         if (addrMgrConst::is_dii_addr(wr_addr+j) && mem_type=="dev") {
         cache_type[1] ==0; 
         }else if(addrMgrConst::is_dii_addr(wr_addr+j) && mem_type=="nor"){
         cache_type[1] ==1;
         }
         if (addrMgrConst::is_dce_addr(wr_addr)) {
            local_axi4_addr_region_pick_ctl == 1;
         } else {
            local_axi4_addr_region_pick_ctl == 0;
         }
       })
       rd_txn.wait_for_transaction_end();
       get_response(rsp, rd_txn.get_transaction_id());
       `uvm_info(get_full_name(), $sformatf("rd to addr:0x%0h ns:%0b len:%0d size:%0d is completed ...", rd_txn.addr, rd_txn.prot_type[1], rd_txn.burst_length, rd_txn.burst_size), UVM_LOW)
       //data_integrity_check(rd_txn, full_cacheline_init_txn); //needs size and len to be same, hence cannot use. 
      end
    end
    `uvm_info(get_full_name(), $psprintf("Exit body ..."), UVM_LOW)
  endtask:body 

endclass:svt_narrow_single_beat_rd_seq
