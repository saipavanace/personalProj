//===========================================================================================================================
// base class for all axi4 and ace* sequences. 
// extracting information from io_mstr_seq_cfg and assign to sequences happens in this class
//===========================================================================================================================

class io_subsys_base_seq extends uvm_sequence;
  `svt_xvm_object_utils(io_subsys_base_seq)
  mstr_seq_cfg mstr_cfg;
  io_mstr_seq_cfg  cfg;
  string nativeif, instname;
  int core = -1;
  bit mpu = 0;
  int funitid;
  int portid, num_addr;
  int seq_id;
  int region_idx,count;
  bit[<%=obj.AiuInfo[0].wAddr%>-1:0] addr_coh,addr_noncoh;
  bit reduce_addr_area;
  bit [`SVT_AXI_MAX_ADDR_WIDTH-7:0] user_cacheline_coh_addrq[$];
  addr_trans_mgr_pkg::addr_trans_mgr  m_addr_mgr;

  bit [addr_trans_mgr_pkg::addrMgrConst::W_SEC_ADDR-1:0] all_dmi_dii_start_addr[int][$]; 
  bit [addr_trans_mgr_pkg::addrMgrConst::W_SEC_ADDR-1:0] all_dii_start_addr[int][$]; 
  bit [2:0]dii_region_rsvd; // DEV=0, NONCACHEABLE=1, CACHEABLE=2
  static bit [addr_trans_mgr_pkg::addrMgrConst::W_SEC_ADDR-1:0] all_dii_sub_region_type[int][$]; 
  static bit all_dii_sub_region_type_cfg_done;
  bit [addr_trans_mgr_pkg::addrMgrConst::W_SEC_ADDR-1:0] all_dmi_start_addr[int][$]; 
  bit all_dmi_nc[int][$]; 
  
  function new(string name = "io_subsys_base_seq");
    super.new(name);
  endfunction: new

  virtual task pre_body();
    super.pre_body();
    m_addr_mgr = addr_trans_mgr::get_instance();

    `uvm_info(get_full_name(), $psprintf("fn:pre_body Get %0s_%0s_mstr_seq_cfg_p%0d_s%0d from config_db", nativeif, instname, portid,seq_id), UVM_LOW);
    if (uvm_config_db #(mstr_seq_cfg)::get(null, get_full_name(), $sformatf("%0s_%0s_mstr_seq_cfg_p%0d_s%0d", nativeif, instname, portid,seq_id), mstr_cfg) == 0)
      `uvm_error(get_full_name(), $psprintf("%0s_%0s_mstr_seq_cfg_p%0d_s%0d not found in config_db", nativeif, instname, portid,seq_id));

      if (!$cast(cfg, mstr_cfg)) begin
        `uvm_error(get_full_name(), $psprintf("fn:pre_body cfg cannot be cast to io_mstr_seq_cfg"));
      end else begin
        `uvm_info(get_full_name(), $psprintf("fn:pre_body io_mstr_seq_cfg- %0s", cfg.print()), UVM_LOW);
      end
      if (cfg.reduce_addr_area==1 && cfg.use_user_addrq==0) begin
          foreach(addrMgrConst::memregions_info[region]) begin
             if(cfg.start_addr inside {[addrMgrConst::memregions_info[region].start_addr:addrMgrConst::memregions_info[region].end_addr]}) begin
               region_idx = region;
               `uvm_info(get_full_name(), $psprintf("User address cfg.start_addr:0x%h from region-%0d",cfg.start_addr, region), UVM_LOW);
               break;
             end else begin
               `uvm_info(get_full_name(), $psprintf("User address cfg.start_addr:0x%h  not from region-%0d",cfg.start_addr, region), UVM_LOW);
             end
         end
         if(!cfg.end_addr inside {[addrMgrConst::memregions_info[region_idx].start_addr:addrMgrConst::memregions_info[region_idx].end_addr]}) begin
            `uvm_error("USER_ADDR_ERR",$sformatf("TB : User address cfg.end_addr %0h is wrongly configured for cfg.start_addr ",cfg.end_addr,cfg.start_addr))
         end
     end

        
  endtask:pre_body;

  virtual task body();
        
  endtask:body

 
        
endclass:io_subsys_base_seq
