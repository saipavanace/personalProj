//--------------------------------------------------------
// Test : ncore_fsc_ralgen_err_intr_test 
//---------------------------------------------------------
class ncore_fsc_ralgen_err_intr_test extends ncore_sys_test;

    `uvm_component_utils(ncore_fsc_ralgen_err_intr_test)

    ncore_fsc_ralgen_err_intr_seq csr_seq;

    function new(string name = "ncore_fsc_ralgen_err_intr_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction 

    function void build_phase(uvm_phase phase);
        `uvm_info("Build", "Entered Build Phase", UVM_LOW);
        super.build_phase(phase);
        csr_seq = ncore_fsc_ralgen_err_intr_seq::type_id::create("csr_seq");
        `uvm_info("Build", "Exited Build Phase", UVM_LOW);
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        phase.raise_objection(this, "Start RALGEN sequence");
        `uvm_info("run_phase", "Entered...", UVM_LOW)
        csr_seq = ncore_fsc_ralgen_err_intr_seq::type_id::create("csr_seq");
        csr_seq.model = env.regmodel;
        #36000ns;
        //***********************************************
        // Run the reg model sequence
        //***********************************************
        csr_seq.start(null);
        `uvm_info("NCORE", "Running RALGEN sequence",UVM_LOW)
        phase.drop_objection(this, "End RALGEN sequence");
        `uvm_info("run_phase", "Exiting...", UVM_LOW)
    endtask: run_phase


    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction
 

endclass: ncore_fsc_ralgen_err_intr_test
