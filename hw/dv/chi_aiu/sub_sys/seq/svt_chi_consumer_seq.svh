
class svt_chi_consumer_seq extends svt_chi_rn_transaction_base_sequence;
  `svt_xvm_object_utils(svt_chi_consumer_seq)
  `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

  svt_chi_rn_transaction buffer_rd_txn;
  svt_chi_rn_transaction flag_rd_txn;
  svt_chi_rn_transaction flag_wr_txn;
<% if(obj.testBench == "fsys") { %>
  ncoreConfigInfo::buffer_info_t buffers[];
  int buffer_itr;
<% } else { %>
  io_subsys_snps_pcie_vseq parent_seq;
  io_subsys_snps_pcie_vseq vseq;
<% } %>
  typedef struct packed {
    bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] araddr;
    int unsigned arlen;
    int unsigned arsize;
  } rd_txn_t;
  typedef rd_txn_t rd_txn_queue_t[$];

  function new(string name = "svt_chi_consumer_seq");
    super.new(name);
    this.set_response_queue_depth(-1);
  endfunction: new
  
  virtual task pre_body();
    super.pre_body();
  endtask:pre_body;

  virtual task body();
    int i=0;
    int axid;
    svt_chi_rn_transaction flag_wr_txn;
    bit success;
    `uvm_info(get_full_name(), $sformatf("Entered body ..."), UVM_LOW)

<% if(obj.testBench != "fsys") { %>
    success = $cast(parent_seq,this.get_parent_sequence());
    `uvm_info(get_name(), $sformatf("success:%0b", success), UVM_LOW);

    if (parent_seq == null) begin 
      `uvm_error(get_full_name(), "Failed to get parent sequence handle");
    end else begin
      `uvm_info(get_full_name(), $sformatf("Got parent sequence:%0s", parent_seq.get_name()), UVM_LOW);
    end
<% } %>

