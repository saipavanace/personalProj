`ifdef IO_UNITS_CNT_NON_ZERO
class fsys_snps_pcie_producer_consumer_vseq extends fsys_main_traffic_virtual_seq;
`uvm_object_utils(fsys_snps_pcie_producer_consumer_vseq)

  concerto_test_cfg test_cfg;

 // Seq attributes
  svt_axi_master_transaction buffer_wr_txnq[$];
  bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] flag_addrq[$];
  ncoreConfigInfo::buffer_info_t buffers[];
  string flag_mem, buf_mem;
  int producer_funitid, consumer_funitid, num_buffers, buffer_itr; 
  string consumer_type="";
  bit prod_cons_64B=0;
  bit prod_cons_32B=0;
  bit cons_ace=0; 
  bit cons_chi=0; 
  bit cons_pcie=0; 
  bit cons_any_ioaiu=0; 
  bit is_512bits_port_exist_in_cfg;
  bit is_256bits_port_exist_in_cfg;
  int num_owo_in_cfg, num_ace_in_cfg, num_512b_owo_in_cfg, num_256b_owo_in_cfg;
  bit skip_multiport_axi;
  int set_owo_burst_size;

function new(string name = "fsys_snps_pcie_producer_consumer_vseq");

  super.new(name);
  if (!$value$plusargs("num_buffers=%0d",num_buffers)) begin
    num_buffers = $urandom_range(3,15);
  end
  if (!$value$plusargs("buffer_itr=%0d", buffer_itr)) begin 
    buffer_itr = $urandom_range(1, 3); //no benefit going more than 3
  end
  buffers = new[num_buffers];
  if($test$plusargs("skip_multiport_axi")) begin
    skip_multiport_axi = 1;
  end
  if (!$value$plusargs("flag_mem=%0s", flag_mem)) begin
    flag_mem = "any";
  end
  if (!$value$plusargs("buf_mem=%0s", buf_mem)) begin
    buf_mem = "any";
  end

  if($test$plusargs("prod_cons_64B")) begin
      prod_cons_64B = 1;
      foreach(ncoreConfigInfo::io_subsys_owo_en[i]) begin 
        if ((ncoreConfigInfo::io_subsys_owo_en[i] == 1) && (ncoreConfigInfo::io_subsys_wdata_a[i] == 512)) begin 
            is_512bits_port_exist_in_cfg = 1; 
            num_512b_owo_in_cfg = num_512b_owo_in_cfg + 1;
        end
        num_owo_in_cfg = num_owo_in_cfg+1;
      end
      if(num_owo_in_cfg==0)
          `uvm_error(get_full_name(), $psprintf("Invalid configuration for the test. Please provide valid configuration with atleast single IOAIU with OWO enabled."))
      if(num_owo_in_cfg==1) begin
         cons_any_ioaiu = 1; 
      end
      if(is_512bits_port_exist_in_cfg==0) begin
         cons_any_ioaiu = 1; 
         prod_cons_64B = 0;
      end
      void'($value$plusargs("set_owo_burst_size=%0d",set_owo_burst_size)) ;
  end 
  if($test$plusargs("prod_cons_32B")) begin
      prod_cons_32B = 1;
      foreach(ncoreConfigInfo::io_subsys_owo_en[i]) begin 
        if ((ncoreConfigInfo::io_subsys_owo_en[i] == 1) && (ncoreConfigInfo::io_subsys_wdata_a[i] == 256)) begin 
            is_256bits_port_exist_in_cfg = 1; 
            num_256b_owo_in_cfg= num_256b_owo_in_cfg+ 1;
        end
        num_owo_in_cfg = num_owo_in_cfg+1;
      end
      if(num_owo_in_cfg==0)
          `uvm_error(get_full_name(), $psprintf("Invalid configuration for the test. Please provide valid configuration with atleast single IOAIU with OWO enabled."))
      if(num_owo_in_cfg==1) begin
         cons_any_ioaiu = 1; 
      end
      if(is_256bits_port_exist_in_cfg==0) begin
         cons_any_ioaiu = 1; 
         prod_cons_32B = 0;
      end
      void'($value$plusargs("set_owo_burst_size=%0d",set_owo_burst_size)) ;
  end
  if ($test$plusargs("cons_ace")) begin
      cons_ace = 1;
      foreach(ncoreConfigInfo::io_subsys_owo_en[i]) begin 
        if (ncoreConfigInfo::io_subsys_nativeif_a[i] inside {"ACE", "ACE5"}) begin 
            num_ace_in_cfg = num_ace_in_cfg+1;
        end
      end
      if(num_ace_in_cfg==0) begin
         cons_any_ioaiu = 1; 
         cons_ace = 0;
      end
  end else if ($test$plusargs("cons_chi")) begin
      cons_chi = 1;
      if(ncoreConfigInfo::NUM_CHI_MASTERS==0)
          `uvm_error(get_full_name(), $psprintf("Invalid configuration for the test - consumer chi. Please provide valid configuration with atleast single CHIAIU."))
      buffer_itr = 1;
  end else if ($test$plusargs("cons_pcie")) begin 
      cons_pcie = 1;
  end else begin 
      cons_any_ioaiu= 1;
  end

  if(cons_any_ioaiu==1) begin
      if(ncoreConfigInfo::NUM_IO_MASTERS<2)
          `uvm_error(get_full_name(), $psprintf("Invalid configuration for the test. Please provide valid configuration with atleast two IOAIU."))
  end
