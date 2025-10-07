class ncore_chi_base_seq extends cdnChiUvmSequence;
    `uvm_object_utils(ncore_chi_base_seq)

    myChiTransaction trans;
    ral_sys_ncore model;
    bit write_req = 'b0;
    int txn_id;

    rand bit[<%=obj.wSysAddr-1%>:0] start_addr = 'h0;
    uvm_sequence_item item;

    int cache_value = 'h0;
    rand denaliChiReqOpCodeT tx_OpCode;
    rand int unsigned sequence_length;

    constraint reasonable_sequence_length {
        sequence_length == 1;
    }

	function new(string name = "ncore_chi_base_seq");
		super.new(name);
	endfunction : new 

    virtual task body();
        super.body();
        $cast(model, this.model);

        `uvm_info("BASE_SEQ", "Starting ncore_chi_base_seq", UVM_LOW);
        for (int i=0; i<sequence_length; i++) begin
            `uvm_do_with(trans,  {
	            ReqOpCode == tx_OpCode;
                Addr == start_addr + 'h40*i;
                TxnID == txn_id;
                MemAttr == (cache_value[4] ? 'hd : 'h5 ) ;
	            StashNIDValid ==0;
    		    Poison ==0;
	        })
	        get_response(item, trans.get_transaction_id());

        if (!$cast(trans, item)) 
        `uvm_fatal(get_type_name(), "$cast(trans, item) call failed!");
        end
        `uvm_info("BASE_SEQ", "Finished ncore_chi_base_seq", UVM_LOW);
    endtask

endclass



