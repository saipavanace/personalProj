//==============================================================================================================================
// svt_axi_ace_master_base_virtual_sequence <-- io_subsys_snps_base_vseq <-- io_subsys_snps_pcie_vseq
//==============================================================================================================================
class io_subsys_snps_pcie_vseq extends io_subsys_snps_vseq;
  `uvm_object_utils(io_subsys_snps_pcie_vseq)

  addrMgrConst::buffer_info_t buffers[];
  int producer_funitid, consumer_funitid, num_buffers, buffer_itr; 
  bit prod_cons_same_wdata = 0;
  string flag_mem, buf_mem;

  function new(string name = "io_subsys_snps_pcie_vseq");
    super.new(name);
    if (!$value$plusargs("num_buffers=%0d",num_buffers)) begin
      num_buffers = $urandom_range(3,15);
    end
    if (!$value$plusargs("buffer_itr=%0d", buffer_itr)) begin 
      buffer_itr = $urandom_range(1, 3); //no benefit going more than 3
    end
    if (!$value$plusargs("flag_mem=%0s", flag_mem)) begin
      flag_mem = "any";
    end
    if (!$value$plusargs("buf_mem=%0s", buf_mem)) begin
      buf_mem = "any";
    end


    buffers = new[num_buffers];
  endfunction

  function int calc_max_burst_len(bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] addr, int beat_bytes, output int size);
    int offset = addr % 4096;
    int avail = 4096 - offset;
    int num_full_beats = avail / beat_bytes;
    int result, idx;

    if (num_full_beats == 0) begin 
      result = 1 << $clog2(avail);
      if (result > avail)
        result = result >> 1;
      size = $clog2(result);
      return 1;
    end else begin 
      size = $clog2(beat_bytes);
      if (offset % beat_bytes == 0)
        return num_full_beats;
      else 
        return num_full_beats + 1; 
    end
  endfunction:calc_max_burst_len

  function void initialize_buffers;
    int buf_size    = num_buffers;
    int memrgn_size, idx;
    int counter = 0;
    bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] flag_addr;
    string flag_mem_q[$];
    int sel;
    bit [11:0] half_boundary_addr;
    
    `uvm_info(get_full_name(), $psprintf("buf_size:%0d memrgn_size:%0d buf_mem:%0s flag_mem:%0s", buf_size, memrgn_size, buf_mem, flag_mem), UVM_LOW);

        if (buf_mem == "coh_dmi") begin 
          memrgn_size  = addrMgrConst::dmi_memory_coh_domain_start_addr.size();
        end else if (buf_mem == "dii") begin 
          memrgn_size = addrMgrConst::dii_memory_domain_start_addr.size();
        end else if (buf_mem == "noncoh_dmi" && addrMgrConst::dmi_memory_noncoh_domain_start_addr.size() > 0) begin 
          memrgn_size  = addrMgrConst::dmi_memory_noncoh_domain_start_addr.size();
        end else begin 
          memrgn_size = addrMgrConst::memregions_info.size();
        end
          

    if (buf_size <= memrgn_size) begin
      for (int bidx = 0; bidx < buf_size; bidx++) begin
        if (buf_mem == "coh_dmi") begin 
          buffers[bidx].page_start_addr  = addrMgrConst::dmi_memory_coh_domain_start_addr[bidx];
        end else if (buf_mem == "dii") begin 
          buffers[bidx].page_start_addr  = addrMgrConst::dii_memory_domain_start_addr[bidx];
        end else if (buf_mem == "noncoh_dmi" && addrMgrConst::dmi_memory_noncoh_domain_start_addr.size() > 0) begin 
          buffers[bidx].page_start_addr  = addrMgrConst::dmi_memory_noncoh_domain_start_addr[bidx];
        end else begin 
          buffers[bidx].page_start_addr  = addrMgrConst::memregions_info[bidx].start_addr;
        end
        buffers[bidx].start_addr       = buffers[bidx].page_start_addr;

        half_boundary_addr = { $urandom_range(0, 63), 6'h00 };
        void'(std::randomize(sel) with { sel dist { 0 := 20, 1 := 40, 2 := 40 }; });      if (sel == 0)
        buffers[bidx].start_addr[11:0] =  $urandom;
        else if (sel == 1)
        buffers[bidx].start_addr[11:0] = 12'h000;
        else
        buffers[bidx].start_addr[11:0] = half_boundary_addr;
        
      end
    end
    else begin
      for (int bidx = 0; bidx < (buf_size + memrgn_size); bidx = bidx + memrgn_size) begin 
        for (int midx=0; midx < memrgn_size; midx++) begin
          `uvm_info(get_full_name(), $psprintf("bidx:%0d midx:%0d", bidx, midx), UVM_LOW);
          if (buf_mem == "coh_dmi") begin
            buffers[bidx + midx].page_start_addr  = addrMgrConst::dmi_memory_coh_domain_start_addr[midx] + (counter*(4096)); 
          end else if (buf_mem == "noncoh_dmi" && addrMgrConst::dmi_memory_noncoh_domain_start_addr.size() > 0) begin
            buffers[bidx + midx].page_start_addr  = addrMgrConst::dmi_memory_noncoh_domain_start_addr[midx] + (counter*(4096)); 
          end else if (buf_mem == "dii") begin
            buffers[bidx + midx].page_start_addr  = addrMgrConst::dii_memory_domain_start_addr[midx] + (counter*(4096)); 
          end else begin
            buffers[bidx + midx].page_start_addr  = addrMgrConst::memregions_info[midx].start_addr + (counter*(4096)); 
          end
          buffers[bidx + midx].start_addr       = buffers[bidx + midx].page_start_addr;

          half_boundary_addr = { $urandom_range(0, 63), 6'h00 };
          void'(std::randomize(sel) with { sel dist { 0 := 20, 1 := 40, 2 := 40 }; });
          if (sel == 0)
          buffers[bidx + midx].start_addr[11:0] = $urandom;
          else if (sel == 1)
          buffers[bidx + midx].start_addr[11:0] = 12'h000;
          else
          buffers[bidx + midx].start_addr[11:0] = half_boundary_addr;
          end
        counter++;
      end
    end
         
    if (flag_mem == "coh_dmi") begin
      flag_addr = addrMgrConst::dmi_memory_coh_domain_end_addr[0] - 63;
    end else if (flag_mem == "dii") begin
      flag_addr = addrMgrConst::dii_memory_domain_end_addr[0] - 63;
    end else if ((flag_mem == "noncoh_dmi") && (addrMgrConst::dmi_memory_noncoh_domain_end_addr.size() > 0)) begin
      flag_addr = addrMgrConst::dmi_memory_noncoh_domain_end_addr[0] - 63;
    end else begin
      flag_mem_q = {};
      if (addrMgrConst::dmi_memory_coh_domain_end_addr.size() > 0)
        flag_mem_q.push_back("coh_dmi");
      if (addrMgrConst::dmi_memory_noncoh_domain_end_addr.size() > 0)
        flag_mem_q.push_back("noncoh_dmi");
      if (addrMgrConst::dii_memory_domain_end_addr.size() > 0)
        flag_mem_q.push_back("dii");
      idx = $urandom_range(0, flag_mem_q.size()-1);
      `uvm_info(get_full_name(), $psprintf("Randomly selected flag_mem:%0s", flag_mem_q[idx]), UVM_LOW);
      if(flag_mem_q[idx] == "coh_dmi") begin
        flag_addr = addrMgrConst::dmi_memory_coh_domain_end_addr[0] - 63;
      end else if (flag_mem_q[idx] == "dii") begin
        flag_addr = addrMgrConst::dii_memory_domain_end_addr[0] - 63;
      end else if (flag_mem_q[idx] == "noncoh_dmi") begin
        flag_addr = addrMgrConst::dmi_memory_noncoh_domain_end_addr[0] - 63;
      end
    end 
    
    for (int bidx = 0; bidx < buf_size; bidx++) begin 
      if (bidx == 0) begin
        buffers[bidx].flag_addr = flag_addr;
      end else begin
        buffers[bidx].flag_addr = buffers[bidx-1].flag_addr + 1;
      end
      //this is max burst_length else we will violate 4KB byte boundary
      buffers[bidx].len_32B_bus = calc_max_burst_len(buffers[bidx].start_addr, 32, buffers[bidx].size_32B_bus);
      buffers[bidx].len_64B_bus = calc_max_burst_len(buffers[bidx].start_addr, 64, buffers[bidx].size_64B_bus);
    end

    `uvm_info(get_full_name(), $psprintf("fn:populate_buffer_addrq - Printing bufferq"), UVM_LOW);
    foreach(buffers[i]) begin
      `uvm_info(get_full_name(), $psprintf("Index:%0d | FlagAddr:0x%0h | PageStartAddr:0x%0h | StartAddr:0x%0h | 32B_bus --> Len:%0d Size:%0d | 64B_bus --> Len:%0d Size:%0d", i, buffers[i].flag_addr, buffers[i].page_start_addr, buffers[i].start_addr, buffers[i].len_32B_bus, buffers[i].size_32B_bus, buffers[i].len_64B_bus, buffers[i].size_64B_bus), UVM_LOW);
    end

  endfunction:initialize_buffers

  function init_producer_consumer_seq_buffers(ref addrMgrConst::buffer_info_t seq_buffers[]);
      seq_buffers = new[buffers.size()];
      for(int i=0;i<buffers.size();i=i+1) begin
          seq_buffers[i].page_start_addr  = buffers[i].page_start_addr  ;
          seq_buffers[i].start_addr       = buffers[i].start_addr       ;
          seq_buffers[i].flag_addr        = buffers[i].flag_addr;
          seq_buffers[i].len_32B_bus      = buffers[i].len_32B_bus;
          seq_buffers[i].len_64B_bus      = buffers[i].len_64B_bus;
          seq_buffers[i].size_32B_bus     = buffers[i].size_32B_bus;
          seq_buffers[i].size_64B_bus     = buffers[i].size_64B_bus;
      end
  endfunction : init_producer_consumer_seq_buffers

  function void select_producer_consumer();
    int owo_aiu_funitidq[$];
    int ace_aiu_funitidq[$];
    int any_aiu_funitidq[$];
    int match_idxq[$];
   
    foreach(addrMgrConst::io_subsys_owo_en[i]) begin 
      if (addrMgrConst::io_subsys_owo_en[i] == 1) begin 
        if ($test$plusargs("prod_cons_64B")) begin
          if (addrMgrConst::io_subsys_wdata_a[i] == 512) owo_aiu_funitidq.push_back(addrMgrConst::io_subsys_funitid_a[i]); 
        end else begin 
          owo_aiu_funitidq.push_back(addrMgrConst::io_subsys_funitid_a[i]);
        end 
      end else if (addrMgrConst::io_subsys_nativeif_a[i] inside {"ACE", "ACE5"}) begin 
        ace_aiu_funitidq.push_back(addrMgrConst::io_subsys_funitid_a[i]); 
      end
    end
    owo_aiu_funitidq.shuffle();
    ace_aiu_funitidq.shuffle();

    producer_funitid = owo_aiu_funitidq.pop_front();
    
    foreach(addrMgrConst::io_subsys_funitid_a[i]) begin
      if (addrMgrConst::io_subsys_funitid_a[i] != producer_funitid) begin 
        any_aiu_funitidq.push_back(addrMgrConst::io_subsys_funitid_a[i]);
      end
    end
    any_aiu_funitidq.shuffle();

    if ($test$plusargs("cons_ace")) begin
    	consumer_funitid = ace_aiu_funitidq.pop_front();
    end else if ($test$plusargs("cons_pcie") || $test$plusargs("prod_cons_64B")) begin
	    consumer_funitid = owo_aiu_funitidq.pop_front();
    end else begin 
	    consumer_funitid = any_aiu_funitidq.pop_front();
    end

    match_idxq = {};
    match_idxq = addrMgrConst::io_subsys_funitid_a.find_index(item) with (item inside {producer_funitid, consumer_funitid});
    
    if (match_idxq.size() != 2)
      `uvm_error(get_full_name(), $psprintf("fn:select_producer_consumer should have seen two matches size:%0d", match_idxq.size()));

    if (addrMgrConst::io_subsys_wdata_a[match_idxq[0]] == addrMgrConst::io_subsys_wdata_a[match_idxq[1]]) begin
        prod_cons_same_wdata = 1;
    end
    
    `uvm_info(get_full_name(), $psprintf("fn:select_producer_consumer - producer_funitid:%0d consumer_funitid:%0d num_buffers:%0d buffer_itr:%0d prod_cons_same_wdata:%0d",producer_funitid, consumer_funitid, num_buffers, buffer_itr, prod_cons_same_wdata), UVM_NONE);

  endfunction:select_producer_consumer
  
  task pre_body();
    super.pre_body();
    select_producer_consumer();
    initialize_buffers();
    //`uvm_error(get_full_name(), "End to debug");
  endtask:pre_body;

  task body();
    svt_producer_seq producer_seq;
    svt_consumer_seq consumer_seq;

    `uvm_info(get_full_name(), "Enter body", UVM_LOW);
    foreach(addrMgrConst::io_subsys_nativeif_a[i]) begin: _all_ioaiu_loop_
      if (addrMgrConst::io_subsys_funitid_a[i] == producer_funitid) begin: _producer_
        fork
          automatic int j = i;
            `uvm_info(get_full_name(), $psprintf("Starting svt_producer_seq on inst:%0s nativeif:%0s on mstr_agnt_seqr:%0s", addrMgrConst::io_subsys_instname_a[j], addrMgrConst::io_subsys_nativeif_a[j], mstr_agnt_seqr_str[j]), UVM_LOW);
            producer_seq = svt_producer_seq::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", addrMgrConst::io_subsys_nativeif_a[j].tolower(), addrMgrConst::io_subsys_instname_a[j], j));
            init_producer_consumer_seq_buffers(producer_seq.buffers);
            producer_seq.buffer_itr = buffer_itr;
            producer_seq.start(mstr_agnt_seqr_a[j], this);
        join_none
      end: _producer_
      else if(addrMgrConst::io_subsys_funitid_a[i] == consumer_funitid) begin: _consumer_
        fork
          automatic int j = i;
          begin
            `uvm_info(get_full_name(), $psprintf("Starting svt_consumer_seq on inst:%0s nativeif:%0s on mstr_agnt_seqr_str:%0s", addrMgrConst::io_subsys_instname_a[j], addrMgrConst::io_subsys_nativeif_a[j], mstr_agnt_seqr_str[j]), UVM_LOW);
            consumer_seq = svt_consumer_seq::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", addrMgrConst::io_subsys_nativeif_a[j].tolower(), addrMgrConst::io_subsys_instname_a[j], j));
            init_producer_consumer_seq_buffers(consumer_seq.buffers);
            consumer_seq.buffer_itr = buffer_itr;
            consumer_seq.start(mstr_agnt_seqr_a[j], this);
          end
        join_none
      end: _consumer_
    end: _all_ioaiu_loop_
    wait fork;

  endtask:body
endclass: io_subsys_snps_pcie_vseq
