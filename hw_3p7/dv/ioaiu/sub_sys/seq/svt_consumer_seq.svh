//=====================================================================================================================================
// svt_sequence <-- svt_axi_master_base_sequence <-- svt_consumer_seq
/*
 *  This sequence implements pcie consumer traffic as described in CONC-15271.
 */
//====================================================================================================================================


class svt_consumer_seq extends svt_axi_master_base_sequence;
  `svt_xvm_object_utils(svt_consumer_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)

  bit producer_consumer_same_wdata;
  bit single_beat;
  addrMgrConst::buffer_info_t buffers[];
  int buffer_itr;
  typedef struct packed {
    bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] araddr;
    int unsigned arlen;
    int unsigned arsize;
  } rd_txn_t;
  typedef rd_txn_t rd_txn_queue_t[$];

  function new(string name = "svt_consumer_seq");
    super.new(name);
  endfunction: new
  
  virtual task pre_body();
    super.pre_body();
    if ($test$plusargs("single_beat")) begin
      single_beat = 1;
    end
  endtask:pre_body;

  virtual task body();
    //`uvm_info(get_full_name(), $sformatf("Entered body ..."), UVM_LOW)

   for(int m = 0; m < buffer_itr; m++) begin
      for(int i = 0; i < buffers.size(); i++) begin
        fork
        automatic int j=i;
        automatic int n=m;
        begin
          `uvm_info(get_full_name(), $sformatf("read_buffer[%0d,%0d] process begins...",n,j), UVM_MEDIUM)
          read_buffer(n,j);
          `uvm_info(get_full_name(), $sformatf("read_buffer[%0d,%0d] process over...",n,j), UVM_MEDIUM)
        end
        join_none
      end
      wait fork;
    end

    //`uvm_info(get_full_name(), $sformatf("Exited body ..."), UVM_LOW)
  endtask:body

  extern task read_buffer(int buffer_itr, int buffer_idx);
  extern function automatic rd_txn_queue_t generate_cacheline_rd_txns(input bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] start_addr, input int unsigned bus_width_bytes);
endclass:svt_consumer_seq

task svt_consumer_seq::read_buffer(int buffer_itr, int buffer_idx);
  svt_axi_master_transaction flag_rd_txn[int], flag_wr_txn[int], buffer_rd_txn[int];
  int i = 0;
  bit buf_rd_reverse;
  int page_offset, buf_start_idx, buf_end_idx;
  int num_remaining_cachelines;
  int match_idxq[$];
  rd_txn_queue_t rd_txns; 
  bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] next_cacheline_addr;
  svt_axi_master_transaction buffer_rd_txns[];

  `uvm_info(get_name(), $sformatf("fn:read_buffer buffer_itr:%0d buffer_idx:%0d Start", buffer_itr, buffer_idx), UVM_LOW)

  do
  begin
    i++;
    `svt_xvm_do_with(flag_rd_txn[buffer_idx],
    {
      addr == buffers[buffer_idx].flag_addr;
      prot_type[1] == 0;
      if (cfg.axi_interface_type inside {svt_axi_port_configuration::ACE_LITE, svt_axi_port_configuration::AXI_ACE}) {
        xact_type == svt_axi_transaction::COHERENT;
        if (addrMgrConst::is_dce_addr(buffers[buffer_idx].flag_addr)) {
            coherent_xact_type == svt_axi_transaction::READONCE;
        } else {
            coherent_xact_type == svt_axi_transaction::READNOSNOOP;
            domain_type == svt_axi_transaction::SYSTEMSHAREABLE;
        }
    } else {
      xact_type == svt_axi_transaction::READ;
    }
     burst_length == 1;
     burst_size == 0;
    })
    flag_rd_txn[buffer_idx].wait_for_transaction_end();
    get_response(rsp, flag_rd_txn[buffer_idx].get_transaction_id());
    `uvm_info(get_name(), $sformatf("fn:read_buffer buffer_itr:%0d buffer_idx:%0d flag read attempt i:%0d addr:0x%0h need to read 'hff,  Got data:0x%0h", buffer_itr, buffer_idx, i, flag_rd_txn[buffer_idx].addr, rsp.data[0]), UVM_LOW)
  end while((rsp.data[0] != 'hff) && (i < 500));

  if (i == 500)
    `uvm_error(get_name(), $sformatf("fn:read_buffer buffer_itr:%0d buffer_idx:%0d 500 attempts made to read flag address so investigate further", buffer_itr, buffer_idx))
  else 
    `uvm_info(get_name(), $sformatf("fn:read_buffer buffer_itr:%0d buffer_idx:%0d read flag address:0x%0h  success on attempt:%0d", buffer_itr, buffer_idx, flag_rd_txn[buffer_idx], i), UVM_LOW)

  if (cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE) begin 
        if (buffers[buffer_idx].start_addr % 64 != 0) begin: _rest_of_starting_cacheline_read_
		rd_txns = generate_cacheline_rd_txns(buffers[buffer_idx].start_addr, (cfg.data_width/8));	
		foreach (rd_txns[i]) begin 
			//`uvm_info(get_full_name(), $sformatf("remaining_bytes_read_ofstart_addr_for_ace idx:%0d addr:0x%0h len:%0d size:%0d", i, rd_txns[i].araddr, rd_txns[i].arlen, rd_txns[i].arsize), UVM_LOW)
		end
		next_cacheline_addr = buffers[buffer_idx].start_addr + 64;
	end: _rest_of_starting_cacheline_read_
	else begin: _start_addr_is_cache_aligned_ 
		next_cacheline_addr = buffers[buffer_idx].start_addr;
	end: _start_addr_is_cache_aligned_
	
  if (!single_beat) begin
    next_cacheline_addr[5:0] = 0;
    page_offset = next_cacheline_addr % 4096;
    num_remaining_cachelines = (4096 - page_offset)/64;
    for(int i = 0; i < num_remaining_cachelines; i++) begin 
          rd_txn_t txn = '{default:0};
            txn.araddr = next_cacheline_addr + i*64;
      txn.arsize = $clog2(cfg.data_width/8);
      txn.arlen = 64/(cfg.data_width/8) - 1;
      rd_txns.push_back(txn);
    end
  end

