class ncore_apb_debug_test extends ncore_sys_test;
  `uvm_component_utils(ncore_apb_debug_test);
  
  ncore_apb_debug_vseq apb_vseq;
  
  function new (string name="ncore_apb_debug_test", uvm_component parent);
    super.new (name, parent);
  endfunction : new
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction: build_phase
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    apb_vseq = ncore_apb_debug_vseq::type_id::create("apb_vseq");
    apb_vseq.regmodel = env.regmodel;
    apb_vseq.debug_regmodel = env.debug_m_regs;
    <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
        apb_vseq.chi_sequencer<%=idx%> = env.m_aiuChiMstAgent<%=idx%>.sequencer; 
    <%}%>
   `uvm_info(get_name(), "Starting ncore_apb_debug_test", UVM_LOW)
    apb_vseq.start(null);
   `uvm_info(get_name(), "Done ncore_apb_debug_test", UVM_LOW)
    phase.drop_objection(this);
  endtask: run_phase

endclass: ncore_apb_debug_test

