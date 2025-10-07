class svt_rd_after_wr_wrap_seq extends svt_axi_seq;
  `svt_xvm_object_utils(svt_rd_after_wr_wrap_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
 
  io_subsys_axi_master_transaction full_cacheline_init_txn,wr_txn, rd_txn,full_cacheline_rd_txn;
  string mem_type;
  
  function new(string name = "svt_rd_after_wr_wrap_seq");
    super.new(name);
  endfunction: new

  virtual task pre_body();
    super.pre_body();
  endtask:pre_body;

  virtual task body();
    bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] wr_addr,temp_wr_addr;
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] wr_data;
    int idx = -1;
    int num_beats;
    string port_name ; 
    int mp_aiu_pri_bitsq [$];

    `uvm_info(get_full_name(), $psprintf("Entered body ..."), UVM_LOW)
    if(ncoreConfigInfo::io_subsys_owo_en[cfg.port_id] != 1)begin
    if(!$value$plusargs("mem_type=%0s",mem_type))begin
      mem_type = "";
    end
    if ($test$plusargs("coh_dmi")) begin
      idx = $urandom_range(0, cfg.innershareable_start_addr.size()-1);
      wr_addr = cfg.innershareable_start_addr[idx] + 64*((cfg.port_id*20) + 1); //to make sure different addresses running on each port
    end else begin
      foreach (cfg.nonshareable_start_addr[i]) begin 
        if ($test$plusargs("dii_target") && ncoreConfigInfo::is_dii_addr(cfg.nonshareable_start_addr[i])) begin 
          idx = i;
          break;
        end else if ($test$plusargs("noncoh_dmi") && ncoreConfigInfo::is_dmi_addr(cfg.nonshareable_start_addr[i])) begin
          idx = i;
          break;
        end
      end
      wr_addr = cfg.nonshareable_start_addr[idx] + 64*((cfg.port_id*20) + 1); //to make sure different addresses running on each port
    end
    if (idx == -1) begin
      `uvm_error(get_full_name(), $psprintf("address-region specified not found ..."))
    end
    wr_addr[5:0] = 0;
    if(core_id >= 0)begin
    wr_addr = ncoreConfigInfo::update_addr_for_core(wr_addr,funitid, core_id); 
    end
    `uvm_info(get_type_name(),$sformatf("start address of cacheline:0x%0h",wr_addr),UVM_LOW)
    num_beats = 64 / (cfg.data_width/8);
    for(int i=0;i<20;i++)begin
    `svt_xvm_do_with(full_cacheline_init_txn,
     {
       if(port_cfg.axi_interface_type inside{ svt_axi_port_configuration::AXI_ACE,svt_axi_port_configuration :: ACE_LITE} ){
       xact_type ==COHERENT;
         is_unique == 0;
       if((ncoreConfigInfo::is_dce_addr(wr_addr))){
       coherent_xact_type == svt_axi_transaction::WRITEUNIQUE;
         domain_type inside {1,2};
         }
       else {
       coherent_xact_type == svt_axi_transaction::WRITENOSNOOP;
         domain_type inside {0,3};
         }
       }
       else{
       xact_type == svt_axi_transaction::WRITE;
       }
       addr == wr_addr+(i*64);
       burst_size == $clog2(cfg.data_width/8);
       burst_length == num_beats;
       burst_type == svt_axi_transaction::WRAP;
       if (ncoreConfigInfo::is_dii_addr(wr_addr) && mem_type=="dev") {
       cache_type ==0; //non-bufferable writes
       }else if(ncoreConfigInfo::is_dii_addr(wr_addr) && mem_type=="nor"){
       cache_type ==2;
       }else if(ncoreConfigInfo::is_dii_addr(wr_addr)){
       cache_type inside{0,2};
       }
       else{
       cache_type == 2; //non-bufferable writes
        }
       foreach(wstrb[index]){
          wstrb[index]==(1<<(1<<(burst_size)))-1;
          data[index] == '1;
       }
       if (ncoreConfigInfo::is_dce_addr(wr_addr)) {
          local_axi4_addr_region_pick_ctl == 1;
       } else {
          local_axi4_addr_region_pick_ctl == 0;
       }
     })
    full_cacheline_init_txn.wait_for_transaction_end();
    `uvm_info(get_full_name(), $sformatf("full cacheline data_width=%0d data=%p and strb=%p",cfg.data_width,full_cacheline_init_txn.data,full_cacheline_init_txn.wstrb), UVM_LOW)
    `uvm_info(get_full_name(), $sformatf("full cacheline write to addr:0x%0h ns:%0b is completed ...",full_cacheline_init_txn.addr, full_cacheline_init_txn.prot_type[1]), UVM_LOW)
end
	  for (int i = 2; i <= 16 ; i=(i*2)) begin
	    for (int j = 0; j < 64; j++) begin
              if(ncoreConfigInfo::is_dce_addr(wr_addr) && (nativeif == "ace" || nativeif == "ace5"))begin                
                if(!(((wr_addr[ncoreConfigInfo::SYS_wSysCacheline-1:0]+j) + (i * (cfg.data_width/8)))<=64))begin
                  continue;
                end
              end
        if(((wr_addr+j) % (cfg.data_width/8) != 0))begin
           continue;
        end
              for(int k =0; k<=((8<<i)/64);k++)begin
                wr_data[k*32 +:32] = $urandom();
              end
      `svt_xvm_do_with(wr_txn,
       {
         if(port_cfg.axi_interface_type inside{ svt_axi_port_configuration::AXI_ACE,svt_axi_port_configuration :: ACE_LITE} ){
         xact_type ==COHERENT;
           is_unique == 0;
         if((ncoreConfigInfo::is_dce_addr(wr_addr)))
         coherent_xact_type == svt_axi_transaction::WRITEUNIQUE;
         else
         coherent_xact_type == svt_axi_transaction::WRITENOSNOOP;
         }
         else{
         xact_type == svt_axi_transaction::WRITE;
         }
         addr == wr_addr + j;
         domain_type == full_cacheline_init_txn.domain_type;
         prot_type[1] == full_cacheline_init_txn.prot_type[1];
         qos ==full_cacheline_init_txn.qos;
         burst_length == i;
         burst_type == svt_axi_transaction::WRAP;
         if (ncoreConfigInfo::is_dii_addr(wr_addr+j) && mem_type=="dev") {
          cache_type ==0; //non-bufferable writes
         }else if(ncoreConfigInfo::is_dii_addr(wr_addr+j) && mem_type=="nor"){
          cache_type ==2;
         }else if(ncoreConfigInfo::is_dii_addr(wr_addr)){
          cache_type == full_cacheline_init_txn.cache_type;
         }
         else{
         cache_type == 2; //non-bufferable writes
         }
         if (ncoreConfigInfo::is_dce_addr(wr_addr)) {
            local_axi4_addr_region_pick_ctl == 1;
         } else {
            local_axi4_addr_region_pick_ctl == 0;
         }
         foreach(wstrb[index]){
          wstrb[index]==(1<<(1<<(burst_size)))-1;
        }
        foreach(data[index]){
          data[index] == wr_data;
        }
       })
       wr_txn.wait_for_transaction_end();
       `uvm_info(get_full_name(), $sformatf("narrow single beat wr to addr:0x%0h ns:%0b len:%0d size:%0d is completed ...", wr_txn.addr, wr_txn.prot_type[1], wr_txn.burst_length, wr_txn.burst_size), UVM_LOW)

       `svt_xvm_do_with(rd_txn,
       {
         if(port_cfg.axi_interface_type inside{ svt_axi_port_configuration::AXI_ACE,svt_axi_port_configuration :: ACE_LITE} ){
         xact_type ==COHERENT;
           is_unique == 0;
         if((ncoreConfigInfo::is_dce_addr(wr_addr)))
         coherent_xact_type == svt_axi_transaction::READONCE;
         else
         coherent_xact_type == svt_axi_transaction::READNOSNOOP;
         }
         else{
         xact_type == svt_axi_transaction::READ;
         }
         addr == wr_addr + j;
         domain_type == full_cacheline_init_txn.domain_type;
         prot_type[1] == full_cacheline_init_txn.prot_type[1];
         qos ==full_cacheline_init_txn.qos; 
         burst_length == i;
         burst_type == svt_axi_transaction::WRAP;
         if (ncoreConfigInfo::is_dii_addr(wr_addr+j) && mem_type=="dev") {
         cache_type[1] ==0; 
         }else if(ncoreConfigInfo::is_dii_addr(wr_addr+j) && mem_type=="nor"){
         cache_type[1] ==1;
         }
         else if(ncoreConfigInfo::is_dii_addr(wr_addr+j)){
          cache_type == full_cacheline_init_txn.cache_type;
         }
         if (ncoreConfigInfo::is_dce_addr(wr_addr)) {
            local_axi4_addr_region_pick_ctl == 1;
         } else {
            local_axi4_addr_region_pick_ctl == 0;
         }
       })
       rd_txn.wait_for_transaction_end();
       get_response(rsp, rd_txn.get_transaction_id());
       `uvm_info(get_full_name(), $sformatf("narrow single beat rd to addr:0x%0h ns:%0b len:%0d size:%0d is completed ...", rd_txn.addr, rd_txn.prot_type[1], rd_txn.burst_length, rd_txn.burst_size), UVM_LOW)
       data_integrity_check(rd_txn,wr_txn); //needs size and len to be same, hence cannot use.
    
      end
    end

    `svt_xvm_do_with(full_cacheline_rd_txn,
       {
         if(port_cfg.axi_interface_type inside{ svt_axi_port_configuration::AXI_ACE,svt_axi_port_configuration :: ACE_LITE} ){
         xact_type ==COHERENT;
         if((ncoreConfigInfo::is_dce_addr(wr_addr)))
         coherent_xact_type == svt_axi_transaction::READONCE;
         else
         coherent_xact_type == svt_axi_transaction::READNOSNOOP;
         }
         else{
         xact_type == svt_axi_transaction::READ;
         }
         addr == wr_addr;
         domain_type == full_cacheline_init_txn.domain_type;
         qos ==full_cacheline_init_txn.qos;
         prot_type[1] == full_cacheline_init_txn.prot_type[1];
         burst_size == $clog2(cfg.data_width/8);
         burst_length == num_beats;
         burst_type == svt_axi_transaction::WRAP;
         if (ncoreConfigInfo::is_dii_addr(wr_addr) && mem_type=="dev") {
         cache_type[1] ==0; 
         }else if(ncoreConfigInfo::is_dii_addr(wr_addr) && mem_type=="nor"){
         cache_type[1] ==1;
         }
         if (ncoreConfigInfo::is_dce_addr(wr_addr)) {
            local_axi4_addr_region_pick_ctl == 1;
         } else {
            local_axi4_addr_region_pick_ctl == 0;
         }
       })
       full_cacheline_rd_txn.wait_for_transaction_end();
       get_response(rsp, full_cacheline_rd_txn.get_transaction_id());
       `uvm_info(get_full_name(), $sformatf("full_cacheline rd to addr:0x%0h ns:%0b len:%0d size:%0d is completed ...", full_cacheline_rd_txn.addr, full_cacheline_rd_txn.prot_type[1], full_cacheline_rd_txn.burst_length, full_cacheline_rd_txn.burst_size), UVM_LOW)
       //data_integrity_check(full_cacheline_rd_txn,full_cacheline_init_txn);
      end
    `uvm_info(get_full_name(), $psprintf("Exit body ..."), UVM_LOW)
  endtask:body 

endclass:svt_rd_after_wr_wrap_seq

