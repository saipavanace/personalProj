class io_subsys_axi_slave_transaction extends svt_axi_slave_transaction; 

    `svt_xvm_object_utils(io_subsys_axi_slave_transaction)
    
     //TODO:make bvalid 40 to 100
`ifdef DIRECTED_TEST_FOR_DII    
    constraint bvalid_dly {
    bvalid_delay == 40;
        reference_event_for_bvalid_delay == svt_axi_transaction::LAST_DATA_HANDSHAKE;
}
`endif
    function new(string name = "io_subsys_axi_slave_transaction");
        super.new(name);    
    endfunction: new

    function void pre_randomize(); 
        super.pre_randomize();
    endfunction: pre_randomize

    function void post_randomize();
        super.post_randomize();
    endfunction: post_randomize	
  endclass
