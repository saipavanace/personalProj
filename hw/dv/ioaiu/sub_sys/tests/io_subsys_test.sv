`ifdef USE_VIP_SNPS // Now using this test for synopsys vip sim
class io_subsys_test extends io_subsys_base_test;
    `uvm_component_utils(io_subsys_test)
    io_subsys_snps_vseq vseq;

    function new(string name = "io_subsys_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction:new

    function void build_phase(uvm_phase phase);
        `uvm_info("IO_SUBSYS_TEST", "Enter BUILD_PHASE", UVM_LOW);

        super.build_phase(phase);
       
        `uvm_info("IO_SUBSYS_TEST", "Exit BUILD_PHASE", UVM_LOW);
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        
        `uvm_info("IO_SUBSYS_TEST", "Enter RUN_PHASE", UVM_LOW);
                
        super.run_phase(phase);
        `uvm_info("IO_SUBSYS_TEST", "Exit RUN_PHASE", UVM_LOW);
    endtask:run_phase
    
    task start_sequence();
        `uvm_info("IO_SUBSYS_TEST", "tsk:start_sequence start", UVM_LOW);
                `uvm_info(get_name(), "Starting io_subsys_seq", UVM_NONE)
                vseq = io_subsys_snps_vseq::type_id::create("vseq");
                io_subsys_init_snps_vseq(vseq);
                vseq.start(`SVT_VIRTUAL_SEQR_PATH);
                `uvm_info(get_name(), "Done io_subsys_seq", UVM_NONE)
        `uvm_info("IO_SUBSYS_TEST", "tsk:start_sequence end", UVM_LOW);
    endtask: start_sequence

endclass:io_subsys_test
`endif // USE_VIP_SNPS  Now using this test for synopsys vip sim
