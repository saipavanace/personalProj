
class fn_csr_access_test extends base_test;
    `uvm_component_utils(fn_csr_access_test)
	axi_axaddr_t addr;
    bit [31:0] data;

	function new(string name = "fn_csr_access_test", uvm_component parent=null);
    	super.new(name,parent);
	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction : build_phase

	task run_phase (uvm_phase phase);
		super.run_phase(phase);
		phase.raise_objection(this, "Start_test");
		addr = addrMgrConst::NRS_REGION_BASE ;

    	// Assuming the Reset value of NRSBAR = 0x0 ; Reading USIDR 
    	//addr[19:0] = 20'hFF000;   
    	`uvm_info("IOAIU_BOOT_SEQ", $sformatf("Reading UIDR (0x%0h)", addr), UVM_NONE)
    	read_csr(addr,data);
    	`uvm_info("IOAIU_BOOT_SEQ", $sformatf("UIDR = 0x%0h", data), UVM_NONE)
		#(<%=obj.Clocks[0].params.period%>ps*25);
		phase.drop_objection(this, "Finish_test");
	endtask:run_phase

	virtual function void report_phase(uvm_phase phase);
		super.report_phase(phase);
	endfunction: report_phase

endclass: fn_csr_access_test