endfunction

  function int calc_max_burst_len(bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] addr, int beat_bytes, output int size);
    int offset = addr % 4096;
    int avail = 4096 - offset;
    int num_full_beats = avail / beat_bytes;
    int result;

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
    //int memrgn_size = ncoreConfigInfo::memregions_info.size();
    int memrgn_size, idx;
    int counter = 0;
    string flag_mem_q[$];
    bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] flag_addr;
        
    `uvm_info(get_full_name(), $psprintf("buf_size:%0d memrgn_size:%0d buf_mem:%0s flag_mem:%0s", buf_size, memrgn_size, buf_mem, flag_mem), UVM_LOW);

    if (buf_mem == "coh_dmi") begin 
      memrgn_size  = ncoreConfigInfo::dmi_memory_coh_domain_start_addr.size();
    end else if (buf_mem == "dii") begin 
      memrgn_size = ncoreConfigInfo::dii_memory_domain_start_addr.size();
    end else if (buf_mem == "noncoh_dmi" && ncoreConfigInfo::dmi_memory_noncoh_domain_start_addr.size() > 0) begin 
      memrgn_size  = ncoreConfigInfo::dmi_memory_noncoh_domain_start_addr.size();
    end else begin 
      memrgn_size = ncoreConfigInfo::memregions_info.size();
    end
          
    if (buf_size <= memrgn_size) begin
      for (int bidx = 0; bidx < buf_size; bidx++) begin
        if (buf_mem == "coh_dmi") begin 
          buffers[bidx].page_start_addr  = ncoreConfigInfo::dmi_memory_coh_domain_start_addr[bidx];
        end else if (buf_mem == "dii") begin 
          buffers[bidx].page_start_addr  = ncoreConfigInfo::dii_memory_domain_start_addr[bidx];
        end else if (buf_mem == "noncoh_dmi" && ncoreConfigInfo::dmi_memory_noncoh_domain_start_addr.size() > 0) begin 
          buffers[bidx].page_start_addr  = ncoreConfigInfo::dmi_memory_noncoh_domain_start_addr[bidx];
        end else begin 
          buffers[bidx].page_start_addr  = ncoreConfigInfo::memregions_info[bidx].start_addr;
        end
        buffers[bidx].start_addr       = buffers[bidx].page_start_addr;
        if(set_owo_burst_size==0) begin
          buffers[bidx].start_addr[11:0] = $urandom;
        end
      end
    end
    else begin
      for (int bidx = 0; bidx < (buf_size + memrgn_size); bidx = bidx + memrgn_size) begin 
        for (int midx=0; midx < memrgn_size; midx++) begin
          `uvm_info(get_full_name(), $psprintf("bidx:%0d midx:%0d", bidx, midx), UVM_LOW);
          if (buf_mem == "coh_dmi") begin
            buffers[bidx + midx].page_start_addr  = ncoreConfigInfo::dmi_memory_coh_domain_start_addr[midx] + (counter*(4096)); 
          end else if (buf_mem == "noncoh_dmi" && ncoreConfigInfo::dmi_memory_noncoh_domain_start_addr.size() > 0) begin
            buffers[bidx + midx].page_start_addr  = ncoreConfigInfo::dmi_memory_noncoh_domain_start_addr[midx] + (counter*(4096)); 
          end else if (buf_mem == "dii") begin
            buffers[bidx + midx].page_start_addr  = ncoreConfigInfo::dii_memory_domain_start_addr[midx] + (counter*(4096)); 
          end else begin
            buffers[bidx + midx].page_start_addr  = ncoreConfigInfo::memregions_info[midx].start_addr + (counter*(4096)); 
          end
          buffers[bidx + midx].start_addr       = buffers[bidx + midx].page_start_addr;
          if(set_owo_burst_size==0) begin
            buffers[bidx + midx].start_addr[11:0] = $urandom;
          end
        end
        counter++;
      end
    end
           
    if (flag_mem == "coh_dmi") begin
      flag_addr = ncoreConfigInfo::dmi_memory_coh_domain_end_addr[0] - 63;
    end else if (flag_mem == "dii") begin
      flag_addr = ncoreConfigInfo::dii_memory_domain_end_addr[0] - 63;
    end else if ((flag_mem == "noncoh_dmi") && (ncoreConfigInfo::dmi_memory_noncoh_domain_end_addr.size() > 0)) begin
      flag_addr = ncoreConfigInfo::dmi_memory_noncoh_domain_end_addr[0] - 63;
    end else begin
      flag_mem_q = {};
      if (ncoreConfigInfo::dmi_memory_coh_domain_end_addr.size() > 0)
        flag_mem_q.push_back("coh_dmi");
      if (ncoreConfigInfo::dmi_memory_noncoh_domain_end_addr.size() > 0)
        flag_mem_q.push_back("noncoh_dmi");
      if (ncoreConfigInfo::dii_memory_domain_end_addr.size() > 0)
        flag_mem_q.push_back("dii");
      idx = $urandom_range(0, flag_mem_q.size()-1);
      `uvm_info(get_full_name(), $psprintf("Randomly selected flag_mem:%0s", flag_mem_q[idx]), UVM_LOW);
      if(flag_mem_q[idx] == "coh_dmi") begin
        flag_addr = ncoreConfigInfo::dmi_memory_coh_domain_end_addr[0] - 63;
      end else if (flag_mem_q[idx] == "dii") begin
        flag_addr = ncoreConfigInfo::dii_memory_domain_end_addr[0] - 63;
      end else if (flag_mem_q[idx] == "noncoh_dmi") begin
        flag_addr = ncoreConfigInfo::dmi_memory_noncoh_domain_end_addr[0] - 63;
      end
    end 
   
    for (int bidx = 0; bidx < buf_size; bidx++) begin 
      if (bidx == 0) begin
        buffers[bidx].flag_addr = flag_addr;
      end else begin
        buffers[bidx].flag_addr = buffers[bidx-1].flag_addr + 1;
      end
      //buffers[bidx].len_32B_bus = 4;
      //buffers[bidx].len_64B_bus = 4; 
      //this is max burst_length else we will violate 4KB byte boundary
      if(set_owo_burst_size==0) begin
        buffers[bidx].len_32B_bus = calc_max_burst_len(buffers[bidx].start_addr, 32, buffers[bidx].size_32B_bus);
        buffers[bidx].len_64B_bus = calc_max_burst_len(buffers[bidx].start_addr, 64, buffers[bidx].size_64B_bus);
      end else begin
        buffers[bidx].size_32B_bus = $clog2(32);
        buffers[bidx].size_64B_bus = $clog2(64);
        buffers[bidx].len_32B_bus = set_owo_burst_size/32;
        buffers[bidx].len_64B_bus = set_owo_burst_size/64;
      end
    end

    `uvm_info(get_full_name(), $psprintf("fn:populate_buffer_addrq - Printing bufferq"), UVM_LOW);
    foreach(buffers[i]) begin
      `uvm_info(get_full_name(), $psprintf("Index:%0d | FlagAddr:0x%0h | PageStartAddr:0x%0h | StartAddr:0x%0h | 32B_bus --> Len:%0d Size:%0d | 64B_bus --> Len:%0d Size:%0d", i, buffers[i].flag_addr, buffers[i].page_start_addr, buffers[i].start_addr, buffers[i].len_32B_bus, buffers[i].size_32B_bus, buffers[i].len_64B_bus, buffers[i].size_64B_bus), UVM_LOW);
    end

  endfunction:initialize_buffers

  function init_producer_consumer_seq_buffers(ref ncoreConfigInfo::buffer_info_t seq_buffers[]);
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
  `ifdef CHI_UNITS_CNT_NON_ZERO
  `endif
  `ifdef CHI_UNITS_CNT_NON_ZERO 
    int chi_aiu_funitidq[$];
  `endif
    int ace_aiu_funitidq[$];
    int any_ioaiu_funitidq[$];
   
    foreach(ncoreConfigInfo::io_subsys_owo_en[i]) begin 
      if (ncoreConfigInfo::io_subsys_owo_en[i] == 1) begin 
        if (prod_cons_64B==1) begin
          if(ncoreConfigInfo::io_subsys_wdata_a[i] == 512) owo_aiu_funitidq.push_back(ncoreConfigInfo::io_subsys_funitid_a[i]); 
        end
        else if (prod_cons_32B==1) begin
          if(ncoreConfigInfo::io_subsys_wdata_a[i] == 256) owo_aiu_funitidq.push_back(ncoreConfigInfo::io_subsys_funitid_a[i]); 
        end else begin 
          owo_aiu_funitidq.push_back(ncoreConfigInfo::io_subsys_funitid_a[i]);
        end 
      end else if (ncoreConfigInfo::io_subsys_nativeif_a[i] inside {"ACE", "ACE5"}) begin 
        ace_aiu_funitidq.push_back(ncoreConfigInfo::io_subsys_funitid_a[i]); 
      end
    end

    producer_funitid = owo_aiu_funitidq.pop_front();

    foreach(ncoreConfigInfo::io_subsys_funitid_a[i]) begin
      if (ncoreConfigInfo::io_subsys_funitid_a[i] != producer_funitid) begin 
          if (skip_multiport_axi==0) 
             any_ioaiu_funitidq.push_back(ncoreConfigInfo::io_subsys_funitid_a[i]);
          else if ((skip_multiport_axi==1) && (ncoreConfigInfo::io_multiport[i]==0)) 
             any_ioaiu_funitidq.push_back(ncoreConfigInfo::io_subsys_funitid_a[i]);
      end
    end
    any_ioaiu_funitidq.shuffle();

  `ifdef CHI_UNITS_CNT_NON_ZERO
    for (int i=0;i<ncoreConfigInfo::NUM_CHI_MASTERS;i=i+1) begin
        chi_aiu_funitidq.push_back(i);
    end
  `endif
    owo_aiu_funitidq.shuffle();
    ace_aiu_funitidq.shuffle();
  `ifdef CHI_UNITS_CNT_NON_ZERO
    chi_aiu_funitidq.shuffle();
  `endif


    if (cons_ace==1) begin
    	consumer_funitid = ace_aiu_funitidq.pop_front();
        consumer_type = "ACE";
  `ifdef CHI_UNITS_CNT_NON_ZERO
    end else if (cons_chi==1) begin
    	consumer_funitid = chi_aiu_funitidq.pop_front();
        consumer_type = "CHI";
  `endif
    end else if ((cons_pcie==1) || (prod_cons_64B==1) || (prod_cons_32B==1)) begin 
        do
        begin
	    consumer_funitid = owo_aiu_funitidq.pop_front();
            consumer_type = "IOAIUp";
        end
        while(consumer_funitid == producer_funitid);
    end else begin 
	consumer_funitid = any_ioaiu_funitidq.pop_front();
        consumer_type = "IOAIU";
    end

    `uvm_info(get_full_name(), $psprintf("fn:select_producer_consumer - producer_funitid:%0d consumer_funitid:%0d num_buffers:%0d consumer_type:%0s",producer_funitid, consumer_funitid, num_buffers,consumer_type), UVM_NONE);

  endfunction:select_producer_consumer
  
  task pre_body();
    super.pre_body();
    select_producer_consumer();
    initialize_buffers();
    //`uvm_error(get_full_name(), "End to debug");
  endtask:pre_body;

