<%const chipletObj = obj.lib.getAllChipletRefs();%>

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
    //super.run_phase(phase);
    phase.raise_objection(this);
    apb_vseq = ncore_apb_debug_vseq::type_id::create("apb_vseq");
    apb_vseq.regmodel = m_env.regmodel;
    apb_vseq.debug_regmodel = m_env.debug_m_regs;
    <%for(let i=0; i<chipletObj[0].nCHIs; i++){%>
        apb_vseq.chi_rn_sqr<%=i%> = m_env.m_amba_env.chi_system[0].rn[<%=i%>].rn_xact_seqr;
    <%}%>
    apb_vseq.start(null);
    phase.drop_objection(this);
  endtask: run_phase

endclass: ncore_apb_debug_test

