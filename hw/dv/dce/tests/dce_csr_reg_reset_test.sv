
class dce_csr_reg_reset_test extends dce_base_test;

  `uvm_component_utils(dce_csr_reg_reset_test)
   dce_csr_id_reset_seq id_reset_seq;


  function new(string name = "dce_csr_reg_reset_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction : build_phase

  task run_phase(uvm_phase phase);
     fork
        this.run_main(phase);
        //run_watchdog_timer(phase);
     join
  endtask : run_phase

  task run_main (uvm_phase phase);
     uvm_reg_hw_reset_seq   reg_reset_seq = uvm_reg_hw_reset_seq::type_id::create("reg_reset_seq"); 
     uvm_objection uvm_obj;
     uvm_obj = phase.get_objection();
     uvm_obj.set_drain_time(this, 1us);
      uvm_resource_db#(bit)::set({"REG::",m_env.m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUTAR.get_full_name()}, "NO_REG_TESTS", 1,this);
      uvm_resource_db#(bit)::set({"REG::",m_env.m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUSFMAR.get_full_name()}, "NO_REG_TESTS", 1,this);
     id_reset_seq           = dce_csr_id_reset_seq::type_id::create("id_reset_seq");

     `uvm_info("RUN_PHASE",$sformatf("raise objection "), UVM_LOW)
      phase.raise_objection(this, "Start dce_csr_reg_reset_test run_main");
      reg_reset_seq.model     = m_env.m_regs;
      id_reset_seq.model      = m_env.m_regs;
      reg_reset_seq.start(m_env.m_apb_agent.m_apb_sequencer);
      id_reset_seq.start(m_env.m_apb_agent.m_apb_sequencer);
      phase.drop_objection(this, "Finish dce_csr_reg_reset_test run_main");
     `uvm_info("RUN_PHASE",$sformatf("drop objection "), UVM_LOW)

  endtask : run_main


endclass: dce_csr_reg_reset_test