<% if(obj.testBench == "fsys") { %>
    for(int i = 0; i < buffers.size(); i++) begin
<% } else { %>
    for(int i = 0; i < parent_seq.buffers.size(); i++) begin
<% } %>
      fork
        automatic int j=i;
        read_buffer(j);
      join_none
    end
    wait fork;

    `uvm_info(get_full_name(), $sformatf("Exited body ..."), UVM_LOW)
  endtask:body

  extern task read_buffer(int buffer_idx);
  extern function automatic rd_txn_queue_t generate_cacheline_rd_txns(input bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] start_addr, input int unsigned bus_width_bytes);
endclass:svt_chi_consumer_seq

task svt_chi_consumer_seq::read_buffer(int buffer_idx);
  svt_chi_rn_transaction flag_rd_txn[int], flag_wr_txn[int], buffer_rd_txn[int];
  int i = 0;
  int axid, page_offset;
  int num_remaining_cachelines;
  int match_idxq[$];
  rd_txn_queue_t rd_txns; 
  bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] next_cacheline_addr;
  svt_chi_rn_transaction buffer_rd_txns_starting_cacheline[];

  `uvm_info(get_full_name(), $sformatf("fn:read_buffer buffer_idx:%0d Start", buffer_idx), UVM_LOW)
  do
  begin
    i++;
    //`uvm_info(get_full_name(), $sformatf("fn:read_buffer buffer_idx:%0d i:%0d flag read until it reads 1...", buffer_idx, i), UVM_LOW)
    `svt_xvm_do_with(flag_rd_txn[buffer_idx],
    {
     xact_type == svt_chi_rn_transaction::READONCE;
<% if(obj.testBench == "fsys") { %>
     addr == buffers[buffer_idx].flag_addr;
<% } else { %>
     addr == parent_seq.buffers[buffer_idx].flag_addr;
<% } %>
     snp_attr_is_snoopable == 1'b1;
     data_size == svt_chi_rn_transaction::SIZE_64BYTE;
     is_non_secure_access == 0;
    })
    flag_rd_txn[buffer_idx].wait_end();
    get_response(rsp, flag_rd_txn[buffer_idx].get_transaction_id());
    //rsp.print();
    //`uvm_info(get_full_name(), $sformatf("fn:read_buffer buffer_idx:%0d flag read attempt i:%0d flag read Got data:0x%0h", buffer_idx, i, rsp.data[7:0]), UVM_LOW)
  end while((rsp.data[7:0] != 'hff) && (i < 500));

  if (i == 500)
    `uvm_error(get_full_name(), $sformatf("fn:read_buffer buffer_idx:%0d 500 attempts made to read flag address so investigate further", buffer_idx))

  //if (cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE) begin 
<% if(obj.testBench == "fsys") { %>
        if (buffers[buffer_idx].start_addr % 64 != 0) begin: _rest_of_starting_cacheline_read_
		//rd_txns = generate_cacheline_rd_txns(buffers[buffer_idx].start_addr, (cfg.data_width/8));	
		//foreach (rd_txns[i]) begin 
			//`uvm_info(get_full_name(), $sformatf("remaining_bytes_read_ofstart_addr_for_ace idx:%0d addr:0x%0h len:%0d size:%0d", i, rd_txns[i].araddr, rd_txns[i].arlen, rd_txns[i].arsize), UVM_LOW)
		//end
    		rd_txn_t txn = '{default:0};
	        txn.araddr = buffers[buffer_idx].start_addr;
		txn.arsize = 1;
		txn.arlen = 1;
		rd_txns.push_back(txn);
		next_cacheline_addr = buffers[buffer_idx].start_addr + 64;
	end: _rest_of_starting_cacheline_read_
	else begin: _start_addr_is_cache_aligned_ 
		next_cacheline_addr = buffers[buffer_idx].start_addr;
	end: _start_addr_is_cache_aligned_
<% } else { %>
        if (parent_seq.buffers[buffer_idx].start_addr % 64 != 0) begin: _rest_of_starting_cacheline_read_
		//rd_txns = generate_cacheline_rd_txns(parent_seq.buffers[buffer_idx].start_addr, (cfg.data_width/8));	
		//foreach (rd_txns[i]) begin 
			//`uvm_info(get_full_name(), $sformatf("remaining_bytes_read_ofstart_addr_for_ace idx:%0d addr:0x%0h len:%0d size:%0d", i, rd_txns[i].araddr, rd_txns[i].arlen, rd_txns[i].arsize), UVM_LOW)
		//end
    		rd_txn_t txn = '{default:0};
	        txn.araddr = parent_seq.buffers[buffer_idx].start_addr;
		txn.arsize = 1;
		txn.arlen = 1;
		rd_txns.push_back(txn);
		next_cacheline_addr = parent_seq.buffers[buffer_idx].start_addr + 64;
	end: _rest_of_starting_cacheline_read_
	else begin: _start_addr_is_cache_aligned_ 
		next_cacheline_addr = parent_seq.buffers[buffer_idx].start_addr;
	end: _start_addr_is_cache_aligned_
<% } %>
	
	next_cacheline_addr[5:0] = 0;
	page_offset = next_cacheline_addr % 4096;

	num_remaining_cachelines = (4096 - page_offset)/64;
	for(int i = 0; i < num_remaining_cachelines; i++) begin 
    		rd_txn_t txn = '{default:0};
	        txn.araddr = next_cacheline_addr + i*64;
		txn.arsize = 1;
		txn.arlen = 1;
		rd_txns.push_back(txn);
	end
	foreach (rd_txns[i]) begin 
    		//`uvm_info(get_full_name(), $sformatf("entire_page_read_for_ace idx:%0d addr:0x%0h len:%0d size:%0d", i, rd_txns[i].araddr, rd_txns[i].arlen, rd_txns[i].arsize), UVM_LOW)
	end
	buffer_rd_txns_starting_cacheline = new[rd_txns.size()];
  //end
  `uvm_info(get_full_name(), $sformatf("fn:read_buffer buffer_idx:%0d Initiating buffer read", buffer_idx), UVM_LOW)
  //`uvm_error(get_name(), $sformatf("End to debug"))

   //axid = (1 << ncoreConfigInfo::AXID_WIDTH) - (buffer_idx + 1) ;
    

   //if (cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE)  begin: _ace_
      for(int i = 0; i < rd_txns.size(); i++) begin
   	`svt_xvm_do_with(buffer_rd_txns_starting_cacheline[i],
        {
        xact_type == svt_chi_rn_transaction::READONCE;
        addr == rd_txns[i].araddr;
        snp_attr_is_snoopable == 1'b1;
        data_size == svt_chi_rn_transaction::SIZE_64BYTE;
        is_non_secure_access == 0;
        })
      end
      fork
        begin
          for (int i = 0;i < rd_txns.size();i++) begin 
     	     buffer_rd_txns_starting_cacheline[i].wait_end();
          end  
        end 
      join
   //end: _ace_

     // if (parent_seq.prod_cons_same_wdata == 1) begin
     //   match_idxq = {};
     //   match_idxq = parent_seq.buffer_wr_txnq.find_last_index(item) with (item.addr == buffer_rd_txn[buffer_idx].addr);
     // 
     //   if (match_idxq.size() == 0)
     //     `uvm_error(get_name(), $sformatf("fn:read_buffer buffer_idx:%0d buffer read, cannot find matching buffer write to compare", buffer_idx))
     //   else 
     //     `uvm_info(get_name(), $sformatf("fn:read_buffer buffer_idx:%0d buffer read, matched buffer write at idx:%0d to compare", buffer_idx, match_idxq[0]), UVM_LOW)

     //   data_integrity_check(buffer_rd_txn[buffer_idx], parent_seq.buffer_wr_txnq[match_idxq[0]]);
     // end
   
    `svt_xvm_do_with(flag_wr_txn[buffer_idx],
      {
       xact_type == svt_chi_rn_transaction::WRITEUNIQUEFULL;
<% if(obj.testBench == "fsys") { %>
       addr == buffers[buffer_idx].flag_addr;
<% } else { %>
       addr == parent_seq.buffers[buffer_idx].flag_addr;
<% } %>
       snp_attr_is_snoopable == 1'b1;
       data_size == svt_chi_rn_transaction::SIZE_64BYTE;
       is_non_secure_access == 0;
       data[0] == 'h00;
      })

endtask:read_buffer
