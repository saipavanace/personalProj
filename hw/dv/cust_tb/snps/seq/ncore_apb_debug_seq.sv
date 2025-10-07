<%const chipletObj = obj.lib.getAllChipletRefs();%>

<%
//Embedded javascript code to figure number of blocks
  var _child_blkid = [];
  var _child_blk   = [];
  var nGPRA = 0;
  var chiaiu_idx = 0;
  var ioaiu_idx  = 0;
  var aceaiu_idx = 0;
  var has_chib  = 0;
  var has_chia  = 0;
  var has_chie  = 0;
  var has_ace  = 0;
  var nACE = 0;
  var nCHI = 0;


  for(var pidx = 0; pidx < chipletObj[0].nAIUs; pidx++) {
    if((chipletObj[0].AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(chipletObj[0].AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(chipletObj[0].AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
      _child_blkid[pidx] = 'chiaiu' + chiaiu_idx;
      _child_blk[pidx]   = 'chiaiu';
      chiaiu_idx++;
    if(chipletObj[0].AiuInfo[pidx].fnNativeInterface == 'CHI-A') {
      has_chia  = 1;
    }
    if(chipletObj[0].AiuInfo[pidx].fnNativeInterface == 'CHI-B') {
      has_chib  = 1;
    }
    if(chipletObj[0].AiuInfo[pidx].fnNativeInterface == 'CHI-E') {
      has_chie  = 1;
    }
    } else {
      _child_blkid[pidx] = 'ioaiu' + ioaiu_idx;
      _child_blk[pidx]   = 'ioaiu';
      ioaiu_idx += chipletObj[0].AiuInfo[pidx].nNativeInterfacePorts;
    }
    if((chipletObj[0].AiuInfo[pidx].fnNativeInterface == 'ACE') || (chipletObj[0].AiuInfo[pidx].fnNativeInterface == 'ACE5') ){
      aceaiu_idx += chipletObj[0].AiuInfo[pidx].nNativeInterfacePorts;
      has_ace  = 1 ;
    } 
  
  } 

  nGPRA = chipletObj[0].AiuInfo[0].nGPRA;
  nACE = aceaiu_idx;
  nCHI = chiaiu_idx;

%>
<% if(chiaiu_idx != 0) { %>
//===================================================================================
class ncore_apb_debug_seq extends svt_chi_rn_transaction_base_sequence;
//===================================================================================
  local svt_chi_rn_agent my_agent;
  
   /** UVM Object Utility macro */
  `uvm_object_utils(ncore_apb_debug_seq)
  
    /** Class Constructor */
  extern function new(string name="ncore_apb_debug_seq");
  
  /** Node configuration obtained from the sequencer */
  svt_chi_node_configuration cfg;
  
  /** Parameter that controls the number of transactions that will be generated */
  rand int unsigned sequence_length;
  
  
  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length == 10;
  }
  bit[<%=chipletObj[0].wSysAddr-1%>:0] start_addr = 'h0;
  int transaction = 0;
  bit [5:0] cache_value = 5'h0;
  bit [3:0] qos_value = 4'h0;
  string coherent_command = "READNOSNOOP";
  int master_id = 0;
  int addr_incr = 'h40;
  int addr_offset = 'h0;
  bit trace_tag_val = 1'b0;

  ncore_config_pkg::ncoreConfigInfo::sys_addr_csr_t csrq[$];

  `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

  function bit[<%=chipletObj[0].wSysAddr-1%>:0] get_intlv_address(bit[<%=chipletObj[0].wSysAddr-1%>:0] addr, int mid);
    // If interleaving is enabled, find the addr
    <%if(chipletObj[0].initiatorGroups.length > 0){%>
        <%chipletObj[0].initiatorGroups.forEach((group) => {%>
            <%if(group.aPrimaryAiuPortBits.length > 0){%>
                <%group.fUnitIds.forEach((funitid) => {%>
                    if (mid == <%=funitid%>) begin
                      addr[<%=group.aPrimaryAiuPortBits[group.aPrimaryAiuPortBits.length-1]%>:<%=group.aPrimaryAiuPortBits[0]%>] = (mid%(<%=group.fUnitIds.length%>));
                    end
                <%})%>
            <%}%>
        <%});%>
    <%}%>
    return addr;
  endfunction: get_intlv_address

  virtual task body();
    svt_chi_rn_transaction read_tran[];
    int num_completed_perf_intervals_for_master;
    bit status;
    `SVT_XVM(component) my_component;

/** BANDWIDTH_TEST time variable  */
    time seq_begin_time1, seq_begin_time2, seq_begin_time3, seq_begin_time4;
    time seq_end_time1, seq_end_time2, seq_end_time3, seq_end_time4;
    shortreal bandwidth1, bandwidth2, bandwidth3, bandwidth4;
    super.body();

    my_component = p_sequencer.get_parent();
    void'($cast(my_agent,my_component));

    read_tran = new[sequence_length];

    repeat(100) @(posedge ncore_system_tb_top.sys_clk);
    for (int i=0; i < sequence_length; i++) begin
      fork
         automatic int idx0 = i;
	  
         /** Set up the read transaction */
         `uvm_create(read_tran[idx0])
         read_tran[idx0].cfg = this.cfg;
         read_tran[idx0] = new($sformatf("read_tran_%0d",idx0));
         `svt_xvm_do_with(read_tran[idx0],
            {
              addr             == get_intlv_address((start_addr + addr_offset + (addr_incr * idx0)), master_id);
              addr[5:0]        == 0;
              txn_id           == idx0%64;
              qos              == qos_value;
	      // have to set to "0" for GPU (DATA_SECURE_NORMAL) snoop CPU cache.
              is_non_secure_access == 1'b0;
              data_size        == svt_chi_transaction::SIZE_64BYTE;
              xact_type        == transaction;
              byte_enable      == {`SVT_CHI_MAX_BE_WIDTH{1'b1}};
              is_likely_shared  == cache_value[0];
              snp_attr_is_snoopable    == cache_value[1];
              mem_attr_is_early_wr_ack_allowed == cache_value[2];
              mem_attr_is_cacheable    == cache_value[3];
              mem_attr_allocate_hint   == cache_value[4];
              exp_comp_ack     == cache_value[5];
              snp_attr_snp_domain_type == svt_chi_transaction::INNER;
              mem_attr_mem_type        == svt_chi_transaction::NORMAL;
              order_type == svt_chi_transaction::NO_ORDERING_REQUIRED;
              trace_tag == trace_tag_val;
            })
	  
         // add for BANDWIDTH_TEST
         if(idx0 == 0)
           seq_begin_time1 =  $time;
	  
         /** Wait for the write transaction to complete */
         read_tran[idx0].wait_end();
      join_none
    end
    wait fork; //waiting for the completion of active fork threads

    for (int i=0; i < sequence_length; i++) begin
      if(read_tran[i].response_resp_err_status==2 || read_tran[i].response_resp_err_status==3)begin
         read_tran[i].print();
        `uvm_error("body", $sformatf("Unexpected resp error is %0d", read_tran[i].response_resp_err_status));
      end else begin
        `uvm_info("body", $sformatf("resp error is %0d", read_tran[i].response_resp_err_status),UVM_DEBUG);
      end 
    end

    // add for BANDWIDTH_TEST
    seq_end_time1   =  $time;
    bandwidth1 =(sequence_length*64*1000000)/(seq_end_time1-seq_begin_time1);
    
    `uvm_info("body", $sformatf("==============================================================="), UVM_LOW);
    `uvm_info("body", $sformatf("TEST Results"), UVM_LOW);
    `uvm_info("body", $sformatf("==============================================================="), UVM_LOW);
    `uvm_info("body", $sformatf("BANDWIDTH CAIU%0d %s :%.2f MB/s",master_id,coherent_command,bandwidth1), UVM_LOW);
    
    // Wait for NBA region to elapse so that the metrics are collected for any transactions ending at the same time.
     uvm_wait_for_nba_region();
    
    `uvm_info("body", "Exiting...", UVM_LOW)
  endtask: body

endclass: ncore_apb_debug_seq

function ncore_apb_debug_seq::new(string name="ncore_apb_debug_seq");
  super.new(name);
  //Set the response depth to -1, to accept infinite number of responses
  this.set_response_queue_depth(-1);
endfunction
<% } %>