task body();
    svt_producer_seq io_producer_seq;
    svt_consumer_seq io_consumer_seq;
  `ifdef CHI_UNITS_CNT_NON_ZERO
    svt_chi_consumer_seq chi_consumer_seq;
  `endif

    `uvm_info(get_full_name(), "Starting fsys_snps_pcie_producer_consumer_vseq...",UVM_LOW);
    //super.body();
    fork
    begin
        foreach(ncoreConfigInfo::io_subsys_nativeif_a[i]) begin: _all_ioaiu_loop_
            if (ncoreConfigInfo::io_subsys_funitid_a[i] == producer_funitid) begin: _producer_
              fork
                automatic int j = i;
                begin
                  `uvm_info(get_full_name(), $psprintf("Starting IO svt_producer_seq on inst:%0s nativeif:%0s on mstr_agnt_seqr:%0s", ncoreConfigInfo::io_subsys_instname_a[j], ncoreConfigInfo::io_subsys_nativeif_a[j], ioaiu_traffic_vseq.snps_vseq.mstr_agnt_seqr_str[j]), UVM_LOW);
                  io_producer_seq = svt_producer_seq::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", ncoreConfigInfo::io_subsys_nativeif_a[j].tolower(), ncoreConfigInfo::io_subsys_instname_a[j], j));
                  init_producer_consumer_seq_buffers(io_producer_seq.buffers);
                  io_producer_seq.buffer_itr = buffer_itr;
                  //io_producer_seq.buffers = buffers;
                  io_producer_seq.start(ioaiu_traffic_vseq.snps_vseq.mstr_agnt_seqr_a[j], this);
                  `uvm_info(get_full_name(), $psprintf("Ending IO svt_producer_seq on inst:%0s nativeif:%0s on mstr_agnt_seqr:%0s", ncoreConfigInfo::io_subsys_instname_a[j], ncoreConfigInfo::io_subsys_nativeif_a[j], ioaiu_traffic_vseq.snps_vseq.mstr_agnt_seqr_str[j]), UVM_LOW);
                end
              join_none
            end: _producer_
        end: _all_ioaiu_loop_
        wait fork;
        `uvm_info(get_full_name(), $psprintf("IO svt_producer_seq thread ends"), UVM_LOW)
    end

    begin
      if((consumer_type == "IOAIUp") || (consumer_type == "ACE") || (consumer_type == "IOAIU")) begin : _if_ioaiu_consumer_
        foreach(ncoreConfigInfo::io_subsys_nativeif_a[i]) begin: _all_ioaiu_loop_
            if(ncoreConfigInfo::io_subsys_funitid_a[i] == consumer_funitid) begin: _consumer_
              fork
                automatic int j = i;
                begin
                  `uvm_info(get_full_name(), $psprintf("Starting IO svt_consumer_seq on inst:%0s nativeif:%0s on mstr_agnt_seqr_str:%0s", ncoreConfigInfo::io_subsys_instname_a[j], ncoreConfigInfo::io_subsys_nativeif_a[j], ioaiu_traffic_vseq.snps_vseq.mstr_agnt_seqr_str[j]), UVM_LOW);
                  io_consumer_seq = svt_consumer_seq::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", ncoreConfigInfo::io_subsys_nativeif_a[j].tolower(), ncoreConfigInfo::io_subsys_instname_a[j], j));
                  init_producer_consumer_seq_buffers(io_consumer_seq.buffers);
                  io_consumer_seq.buffer_itr = buffer_itr;
                  //io_consumer_seq.buffers = buffers;
                  io_consumer_seq.start(ioaiu_traffic_vseq.snps_vseq.mstr_agnt_seqr_a[j], this);
                  `uvm_info(get_full_name(), $psprintf("Ending IO svt_consumer_seq on inst:%0s nativeif:%0s on mstr_agnt_seqr_str:%0s", ncoreConfigInfo::io_subsys_instname_a[j], ncoreConfigInfo::io_subsys_nativeif_a[j], ioaiu_traffic_vseq.snps_vseq.mstr_agnt_seqr_str[j]), UVM_LOW);
                end
              join_none
            end: _consumer_
        end: _all_ioaiu_loop_
        wait fork;
        `uvm_info(get_full_name(), $psprintf("IO svt_consumer_seq thread ends"), UVM_LOW)
      end : _if_ioaiu_consumer_
    end
    
  `ifdef CHI_UNITS_CNT_NON_ZERO
    begin
      if(consumer_type == "CHI") begin : _if_chiaiu_consumer_
    <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
        if(consumer_funitid==<%=idx%>) begin
            `uvm_info(get_full_name(), $psprintf("Starting CHI svt_consumer_seq on CHIAIU[<%=idx%>]"), UVM_LOW);
            chi_consumer_seq = svt_chi_consumer_seq::type_id::create("chi_consumer_seq<%=idx%>");
            init_producer_consumer_seq_buffers(chi_consumer_seq.buffers);
            chi_consumer_seq.buffer_itr = buffer_itr;
            chi_consumer_seq.start(chi_traffic_snps_vseq.coh_vseqr.rn_xact_seqr<%=idx%>);
            `uvm_info(get_full_name(), $psprintf("Ending CHI svt_consumer_seq on CHIAIU[<%=idx%>]"), UVM_LOW);
        end
    <%}%>
      end : _if_chiaiu_consumer_
    end
  `endif
    join

    `uvm_info(get_full_name(), "Ending fsys_snps_pcie_producer_consumer_vseq...",UVM_LOW);

endtask: body

endclass: fsys_snps_pcie_producer_consumer_vseq
`endif
