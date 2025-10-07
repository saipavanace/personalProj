class svt_rd_after_wr_wrap_seq extends svt_axi_seq;
  `svt_xvm_object_utils(svt_rd_after_wr_wrap_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
 
  io_subsys_axi_master_transaction full_cacheline_init_txn,wr_txn, rd_txn,full_cacheline_rd_txn;
  string mem_type;
	static bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] prev_core_addr[$];
	typedef bit[`SVT_AXI_MAX_ADDR_WIDTH-1:0] narrow_addr_check[$];
	static narrow_addr_check narrow_addr_chk[int];
  int idx = -1;
  
  function new(string name = "svt_rd_after_wr_wrap_seq");
    super.new(name);
  endfunction: new

  virtual task pre_body();
    super.pre_body();
  endtask:pre_body;

  virtual task body();
    bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] wr_addr,temp_wr_addr,wr_addr_mask;
    bit [`SVT_AXI_MAX_DATA_WIDTH-1:0] wr_data[$];
    int num_beats;
    string port_name ; 
    int mp_aiu_pri_bitsq [$];
		int index[$];
		int count =0 ;

    `uvm_info(get_full_name(), $psprintf("Entered body ..."), UVM_LOW)
    if(addrMgrConst::io_subsys_owo_en[cfg.port_id] != 1)begin
    if(!$value$plusargs("mem_type=%0s",mem_type))begin
      mem_type = "";
    end
		do begin
    index = {};
    wr_addr = get_address_for_core(count, core_id, funitid); 
    index = prev_core_addr.find_index() with (item[`SVT_AXI_MAX_ADDR_WIDTH-1:addrMgrConst::SYS_wSysCacheline] == wr_addr[`SVT_AXI_MAX_ADDR_WIDTH-1:addrMgrConst::SYS_wSysCacheline]);
    count++;
end while ((index.size() != 0) && (count != 1000));
		if(count == 1000)
		`uvm_error(get_full_name(),$sformatf("Repeated address generated 100 times"))
		//prev_core_addr.push_back(wr_addr);
    if (idx == -1) begin
      `uvm_error(get_full_name(), $psprintf("address-region specified not found ..."))
    end
		if(core_id>=0)begin
		  core_bits_for_master(funitid,mp_aiu_pri_bitsq);
      wr_addr_mask = (1<<mp_aiu_pri_bitsq[0])-1;
		end
    `uvm_info(get_type_name(),$sformatf("start address of cacheline:0x%0h",wr_addr),UVM_LOW)
    num_beats = 64 / (cfg.data_width/8);
    for(int i=0;i<40;i++)begin
		 temp_wr_addr = wr_addr - (15*64) + (i*64);
		 if (core_id >= 0 && (core_id != addrMgrConst::get_addr_core_id(temp_wr_addr,funitid))) begin
        break;
     end 
		 index = {};
		 index = prev_core_addr.find_first_index()with(item[`SVT_AXI_MAX_ADDR_WIDTH-1:addrMgrConst::SYS_wSysCacheline] == temp_wr_addr[`SVT_AXI_MAX_ADDR_WIDTH-1:addrMgrConst::SYS_wSysCacheline]);
		 if(index.size() != 0)begin
		   continue;
		 end
		 prev_core_addr.push_back(temp_wr_addr);
    `uvm_info(get_type_name(),$sformatf("address of cacheline:0x%0h",temp_wr_addr),UVM_LOW)
    `svt_xvm_do_with(full_cacheline_init_txn,
     {
       if(port_cfg.axi_interface_type inside{ svt_axi_port_configuration::AXI_ACE,svt_axi_port_configuration :: ACE_LITE} ){
       xact_type ==COHERENT;
         is_unique == 0;
       if((addrMgrConst::is_dce_addr(wr_addr))){
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
          data[index] == '1;
       }
       if (addrMgrConst::is_dce_addr(wr_addr)) {
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
              if(addrMgrConst::is_dce_addr(wr_addr) && (nativeif == "ace" || nativeif == "ace5"))begin                
                if(!(((wr_addr[addrMgrConst::SYS_wSysCacheline-1:0]+j) + (i * (cfg.data_width/8)))<=64))begin
                  continue;
                end
              end
        if(((wr_addr+j) % (cfg.data_width/8) != 0))begin
           continue;
        end
              for(int k =0; k<i;k++)begin
							  for(int h=0; h<(cfg.data_width/8);h++)begin
									wr_data[k][h*32 +:32] = $urandom();
								end
              end
			temp_wr_addr = wr_addr + j;
			if (core_id >= 0 && ((core_id != addrMgrConst::get_addr_core_id(temp_wr_addr,funitid)) || ((((temp_wr_addr & wr_addr_mask)/(cfg.data_width/8))*(cfg.data_width/8)) + (i*(cfg.data_width/8)) >= (1 << mp_aiu_pri_bitsq[0])))) begin
			  `uvm_info(get_full_name(),$sformatf("unsupportable combinationtemp_wr_addr:%0h,wr_addr_mask:%0h,cfg.data_width:%0d,i:%0d,mp_aiu_pri_bitsq[0]:%0d ",temp_wr_addr,wr_addr_mask,cfg.data_width,i,mp_aiu_pri_bitsq[0]),UVM_LOW)
        break;
     end
			narrow_addr_chk[cfg.port_id].push_back(temp_wr_addr);
			foreach(narrow_addr_chk[k])begin
			if(k != cfg.port_id)begin
			if(temp_wr_addr inside {narrow_addr_chk[k]})
			  `uvm_error(get_full_name(),$sformatf("Master generate the repeated address:0x:%0h",temp_wr_addr))
			end
			end
      `svt_xvm_do_with(wr_txn,
       {
         if(port_cfg.axi_interface_type inside{ svt_axi_port_configuration::AXI_ACE,svt_axi_port_configuration :: ACE_LITE} ){
         xact_type ==COHERENT;
           is_unique == 0;
         if((addrMgrConst::is_dce_addr(wr_addr)))
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
         if (addrMgrConst::is_dii_addr(wr_addr+j) && mem_type=="dev") {
          cache_type ==0; //non-bufferable writes
         }else if(addrMgrConst::is_dii_addr(wr_addr+j) && mem_type=="nor"){
          cache_type ==2;
         }else if(addrMgrConst::is_dii_addr(wr_addr)){
          cache_type == full_cacheline_init_txn.cache_type;
         }
         else{
         cache_type == 2; //non-bufferable writes
         }
         if (addrMgrConst::is_dce_addr(wr_addr)) {
            local_axi4_addr_region_pick_ctl == 1;
         } else {
            local_axi4_addr_region_pick_ctl == 0;
         }
         foreach(wstrb[index]){
          wstrb[index]==(1<<(1<<(burst_size)))-1;
        }
        foreach(data[index]){
          data[index] == wr_data[index];
        }
       })
       wr_txn.wait_for_transaction_end();
       `uvm_info(get_full_name(), $sformatf("narrow single beat wr to addr:0x%0h ns:%0b len:%0d size:%0d is completed ...", wr_txn.addr, wr_txn.prot_type[1], wr_txn.burst_length, wr_txn.burst_size), UVM_LOW)

       `svt_xvm_do_with(rd_txn,
       {
         if(port_cfg.axi_interface_type inside{ svt_axi_port_configuration::AXI_ACE,svt_axi_port_configuration :: ACE_LITE} ){
         xact_type ==COHERENT;
           is_unique == 0;
         if((addrMgrConst::is_dce_addr(wr_addr)))
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
         if (addrMgrConst::is_dii_addr(wr_addr+j) && mem_type=="dev") {
         cache_type[1] ==0; 
         }else if(addrMgrConst::is_dii_addr(wr_addr+j) && mem_type=="nor"){
         cache_type[1] ==1;
         }
         else if(addrMgrConst::is_dii_addr(wr_addr+j)){
          cache_type == full_cacheline_init_txn.cache_type;
         }
         if (addrMgrConst::is_dce_addr(wr_addr)) {
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
         if((addrMgrConst::is_dce_addr(wr_addr)))
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
         if (addrMgrConst::is_dii_addr(wr_addr) && mem_type=="dev") {
         cache_type[1] ==0; 
         }else if(addrMgrConst::is_dii_addr(wr_addr) && mem_type=="nor"){
         cache_type[1] ==1;
         }
         if (addrMgrConst::is_dce_addr(wr_addr)) {
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
 function automatic bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] get_address_for_core(
    input logic [63:0] count, 
    input int core_id,
    input int funitid
);
    
    bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] wr_addr;
    
    // Check if the coh_dmi plusarg is set
    if ($test$plusargs("coh_dmi")) begin
        idx = $urandom_range(0, cfg.innershareable_start_addr.size() - 1);
        wr_addr = (cfg.innershareable_start_addr[idx]+(64*20)) + 64 * ((cfg.port_id * 50) + 1) + (64 * count);
    end else begin
        // Iterate through nonshareable addresses
        foreach (cfg.nonshareable_start_addr[i]) begin
            // Check for specific plusargs and address types
            if ($test$plusargs("dii_target") && addrMgrConst::is_dii_addr(cfg.nonshareable_start_addr[i])) begin
                idx = i;
                break;
            end else if ($test$plusargs("noncoh_dmi") && addrMgrConst::is_dmi_addr(cfg.nonshareable_start_addr[i])) begin
                idx = i;
                break;
            end
        end
        wr_addr = (cfg.nonshareable_start_addr[idx] +(64*20)) + 64 * ((cfg.port_id * 30) + 1) + (64 * count);
    end

    // Clear the lower 6 bits of the address (cacheline alignment)
    wr_addr[5:0] = 0;
    
    // Update the address based on core ID if applicable
    if (core_id >= 0) begin
        wr_addr = addrMgrConst::update_addr_for_core(wr_addr, funitid, core_id);
    end
    
    return wr_addr;

endfunction : get_address_for_core
function void core_bits_for_master(input int agentid, output int primary_bits[$]);
	primary_bits = addrMgrConst::mp_aiu_intv_bits[agentid].pri_bits;
  if (primary_bits.size()) primary_bits.sort();	
endfunction
endclass:svt_rd_after_wr_wrap_seq

