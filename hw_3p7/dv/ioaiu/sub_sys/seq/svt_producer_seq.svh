//=====================================================================================================================================
// svt_sequence <-- svt_axi_master_base_sequence <-- svt_producer_seq
/*
 *  This sequence implements pcie producer traffic as described in CONC-15271.
 */
//====================================================================================================================================
typedef class io_subsys_snps_pcie_vseq;

class svt_producer_seq extends svt_axi_master_base_sequence;
  `svt_xvm_object_utils(svt_producer_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)

  bit single_beat;
  addrMgrConst::buffer_info_t buffers[];
  int buffer_itr;

  function new(string name = "svt_producer_seq");
    super.new(name);
  endfunction: new

  virtual task pre_body();
    super.pre_body();
    if ($test$plusargs("single_beat")) begin
      single_beat = 1;
    end
//    `uvm_info(get_full_name(), $psprintf("fn:populate_buffer_addrq - Printing bufferq in producer seq"), UVM_LOW);
//    foreach(buffers[i]) begin
//      `uvm_info(get_full_name(), $psprintf("Index:%0d | FlagAddr:0x%0h | PageStartAddr:0x%0h | StartAddr:0x%0h | 32B_bus --> Len:%0d Size:%0d | 64B_bus --> Len:%0d Size:%0d", i, buffers[i].flag_addr, buffers[i].page_start_addr, buffers[i].start_addr, buffers[i].len_32B_bus, buffers[i].size_32B_bus, buffers[i].len_64B_bus, buffers[i].size_64B_bus), UVM_LOW);
//    end

    //`uvm_error(get_full_name(), "End to debug");
  endtask:pre_body;
  
  virtual task body();
    svt_axi_master_transaction flag_wr_txn;
    bit success;
    //`uvm_info(get_full_name(), $sformatf("Entered body ..."), UVM_LOW)

    //This is basically an init sequence code that is initializing all the flag addresses to 0;
    `svt_xvm_do_with(flag_wr_txn,
     {
       addr == buffers[0].flag_addr;
       prot_type[1] == 0;
       if (port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE) {
         xact_type == svt_axi_transaction::COHERENT;
         if (addrMgrConst::is_dce_addr(buffers[0].flag_addr)) {
            coherent_xact_type == svt_axi_transaction::WRITEUNIQUE;
         } else {
            coherent_xact_type == svt_axi_transaction::WRITENOSNOOP;
            domain_type == svt_axi_transaction::SYSTEMSHAREABLE;
         }
       } else {
        xact_type == svt_axi_transaction::WRITE;
       }
       if (port_cfg.data_width == 512) {
        burst_length == 1;
        burst_size == 6;
       } else {
        burst_length == 2;
        burst_size == 5;
        }
       foreach(wstrb[index]){
          wstrb[index] == (1<<(1<<(burst_size)))-1;
          data[index] == 0;
        }
     })
    flag_wr_txn.wait_for_transaction_end();
    `uvm_info(get_full_name(), $sformatf("init sequence to write flag_addr=0 completed ..."), UVM_LOW)
    //--------------------------------------------------------------------

    for (int m = 0; m < buffer_itr; m++) begin
      for(int i = 0; i < buffers.size(); i++) begin
        fork
        automatic int j=i;
        automatic int n=m;
        begin
          `uvm_info(get_full_name(), $sformatf("write_buffer[%0d,%0d] process begins...",n,j), UVM_LOW)
          write_buffer(n,j);
          `uvm_info(get_full_name(), $sformatf("write_buffer[%0d,%0d] process over...",n,j), UVM_LOW)
        end
        join_none
      end
      wait fork;
    end
    //`uvm_info(get_name(), $sformatf("Exited body ..."), UVM_LOW)
  endtask:body

  extern task write_buffer(int buffer_itr, int buffer_idx);

endclass: svt_producer_seq