//	foreach (rd_txns[i]) begin 
//    	`uvm_info(get_name(), $sformatf("fn:read_buffer buffer_itr:%0d buffer_idx:%0d entire_page_read_for_ace_txn_%0d addr:0x%0h len:%0d size:%0d", buffer_itr, buffer_idx, i, rd_txns[i].araddr, rd_txns[i].arlen, rd_txns[i].arsize), UVM_LOW)
//	end
	buffer_rd_txns = new[rd_txns.size()];
  end
  `uvm_info(get_name(), $sformatf("fn:read_buffer buffer_itr:%0d  buffer_idx:%0d Initiating buffer read", buffer_itr, buffer_idx), UVM_LOW)
  //`uvm_error(get_name(), $sformatf("End to debug"))

    buf_start_idx = 0;
    buf_end_idx   = rd_txns.size()-1;

   if ((cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE) && addrMgrConst::is_dce_addr(buffers[buffer_idx].start_addr))  begin: _ace_coh_addr_
      buf_rd_reverse = $urandom_range(0,1);
      for(int i = buf_start_idx; i <= buf_end_idx; i++) begin
        automatic int j;
        if (buf_rd_reverse) begin
          j = buf_end_idx - i;
        end else begin
          j = i;
        end
        `svt_xvm_do_with(buffer_rd_txns[j],
          {
          xact_type == svt_axi_transaction::COHERENT;
          coherent_xact_type == svt_axi_transaction::READONCE;
          addr == rd_txns[j].araddr;
          burst_length == rd_txns[j].arlen + 1;
          burst_size == rd_txns[j].arsize;
          prot_type[1] == 0;
          suspend_master_xact == 0;
        })
      end
      fork
        begin
          for (int i = buf_start_idx;i <= buf_end_idx ;i++) begin 
     	     buffer_rd_txns[i].wait_for_transaction_end();
          end  
        end 
      join
   end: _ace_coh_addr_
   else begin: _non_ace_ 
    `svt_xvm_do_with(buffer_rd_txn[buffer_idx],
      {
        addr == buffers[buffer_idx].start_addr;
        prot_type[1] == 0;
        if (cfg.axi_interface_type inside {svt_axi_port_configuration::ACE_LITE, svt_axi_port_configuration::AXI_ACE}) {
          xact_type == svt_axi_transaction::COHERENT;
          if (addrMgrConst::is_dce_addr(buffers[buffer_idx].start_addr)) {
            coherent_xact_type == svt_axi_transaction::READONCE;
          } else {
            coherent_xact_type == svt_axi_transaction::READNOSNOOP;
            domain_type == svt_axi_transaction::SYSTEMSHAREABLE;
          }
        } else {
          xact_type == svt_axi_transaction::READ;
        }
        if (single_beat == 1) {
          burst_length == 1;
        } else {
          if (cfg.data_width == 512) {
           burst_length == buffers[buffer_idx].len_64B_bus;
          } else if (cfg.data_width == 256) {
           burst_length == buffers[buffer_idx].len_32B_bus;
          }
        }
      })
      buffer_rd_txn[buffer_idx].wait_for_transaction_end();
    end: _non_ace_

    `uvm_info(get_name(), $sformatf("fn:read_buffer buffer_itr:%0d buffer_idx:%0d Initiating flag write with 'h00", buffer_itr, buffer_idx), UVM_LOW)

    `svt_xvm_do_with(flag_wr_txn[buffer_idx],
      {
        addr == buffers[buffer_idx].flag_addr;
        prot_type[1] == 0;
       if (cfg.axi_interface_type inside {svt_axi_port_configuration::ACE_LITE, svt_axi_port_configuration::AXI_ACE}) {
        xact_type == svt_axi_transaction::COHERENT;
        if (addrMgrConst::is_dce_addr(buffers[buffer_idx].flag_addr)) {
            coherent_xact_type == svt_axi_transaction::WRITEUNIQUE;
        } else {
            coherent_xact_type == svt_axi_transaction::WRITENOSNOOP;
            domain_type == svt_axi_transaction::SYSTEMSHAREABLE;
        }
       } else {
        xact_type == svt_axi_transaction::WRITE;
       }
       burst_length == 1;
       burst_size == 0;
       foreach(wstrb[index]){
          wstrb[index]==(1<<(1<<(burst_size)))-1;
        }
        data[0] == 'h00;
      })
      flag_wr_txn[buffer_idx].wait_for_transaction_end();
     `uvm_info(get_name(), $sformatf("fn:read_buffer buffer_itr:%0d buffer_idx:%0d End", buffer_itr, buffer_idx), UVM_LOW)
endtask:read_buffer
  
function automatic svt_consumer_seq::rd_txn_queue_t svt_consumer_seq::generate_cacheline_rd_txns(input bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] start_addr, input int unsigned bus_width_bytes);
  int unsigned max_beats; 
  int unsigned cacheline_size = 64;
  int unsigned max_arsize = $clog2(bus_width_bytes);
  logic [`SVT_AXI_MAX_ADDR_WIDTH:0] addr = start_addr;
  int unsigned used; 
  int unsigned offset_in_line = addr % cacheline_size;
  int unsigned remaining = cacheline_size - offset_in_line;

  rd_txn_queue_t txns = {};
  while (remaining > 0) begin
    rd_txn_t txn = '{default:0};
    txn.araddr = addr;

    max_beats = remaining/bus_width_bytes;

    //`uvm_info(get_full_name(), $sformatf("fn:generate_cacheline_rd_txns addr:0x%0h remaining:%0d bus_width_bytes:%0d max_beats:%0d", addr, remaining, bus_width_bytes, max_beats), UVM_LOW)
    if (max_beats >= 2) begin
      txn.arsize = max_arsize;
      txn.arlen = max_beats - 1;
      txns.push_back(txn);
      used = (1 << txn.arsize) * (txn.arlen + 1);
      addr += used;
      remaining -= used;
    end
    else if (max_beats == 1) begin
      txn.arsize = max_arsize;
      txn.arlen = 0;
      txns.push_back(txn);
      addr += bus_width_bytes;
      remaining -= bus_width_bytes;
    end
    else begin
      for (int s = max_arsize; s >= 0; s--) begin
        if ((1 << s) <= remaining) begin
          txn.arsize = s;
          txn.arlen = 0;
          txns.push_back(txn);
          addr += (1 << s);
          remaining -= (1 << s);
          break;
        end
      end
    end
  end

  return txns;

endfunction: generate_cacheline_rd_txns
