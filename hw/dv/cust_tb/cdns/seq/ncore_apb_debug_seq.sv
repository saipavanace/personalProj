class ncore_apb_debug_seq extends cdnChiUvmSequence;
  
   /** UVM Object Utility macro */
  `uvm_object_utils(ncore_apb_debug_seq)
  
    myChiTransaction writeReq;
    myChiTransaction readReq;
    ral_sys_ncore model;
    bit write_req = 'b0;
    int txn_id;
  int master_id = 0;
  int addr_incr = 'h40;
  int addr_offset = 'h0;
  bit trace_tag_val = 1'b0;

    rand bit[<%=obj.wSysAddr-1%>:0] start_addr = 'h0;
    uvm_sequence_item item;

    int cache_value = 0;
    rand denaliChiReqOpCodeT tx_OpCode;
    rand int unsigned sequence_length;

  ncore_config_pkg::ncoreConfigInfo::sys_addr_csr_t csrq[$];


  constraint reasonable_sequence_length {
    sequence_length == 10;
  }

	function new(string name = "ncore_apb_debug_seq");
		super.new(name);
	endfunction : new 
  function bit[<%=obj.wSysAddr-1%>:0] get_intlv_address(bit[<%=obj.wSysAddr-1%>:0] addr, int mid);
    // If interleaving is enabled, find the addr
    <%if(obj.initiatorGroups.length > 0){%>
        <%obj.initiatorGroups.forEach((group) => {%>
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
    int num_completed_perf_intervals_for_master;
    bit status;
    time seq_begin_time1, seq_begin_time2, seq_begin_time3, seq_begin_time4;
    time seq_end_time1, seq_end_time2, seq_end_time3, seq_end_time4;
    shortreal bandwidth1, bandwidth2, bandwidth3, bandwidth4;
    super.body();

        `uvm_info("BASE_SEQ", "Starting ncore_apb_debug_seq", UVM_LOW);
    //repeat(100) @(posedge tb_top.sys_clk);
        for (int i=0; i<sequence_length; i++) begin
      fork
         automatic int idx0 = i;
         `uvm_create(readReq)
		`uvm_do_with(readReq,  {
				readReq.ReqOpCode == tx_OpCode;
                readReq.Addr == get_intlv_address((start_addr + addr_offset + (addr_incr * idx0)), master_id);
                readReq.TxnID == txn_id;
                readReq.MemAttr == (cache_value[4] ? 'hd : 'h5 ) ;
			})
		get_response(item, readReq.get_transaction_id());
         if(idx0 == 0)
           seq_begin_time1 =  $time;
	  
         /** Wait for the write transaction to complete */
      join_none
    end
    wait fork; //waiting for the completion of active fork threads
        readReq.print();
        if (!$cast(readReq, item)) 
        `uvm_fatal(get_type_name(), "$cast(readReq, item) call failed!");
		 #1000;
        `uvm_info("BASE_SEQ", "Finished ncore_apb_debug_seq", UVM_LOW);
    endtask

endclass: ncore_apb_debug_seq