task svt_producer_seq::write_buffer(int buffer_itr, int buffer_idx);
    svt_axi_master_transaction flag_rd_txn[int], flag_wr_txn[int], buffer_wr_txn[int];
    int i = 0;

    `uvm_info(get_name(), $sformatf("fn:write_buffer buffer_itr:%0d buffer_idx:%0d Start", buffer_itr, buffer_idx), UVM_LOW)
    do
    begin
      i++;
      `svt_xvm_do_with(flag_rd_txn[buffer_idx],
      {
      addr == buffers[buffer_idx].flag_addr;
      prot_type[1] == 0;
      if (port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE) {
        xact_type == svt_axi_transaction::COHERENT;
        if (addrMgrConst::is_dce_addr(buffers[buffer_idx].flag_addr)) {
            coherent_xact_type == svt_axi_transaction::READONCE;
        } else {
            coherent_xact_type == svt_axi_transaction::READNOSNOOP;
            domain_type == svt_axi_transaction::SYSTEMSHAREABLE;
        }
      } else{
        xact_type == svt_axi_transaction::READ;
      }
       burst_length == 1;
       burst_size == 0;
      })
      flag_rd_txn[buffer_idx].wait_for_transaction_end();
      get_response(rsp, flag_rd_txn[buffer_idx].get_transaction_id());
      `uvm_info(get_name(), $sformatf("fn:write_buffer buffer_itr:%0d buffer_idx:%0d flag read Attempt i:%0d, addr:0x%0h Need to read 'h00,  Got data:0x%0h", buffer_itr, buffer_idx, i, flag_rd_txn[buffer_idx].addr, rsp.data[0]), UVM_LOW)
    end while((rsp.data[0] != 0) && (i < 500));

    if (i == 500)
      `uvm_error(get_name(), $sformatf("fn:write_buffer buffer_itr:%0d buffer_idx:%0d 500 attempt made to read flag address so investigate further", buffer_itr, buffer_idx))
    else 
      `uvm_info(get_name(), $sformatf("fn:write_buffer buffer_itr:%0d buffer_idx:%0d read flag address:%0h success on attempt:%0d", buffer_itr, buffer_idx, flag_rd_txn[buffer_idx].addr, i), UVM_LOW)


    `uvm_info(get_name(), $sformatf("fn:write_buffer buffer_itr:%0d buffer_idx:%0d Initiating buffer write", buffer_itr, buffer_idx), UVM_LOW)
    
    `svt_xvm_do_with(buffer_wr_txn[buffer_idx],
     {
       addr ==buffers[buffer_idx].start_addr;
       prot_type[1] == 0;
       data_before_addr == 0;
       if (port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE) {
        xact_type == svt_axi_transaction::COHERENT;
        if (addrMgrConst::is_dce_addr(buffers[buffer_idx].start_addr)) {
            coherent_xact_type == svt_axi_transaction::WRITEUNIQUE;
        } else {
            coherent_xact_type == svt_axi_transaction::WRITENOSNOOP;
            domain_type == svt_axi_transaction::SYSTEMSHAREABLE;
        }
       } else {
        xact_type == svt_axi_transaction::WRITE;
       }
       if (single_beat == 1) {
        burst_length == 1;
       } else {
        if (port_cfg.data_width == 512) {
          burst_length == buffers[buffer_idx].len_64B_bus;
        } else {
          burst_length == buffers[buffer_idx].len_32B_bus;
        }
       }
        foreach(wstrb[i]) {
          wstrb[i]==(1<<(1<<(burst_size)))-1;
        }
       })

    `uvm_info(get_name(), $sformatf("fn:write_buffer buffer_itr:%0d buffer_idx:%0d Initiating flag write with 'hff", buffer_itr, buffer_idx), UVM_LOW)

    `svt_xvm_do_with(flag_wr_txn[buffer_idx],
     {
       addr == buffers[buffer_idx].flag_addr;
       prot_type[1] == 0;
       id == buffer_wr_txn[buffer_idx].id;
       if (port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE) {
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
          wstrb[index] == (1<<(1<<(burst_size)))-1;
          data[index]  == (1 << `SVT_AXI_MAX_DATA_WIDTH) - 1;
        }
     })
      flag_wr_txn[buffer_idx].wait_for_transaction_end();
      `uvm_info(get_name(), $sformatf("fn:write_buffer buffer_itr:%0d buffer_idx:%0d End", buffer_itr, buffer_idx), UVM_LOW)

endtask:write_buffer

